class_name Places
extends RefCounted
## Every favourite place a creature can live in. A place is DATA - a palette, a list of props
## and a weather drift - and one renderer (PlacePainter) draws them all. Add a prop kind to the
## painter rather than writing per-place drawing code (the same rule DrawFight keeps for stages).
##
## Art direction (.ai/art-direction.md): nothing in a place may be darker than about 30% value,
## because the creatures are drawn in black and they have to win every frame. Night and caves
## are lavender, not black.
##
## Props are [kind, x, y, scale]. x/y are world pixels on the 1280x720 design screen; the ground
## band where creatures walk runs from y = 440 (the horizon) down past the bottom.

const ORDER := ["meadow", "forest", "beach", "ocean", "mountains", "desert",
	"jungle", "cave", "volcano", "swamp", "sky", "moon", "castle", "candy"]

const DATA := {
	"meadow": {"tags": ["outside", "warm", "grassy"], "name": "Sunny Meadow", "sky": [Color("#a9d8f2"), Color("#e9f6fa")],
		"far": Color("#b5df95"), "ground": Color("#c6e89d"), "drift": "petals",
		"props": [["sun", 1080, 110, 1.0], ["cloud", 330, 130, 1.0], ["cloud", 760, 90, 0.7],
			["tree", 170, 440, 1.25], ["bush", 330, 445, 0.9], ["tree", 1160, 440, 1.0],
			["flower", 520, 470, 1.0], ["flower", 610, 500, 0.9], ["flower", 900, 480, 1.1],
			["flower", 1020, 560, 1.0], ["flower", 250, 620, 1.1]]},
	"forest": {"tags": ["outside", "cool", "grassy"], "name": "Deep Forest", "sky": [Color("#c3e3d0"), Color("#eef7ee")],
		"far": Color("#9fcf9f"), "ground": Color("#bcdca6"), "drift": "leaves",
		"props": [["pine", 90, 445, 1.5], ["pine", 260, 440, 1.2], ["pine", 420, 440, 1.6],
			["pine", 860, 440, 1.3], ["pine", 1030, 445, 1.7], ["pine", 1220, 440, 1.2],
			["mushroom", 600, 470, 1.0], ["mushroom", 690, 520, 0.7], ["bush", 760, 450, 0.8],
			["mushroom", 1100, 600, 0.9]]},
	"beach": {"tags": ["outside", "hot", "sandy", "wet"], "name": "Sandy Beach", "sky": [Color("#9fd6f5"), Color("#eaf7fc")],
		"far": Color("#8fd0e8"), "far_shape": "sea", "ground": Color("#f4e2b0"), "drift": "",
		"props": [["sun", 220, 100, 1.1], ["cloud", 900, 120, 0.9], ["palm", 1090, 450, 1.3],
			["palm", 1210, 460, 1.0], ["shell", 420, 560, 1.0], ["shell", 720, 640, 0.8],
			["rock", 160, 470, 0.8], ["shell", 980, 600, 1.0]]},
	"ocean": {"tags": ["wet", "cool", "sandy"], "name": "Under the Sea", "sky": [Color("#8fcdea"), Color("#c9ecf5")],
		"far": Color("#a5d7e6"), "ground": Color("#eedcb0"), "drift": "bubbles", "water": true,
		"props": [["seaweed", 120, 460, 1.4], ["seaweed", 190, 470, 1.0], ["coral", 380, 455, 1.0],
			["rock", 560, 460, 1.0], ["seaweed", 820, 460, 1.6], ["coral", 990, 470, 1.2],
			["seaweed", 1180, 465, 1.2], ["shell", 680, 620, 0.9], ["shell", 300, 660, 0.8]]},
	"mountains": {"tags": ["outside", "cold", "snowy", "high"], "name": "Snowy Mountains", "sky": [Color("#bcd6ee"), Color("#f1f6fb")],
		"far": Color("#d7e4f0"), "ground": Color("#f4f7fb"), "drift": "snow",
		"props": [["peak", 260, 440, 1.6], ["peak", 700, 440, 2.1], ["peak", 1120, 440, 1.5],
			["pine", 120, 450, 1.0], ["pine", 1000, 455, 1.1], ["pine", 1220, 450, 0.9],
			["rock", 520, 470, 0.8]]},
	"desert": {"tags": ["outside", "hot", "dry", "sandy"], "name": "Dusty Desert", "sky": [Color("#f7d9a8"), Color("#fdf2dc")],
		"far": Color("#f0cf95"), "far_shape": "dunes", "ground": Color("#f6dfa8"), "drift": "",
		"props": [["sun", 1050, 120, 1.3], ["cactus", 200, 450, 1.2], ["cactus", 900, 445, 0.9],
			["rock", 560, 465, 0.9], ["cactus", 1190, 470, 1.0], ["rock", 380, 640, 0.6]]},
	"jungle": {"tags": ["outside", "hot", "wet", "grassy"], "name": "Jungle", "sky": [Color("#b9e3c3"), Color("#ecf8ea")],
		"far": Color("#98d39a"), "ground": Color("#b8dfa0"), "drift": "leaves",
		"props": [["vine", 80, 0, 1.0], ["vine", 330, 0, 0.8], ["vine", 980, 0, 1.1],
			["vine", 1200, 0, 0.9], ["palm", 140, 450, 1.4], ["bush", 360, 450, 1.3],
			["bush", 820, 445, 1.1], ["palm", 1060, 450, 1.5], ["flower", 600, 480, 1.2],
			["bush", 1230, 455, 1.0]]},
	"cave": {"tags": ["inside", "cool", "rocky", "sparkly"], "name": "Crystal Cave", "sky": [Color("#cdbfe6"), Color("#e8e0f4")],
		"far": Color("#bfb0dc"), "far_shape": "stalactites", "ground": Color("#d8cdea"),
		"drift": "sparkles",
		"props": [["crystal", 160, 450, 1.3], ["crystal", 420, 455, 0.9], ["mushroom", 600, 470, 0.9],
			["crystal", 880, 450, 1.6], ["crystal", 1150, 460, 1.0], ["rock", 1010, 470, 0.9]]},
	"volcano": {"tags": ["outside", "hot", "rocky"], "name": "Volcano", "sky": [Color("#f8c4a0"), Color("#fde7d6")],
		"far": Color("#e6b7a0"), "ground": Color("#e7c9b8"), "drift": "embers",
		"props": [["volcano", 760, 440, 1.6], ["rock", 200, 465, 1.1], ["rock", 1120, 470, 1.0],
			["rock", 420, 640, 0.6], ["cloud", 260, 110, 0.7]]},
	"sky": {"tags": ["outside", "cool", "high"], "special": true, "price": 90, "name": "Cloud Kingdom", "sky": [Color("#b6dcf7"), Color("#f2f9fe")],
		"far": Color("#ffffff"), "far_shape": "clouds", "ground": Color("#fbfdff"), "drift": "",
		"props": [["sun", 1000, 120, 1.0], ["cloud", 180, 160, 1.2], ["cloud", 640, 90, 0.8],
			["rainbow", 640, 440, 1.0], ["cloud", 1180, 260, 0.7]]},
	"swamp": {"tags": ["outside", "warm", "wet", "muddy"], "name": "Muddy Swamp", "sky": [Color("#c9dcc0"), Color("#eef3e3")],
		"far": Color("#b2cc9e"), "ground": Color("#c8d7a6"), "drift": "fireflies",
		"props": [["tree", 140, 440, 1.0], ["reed", 330, 460, 1.0], ["reed", 380, 470, 0.8],
			["puddle", 640, 560, 1.4], ["reed", 900, 455, 1.1], ["puddle", 1060, 650, 0.9],
			["tree", 1180, 440, 1.2], ["mushroom", 520, 470, 0.7]]},
	"moon": {"tags": ["cold", "rocky", "bouncy"], "special": true, "price": 120, "name": "The Moon", "sky": [Color("#c7bfe8"), Color("#e9e4f6")],
		"far": Color("#d4cfe6"), "far_shape": "craters", "ground": Color("#e4e1ee"),
		"drift": "twinkle",
		"props": [["planet", 1050, 140, 1.0], ["star", 200, 90, 1.0], ["star", 420, 170, 0.6],
			["star", 640, 70, 0.8], ["star", 830, 210, 0.5], ["star", 1220, 300, 0.7],
			["crater", 380, 560, 1.2], ["crater", 900, 640, 0.9], ["rock", 1150, 470, 0.8]]},
	"castle": {"tags": ["outside", "fancy", "grassy"], "special": true, "price": 150,
		"name": "Castle", "sky": [Color("#b9d6f2"), Color("#eef6fb")],
		"far": Color("#d9d3e8"), "far_shape": "battlements", "ground": Color("#cfe6b0"), "drift": "petals",
		"props": [["tower", 170, 440, 1.3], ["tower", 1110, 440, 1.5], ["flag", 640, 210, 1.0],
			["cloud", 420, 110, 0.8], ["bush", 330, 450, 0.8], ["flower", 900, 500, 1.0],
			["flower", 260, 600, 0.9], ["bush", 960, 455, 0.9]]},
	"candy": {"tags": ["outside", "sweet", "warm"], "special": true, "price": 100,
		"name": "Candy Land", "sky": [Color("#f7c9e0"), Color("#fdf0f6")],
		"far": Color("#e9c3a5"), "ground": Color("#fbd9e6"), "drift": "sprinkles",
		"props": [["lollipop", 150, 450, 1.3], ["candy_cane", 330, 450, 1.1], ["gumdrop", 520, 470, 1.0],
			["lollipop", 1100, 445, 1.5], ["candy_cane", 920, 455, 1.2], ["gumdrop", 760, 640, 0.8],
			["cloud", 640, 110, 0.9], ["gumdrop", 250, 650, 0.7]]},
}

const HORIZON := 440.0
const GROUND_BOTTOM := 700.0


static func get_place(id: String) -> Dictionary:
	return DATA.get(id, DATA["meadow"])


static func display_name(id: String) -> String:
	return get_place(id)["name"]


static func tags(id: String) -> Array:
	return get_place(id).get("tags", [])


## Favourite places a pet can dream of: the special ones are bought in the shop before a pet
## can live there, but any place can be a favourite.
static func is_special(id: String) -> bool:
	return get_place(id).get("special", false)


## How much a pet likes a place: 1 for its favourite, part for sharing words with it.
static func liking(favourite: String, place: String) -> float:
	if favourite == place:
		return 1.0
	var mine := tags(favourite)
	var shared := 0
	for t in tags(place):
		if mine.has(t):
			shared += 1
	return clampf(shared / maxf(1.0, mine.size()), 0.0, 0.8)
