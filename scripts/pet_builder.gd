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
	var file := type + "_shine.png"
	pet["_img"][file] = shine["mask"]
	part["shine"] = shine["mode"]
	part["shine_image"] = file


## Which drawing a type attaches to (the head if there is one and it is a face part, else the
## body), and where on it as a fraction of its ink box.
static func attach_ref(pet: Dictionary, type: String) -> Dictionary:
	var info := PartTypes.info(type)
	var h := head(pet)
	if info.get("ref", "body") == "head" and not h.is_empty():
		return {"part": h, "uv": info["anchor"]}
	var uv: Vector2 = info.get("body_anchor", info.get("anchor", Vector2(0.5, 0.5)))
	return {"part": find(pet, "body"), "uv": uv}


## The anchor in the reference drawing's own pixels. With an edge direction it walks from the
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


## The reference drawing shown faintly on the sheet while a part is drawn, placed so the
## anchor sits on the red dot at the sheet's zoom. Draw a leg over this and it comes out the
## right size, in the right place, first time. Empty for the body.
static func ghost(pet: Dictionary, type: String) -> Dictionary:
	if type == "body" or not PartTypes.TYPES.has(type):
		return {}
	var ref := attach_ref(pet, type)
	var rp: Dictionary = ref["part"]
	if rp.is_empty():
		return {}
	var info := PartTypes.info(type)
	var img: Image = pet["_img"][rp["image"]]
	var a := anchor_px(img, ref["uv"], info.get("edge", Vector2.ZERO))
	var gs := float(info["zoom"]) * float(rp["draw_scale"]) * float(rp["scale"])
	var dot: Vector2 = info["dot"]
	return {"image": img, "rect": Rect2(dot - a * gs, Vector2(img.get_size()) * gs)}


## Adds `count` copies of one drawn part, laid out where they most likely go: legs fanned
## along the bottom of the body in near/far pairs, eyes side by side on the head, and so on.
## The kid can move all of it in the assembly screen; this just makes the first look good.
static func add_parts(pet: Dictionary, type: String, count: int, img: Image, pivot: Vector2,
		shine := {}) -> void:
	var file := type + ".png"
	pet["_img"][file] = img
	var info := PartTypes.info(type)
	var ref := attach_ref(pet, type)
	var rp: Dictionary = ref["part"]
	var rimg: Image = pet["_img"][rp["image"]]
	var rsize := Vector2(rimg.get_size())
	var rscale := float(rp["draw_scale"]) * float(rp["scale"])
	var paired: bool = info["pairs"]
	var groups := ceili(count / 2.0) if paired else count
	var spread: float = info["spread"]
	for i in count:
		var g := i / 2 if paired else i
		var side := i % 2 if paired else 0
		var uv: Vector2 = ref["uv"]
		if groups > 1:
			uv.x += spread * (g / float(groups - 1) * 2.0 - 1.0)
		var a := anchor_px(rimg, uv, info.get("edge", Vector2.ZERO))
		var pos := v2(rp["pos"]) + (a - v2(rp["pivot"])) * rscale
		if side == 1:
			var far: Vector2 = info.get("far", Vector2(-0.07, -0.02))
			pos += far * rsize * rscale
		pet["parts"].append({
			"id": "%s_%d" % [type, _next_index(pet, type)], "type": type, "image": file,
			"pivot": arr(pivot), "draw_scale": 1.0 / float(info["zoom"]), "scale": 1.0,
			"pos": arr(pos), "rot": 0.0, "flip": false,
			"behind": side == 1 or BEHIND_TYPES.has(type), "parent": rp["id"],
			"pair": g, "side": side,
		})
		_add_shine(pet, pet["parts"][pet["parts"].size() - 1], type, shine)


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


## After a drop: a part whose joint lands on the head's ink rides on the head from now on, and
## one dragged off it goes back to the body.
static func reattach(pet: Dictionary, id: String) -> void:
	var p := find(pet, id)
	var h := head(pet)
	if p.is_empty() or p["type"] == "body" or p["type"] == "head":
		return
	var on_head := not h.is_empty() and ink_at(pet, h, v2(p["pos"]))
	p["parent"] = h["id"] if on_head else "body"


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


static func remove_part(pet: Dictionary, id: String) -> void:
	var p := find(pet, id)
	if p.is_empty() or p["type"] == "body":
		return
	for k in children(pet, id):
		k["parent"] = "body"
	pet["parts"].erase(p)
