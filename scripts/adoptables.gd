class_name Adoptables
extends RefCounted
## The forty pets in the shop's Adopt tab - creatures the kid did not draw, drawn as if by
## other kids (scripts/art_adopt_*.gd) and put together by the same PetBuilder.add_parts a
## kid's own pet goes through. Here is who they are as pets: size, favourite place,
## personality, favourite food and toy, and what they cost to adopt (.ai/shop.md).
##
## Adopting copies one into the family as a new pet with its own folder, so from then on it is
## exactly like a pet the kid drew: it trains, trusts, wears clothes and enters competitions.

const GROUPS := ["adopt_a", "adopt_b", "adopt_c", "adopt_d"]
const GROUP_NAMES := {"adopt_a": "Meadow & Forest", "adopt_b": "Fliers",
	"adopt_c": "Water & Oddballs", "adopt_d": "Dinos & Monsters"}
const PRICES := {"tiny": 35, "small": 45, "medium": 60, "big": 75, "huge": 90, "giant": 110}

const INFO := {
	"pip": ["adopt_a", "tiny", "meadow", ["cuddly", "shy"], "kit_carrot", "kit_teddy"],
	"bramble": ["adopt_a", "small", "forest", ["shy", "curious"], "kit_bugs", "kit_puzzle_ball"],
	"moss": ["adopt_a", "medium", "swamp", ["calm", "sleepy"], "kit_apple", "kit_ball"],
	"clover": ["adopt_a", "small", "meadow", ["playful", "curious"], "kit_apple", "kit_frisbee"],
	"tank": ["adopt_a", "big", "desert", ["brave", "hungry"], "kit_chili", "kit_rope"],
	"waffles": ["adopt_a", "medium", "mountains", ["cuddly", "playful"], "kit_bone", "kit_teddy"],
	"sprocket": ["adopt_a", "small", "forest", ["clever", "playful"], "kit_fish", "kit_stick"],
	"pudding": ["adopt_a", "small", "swamp", ["hungry", "silly"], "kit_cake", "kit_ball"],
	"boulder": ["adopt_a", "huge", "mountains", ["calm", "brave"], "kit_carrot", "kit_rope"],
	"dottie": ["adopt_a", "small", "meadow", ["playful", "silly"], "kit_bugs", "kit_duck"],
	"skye": ["adopt_b", "huge", "sky", ["calm", "sleepy"], "kit_fish", "kit_frisbee"],
	"hoot": ["adopt_b", "small", "forest", ["clever", "sleepy"], "kit_bugs", "kit_puzzle_ball"],
	"zephyr": ["adopt_b", "small", "jungle", ["sporty", "curious"], "kit_bugs", "kit_frisbee"],
	"blaze": ["adopt_b", "big", "volcano", ["brave", "playful"], "kit_chili", "kit_ball"],
	"petal": ["adopt_b", "small", "meadow", ["fancy", "cuddly"], "kit_icecream", "kit_teddy"],
	"comet": ["adopt_b", "tiny", "moon", ["curious", "silly"], "kit_cookie", "kit_frisbee"],
	"pelly": ["adopt_b", "medium", "beach", ["hungry", "silly"], "kit_fish", "kit_duck"],
	"gizmo": ["adopt_b", "tiny", "cave", ["shy", "clever"], "kit_bugs", "kit_puzzle_ball"],
	"twinkle": ["adopt_b", "tiny", "candy", ["fancy", "playful"], "kit_cake", "kit_duck"],
	"ptera": ["adopt_b", "big", "sky", ["sporty", "brave"], "kit_fish", "kit_stick"],
	"bubbles": ["adopt_c", "medium", "ocean", ["calm", "silly"], "kit_fish", "kit_ball"],
	"squidge": ["adopt_c", "medium", "ocean", ["clever", "playful"], "kit_fish", "kit_puzzle_ball"],
	"shelly": ["adopt_c", "small", "beach", ["brave", "hungry"], "kit_fish", "kit_rope"],
	"finnegan": ["adopt_c", "medium", "ocean", ["playful", "cuddly"], "kit_fish", "kit_ball"],
	"puddles": ["adopt_c", "small", "swamp", ["sporty", "silly"], "kit_bugs", "kit_ball"],
	"coral": ["adopt_c", "small", "ocean", ["shy", "fancy"], "kit_carrot", "kit_duck"],
	"gloop": ["adopt_c", "small", "cave", ["silly", "hungry"], "kit_pizza", "kit_puzzle_ball"],
	"sir_snail": ["adopt_c", "tiny", "swamp", ["calm", "fancy"], "kit_carrot", "kit_teddy"],
	"nessie": ["adopt_c", "giant", "ocean", ["shy", "calm"], "kit_fish", "kit_frisbee"],
	"axel": ["adopt_c", "small", "swamp", ["cuddly", "curious"], "kit_bugs", "kit_duck"],
	"rumble": ["adopt_d", "giant", "jungle", ["brave", "hungry"], "kit_bone", "kit_rope"],
	"trixie": ["adopt_d", "huge", "jungle", ["calm", "brave"], "kit_carrot", "kit_ball"],
	"marshmallow": ["adopt_d", "big", "mountains", ["cuddly", "sleepy"], "kit_icecream", "kit_teddy"],
	"sparkle": ["adopt_d", "big", "candy", ["fancy", "playful"], "kit_cake", "kit_frisbee"],
	"bolt": ["adopt_d", "medium", "moon", ["clever", "sporty"], "kit_cookie", "kit_ball"],
	"cactus_jack": ["adopt_d", "medium", "desert", ["brave", "silly"], "kit_apple", "kit_stick"],
	"gummy": ["adopt_d", "small", "candy", ["silly", "cuddly"], "kit_cake", "kit_duck"],
	"ember": ["adopt_d", "small", "volcano", ["sporty", "playful"], "kit_chili", "kit_stick"],
	"crystal": ["adopt_d", "big", "cave", ["calm", "clever"], "kit_cookie", "kit_puzzle_ball"],
	"mo": ["adopt_d", "medium", "castle", ["silly", "cuddly"], "kit_pizza", "kit_teddy"],
}

## Each one's voice - a recipe like a kid would make (Voice): base, then nudges.
const VOICES := {
	"pip": {"base": "squeak", "pitch": 3.0}, "bramble": {"base": "oink", "pitch": 4.0, "speed": 1.3},
	"moss": {"base": "moo", "pitch": 2.0, "speed": 0.8}, "clover": {"base": "baa", "pitch": 4.0},
	"tank": {"base": "honk", "pitch": -5.0}, "waffles": {"base": "bark", "pitch": 2.0, "wobble": 0.2},
	"sprocket": {"base": "bark", "pitch": 5.0, "speed": 1.3},
	"pudding": {"base": "oink", "pitch": 0.0}, "boulder": {"base": "moo", "pitch": -4.0, "speed": 0.8},
	"dottie": {"base": "bark", "pitch": 7.0, "speed": 1.5},
	"skye": {"base": "hoot", "pitch": -6.0, "speed": 0.6, "echo": 0.6, "wobble": 0.3},
	"hoot": {"base": "hoot", "pitch": 0.0}, "zephyr": {"base": "trill", "pitch": 3.0, "speed": 1.4},
	"blaze": {"base": "roar", "pitch": 4.0, "speed": 1.2}, "petal": {"base": "meow", "pitch": 4.0, "wobble": 0.2},
	"comet": {"base": "chirp", "pitch": 2.0, "echo": 0.4, "bend": 0.5}, "pelly": {"base": "quack", "pitch": -3.0},
	"gizmo": {"base": "squeak", "pitch": 6.0, "speed": 1.4}, "twinkle": {"base": "chirp", "pitch": 5.0, "wobble": 0.3},
	"ptera": {"base": "honk", "pitch": 2.0, "bend": -0.4},
	"bubbles": {"base": "gurgle", "pitch": 3.0, "echo": 0.3}, "squidge": {"base": "gurgle", "pitch": -2.0, "wobble": 0.4},
	"shelly": {"base": "beep", "pitch": 4.0, "speed": 1.5}, "finnegan": {"base": "bark", "pitch": -1.0, "wobble": 0.3},
	"puddles": {"base": "ribbit", "pitch": 0.0}, "coral": {"base": "trill", "pitch": 5.0, "speed": 0.8},
	"gloop": {"base": "gurgle", "pitch": -5.0, "speed": 0.8}, "sir_snail": {"base": "hoot", "pitch": 3.0, "speed": 0.6},
	"nessie": {"base": "moo", "pitch": 3.0, "echo": 0.5, "wobble": 0.3}, "axel": {"base": "squeak", "pitch": -2.0, "wobble": 0.4},
	"rumble": {"base": "roar", "pitch": -3.0}, "trixie": {"base": "trumpet", "pitch": -5.0},
	"marshmallow": {"base": "purr", "pitch": 2.0}, "sparkle": {"base": "baa", "pitch": 6.0, "echo": 0.3, "wobble": 0.3},
	"bolt": {"base": "beep", "pitch": 0.0, "robot": 0.5}, "cactus_jack": {"base": "honk", "pitch": 3.0, "bend": 0.5},
	"gummy": {"base": "boing", "pitch": 2.0}, "ember": {"base": "roar", "pitch": 8.0, "speed": 1.4},
	"crystal": {"base": "hoot", "pitch": -5.0, "echo": 0.5, "robot": 0.2}, "mo": {"base": "roar", "pitch": 1.0, "wobble": 0.5},
}

static var _rosters := {}
static var _built := {}


static func ids_in(group: String) -> Array:
	var out := []
	for id in INFO:
		if INFO[id][0] == group:
			out.append(id)
	return out


static func roster_entry(id: String) -> Dictionary:
	var group: String = INFO[id][0]
	if not _rosters.has(group):
		var script = load("res://scripts/art_%s.gd" % group)
		_rosters[group] = script.ROSTER if script != null else {}
	return _rosters[group].get(id, {"name": id.capitalize(), "parts": {}})


static func price(id: String) -> int:
	return PRICES.get(INFO[id][1], 60)


## The creature as it is in the shop (cached): a pet dictionary with its personality and
## starting stats, ready to show.
static func build(id: String) -> Dictionary:
	if not _built.has(id):
		var info: Array = INFO[id]
		var pet := Roster.assemble(info[0], id, roster_entry(id))
		if pet.is_empty():
			pet = PetBuilder.new_pet()
			var img := Image.create(120, 120, false, Image.FORMAT_RGBA8)
			img.fill(Color("#c9bfe6"))
			PetBuilder.set_body(pet, img)
			pet["name"] = roster_entry(id).get("name", id.capitalize())
		pet["size"] = info[1]
		pet["place"] = info[2]
		pet["personality"] = info[3]
		pet["food"] = {"item": info[4]}
		pet["toy"] = {"item": info[5]}
		pet["needs"] = {"food": 0.8, "fun": 0.8, "clean": 1.0, "energy": 1.0}
		pet["adopted_from"] = id
		pet["voice"] = VOICES.get(id, Voice.default_for(pet)).duplicate()
		Stats.ensure(pet)
		_built[id] = pet
	var base: Dictionary = _built[id]
	var copy := base.duplicate(true)
	copy["_img"] = base["_img"]
	copy["_tex"] = {}
	return copy


## A fresh family pet made from it - its own id, folder and drawings.
static func adopt(id: String) -> Dictionary:
	var pet := build(id)
	var now := Time.get_unix_time_from_system()
	pet["id"] = PetStore.new_id()
	pet["created"] = now
	pet["last_seen"] = now
	pet["love"] = 0
	pet["_img"] = pet["_img"].duplicate()
	return pet
