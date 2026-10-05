class_name Homes
extends RefCounted
## The ready-built homes a family chooses from when they build on an empty plot: one for each
## place, each with its own house and a few things already set out (.ai/places.md). The kid
## picks one and names it; after that it is theirs to decorate. Homes in special places are
## locked until the place is bought in the shop.
##
## Items are [item id, x, y, scale] in world pixels on the 1280x720 design screen; the house
## stands at the back, near the horizon, so pets walk in front of it.

const PREMADE := {
	"meadow_cottage": {"name": "Meadow Cottage", "place": "meadow", "house": "house_cottage",
		"items": [["house_cottage", 960, 474, 1.0], ["deco_mailbox", 760, 520, 1.0],
			["kit_flowerpot", 1150, 530, 1.0], ["kit_fence", 300, 476, 1.0], ["kit_bed", 520, 610, 1.0]]},
	"mushroom_house": {"name": "Mushroom House", "place": "forest", "house": "house_mushroom",
		"items": [["house_mushroom", 330, 474, 1.0], ["deco_mushroom_stool", 560, 540, 1.0],
			["deco_log_bench", 900, 520, 1.0], ["kit_campfire", 1060, 600, 1.0]]},
	"beach_hut": {"name": "Beach Hut", "place": "beach", "house": "house_beach_hut",
		"items": [["house_beach_hut", 980, 474, 1.0], ["kit_umbrella", 420, 540, 1.0],
			["kit_hammock", 680, 500, 1.0], ["deco_sandcastle", 260, 620, 1.0]]},
	"shell_house": {"name": "Shell House", "place": "ocean", "house": "house_shell",
		"items": [["house_shell", 900, 474, 1.0], ["deco_seashell_chair", 560, 560, 1.0],
			["kit_puzzle_ball", 320, 620, 1.0]]},
	"igloo": {"name": "Snug Igloo", "place": "mountains", "house": "house_igloo",
		"items": [["house_igloo", 360, 476, 1.0], ["kit_snowman", 820, 500, 1.0],
			["deco_snow_pile", 1060, 560, 1.0], ["kit_campfire", 600, 600, 1.0]]},
	"adobe": {"name": "Adobe House", "place": "desert", "house": "house_adobe",
		"items": [["house_adobe", 960, 474, 1.0], ["kit_umbrella", 520, 540, 1.0],
			["deco_hay_bale", 300, 580, 1.0]]},
	"jungle_hut": {"name": "Jungle Hut", "place": "jungle", "house": "house_jungle_hut",
		"items": [["house_jungle_hut", 380, 474, 1.0], ["kit_hammock", 820, 500, 1.0],
			["kit_drum", 1060, 600, 1.0]]},
	"crystal_burrow": {"name": "Crystal Burrow", "place": "cave", "house": "house_burrow",
		"items": [["house_burrow", 920, 474, 1.0], ["deco_crystal_lamp", 560, 520, 1.0],
			["kit_cushion", 340, 610, 1.0]]},
	"stone_hut": {"name": "Stone Hut", "place": "volcano", "house": "house_stone_hut",
		"items": [["house_stone_hut", 320, 474, 1.0], ["deco_lantern", 640, 520, 1.0],
			["kit_rock", 1080, 560, 1.0]]},
	"stilt_house": {"name": "Stilt House", "place": "swamp", "house": "house_stilt",
		"items": [["house_stilt", 900, 474, 1.0], ["deco_lily_pad", 500, 600, 1.0],
			["kit_pond", 260, 560, 1.0]]},
	"cloud_castle": {"name": "Cloud Castle", "place": "sky", "house": "house_cloud_castle",
		"items": [["house_cloud_castle", 640, 470, 1.0], ["deco_cloud_bench", 280, 560, 1.0],
			["kit_trampoline", 1040, 600, 1.0]]},
	"moon_base": {"name": "Moon Base", "place": "moon", "house": "house_moon_base",
		"items": [["house_moon_base", 900, 474, 1.0], ["deco_moon_flag", 420, 520, 1.0],
			["kit_lamp", 1140, 540, 1.0]]},
	"castle_keep": {"name": "Castle Keep", "place": "castle", "house": "house_castle_keep",
		"items": [["house_castle_keep", 360, 474, 1.0], ["deco_lantern", 700, 520, 1.0],
			["kit_flowerpot", 960, 540, 1.0]]},
	"gingerbread": {"name": "Gingerbread House", "place": "candy", "house": "house_gingerbread",
		"items": [["house_gingerbread", 920, 474, 1.0], ["deco_candy_lamp", 520, 520, 1.0],
			["kit_cushion", 300, 610, 1.0]]},
}


static func ids() -> Array:
	return PREMADE.keys()


static func info(id: String) -> Dictionary:
	return PREMADE.get(id, {})


## The home's things as saved entries: {item, pos, scale, flip}.
static func starting_items(id: String) -> Array:
	var out := []
	for it in info(id).get("items", []):
		out.append({"item": it[0], "pos": [it[1], it[2]], "scale": it[3], "flip": false})
	return out
