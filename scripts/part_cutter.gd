class_name PartCutter
extends RefCounted
## Turns a creature drawn on one sheet (CreatureSheet) into a pet (.ai/creature-pipeline.md).
##
## The kid draws each part as its own DRAWING, in place on the creature: a leg, then "Draw another
## leg" or "Copy this leg" for the next. Each drawing becomes parts:
##   - its separate PIECES are separate parts - four legs drawn in one go are still four legs that
##     walk; ink about 12 px apart or less is one piece, and so is ink mostly inside another's box
##     (a pupil, an eye's highlight, a wing's feathers); stray specks are dropped. Two drawings are
##     never one piece, however they overlap;
##   - each piece rides on a HOST: face parts on the head they are drawn on (or the body, with no
##     head), hands on an arm, feet and claws on a leg, everything else on the body;
##   - its JOINT is where it touches its host - a leg swings from where it meets the body, an ear
##     wobbles from its base - or its middle for eyes, mouths and noses, which blink, open and
##     twitch about their centre. Drawn not touching anything, it hangs from its nearest point;
##   - it goes IN FRONT of its host or BEHIND it, as the kid chose for that drawing, and among the
##     parts on the same host the later-stacked one is in front (the drawing's `z`).
## Nothing is ever added that the kid did not draw or copy: no hidden twins.
##
## Nothing is redrawn or tidied: each part is exactly the kid's pixels, cut out.

## Ink this close is one piece (sheet px): a pupil inside an eye, a dashed line.
const GROUP_GAP := 6
## Pieces with less ink than this are specks, not parts.
const SPECK := 40
## Parts whose joint is their middle rather than where they touch.
const CENTRE_TYPES := ["eye", "mouth", "nose"]
const BODY_ONLY := ["head", "leg", "arm", "wing", "tail", "fin", "tentacle"]
## Start out tucked behind what they grow from, so the join never shows - until the kid says
## otherwise. (Hair does not: drawn in place, it is drawn ON the head.)
const BEHIND := ["tail", "spike", "fin"]


## The separate pieces of a drawing whose top-left is at `at` on the sheet: [{rect (sheet px),
## image (just that piece's pixels), ink (how many), centre}], left to right.
static func pieces(layer: Image, at := Vector2i.ZERO) -> Array:
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

	# An island mostly inside another's box is part of it: an eye's highlight, a wing's feathers.
	# Merely overlapping boxes are not - four slanted legs stay four.
	var group := range(boxes.size() + 1)
	var merged := true
	while merged:
		merged = false
		for a in boxes.size():
			for b in range(a + 1, boxes.size()):
				var ga := _root(group, a + 1)
				var gb := _root(group, b + 1)
				var ra: Rect2i = boxes[a]
				var rb: Rect2i = boxes[b]
				if ga != gb and ra.intersection(rb).get_area() * 2 >= mini(ra.get_area(), rb.get_area()):
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
		var on_sheet := Rect2i(region.position + at, region.size)
		out.append({"rect": Rect2i(box.position + on_sheet.position, box.size), "image": img,
			"ink": px.size(), "centre": sum / px.size() + Vector2(on_sheet.position) + Vector2(0.5, 0.5),
			"pixels": px, "region": on_sheet, "region_w": w})
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
			if (h["rgba"] as PackedByteArray)[j * 4 + 3] > 100:
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
		var rgba: PackedByteArray = h["rgba"]
		var hstep := maxi(1, int(sqrt(float(hr.size.x * hr.size.y) / 1500.0)))
		var ink := []
		for y in range(0, hr.size.y, hstep):
			for x in range(0, hr.size.x, hstep):
				if rgba[(y * hw + x) * 4 + 3] > 100:
					ink.append(Vector2(x, y) + Vector2(hr.position))
		for k in range(0, px.size(), step):
			var p := Vector2(px[k] % rw, px[k] / rw) + Vector2(region.position)
			for q in ink:
				var d := p.distance_squared_to(q)
				if d < best_d:
					best_d = d
					out = {"host": h, "point": p}
	return out


## A host entry for a placed part: what `attach` needs to know about it - its pixels as bytes, read
## four to a pixel (the alpha is every fourth).
static func host_entry(id: String, type: String, rect: Rect2i, image: Image) -> Dictionary:
	var img := image.duplicate() as Image
	img.convert(Image.FORMAT_RGBA8)
	return {"id": id, "type": type, "rect": rect, "rgba": img.get_data(), "w": rect.size.x, "image": image}


## The pet, from the creature's drawings: type -> [{image (cropped to its ink), at (sheet px of
## its top-left), shine ({} or {mode, mask} the same size), behind, z}], as CreatureSheet keeps
## them. Empty if there is no body yet. `cache` keeps each drawing's pieces between calls (by its
## Image), so only a drawing that changed is cut again.
static func build(layers: Dictionary, cache := {}) -> Dictionary:
	var bodies: Array = layers.get("body", [])
	if bodies.is_empty():
		return {}
	var bd: Dictionary = bodies[0]
	var body_img: Image = bd["image"]
	var u := body_img.get_used_rect()
	if u.size.x < 2:
		return {}
	var used := Rect2i(Vector2i(bd["at"]) + u.position, u.size)
	var pet := PetBuilder.new_pet()
	PetBuilder.set_body(pet, body_img.get_region(u), _crop_shine(bd.get("shine", {}), u, null))
	var centre := Vector2(used.position) + Vector2(used.size) / 2.0
	var hosts := [host_entry("body", "body", used, body_img.get_region(u))]
	var seen := {}
	var zs := {}
	for type in PartTypes.ORDER:
		var found := []
		for d in layers.get(type, []):
			var img: Image = d["image"]
			seen[img] = true
			if not cache.has(img):
				cache[img] = pieces(img, Vector2i(d["at"]))
			for piece in cache[img]:
				found.append([piece, d])
		# Left to right across all of a type's drawings, so four legs drawn one by one still take
		# turns as they walk.
		found.sort_custom(_left_of)
		for i in found.size():
			var piece: Dictionary = found[i][0]
			var d: Dictionary = found[i][1]
			var a := attach(piece, type, hosts)
			var host: Dictionary = a["host"]
			var joint: Vector2 = a["joint"]
			var file := PetBuilder.unused_file(pet, type)
			pet["_img"][file] = piece["image"]
			var part := {
				"id": "%s_%d" % [type, PetBuilder._next_index(pet, type)], "type": type, "image": file,
				"pivot": PetBuilder.arr(joint - Vector2(piece["rect"].position)), "draw_scale": 1.0,
				"scale": 1.0, "pos": PetBuilder.arr(joint - centre), "rot": 0.0, "flip": false,
				"behind": bool(d.get("behind", BEHIND.has(type))), "parent": host["id"], "pair": i,
				"side": 0,
			}
			# The drawing's place in the stack first, then the order they were cut in.
			zs[part["id"]] = int(d.get("z", 0)) * 10000 + pet["parts"].size()
			pet["parts"].append(part)
			var own := Rect2i(piece["rect"].position - Vector2i(d["at"]), piece["rect"].size)
			PetBuilder._add_shine(pet, part, type, _crop_shine(d.get("shine", {}), own, piece))
			if PartTypes.MAIN.has(type):
				hosts.append(host_entry(part["id"], type, piece["rect"], piece["image"]))
	for img in cache.keys():
		if not seen.has(img):
			cache.erase(img)
	# Parts on the same host stack as the kid stacked their drawings: a later one in front. Hosts
	# still come before what hangs on them (by depth), so Creature hangs every part in one pass and
	# each host's parts go on in exactly this order.
	var depth := {"body": 0}
	for part in pet["parts"]:
		if part["id"] != "body":
			depth[part["id"]] = int(depth.get(part["parent"], 0)) + 1
	var body: Dictionary = pet["parts"][0]
	var rest: Array = pet["parts"].slice(1)
	rest.sort_custom(func(a, b): return _stack_key(a, depth, zs) < _stack_key(b, depth, zs))
	pet["parts"] = [body] + rest
	return pet


static func _stack_key(part: Dictionary, depth: Dictionary, zs: Dictionary) -> int:
	return int(depth[part["id"]]) * 100000000 + int(zs[part["id"]])


static func _left_of(a: Array, b: Array) -> bool:
	return a[0]["rect"].position.x < b[0]["rect"].position.x


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
