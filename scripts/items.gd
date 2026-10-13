class_name Items
extends RefCounted
## Every food, toy, piece of furniture and piece of clothing behind one interface - whether a
## kid drew it, it came in the free starter kit, or it was bought in the shop.
##
## An item is a Dictionary: id, category, name, words, shine ("" or a Shiny mode), wear (for
## clothes: head / eyes / neck / back), height (furniture's size in a place, world px), plus
## "_img" and "_tex" at runtime. Kit and shop items are the game's own drawings, baked into
## res://art by tools/bake_art.gd; drawn items live in user://items/<id>/.
##
## A kid never HAS to draw: the starter kit covers every category, so a pet can have a
## favourite food and a decorated home on day one, and drawing is always the better option
## rather than the only one.

const CATEGORIES := ["food", "toy", "furniture", "clothing"]
const DRAWN_ROOT := "user://items"

## Free from the start.
const KIT := {
	"kit_bed": {"category": "furniture", "name": "Comfy Bed", "words": ["cozy"], "height": 70},
	"kit_cushion": {"category": "furniture", "name": "Cushion", "words": ["cozy"], "height": 55},
	"kit_doghouse": {"category": "furniture", "name": "Pet House", "words": ["cozy", "hidey"], "height": 190},
	"kit_tree": {"category": "furniture", "name": "Tree", "words": ["climbable", "shady"], "height": 330},
	"kit_bush": {"category": "furniture", "name": "Bush", "words": ["hidey"], "height": 120},
	"kit_rock": {"category": "furniture", "name": "Big Rock", "words": ["climbable"], "height": 110},
	"kit_pond": {"category": "furniture", "name": "Pond", "words": ["splashy"], "height": 70},
	"kit_trampoline": {"category": "furniture", "name": "Trampoline", "words": ["bouncy"], "height": 90},
	"kit_lamp": {"category": "furniture", "name": "Lamp", "words": ["warm", "glowy"], "height": 200},
	"kit_campfire": {"category": "furniture", "name": "Campfire", "words": ["warm", "glowy"], "height": 90},
	"kit_umbrella": {"category": "furniture", "name": "Umbrella", "words": ["shady"], "height": 230},
	"kit_fence": {"category": "furniture", "name": "Fence", "words": [], "height": 80},
	"kit_flowerpot": {"category": "furniture", "name": "Flowers", "words": [], "height": 90},
	"kit_sign": {"category": "furniture", "name": "Sign", "words": [], "height": 150},
	"kit_slide": {"category": "furniture", "name": "Slide", "words": ["slidey"], "height": 180},
	"kit_tent": {"category": "furniture", "name": "Tent", "words": ["cozy", "hidey"], "height": 170},
	"kit_hammock": {"category": "furniture", "name": "Hammock", "words": ["cozy"], "height": 140},
	"kit_snowman": {"category": "furniture", "name": "Snowman", "words": [], "height": 200},
	"kit_scratch_post": {"category": "furniture", "name": "Scratch Post", "words": ["scratchy"], "height": 160},
	"kit_drum": {"category": "furniture", "name": "Drum", "words": ["musical"], "height": 80},
	"kit_fruit_tree": {"category": "furniture", "name": "Apple Tree", "words": ["tasty", "shady"], "height": 300},
	"kit_toybox": {"category": "furniture", "name": "Toy Box", "words": ["hidey"], "height": 90},
	# The houses that come with ready-built homes, and their decorations - free in the drawer too.
	"house_cottage": {"category": "furniture", "name": "Cottage", "words": ["cozy", "hidey"], "height": 320, "house": true},
	"house_mushroom": {"category": "furniture", "name": "Mushroom House", "words": ["cozy", "hidey"], "height": 330, "house": true},
	"house_beach_hut": {"category": "furniture", "name": "Beach Hut", "words": ["cozy", "hidey", "shady"], "height": 320, "house": true},
	"house_shell": {"category": "furniture", "name": "Shell House", "words": ["cozy", "hidey"], "height": 300, "house": true},
	"house_igloo": {"category": "furniture", "name": "Igloo", "words": ["cozy", "hidey", "warm"], "height": 260, "house": true},
	"house_adobe": {"category": "furniture", "name": "Adobe House", "words": ["cozy", "hidey", "shady"], "height": 300, "house": true},
	"house_jungle_hut": {"category": "furniture", "name": "Jungle Hut", "words": ["cozy", "hidey", "climbable"], "height": 340, "house": true},
	"house_burrow": {"category": "furniture", "name": "Burrow", "words": ["cozy", "hidey", "warm"], "height": 260, "house": true},
	"house_stone_hut": {"category": "furniture", "name": "Stone Hut", "words": ["cozy", "hidey", "shady"], "height": 300, "house": true},
	"house_stilt": {"category": "furniture", "name": "Stilt House", "words": ["cozy", "hidey", "climbable"], "height": 360, "house": true},
	"house_cloud_castle": {"category": "furniture", "name": "Cloud Castle", "words": ["cozy", "hidey", "bouncy"], "height": 380, "house": true},
	"house_moon_base": {"category": "furniture", "name": "Moon Base", "words": ["cozy", "hidey", "warm"], "height": 300, "house": true},
	"house_castle_keep": {"category": "furniture", "name": "Castle Keep", "words": ["cozy", "hidey", "fancy"], "height": 380, "house": true},
	"house_gingerbread": {"category": "furniture", "name": "Gingerbread House", "words": ["cozy", "hidey", "tasty"], "height": 320, "house": true},
	"deco_mailbox": {"category": "furniture", "name": "Mailbox", "words": [], "height": 120},
	"deco_mushroom_stool": {"category": "furniture", "name": "Toadstool", "words": ["cozy"], "height": 80},
	"deco_log_bench": {"category": "furniture", "name": "Log Bench", "words": ["cozy", "climbable"], "height": 80},
	"deco_sandcastle": {"category": "furniture", "name": "Sandcastle", "words": ["hidey"], "height": 110},
	"deco_seashell_chair": {"category": "furniture", "name": "Shell Chair", "words": ["cozy", "fancy"], "height": 110},
	"deco_snow_pile": {"category": "furniture", "name": "Snow Pile", "words": ["bouncy"], "height": 80},
	"deco_crystal_lamp": {"category": "furniture", "name": "Crystal Lamp", "words": ["glowy", "fancy"], "height": 130},
	"deco_lantern": {"category": "furniture", "name": "Lantern", "words": ["warm", "glowy"], "height": 150},
	"deco_lily_pad": {"category": "furniture", "name": "Lily Pad", "words": ["splashy"], "height": 50},
	"deco_cloud_bench": {"category": "furniture", "name": "Cloud Bench", "words": ["cozy", "bouncy"], "height": 90},
	"deco_moon_flag": {"category": "furniture", "name": "Moon Flag", "words": [], "height": 170},
	"deco_candy_lamp": {"category": "furniture", "name": "Candy Lamp", "words": ["glowy", "tasty"], "height": 170},
	"deco_hay_bale": {"category": "furniture", "name": "Hay Bale", "words": ["cozy", "climbable"], "height": 90},
	"kit_ball": {"category": "toy", "name": "Ball", "words": ["bouncy", "rolly"]},
	"kit_rope": {"category": "toy", "name": "Rope", "words": ["stretchy", "chewy"]},
	"kit_frisbee": {"category": "toy", "name": "Flying Disc", "words": ["floaty"]},
	"kit_stick": {"category": "toy", "name": "Stick", "words": ["spinny"]},
	"kit_duck": {"category": "toy", "name": "Squeaky Duck", "words": ["squeaky"]},
	"kit_teddy": {"category": "toy", "name": "Teddy", "words": ["soft"]},
	"kit_puzzle_ball": {"category": "toy", "name": "Treat Ball", "words": ["puzzly", "rolly"]},
	"kit_chew_bone": {"category": "toy", "name": "Chew Bone", "words": ["chewy"]},
	"kit_log": {"category": "toy", "name": "Big Log", "words": ["heavy", "rolly"]},
	"kit_apple": {"category": "food", "name": "Apple", "words": ["juicy", "healthy"]},
	"kit_bone": {"category": "food", "name": "Bone", "words": ["meaty", "chewy"]},
	"kit_fish": {"category": "food", "name": "Fish", "words": ["fishy"]},
	"kit_cake": {"category": "food", "name": "Cake", "words": ["sweet"]},
	"kit_carrot": {"category": "food", "name": "Carrot", "words": ["crunchy", "healthy"]},
	"kit_cookie": {"category": "food", "name": "Cookie", "words": ["sweet", "crunchy"]},
	"kit_bugs": {"category": "food", "name": "Bug Snack", "words": ["buggy", "weird"]},
	"kit_pizza": {"category": "food", "name": "Pizza", "words": ["meaty"]},
	"kit_icecream": {"category": "food", "name": "Ice Cream", "words": ["cold", "sweet"]},
	"kit_chili": {"category": "food", "name": "Chili", "words": ["spicy"]},
	# The Bath drawer. "soapy" washes mud off; "fluffy" brushes a pet till it is fluffy.
	"kit_sponge": {"category": "bath", "name": "Sponge", "words": ["soapy"]},
	"kit_brush": {"category": "bath", "name": "Brush", "words": ["fluffy"]},
}

## Bought with gold stars (.ai/shop.md). "uses" marks a consumable; everything else is kept.
## "prize" items are never on sale - they are won.
const SHOP := {
	"shiny_ball": {"category": "toy", "name": "Shiny Ball", "words": ["bouncy", "rolly"], "price": 30, "shine": "gold"},
	"golden_bone": {"category": "toy", "name": "Golden Bone", "words": ["chewy"], "price": 30, "shine": "gold"},
	"glitter_disc": {"category": "toy", "name": "Glitter Disc", "words": ["floaty"], "price": 35, "shine": "glitter"},
	"rainbow_rope": {"category": "toy", "name": "Rainbow Rope", "words": ["stretchy"], "price": 35, "shine": "rainbow"},
	"crystal_squeaker": {"category": "toy", "name": "Crystal Squeaker", "words": ["squeaky"], "price": 25, "shine": "silver"},
	"star_plush": {"category": "toy", "name": "Star Plush", "words": ["soft"], "price": 30, "shine": "gold"},
	"puzzle_cube": {"category": "toy", "name": "Puzzle Cube", "words": ["puzzly"], "price": 40, "shine": "rainbow"},
	"rocket_ball": {"category": "toy", "name": "Rocket Ball", "words": ["rolly", "spinny"], "price": 35, "shine": "gold"},
	"star_snack": {"category": "food", "name": "Star Snack", "words": ["sweet"], "price": 15, "shine": "gold", "uses": 1,
		"note": "Every stat trains faster for 10 minutes"},
	"shop_throne": {"category": "furniture", "name": "Throne", "words": ["fancy", "cozy"], "price": 60, "shine": "gold", "height": 200},
	"shop_rainbow_slide": {"category": "furniture", "name": "Rainbow Slide", "words": ["slidey", "bouncy"], "price": 50, "shine": "rainbow", "height": 220},
	"shop_hot_tub": {"category": "furniture", "name": "Hot Tub", "words": ["warm", "splashy"], "price": 45, "height": 100},
	"shop_treehouse": {"category": "furniture", "name": "Treehouse", "words": ["climbable", "hidey", "cozy"], "price": 70, "height": 380},
	"shop_piano": {"category": "furniture", "name": "Piano", "words": ["musical", "fancy"], "price": 45, "height": 160},
	"shop_castle_bed": {"category": "furniture", "name": "Castle Bed", "words": ["cozy", "fancy"], "price": 65, "height": 220},
	"hat_party": {"category": "clothing", "name": "Party Hat", "words": ["silly"], "price": 10, "wear": "head"},
	"hat_top": {"category": "clothing", "name": "Top Hat", "words": ["fancy"], "price": 18, "wear": "head"},
	"hat_crown": {"category": "clothing", "name": "Crown", "words": ["fancy"], "price": 50, "wear": "head", "shine": "gold"},
	"hat_beanie": {"category": "clothing", "name": "Beanie", "words": ["warm", "cozy"], "price": 12, "wear": "head"},
	"hat_cowboy": {"category": "clothing", "name": "Cowboy Hat", "words": ["brave", "cool"], "price": 15, "wear": "head"},
	"hat_wizard": {"category": "clothing", "name": "Wizard Hat", "words": ["spooky"], "price": 20, "wear": "head"},
	"hat_pirate": {"category": "clothing", "name": "Pirate Hat", "words": ["brave"], "price": 18, "wear": "head"},
	"hat_flowers": {"category": "clothing", "name": "Flower Crown", "words": ["cozy", "fancy"], "price": 15, "wear": "head"},
	"hat_chef": {"category": "clothing", "name": "Chef Hat", "words": ["silly"], "price": 12, "wear": "head"},
	"hat_cap": {"category": "clothing", "name": "Cap", "words": ["sporty", "cool"], "price": 10, "wear": "head"},
	"glasses_sun": {"category": "clothing", "name": "Sunglasses", "words": ["cool"], "price": 12, "wear": "eyes"},
	"glasses_heart": {"category": "clothing", "name": "Heart Glasses", "words": ["silly"], "price": 12, "wear": "eyes"},
	"glasses_round": {"category": "clothing", "name": "Round Glasses", "words": ["fancy"], "price": 12, "wear": "eyes"},
	"glasses_monocle": {"category": "clothing", "name": "Monocle", "words": ["fancy"], "price": 15, "wear": "eyes"},
	"neck_bowtie": {"category": "clothing", "name": "Bow Tie", "words": ["fancy"], "price": 10, "wear": "neck"},
	"neck_scarf": {"category": "clothing", "name": "Scarf", "words": ["warm", "cozy"], "price": 12, "wear": "neck"},
	"neck_bandana": {"category": "clothing", "name": "Bandana", "words": ["cool", "sporty"], "price": 10, "wear": "neck"},
	"neck_medal": {"category": "clothing", "name": "Gold Medal", "words": ["sporty"], "price": 0, "wear": "neck", "prize": true},
	"back_cape": {"category": "clothing", "name": "Hero Cape", "words": ["brave"], "price": 25, "wear": "back"},
	"back_backpack": {"category": "clothing", "name": "Backpack", "words": ["sporty"], "price": 15, "wear": "back"},
	"back_wings": {"category": "clothing", "name": "Fairy Wings", "words": ["silly", "fancy"], "price": 30, "wear": "back", "shine": "glitter"},
	# One marker lasts a whole drawing - every part of a new pet, or one toy -
	# and is used up when it is finished. So they cost a lot.
	"marker_gold": {"category": "supply", "name": "Gold Marker", "words": [], "price": 120, "uses": 1, "shine": "gold",
		"note": "Draw a whole pet (or one thing) in shining gold"},
	"marker_rainbow": {"category": "supply", "name": "Rainbow Marker", "words": [], "price": 150, "uses": 1, "shine": "rainbow",
		"note": "Draw a whole pet (or one thing) in shimmering rainbow"},
	"marker_glitter": {"category": "supply", "name": "Glitter Marker", "words": [], "price": 120, "uses": 1, "shine": "glitter",
		"note": "Draw a whole pet (or one thing) in sparkly glitter"},
}

## The marker each shine mode comes from, and the colour it lays down on the page.
const MARKERS := {"gold": ["marker_gold", Color("#f2c94c")], "rainbow": ["marker_rainbow", Color("#f4eefa")],
	"glitter": ["marker_glitter", Color("#f6c6ea")]}

static var _cache := {}
static var _pivots := {}


static func is_catalog(id: String) -> bool:
	return KIT.has(id) or SHOP.has(id)


static func catalog(id: String) -> Dictionary:
	return KIT.get(id, SHOP.get(id, {}))


static func art_group(id: String) -> String:
	for prefix in ["hat_", "glasses_", "neck_", "back_", "icon_", "marker_", "trick_"]:
		if id.begins_with(prefix):
			return "wear"
	for prefix in ["tool_", "edit_", "part_", "size_", "ui_", "snd_"]:
		if id.begins_with(prefix):
			return "ui"
	if id.begins_with("house_") or id.begins_with("deco_"):
		return "homes"
	return "things"


## An item by id, with its picture loaded. Empty if it does not exist.
static func get_item(id: String) -> Dictionary:
	if _cache.has(id):
		return _cache[id]
	var item := {}
	if is_catalog(id):
		item = catalog(id).duplicate(true)
		item["id"] = id
		item["source"] = "kit" if KIT.has(id) else "shop"
		var tex := art_texture(id)
		item["_tex"] = tex
		item["_img"] = tex.get_image()
		item["pivot"] = art_pivot(id, item["_img"])
	else:
		var dir := DRAWN_ROOT + "/" + id
		var data = JSON.parse_string(FileAccess.get_file_as_string(dir + "/item.json"))
		if typeof(data) != TYPE_DICTIONARY:
			return {}
		item = data
		item["source"] = "drawn"
		var img := Image.load_from_file(dir + "/image.png")
		if img == null:
			return {}
		item["_img"] = img
		item["_tex"] = ImageTexture.create_from_image(img)
		if item.get("shine", "") != "" and FileAccess.file_exists(dir + "/shine.png"):
			item["_shine"] = Image.load_from_file(dir + "/shine.png")
		item["_recording"] = Voice.load_recording(dir + "/sound.f32")
	_cache[id] = item
	return item


## The game's own drawing for an art id (an item, an icon, a trick card). A soft placeholder
## if it has not been baked yet, so a missing drawing never crashes a screen.
static func art_texture(id: String) -> Texture2D:
	var path := "res://art/%s/%s.png" % [art_group(id), id]
	if ResourceLoader.exists(path):
		var tex = load(path)
		if tex is Texture2D:
			return tex
	var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	img.fill_rect(Rect2i(12, 12, 72, 72), Color("#d9d2ea"))
	return ImageTexture.create_from_image(img)


static func art_pivot(id: String, img: Image) -> Vector2:
	var group := art_group(id)
	if not _pivots.has(group):
		var path := "res://art/%s/pivots.json" % group
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
		_pivots[group] = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
	var p = _pivots[group].get(id)
	if p is Array and p.size() >= 2:
		return Vector2(float(p[0]), float(p[1]))
	return Vector2(img.get_size()) / 2.0


## Every item a kid can use in a category: the starter kit, shop items they own, and their
## own drawings - their drawings first, because those are the ones they care about.
static func available(profile: Profile, category: String) -> Array:
	var ids := []
	for id in profile.drawn_items():
		var item := get_item(id)
		if item.get("category", "") == category:
			ids.append(id)
	for id in SHOP:
		if SHOP[id]["category"] == category and profile.owned(id) > 0:
			ids.append(id)
	for id in KIT:
		if KIT[id]["category"] == category:
			ids.append(id)
	return ids


## Saves a kid's drawing as a new item and returns it.
static func save_drawn(category: String, image: Image, pivot: Vector2, words: Array,
		shine := "", shine_mask: Image = null, extra := {},
		recording := PackedFloat32Array()) -> Dictionary:
	var id := "item_" + PetStore.new_id().substr(4)
	var dir := DRAWN_ROOT + "/" + id
	DirAccess.make_dir_recursive_absolute(dir)
	image.save_png(dir + "/image.png")
	var data := {"id": id, "category": category, "name": "", "words": words,
		"pivot": [pivot.x, pivot.y], "shine": shine,
		"height": 150 if category == "furniture" else 0}
	data.merge(extra, true)
	if shine != "" and shine_mask != null:
		shine_mask.save_png(dir + "/shine.png")
	Voice.save_recording(dir + "/sound.f32", recording)
	var f := FileAccess.open(dir + "/item.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	_cache.erase(id)
	return get_item(id)


static func pivot_of(item: Dictionary) -> Vector2:
	var p = item.get("pivot", [0, 0])
	return p if p is Vector2 else Vector2(float(p[0]), float(p[1]))


static func display_name(item: Dictionary) -> String:
	var n: String = item.get("name", "")
	if n != "":
		return n
	var words: Array = item.get("words", [])
	var kind: String = {"food": "snack", "toy": "toy", "furniture": "thing", "clothing": "outfit"}.get(
		item.get("category", ""), "thing")
	return ("%s %s" % [words[0], kind]).capitalize() if not words.is_empty() else "My " + kind


## Puts an item's picture on a sprite, shiny if it is. The sprite's origin is the item's pivot.
static func dress_sprite(sprite: Sprite2D, item: Dictionary) -> void:
	sprite.texture = item["_tex"]
	sprite.centered = false
	sprite.offset = -pivot_of(item)
	var shine: String = item.get("shine", "")
	if shine != "":
		Shiny.apply(sprite, item["_img"], shine, item.get("_shine"), sprite.offset)
