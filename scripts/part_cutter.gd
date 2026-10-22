class_name PartCutter
extends RefCounted
## Turns a creature drawn on one sheet (CreatureSheet) into a pet (.ai/creature-pipeline.md).
##
## Each part type was drawn on its own layer, in place on the creature. A layer becomes parts:
##   - its separate PIECES are separate parts - two eyes drawn, two eyes that blink on their own;
##     ink this close together is one piece (a pupil inside its eye), and stray specks are dropped;
##   - each piece rides on a HOST: face parts on the head they are drawn on (or the body, with no
##     head), hands on an arm, feet and claws on a leg, everything else on the body;
##   - its JOINT is where it touches its host - a leg swings from where it meets the body, an ear
##     wobbles from its base - or its middle for eyes, mouths and noses, which blink, open and
##     twitch about their centre. Drawn not touching anything, it hangs from its nearest point.
## A single wing, ear, horn, antenna, leg, arm or tentacle gets a twin behind it, shaded, for
## depth - the cutout trick the rest of the pipeline uses for far limbs.
##
## Nothing is redrawn or tidied: each part is exactly the kid's pixels, cut out.

## Ink this close is one piece (sheet px): a pupil inside an eye, a dashed line.
const GROUP_GAP := 6
## Pieces with less ink than this are specks, not parts.
const SPECK := 40
## Parts whose joint is their middle rather than where they touch.
const CENTRE_TYPES := ["eye", "mouth", "nose"]
const BODY_ONLY := ["head", "leg", "arm", "wing", "tail", "fin", "tentacle"]
## Tucked behind what they grow from, so the join never shows. (Hair is not: drawn in place, it is
## drawn ON the head, and the kid should see it there.)
const BEHIND := ["tail", "spike", "fin"]


## The separate pieces of a layer (a sheet-sized drawing): [{rect (sheet px), image (just that
## piece's pixels), ink (how many), centre}], left to right.
static func pieces(layer: Image) -> Array:
	var used := layer.get_used_rect()
	if used.size.x < 2 or used.size.y < 2:
		return []
	var region := used.grow(GROUP_GAP + 1).intersection(Rect2i(Vector2i.ZERO, layer.get_size()))
	var sub := layer.get_region(region)
	sub.convert(Image.FORMAT_RGBA8)
	var w := sub.get_width()
	var h := sub.get_height()
	var rgba := sub.get_data()
	var grown_bits := BitMap.new()
	grown_bits.create_from_image_alpha(sub, 0.1)
	grown_bits.grow_mask(GROUP_GAP, Rect2i(0, 0, w, h))
	var grown_img := grown_bits.convert_to_image()
	grown_img.convert(Image.FORMAT_L8)
	var grown := grown_img.get_data()

	# Label the grown ink: one label per island.
	var label := PackedInt32Array()
	label.resize(w * h)
	var boxes := []
	for start in w * h:
		if grown[start] == 0 or label[start] != 0:
			continue
		var id := boxes.size() + 1
		var box := Rect2i(start % w, start / w, 1, 1)
		var stack := PackedInt32Array([start])
		label[start] = id
		while not stack.is_empty():
			var i := stack[stack.size() - 1]
			stack.remove_at(stack.size() - 1)
			var x := i % w
			var y := i / w
			box = box.expand(Vector2i(x, y))
			for n in [i - 1 if x > 0 else -1, i + 1 if x < w - 1 else -1, i - w if y > 0 else -1,
					i + w if y < h - 1 else -1]:
				if n >= 0 and grown[n] != 0 and label[n] == 0:
					label[n] = id
					stack.append(n)
		boxes.append(box)

	# Islands whose boxes overlap are one piece: an eye's highlight drawn just apart from it.
	var group := range(boxes.size() + 1)
	var merged := true
	while merged:
		merged = false
		for a in boxes.size():
			for b in range(a + 1, boxes.size()):
				var ga := _root(group, a + 1)
				var gb := _root(group, b + 1)
				if ga != gb and (boxes[a] as Rect2i).grow(2).intersects(boxes[b]):
					group[gb] = ga
					merged = true

	# Each piece: its own ink only, cropped.
	var by_root := {}
	for i in w * h:
		if rgba[i * 4 + 3] <= 25 or label[i] == 0:
			continue
		var r := _root(group, label[i])
		if not by_root.has(r):
			by_root[r] = []
		(by_root[r] as Array).append(i)
	var out := []
	for r in by_root:
		var px: Array = by_root[r]
		if px.size() < SPECK:
			continue
		var box := Rect2i(px[0] % w, px[0] / w, 1, 1)
		var sum := Vector2.ZERO
		for i in px:
			box = box.expand(Vector2i(i % w, i / w))
			sum += Vector2(i % w, i / w)
		box.size += Vector2i.ONE
		var bytes := PackedByteArray()
		bytes.resize(box.size.x * box.size.y * 4)
		for i in px:
			var x: int = i % w - box.position.x
			var y: int = i / w - box.position.y
			var o := (y * box.size.x + x) * 4
			for k in 4:
				bytes[o + k] = rgba[i * 4 + k]
		var img := Image.create_from_data(box.size.x, box.size.y, false, Image.FORMAT_RGBA8, bytes)
		out.append({"rect": Rect2i(box.position + region.position, box.size), "image": img,
			"ink": px.size(), "centre": sum / px.size() + Vector2(region.position) + Vector2(0.5, 0.5),
			"pixels": px, "region": region, "region_w": w})
	out.sort_custom(func(a, b): return a["rect"].position.x < b["rect"].position.x)
	return out


static func _root(group: Array, i: int) -> int:
	while group[i] != i:
		i = group[i]
	return i


## Which host a piece of `type` rides on, and its joint (sheet px): {host (a host entry), joint}.
## `hosts` are the parts placed so far that can carry others: {id, type, rect, alpha
## (PackedByteArray, one byte per rect pixel), w}.
static func attach(piece: Dictionary, type: String, hosts: Array) -> Dictionary:
	var allowed := []
	for h in hosts:
		if _can_carry(h["type"], type):
			allowed.append(h)
	if allowed.is_empty():
		allowed = [hosts[0]]
	# Where it overlaps each allowed host, and how much.
	var best := {}
	var best_n := 0
	var best_sum := Vector2.ZERO
	for h in allowed:
		var n := 0
		var sum := Vector2.ZERO
		var hr: Rect2i = h["rect"]
		var region: Rect2i = piece["region"]
		var rw: int = piece["region_w"]
		for i in piece["pixels"]:
			var at := Vector2i(i % rw, i / rw) + region.position
			if not hr.has_point(at):
				continue
			var j := (at.y - hr.position.y) * int(h["w"]) + (at.x - hr.position.x)
			if (h["alpha"] as PackedByteArray)[j] > 100:
				n += 1
				sum += Vector2(at)
		# A face part prefers a head it is on; the body only if it is on no head.
		var better: bool = n > best_n or (n == best_n and n > 0 and h["type"] != "body" and best.get("type", "") == "body")
		if better:
			best = h
			best_n = n
			best_sum = sum
	if best_n > 0:
		var joint: Vector2 = piece["centre"] if CENTRE_TYPES.has(type) else best_sum / best_n + Vector2(0.5, 0.5)
		return {"host": best, "joint": joint}
	# Touching nothing: hang it from its point nearest to the nearest allowed host.
	var near := _nearest(piece, allowed)
	var joint2: Vector2 = piece["centre"] if CENTRE_TYPES.has(type) else near["point"]
	return {"host": near["host"], "joint": joint2}


## Can a part of `host_type` carry a part of `type`?
static func _can_carry(host_type: String, type: String) -> bool:
	if host_type == "body":
		return true
	if BODY_ONLY.has(type):
		return false
	match type:
		"hand":
			return host_type == "arm"
		"foot", "claw":
			return host_type == "leg" or host_type == "arm"
	return host_type == "head"  # face parts, spikes and anything else


## The allowed host nearest the piece, and the piece's point nearest it - sampled, which is plenty
## for "where does a floating ear hang from".
static func _nearest(piece: Dictionary, hosts: Array) -> Dictionary:
	var region: Rect2i = piece["region"]
	var rw: int = piece["region_w"]
	var px: Array = piece["pixels"]
	var step := maxi(1, px.size() / 200)
	var best_d := INF
	var out := {"host": hosts[0], "point": piece["centre"]}
	for h in hosts:
		var hr: Rect2i = h["rect"]
		var hw: int = h["w"]
		var alpha: PackedByteArray = h["alpha"]
		var hstep := maxi(1, int(sqrt(float(hr.size.x * hr.size.y) / 1500.0)))
		var ink := []
		for y in range(0, hr.size.y, hstep):
			for x in range(0, hr.size.x, hstep):
				if alpha[y * hw + x] > 100:
					ink.append(Vector2(x, y) + Vector2(hr.position))
		for k in range(0, px.size(), step):
			var p := Vector2(px[k] % rw, px[k] / rw) + Vector2(region.position)
			for q in ink:
				var d := p.distance_squared_to(q)
				if d < best_d:
					best_d = d
					out = {"host": h, "point": p}
	return out


## A host entry for a placed part: what `attach` needs to know about it.
static func host_entry(id: String, type: String, rect: Rect2i, image: Image) -> Dictionary:
	var img := image.duplicate() as Image
	img.convert(Image.FORMAT_RGBA8)
	var rgba := img.get_data()
	var alpha := PackedByteArray()
	alpha.resize(rect.size.x * rect.size.y)
	for i in alpha.size():
		alpha[i] = rgba[i * 4 + 3]
	return {"id": id, "type": type, "rect": rect, "alpha": alpha, "w": rect.size.x, "image": image}


## The pet, from the creature's layers: type -> sheet-sized drawing, and type -> {mode, mask}
## for the ones drawn partly with a shiny marker. Empty if there is no body yet. `cache` keeps
## each layer's pieces (type -> pieces) between calls, so only a layer that changed is cut again.
static func build(layers: Dictionary, shines := {}, cache := {}) -> Dictionary:
	if not layers.has("body"):
		return {}
	var body_layer: Image = layers["body"]
	var used := body_layer.get_used_rect()
	if used.size.x < 2:
		return {}
	var pet := PetBuilder.new_pet()
	PetBuilder.set_body(pet, body_layer.get_region(used), _crop_shine(shines.get("body", {}), used, null))
	var centre := Vector2(used.position) + Vector2(used.size) / 2.0
	var hosts := [host_entry("body", "body", used, body_layer.get_region(used))]
	var twins := []
	for type in PartTypes.ORDER:
		if not layers.has(type):
			continue
		if not cache.has(type):
			cache[type] = pieces(layers[type])
		var ps: Array = cache[type]
		var placed := []
		for i in ps.size():
			var piece: Dictionary = ps[i]
			var a := attach(piece, type, hosts)
			var host: Dictionary = a["host"]
			var joint: Vector2 = a["joint"]
			var file := PetBuilder.unused_file(pet, type)
			pet["_img"][file] = piece["image"]
			var part := {
				"id": "%s_%d" % [type, PetBuilder._next_index(pet, type)], "type": type, "image": file,
				"pivot": PetBuilder.arr(joint - Vector2(piece["rect"].position)), "draw_scale": 1.0,
				"scale": 1.0, "pos": PetBuilder.arr(joint - centre), "rot": 0.0, "flip": false,
				"behind": BEHIND.has(type), "parent": host["id"], "pair": i, "side": 0,
			}
			pet["parts"].append(part)
			PetBuilder._add_shine(pet, part, type, _crop_shine(shines.get(type, {}), piece["rect"], piece))
			placed.append({"part": part, "host": host, "piece": piece})
			if PartTypes.MAIN.has(type):
				hosts.append(host_entry(part["id"], type, piece["rect"], piece["image"]))
		# One wing drawn: its pair goes behind, shaded, for depth.
		if placed.size() == 1 and bool(PartTypes.info(type).get("pairs", false)):
			twins.append(placed[0])
	# Twins come last, so a lone arm's twin gets a copy of the hand drawn on it too.
	for p in twins:
		_add_twin(pet, p, p["part"]["type"], centre)
	return pet


static func _add_twin(pet: Dictionary, p: Dictionary, type: String, centre: Vector2) -> void:
	var part: Dictionary = p["part"]
	var host: Dictionary = p["host"]
	var info := PartTypes.info(type)
	var face_on_body: bool = host["type"] == "body" and PartTypes.FACE.has(type)
	var far: Vector2 = info.get("body_far" if face_on_body and info.has("body_far") else "far", Vector2(-0.07, -0.02))
	var hr: Rect2i = host["rect"]
	var joint := PetBuilder.v2(part["pos"]) + centre
	var shift := Vector2(far.x * hr.size.x, far.y * hr.size.y)
	# Off the side of the host (an ear drawn on the right of the head): the other way instead.
	var uv := (joint + shift - Vector2(hr.position)) / Vector2(hr.size)
	if uv.x < 0.0 or uv.x > 1.0:
		shift.x = -shift.x
		uv = (joint + shift - Vector2(hr.position)) / Vector2(hr.size)
	var at := joint + shift
	# Walked to the host's outline the way the part grows (an ear up onto the top of the head), so
	# the twin sits on the host, not in the air beside it.
	var edge: Vector2 = info.get("edge", Vector2.ZERO)
	if edge != Vector2.ZERO and uv.x >= 0.0 and uv.x <= 1.0 and uv.y >= 0.0 and uv.y <= 1.0:
		at = PetBuilder.anchor_px(host["image"], uv, edge) + Vector2(hr.position)
	var twin := _copy_part(pet, part, at - joint, part["parent"])
	twin["behind"] = true
	# What rides on it comes too - a hand on the twin arm.
	for child in PetBuilder.children(pet, part["id"]):
		if int(child.get("side", 0)) == 0:
			_copy_part(pet, child, at - joint, twin["id"])


## A far-side copy of a part, moved by `shift` (body space) and riding on `parent`.
static func _copy_part(pet: Dictionary, part: Dictionary, shift: Vector2, parent: String) -> Dictionary:
	var twin: Dictionary = part.duplicate(true)
	twin["id"] = "%s_%d" % [part["type"], PetBuilder._next_index(pet, part["type"])]
	twin["pos"] = PetBuilder.arr(PetBuilder.v2(part["pos"]) + shift)
	twin["parent"] = parent
	twin["side"] = 1
	pet["parts"].append(twin)
	return twin


## The shine mask for one piece (or the whole body): {mode, mask} cropped to `rect`, and to the
## piece's own pixels. {} when none of it shines.
static func _crop_shine(shine: Dictionary, rect: Rect2i, piece: Variant) -> Dictionary:
	if shine.is_empty() or shine.get("mask") == null:
		return {}
	var mask: Image = (shine["mask"] as Image).get_region(rect)
	if piece != null:
		var keep: Image = (piece as Dictionary)["image"]
		for y in mask.get_height():
			for x in mask.get_width():
				if keep.get_pixel(x, y).a <= 0.1:
					mask.set_pixel(x, y, Color(0, 0, 0, 0))
	if mask.get_used_rect().size.x == 0:
		return {}
	return {"mode": shine["mode"], "mask": mask}
