class_name PetBuilder
extends RefCounted
## Turns a kid's drawings into a creature layout, and edits that layout.
##
## Every part is stored in BODY SPACE: its joint's position and rotation in the body drawing's
## pixels, with the body's middle at (0, 0). That is the rest pose exactly as it looked in the
## assembly screen. Creature turns it into a joint hierarchy (eyes ride on the head) when it
## builds the rig, so the layout never has to know about parent-relative maths.
##
## A part's drawing is cropped to its own ink. "pivot" is the red dot - where the kid started
## drawing - in the cropped image's pixels, and the part rotates about it.

## Types whose root is tucked behind whatever they grow from, so the join never shows.
const BEHIND_TYPES := ["tail", "spike", "fin", "hair"]


static func new_pet() -> Dictionary:
	var now := Time.get_unix_time_from_system()
	return {
		"id": PetStore.new_id(), "name": "", "size": "medium", "place": "meadow",
		"parts": [], "food": {}, "toy": {}, "love": 0, "created": now, "last_seen": now,
		"personality": [], "outfit": [], "home": "",
		"needs": {"food": 0.7, "fun": 0.7, "clean": 1.0, "energy": 1.0},
		"_img": {}, "_tex": {},
	}


static func v2(a) -> Vector2:
	return Vector2(float(a[0]), float(a[1]))


static func arr(v: Vector2) -> Array:
	return [snappedf(v.x, 0.01), snappedf(v.y, 0.01)]


static func find(pet: Dictionary, id: String) -> Dictionary:
	for p in pet["parts"]:
		if p["id"] == id:
			return p
	return {}


static func head(pet: Dictionary) -> Dictionary:
	for p in pet["parts"]:
		if p["type"] == "head":
			return p
	return {}


static func count_of(pet: Dictionary, type: String) -> int:
	var n := 0
	for p in pet["parts"]:
		if p["type"] == type:
			n += 1
	return n


static func has_type(pet: Dictionary, type: String) -> bool:
	return count_of(pet, type) > 0


## A part's joint in body space (flip, but no size - the sprite carries size).
static func joint_xform(p: Dictionary) -> Transform2D:
	return Transform2D(float(p["rot"]), Vector2(-1.0 if p["flip"] else 1.0, 1.0), 0.0, v2(p["pos"]))


## Maps a part's image pixels into body space.
static func sprite_xform(p: Dictionary) -> Transform2D:
	var s := float(p["draw_scale"]) * float(p["scale"])
	return joint_xform(p) * Transform2D(0.0, Vector2(s, s), 0.0, -v2(p["pivot"]) * s)


# --- Building from drawings ------------------------------------------------------------------

## `shine` is {mode, mask} when the kid drew part of it with a shiny marker.
static func set_body(pet: Dictionary, img: Image, shine := {}) -> void:
	pet["_img"]["body.png"] = img
	pet["parts"] = [{
		"id": "body", "type": "body", "image": "body.png",
		"pivot": arr(Vector2(img.get_size()) / 2.0), "draw_scale": 1.0, "scale": 1.0,
		"pos": [0.0, 0.0], "rot": 0.0, "flip": false, "behind": false, "parent": "",
		"pair": 0, "side": 0,
	}]
	_add_shine(pet, pet["parts"][0], "body", shine)


static func _add_shine(pet: Dictionary, part: Dictionary, type: String, shine: Dictionary) -> void:
	if shine.is_empty() or shine.get("mask") == null:
		return
	var file := unused_file(pet, part["image"].get_basename() + "_shine")
	pet["_img"][file] = shine["mask"]
	part["shine"] = shine["mode"]
	part["shine_image"] = file


## What a type goes on when nothing says otherwise: face parts on the head (or the body if
## there is no head), hands on arms, feet and claws on legs, everything else on the body.
static func default_host(pet: Dictionary, type: String) -> String:
	var host: String = PartTypes.info(type).get("host", "body")
	if host != "body" and not has_type(pet, host):
		return "body"
	return host


## Every part an add-on can go on, of one host type - all four legs get a foot each.
static func parts_of(pet: Dictionary, host: String) -> Array:
	if host == "body":
		return [find(pet, "body")]
	var out := []
	for p in pet["parts"]:
		if p["type"] == host:
			out.append(p)
	return out


## Where on the host's drawing a type attaches, as a fraction of its ink box. `headless` is a
## creature whose face is on its body - arms then go under the face, not across it.
static func anchor_uv(type: String, host: String, headless := false) -> Vector2:
	var info := PartTypes.info(type)
	if host == "body" and info.get("host", "body") == "head":
		return info.get("body_anchor", info.get("anchor", Vector2(0.5, 0.5)))
	if headless and info.has("headless_anchor"):
		return info["headless_anchor"]
	return info.get("anchor", Vector2(0.5, 0.5))


## The anchor in the host drawing's own pixels. With an edge direction it walks from the
## anchor to the last ink in that direction, then tucks back inside the outline a little, so a
## leg lands on the bottom of the body the kid actually drew rather than on its bounding box.
static func anchor_px(img: Image, uv: Vector2, edge: Vector2) -> Vector2:
	var size := Vector2(img.get_size())
	var start := uv * size
	if edge == Vector2.ZERO:
		return start
	var last := Vector2(-1, -1)
	var p := start
	while p.x >= 0 and p.y >= 0 and p.x < size.x and p.y < size.y:
		if img.get_pixel(int(p.x), int(p.y)).a > 0.5:
			last = p
		p += edge
	if last.x < 0:
		return start
	return last - edge * 8.0


## The host's drawing shown faintly on the sheet while a part is drawn, placed so the anchor
## sits on the red dot at the sheet's zoom. Draw a leg over this and it comes out the right
## size, in the right place, first time. Empty for the body.
static func ghost(pet: Dictionary, type: String, host := "") -> Dictionary:
	if type == "body" or not PartTypes.TYPES.has(type):
		return {}
	if host == "":
		host = default_host(pet, type)
	var hosts := parts_of(pet, host)
	if hosts.is_empty() or hosts[0].is_empty():
		return {}
	var hp: Dictionary = hosts[0]
	return ghost_on(pet["_img"][hp["image"]], float(hp["draw_scale"]) * float(hp["scale"]), type, host,
		not has_type(pet, "head"))


## The same, from a host drawing that is not on the pet yet - the head still being drawn when
## the kid adds its horns. `at` (host image pixels), when given, is the spot the kid tapped for
## it, which goes on the dot instead of where it would go by itself.
static func ghost_on(host_img: Image, host_scale: float, type: String, host: String,
		headless := false, at := Vector2(-1, -1)) -> Dictionary:
	var info := PartTypes.info(type)
	var a := at if at.x >= 0.0 else anchor_px(host_img, anchor_uv(type, host, headless), info.get("edge", Vector2.ZERO))
	var gs := float(info["zoom"]) * host_scale
	var dot: Vector2 = info["dot"]
	return {"image": host_img, "rect": Rect2(dot - a * gs, Vector2(host_img.get_size()) * gs)}


## Adds `count` copies of one drawn part to EVERY part of the host type, laid out where they
## most likely go: legs fanned along the bottom of the body in near/far pairs, eyes side by side
## on each head, a hand on the end of each arm. The kid can move all of it in the assembly
## screen; this just makes the first look good.
## `layout` overrides where they go (see layout_on_host) - roster creatures use it so every one
## does not have its eyes and head in the same spot. A kid's pet never needs it: they drag.
static func add_parts(pet: Dictionary, type: String, count: int, img: Image, pivot: Vector2,
		shine := {}, host := "", layout := {}) -> void:
	if host == "":
		host = default_host(pet, type)
	var stem := type if host == "body" or host == PartTypes.info(type).get("host", "body") 		else "%s_on_%s" % [type, host]
	var file := unused_file(pet, stem)
	pet["_img"][file] = img
	var info := PartTypes.info(type)
	for hp in parts_of(pet, host):
		if hp.is_empty():
			continue
		var rimg: Image = pet["_img"][hp["image"]]
		var on_body := host == "body"
		var spots := layout_on_host(type, host, count, rimg, sprite_xform(hp),
			float(hp["draw_scale"]) * float(hp["scale"]), not has_type(pet, "head"), layout)
		for spot in spots:
			pet["parts"].append({
				"id": "%s_%d" % [type, _next_index(pet, type)], "type": type, "image": file,
				"pivot": arr(pivot), "draw_scale": 1.0 / float(info["zoom"]), "scale": 1.0,
				"pos": arr(spot["pos"]), "rot": 0.0 if on_body else float(hp["rot"]),
				"flip": false if on_body else bool(hp["flip"]),
				"behind": spot["behind"], "parent": hp["id"],
				# A far-side host's add-ons are far-side too, so they are shaded with it.
				"pair": spot["pair"], "side": maxi(int(spot["side"]), int(hp.get("side", 0))),
			})
			_add_shine(pet, pet["parts"][pet["parts"].size() - 1], type, shine)


## Where `count` copies of a type go on one host drawing: [{pos, pair, side, behind}], with pos
## mapped through `host_x` (host image pixels -> wherever the caller wants: body space for a
## pet, the drawing sheet for a preview). `layout` may override the type's PartTypes values:
## "anchor" [u, v] (a fraction of the host's ink box), "edge" [x, y] (the way it walks to the
## outline; [0, 0] to stay put), "spread" (how far apart copies fan) and "far" [x, y] - or
## "spots": the exact places a kid tapped (host image pixels), one copy each. Tapped pairs go
## near-far from left to right, so the left ear is the near one and the right ear the far one.
static func layout_on_host(type: String, host: String, count: int, host_img: Image,
		host_x: Transform2D, host_scale: float, headless := false, layout := {}) -> Array:
	var info := PartTypes.info(type)
	var paired: bool = info["pairs"]
	if layout.has("spots") and not (layout["spots"] as Array).is_empty():
		var spots: Array = (layout["spots"] as Array).duplicate()
		if paired:
			spots.sort_custom(func(a, b): return v2(a).x < v2(b).x)
		var tapped := []
		for i in spots.size():
			var side := i % 2 if paired else 0
			tapped.append({"pos": host_x * v2(spots[i]), "pair": i / 2 if paired else i, "side": side,
				"behind": side == 1 or BEHIND_TYPES.has(type)})
		return tapped
	var groups := ceili(count / 2.0) if paired else count
	var spread := float(layout.get("spread", info["spread"]))
	var uv0 := anchor_uv(type, host, headless)
	if layout.has("anchor"):
		uv0 = Vector2(float(layout["anchor"][0]), float(layout["anchor"][1]))
	var edge: Vector2 = info.get("edge", Vector2.ZERO)
	if layout.has("edge"):
		edge = Vector2(float(layout["edge"][0]), float(layout["edge"][1]))
	var on_body_face: bool = host == "body" and info.get("host", "body") == "head"
	var far_off: Vector2 = info.get("body_far" if on_body_face and info.has("body_far") else "far",
		Vector2(-0.07, -0.02))
	if layout.has("far"):
		far_off = Vector2(float(layout["far"][0]), float(layout["far"][1]))
	var size := Vector2(host_img.get_size())
	var out := []
	for i in count:
		var g := i / 2 if paired else i
		var side := i % 2 if paired else 0
		var uv := uv0
		if groups > 1:
			uv.x += spread * (g / float(groups - 1) * 2.0 - 1.0)
		var far: Vector2 = far_off if side == 1 else Vector2.ZERO
		# An odd one out of a pair - a unicorn's horn, the middle of three - goes between the pair.
		if paired and side == 0 and i == count - 1 and count % 2 == 1:
			far = Vector2(far_off.x * 0.5, 0.0)
		# The far copy is moved along BEFORE walking to the edge, so it lands on the outline
		# there too - a far ear on a round head sits on the head, not in the air beside it.
		uv.x += far.x
		var a := anchor_px(host_img, uv, edge)
		var pos: Vector2 = host_x * a
		pos.y += far.y * size.y * host_scale
		out.append({"pos": pos, "pair": g, "side": side,
			"behind": side == 1 or BEHIND_TYPES.has(type)})
	return out


static func _next_index(pet: Dictionary, type: String) -> int:
	var n := 0
	while not find(pet, "%s_%d" % [type, n]).is_empty():
		n += 1
	return n


# --- Layout queries --------------------------------------------------------------------------

static func children(pet: Dictionary, id: String) -> Array:
	var out := []
	for p in pet["parts"]:
		if p["parent"] == id:
			out.append(p)
	return out


## A part and everything riding on it.
static func group(pet: Dictionary, id: String) -> Array:
	var out := [find(pet, id)]
	for k in children(pet, id):
		out.append_array(group(pet, k["id"]))
	return out


## Back to front. A part's behind-children, then the part, then its front-children - so a far
## ear sits behind the head but still in front of the body the head sits on.
static func draw_order(pet: Dictionary) -> Array:
	var out := []
	if not find(pet, "body").is_empty():
		_stack(pet, "body", out)
	return out


static func _stack(pet: Dictionary, id: String, out: Array) -> void:
	var kids := children(pet, id)
	for k in kids:
		if k["behind"]:
			_stack(pet, k["id"], out)
	out.append(find(pet, id))
	for k in kids:
		if not k["behind"]:
			_stack(pet, k["id"], out)


## The box round every drawn pixel in the rest pose, in body space.
static func rest_bounds(pet: Dictionary) -> Rect2:
	var r := Rect2()
	var first := true
	for p in pet["parts"]:
		var img: Image = pet["_img"].get(p["image"])
		if img == null:
			continue
		var x := sprite_xform(p)
		var s := Vector2(img.get_size())
		for c in [Vector2.ZERO, Vector2(s.x, 0), s, Vector2(0, s.y)]:
			var q: Vector2 = x * c
			if first:
				r = Rect2(q, Vector2.ZERO)
				first = false
			else:
				r = r.expand(q)
	return r


## True when `point` (body space) lands on the part's ink.
static func ink_at(pet: Dictionary, p: Dictionary, point: Vector2) -> bool:
	var img: Image = pet["_img"].get(p["image"])
	if img == null:
		return false
	var local := sprite_xform(p).affine_inverse() * point
	var x := int(local.x)
	var y := int(local.y)
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return false
	return img.get_pixel(x, y).a > 0.3


# --- Edits (the assembly screen) -------------------------------------------------------------
# Each edit moves a part together with everything riding on it, about the part's own joint.

static func move_group(pet: Dictionary, id: String, delta: Vector2) -> void:
	for p in group(pet, id):
		p["pos"] = arr(v2(p["pos"]) + delta)


static func rotate_group(pet: Dictionary, id: String, angle: float) -> void:
	var pivot := v2(find(pet, id)["pos"])
	for p in group(pet, id):
		p["pos"] = arr(pivot + (v2(p["pos"]) - pivot).rotated(angle))
		p["rot"] = float(p["rot"]) + angle


static func scale_group(pet: Dictionary, id: String, k: float) -> void:
	var pivot := v2(find(pet, id)["pos"])
	for p in group(pet, id):
		p["pos"] = arr(pivot + (v2(p["pos"]) - pivot) * k)
		p["scale"] = clampf(float(p["scale"]) * k, 0.15, 6.0)


static func flip_group(pet: Dictionary, id: String) -> void:
	var px := v2(find(pet, id)["pos"]).x
	for p in group(pet, id):
		var q := v2(p["pos"])
		p["pos"] = arr(Vector2(2.0 * px - q.x, q.y))
		p["rot"] = -float(p["rot"])
		p["flip"] = not p["flip"]


## After a drop: an add-on whose joint lands on a head's, arm's or leg's ink rides on that part
## from then on; dropped anywhere else it rides on the body. Main parts always ride on the body.
static func reattach(pet: Dictionary, id: String) -> void:
	var p := find(pet, id)
	if p.is_empty() or p["type"] == "body" or PartTypes.MAIN.has(p["type"]):
		return
	var at := v2(p["pos"])
	var order := draw_order(pet)
	order.reverse()
	for h in order:
		if PartTypes.MAIN.has(h["type"]) and h["id"] != id and ink_at(pet, h, at):
			p["parent"] = h["id"]
			return
	p["parent"] = "body"


static func copy_part(pet: Dictionary, id: String) -> Dictionary:
	var src := find(pet, id)
	if src.is_empty() or src["type"] == "body":
		return {}
	var p: Dictionary = src.duplicate(true)
	p["id"] = "%s_%d" % [src["type"], _next_index(pet, src["type"])]
	p["pos"] = arr(v2(src["pos"]) + Vector2(24, 0))
	p["pair"] = int(src["pair"]) + 1
	pet["parts"].append(p)
	return p


## "<stem>.png", or "<stem>_2.png" and so on if that is taken - a second, different drawing of
## horns added later must not paint over the first.
static func unused_file(pet: Dictionary, stem: String) -> String:
	var file := stem + ".png"
	var n := 2
	while pet["_img"].has(file):
		file = "%s_%d.png" % [stem, n]
		n += 1
	return file


static func remove_part(pet: Dictionary, id: String) -> void:
	var p := find(pet, id)
	if p.is_empty() or p["type"] == "body":
		return
	for k in children(pet, id):
		k["parent"] = "body"
	pet["parts"].erase(p)
