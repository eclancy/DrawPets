class_name Mud
extends RefCounted
## Mud, sand and dust on a pet: crayon splats laid OVER its drawing, never in it - the drawing is
## the kid's and is never changed (rule 1). A sponge scrubs them off (PlaceScreen's Bath).
##
## Getting muddy is fun, not a telling-off: splashing about the swamp, digging, playing in the
## rain. Kept in pet["mud"] as [part_id, x, y, r, seed, kind] - x, y and r in the part's own
## image pixels - so a splat rides the part it landed on and squashes with it.

const MAX := 12
## Light enough for creatures' black to win; brown, never black.
const COLORS := {"mud": Color("#8c6a4b"), "sand": Color("#d2b273"), "dust": Color("#aaa1c2")}
## Which parts each kind of getting dirty lands on, best first.
const WHERE := {
	"feet": ["foot", "leg", "tentacle", "claw", "tail", "body"],
	"front": ["hand", "claw", "arm", "nose", "mouth", "foot", "leg", "head", "body"],
	"all": ["body", "head", "leg", "arm", "tail", "ear", "foot", "wing", "fin"],
}
## How much each splat lowers the clean need (it never goes under PetStore's floor).
const PER_SPLAT := 0.05


## What a place gets on a pet: mud, sand, dust - or "" for nowhere dirty (under the sea, the
## clouds, the snow).
static func kind_for(place_id: String) -> String:
	var tags := Places.tags(place_id)
	if Places.get_place(place_id).get("water", false) or tags.has("snowy") or place_id == "sky":
		return ""
	if tags.has("sandy"):
		return "sand"
	if tags.has("rocky") and not tags.has("grassy"):
		return "dust"
	return "mud"


static func count(pet: Dictionary) -> int:
	return pet.get("mud", []).size()


## Splats up to `n` spots of `kind` on the parts `where` picks. Returns how many landed.
static func splat(pet: Dictionary, n: int, where: String, kind := "mud") -> int:
	if kind == "" or not pet.has("_img"):
		return 0
	var spots: Array = pet.get("mud", [])
	var order: Array = WHERE.get(where, WHERE["all"])
	var tall := maxf(PetBuilder.rest_bounds(pet).size.y, 1.0)
	var added := 0
	for k in n:
		if spots.size() >= MAX:
			break
		var part := _pick_part(pet, order, spots.size() + k)
		if part.is_empty():
			break
		var img: Image = pet["_img"].get(part["image"])
		if img == null:
			continue
		var at := _ink_spot(img, where == "feet" and part["type"] == "body")
		if at.x < 0.0:
			continue
		# Sized by the whole creature, not the part: a splat on a thin leg is as big as one on its
		# body, and spills over the edge the way mud does.
		var sk := maxf(float(part["draw_scale"]) * float(part["scale"]), 0.01)
		var r := tall * 0.07 / sk * randf_range(0.8, 1.2)
		spots.append([part["id"], at.x, at.y, r, randi() % 9973, kind])
		added += 1
	pet["mud"] = spots
	if added > 0:
		PetStore.change_need(pet, "clean", -PER_SPLAT * added)
	return added


## A part to land on: mostly the first types in `order` the pet has, sometimes the next ones.
static func _pick_part(pet: Dictionary, order: Array, salt: int) -> Dictionary:
	var choices := []
	for t in order:
		for p in pet["parts"]:
			if p["type"] == t:
				choices.append(p)
		if choices.size() >= 3:
			break
	if choices.is_empty():
		return {}
	return choices[(randi() + salt) % choices.size()]


## A random point on the ink of a drawing (its lower part only, for the underside of a body).
static func _ink_spot(img: Image, low_only: bool) -> Vector2:
	var w := img.get_width()
	var h := img.get_height()
	for i in 40:
		var x := randi() % maxi(w, 1)
		var y := randi() % maxi(h, 1)
		if low_only:
			y = int(h * 0.55) + randi() % maxi(int(h * 0.45), 1)
		if img.get_pixel(x, y).a > 0.5:
			return Vector2(x, y)
	return Vector2(-1, -1)


## Scrubs off the splat nearest a global point, if one is within `reach`. True if it did.
static func scrub_near(c: Creature, at: Vector2, reach: float) -> bool:
	var spots: Array = c.pet.get("mud", [])
	var best := -1
	var best_d := reach
	for i in spots.size():
		var g := where_is(c, spots[i])
		if g.x == INF:
			continue
		var d := g.distance_to(at)
		if d < best_d:
			best_d = d
			best = i
	if best < 0:
		return false
	spots.remove_at(best)
	c.pet["mud"] = spots
	return true


## A splat's place on screen, or INF if its part is gone.
static func where_is(c: Creature, s: Array) -> Vector2:
	for part in c.parts:
		if part.name == s[0]:
			return part.sprite.get_global_transform() * (part.sprite.offset + Vector2(s[1], s[2]))
	return Vector2.INF


static func clear(pet: Dictionary) -> void:
	pet.erase("mud")


## Draws the splats on one part, as a child of its sprite (so it moves, squashes and turns with
## it, and is shaded with it on the far side).
class Layer extends Node2D:
	var spots: Array = []

	func _draw() -> void:
		for s in spots:
			var at := Vector2(s[1], s[2])
			var r := float(s[3])
			var seed := int(s[4])
			var col: Color = Mud.COLORS.get(s[5] if s.size() > 5 else "mud", Mud.COLORS["mud"])
			draw_colored_polygon(Crayon.blob(at, Vector2(r, r * 0.82) * 0.92, seed, 18, 0.28), Color(col, 0.55))
			Crayon.fill_blob(self, at, Vector2(r, r * 0.82), col, seed, 0.28)
			# A few flicks around it, the way a splat lands.
			for i in 3:
				var a := TAU * absf(Crayon.noise(seed, i))
				var d := r * (1.25 + 0.3 * absf(Crayon.noise(seed + 1, i)))
				Crayon.fill_blob(self, at + Vector2(cos(a), sin(a)) * d, Vector2(r, r) * 0.2, col, seed + 5 + i, 0.2)
