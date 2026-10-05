class_name Rivals
extends RefCounted
## The rival pets at competitions - drawn as if by other kids (scripts/art_rivals.gd) and put
## together by exactly the same PetBuilder.add_parts a kid's own pet goes through, so they
## move the same way theirs does.
##
## Rivals have stats for the cup they turn up to, strongest in the event's stat. They are
## friendly - they cheer, they celebrate - and they are beatable at every cup with training
## and good timing.

const SIZES := {"biscuit": "medium", "zippy": "small", "puffles": "small", "captain_fins": "medium",
	"duchess": "medium", "rocky": "big", "noodle": "medium", "mango": "small"}

static var _built := {}
static var _pivots := {}


static func ids() -> Array:
	return ArtRivals.ROSTER.keys()


## A rival as a pet dictionary (cached; a fresh copy of its data each call).
static func build(id: String) -> Dictionary:
	if not _built.has(id):
		_built[id] = _assemble(id)
	var base: Dictionary = _built[id]
	var pet := base.duplicate(true)
	pet["_img"] = base["_img"]
	pet["_tex"] = base["_tex"]
	return pet


static func _assemble(id: String) -> Dictionary:
	var roster: Dictionary = ArtRivals.ROSTER[id]
	var pet := PetBuilder.new_pet()
	pet["id"] = "rival_" + id
	pet["name"] = roster["name"]
	pet["size"] = SIZES.get(id, "medium")
	pet["needs"] = {"food": 1.0, "fun": 1.0, "clean": 1.0, "energy": 1.0}
	PetBuilder.set_body(pet, _image(id + "_body"))
	var parts: Dictionary = roster["parts"]
	for type in PartTypes.ORDER:
		if parts.has(type):
			var art := "%s_%s" % [id, type]
			PetBuilder.add_parts(pet, type, int(parts[type]), _image(art), _pivot(art))
	return pet


static func _image(art: String) -> Image:
	var path := "res://art/rivals/%s.png" % art
	if ResourceLoader.exists(path):
		var tex = load(path)
		if tex is Texture2D:
			return tex.get_image()
	var img := Image.create(120, 120, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	img.fill_rect(Rect2i(10, 10, 100, 100), Color("#c9bfe6"))
	return img


static func _pivot(art: String) -> Vector2:
	if _pivots.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://art/rivals/pivots.json"))
		_pivots = parsed if typeof(parsed) == TYPE_DICTIONARY else {"_": 0}
	var p = _pivots.get(art)
	return Vector2(float(p[0]), float(p[1])) if p is Array else Vector2(60, 60)


## `count` rivals for a cup, the same ones all day: [{id, name, pet}] with stats set.
static func field(kind: String, tier: int, count: int, seed: int) -> Array:
	var pool := ids()
	var chosen := []
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	while chosen.size() < count and not pool.is_empty():
		chosen.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	var range_v: Array = Events.TIERS[tier]["rivals"]
	var main: String = Events.info(kind).get("stat", "")
	var out := []
	for i in chosen.size():
		var pet := build(chosen[i])
		var stats := {}
		for stat in Stats.LIST:
			var v := rng.randf_range(range_v[0], range_v[1])
			if stat != main:
				v *= 0.75
			stats[stat] = v
		# Spread them out: the first is the weakest, the last the toughest.
		if main != "":
			stats[main] = lerpf(range_v[0], range_v[1], (i + 0.5) / chosen.size()) + rng.randf_range(-3.0, 3.0)
		pet["stats"] = stats
		out.append({"id": chosen[i], "name": pet["name"], "pet": pet})
	return out
