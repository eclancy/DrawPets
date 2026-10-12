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

const VOICES := {"biscuit": {"base": "bark", "pitch": 1.0}, "zippy": {"base": "trill", "pitch": 2.0, "speed": 1.4},
	"puffles": {"base": "squeak", "pitch": 1.0, "wobble": 0.4}, "captain_fins": {"base": "gurgle", "pitch": -1.0},
	"duchess": {"base": "chirp", "pitch": -1.0, "wobble": 0.2}, "rocky": {"base": "roar", "pitch": -6.0, "speed": 0.8},
	"noodle": {"base": "boing", "pitch": 3.0}, "mango": {"base": "meow", "pitch": 0.0}}

static var _built := {}


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
	var pet := Roster.assemble("rivals", id, ArtRivals.ROSTER[id])
	if pet.is_empty():
		pet = PetBuilder.new_pet()
		var img := Image.create(120, 120, false, Image.FORMAT_RGBA8)
		img.fill(Color("#c9bfe6"))
		PetBuilder.set_body(pet, img)
		pet["name"] = ArtRivals.ROSTER[id]["name"]
	pet["id"] = "rival_" + id
	pet["size"] = SIZES.get(id, "medium")
	pet["needs"] = {"food": 1.0, "fun": 1.0, "clean": 1.0, "energy": 1.0}
	pet["voice"] = VOICES.get(id, {"base": "bark"}).duplicate()
	return pet


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
