class_name ArtWear
extends RefCounted
## The game's own drawings of clothes, icons and trick cards. Baked to res://art/wear/ by
## tools/bake_art.gd.
##
## Same house style as ArtThings: coloured pencil or marker, outlined in a darker shade of the
## same colour, never black, nothing darker than about 30% value. Clothes are drawn FACING
## RIGHT (creatures face right) and big - they are scaled to fit each pet when worn. Shiny
## items get their shine at runtime; draw them in light clean colours.
##
## Sheet: 512 x 512, y down, centred on (256, 256).
## Hat pivots are the middle of the brim's underside ("bottom") - where it sits on a head.
## Scarves, bandanas, capes and medals hang from "top". Glasses, bow ties, backpacks and all
## icons pivot on their "center".

const ASSETS := {
	# Clothes - every one is sold in the shop.
	"hat_party": {"pivot": "bottom", "look": "striped party cone hat, pom-pom on top"},
	"hat_top": {"pivot": "bottom", "look": "tall top hat with a ribbon band (plum, not black)"},
	"hat_crown": {"pivot": "bottom", "look": "crown with points and gems (gold - draw pale yellow)"},
	"hat_beanie": {"pivot": "bottom", "look": "knitted beanie with a bobble"},
	"hat_cowboy": {"pivot": "bottom", "look": "cowboy hat, wide curved brim"},
	"hat_wizard": {"pivot": "bottom", "look": "tall floppy wizard hat with stars and moons"},
	"hat_pirate": {"pivot": "bottom", "look": "pirate tricorn, skull-free: a white feather instead"},
	"hat_flowers": {"pivot": "bottom", "look": "flower crown, a ring of daisies and leaves"},
	"hat_chef": {"pivot": "bottom", "look": "puffy white chef hat"},
	"hat_cap": {"pivot": "bottom", "look": "baseball cap, brim pointing right (forward)"},
	"glasses_sun": {"pivot": "center", "look": "sunglasses, two lenses (dark teal, not black)"},
	"glasses_heart": {"pivot": "center", "look": "heart-shaped pink glasses"},
	"glasses_round": {"pivot": "center", "look": "big round nerdy glasses"},
	"glasses_monocle": {"pivot": "center", "look": "monocle on a little chain"},
	"neck_bowtie": {"pivot": "center", "look": "bow tie, polka dots"},
	"neck_scarf": {"pivot": "top", "look": "striped knitted scarf, one end hanging"},
	"neck_bandana": {"pivot": "top", "look": "folded triangle bandana with dots"},
	"neck_medal": {"pivot": "top", "look": "gold medal on a ribbon loop"},
	"back_cape": {"pivot": "top", "look": "superhero cape, flowing back (to the left), star on it"},
	"back_backpack": {"pivot": "center", "look": "small backpack with a pocket"},
	"back_wings": {"pivot": "center", "look": "costume fairy wings, see-through pastel"},
	# Icons - the UI's pictures.
	"icon_star": {"pivot": "center", "look": "gold star sticker, the money of the game (gold)"},
	"icon_heart": {"pivot": "center", "look": "filled red-pink heart - a level of trust"},
	"icon_heart_empty": {"pivot": "center", "look": "the same heart, outline only, pale inside"},
	"icon_speed": {"pivot": "center", "look": "lightning bolt, yellow"},
	"icon_strength": {"pivot": "center", "look": "dumbbell, red ends"},
	"icon_agility": {"pivot": "center", "look": "bouncy coil spring, green"},
	"icon_stamina": {"pivot": "center", "look": "battery, full, blue"},
	"icon_smarts": {"pivot": "center", "look": "light bulb, glowing"},
	"icon_charm": {"pivot": "center", "look": "pink bow ribbon with a sparkle"},
	"icon_food": {"pivot": "center", "look": "pet food bowl, full"},
	"icon_fun": {"pivot": "center", "look": "ball and a squiggle of motion"},
	"icon_clean": {"pivot": "center", "look": "bar of soap with bubbles"},
	"icon_energy": {"pivot": "center", "look": "crescent moon with a small z"},
	"icon_shop": {"pivot": "center", "look": "little shop stall, striped awning"},
	"icon_calendar": {"pivot": "center", "look": "calendar page with rings on top, a star on one day"},
	"icon_home": {"pivot": "center", "look": "little house"},
	"icon_trophy": {"pivot": "center", "look": "trophy cup, two handles (gold)"},
	"icon_ribbon_1": {"pivot": "center", "look": "prize rosette, gold, a 1 in the middle"},
	"icon_ribbon_2": {"pivot": "center", "look": "prize rosette, silver-blue, a 2"},
	"icon_ribbon_3": {"pivot": "center", "look": "prize rosette, bronze-orange, a 3"},
	"icon_lock": {"pivot": "center", "look": "padlock, closed"},
	"icon_wardrobe": {"pivot": "center", "look": "coat hanger with a little shirt"},
	"icon_decorate": {"pivot": "center", "look": "paint palette with a brush"},
	"icon_toys": {"pivot": "center", "look": "toy box with a ball on top"},
	"icon_bath": {"pivot": "center", "look": "a little bathtub on feet, heaped with bubbles"},
	"icon_walk": {"pivot": "center", "look": "a red lead with a loop handle, and two paw prints"},
	"icon_camera": {"pivot": "center", "look": "a chunky toy camera, big lens, a flash"},
	"icon_friends": {"pivot": "center", "look": "two little phones leaning together, a heart hopping between them"},
	"icon_rosette": {"pivot": "center", "look": "a rainbow rosette with a heart in the middle and two ribbon tails - for joining in, not winning"},
	"icon_album": {"pivot": "center", "look": "a photo album open, two little photos in it"},
	"icon_journal": {"pivot": "center", "look": "a diary with a heart on the cover and a ribbon bookmark"},
	"icon_pantry": {"pivot": "center", "look": "picnic basket with an apple"},
	"icon_draw": {"pivot": "center", "look": "a crayon drawing a squiggle"},
	"marker_gold": {"pivot": "center", "look": "felt-tip marker, gold cap (gold)"},
	"marker_rainbow": {"pivot": "center", "look": "felt-tip marker with a rainbow body (rainbow)"},
	"marker_glitter": {"pivot": "center", "look": "felt-tip marker, pink with sparkles (glitter)"},
	# Trick cards - the symbol on each card in the Trick Show.
	"trick_spin": {"pivot": "center", "look": "circular arrow going round"},
	"trick_jump": {"pivot": "center", "look": "arrow arcing up and over"},
	"trick_sit": {"pivot": "center", "look": "arrow pointing down onto a line"},
	"trick_wave": {"pivot": "center", "look": "a waving hand with motion lines"},
	"trick_roll": {"pivot": "center", "look": "two arrows chasing round in a loop, sideways"},
	"trick_bow": {"pivot": "center", "look": "a curtsy - a little figure bowing, or a bow-down arc"},
	"trick_dance": {"pivot": "center", "look": "two music notes and a twirly ribbon"},
	"icon_tricks": {"pivot": "center", "look": "a trick card with a star on it, a swoosh arrow beside it"},
}

## Paper laid under every shape first, so a drawing is opaque like a cut-out sticker: a worn hat
## hides the pet's lines behind it instead of letting them show through the pencil strokes.
const PAPER := Color("#fffdf8")
const SHINE := Color(1, 1, 1, 0.62)


static func assets() -> Dictionary:
	return ASSETS


static func draw(id: String, c: CanvasItem) -> void:
	match id:
		"hat_party":
			_party_hat(c)
		"hat_top":
			_top_hat(c)
		"hat_crown":
			_crown(c)
		"hat_beanie":
			_beanie(c)
		"hat_cowboy":
			_cowboy(c)
		"hat_wizard":
			_wizard(c)
		"hat_pirate":
			_pirate(c)
		"hat_flowers":
			_flower_crown(c)
		"hat_chef":
			_chef(c)
		"hat_cap":
			_cap(c)
		"glasses_sun":
			_sun_glasses(c)
		"glasses_heart":
			_heart_glasses(c)
		"glasses_round":
			_round_glasses(c)
		"glasses_monocle":
			_monocle(c)
		"neck_bowtie":
			_bowtie(c)
		"neck_scarf":
			_scarf(c)
		"neck_bandana":
			_bandana(c)
		"neck_medal":
			_medal(c)
		"back_cape":
			_cape(c)
		"back_backpack":
			_backpack(c)
		"back_wings":
			_wings(c)
		"icon_star":
			_star(c)
		"icon_heart":
			_heart_icon(c, true)
		"icon_heart_empty":
			_heart_icon(c, false)
		"icon_speed":
			_bolt(c)
		"icon_strength":
			_dumbbell(c)
		"icon_agility":
			_spring(c)
		"icon_stamina":
			_battery(c)
		"icon_smarts":
			_bulb(c)
		"icon_charm":
			_charm_bow(c)
		"icon_food":
			_food_bowl(c)
		"icon_fun":
			_fun_ball(c)
		"icon_clean":
			_soap(c)
		"icon_energy":
			_moon(c)
		"icon_shop":
			_shop(c)
		"icon_calendar":
			_calendar(c)
		"icon_home":
			_house(c)
		"icon_trophy":
			_trophy(c)
		"icon_ribbon_1":
			_rosette(c, 1, Color("#ffd75e"), Color("#fff3bd"), 401)
		"icon_ribbon_2":
			_rosette(c, 2, Color("#a7c3ea"), Color("#e8f0fb"), 421)
		"icon_ribbon_3":
			_rosette(c, 3, Color("#f2a465"), Color("#fde3cc"), 441)
		"icon_lock":
			_lock(c)
		"icon_wardrobe":
			_hanger(c)
		"icon_bath":
			_icon_bath(c)
		"icon_walk":
			_icon_walk(c)
		"icon_camera":
			_icon_camera(c)
		"icon_rosette":
			_icon_rosette(c)
		"icon_friends":
			_icon_friends(c)
		"icon_album":
			_icon_album(c)
		"icon_journal":
			_icon_journal(c)
		"icon_decorate":
			_palette(c)
		"icon_toys":
			_toy_box(c)
		"icon_pantry":
			_basket(c)
		"icon_draw":
			_crayon_icon(c)
		"marker_gold":
			_felt_marker(c, Color("#fff4cf"), Color("#ffdd6e"), Color("#f7c94e"), "gold", 501)
		"marker_rainbow":
			_felt_marker(c, Color("#fff8f0"), Color("#efe8fb"), Color("#c9b4f4"), "rainbow", 521)
		"marker_glitter":
			_felt_marker(c, Color("#f7a8d0"), Color("#fbcbe3"), Color("#f290c0"), "glitter", 541)
		"trick_spin":
			_trick_spin(c)
		"trick_dance":
			_trick_dance(c)
		"icon_tricks":
			_icon_tricks(c)
		"trick_jump":
			_trick_jump(c)
		"trick_sit":
			_trick_sit(c)
		"trick_wave":
			_trick_wave(c)
		"trick_roll":
			_trick_roll(c)
		"trick_bow":
			_trick_bow(c)


# --- Hats --------------------------------------------------------------------------------------

## Marker: a striped cone hat. The stripes are clipped to the cone so they stay inside it.
static func _party_hat(c: CanvasItem) -> void:
	var cone := PackedVector2Array([Vector2(150, 440), Vector2(256, 110), Vector2(362, 440)])
	_under(c, cone)
	Crayon.marker_fill(c, cone, Color("#8fd0f0"), 41)
	for i in 4:
		var y := 170.0 + i * 70.0
		var band := PackedVector2Array([Vector2(100, y), Vector2(412, y - 30), Vector2(412, y),
			Vector2(100, y + 30)])
		for piece in Geometry2D.intersect_polygons(band, cone):
			Crayon.marker_fill(c, piece, Color("#f7a6c8"), 42 + i, 18.0)
	Crayon.marker_line(c, cone, Color("#3d7fa8"), 10.0, 43)
	_mark(c, Crayon.blob(Vector2(256, 98), Vector2(40, 38), 44, 14, 0.15), Color("#ffd166"), 45, 9.0)
	_mark(c, Crayon.ellipse(Vector2(256, 448), Vector2(118, 20)), Color("#f7a6c8"), 46, 9.0)


## Marker: a plum top hat - brim, tall crown with a rose band, and the lighter top showing.
static func _top_hat(c: CanvasItem) -> void:
	var plum := Color("#a77cc4")
	_mark(c, Crayon.ellipse(Vector2(256, 418), Vector2(182, 32), 48), plum.lightened(0.1), 61)
	var crown := _join([[Vector2(150, 108), Vector2(362, 108)],
		_arc(Vector2(256, 410), Vector2(92, 18), 0.0, PI, 16)])
	_under(c, crown)
	Crayon.marker_fill(c, crown, plum, 62)
	var band := PackedVector2Array([Vector2(120, 326), Vector2(392, 326), Vector2(392, 384),
		Vector2(120, 384)])
	for piece in Geometry2D.intersect_polygons(band, crown):
		Crayon.marker_fill(c, piece, Color("#f59cbc"), 63, 18.0)
	Crayon.line(c, Vector2(186, 140), Vector2(192, 304), SHINE, 14.0, 64)
	Crayon.marker_line(c, crown, plum.darkened(0.5), 11.0, 65)
	_mark(c, Crayon.ellipse(Vector2(256, 108), Vector2(106, 20), 40), plum.lightened(0.3), 66, 9.0)


## Pencil: a pale gold crown - five points with balls on the tips, a rim with gems.
static func _crown(c: CanvasItem) -> void:
	var gold := Color("#ffe27a")
	var tips := [Vector2(108, 182), Vector2(182, 146), Vector2(256, 112), Vector2(330, 146),
		Vector2(404, 182)]
	var body := PackedVector2Array([Vector2(126, 440), tips[0], Vector2(152, 300), tips[1],
		Vector2(220, 286), tips[2], Vector2(292, 286), tips[3], Vector2(360, 300), tips[4],
		Vector2(386, 440)])
	_pen(c, body, gold, 71, 10.0)
	Crayon.line(c, Vector2(250, 190), Vector2(244, 330), SHINE, 12.0, 72)
	for i in tips.size():
		var tip: Vector2 = tips[i]
		_pen(c, Crayon.ellipse(tip, Vector2(21, 21), 20), Color("#fff1b0"), 73 + i, 8.0)
	_pen(c, Crayon.rounded_rect(Rect2(112, 362, 288, 82), 14), Color("#ffd35a"), 79, 10.0)
	_pen(c, Crayon.ellipse(Vector2(256, 403), Vector2(32, 25), 24), Color("#f78fa7"), 80, 8.0)
	for i in 2:
		var x := 172.0 + i * 168.0
		var gem := PackedVector2Array([Vector2(x, 381), Vector2(x + 21, 403), Vector2(x, 425),
			Vector2(x - 21, 403)])
		_pen(c, gem, Color("#86d4e8"), 81 + i, 8.0)
	Crayon.line(c, Vector2(130, 378), Vector2(222, 378), SHINE, 8.0, 83)


## Pencil: a knitted beanie - ribbed cuff, a yellow stripe and a fuzzy bobble.
static func _beanie(c: CanvasItem) -> void:
	var red := Color("#f2846c")
	var yellow := Color("#ffe08a")
	var dome := _arc(Vector2(256, 362), Vector2(166, 214), PI, TAU, 32)
	_under(c, dome)
	Crayon.pencil_fill(c, dome, red, 91)
	var stripe := PackedVector2Array([Vector2(60, 232), Vector2(452, 232), Vector2(452, 276),
		Vector2(60, 276)])
	for piece in Geometry2D.intersect_polygons(stripe, dome):
		Crayon.pencil_fill(c, piece, yellow, 92)
	for i in 5:
		var x := 136.0 + i * 60.0
		var top := Vector2(256.0 + (x - 256.0) * 0.3, 176)
		var rib := _cubic(Vector2(x, 352), Vector2(x, 280), Vector2(256.0 + (x - 256.0) * 0.8, 210), top, 10)
		Crayon.pencil_line(c, rib, red.darkened(0.3), 4.0, 93 + i, false)
	Crayon.pencil_line(c, dome, red.darkened(0.45), 10.0, 99)
	var cuff := Crayon.rounded_rect(Rect2(78, 334, 356, 108), 34)
	_under(c, cuff)
	Crayon.pencil_fill(c, cuff, red.darkened(0.05), 100)
	for i in 12:
		var x := 106.0 + i * 27.0
		Crayon.line(c, Vector2(x, 348), Vector2(x, 428), red.darkened(0.32), 5.0, 101 + i, 1.5)
	Crayon.pencil_line(c, cuff, red.darkened(0.45), 10.0, 113)
	var bob_at := Vector2(250, 134)
	for i in 28:
		var d := Vector2.from_angle(TAU * i / 28.0)
		Crayon.line(c, bob_at + d * 46.0, bob_at + d * (72.0 + Crayon.noise(114, i) * 7.0),
			yellow.darkened(0.4), 6.0, 115 + i, 1.0)
	_pen(c, Crayon.blob(bob_at, Vector2(62, 58), 116, 22, 0.14), yellow, 117, 9.0)


## Marker: a tan cowboy hat - dented crown with a red band, wide brim curling up at the sides.
static func _cowboy(c: CanvasItem) -> void:
	var tan := Color("#e3aa6e")
	var crown := _join([[Vector2(150, 396)],
		_cubic(Vector2(150, 396), Vector2(158, 300), Vector2(160, 232), Vector2(174, 198)),
		_cubic(Vector2(174, 198), Vector2(184, 150), Vector2(236, 152), Vector2(256, 186)),
		_cubic(Vector2(256, 186), Vector2(276, 152), Vector2(328, 150), Vector2(338, 198)),
		_cubic(Vector2(338, 198), Vector2(352, 232), Vector2(354, 300), Vector2(362, 396))])
	_under(c, crown)
	Crayon.marker_fill(c, crown, tan, 111)
	var band := PackedVector2Array([Vector2(120, 326), Vector2(392, 326), Vector2(392, 382),
		Vector2(120, 382)])
	for piece in Geometry2D.intersect_polygons(band, crown):
		Crayon.marker_fill(c, piece, Color("#ea7468"), 112, 18.0)
	Crayon.marker_line(c, _cubic(Vector2(256, 192), Vector2(250, 220), Vector2(258, 246),
		Vector2(252, 276), 8), tan.darkened(0.35), 7.0, 113, false)
	Crayon.line(c, Vector2(186, 220), Vector2(178, 310), SHINE, 12.0, 114)
	Crayon.marker_line(c, crown, tan.darkened(0.5), 11.0, 115)
	var brim := _join([
		_cubic(Vector2(462, 316), Vector2(424, 392), Vector2(330, 404), Vector2(256, 404)),
		_cubic(Vector2(256, 404), Vector2(182, 404), Vector2(88, 392), Vector2(50, 316)),
		_cubic(Vector2(50, 316), Vector2(70, 420), Vector2(176, 448), Vector2(256, 448)),
		_cubic(Vector2(256, 448), Vector2(336, 448), Vector2(442, 420), Vector2(462, 316))])
	_mark(c, brim, tan.darkened(0.06), 116)


## Marker: a tall floppy wizard hat whose tip flops back (left), with yellow stars and moons.
static func _wizard(c: CanvasItem) -> void:
	var blue := Color("#8c97f0")
	var yellow := Color("#ffe27a")
	var spine := _cubic(Vector2(256, 416), Vector2(256, 250), Vector2(266, 88), Vector2(100, 196), 28)
	var cone := _band(spine, 206.0, 6.0)
	_under(c, cone)
	Crayon.marker_fill(c, cone, blue, 121)
	var deco := [
		Crayon.star(spine[4] + Vector2(-38, 8), 34.0, 122),
		_crescent(spine[6] + Vector2(48, 0), 32.0, Vector2(14, -10), 28.0),
		Crayon.star(spine[12] + Vector2(8, 4), 26.0, 123),
		Crayon.star(spine[19] + Vector2(0, 4), 16.0, 124),
		_crescent(spine[9] + Vector2(-36, 10), 18.0, Vector2(8, -6), 16.0)]
	for i in deco.size():
		var shape: PackedVector2Array = deco[i]
		for piece in Geometry2D.intersect_polygons(shape, cone):
			_under(c, piece)
			Crayon.marker_fill(c, piece, yellow, 125 + i, 12.0)
			Crayon.marker_line(c, piece, yellow.darkened(0.45), 6.0, 130 + i)
	Crayon.marker_line(c, cone, blue.darkened(0.5), 11.0, 135)
	_mark(c, Crayon.star(spine[spine.size() - 1] + Vector2(-4, 6), 30.0, 136), yellow, 137, 8.0)
	_mark(c, Crayon.ellipse(Vector2(256, 416), Vector2(182, 30), 48), blue.darkened(0.08), 138)


## Marker: a navy-lavender tricorn with gold trim and a white feather sweeping back.
static func _pirate(c: CanvasItem) -> void:
	var navy := Color("#7a8bca")
	var gold := Color("#ffe08a")
	var white := Color("#fbf8f0")
	var line := Color("#958fc2")
	var dome := _arc(Vector2(256, 356), Vector2(128, 186), PI, TAU, 24)
	_mark(c, dome, navy.darkened(0.1), 141)
	var quill := _cubic(Vector2(232, 330), Vector2(212, 230), Vector2(160, 150), Vector2(60, 110), 20)
	var feather := _leaf(quill, 96.0)
	_under(c, feather)
	Crayon.pencil_fill(c, feather, white, 142)
	for i in range(4, 19, 2):
		var p: Vector2 = quill[i]
		var d := (quill[i + 1] - quill[i - 1]).normalized()
		var reach := 40.0 * sin(PI * i / 20.0)
		for side: float in [-1.0, 1.0]:
			var tip := p + d.orthogonal() * side * reach - d * 16.0
			Crayon.line(c, p, tip, line.lightened(0.15), 4.0, 143 + i, 1.0)
	Crayon.pencil_line(c, feather, line, 9.0, 165)
	Crayon.pencil_line(c, quill, line, 5.0, 166, false)
	var top_edge := _join([
		_cubic(Vector2(460, 246), Vector2(420, 316), Vector2(330, 346), Vector2(256, 346)),
		_cubic(Vector2(256, 346), Vector2(182, 346), Vector2(92, 316), Vector2(52, 246))])
	var brim := _join([[Vector2(122, 442), Vector2(390, 442)],
		_cubic(Vector2(390, 442), Vector2(424, 420), Vector2(452, 340), Vector2(460, 246)),
		top_edge,
		_cubic(Vector2(52, 246), Vector2(60, 340), Vector2(88, 420), Vector2(122, 442))])
	_mark(c, brim, navy, 167)
	Crayon.line(c, Vector2(96, 300), Vector2(118, 392), SHINE, 11.0, 168)
	Crayon.marker_line(c, top_edge, gold.darkened(0.45), 26.0, 169, false)
	Crayon.marker_line(c, top_edge, gold, 15.0, 169, false)
	_mark(c, _flower(Vector2(256, 392), 30.0, 8, 170, 0.2), gold, 171, 7.0)


## Pencil: a flower crown - a vine ring seen from the side, small flowers behind, big in front.
static func _flower_crown(c: CanvasItem) -> void:
	var leaf_col := Color("#7cc77a")
	var centre := Vector2(256, 300)
	var ring := Vector2(184, 60)
	var petals := [Color("#fffaf0"), Color("#f9a9c9"), Color("#fffaf0"), Color("#c9b6f6")]
	var hearts := [Color("#ffcf3f"), Color("#ffe27a"), Color("#ffcf3f"), Color("#ffe27a")]
	var lines := [Color("#a99ad0"), Color("#f9a9c9").darkened(0.45), Color("#a99ad0"),
		Color("#c9b6f6").darkened(0.45)]
	for layer in 2:
		if layer == 1:
			var vine := Crayon.ellipse(centre, ring, 48)
			Crayon.marker_line(c, vine, leaf_col.darkened(0.45), 24.0, 141)
			Crayon.marker_line(c, vine, leaf_col, 13.0, 141)
		for k in 10:
			var a := TAU * k / 10.0
			if (sin(a) >= 0.0) != (layer == 1):
				continue
			var at := centre + Vector2(cos(a) * ring.x, sin(a) * ring.y)
			var tangent := Vector2(-sin(a) * ring.x, cos(a) * ring.y).normalized()
			var s := 0.75 + 0.25 * sin(a)
			var leaf := _leaf(PackedVector2Array([at - tangent * 4.0, at + tangent.rotated(-0.5) * 70.0 * s]), 34.0 * s)
			_pen(c, leaf, leaf_col, 142 + k, 6.0)
		for k in 8:
			var a := TAU * k / 8.0 + 0.39
			if (sin(a) >= 0.0) != (layer == 1):
				continue
			var at := centre + Vector2(cos(a) * ring.x, sin(a) * ring.y)
			var s := 0.76 + 0.24 * sin(a)
			var col: Color = petals[k % 4]
			var flower := _flower(at, 56.0 * s, 8, 160 + k, 0.42)
			_under(c, flower)
			Crayon.pencil_fill(c, flower, col, 170 + k)
			Crayon.pencil_line(c, flower, lines[k % 4], 7.0, 180 + k)
			_pen(c, Crayon.blob(at, Vector2(17, 17) * s, 190 + k, 12, 0.1), hearts[k % 4], 200 + k, 6.0)


## Pencil: a puffy chef hat - three soft lobes over a pleated band, shaded lavender.
static func _chef(c: CanvasItem) -> void:
	var white := Color("#fffaf0")
	var shade := Color("#dfe2f4")
	var line := Color("#8c90c0")
	var lobes := [Crayon.blob(Vector2(184, 250), Vector2(96, 88), 151, 20, 0.05),
		Crayon.blob(Vector2(256, 194), Vector2(108, 102), 152, 20, 0.05),
		Crayon.blob(Vector2(328, 250), Vector2(96, 88), 153, 20, 0.05)]
	var puff := _union([lobes[0], lobes[1], lobes[2],
		Crayon.rounded_rect(Rect2(150, 250, 212, 110), 30)])
	_under(c, puff)
	Crayon.pencil_fill(c, puff, white, 154)
	for i in 3:
		var lobe: PackedVector2Array = lobes[i]
		for crescent in Geometry2D.clip_polygons(lobe, _shift(lobe, Vector2(16, -18))):
			for piece in Geometry2D.intersect_polygons(crescent, puff):
				Crayon.pencil_fill(c, piece, shade, 155 + i)
	Crayon.pencil_line(c, _cubic(Vector2(206, 330), Vector2(200, 300), Vector2(206, 270),
		Vector2(222, 252), 8), line, 5.0, 158, false)
	Crayon.pencil_line(c, _cubic(Vector2(306, 330), Vector2(312, 300), Vector2(306, 270),
		Vector2(290, 252), 8), line, 5.0, 159, false)
	Crayon.pencil_line(c, puff, line, 10.0, 160)
	var band := Crayon.rounded_rect(Rect2(160, 332, 192, 112), 16)
	_under(c, band)
	Crayon.pencil_fill(c, band, white, 161)
	Crayon.pencil_fill(c, PackedVector2Array([Vector2(160, 410), Vector2(352, 410),
		Vector2(352, 440), Vector2(160, 440)]), shade, 162)
	for i in 4:
		var x := 198.0 + i * 38.0
		Crayon.line(c, Vector2(x, 348), Vector2(x + 2.0, 428), line.lightened(0.15), 5.0, 163 + i, 1.5)
	Crayon.pencil_line(c, band, line, 10.0, 168)


## Marker: a baseball cap facing right - crown with seams and a star, brim sticking out front.
static func _cap(c: CanvasItem) -> void:
	var red := Color("#f27a6e")
	var brim := _join([
		_cubic(Vector2(300, 366), Vector2(370, 352), Vector2(450, 358), Vector2(490, 388)),
		_cubic(Vector2(490, 388), Vector2(500, 400), Vector2(486, 412), Vector2(462, 412)),
		_cubic(Vector2(462, 412), Vector2(420, 414), Vector2(350, 414), Vector2(300, 410))])
	_mark(c, brim, red.darkened(0.12), 179)
	Crayon.marker_line(c, _cubic(Vector2(380, 370), Vector2(410, 364), Vector2(446, 368), Vector2(474, 386), 8),
		red.lightened(0.25), 8.0, 180, false)
	var crown := _arc(Vector2(228, 410), Vector2(152, 168), PI, TAU, 32)
	_under(c, crown)
	Crayon.marker_fill(c, crown, red, 171)
	Crayon.marker_line(c, _cubic(Vector2(228, 246), Vector2(196, 300), Vector2(172, 360),
		Vector2(166, 408)), red.darkened(0.32), 6.0, 172, false)
	Crayon.marker_line(c, _cubic(Vector2(228, 246), Vector2(258, 300), Vector2(282, 360),
		Vector2(290, 408)), red.darkened(0.32), 6.0, 173, false)
	Crayon.line(c, Vector2(120, 330), Vector2(150, 270), SHINE, 13.0, 174)
	_mark(c, Crayon.star(Vector2(318, 344), 38.0, 175), Color("#ffe27a"), 176, 7.0)
	Crayon.marker_line(c, crown, red.darkened(0.5), 11.0, 177)
	_mark(c, Crayon.ellipse(Vector2(228, 244), Vector2(22, 14), 16), red.darkened(0.1), 178, 7.0)


# --- Glasses ---------------------------------------------------------------------------------

## Marker: coral-framed sunglasses with dark teal lenses (never black) and a glint.
static func _sun_glasses(c: CanvasItem) -> void:
	var frame := Color("#f37b6c")
	var tint := Color("#2b5f68")
	var shape := _join([[Vector2(-96, -58), Vector2(92, -58)],
		_cubic(Vector2(92, -58), Vector2(98, 10), Vector2(74, 72), Vector2(8, 74)),
		_cubic(Vector2(8, 74), Vector2(-62, 76), Vector2(-94, 30), Vector2(-96, -58))])
	for side in 2:
		var at := Vector2(146 + side * 220, 248)
		var lens := _shift(shape if side == 1 else _mirror(shape, 0.0), at)
		c.draw_colored_polygon(lens, tint)
		Crayon.marker_fill(c, lens, tint.lightened(0.12), 211 + side)
		Crayon.line(c, at + Vector2(-50, 40), at + Vector2(6, -30), Color(0.85, 0.97, 1.0, 0.5), 15.0, 213 + side)
		Crayon.line(c, at + Vector2(-8, 46), at + Vector2(26, 4), Color(0.85, 0.97, 1.0, 0.4), 8.0, 215 + side)
		_frame(c, lens, frame, 18.0, 217 + side)
	_frame(c, _cubic(Vector2(236, 214), Vector2(246, 192), Vector2(266, 192), Vector2(276, 214), 8),
		frame, 18.0, 219, false)
	_frame(c, PackedVector2Array([Vector2(52, 200), Vector2(22, 186)]), frame, 16.0, 220, false)
	_frame(c, PackedVector2Array([Vector2(460, 200), Vector2(490, 186)]), frame, 16.0, 221, false)


## Pencil: heart-shaped pink glasses.
static func _heart_glasses(c: CanvasItem) -> void:
	var frame := Color("#f2679f")
	for side in 2:
		var lens := _heart(Vector2(144 + side * 224, 240), 212.0)
		_under(c, lens)
		Crayon.pencil_fill(c, lens, Color("#ffc6dd"), 231 + side)
		var hl := Vector2(98 + side * 224, 210)
		Crayon.line(c, hl, hl + Vector2(26, -26), SHINE, 12.0, 233 + side)
		_frame(c, lens, frame, 16.0, 235 + side)
	_frame(c, _cubic(Vector2(238, 210), Vector2(246, 190), Vector2(266, 190), Vector2(274, 210), 8),
		frame, 16.0, 237, false)


## Pencil: big round nerdy glasses - chunky brown frames, pale lenses with a shine.
static func _round_glasses(c: CanvasItem) -> void:
	var frame := Color("#c98d5c")
	for side in 2:
		var at := Vector2(148 + side * 216, 256)
		var lens := Crayon.ellipse(at, Vector2(98, 98), 48)
		_under(c, lens)
		Crayon.pencil_fill(c, lens, Color("#e1effc"), 241 + side)
		Crayon.marker_line(c, _arc(at, Vector2(66, 66), PI * 1.08, PI * 1.45, 10), SHINE, 13.0, 243 + side, false)
		_frame(c, lens, frame, 22.0, 245 + side)
	_frame(c, _cubic(Vector2(244, 240), Vector2(250, 222), Vector2(262, 222), Vector2(268, 240), 6),
		frame, 18.0, 247, false)
	_frame(c, PackedVector2Array([Vector2(52, 236), Vector2(22, 224)]), frame, 16.0, 248, false)
	_frame(c, PackedVector2Array([Vector2(460, 236), Vector2(490, 224)]), frame, 16.0, 249, false)


## Pencil: a monocle - gold rim, pale lens, a chain drooping back, and a glint opposite so the
## lens stays in the middle of the drawing (the pivot is the centre of the ink).
static func _monocle(c: CanvasItem) -> void:
	var gold := Color("#f5d36a")
	var at := Vector2(256, 250)
	var lens := Crayon.ellipse(at, Vector2(116, 116), 48)
	var chain := _cubic(at + Vector2.from_angle(PI * 0.75) * 120.0, Vector2(150, 430),
		Vector2(110, 450), Vector2(80, 420), 30)
	var fine := _resample(chain, 21.0)
	for i in fine.size() - 1:
		var p: Vector2 = fine[i]
		var d := (fine[i + 1] - p).angle()
		var link := _turn(Crayon.ellipse(p, Vector2(13, 8), 12), p, d + (0.0 if i % 2 == 0 else 0.0))
		Crayon.pencil_line(c, link, gold.darkened(0.45), 6.0, 251 + i)
	_pen(c, Crayon.ellipse(Vector2(78, 424), Vector2(16, 16), 16), gold, 280, 7.0)
	_under(c, lens)
	Crayon.pencil_fill(c, lens, Color("#e1effc"), 281)
	Crayon.marker_line(c, _arc(at, Vector2(76, 76), PI * 1.08, PI * 1.45, 10), SHINE, 14.0, 282, false)
	_frame(c, lens, gold, 24.0, 283)
	_pen(c, _sparkle(Vector2(404, 106), 46.0), Color("#ffe58a"), 284, 7.0)


# --- Neck and back ---------------------------------------------------------------------------

## Marker: a blue bow tie with cream polka dots.
static func _bowtie(c: CanvasItem) -> void:
	var blue := Color("#64a6ec")
	var wing := _join([
		_cubic(Vector2(226, 222), Vector2(180, 186), Vector2(118, 134), Vector2(74, 136)),
		_cubic(Vector2(74, 136), Vector2(36, 180), Vector2(36, 332), Vector2(74, 376)),
		_cubic(Vector2(74, 376), Vector2(118, 378), Vector2(180, 326), Vector2(226, 290))])
	for side in 2:
		var w := wing if side == 0 else _mirror(wing, 256.0)
		_under(c, w)
		Crayon.marker_fill(c, w, blue, 301 + side)
		_dots(c, w, Color("#fff4dc"), 303 + side * 50, 15.0, 62.0)
		var sx := 1.0 if side == 0 else -1.0
		Crayon.marker_line(c, _cubic(Vector2(256 - sx * 50, 240), Vector2(256 - sx * 90, 226),
			Vector2(256 - sx * 120, 210), Vector2(256 - sx * 150, 196), 8), blue.darkened(0.35), 6.0, 305 + side, false)
		Crayon.marker_line(c, _cubic(Vector2(256 - sx * 50, 272), Vector2(256 - sx * 90, 286),
			Vector2(256 - sx * 120, 302), Vector2(256 - sx * 150, 316), 8), blue.darkened(0.35), 6.0, 307 + side, false)
		Crayon.marker_line(c, w, blue.darkened(0.5), 11.0, 309 + side)
	_mark(c, Crayon.rounded_rect(Rect2(210, 204, 92, 104), 26), blue.darkened(0.08), 311)
	Crayon.line(c, Vector2(228, 226), Vector2(230, 260), SHINE, 9.0, 312)


## Pencil: a striped knitted scarf - the wrap round the neck, one end hanging down the back.
static func _scarf(c: CanvasItem) -> void:
	var green := Color("#62c08e")
	var cream := Color("#fff1d4")
	var tail_path := _cubic(Vector2(162, 150), Vector2(154, 260), Vector2(134, 350), Vector2(110, 430), 24)
	var tail := _band(tail_path, 104.0, 96.0)
	_under(c, tail)
	Crayon.pencil_fill(c, tail, green, 321)
	_stripe_along(c, tail_path, 104.0, 96.0, cream, 46.0, 322)
	var end: Vector2 = tail_path[tail_path.size() - 1]
	var d := (end - tail_path[tail_path.size() - 3]).normalized()
	for k in 6:
		var p := end + d.orthogonal() * (k - 2.5) * 17.0
		Crayon.line(c, p, p + d * 38.0, green.darkened(0.3), 8.0, 330 + k, 2.0)
	Crayon.pencil_line(c, tail, green.darkened(0.45), 10.0, 337)
	var wrap_path := _cubic(Vector2(100, 116), Vector2(170, 156), Vector2(342, 156), Vector2(412, 116), 24)
	var wrap := _union([_band(wrap_path, 116.0), Crayon.ellipse(wrap_path[0], Vector2(58, 58), 24),
		Crayon.ellipse(wrap_path[wrap_path.size() - 1], Vector2(58, 58), 24)])
	_under(c, wrap)
	Crayon.pencil_fill(c, wrap, green, 338)
	_stripe_along(c, wrap_path, 116.0, 116.0, cream, 46.0, 339)
	Crayon.pencil_line(c, wrap, green.darkened(0.45), 10.0, 345)


## Marker: a red triangle bandana with cream dots, its rolled band tied round the neck.
static func _bandana(c: CanvasItem) -> void:
	var red := Color("#ec6862")
	var tri := _join([[Vector2(70, 120), Vector2(442, 120)],
		_cubic(Vector2(442, 120), Vector2(410, 250), Vector2(334, 380), Vector2(278, 452)),
		_cubic(Vector2(278, 452), Vector2(222, 400), Vector2(120, 260), Vector2(70, 120))])
	_under(c, tri)
	Crayon.marker_fill(c, tri, red, 351)
	_dots(c, tri, Color("#fff1dc"), 352, 15.0, 64.0)
	Crayon.marker_line(c, _cubic(Vector2(150, 170), Vector2(200, 250), Vector2(240, 320),
		Vector2(266, 380), 10), red.darkened(0.3), 6.0, 353, false)
	Crayon.marker_line(c, tri, red.darkened(0.5), 11.0, 354)
	var roll_path := _cubic(Vector2(66, 112), Vector2(160, 140), Vector2(352, 140), Vector2(446, 112), 20)
	var roll := _union([_band(roll_path, 56.0), Crayon.ellipse(roll_path[0], Vector2(28, 28), 16),
		Crayon.ellipse(roll_path[roll_path.size() - 1], Vector2(28, 28), 16)])
	_under(c, roll)
	Crayon.marker_fill(c, roll, red.lightened(0.06), 355, 18.0)
	Crayon.marker_line(c, roll_path, red.darkened(0.3), 5.0, 356, false)
	Crayon.marker_line(c, roll, red.darkened(0.5), 11.0, 357)


## Pencil: a pale gold medal on a blue ribbon loop (gold at runtime).
static func _medal(c: CanvasItem) -> void:
	var blue := Color("#94c6f2")
	var gold := Color("#ffe27a")
	var straps := [PackedVector2Array([Vector2(116, 40), Vector2(184, 40), Vector2(284, 284), Vector2(226, 296)]),
		PackedVector2Array([Vector2(328, 40), Vector2(396, 40), Vector2(286, 296), Vector2(228, 284)])]
	for i in 2:
		var s: PackedVector2Array = straps[i]
		_under(c, s)
		Crayon.pencil_fill(c, s, blue, 361 + i)
		var mid := PackedVector2Array([s[0].lerp(s[1], 0.36), s[0].lerp(s[1], 0.64),
			s[3].lerp(s[2], 0.64), s[3].lerp(s[2], 0.36)])
		Crayon.pencil_fill(c, mid, Color("#fff6e0"), 363 + i)
		Crayon.pencil_line(c, s, blue.darkened(0.45), 9.0, 365 + i)
	_frame(c, Crayon.ellipse(Vector2(256, 290), Vector2(24, 20), 20), gold, 12.0, 367)
	_pen(c, Crayon.ellipse(Vector2(256, 370), Vector2(102, 102), 48), gold, 368, 10.0)
	_pen(c, Crayon.ellipse(Vector2(256, 370), Vector2(70, 70), 40), Color("#fff2bd"), 369, 7.0)
	_pen(c, Crayon.star(Vector2(256, 376), 46.0, 370), Color("#ffd75a"), 371, 7.0)
	Crayon.pencil_line(c, _arc(Vector2(256, 370), Vector2(86, 86), PI * 1.1, PI * 1.4, 8), SHINE, 10.0, 372, false)


## Marker: a red superhero cape billowing back to the left, a yellow star on it.
static func _cape(c: CanvasItem) -> void:
	var red := Color("#ee6464")
	var body := PackedVector2Array([Vector2(212, 62), Vector2(300, 62)])
	body.append_array(_cubic(Vector2(300, 62), Vector2(344, 170), Vector2(424, 300), Vector2(468, 416)))
	for i in range(1, 37):
		var t := i / 36.0
		body.append(Vector2(lerpf(468, 44, t), lerpf(416, 346, t) + sin(t * 3.0 * TAU) * 16.0))
	body.append_array(_cubic(Vector2(44, 346), Vector2(56, 250), Vector2(124, 150), Vector2(212, 62)))
	body = _join([body])
	_under(c, body)
	Crayon.marker_fill(c, body, red, 381)
	for i in 3:
		var foot := Vector2(lerpf(110, 400, i / 2.0), lerpf(360, 400, i / 2.0))
		Crayon.marker_line(c, _cubic(Vector2(236 + i * 20, 96), Vector2(236 + i * 20, 160),
			foot.lerp(Vector2(256, 96), 0.4), foot, 10), red.darkened(0.3), 6.0, 382 + i, false)
	_mark(c, Crayon.star(Vector2(254, 262), 78.0, 385), Color("#ffe27a"), 386, 9.0)
	Crayon.marker_line(c, body, red.darkened(0.5), 11.0, 387)
	_mark(c, Crayon.rounded_rect(Rect2(192, 40, 128, 44), 20), red.darkened(0.1), 388, 9.0)
	_mark(c, Crayon.ellipse(Vector2(256, 62), Vector2(19, 19), 16), Color("#ffe27a"), 389, 7.0)


## Marker: a small orange backpack - top loop, flap with two strap buckles, a yellow pocket.
static func _backpack(c: CanvasItem) -> void:
	var orange := Color("#f7a45e")
	var teal := Color("#5cc0b2")
	_frame(c, _arc(Vector2(256, 112), Vector2(46, 44), PI, TAU, 12), teal, 14.0, 391, false)
	var body := Crayon.rounded_rect(Rect2(124, 104, 264, 344), 76)
	_mark(c, body, orange, 392)
	var cut := _join([[Vector2(100, 80), Vector2(412, 80), Vector2(412, 214)],
		_cubic(Vector2(412, 214), Vector2(340, 262), Vector2(172, 262), Vector2(100, 214))])
	for piece in Geometry2D.intersect_polygons(body, cut):
		Crayon.marker_fill(c, piece, orange.darkened(0.08), 393)
		Crayon.marker_line(c, piece, orange.darkened(0.5), 10.0, 394)
	for i in 2:
		var x := 196.0 + i * 120.0
		_mark(c, Crayon.rounded_rect(Rect2(x - 13, 196, 26, 98), 8), teal, 395 + i, 8.0)
		_mark(c, Crayon.rounded_rect(Rect2(x - 20, 262, 40, 30), 6), Color("#ffe08a"), 397 + i, 7.0)
	var pocket := Crayon.rounded_rect(Rect2(162, 318, 188, 112), 30)
	_mark(c, pocket, Color("#ffd36b"), 399)
	Crayon.marker_line(c, PackedVector2Array([Vector2(178, 350), Vector2(334, 350)]),
		Color("#ffd36b").darkened(0.45), 7.0, 400, false)
	Crayon.line(c, Vector2(150, 190), Vector2(148, 300), SHINE, 13.0, 401)


## Pencil: costume fairy wings - four pastel lobes you can see through, veins and sparkles.
static func _wings(c: CanvasItem) -> void:
	var lav := Color("#c4b2f4")
	var pink := Color("#f7bcd8")
	var line := Color("#9583d4")
	var upper := _join([
		_cubic(Vector2(262, 250), Vector2(292, 96), Vector2(440, 30), Vector2(474, 128)),
		_cubic(Vector2(474, 128), Vector2(496, 210), Vector2(380, 268), Vector2(262, 262))])
	var lower := _join([
		_cubic(Vector2(262, 266), Vector2(380, 276), Vector2(460, 330), Vector2(436, 402)),
		_cubic(Vector2(436, 402), Vector2(408, 470), Vector2(300, 430), Vector2(262, 272))])
	for side in 2:
		var u := upper if side == 0 else _mirror(upper, 256.0)
		var l := lower if side == 0 else _mirror(lower, 256.0)
		var sx := 1.0 if side == 0 else -1.0
		for k in 2:
			var w := l if k == 0 else u
			var col := pink if k == 0 else lav
			c.draw_colored_polygon(w, Color(1, 1, 1, 0.3))
			Crayon.pencil_fill(c, w, col, 411 + side * 4 + k)
			var veins := [Vector2(150, 330), Vector2(180, 380)] if k == 0 else [Vector2(180, 120), Vector2(200, 200)]
			for j in 2:
				var tip: Vector2 = veins[j]
				var p := Vector2(256.0 + sx * tip.x, tip.y)
				Crayon.pencil_line(c, _cubic(Vector2(256 + sx * 10, 262), Vector2(256 + sx * tip.x * 0.4, 262),
					Vector2(256 + sx * tip.x * 0.7, lerpf(262, tip.y, 0.6)), p, 10), line.lightened(0.25), 4.0,
					421 + side * 8 + k * 2 + j, false)
			Crayon.pencil_line(c, w, line, 9.0, 441 + side * 4 + k)
		for j in 2:
			var glint := _sparkle(Vector2(256 + sx * (130 - j * 18), 150 + j * 210), 22.0 - j * 6.0)
			c.draw_colored_polygon(glint, PAPER)
			Crayon.pencil_line(c, glint, line, 4.0, 451 + side * 2 + j)
	_pen(c, Crayon.rounded_rect(Rect2(238, 212, 36, 96), 18), lav.darkened(0.08), 455, 8.0)


# --- Icons -----------------------------------------------------------------------------------

## Pencil: a five-pointed star sticker with a highlight - shiny gold at runtime.
static func _star(c: CanvasItem) -> void:
	var star := Crayon.star(Vector2(256, 276), 214.0, 51)
	_pen(c, star, Color("#ffd75e"), 52, 10.0)
	Crayon.pencil_fill(c, Crayon.star(Vector2(234, 248), 78.0, 53), Color("#fff3b8"), 54)


## Marker: a red-pink heart (full), or the same heart left pale inside (empty). Both share the
## same outline so they line up side by side in a row of hearts.
static func _heart_icon(c: CanvasItem, full: bool) -> void:
	var pink := Color("#f3627f")
	var heart := _heart(Vector2(256, 222), 416.0)
	_under(c, heart)
	if full:
		Crayon.marker_fill(c, heart, pink, 221)
		Crayon.marker_line(c, _arc(Vector2(170, 168), Vector2(62, 56), PI * 1.02, PI * 1.48, 10),
			SHINE, 18.0, 222, false)
	else:
		Crayon.pencil_fill(c, heart, Color("#fde4eb"), 221)
	_frame(c, heart, pink, 16.0, 223)


## Marker: a yellow lightning bolt.
static func _bolt(c: CanvasItem) -> void:
	var yellow := Color("#ffd23f")
	var bolt := PackedVector2Array([Vector2(282, 36), Vector2(398, 36), Vector2(318, 196),
		Vector2(410, 196), Vector2(160, 478), Vector2(222, 286), Vector2(122, 286)])
	_mark(c, bolt, yellow, 231, 12.0)
	Crayon.line(c, Vector2(292, 64), Vector2(196, 254), SHINE, 13.0, 232)


## Marker: a dumbbell - lavender bar, two red plates on each end.
static func _dumbbell(c: CanvasItem) -> void:
	var red := Color("#ef5e5e")
	_mark(c, _capsule(Vector2(80, 256), Vector2(432, 256), 46), Color("#bdb8dc"), 241, 10.0)
	for side in 2:
		var sx := 1.0 if side == 0 else -1.0
		var inner := Crayon.rounded_rect(Rect2(256 + sx * 116 - 34, 132, 68, 248), 20)
		var outer := Crayon.rounded_rect(Rect2(256 + sx * 172 - 26, 170, 52, 172), 16)
		_mark(c, outer, red.darkened(0.06), 242 + side, 11.0)
		_mark(c, inner, red, 244 + side, 11.0)
		Crayon.line(c, Vector2(256 + sx * 116 - 14, 160), Vector2(256 + sx * 116 - 14, 250), SHINE, 11.0, 246 + side)


## Marker: a green coil spring seen a little from above - back of each coil paler.
static func _spring(c: CanvasItem) -> void:
	var green := Color("#62c86e")
	var back := green.lightened(0.38)
	var runs := [[], []]
	var cur := PackedVector2Array()
	var cur_front := true
	var n := 200
	for i in n + 1:
		var t := 4.0 * TAU * i / n
		var p := Vector2(256 + 150 * sin(t), 92 + 78 * t / TAU + 36 * cos(t))
		var front := cos(t) >= 0.0
		if i > 0 and front != cur_front:
			cur.append(p)
			runs[0 if cur_front else 1].append(cur)
			cur = PackedVector2Array()
		cur.append(p)
		cur_front = front
	runs[0 if cur_front else 1].append(cur)
	for layer in [1, 0]:
		var col := green if layer == 0 else back
		var list: Array = runs[layer]
		for i in list.size():
			var run: PackedVector2Array = list[i]
			Crayon.marker_line(c, run, col.darkened(0.5), 38.0, 251 + i, false)
			Crayon.marker_line(c, run, col, 23.0, 251 + i, false)


## Pencil: a full battery - pale case, four blue charge bars.
static func _battery(c: CanvasItem) -> void:
	var blue := Color("#5b9cf0")
	_pen(c, Crayon.rounded_rect(Rect2(420, 204, 48, 104), 14), blue.lightened(0.2), 261, 10.0)
	_pen(c, Crayon.rounded_rect(Rect2(46, 136, 384, 240), 42), Color("#e2eeff"), 262, 0.0)
	for i in 4:
		var bar := Crayon.rounded_rect(Rect2(84 + i * 84, 172, 68, 168), 14)
		_under(c, bar)
		Crayon.marker_fill(c, bar, blue, 263 + i, 18.0)
		Crayon.line(c, Vector2(100 + i * 84, 194), Vector2(100 + i * 84, 300), SHINE, 9.0, 267 + i)
	Crayon.pencil_line(c, Crayon.rounded_rect(Rect2(46, 136, 384, 240), 42), blue.darkened(0.45), 12.0, 271)


## Marker: a glowing light bulb - yellow glass, orange filament, lavender screw base, rays.
static func _bulb(c: CanvasItem) -> void:
	var yellow := Color("#ffe066")
	var at := Vector2(256, 214)
	for i in 7:
		var a := PI + PI * (i + 0.5) / 7.0
		var d := Vector2.from_angle(a)
		Crayon.marker_line(c, PackedVector2Array([at + d * 152.0, at + d * 192.0]),
			Color("#ffb84d"), 15.0, 281 + i, false)
	var glass := _union([Crayon.ellipse(at, Vector2(126, 126), 48),
		PackedVector2Array([Vector2(184, 300), Vector2(328, 300), Vector2(302, 374), Vector2(210, 374)])])
	_mark(c, glass, yellow, 288, 11.0)
	var filament := PackedVector2Array([Vector2(230, 344), Vector2(236, 262)])
	filament.append_array(_loops(Vector2(236, 262), Vector2(276, 262), 3.0, 9.0, 36))
	filament.append(Vector2(282, 344))
	Crayon.marker_line(c, filament, Color("#f59a3c"), 8.0, 289, false)
	Crayon.marker_line(c, _arc(at, Vector2(88, 88), PI * 1.06, PI * 1.42, 10), SHINE, 16.0, 290, false)
	var base := Crayon.rounded_rect(Rect2(202, 364, 108, 84), 16)
	_pen(c, base, Color("#bbb6da"), 291, 10.0)
	for i in 2:
		var y := 392.0 + i * 26.0
		Crayon.line(c, Vector2(210, y), Vector2(302, y - 6), Color("#bbb6da").darkened(0.4), 6.0, 292 + i)
	_pen(c, Crayon.rounded_rect(Rect2(230, 444, 52, 28), 12), Color("#bbb6da").darkened(0.1), 294, 9.0)


## Marker: a pink bow - two loops, two notched tails, a knot - and one yellow sparkle.
static func _charm_bow(c: CanvasItem) -> void:
	var pink := Color("#f48fbf")
	var tail := PackedVector2Array([Vector2(238, 246), Vector2(266, 262), Vector2(206, 450),
		Vector2(174, 420), Vector2(130, 440)])
	var loop := _join([
		_cubic(Vector2(236, 212), Vector2(170, 100), Vector2(70, 90), Vector2(62, 190)),
		_cubic(Vector2(62, 190), Vector2(56, 286), Vector2(170, 286), Vector2(236, 244))])
	for side in 2:
		_mark(c, tail if side == 0 else _mirror(tail, 256.0), pink.darkened(0.06), 301 + side)
	for side in 2:
		var l := loop if side == 0 else _mirror(loop, 256.0)
		_mark(c, l, pink, 303 + side)
		var sx := 1.0 if side == 0 else -1.0
		var fold := _join([
			_cubic(Vector2(256 - sx * 26, 214), Vector2(256 - sx * 70, 170), Vector2(256 - sx * 120, 170),
				Vector2(256 - sx * 128, 214)),
			_cubic(Vector2(256 - sx * 128, 214), Vector2(256 - sx * 120, 240), Vector2(256 - sx * 70, 246),
				Vector2(256 - sx * 26, 238))])
		Crayon.marker_fill(c, fold, pink.darkened(0.14), 305 + side, 14.0)
	_mark(c, Crayon.rounded_rect(Rect2(220, 194, 72, 74), 22), pink.darkened(0.04), 307)
	Crayon.line(c, Vector2(96, 150), Vector2(128, 122), SHINE, 13.0, 308)
	_mark(c, _sparkle(Vector2(420, 92), 56.0), Color("#ffe27a"), 309, 9.0)


## Pencil and marker: a blue bowl heaped with kibble.
static func _food_bowl(c: CanvasItem) -> void:
	var blue := Color("#64a6ec")
	var kibble := [Color("#dd9a5c"), Color("#eab47a"), Color("#d38a4c")]
	var rows := [[Vector2(234, 168), Vector2(282, 172)],
		[Vector2(180, 210), Vector2(232, 204), Vector2(284, 208), Vector2(334, 214)],
		[Vector2(132, 254), Vector2(184, 246), Vector2(236, 248), Vector2(288, 244), Vector2(340, 250),
			Vector2(388, 258)],
		[Vector2(104, 290), Vector2(156, 286), Vector2(210, 284), Vector2(262, 286), Vector2(314, 282),
			Vector2(366, 288), Vector2(414, 292)]]
	var k := 0
	for row in rows:
		for p in row:
			var at: Vector2 = p
			_pen(c, Crayon.blob(at, Vector2(30, 27), 311 + k, 12, 0.14), kibble[k % 3], 340 + k, 7.0)
			k += 1
	var bowl := _join([[Vector2(70, 300), Vector2(442, 300)],
		_cubic(Vector2(442, 300), Vector2(434, 380), Vector2(412, 440), Vector2(372, 452)),
		_cubic(Vector2(140, 452), Vector2(100, 440), Vector2(78, 380), Vector2(70, 300))])
	_under(c, bowl)
	Crayon.marker_fill(c, bowl, blue, 371)
	var band := PackedVector2Array([Vector2(40, 352), Vector2(472, 352), Vector2(472, 388),
		Vector2(40, 388)])
	for piece in Geometry2D.intersect_polygons(band, bowl):
		_under(c, piece)
		Crayon.marker_fill(c, piece, Color("#fff4dc"), 372, 16.0)
	Crayon.marker_line(c, bowl, blue.darkened(0.5), 11.0, 373)
	_mark(c, Crayon.rounded_rect(Rect2(52, 284, 408, 38), 19), blue.lightened(0.14), 374, 10.0)


## Marker: a bouncing blue ball with a star, a loopy purple squiggle trailing behind it.
static func _fun_ball(c: CanvasItem) -> void:
	var purple := Color("#a08cf2")
	var trail := _loops(Vector2(70, 214), Vector2(190, 208), 2.0, 42.0)
	_frame(c, trail, purple, 17.0, 381, false)
	_frame(c, PackedVector2Array([Vector2(98, 136), Vector2(190, 150)]), purple, 13.0, 386, false)
	_frame(c, PackedVector2Array([Vector2(98, 376), Vector2(190, 362)]), purple, 13.0, 387, false)
	var at := Vector2(354, 256)
	var ball := Crayon.ellipse(at, Vector2(130, 130), 48)
	_mark(c, ball, Color("#66b6f2"), 382, 12.0)
	_mark(c, Crayon.star(at + Vector2(2, 8), 66.0, 383), Color("#ffe27a"), 384, 8.0)
	Crayon.marker_line(c, _arc(at, Vector2(100, 100), PI * 1.06, PI * 1.4, 10), SHINE, 15.0, 385, false)


## Pencil and marker: a pink bar of soap with see-through bubbles.
static func _soap(c: CanvasItem) -> void:
	var pink := Color("#f6a2c0")
	var bar := Crayon.rounded_rect(Rect2(44, 250, 336, 190), 54)
	_mark(c, bar, pink, 391, 12.0)
	var top := Crayon.rounded_rect(Rect2(64, 264, 296, 66), 30)
	Crayon.marker_fill(c, top, pink.lightened(0.35), 392, 18.0)
	_pen(c, Crayon.rounded_rect(Rect2(134, 350, 156, 50), 24), pink.lightened(0.2), 393, 6.0)
	var bubbles := [[Vector2(330, 214), 76.0], [Vector2(428, 300), 44.0], [Vector2(196, 196), 50.0],
		[Vector2(300, 86), 40.0], [Vector2(436, 150), 30.0]]
	for i in bubbles.size():
		var at: Vector2 = bubbles[i][0]
		var r: float = bubbles[i][1]
		var b := Crayon.ellipse(at, Vector2(r, r), 32)
		c.draw_colored_polygon(b, Color(0.93, 0.97, 1.0, 0.75))
		Crayon.pencil_fill(c, b, Color("#d4ebff"), 394 + i)
		Crayon.pencil_line(c, b, Color("#7fb2e6"), 9.0, 400 + i)
		Crayon.marker_line(c, _arc(at, Vector2(r, r) * 0.62, PI * 1.08, PI * 1.45, 8), Color(1, 1, 1, 0.9),
			maxf(6.0, r * 0.16), 406 + i, false)


## Pencil: a pale yellow crescent moon and a lavender "z".
static func _moon(c: CanvasItem) -> void:
	var yellow := Color("#ffe58a")
	var moon := _crescent(Vector2(226, 268), 196.0, Vector2(104, -72), 170.0)
	_pen(c, moon, yellow, 411, 10.0)
	Crayon.line(c, Vector2(80, 300), Vector2(110, 380), SHINE, 13.0, 412)
	var z := Color("#8a90e6")
	var zp := PackedVector2Array([Vector2(338, 104), Vector2(452, 104), Vector2(338, 222), Vector2(452, 222)])
	Crayon.marker_line(c, zp, z.darkened(0.3), 34.0, 413, false)
	Crayon.marker_line(c, zp, z, 22.0, 413, false)


## Marker: a little shop stall - striped awning with a scalloped edge, posts, a counter.
static func _shop(c: CanvasItem) -> void:
	var red := Color("#ef6b6b")
	var wood := Color("#e6ae74")
	_pen(c, PackedVector2Array([Vector2(104, 180), Vector2(408, 180), Vector2(408, 340), Vector2(104, 340)]),
		Color("#fff0c4"), 421, 0.0)
	for i in 2:
		_mark(c, Crayon.rounded_rect(Rect2(84 + i * 322, 160, 22, 220), 8), wood, 422 + i, 9.0)
	_mark(c, Crayon.ellipse(Vector2(200, 302), Vector2(36, 34), 20), Color("#ef6262"), 424, 8.0)
	_mark(c, Crayon.ellipse(Vector2(306, 300), Vector2(40, 38), 20), Color("#6aaeee"), 425, 8.0)
	var counter := Crayon.rounded_rect(Rect2(64, 332, 384, 124), 16)
	_mark(c, counter, wood, 426, 11.0)
	Crayon.marker_line(c, PackedVector2Array([Vector2(80, 372), Vector2(432, 372)]), wood.darkened(0.4), 7.0, 427, false)
	var awning := PackedVector2Array([Vector2(84, 60), Vector2(428, 60), Vector2(474, 176)])
	for k in range(5, -1, -1):
		awning.append_array(_arc(Vector2(38 + 72 * k + 36, 176), Vector2(36, 36), 0.0, PI, 10))
	awning = _join([awning])
	_under(c, awning)
	Crayon.marker_fill(c, awning, Color("#fff4e0"), 428)
	for k in range(0, 6, 2):
		var stripe := PackedVector2Array([Vector2(84 + 344 * k / 6.0, 50), Vector2(84 + 344 * (k + 1) / 6.0, 50),
			Vector2(38 + 72 * (k + 1), 220), Vector2(38 + 72 * k, 220)])
		for piece in Geometry2D.intersect_polygons(stripe, awning):
			Crayon.marker_fill(c, piece, red, 429 + k, 18.0)
	Crayon.marker_line(c, awning, red.darkened(0.5), 11.0, 436)


## Pencil: a calendar page - coral header, two binder rings, pale days, a star on one.
static func _calendar(c: CanvasItem) -> void:
	var coral := Color("#f07a7a")
	var page := Crayon.rounded_rect(Rect2(72, 92, 368, 372), 36)
	_under(c, page)
	Crayon.pencil_fill(c, page, Color("#fffaf0"), 441)
	for piece in Geometry2D.intersect_polygons(page, PackedVector2Array([Vector2(40, 60),
			Vector2(472, 60), Vector2(472, 192), Vector2(40, 192)])):
		Crayon.marker_fill(c, piece, coral, 442)
	for row in 3:
		for col in 4:
			if row == 1 and col == 2:
				continue
			var cell := Crayon.rounded_rect(Rect2(110 + col * 76, 220 + row * 76, 54, 52), 10)
			Crayon.pencil_fill(c, cell, Color("#cfc9ee"), 443 + row * 4 + col)
	Crayon.pencil_line(c, page, coral.darkened(0.45), 12.0, 460)
	Crayon.marker_line(c, PackedVector2Array([Vector2(80, 192), Vector2(432, 192)]), coral.darkened(0.45), 9.0, 461, false)
	for i in 2:
		var x := 172.0 + i * 168.0
		_mark(c, Crayon.ellipse(Vector2(x, 140), Vector2(17, 15), 16), coral.darkened(0.3), 462 + i, 6.0)
		_frame(c, _cubic(Vector2(x, 140), Vector2(x - 2, 90), Vector2(x - 2, 48), Vector2(x, 40), 8),
			Color("#b7b2dc"), 18.0, 464 + i, false)
	_mark(c, Crayon.star(Vector2(298, 324), 54.0, 466), Color("#ffd75e"), 467, 9.0)


## Marker and pencil: a little house - red roof, chimney, blue door, a window.
static func _house(c: CanvasItem) -> void:
	_mark(c, Crayon.rounded_rect(Rect2(332, 92, 52, 120), 6), Color("#e98a6a"), 471, 10.0)
	_pen(c, PackedVector2Array([Vector2(110, 230), Vector2(402, 230), Vector2(402, 454), Vector2(110, 454)]),
		Color("#ffe0a6"), 472, 11.0)
	_mark(c, PackedVector2Array([Vector2(56, 262), Vector2(256, 62), Vector2(456, 262)]), Color("#ef6a5c"), 473, 12.0)
	var door := _join([[Vector2(284, 454), Vector2(284, 352)],
		_arc(Vector2(322, 352), Vector2(38, 38), PI, TAU, 10), [Vector2(360, 454)]])
	_mark(c, door, Color("#6fa2ea"), 474, 10.0)
	_mark(c, Crayon.ellipse(Vector2(344, 404), Vector2(8, 8), 10), Color("#ffe27a"), 475, 5.0)
	var window := Crayon.rounded_rect(Rect2(144, 300, 84, 80), 8)
	_pen(c, window, Color("#cfe8ff"), 476, 9.0)
	Crayon.line(c, Vector2(186, 304), Vector2(186, 376), Color("#cfe8ff").darkened(0.45), 7.0, 477)
	Crayon.line(c, Vector2(148, 340), Vector2(224, 340), Color("#cfe8ff").darkened(0.45), 7.0, 478)


## Marker: a pale gold trophy cup with two loop handles (gold at runtime).
static func _trophy(c: CanvasItem) -> void:
	var gold := Color("#ffe27e")
	for side in 2:
		var sx := 1.0 if side == 0 else -1.0
		var handle := _cubic(Vector2(256 - sx * 120, 116), Vector2(256 - sx * 220, 100),
			Vector2(256 - sx * 220, 260), Vector2(256 - sx * 96, 250), 16)
		_frame(c, handle, gold, 24.0, 481 + side, false)
	var cup := _join([[Vector2(120, 78), Vector2(392, 78)],
		_cubic(Vector2(392, 78), Vector2(392, 240), Vector2(330, 300), Vector2(282, 312)),
		[Vector2(278, 372), Vector2(234, 372)],
		_cubic(Vector2(230, 312), Vector2(182, 300), Vector2(120, 240), Vector2(120, 78))])
	_mark(c, cup, gold, 483, 12.0)
	Crayon.line(c, Vector2(156, 120), Vector2(176, 236), SHINE, 16.0, 484)
	_mark(c, Crayon.star(Vector2(262, 186), 56.0, 485), Color("#fff4c4"), 486, 8.0)
	_mark(c, Crayon.ellipse(Vector2(256, 78), Vector2(136, 20), 40), Color("#fff4c4"), 487, 10.0)
	_mark(c, Crayon.rounded_rect(Rect2(184, 364, 144, 42), 10), gold.darkened(0.06), 488, 10.0)
	_mark(c, Crayon.rounded_rect(Rect2(150, 400, 212, 62), 14), gold, 489, 11.0)


## Marker: a prize rosette - pleated ring, pale middle with a hand-drawn number, two tails.
static func _rosette(c: CanvasItem, n: int, col: Color, inner: Color, seed: int) -> void:
	var tail := PackedVector2Array([Vector2(212, 238), Vector2(272, 262), Vector2(228, 478),
		Vector2(192, 446), Vector2(148, 470)])
	for side in 2:
		_mark(c, tail if side == 0 else _mirror(tail, 256.0), col.darkened(0.08), seed + side)
	var at := Vector2(256, 196)
	var ring := _flower(at, 164.0, 16, seed + 2, 0.13)
	_under(c, ring)
	Crayon.marker_fill(c, ring, col, seed + 3)
	for i in 16:
		var d := Vector2.from_angle(TAU * (i + 0.5) / 16.0)
		Crayon.line(c, at + d * 104.0, at + d * 146.0, col.darkened(0.3), 5.0, seed + 4 + i, 1.0)
	Crayon.marker_line(c, ring, col.darkened(0.5), 11.0, seed + 20)
	_mark(c, Crayon.ellipse(at, Vector2(102, 102), 40), inner, seed + 21, 10.0)
	_digit(c, n, at + Vector2(0, 2), 128.0, col.darkened(0.5), 24.0, seed + 22)


## Marker and pencil: a closed padlock - lavender shackle, yellow body, keyhole.
static func _lock(c: CanvasItem) -> void:
	var shackle := _join([[Vector2(166, 250)], _arc(Vector2(256, 214), Vector2(90, 120), PI, TAU, 20),
		[Vector2(346, 250)]])
	_frame(c, shackle, Color("#c3bfe4"), 34.0, 491, false)
	var yellow := Color("#ffcf57")
	_mark(c, Crayon.rounded_rect(Rect2(108, 224, 296, 224), 42), yellow, 492, 12.0)
	var hole := _union([Crayon.ellipse(Vector2(256, 314), Vector2(28, 28), 20),
		PackedVector2Array([Vector2(244, 320), Vector2(268, 320), Vector2(278, 392), Vector2(234, 392)])])
	_pen(c, hole, yellow.darkened(0.42), 493, 6.0)
	Crayon.line(c, Vector2(144, 260), Vector2(142, 400), SHINE, 14.0, 494)


## Marker: a coat hanger with a teal T-shirt hanging on it.
static func _hanger(c: CanvasItem) -> void:
	var wood := Color("#d9a56a")
	var hook := _join([_arc(Vector2(256, 76), Vector2(28, 28), PI * 0.5, TAU + 0.5, 16)])
	var hook_path := PackedVector2Array([Vector2(256, 140)])
	hook_path.append_array(hook)
	_frame(c, hook_path, Color("#bbb6da"), 13.0, 501, false)
	_frame(c, PackedVector2Array([Vector2(256, 140), Vector2(70, 232), Vector2(442, 232)]), wood, 18.0, 502)
	var teal := Color("#4fc0b0")
	var shirt := _join([[Vector2(218, 196), Vector2(140, 214), Vector2(66, 282), Vector2(112, 334),
		Vector2(150, 306), Vector2(152, 466), Vector2(360, 466), Vector2(362, 306), Vector2(400, 334),
		Vector2(446, 282), Vector2(372, 214), Vector2(294, 196)],
		_cubic(Vector2(294, 196), Vector2(282, 240), Vector2(230, 240), Vector2(218, 196))])
	_under(c, shirt)
	Crayon.marker_fill(c, shirt, teal, 503)
	for piece in Geometry2D.intersect_polygons(shirt, PackedVector2Array([Vector2(40, 352),
			Vector2(472, 352), Vector2(472, 392), Vector2(40, 392)])):
		Crayon.marker_fill(c, piece, Color("#ffe27a"), 504, 16.0)
	Crayon.marker_line(c, shirt, teal.darkened(0.5), 11.0, 505)


## Marker: a wooden paint palette with five paint dabs and a brush.
static func _palette(c: CanvasItem) -> void:
	var wood := Color("#ecbd84")
	var pts := PackedVector2Array()
	for i in 48:
		var a := TAU * i / 48.0
		var dent := 1.0 - 0.3 * exp(-pow(wrapf(a - 0.65, -PI, PI), 2) / 0.05)
		pts.append(Vector2(236, 222) + Vector2(cos(a) * 204, sin(a) * 166) * dent)
	_mark(c, pts, wood, 511, 11.0)
	_mark(c, Crayon.ellipse(Vector2(300, 318), Vector2(30, 26), 20), Color("#fff8ec"), 512, 9.0)
	var dabs := [[Vector2(120, 190), Color("#f06464")], [Vector2(206, 120), Color("#ffd84a")],
		[Vector2(310, 124), Color("#6cc86a")], [Vector2(372, 206), Color("#5ea4ef")],
		[Vector2(134, 302), Color("#a585ee")]]
	for i in dabs.size():
		var at: Vector2 = dabs[i][0]
		_mark(c, Crayon.blob(at, Vector2(42, 38), 513 + i, 14, 0.14), dabs[i][1], 520 + i, 9.0)
	var tip := Vector2(258, 262)
	var dir := Vector2(1, 1.08).normalized()
	_mark(c, _capsule(tip + dir * 104.0, tip + dir * 270.0, 34), Color("#ef7f6a"), 526, 10.0)
	var bristles := _leaf(PackedVector2Array([tip, tip + dir * 82.0]), 50.0)
	_mark(c, bristles, Color("#5ea4ef"), 528, 9.0)
	var ferrule := _shift(_turn(Crayon.rounded_rect(Rect2(-30, -22, 60, 44), 6), Vector2.ZERO, dir.angle()),
		tip + dir * 92.0)
	_mark(c, ferrule, Color("#c7c3e3"), 529, 9.0)


## Marker: a blue toy box with a star, a red-and-white ball peeking over the top.
static func _toy_box(c: CanvasItem) -> void:
	var ball := Crayon.ellipse(Vector2(306, 168), Vector2(108, 108), 48)
	_under(c, ball)
	Crayon.marker_fill(c, ball, Color("#f4f1ea"), 531)
	for piece in Geometry2D.intersect_polygons(PackedVector2Array([Vector2(180, 130), Vector2(440, 100),
			Vector2(440, 160), Vector2(180, 190)]), ball):
		Crayon.marker_fill(c, piece, Color("#e95a5e"), 532)
	Crayon.marker_line(c, ball, Color("#a8484c"), 11.0, 533)
	var blue := Color("#76acea")
	_mark(c, Crayon.rounded_rect(Rect2(80, 236, 352, 222), 18), blue, 534, 12.0)
	_mark(c, Crayon.rounded_rect(Rect2(62, 214, 388, 50), 16), blue.lightened(0.15), 535, 11.0)
	_mark(c, Crayon.star(Vector2(256, 356), 66.0, 536), Color("#ffe27a"), 537, 9.0)


## Pencil: a wicker picnic basket with a handle, an apple peeking out.
static func _basket(c: CanvasItem) -> void:
	var wicker := Color("#e3b06c")
	_frame(c, _arc(Vector2(256, 246), Vector2(150, 170), PI, TAU, 24), wicker, 22.0, 541, false)
	_pen(c, Crayon.ellipse(Vector2(330, 214), Vector2(76, 70), 32), Color("#ef5d5d"), 542, 10.0)
	Crayon.line(c, Vector2(330, 152), Vector2(336, 116), Color("#b07a4a"), 10.0, 543)
	_pen(c, _leaf(PackedVector2Array([Vector2(338, 130), Vector2(396, 108)]), 30.0), Color("#7cc77a"), 544, 6.0)
	Crayon.line(c, Vector2(292, 186), Vector2(300, 170), SHINE, 10.0, 545)
	var body := _join([[Vector2(78, 252), Vector2(434, 252)],
		_cubic(Vector2(434, 252), Vector2(424, 340), Vector2(410, 420), Vector2(384, 458)),
		_cubic(Vector2(128, 458), Vector2(102, 420), Vector2(88, 340), Vector2(78, 252))])
	_under(c, body)
	Crayon.pencil_fill(c, body, wicker, 546)
	for row in 4:
		var y := 290.0 + row * 42.0
		Crayon.line(c, Vector2(60, y), Vector2(452, y), wicker.darkened(0.3), 6.0, 547 + row)
		for k in 8:
			var x := 110.0 + k * 42.0 + (row % 2) * 21.0
			Crayon.line(c, Vector2(x, y - 34), Vector2(x, y - 8), wicker.darkened(0.25), 5.0, 551 + row * 8 + k, 1.0)
	Crayon.pencil_line(c, body, wicker.darkened(0.45), 11.0, 590)
	_pen(c, Crayon.rounded_rect(Rect2(60, 230, 392, 44), 20), wicker.darkened(0.06), 591, 11.0)


## Marker: a purple crayon finishing a loopy squiggle.
static func _crayon_icon(c: CanvasItem) -> void:
	var purple := Color("#a282f0")
	var trail := _loops(Vector2(34, 412), Vector2(238, 346), 2.0, 44.0)
	_frame(c, trail, purple, 17.0, 601, false)
	var at := Vector2(356, 200)
	var ang := deg_to_rad(-50)
	var mid := Vector2(183, 0)
	var tip := _union([PackedVector2Array([Vector2(8, -14), Vector2(70, -40), Vector2(70, 40), Vector2(8, 14)]),
		Crayon.ellipse(Vector2(10, 0), Vector2(12, 14), 16)])
	_mark(c, _place(tip, mid, at, ang), purple.darkened(0.1), 602, 10.0)
	_mark(c, _place(Crayon.rounded_rect(Rect2(64, -42, 302, 84), 16), mid, at, ang), purple, 603, 11.0)
	var wrap := _place(Crayon.rounded_rect(Rect2(112, -44, 214, 88), 6), mid, at, ang)
	_mark(c, wrap, purple.lightened(0.45), 604, 9.0)
	for x in [138.0, 300.0]:
		var stripe := _place(PackedVector2Array([Vector2(x - 8, -44), Vector2(x + 8, -44), Vector2(x + 8, 44),
			Vector2(x - 8, 44)]), mid, at, ang)
		Crayon.marker_fill(c, stripe, purple, 605 + int(x), 12.0)
	Crayon.marker_line(c, _place(PackedVector2Array([Vector2(170, 0), Vector2(270, 0)]), mid, at, ang),
		purple.darkened(0.2), 8.0, 607, false)
	Crayon.line(c, _place1(Vector2(80, -24), mid, at, ang), _place1(Vector2(350, -24), mid, at, ang), SHINE, 9.0, 608)


## A felt-tip marker lying corner to corner, nib at the bottom left, cap posted on its end.
static func _felt_marker(c: CanvasItem, body_col: Color, cap_col: Color, nib_col: Color,
		kind: String, seed: int) -> void:
	var at := Vector2(256, 258)
	var ang := deg_to_rad(-40)
	var mid := Vector2(212, 0)
	var nib := _union([PackedVector2Array([Vector2(8, -14), Vector2(56, -30), Vector2(56, 30), Vector2(8, 14)]),
		Crayon.ellipse(Vector2(10, 0), Vector2(13, 15), 16)])
	_mark(c, _place(nib, mid, at, ang), nib_col, seed, 9.0)
	_mark(c, _place(Crayon.rounded_rect(Rect2(46, -42, 36, 84), 10), mid, at, ang), cap_col, seed + 1, 9.0)
	var body := _place(Crayon.rounded_rect(Rect2(74, -48, 268, 96), 22), mid, at, ang)
	_under(c, body)
	Crayon.marker_fill(c, body, body_col, seed + 2)
	match kind:
		"rainbow":
			var cols := [Color("#f7a0a0"), Color("#ffc890"), Color("#fff0a0"), Color("#b8eab0"),
				Color("#a8d0f8"), Color("#cbb4f4")]
			for i in 6:
				var x := 66.0 + i * 46.0
				var band := _place(PackedVector2Array([Vector2(x, -60), Vector2(x + 46, -60),
					Vector2(x + 66, 60), Vector2(x + 20, 60)]), mid, at, ang)
				for piece in Geometry2D.intersect_polygons(band, body):
					Crayon.marker_fill(c, piece, cols[i], seed + 3 + i, 18.0)
		"glitter":
			var spots := [Vector2(110, -18), Vector2(160, 20), Vector2(206, -22), Vector2(252, 16),
				Vector2(298, -14), Vector2(134, 28), Vector2(232, 30), Vector2(186, -2), Vector2(280, -30)]
			for i in spots.size():
				var p := _place1(spots[i], mid, at, ang)
				if i < 5:
					_pen(c, _sparkle(p, 17.0), Color("#fff6d0"), seed + 3 + i, 4.0)
				else:
					c.draw_circle(p, 6.0, Color("#fffdf2"))
		_:
			var band := _place(PackedVector2Array([Vector2(74, -12), Vector2(342, -12), Vector2(342, 12),
				Vector2(74, 12)]), mid, at, ang)
			for piece in Geometry2D.intersect_polygons(band, body):
				Crayon.marker_fill(c, piece, cap_col, seed + 3, 14.0)
	Crayon.line(c, _place1(Vector2(96, -30), mid, at, ang), _place1(Vector2(320, -30), mid, at, ang), SHINE, 10.0, seed + 12)
	Crayon.marker_line(c, body, body_col.darkened(0.5) if kind != "rainbow" else Color("#9a8cc8"), 11.0, seed + 13)
	_mark(c, _place(Crayon.rounded_rect(Rect2(312, -54, 118, 108), 30), mid, at, ang), cap_col, seed + 14, 11.0)
	_mark(c, _place(Crayon.rounded_rect(Rect2(334, -74, 88, 26), 12), mid, at, ang), cap_col.darkened(0.08), seed + 15, 9.0)


# --- Trick cards -----------------------------------------------------------------------------

## Marker: one violet arrow going round a circle.
static func _trick_spin(c: CanvasItem) -> void:
	var path := _arc(Vector2(256, 266), Vector2(150, 150), deg_to_rad(-40), deg_to_rad(222), 40)
	_mark(c, _arrow(path, 64.0, 96.0, 164.0), Color("#9d8af4"), 611, 12.0)


## Marker: two purple music notes bouncing beside a pink twirl of ribbon.
static func _trick_dance(c: CanvasItem) -> void:
	var twirl := PackedVector2Array()
	for i in 40:
		var t := i / 39.0
		twirl.append(Vector2(70 + t * 200, 420 - t * 300) + Vector2(cos(t * TAU * 2.0), sin(t * TAU * 2.0)) * 40.0)
	Crayon.marker_line(c, twirl, Color("#f58fb8").darkened(0.4), 30.0, 661, false)
	Crayon.marker_line(c, twirl, Color("#f58fb8"), 18.0, 661, false)
	var purple := Color("#9d8af4")
	for n in [[Vector2(330, 360), 0], [Vector2(420, 300), 1]]:
		var at: Vector2 = n[0]
		var head := _turn(Crayon.ellipse(at, Vector2(44, 32), 20), at, deg_to_rad(-20))
		_mark(c, _union([head, _capsule(at + Vector2(36, -8), at + Vector2(36, -190), 12)]), purple, 662 + int(n[1]), 11.0)
	_mark(c, _capsule(Vector2(366, 170), Vector2(456, 110), 16), purple, 665, 11.0)


## Marker: a trick card - paper with a pink border and a gold star - and a swoosh beside it.
static func _icon_tricks(c: CanvasItem) -> void:
	var card := _turn(Crayon.rounded_rect(Rect2(126, 70, 230, 330), 30), Vector2(240, 235), deg_to_rad(-10))
	_mark(c, card, Color("#f7b6cc"), 671, 11.0)
	var inner := _turn(Crayon.rounded_rect(Rect2(152, 96, 178, 278), 20), Vector2(240, 235), deg_to_rad(-10))
	_mark(c, inner, Color("#fffdf6"), 672, 0.1)
	_mark(c, Crayon.star(Vector2(240, 236), 78.0, 3), Color("#ffd166"), 673, 9.0)
	var swoosh := _arc(Vector2(250, 260), Vector2(200, 170), deg_to_rad(20), deg_to_rad(110), 18)
	_mark(c, _arrow(swoosh, 40.0, 70.0, 110.0), Color("#9d8af4"), 674, 10.0)


## Marker: a green arrow arcing up and over.
static func _trick_jump(c: CanvasItem) -> void:
	var path := _cubic(Vector2(66, 420), Vector2(90, 20), Vector2(392, 10), Vector2(404, 324), 32)
	var arrow := _union([_arrow(path, 56.0, 92.0, 156.0), Crayon.ellipse(path[0], Vector2(28, 28), 16)])
	_mark(c, arrow, Color("#5fc87a"), 621, 12.0)


## Marker: an orange arrow pointing down onto a lavender line.
static func _trick_sit(c: CanvasItem) -> void:
	_mark(c, _capsule(Vector2(80, 446), Vector2(432, 446), 36), Color("#a7a2ea"), 631, 11.0)
	var path := PackedVector2Array([Vector2(256, 40), Vector2(256, 170), Vector2(256, 300)])
	_mark(c, _arrow(path, 80.0, 108.0, 210.0), Color("#f7a04a"), 632, 12.0)


## Pencil: an open hand waving, tilted, with motion marks either side.
static func _trick_wave(c: CanvasItem) -> void:
	var skin := Color("#ffc59a")
	var hand := _union([Crayon.rounded_rect(Rect2(158, 214, 194, 196), 64),
		Crayon.rounded_rect(Rect2(196, 380, 120, 96), 30),
		_capsule(Vector2(180, 260), Vector2(178, 98), 44),
		_capsule(Vector2(229, 250), Vector2(229, 62), 46),
		_capsule(Vector2(278, 250), Vector2(280, 74), 46),
		_capsule(Vector2(326, 266), Vector2(332, 122), 42),
		_capsule(Vector2(176, 350), Vector2(94, 268), 48)])
	hand = _turn(hand, Vector2(256, 300), deg_to_rad(-12))
	_pen(c, hand, skin, 641, 10.0)
	Crayon.pencil_line(c, _turn(_cubic(Vector2(210, 300), Vector2(240, 330), Vector2(290, 330),
		Vector2(316, 300), 8), Vector2(256, 300), deg_to_rad(-12)), skin.darkened(0.3), 6.0, 642, false)
	var orange := Color("#f7a04a")
	for i in 2:
		var r := 214.0 + i * 40.0
		Crayon.marker_line(c, _arc(Vector2(250, 250), Vector2(r, r), deg_to_rad(-150), deg_to_rad(-122), 8),
			orange, 14.0, 643 + i, false)
		Crayon.marker_line(c, _arc(Vector2(250, 250), Vector2(r, r), deg_to_rad(-58), deg_to_rad(-30), 8),
			orange, 14.0, 645 + i, false)


## Marker: two arrows chasing each other round a wide sideways loop - teal over, pink under.
static func _trick_roll(c: CanvasItem) -> void:
	var at := Vector2(250, 256)
	var r := Vector2(176, 110)
	var over := _arc(at, r, deg_to_rad(196), deg_to_rad(330), 24)
	var under := _arc(at, r, deg_to_rad(16), deg_to_rad(150), 24)
	_mark(c, _arrow(over, 52.0, 86.0, 140.0), Color("#4fb6dc"), 651, 12.0)
	_mark(c, _arrow(under, 52.0, 86.0, 140.0), Color("#f58fb8"), 652, 12.0)


## Marker: a little blue figure taking a bow, a yellow arrow curving down over its head.
static func _trick_bow(c: CanvasItem) -> void:
	var blue := Color("#6fa8ee")
	var body := _union([_capsule(Vector2(150, 444), Vector2(196, 300), 52),
		_capsule(Vector2(236, 444), Vector2(204, 300), 52),
		_capsule(Vector2(236, 444), Vector2(272, 448), 40),
		_capsule(Vector2(200, 296), Vector2(326, 240), 96),
		Crayon.ellipse(Vector2(388, 304), Vector2(64, 64), 32),
		_capsule(Vector2(292, 270), Vector2(296, 360), 38)])
	_mark(c, body, blue, 661, 12.0)
	Crayon.marker_line(c, _arc(Vector2(406, 316), Vector2(18, 14), 0.2, PI - 0.2, 8), blue.darkened(0.5), 7.0, 662, false)
	var path := _cubic(Vector2(196, 150), Vector2(290, 56), Vector2(420, 70), Vector2(452, 168), 20)
	_mark(c, _arrow(path, 32.0, 60.0, 96.0), Color("#ffd166"), 663, 9.0)


# --- Drawing helpers ---------------------------------------------------------------------------

## Marker: a pale blue bathtub on little feet, bubbles heaped over the top.
static func _icon_bath(c: CanvasItem) -> void:
	var blue := Color("#a9d4f2")
	for x in [150.0, 362.0]:
		_mark(c, Crayon.ellipse(Vector2(x, 420), Vector2(26, 22), 16), Color("#f2c46a"), 9301 + int(x), 8.0)
	var tub := PackedVector2Array()
	for i in 25:
		var a := PI * i / 24.0
		tub.append(Vector2(256, 262) + Vector2(cos(a) * 214, sin(a) * 158))
	_mark(c, tub, blue, 9310)
	var rim := Crayon.rounded_rect(Rect2(28, 236, 456, 46), 22)
	_mark(c, rim, Color("#d7ecfb"), 9320)
	var bubbles := [[Vector2(110, 214), 50.0], [Vector2(196, 176), 64.0], [Vector2(300, 184), 58.0],
		[Vector2(392, 214), 48.0], [Vector2(250, 112), 44.0], [Vector2(352, 120), 30.0], [Vector2(150, 120), 28.0]]
	for i in bubbles.size():
		var at: Vector2 = bubbles[i][0]
		var r: float = bubbles[i][1]
		var b := Crayon.ellipse(at, Vector2(r, r), 28)
		_under(c, b)
		Crayon.marker_fill(c, b, Color("#eef8ff"), 9330 + i)
		Crayon.marker_line(c, b, Color("#7fb7e6"), 9.0, 9340 + i)
		Crayon.marker_line(c, PackedVector2Array([at + Vector2(-r * 0.55, -r * 0.1), at + Vector2(-r * 0.4, -r * 0.45),
			at + Vector2(-r * 0.1, -r * 0.6)]), Color(1, 1, 1, 0.95), 8.0, 9350 + i, false)


## Marker: two little phones leaning together - mint and pink - a heart hopping from one to the
## other along a dotted arc. Swapping pets with a friend.
static func _icon_friends(c: CanvasItem) -> void:
	for p in [[Vector2(150, 300), -0.18, Color("#8fd8c0"), 9901], [Vector2(362, 300), 0.18, Color("#f7a6c8"), 9910]]:
		var at: Vector2 = p[0]
		var phone := _turn(Crayon.rounded_rect(Rect2(at - Vector2(80, 130), Vector2(160, 260)), 28), at, p[1])
		_mark(c, phone, p[2], p[3])
		var screen := _turn(Crayon.rounded_rect(Rect2(at - Vector2(58, 100), Vector2(116, 180)), 14), at, p[1])
		_mark(c, screen, Color("#fffdf6"), p[3] + 1, 6.0)
	for i in 7:
		var t := (i + 0.5) / 7.0
		var at := Vector2(lerpf(170, 342, t), 150 - sin(t * PI) * 90.0)
		c.draw_circle(at, 7.0, Color("#b48ad8"))
	_mark(c, Crayon.heart(Vector2(256, 80), 110.0), Color("#f2557a"), 9920, 8.0)


## Marker: a rosette for joining in - rainbow petals round a heart, two ribbon tails. No number,
## no place: everybody gets one.
static func _icon_rosette(c: CanvasItem) -> void:
	var tails := [[Vector2(200, 300), Vector2(150, 480)], [Vector2(312, 300), Vector2(362, 480)]]
	for i in tails.size():
		var a: Vector2 = tails[i][0]
		var b: Vector2 = tails[i][1]
		_mark(c, PackedVector2Array([a + Vector2(-34, 0), a + Vector2(34, 0), b + Vector2(30, 0), b + Vector2(0, -36),
			b + Vector2(-30, 0)]), [Color("#9cc9ef"), Color("#f7a6c8")][i], 9801 + i, 9.0)
	var colors := [Color("#f7a1a1"), Color("#f9c98a"), Color("#f7e48a"), Color("#a9dd9a"), Color("#9cc9ef"), Color("#c3a9ec")]
	for i in 12:
		var a := TAU * i / 12.0
		_mark(c, Crayon.ellipse(Vector2(256, 230) + Vector2(cos(a), sin(a)) * 112.0, Vector2(52, 52), 18),
			colors[i % colors.size()], 9810 + i, 8.0)
	_mark(c, Crayon.ellipse(Vector2(256, 230), Vector2(100, 100), 32), Color("#fffdf6"), 9830, 9.0)
	_mark(c, Crayon.heart(Vector2(256, 236), 120.0), Color("#f2557a"), 9831, 8.0)


## Marker: a chunky toy camera - a mint body, a big lavender lens, a yellow flash.
static func _icon_camera(c: CanvasItem) -> void:
	_mark(c, Crayon.rounded_rect(Rect2(150, 108, 110, 70), 18), Color("#ffd166"), 9501, 10.0)
	_mark(c, Crayon.rounded_rect(Rect2(52, 150, 408, 270), 50), Color("#8fd8c0"), 9502)
	_mark(c, Crayon.ellipse(Vector2(256, 288), Vector2(104, 104), 32), Color("#fffdf6"), 9503, 10.0)
	_mark(c, Crayon.ellipse(Vector2(256, 288), Vector2(70, 70), 28), Color("#b9a6f0"), 9504, 9.0)
	c.draw_circle(Vector2(232, 262), 18.0, Color(1, 1, 1, 0.85))
	_mark(c, Crayon.ellipse(Vector2(396, 200), Vector2(24, 20), 16), Color("#f7a6c8"), 9505, 7.0)


## Marker: a photo album lying open - a pale blue cover, two little photos with a sun and a hill.
static func _icon_album(c: CanvasItem) -> void:
	var blue := Color("#9cc9ef")
	_mark(c, PackedVector2Array([Vector2(36, 140), Vector2(250, 112), Vector2(262, 420), Vector2(48, 440)]), blue, 9601)
	_mark(c, PackedVector2Array([Vector2(262, 112), Vector2(476, 140), Vector2(464, 440), Vector2(250, 420)]), blue, 9602)
	for p in [[Vector2(84, 178), -0.07], [Vector2(296, 162), 0.06]]:
		var at: Vector2 = p[0]
		var photo := Crayon.rounded_rect(Rect2(at, Vector2(132, 150)), 8)
		_mark(c, photo, Color("#fffdf6"), 9610 + int(at.x), 7.0)
		_mark(c, Crayon.rounded_rect(Rect2(at + Vector2(14, 14), Vector2(104, 92)), 6), Color("#cfe9f7"), 9620 + int(at.x), 5.0)
		_mark(c, Crayon.ellipse(at + Vector2(88, 42), Vector2(14, 14), 12), Color("#ffd166"), 9630 + int(at.x), 4.0)
		_mark(c, PackedVector2Array([at + Vector2(14, 106), at + Vector2(60, 66), at + Vector2(118, 106)]),
			Color("#a9dd9a"), 9640 + int(at.x), 4.0)


## Marker: a diary - a pink cover with a heart, pages showing at the edge, a ribbon bookmark.
static func _icon_journal(c: CanvasItem) -> void:
	_mark(c, Crayon.rounded_rect(Rect2(150, 60, 270, 392), 24), Color("#fffdf6"), 9701, 9.0)
	_mark(c, Crayon.rounded_rect(Rect2(92, 44, 300, 410), 30), Color("#f497b8"), 9702)
	_mark(c, Crayon.rounded_rect(Rect2(92, 44, 54, 410), 20), Color("#e07a9e"), 9703, 9.0)
	_mark(c, Crayon.heart(Vector2(270, 230), 150.0), Color("#fff3a8"), 9704, 9.0)
	_mark(c, PackedVector2Array([Vector2(318, 440), Vector2(352, 440), Vector2(352, 500), Vector2(335, 480),
		Vector2(318, 500)]), Color("#9d8af4"), 9705, 7.0)


## Marker: a red lead - a loop handle, a swinging line and a clip - beside two paw prints.
static func _icon_walk(c: CanvasItem) -> void:
	var red := Color("#ef7f7f")
	var loop := Crayon.ellipse(Vector2(150, 150), Vector2(78, 92), 28)
	Crayon.marker_line(c, loop, red.darkened(0.45), 40.0, 9401)
	Crayon.marker_line(c, loop, red, 24.0, 9401)
	var lead := PackedVector2Array([Vector2(196, 222), Vector2(250, 300), Vector2(330, 330), Vector2(392, 300)])
	Crayon.marker_line(c, lead, red.darkened(0.45), 34.0, 9402, false)
	Crayon.marker_line(c, lead, red, 20.0, 9402, false)
	var clip := Crayon.rounded_rect(Rect2(380, 262, 64, 76), 18)
	_mark(c, clip, Color("#c9c6d8"), 9403, 9.0)
	var paw := Color("#b48ad8")
	for p in [[Vector2(160, 410), 0.0], [Vector2(330, 440), 0.3]]:
		var at: Vector2 = p[0]
		_mark(c, Crayon.ellipse(at, Vector2(42, 34), 20), paw, 9410 + int(at.x), 8.0)
		for i in 4:
			var a := -PI * 0.85 + i * PI * 0.23 + float(p[1])
			_mark(c, Crayon.ellipse(at + Vector2(cos(a), sin(a)) * 56.0, Vector2(15, 18), 14), paw,
				9420 + int(at.x) + i, 7.0)


static func _under(c: CanvasItem, poly: PackedVector2Array) -> void:
	if poly.size() >= 3:
		c.draw_colored_polygon(poly, PAPER)


## A shape in coloured pencil on paper: opaque, pencil-filled, outlined a darker shade.
static func _pen(c: CanvasItem, poly: PackedVector2Array, col: Color, seed: int, w := 9.0) -> void:
	_under(c, poly)
	Crayon.pencil_fill(c, poly, col, seed)
	if w > 0.0:
		Crayon.pencil_line(c, poly, col.darkened(0.45), w, seed + 31)


## A shape in marker on paper: opaque, marker-filled, outlined a darker shade.
static func _mark(c: CanvasItem, poly: PackedVector2Array, col: Color, seed: int, w := 11.0) -> void:
	_under(c, poly)
	Crayon.marker_fill(c, poly, col, seed)
	Crayon.marker_line(c, poly, col.darkened(0.5), w, seed + 31)


## A coloured line with darker edges - glasses frames, handles, rings: the same wobble twice,
## wide and dark then narrower in the colour.
static func _frame(c: CanvasItem, pts: PackedVector2Array, col: Color, w: float, seed: int,
		closed := true) -> void:
	Crayon.marker_line(c, pts, col.darkened(0.48), w + 11.0, seed, closed)
	Crayon.marker_line(c, pts, col, w, seed, closed)


## Polka dots clipped to a shape, each on paper so they stay light over a dark fill.
static func _dots(c: CanvasItem, shape: PackedVector2Array, col: Color, seed: int, r := 15.0,
		gap := 64.0) -> void:
	var b := Crayon.bounds(shape)
	var row := 0
	var y := b.position.y + gap * 0.4
	while y < b.end.y + r:
		var x := b.position.x + gap * (0.3 + 0.5 * (row % 2))
		var k := 0
		while x < b.end.x + r:
			var dot := Crayon.blob(Vector2(x, y), Vector2(r, r), seed + row * 17 + k, 12, 0.12)
			for piece in Geometry2D.intersect_polygons(dot, shape):
				_under(c, piece)
				Crayon.pencil_fill(c, piece, col, seed + row * 17 + k)
			x += gap
			k += 1
		y += gap * 0.82
		row += 1


## Every other stretch of a strip along `path` (width w0 -> w1) in `col`: knitted stripes that
## follow the scarf round its bends.
static func _stripe_along(c: CanvasItem, path: PackedVector2Array, w0: float, w1: float, col: Color,
		step: float, seed: int) -> void:
	var fine := _resample(path, 4.0)
	var n := fine.size()
	var per := maxi(2, int(step / 4.0))
	var i := per / 2
	var k := 0
	while i < n - 1:
		var j := mini(i + per, n - 1)
		if k % 2 == 0:
			var sub := fine.slice(i, j + 1)
			var piece := _band(sub, lerpf(w0, w1, i / float(n - 1)) + 2.0, lerpf(w0, w1, j / float(n - 1)) + 2.0)
			_under(c, piece)
			Crayon.pencil_fill(c, piece, col, seed + k)
		i = j
		k += 1


## A number drawn as fat marker strokes, the way a kid writes it.
static func _digit(c: CanvasItem, n: int, at: Vector2, h: float, col: Color, w: float, seed: int) -> void:
	match n:
		1:
			Crayon.marker_line(c, PackedVector2Array([at + Vector2(-0.2, -0.28) * h, at + Vector2(0.04, -0.5) * h,
				at + Vector2(0.04, 0.5) * h]), col, w, seed, false)
			Crayon.marker_line(c, PackedVector2Array([at + Vector2(-0.2, 0.5) * h, at + Vector2(0.28, 0.5) * h]),
				col, w, seed + 1, false)
		2:
			var pts := _arc(at + Vector2(0, -0.22) * h, Vector2(0.27, 0.27) * h, deg_to_rad(-165), deg_to_rad(25), 16)
			pts.append(at + Vector2(-0.3, 0.5) * h)
			pts.append(at + Vector2(0.32, 0.5) * h)
			Crayon.marker_line(c, pts, col, w, seed, false)
		3:
			var pts := _arc(at + Vector2(-0.02, -0.25) * h, Vector2(0.25, 0.25) * h, deg_to_rad(-160), deg_to_rad(90), 16)
			pts.append_array(_arc(at + Vector2(-0.02, 0.24) * h, Vector2(0.28, 0.26) * h, deg_to_rad(-90),
				deg_to_rad(155), 16))
			Crayon.marker_line(c, pts, col, w, seed, false)


# --- Geometry helpers --------------------------------------------------------------------------

## Points along a cubic Bezier.
static func _cubic(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, n := 16) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n + 1:
		var t := i / float(n)
		var u := 1.0 - t
		pts.append(p0 * u * u * u + p1 * 3.0 * u * u * t + p2 * 3.0 * u * t * t + p3 * t * t * t)
	return pts


## Points along part of an ellipse, from angle a0 to a1 (y down: PI/2 is the bottom).
static func _arc(center: Vector2, radius: Vector2, a0: float, a1: float, n := 24) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n + 1:
		var a := lerpf(a0, a1, i / float(n))
		pts.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	return pts


## Point lists joined end to end, dropping repeated joints and a repeated closing point.
static func _join(parts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for part in parts:
		for q in part:
			var p: Vector2 = q
			if out.is_empty() or out[out.size() - 1].distance_to(p) > 0.5:
				out.append(p)
	if out.size() > 2 and out[0].distance_to(out[out.size() - 1]) < 0.5:
		out.remove_at(out.size() - 1)
	return out


## A strip of width w0 -> w1 along a path, as one polygon.
static func _band(path: PackedVector2Array, w0: float, w1 := -1.0) -> PackedVector2Array:
	if w1 < 0.0:
		w1 = w0
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var n := path.size()
	for i in n:
		var a := path[maxi(i - 1, 0)]
		var b := path[mini(i + 1, n - 1)]
		var normal := (b - a).normalized().orthogonal()
		var w := lerpf(w0, w1, i / float(n - 1)) * 0.5
		left.append(path[i] + normal * w)
		right.append(path[i] - normal * w)
	right.reverse()
	left.append_array(right)
	return left


## A leaf or feather: a strip along a path, pointed at both ends, widest in the middle.
static func _leaf(path: PackedVector2Array, width: float) -> PackedVector2Array:
	var fine := path
	if path.size() < 8:
		fine = _resample(path, path[0].distance_to(path[path.size() - 1]) / 12.0)
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var n := fine.size()
	for i in n:
		var a := fine[maxi(i - 1, 0)]
		var b := fine[mini(i + 1, n - 1)]
		var normal := (b - a).normalized().orthogonal()
		var w := width * 0.5 * pow(sin(PI * i / float(n - 1)), 0.75)
		left.append(fine[i] + normal * w)
		right.append(fine[i] - normal * w)
	right.reverse()
	right.remove_at(0)
	right.remove_at(right.size() - 1)
	left.append_array(right)
	return left


## A thick arrow along a path: the strip, and a triangle head past its end.
static func _arrow(path: PackedVector2Array, w: float, head_len: float, head_w: float) -> PackedVector2Array:
	var n := path.size()
	var end := path[n - 1]
	var dir := (end - path[maxi(0, n - 3)]).normalized()
	var normal := dir.orthogonal()
	var head := PackedVector2Array([end - dir * 6.0 + normal * head_w * 0.5, end + dir * head_len,
		end - dir * 6.0 - normal * head_w * 0.5])
	return _union([_band(path, w), head])


## A stadium: a bar from a to b, w wide, with round ends.
static func _capsule(a: Vector2, b: Vector2, w: float) -> PackedVector2Array:
	var ang := (b - a).angle()
	var r := w * 0.5
	var pts := PackedVector2Array()
	for i in 11:
		pts.append(b + Vector2.from_angle(ang - PI / 2.0 + PI * i / 10.0) * r)
	for i in 11:
		pts.append(a + Vector2.from_angle(ang + PI / 2.0 + PI * i / 10.0) * r)
	return pts


## A four-pointed sparkle with curved sides.
static func _sparkle(center: Vector2, size: float, thin := 0.3) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 4:
		var a0 := -PI / 2.0 + i * PI / 2.0
		var tip := center + Vector2.from_angle(a0) * size
		var next := center + Vector2.from_angle(a0 + PI / 2.0) * size
		var ctrl := center + Vector2.from_angle(a0 + PI / 4.0) * size * thin
		for k in 6:
			var t := k / 6.0
			pts.append(tip * (1.0 - t) * (1.0 - t) + ctrl * 2.0 * (1.0 - t) * t + next * t * t)
	return pts


## A flower or rosette edge: a circle with `petals` round bumps, hashed a little uneven.
static func _flower(center: Vector2, r: float, petals: int, seed: int, depth := 0.28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := petals * 12
	for i in n:
		var a := TAU * i / n
		var bump := sqrt(absf(cos(a * petals / 2.0)))
		var k := 1.0 + Crayon.noise(seed, (i + 6) / 12) * 0.05
		pts.append(center + Vector2.from_angle(a) * r * (1.0 - depth * (1.0 - bump)) * k)
	return pts


## A crescent: a disc with another disc bitten out of it.
static func _crescent(center: Vector2, r: float, offset: Vector2, r2: float) -> PackedVector2Array:
	return _largest(Geometry2D.clip_polygons(Crayon.ellipse(center, Vector2(r, r), 48),
		Crayon.ellipse(center + offset, Vector2(r2, r2), 48)))


## A heart, point down, with enough points to stay smooth when big.
static func _heart(center: Vector2, size: float, n := 72) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var t := TAU * i / n
		var x := 16.0 * pow(sin(t), 3)
		var y := 13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)
		pts.append(center + Vector2(x, -y) * size / 32.0)
	return pts


## A loopy squiggle from one point to another, `loops` curls of radius r on the way.
static func _loops(from: Vector2, to: Vector2, loops: float, r: float, n := 90) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n + 1:
		var t := i / float(n)
		var a := t * loops * TAU
		pts.append(from.lerp(to, t) + Vector2(-sin(a), 1.0 - cos(a)) * r * pow(sin(t * PI), 0.35))
	return pts


## Points every `step` px along a path.
static func _resample(path: PackedVector2Array, step: float) -> PackedVector2Array:
	var out := PackedVector2Array([path[0]])
	var carry := 0.0
	for i in path.size() - 1:
		var a := path[i]
		var b := path[i + 1]
		var seg := a.distance_to(b)
		if seg < 0.001:
			continue
		var d := step - carry
		while d <= seg:
			out.append(a.lerp(b, d / seg))
			d += step
		carry = seg - (d - step)
	if out[out.size() - 1].distance_to(path[path.size() - 1]) > 0.5:
		out.append(path[path.size() - 1])
	return out


## The union of overlapping shapes, as one outline.
static func _union(polys: Array) -> PackedVector2Array:
	var acc: PackedVector2Array = polys[0]
	for i in range(1, polys.size()):
		var next: PackedVector2Array = polys[i]
		acc = _largest(Geometry2D.merge_polygons(acc, next))
	return acc


static func _largest(polys: Array) -> PackedVector2Array:
	var best := PackedVector2Array()
	var best_area := -1.0
	for q in polys:
		var p: PackedVector2Array = q
		var area := 0.0
		for i in p.size():
			area += p[i].cross(p[(i + 1) % p.size()])
		if absf(area) > best_area:
			best_area = absf(area)
			best = p
	return best


static func _mirror(poly: PackedVector2Array, cx: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(Vector2(2.0 * cx - p.x, p.y))
	return out


static func _shift(poly: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(p + by)
	return out


static func _turn(poly: PackedVector2Array, pivot: Vector2, angle: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(pivot + (p - pivot).rotated(angle))
	return out


## From a drawing's own frame (lying along +x, centred on `mid`) onto the sheet at `at`, turned.
static func _place(poly: PackedVector2Array, mid: Vector2, at: Vector2, angle: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(_place1(p, mid, at, angle))
	return out


static func _place1(p: Vector2, mid: Vector2, at: Vector2, angle: float) -> Vector2:
	return at + (p - mid).rotated(angle)
