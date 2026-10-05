class_name ArtHomes
extends RefCounted
## The ready-built homes a family picks for an empty plot - one house for each place - and the
## decorations that come with them. Baked to res://art/homes/ by tools/bake_art.gd.
##
## House style (same as ArtThings - read scripts/art_things.gd, especially its _pen / _mark
## brushes that lay an opaque base under the strokes): coloured pencil or marker, outlined in a
## darker shade of its own colour, never black, nothing darker than about 30% value. Doorways
## and windows are pale (lavender, cream, warm yellow light) - never dark holes.
##
## Sheet: 512 x 512, y down. Everything stands on a ground line at y = 470, centred near x = 256
## ("bottom" pivot). Houses fill the sheet (~400-480 px tall, front or gentle 3/4 view, a clear
## door a pet could walk into); decorations are smaller things.

const ASSETS := {
	# One ready-built house per place.
	"house_cottage": {"pivot": "bottom", "look": "Meadow: a cosy cottage, thatched or red roof, round window, flowers by the door"},
	"house_mushroom": {"pivot": "bottom", "look": "Forest: a big red-capped mushroom house with white spots, a round door, a little window"},
	"house_beach_hut": {"pivot": "bottom", "look": "Beach: a striped wooden beach hut on short stilts, little steps"},
	"house_shell": {"pivot": "bottom", "look": "Under the Sea: a giant spiral seashell house, pink-cream, a round door, bubbles"},
	"house_igloo": {"pivot": "bottom", "look": "Snowy Mountains: an igloo of snow blocks with a tunnel doorway"},
	"house_adobe": {"pivot": "bottom", "look": "Desert: a rounded sandy adobe house, a wooden door, a pot by it"},
	"house_jungle_hut": {"pivot": "bottom", "look": "Jungle: a hut of bamboo and big leaves on stilts, a rope ladder"},
	"house_burrow": {"pivot": "bottom", "look": "Crystal Cave: a cosy burrow mound with crystals poking out and a glowing round door"},
	"house_stone_hut": {"pivot": "bottom", "look": "Volcano: a sturdy stone hut, round stones, a chimney with a puff of smoke"},
	"house_stilt": {"pivot": "bottom", "look": "Swamp: a wooden house on tall stilts with a porch and a ladder"},
	"house_cloud_castle": {"pivot": "bottom", "look": "Cloud Kingdom: a small castle made of puffy clouds, pastel flags"},
	"house_moon_base": {"pivot": "bottom", "look": "The Moon: a round dome moon base with a hatch door and an antenna"},
	"house_castle_keep": {"pivot": "bottom", "look": "Castle: a castle tower keep with battlements, a wooden arched door, a flag"},
	"house_gingerbread": {"pivot": "bottom", "look": "Candy Land: a gingerbread house with icing, sweets on the roof, candy-cane posts"},
	# Decorations that come with them (also free in the Decorate drawer).
	"deco_mailbox": {"pivot": "bottom", "look": "a red mailbox on a post, flag up"},
	"deco_mushroom_stool": {"pivot": "bottom", "look": "a little toadstool stool"},
	"deco_log_bench": {"pivot": "bottom", "look": "a bench made from a log"},
	"deco_sandcastle": {"pivot": "bottom", "look": "a sandcastle with a tiny flag"},
	"deco_seashell_chair": {"pivot": "bottom", "look": "a chair shaped like a scallop shell"},
	"deco_snow_pile": {"pivot": "bottom", "look": "a soft pile of snow with a few snowballs"},
	"deco_crystal_lamp": {"pivot": "bottom", "look": "a glowing crystal on a little stand"},
	"deco_lantern": {"pivot": "bottom", "look": "a paper lantern on a short pole, warm yellow glow"},
	"deco_lily_pad": {"pivot": "bottom", "look": "a big lily pad with a pink flower, seen at a low angle"},
	"deco_cloud_bench": {"pivot": "bottom", "look": "a bench made of a fluffy cloud"},
	"deco_moon_flag": {"pivot": "bottom", "look": "a flag on a pole planted in a little moon rock"},
	"deco_candy_lamp": {"pivot": "bottom", "look": "a lamp post that is a candy cane with a gumdrop light"},
	"deco_hay_bale": {"pivot": "bottom", "look": "a round hay bale"},
}

## The paper the pencil and marker sit on: fills get a solid, lighter coat of their colour
## underneath so nothing behind a thing shows through it in a place.
const PAPER := Color("#fffdf7")
## Warm lamplight in a window or a doorway.
const LIGHT := Color("#fce7a2")
## The pale lavender of an open doorway - never a dark hole.
const INSIDE := Color("#e6e0f4")
## Puffy cloud white, and the soft blue its pencil outline and shading are drawn in.
const CLOUD := Color("#f1f5fd")
const CLOUD_LINE := Color("#9fb1db")
const SNOW := Color("#e9f0fb")


static func assets() -> Dictionary:
	return ASSETS


static func draw(id: String, c: CanvasItem) -> void:
	match id:
		"house_cottage":
			_cottage(c)
		"house_mushroom":
			_mushroom_house(c)
		"house_beach_hut":
			_beach_hut(c)
		"house_shell":
			_shell_house(c)
		"house_igloo":
			_igloo(c)
		"house_adobe":
			_adobe(c)
		"house_jungle_hut":
			_jungle_hut(c)
		"house_burrow":
			_burrow(c)
		"house_stone_hut":
			_stone_hut(c)
		"house_stilt":
			_stilt_house(c)
		"house_cloud_castle":
			_cloud_castle(c)
		"house_moon_base":
			_moon_base(c)
		"house_castle_keep":
			_castle_keep(c)
		"house_gingerbread":
			_gingerbread(c)
		"deco_mailbox":
			_mailbox(c)
		"deco_mushroom_stool":
			_mushroom_stool(c)
		"deco_log_bench":
			_log_bench(c)
		"deco_sandcastle":
			_sandcastle(c)
		"deco_seashell_chair":
			_seashell_chair(c)
		"deco_snow_pile":
			_snow_pile(c)
		"deco_crystal_lamp":
			_crystal_lamp(c)
		"deco_lantern":
			_lantern(c)
		"deco_lily_pad":
			_lily_pad(c)
		"deco_cloud_bench":
			_cloud_bench(c)
		"deco_moon_flag":
			_moon_flag(c)
		"deco_candy_lamp":
			_candy_lamp(c)
		"deco_hay_bale":
			_hay_bale(c)


# --- Houses ----------------------------------------------------------------------------------

## Meadow: a cream cottage with a red tiled roof, a round window up in the gable, a blue door
## and flowers along the front.
static func _cottage(c: CanvasItem) -> void:
	var brick := Color("#e39b86")
	var chim := _pv([Vector2(330, 236), Vector2(332, 104), Vector2(374, 100), Vector2(378, 236)])
	_pen(c, chim, brick, 1001, 5.0)
	_shade(c, chim, brick, 1002, Vector2(-12, 0), 0.15)
	for i in 4:
		var y := 126.0 + i * 24.0
		_pline(c, _pv([Vector2(336, y), Vector2(372, y - 1)]), brick.darkened(0.25), 2.5, 1003 + i)
		var x := 348.0 if i % 2 == 0 else 360.0
		_pline(c, _pv([Vector2(x, y - 24), Vector2(x, y)]), brick.darkened(0.25), 2.5, 1008 + i)
	_pen(c, Crayon.rounded_rect(Rect2(322, 86, 62, 20), 5), brick.darkened(0.06), 1012, 4.5)
	_curl(c, Vector2(352, 80), 52.0, -1.0, Color("#d6cfee"), 1013)
	var cream := Color("#f7e8c8")
	var wall := _pv([Vector2(94, 470), Vector2(98, 278), Vector2(256, 116), Vector2(414, 274), Vector2(418, 470)])
	_pen(c, wall, cream, 1020, 6.0)
	_shade(c, wall, cream, 1021, Vector2(-34, 0), 0.12)
	var blue := Color("#8db8df")
	_lit_window(c, _circle(Vector2(256, 212), 32.0, 28), blue, 1025)
	var petals := [Color("#f394b6"), Color("#f7d65c"), Color("#b9a2ea"), Color("#f6a46b")]
	for side in 2:
		var x := 118.0 if side == 0 else 326.0
		var win := _pv([Vector2(x, 306), Vector2(x + 68, 306), Vector2(x + 68, 374), Vector2(x, 374)])
		_lit_window(c, win, blue, 1030 + side * 10)
		for k in 3:
			var at := Vector2(x + 8 + k * 26, 380 - (k % 2) * 6)
			_flower(c, at, 10.0, petals[(k + side) % 4], Color("#f7d65c") if k != 1 else Color("#f39a52"),
				1050 + side * 10 + k)
		_pen(c, Crayon.rounded_rect(Rect2(x - 10, 384, 88, 22), 5), Color("#c99a6c"), 1070 + side, 4.5)
	var door := _arch(256, 458, 56, 338)
	_door(c, door, blue, 1080, Vector2(290, 402))
	_lit_window(c, _circle(Vector2(256, 326), 15.0, 16), blue.darkened(0.08), 1085, true, 5.0)
	_pen(c, Crayon.rounded_rect(Rect2(186, 456, 140, 14), 4), Color("#cfc8dc"), 1090, 3.5)
	var red := Color("#e8675f")
	var roof := _pv([Vector2(256, 54), Vector2(478, 294), Vector2(448, 324), Vector2(256, 120),
		Vector2(64, 324), Vector2(34, 294)])
	_mark(c, roof, red, 1100, 7.5)
	_tile_rows(c, Vector2(256, 54), Vector2(478, 294), Vector2(256, 120), Vector2(448, 324), 2, 6,
		red.darkened(0.25), 1110)
	_tile_rows(c, Vector2(256, 54), Vector2(34, 294), Vector2(256, 120), Vector2(64, 324), 2, 6,
		red.darkened(0.25), 1130)
	_pline(c, _pv([Vector2(48, 292), Vector2(256, 68), Vector2(464, 292)]), Color("#f4a59b"), 4.0, 1150)
	var heads := [Vector2(116, 430), Vector2(146, 446), Vector2(172, 424), Vector2(340, 426), Vector2(368, 446),
		Vector2(396, 430)]
	for i in heads.size():
		var h: Vector2 = heads[i]
		_stem(c, Vector2(h.x + 2, 470), h, 1160 + i * 3)
	for i in heads.size():
		var h: Vector2 = heads[i]
		_flower(c, h, 13.0, petals[i % 4], Color("#f7d65c") if i % 4 != 1 else Color("#f39a52"), 1180 + i * 3)
	_tuft(c, Vector2(96, 470), 1200, 0.9)
	_tuft(c, Vector2(420, 470), 1201, 0.9)


## Forest: a big red toadstool with white spots, a round wooden door in its stem and a little
## lit window.
static func _mushroom_house(c: CanvasItem) -> void:
	var stem_col := Color("#f3e5c9")
	var stem := _smooth(_pv([Vector2(136, 470), Vector2(132, 466), Vector2(146, 404), Vector2(160, 332),
		Vector2(172, 262), Vector2(340, 262), Vector2(352, 332), Vector2(366, 404), Vector2(380, 466),
		Vector2(376, 470), Vector2(256, 470)]), 2)
	_pen(c, stem, stem_col, 2001, 6.0)
	_shade(c, stem, stem_col, 2002, Vector2(-30, 0), 0.12)
	for i in 5:
		var at := Vector2([190.0, 330.0, 200.0, 318.0, 182.0][i], [330.0, 300.0, 430.0, 446.0, 380.0][i])
		_pline(c, _pv([at, at + Vector2(2, 16)]), stem_col.darkened(0.2), 3.0, 2003 + i)
	var under := Crayon.ellipse(Vector2(256, 278), Vector2(192, 28), 40)
	var gill := Color("#ecd5b6")
	_pen(c, under, gill, 2010, 4.5)
	for k in 15:
		var a := PI * (k + 0.5) / 15.0
		var from := Vector2(256, 272) + Vector2(cos(a) * 70.0, sin(a) * 8.0)
		var to := Vector2(256, 278) + Vector2(cos(a) * 180.0, sin(a) * 24.0)
		_pline(c, _pv([from, to]), gill.darkened(0.22), 2.5, 2011 + k)
	var red := Color("#e66a5c")
	var cap := PackedVector2Array()
	cap.append_array(_arc(Vector2(256, 268), Vector2(224, 236), PI, TAU, 44))
	cap.append_array(_arc(Vector2(256, 268), Vector2(224, 12), 0.0, PI, 24).slice(1, 24))
	cap = _rot(cap, Vector2(256, 268), -0.03)
	_pen(c, cap, red, 2030, 6.5)
	var spots := [Vector3(150, 180, 30), Vector3(258, 98, 36), Vector3(356, 168, 28), Vector3(210, 236, 18),
		Vector3(316, 238, 22), Vector3(92, 250, 15), Vector3(424, 246, 15), Vector3(186, 112, 17),
		Vector3(366, 92, 14), Vector3(260, 186, 14)]
	var spot_col := Color("#fcf4ea")
	for i in spots.size():
		var v: Vector3 = spots[i]
		var blob := _smooth(Crayon.blob(Vector2(v.x, v.y), Vector2(v.z, v.z * 0.86), 2040 + i, 12, 0.14), 2)
		for piece in Geometry2D.intersect_polygons(blob, cap):
			if piece.size() >= 3:
				_pfill(c, piece, spot_col, 2050 + i)
				Crayon.pencil_line(c, piece, Color("#efc8bd"), 3.0, 2060 + i)
	_shade(c, cap, red, 2070, Vector2(-38, -30), 0.14)
	_gleam(c, cap, 2071, Vector2(22, 24), 0.32)
	Crayon.pencil_line(c, cap, red.darkened(0.45), 6.0, 2072)
	var dc := Vector2(246, 388)
	var frame := _arch(dc.x, 470, 70, dc.y)
	_pen(c, frame, Color("#d2c9de"), 2080, 4.5)
	for i in 7:
		var a := PI + PI * (i + 0.5) / 7.0
		var d := Vector2(cos(a), sin(a))
		_pline(c, _pv([dc + d * 56.0, dc + d * 70.0]), Color("#a99fbd"), 3.0, 2081 + i)
	var door := _arch(dc.x, 470, 56, dc.y)
	_door(c, door, Color("#dca36c"), 2090, Vector2(276, 424))
	_lit_window(c, _circle(Vector2(246, 364), 14.0, 16), Color("#c48b57"), 2095, true, 5.0)
	_lit_window(c, _circle(Vector2(332, 334), 16.0, 20), Color("#c48b57"), 2100)
	for m in [[Vector2(96, 470), 1.0, 2110], [Vector2(420, 470), 0.8, 2120], [Vector2(130, 470), 0.6, 2130]]:
		_tiny_toadstool(c, m[0], m[1], m[2])
	_tuft(c, Vector2(164, 470), 2140, 0.9)
	_tuft(c, Vector2(356, 470), 2141, 0.9)


## Beach: a striped wooden beach hut on short stilts, little steps up to a coral door, a
## lifebuoy and a starfish on the wall, a pennant on the roof.
static func _beach_hut(c: CanvasItem) -> void:
	var wood := Color("#dcbb8f")
	var sand := Color("#f2dca6")
	for x in [138.0, 374.0]:
		_pen(c, Crayon.rounded_rect(Rect2(x - 12, 384, 24, 86), 5), wood.darkened(0.06), 3001 + int(x), 4.5)
	var body := _pv([Vector2(120, 386), Vector2(126, 178), Vector2(386, 174), Vector2(392, 386)])
	var aqua := Color("#77c4d6")
	var cream := Color("#fbf1dc")
	_mfill(c, body, cream, 3010)
	var w := 272.0 / 8.0
	for k in 8:
		if k % 2 == 1:
			continue
		var x0 := 120.0 + k * w
		var stripe := _pv([Vector2(x0, 150), Vector2(x0 + w, 150), Vector2(x0 + w + 2, 400), Vector2(x0 + 2, 400)])
		_clip_fill(c, stripe, body, aqua, 3020 + k)
	for k in range(1, 8):
		var x := 120.0 + k * w
		_pline(c, _pv([Vector2(x + 1, 182), Vector2(x + 2, 382)]), aqua.darkened(0.3), 2.5, 3030 + k)
	_shade(c, body, aqua, 3040, Vector2(-26, 0), 0.1)
	Crayon.marker_line(c, body, aqua.darkened(0.48), 6.5, 3041)
	var gable := _pv([Vector2(126, 186), Vector2(256, 80), Vector2(386, 182)])
	_pen(c, gable, cream, 3045, 4.5)
	_lit_window(c, _circle(Vector2(256, 148), 20.0, 20), wood.darkened(0.08), 3046)
	_pen(c, _band(_pv([Vector2(256, 52), Vector2(256, 10)]), 3.5), Color("#c9a37a"), 3050, 3.0)
	_mark(c, _pv([Vector2(259, 12), Vector2(312, 24), Vector2(259, 38)]), Color("#f6cf5c"), 3051, 4.5)
	var coral := Color("#ef8a7b")
	var roof := _pv([Vector2(256, 44), Vector2(436, 198), Vector2(414, 222), Vector2(256, 88),
		Vector2(98, 222), Vector2(76, 198)])
	_mark(c, roof, coral, 3055, 7.0)
	_pline(c, _pv([Vector2(88, 200), Vector2(256, 58), Vector2(424, 200)]), Color("#f8b4a8"), 4.0, 3056)
	var door := _arch(256, 376, 50, 262, 30)
	_door(c, door, coral, 3060, Vector2(286, 322), 24.0)
	_lit_window(c, _circle(Vector2(256, 272), 16.0, 16), coral.darkened(0.1), 3065, true, 5.0)
	var ring := Vector2(166, 300)
	for k in 8:
		var col := Color("#ef7a78") if k % 2 == 0 else Color("#fbf3e6")
		var seg := _annulus(ring, 27.0, 15.0, TAU * k / 8.0, TAU * (k + 1) / 8.0)
		_mfill(c, seg, col, 3070 + k)
	Crayon.marker_line(c, _circle(ring, 27.0, 28), Color("#b8545a"), 4.0, 3080)
	Crayon.marker_line(c, _circle(ring, 15.0, 18), Color("#b8545a"), 3.0, 3081)
	_mark(c, Crayon.star(Vector2(348, 296), 24.0, 3082), Color("#f6b26b"), 3083, 4.0)
	c.draw_circle(Vector2(348, 296), 3.0, Color("#fbe3c4"))
	_pen(c, Crayon.rounded_rect(Rect2(98, 374, 316, 20), 5), wood, 3090, 4.5)
	var steps := [Rect2(204, 394, 104, 26), Rect2(196, 420, 120, 26), Rect2(188, 446, 136, 24)]
	for i in steps.size():
		var r: Rect2 = steps[i]
		_pen(c, Crayon.rounded_rect(r, 4), wood.lightened(0.04 * i), 3095 + i, 4.5)
		_pline(c, _pv([r.position + Vector2(10, 9), r.position + Vector2(r.size.x - 10, 9)]), wood.darkened(0.2), 2.5, 3100 + i)
	for x in [86.0, 426.0]:
		_pen(c, _arc(Vector2(x, 470), Vector2(54, 16), PI, TAU, 16), sand, 3110 + int(x), 4.0)
	_pen(c, _shell_shape(Vector2(438, 452), 16.0), Color("#f6b8bd"), 3120, 3.0)


## Under the Sea: a giant spiral seashell, its turns winding up to a point in pink and cream,
## a flared lip at one side, a round sea-green door, portholes and bubbles drifting up.
static func _shell_house(c: CanvasItem) -> void:
	var pink := Color("#f3b4b6")
	var cream := Color("#fbe5d6")
	var weed := Color("#7fc49a")
	var sut := [56.0, 96.0, 146.0, 208.0, 282.0]
	var slant := 26.0
	var shell := PackedVector2Array()
	for i in 115:
		var y := 470.0 - i * 4.0
		shell.append(Vector2(256.0 - _spire_w(y) * _whorl_bulge(y, sut, 0.0), y))
	shell.append(Vector2(256, 12))
	for i in 115:
		var y := 14.0 + i * 4.0
		shell.append(Vector2(256.0 + _spire_w(y) * _whorl_bulge(y, sut, slant), y))
	shell.append(Vector2(256.0 + _spire_w(470.0), 470))
	_pfill(c, shell, pink, 4001)
	var sutures := []
	for k in sut.size():
		var y0: float = sut[k]
		var a := Vector2(256.0 - _spire_w(y0) - 12.0, y0)
		var b := Vector2(256.0 + _spire_w(y0 + slant) + 12.0, y0 + slant)
		var w := b.x - a.x
		sutures.append(_bez(a, a + Vector2(w * 0.3, 16), b + Vector2(-w * 0.3, 16), b, 20))
	for k in sut.size() - 1:
		if k % 2 == 1:
			continue
		var band: PackedVector2Array = (sutures[k] as PackedVector2Array).duplicate()
		var lower: PackedVector2Array = (sutures[k + 1] as PackedVector2Array).duplicate()
		lower.reverse()
		band.append_array(lower)
		_clip_fill(c, band, shell, cream, 4010 + k, false)
	var low_band := PackedVector2Array()
	for i in 21:
		var t := i / 20.0
		low_band.append(Vector2(lerpf(20, 492, t), 330.0 - 30.0 * t - sin(t * PI) * 10.0))
	for i in 21:
		var t := 1.0 - i / 20.0
		low_band.append(Vector2(lerpf(20, 492, t), 352.0 - 30.0 * t - sin(t * PI) * 10.0))
	_clip_fill(c, low_band, shell, cream, 4020, false)
	var ridge := pink.darkened(0.16)
	for k in sut.size() - 1:
		var upper: PackedVector2Array = sutures[k]
		var lower: PackedVector2Array = sutures[k + 1]
		for j in 6:
			var u := 0.12 + j * 0.15
			var p0 := _at(upper, _path_len(upper) * u) + Vector2(0, 4)
			var p1 := _at(lower, _path_len(lower) * (u + 0.03)) + Vector2(0, -4)
			for piece in Geometry2D.intersect_polyline_with_polygon(_pv([p0, p0.lerp(p1, 0.5) + Vector2(-4, 0), p1]), shell):
				_pline(c, piece, ridge, 2.5, 4030 + k * 10 + j)
	_shade(c, shell, pink, 4060, Vector2(-40, -10), 0.12)
	_gleam(c, shell, 4061, Vector2(28, 10), 0.4)
	for k in sut.size():
		for piece in Geometry2D.intersect_polyline_with_polygon(sutures[k], shell):
			_pline(c, piece, pink.darkened(0.4), 4.0, 4070 + k)
	Crayon.pencil_line(c, shell, pink.darkened(0.45), 6.0, 4080)
	for s in [[Vector2(44, 470), 0.62, 3990], [Vector2(468, 470), 0.5, 3995], [Vector2(486, 470), 0.36, 3998]]:
		var base: Vector2 = s[0]
		var k: float = s[1]
		var path := PackedVector2Array()
		for i in 12:
			var t := i / 11.0
			path.append(base + Vector2(sin(t * TAU * 1.2 + k * 5.0) * 10.0, -t * 200.0 * k))
		_pen(c, _band(path, 8.0), weed, s[2], 4.0)
	var pearl := Color("#e7dcf3")
	var dc := Vector2(250, 398)
	var frame := _ground_cut(_circle(dc, 82.0, 40))
	_pen(c, frame, pearl, 4100, 5.0)
	for i in 9:
		var a := PI + PI * (i + 0.5) / 9.0
		c.draw_circle(dc + Vector2(cos(a), sin(a)) * 73.0, 4.0, Color("#fdfbff"))
	var door := _ground_cut(_circle(dc, 66.0, 36))
	_door(c, door, Color("#86cfc3"), 4105, dc + Vector2(36, 24), 24.0)
	_lit_window(c, _circle(dc + Vector2(0, -28), 15.0, 16), Color("#7cc0b2"), 4110, true, 5.0)
	_lit_window(c, _circle(Vector2(118, 384), 22.0, 22), pearl.darkened(0.08), 4115)
	_lit_window(c, _circle(Vector2(378, 380), 22.0, 22), pearl.darkened(0.08), 4120)
	_lit_window(c, _circle(Vector2(268, 250), 20.0, 20), pearl.darkened(0.08), 4125)
	_mark(c, Crayon.star(Vector2(398, 446), 20.0, 4130), Color("#f59a7f"), 4131, 4.0)
	_pen(c, _shell_shape(Vector2(98, 452), 18.0), Color("#f6d2a6"), 4132, 3.0)
	for b in [Vector3(424, 236, 16), Vector3(452, 186, 11), Vector3(430, 144, 8), Vector3(456, 112, 6),
			Vector3(82, 222, 13), Vector3(60, 172, 9), Vector3(86, 136, 6)]:
		var v: Vector3 = b
		_bubble(c, Vector2(v.x, v.y), v.z, 4140 + int(v.y))


## Half-width of the seashell's cone at height y: a point at the top, wide and rounded at the
## foot.
static func _spire_w(y: float) -> float:
	var t := clampf((y - 12.0) / 330.0, 0.0, 1.0)
	var w := 222.0 * pow(t, 0.82)
	if y > 400.0:
		w *= 1.0 - 0.22 * pow((y - 400.0) / 70.0, 2)
	return w


## How far a turn of the shell bulges out at height y - each turn swells between its seams.
static func _whorl_bulge(y: float, sut: Array, shift: float) -> float:
	var prev := 12.0
	for s in sut:
		var sy: float = s + shift
		if y < sy:
			return 1.0 + 0.09 * sin(clampf((y - prev) / maxf(sy - prev, 1.0), 0.0, 1.0) * PI)
		prev = sy
	return 1.0 + 0.05 * sin(clampf((y - prev) / (470.0 - prev), 0.0, 1.0) * PI)


## Snowy Mountains: a tall igloo of snow blocks, a tunnel doorway at the front, warm-lit ice
## windows and a little pennant on top.
static func _igloo(c: CanvasItem) -> void:
	var joint := Color("#a7b7dc")
	_pen(c, _band(_pv([Vector2(256, 140), Vector2(256, 54)]), 3.5), Color("#c9a37a"), 5001, 3.0)
	_mark(c, _pv([Vector2(259, 56), Vector2(316, 70), Vector2(259, 86)]), Color("#f39ab6"), 5002, 4.5)
	var ctr := Vector2(256, 470)
	var rad := Vector2(212, 334)
	var dome := _arc(ctr, rad, PI, TAU, 52)
	_pen(c, dome, SNOW, 5010, 6.0)
	_shade(c, dome, Color("#c9d6f0"), 5011, Vector2(-44, 0), 0.0)
	_igloo_blocks(c, ctr, rad, 7, joint, 5020)
	_gleam(c, dome, 5012, Vector2(26, 30), 0.5)
	Crayon.pencil_line(c, dome, Color("#8f9fc8"), 6.0, 5013)
	for x in [138.0, 374.0]:
		_lit_window(c, _circle(Vector2(x, 336), 24.0, 22), Color("#bcd8ee"), 5030 + int(x))
	var t_ctr := Vector2(256, 470)
	var t_rad := Vector2(124, 182)
	var tunnel := _arc(t_ctr, t_rad, PI, TAU, 36)
	_pen(c, tunnel, SNOW, 5040, 6.0)
	_shade(c, tunnel, Color("#c9d6f0"), 5041, Vector2(-26, 0), 0.0)
	_igloo_blocks(c, t_ctr, t_rad, 3, joint, 5050)
	Crayon.pencil_line(c, tunnel, Color("#8f9fc8"), 6.0, 5042)
	var door := _arc(t_ctr, Vector2(80, 132), PI, TAU, 28)
	_pen(c, door, INSIDE, 5060, 5.0)
	_shade(c, door, INSIDE, 5063, Vector2(0, 30), 0.08)
	for d in [[Vector3(74, 470, 34), Vector3(110, 470, 22)], [Vector3(440, 470, 30), Vector3(408, 470, 18)]]:
		var heap := _ground_cut(_circles(d))
		_pfill(c, heap, SNOW, 5080 + int(heap[0].x))
		_shade(c, heap, Color("#c9d6f0"), 5081 + int(heap[0].x), Vector2(-10, -10), 0.0)
		Crayon.pencil_line(c, heap, Color("#8f9fc8"), 4.5, 5082 + int(heap[0].x))
	for s in [Vector2(176, 210), Vector2(352, 236), Vector2(420, 120)]:
		_twinkle(c, s, 12.0, Color("#9fb6e0"), 5090 + int(s.x))


## Desert: a rounded adobe house in two steps, log ends poking out, a turquoise door under a
## wooden lintel, a string of chillies and a painted pot by the door.
static func _adobe(c: CanvasItem) -> void:
	var clay := Color("#eab28c")
	var wood := Color("#c99063")
	var teal := Color("#78c7c1")
	var chim := _top_round(Rect2(296, 34, 44, 70), 18)
	_pen(c, chim, clay.lightened(0.02), 5995, 5.0)
	_shade(c, chim, clay, 5996, Vector2(-12, 0), 0.12)
	var upper := _rot(_top_round(Rect2(146, 76, 206, 194), 34), Vector2(250, 180), -0.025)
	_pen(c, upper, clay.lightened(0.05), 6001, 6.0)
	_shade(c, upper, clay, 6002, Vector2(-30, 0), 0.12)
	for x in [174.0, 218.0, 286.0, 330.0]:
		_log_end(c, Vector2(x, 106), 9.0, wood, 6003 + int(x))
	_lit_window(c, Crayon.rounded_rect(Rect2(222, 142, 56, 64), 20), teal, 6010)
	var lower := _top_round(Rect2(62, 232, 388, 238), 46)
	_pen(c, lower, clay, 6020, 6.0)
	_shade(c, lower, clay, 6021, Vector2(-40, -6), 0.13)
	_gleam(c, lower, 6022, Vector2(24, 20), 0.25)
	for i in 6:
		var at := Vector2([100.0, 170.0, 330.0, 400.0, 120.0, 404.0][i], [400.0, 300.0, 286.0, 410.0, 446.0, 450.0][i])
		_pline(c, _pv([at, at + Vector2(14, 2)]), clay.darkened(0.2), 3.0, 6023 + i)
	for x in [96.0, 150.0, 362.0, 416.0]:
		_log_end(c, Vector2(x, 260), 10.0, wood, 6030 + int(x))
	for x in [96.0, 358.0]:
		_lit_window(c, Crayon.rounded_rect(Rect2(x, 300, 58, 64), 20), teal, 6040 + int(x))
	var door := _arch(256, 470, 54, 344, 26)
	_door(c, door, teal, 6050, Vector2(286, 410), 27.0)
	_pen(c, Crayon.rounded_rect(Rect2(188, 300, 136, 18), 5), wood, 6055, 4.5)
	_pline(c, _pv([Vector2(184, 288), Vector2(184, 304)]), Color("#b99a72"), 3.0, 6060)
	for i in 6:
		var at := Vector2(184 + (5.0 if i % 2 == 0 else -5.0), 312 + i * 15.0)
		var chili := _leaf(at, 24.0, 12.0, PI / 2.0 + (0.4 if i % 2 == 0 else -0.4))
		_mark(c, chili, Color("#e8605a"), 6061 + i, 3.0)
	_mark(c, _leaf(Vector2(184, 306), 14.0, 8.0, 0.0), Color("#8cc46a"), 6070, 2.5)
	var terra := Color("#e08e6a")
	var pot := _smooth(_pv([Vector2(364, 470), Vector2(330, 470), Vector2(326, 466), Vector2(318, 440),
		Vector2(320, 410), Vector2(336, 392), Vector2(392, 392), Vector2(408, 410), Vector2(410, 440),
		Vector2(402, 466), Vector2(398, 470)]), 2)
	_pen(c, pot, terra, 6080, 5.0)
	_shade(c, pot, terra, 6081, Vector2(-16, 0), 0.15)
	var zig := PackedVector2Array()
	for i in 9:
		zig.append(Vector2(328 + i * 9.0, 426.0 + (8.0 if i % 2 == 0 else -6.0)))
	_mline(c, zig, Color("#fbe3c0"), 4.5, 6082)
	_pen(c, Crayon.rounded_rect(Rect2(330, 384, 68, 14), 5), terra.lightened(0.06), 6083, 4.0)
	var cactus := Color("#8fca7a")
	_pen(c, _top_round(Rect2(105, 374, 26, 96), 13), cactus, 6090, 4.5)
	_pen(c, _band(_pv([Vector2(118, 436), Vector2(92, 436), Vector2(92, 410)]), 8.0), cactus, 6091, 4.0)
	_pen(c, _band(_pv([Vector2(118, 420), Vector2(142, 420), Vector2(142, 398)]), 8.0), cactus, 6092, 4.0)
	_mark(c, _circle(Vector2(118, 374), 9.0, 12), Color("#f39ab6"), 6093, 3.0)


## Jungle: a bamboo hut up on stilts under a thatch of big overlapping leaves, a rope ladder
## down from the platform, tropical flowers at its feet.
static func _jungle_hut(c: CanvasItem) -> void:
	var bamboo := Color("#cfdb8c")
	for x in [198.0, 314.0]:
		_bamboo(c, Vector2(x, 466), Vector2(x, 340), 9.0, bamboo.darkened(0.08), 7001 + int(x))
	for x in [126.0, 386.0]:
		_bamboo(c, Vector2(x, 470), Vector2(x, 330), 12.0, bamboo, 7010 + int(x))
	_pen(c, _band(_pv([Vector2(132, 452), Vector2(220, 352)]), 5.0), bamboo.darkened(0.04), 7020, 3.5)
	_pen(c, _band(_pv([Vector2(380, 452), Vector2(292, 352)]), 5.0), bamboo.darkened(0.04), 7021, 3.5)
	var poles := 11
	var pw := 256.0 / poles
	for i in poles:
		var x := 128.0 + i * pw
		var col := bamboo if i % 2 == 0 else bamboo.darkened(0.05)
		_pen(c, Crayon.rounded_rect(Rect2(x, 170, pw, 162), 7), col, 7040 + i, 3.5)
		var y := 292.0 + 16.0 * Crayon.noise(7060, i)
		_pline(c, _pv([Vector2(x + 3, y), Vector2(x + pw - 3, y + 1)]), col.darkened(0.3), 2.5, 7070 + i)
	for x in [144.0, 320.0]:
		var win := _pv([Vector2(x, 222), Vector2(x + 48, 222), Vector2(x + 48, 270), Vector2(x, 270)])
		_lit_window(c, win, Color("#c8a46c"), 7080 + int(x))
	var door := _arch(256, 330, 46, 246, 30)
	_pen(c, door, INSIDE, 7090, 4.5)
	_shade(c, door, INSIDE, 7091, Vector2(0, 26), 0.1)
	for x in [206.0, 306.0]:
		_bamboo(c, Vector2(x, 332), Vector2(x, 212), 8.0, bamboo.darkened(0.1), 7095 + int(x))
	var greens := [Color("#86c46a"), Color("#9bd27a"), Color("#76b862")]
	_pfill(c, _pv([Vector2(256, 44), Vector2(410, 176), Vector2(102, 176)]), greens[0], 7030)
	_pen(c, _leaf(Vector2(240, 54), 70.0, 30.0, -2.0), greens[1], 7100, 3.5)
	_pen(c, _leaf(Vector2(274, 52), 70.0, 30.0, -1.15), greens[2], 7101, 3.5)
	for r in 4:
		var row_y := 44.0 + r * 34.0
		var hw := (row_y - 34.0) / 110.0 * 160.0 + 30.0
		var n := maxi(1, roundi(2.0 * hw / 54.0))
		for k in n:
			var x := 256.0 - hw + (k + 0.5) * 2.0 * hw / n
			var tilt := (x - 256.0) / maxf(hw, 1.0) * (0.45 + r * 0.12)
			var col: Color = greens[(k + r) % 3]
			var ang := PI / 2.0 - tilt
			var dir := Vector2(cos(ang), sin(ang))
			var at := Vector2(x, row_y) + dir * 36.0
			_pen(c, _leaf(at, 78.0, 40.0, ang), col, 7110 + r * 20 + k, 3.5)
			_pline(c, _pv([at - dir * 32.0, at + dir * 30.0]), col.darkened(0.25), 2.5, 7111 + r * 20 + k)
	_pen(c, Crayon.rounded_rect(Rect2(88, 324, 336, 22), 6), Color("#d8b47a"), 7200, 4.5)
	for x in [92.0, 420.0]:
		_log_end(c, Vector2(x, 335), 10.0, Color("#d8b47a"), 7201 + int(x))
	var rope := Color("#cfb184")
	for x in [228.0, 284.0]:
		_pline(c, _pv([Vector2(x, 340), Vector2(x + 3, 404), Vector2(x - 2, 468)]), rope.darkened(0.15), 5.0, 7210 + int(x))
	for i in 4:
		var y := 362.0 + i * 28.0
		_pen(c, Crayon.rounded_rect(Rect2(222, y, 68, 11), 4), bamboo.darkened(0.06), 7220 + i, 3.5)
	_pen(c, _leaf(Vector2(66, 440), 80.0, 30.0, -2.2), greens[0], 7230, 3.5)
	_pen(c, _leaf(Vector2(92, 436), 80.0, 30.0, -1.3), greens[1], 7231, 3.5)
	_pen(c, _leaf(Vector2(442, 440), 80.0, 30.0, -0.9), greens[2], 7232, 3.5)
	_pen(c, _leaf(Vector2(418, 434), 80.0, 30.0, -1.8), greens[0], 7233, 3.5)
	_flower(c, Vector2(80, 412), 14.0, Color("#f48aa8"), Color("#f7d65c"), 7240)
	_flower(c, Vector2(434, 410), 12.0, Color("#f6a46b"), Color("#f7d65c"), 7241)
	_pline(c, _bez(Vector2(96, 188), Vector2(90, 230), Vector2(104, 260), Vector2(98, 300), 10), greens[2].darkened(0.2), 4.0, 7250)
	for i in 3:
		_pen(c, _leaf(Vector2(98 + (8.0 if i % 2 == 0 else -8.0), 214 + i * 30.0), 24.0, 13.0,
			PI / 2.0 + (-0.9 if i % 2 == 0 else 0.9)), greens[1], 7251 + i, 2.5)


## Crystal Cave: a cosy earth mound, crystals growing out of it, a round door glowing with
## warm light and a little round window.
static func _burrow(c: CanvasItem) -> void:
	var crystals := [[Vector2(256, 214), 164.0, 64.0, 0.0, Color("#b9a6f0")],
		[Vector2(204, 222), 118.0, 50.0, -0.36, Color("#f4a8c8")],
		[Vector2(310, 220), 128.0, 52.0, 0.34, Color("#8fd8e2")],
		[Vector2(162, 240), 72.0, 36.0, -0.7, Color("#8fd8e2")],
		[Vector2(352, 236), 80.0, 38.0, 0.72, Color("#f4a8c8")]]
	for i in crystals.size():
		var k: Array = crystals[i]
		_crystal(c, k[0], k[1], k[2], k[3], k[4], 8001 + i * 7)
	var earth := Color("#cfa996")
	var mound := _smooth(_pv([Vector2(24, 470), Vector2(26, 456), Vector2(42, 380), Vector2(76, 306),
		Vector2(132, 244), Vector2(200, 208), Vector2(256, 198), Vector2(318, 206), Vector2(386, 240),
		Vector2(440, 304), Vector2(474, 380), Vector2(488, 456), Vector2(488, 470), Vector2(256, 470)]), 2)
	_pen(c, mound, earth, 8040, 6.0)
	var moss := _smooth(_pv([Vector2(110, 262), Vector2(168, 220), Vector2(256, 200), Vector2(344, 214),
		Vector2(408, 260), Vector2(380, 274), Vector2(350, 254), Vector2(318, 270), Vector2(286, 250),
		Vector2(256, 266), Vector2(224, 250), Vector2(194, 270), Vector2(164, 254), Vector2(136, 276)]), 2)
	for piece in Geometry2D.intersect_polygons(moss, mound):
		if piece.size() >= 3:
			_pen(c, piece, Color("#a8d69a"), 8041, 4.0)
	_shade(c, mound, earth, 8042, Vector2(-44, -30), 0.14)
	_gleam(c, mound, 8043, Vector2(30, 30), 0.25)
	for i in 9:
		var at := Vector2([86.0, 120.0, 420.0, 450.0, 396.0, 70.0, 150.0, 360.0, 436.0][i],
			[420.0, 330.0, 330.0, 430.0, 400.0, 450.0, 446.0, 452.0, 376.0][i])
		_pen(c, Crayon.blob(at, Vector2(14, 9), 8050 + i, 10, 0.12), Color("#c2b9d8"), 8060 + i, 3.0)
	_crystal(c, Vector2(84, 352), 64.0, 30.0, -0.9, Color("#b9a6f0"), 8070)
	_crystal(c, Vector2(436, 344), 70.0, 32.0, 0.9, Color("#8fd8e2"), 8077)
	_crystal(c, Vector2(448, 408), 44.0, 22.0, 1.1, Color("#f4a8c8"), 8084)
	var ctr := Vector2(256, 386)
	_rays(c, ctr, Vector2(122, 122), 22.0, [PI + 0.35, PI + 0.8, PI + 1.25, PI + 1.89, PI + 2.34, PI + 2.79],
		Color("#f6d46a"), 8090, 6.0)
	var ring := _ground_cut(_circle(ctr, 104.0, 44))
	var wood := Color("#c99063")
	_pen(c, ring, wood, 8100, 5.0)
	for i in 8:
		var a := PI + PI * (i + 0.5) / 8.0
		var d := Vector2(cos(a), sin(a))
		_pline(c, _pv([ctr + d * 88.0, ctr + d * 104.0]), wood.darkened(0.3), 3.0, 8101 + i)
	var door := _ground_cut(_circle(ctr, 88.0, 40))
	_pfill(c, door, LIGHT, 8110)
	Crayon.pencil_fill(c, Crayon.blob(ctr + Vector2(0, 30), Vector2(60, 42), 8111, 16, 0.06), Color("#fff6d2"), 8112)
	Crayon.pencil_line(c, door, LIGHT.darkened(0.3), 4.0, 8113)
	var leaf := _ground_cut(Crayon.ellipse(Vector2(146, 388), Vector2(32, 84), 32))
	_door(c, leaf, Color("#e7b07a"), 8120, Vector2(134, 408), 16.0)
	_rays(c, Vector2(388, 312), Vector2(36, 36), 12.0, [PI + 0.6, PI + 1.57, PI + 2.5, 0.0], Color("#f6d46a"), 8130, 5.0)
	_lit_window(c, _circle(Vector2(388, 312), 24.0, 24), wood, 8140)
	for m in [[Vector2(408, 470), 0.7], [Vector2(434, 470), 0.5]]:
		_glow_shroom(c, m[0], m[1], 8150 + int((m[0] as Vector2).x))


## Volcano: a sturdy hut of round stones under a lavender slate roof, a stone chimney puffing
## smoke, a heavy wooden door in a stone arch.
static func _stone_hut(c: CanvasItem) -> void:
	var greys := [Color("#d6c2b8"), Color("#c9b6b0"), Color("#ddcbbf"), Color("#c7b8c6")]
	var grout := Color("#e8dbd2")
	var puff := _circles([Vector3(366, 50, 13), Vector3(348, 34, 17), Vector3(322, 24, 18), Vector3(296, 20, 16),
		Vector3(310, 40, 13)])
	_pfill(c, puff, Color("#f1ecf6"), 9001)
	_shade(c, puff, Color("#ddd5ea"), 9002, Vector2(-10, -8), 0.0)
	Crayon.pencil_line(c, puff, Color("#ab9fc4"), 4.5, 9003)
	var chim := _pv([Vector2(334, 236), Vector2(336, 78), Vector2(384, 74), Vector2(388, 236)])
	_pfill(c, chim, grout, 9010)
	_stones_in(c, chim, greys, 9011, 28.0, 22.0, Color("#a8928b"))
	Crayon.pencil_line(c, chim, Color("#a8928b"), 5.0, 9012)
	_pen(c, Crayon.rounded_rect(Rect2(326, 62, 68, 18), 5), Color("#c9b6b0"), 9013, 4.5)
	var body := _pv([Vector2(92, 470), Vector2(94, 256), Vector2(418, 254), Vector2(420, 470)])
	_pfill(c, body, grout, 9020)
	_stones_in(c, body, greys, 9021, 52.0, 38.0, Color("#a8928b"))
	_shade(c, body, greys[0], 9022, Vector2(-40, 0), 0.1)
	Crayon.pencil_line(c, body, Color("#a8928b"), 6.0, 9023)
	var slate := Color("#aaa3cc")
	var roof := _pv([Vector2(60, 278), Vector2(140, 140), Vector2(372, 140), Vector2(452, 278)])
	_mark(c, roof, slate, 9030, 7.0)
	for r in 4:
		var y := 166.0 + r * 27.0
		var f := (y - 140.0) / 138.0
		var x0 := lerpf(140.0, 60.0, f) + 6.0
		var x1 := lerpf(372.0, 452.0, f) - 6.0
		var n := roundi((x1 - x0) / 38.0)
		var w := (x1 - x0) / n
		var path := PackedVector2Array()
		for k in n:
			for j in 6:
				path.append(Vector2(x0 + (k + j / 5.0) * w, y + sin(j / 5.0 * PI) * 9.0))
		_pline(c, path, slate.darkened(0.25), 3.0, 9031 + r)
	_pen(c, Crayon.rounded_rect(Rect2(132, 128, 248, 22), 7), slate.darkened(0.06), 9040, 5.0)
	_pline(c, _pv([Vector2(74, 270), Vector2(144, 148)]), Color("#d6d1ec"), 4.0, 9041)
	var arch_col := Color("#e6d7cc")
	var frame := _arch(256, 470, 76, 390)
	_pen(c, frame, arch_col, 9050, 5.0)
	for i in 9:
		var a := PI + PI * i / 8.0
		var d := Vector2(cos(a), sin(a))
		_pline(c, _pv([Vector2(256, 390) + d * 56.0, Vector2(256, 390) + d * 76.0]), arch_col.darkened(0.3), 3.0, 9051 + i)
	var door := _arch(256, 470, 56, 390)
	_door(c, door, Color("#e88a62"), 9060, Vector2(290, 424))
	var iron := Color("#b3abc9")
	for y in [372.0, 444.0]:
		var strap := Crayon.rounded_rect(Rect2(202, y, 108, 12), 4)
		for piece in Geometry2D.intersect_polygons(strap, door):
			_mark(c, piece, iron, 9065 + int(y), 3.0)
	_lit_window(c, _circle(Vector2(256, 360), 13.0, 16), iron, 9070, true, 5.0)
	for x in [118.0, 334.0]:
		var win := _pv([Vector2(x, 298), Vector2(x + 60, 298), Vector2(x + 60, 352), Vector2(x, 352)])
		_lit_window(c, win, Color("#c99063"), 9080 + int(x))
		_pen(c, Crayon.rounded_rect(Rect2(x - 12, 356, 84, 16), 5), arch_col, 9090 + int(x), 4.0)
	for r in [[Vector2(70, 470), Vector2(30, 20)], [Vector2(446, 470), Vector2(26, 16)], [Vector2(472, 470), Vector2(16, 10)]]:
		var at: Vector2 = r[0]
		var size: Vector2 = r[1]
		_pen(c, _arc(at, size, PI, TAU, 14), greys[3], 9100 + int(at.x), 4.0)


## Swamp: a wooden house up on tall stilts, a mossy roof, a porch with railings and a ladder
## down to the reeds, a lantern on the porch post.
static func _stilt_house(c: CanvasItem) -> void:
	var wood := Color("#d3ad80")
	var post := Color("#bf9a70")
	for x in [178.0, 334.0]:
		_pen(c, Crayon.rounded_rect(Rect2(x - 9, 300, 18, 166), 5), post.lightened(0.1), 10001 + int(x), 4.0)
	_pen(c, _band(_pv([Vector2(140, 440), Vector2(226, 320)]), 5.0), post.lightened(0.05), 10005, 3.5)
	_pen(c, _band(_pv([Vector2(372, 440), Vector2(286, 320)]), 5.0), post.lightened(0.05), 10006, 3.5)
	for x in [134.0, 378.0]:
		_pen(c, Crayon.rounded_rect(Rect2(x - 13, 296, 26, 174), 6), post, 10010 + int(x), 4.5)
		for y in [340.0, 410.0]:
			_pline(c, _pv([Vector2(x - 10, y), Vector2(x + 10, y + 2)]), post.darkened(0.3), 2.5, 10012 + int(x + y))
		_pen(c, _arc(Vector2(x, 470), Vector2(30, 10), PI, TAU, 12), Color("#a9b67e"), 10015 + int(x), 3.5)
	var wall := _pv([Vector2(130, 296), Vector2(130, 154), Vector2(256, 70), Vector2(382, 154), Vector2(382, 296)])
	_pen(c, wall, wood, 10020, 6.0)
	_plank_lines(c, wall, 24.0, wood.darkened(0.25), 2.5, 10021, false)
	_shade(c, wall, wood, 10022, Vector2(-30, 0), 0.12)
	_lit_window(c, _circle(Vector2(256, 132), 18.0, 20), Color("#9cc7b6"), 10030)
	for x in [148.0, 314.0]:
		var win := _pv([Vector2(x, 176), Vector2(x + 50, 176), Vector2(x + 50, 226), Vector2(x, 226)])
		_lit_window(c, win, Color("#9cc7b6"), 10031 + int(x))
	var door := _arch(256, 294, 40, 222, 26)
	_door(c, door, Color("#8cc2b2"), 10040, Vector2(280, 262), 20.0)
	var moss := Color("#93bd7c")
	var roof := _pv([Vector2(256, 34), Vector2(422, 164), Vector2(400, 190), Vector2(256, 78),
		Vector2(112, 190), Vector2(90, 164)])
	_mark(c, roof, moss, 10050, 7.0)
	_tile_rows(c, Vector2(256, 34), Vector2(422, 164), Vector2(256, 78), Vector2(400, 190), 1, 5,
		moss.darkened(0.25), 10051)
	_tile_rows(c, Vector2(256, 34), Vector2(90, 164), Vector2(256, 78), Vector2(112, 190), 1, 5,
		moss.darkened(0.25), 10060)
	Crayon.pencil_fill(c, Crayon.blob(Vector2(160, 130), Vector2(22, 10), 10070, 10, 0.1), Color("#c4e09a"), 10071)
	Crayon.pencil_fill(c, Crayon.blob(Vector2(352, 120), Vector2(18, 9), 10072, 10, 0.1), Color("#c4e09a"), 10073)
	_pen(c, Crayon.rounded_rect(Rect2(76, 288, 360, 22), 6), wood.darkened(0.08), 10080, 5.0)
	var rail := wood.darkened(0.04)
	for x in [84.0, 136.0, 192.0, 320.0, 376.0, 428.0]:
		_pen(c, Crayon.rounded_rect(Rect2(x - 6, 244, 12, 46), 4), rail, 10090 + int(x), 3.5)
	for seg in [[80.0, 198.0], [314.0, 432.0]]:
		var a: float = seg[0]
		var b: float = seg[1]
		_pen(c, Crayon.rounded_rect(Rect2(a, 242, b - a, 11), 4), rail, 10100 + int(a), 3.5)
		_pen(c, Crayon.rounded_rect(Rect2(a, 264, b - a, 9), 4), rail, 10101 + int(a), 3.0)
	_mark(c, Crayon.rounded_rect(Rect2(415, 210, 26, 34), 8), LIGHT, 10110, 4.0)
	_pen(c, _pv([Vector2(410, 214), Vector2(428, 196), Vector2(446, 214)]), Color("#b8afcf"), 10111, 3.5)
	_rays(c, Vector2(428, 227), Vector2(26, 26), 10.0, [PI, PI + 0.8, PI + 1.57, PI + 2.34, 0.0], Color("#f6d46a"), 10112, 4.0)
	var ladder := wood.darkened(0.12)
	for x in [224.0, 288.0]:
		_pen(c, Crayon.rounded_rect(Rect2(x - 6, 300, 12, 170), 4), ladder, 10120 + int(x), 3.5)
	for i in 5:
		_pen(c, Crayon.rounded_rect(Rect2(226, 326 + i * 30.0, 60, 9), 3), ladder.lightened(0.06), 10130 + i, 3.0)
	_reeds(c, Vector2(70, 470), 1.0, 10140)
	_reeds(c, Vector2(448, 470), 0.85, 10150)


## Cloud Kingdom: a little castle built of puffy clouds - three towers with pastel cone roofs
## and flags, a rainbow over a pink door.
static func _cloud_castle(c: CanvasItem) -> void:
	_flag(c, Vector2(256, 62), Color("#f6cf5c"), 11001)
	_mark(c, _pv([Vector2(184, 156), Vector2(256, 58), Vector2(328, 156)]), Color("#a8dec8"), 11005, 6.0)
	var mid := _puffy(Rect2(200, 150, 112, 176), 22.0, 11010)
	_cloud_pen(c, mid, 11011)
	_lit_window(c, _arch(256, 214, 18, 186), Color("#e5b8d6"), 11012, false)
	var roofs := [Color("#f5b2cb"), Color("#c8b5ef")]
	var flags := [Color("#8fd6dc"), Color("#f6a7c4")]
	for side in 2:
		var x := 112.0 if side == 0 else 400.0
		_flag(c, Vector2(x, 104), flags[side], 11020 + side * 10)
		var tower := _puffy(Rect2(x - 44, 196, 88, 264), 22.0, 11021 + side * 10)
		_cloud_pen(c, tower, 11022 + side * 10)
		_mark(c, _pv([Vector2(x - 58, 200), Vector2(x, 100), Vector2(x + 58, 200)]), roofs[side], 11023 + side * 10, 6.0)
		_lit_window(c, _arch(x, 290, 17, 262), Color("#e5b8d6"), 11024 + side * 10, false)
	var keep := _puffy(Rect2(152, 274, 208, 190), 24.0, 11040)
	_cloud_pen(c, keep, 11041)
	var base := _ground_cut(_circles([Vector3(60, 452, 36), Vector3(118, 436, 46), Vector3(190, 448, 40),
		Vector3(322, 448, 40), Vector3(394, 436, 46), Vector3(452, 452, 36), Vector3(256, 460, 40)]))
	_cloud_pen(c, base, 11050)
	var ctr := Vector2(256, 394)
	var bands := [Color("#f6a7b8"), Color("#f8d36e"), Color("#9fdcc0"), Color("#9cc4f0")]
	for i in 4:
		var r_out := 96.0 - i * 9.0
		_mark(c, _annulus(ctr, r_out, r_out - 9.0, PI, TAU), bands[i], 11060 + i, 2.5)
	var door := _arch(256, 470, 58, 394)
	_door(c, door, Color("#f4b5cc"), 11070, Vector2(286, 430), 0.0)
	_mark(c, Crayon.heart(Vector2(256, 372), 26.0), Color("#fbe3ec"), 11075, 3.0)
	for s in [Vector2(160, 150), Vector2(354, 160), Vector2(60, 300), Vector2(460, 290)]:
		_twinkle(c, s, 13.0, Color("#e2b45a"), 11080 + int(s.x), Color("#fbe8a2"))


## The Moon: a round silver dome on little feet, a yellow hatch door with a ramp, portholes and
## an antenna with a dish.
static func _moon_base(c: CanvasItem) -> void:
	var silver := Color("#c9cbe4")
	_pen(c, _band(_pv([Vector2(256, 196), Vector2(256, 92)]), 5.0), silver, 12001, 3.5)
	for y in [130.0, 160.0]:
		_pen(c, Crayon.rounded_rect(Rect2(240, y, 32, 8), 3), silver.darkened(0.05), 12002 + int(y), 3.0)
	_rays(c, Vector2(256, 78), Vector2(20, 20), 12.0, [PI + 0.5, PI + 1.57, PI + 2.64, 0.0, PI], Color("#f39ab6"), 12005, 4.0)
	_mark(c, _circle(Vector2(256, 78), 14.0, 16), Color("#f49ab8"), 12006, 4.0)
	c.draw_circle(Vector2(251, 73), 4.0, Color(1, 1, 1, 0.85))
	for x in [104.0, 186.0, 326.0, 408.0]:
		_pen(c, _band(_pv([Vector2(x, 436), Vector2(x + (x - 256.0) * 0.08, 462)]), 6.0), silver, 12010 + int(x), 3.5)
		_mark(c, Crayon.ellipse(Vector2(x + (x - 256.0) * 0.08, 464), Vector2(18, 7), 14), silver.darkened(0.05), 12011 + int(x), 3.5)
	var shell := Color("#e2e6f8")
	var dome := PackedVector2Array()
	dome.append_array(_arc(Vector2(256, 418), Vector2(190, 224), PI, TAU, 48))
	_pfill(c, dome, shell, 12020)
	_clip_fill(c, _pv([Vector2(40, 376), Vector2(472, 376), Vector2(472, 398), Vector2(40, 398)]), dome,
		Color("#f4a3b8"), 12021)
	for phi in [-0.95, -0.5, 0.5, 0.95]:
		var meridian := PackedVector2Array()
		for i in 13:
			var lat := PI / 2.0 * i / 12.0
			meridian.append(Vector2(256 + 190.0 * cos(lat) * sin(phi), 418 - 224.0 * sin(lat)))
		_pline(c, meridian.slice(0, 11), shell.darkened(0.18), 3.0, 12022 + int(phi * 10))
	for lat in [0.62, 1.05]:
		var hw := 190.0 * cos(lat)
		var y := 418.0 - 224.0 * sin(lat)
		_pline(c, _pv([Vector2(256 - hw + 4, y), Vector2(256, y + 6), Vector2(256 + hw - 4, y)]), shell.darkened(0.18), 3.0,
			12030 + int(lat * 10))
	_shade(c, dome, shell, 12035, Vector2(-40, 0), 0.1)
	_gleam(c, dome, 12036, Vector2(26, 30), 0.5)
	Crayon.pencil_line(c, dome, Color("#9599c8"), 6.0, 12037)
	var dish_at := Vector2(352, 236)
	_pen(c, _band(_pv([Vector2(338, 262), dish_at]), 4.0), silver, 12040, 3.0)
	var bowl := PackedVector2Array()
	bowl.append_array(_arc(Vector2.ZERO, Vector2(34, 18), 0.0, PI, 14))
	var dish := PackedVector2Array()
	for p in bowl:
		dish.append(dish_at + Vector2(0, -6) + p.rotated(-0.6))
	_pen(c, dish, Color("#dfe1f2"), 12041, 4.0)
	_pline(c, _pv([dish_at + Vector2(-2, -12), dish_at + Vector2(-14, -38)]), silver.darkened(0.2), 3.0, 12042)
	c.draw_circle(dish_at + Vector2(-14, -40), 4.5, Color("#f49ab8"))
	_mark(c, Crayon.star(Vector2(176, 262), 18.0, 12045), Color("#f6d47a"), 12046, 3.5)
	_pen(c, Crayon.rounded_rect(Rect2(54, 398, 404, 44), 18), silver, 12050, 5.5)
	for i in 9:
		c.draw_circle(Vector2(84 + i * 43.0, 420), 4.0, silver.darkened(0.2))
	for x in [126.0, 386.0]:
		_lit_window(c, _circle(Vector2(x, 334), 26.0, 26), silver, 12060 + int(x))
	var hatch := Crayon.rounded_rect(Rect2(204, 256, 104, 186), 48)
	_pen(c, Crayon.rounded_rect(Rect2(194, 246, 124, 200), 56), silver, 12070, 5.0)
	_pen(c, hatch, Color("#f5d176"), 12071, 5.0)
	_shade(c, hatch, Color("#f5d176"), 12072, Vector2(-16, 0), 0.12)
	_lit_window(c, _circle(Vector2(256, 308), 22.0, 24), silver, 12073)
	var wheel := Vector2(256, 384)
	Crayon.marker_line(c, _circle(wheel, 18.0, 18), Color("#b49237"), 5.0, 12074)
	for k in 4:
		var a := k * PI / 4.0
		_pline(c, _pv([wheel + Vector2(cos(a), sin(a)) * 18.0, wheel - Vector2(cos(a), sin(a)) * 18.0]), Color("#b49237"), 3.5,
			12075 + k)
	c.draw_circle(wheel, 5.0, Color("#e9bf4f"))
	var ramp := _pv([Vector2(210, 440), Vector2(302, 440), Vector2(326, 470), Vector2(186, 470)])
	_pen(c, ramp, silver.lightened(0.1), 12080, 4.5)
	for y in [450.0, 461.0]:
		_pline(c, _pv([Vector2(200, y), Vector2(312, y)]), silver.darkened(0.15), 2.5, 12081 + int(y))
	for r in [[Vector2(70, 470), Vector2(36, 18)], [Vector2(450, 470), Vector2(30, 14)]]:
		var at: Vector2 = r[0]
		var size: Vector2 = r[1]
		_pen(c, _arc(at, size, PI, TAU, 14), Color("#cdc8e0"), 12090 + int(at.x), 4.0)


## Castle: a square sandstone keep, battlements on top, a flag flying, an oak door in a stone
## arch, arched windows lit inside, ivy climbing one side.
static func _castle_keep(c: CanvasItem) -> void:
	var stone := Color("#e6d4b9")
	_pen(c, _band(_pv([Vector2(256, 104), Vector2(256, 14)]), 4.0), Color("#c9a37a"), 13001, 3.0)
	var flag := PackedVector2Array()
	for i in 11:
		var t := i / 10.0
		flag.append(Vector2(260 + t * 92.0, 18 + sin(t * TAU) * 6.0))
	for i in 11:
		var t := 1.0 - i / 10.0
		flag.append(Vector2(260 + t * 92.0, 62 + sin(t * TAU) * 6.0 - t * 4.0))
	_mark(c, flag, Color("#ec7a86"), 13002, 5.0)
	_mark(c, Crayon.star(Vector2(300, 38), 12.0, 13003), Color("#f7d867"), 13004, 3.0)
	var body := _pv([Vector2(116, 470), Vector2(124, 140), Vector2(388, 138), Vector2(396, 470)])
	_pen(c, body, stone, 13010, 6.0)
	_blocks(c, body, 34.0, 62.0, stone.darkened(0.2), 13011)
	_shade(c, body, stone, 13012, Vector2(-40, 0), 0.12)
	Crayon.pencil_line(c, body, stone.darkened(0.45), 6.0, 13013)
	var top := _crenellated(98, 414, 104, 34, 7, 142)
	_pen(c, top, stone.lightened(0.04), 13020, 6.0)
	_shade(c, top, stone, 13021, Vector2(-30, 0), 0.12)
	_pen(c, Crayon.rounded_rect(Rect2(102, 130, 308, 22), 5), stone.darkened(0.05), 13022, 5.0)
	for i in 10:
		var x := 118.0 + i * 31.0
		_pen(c, _pv([Vector2(x, 152), Vector2(x + 20, 152), Vector2(x + 14, 166), Vector2(x + 6, 166)]),
			stone.darkened(0.05), 13023 + i, 3.0)
	_lit_window(c, _arch(256, 266, 26, 214), Color("#c99063"), 13040)
	for x in [168.0, 344.0]:
		_lit_window(c, _arch(x, 300, 13, 236), Color("#c99063"), 13041 + int(x), false)
	var light_stone := Color("#f1e6d4")
	var frame := _arch(256, 470, 80, 384)
	_pen(c, frame, light_stone, 13050, 5.0)
	for i in 9:
		var a := PI + PI * i / 8.0
		var d := Vector2(cos(a), sin(a))
		_pline(c, _pv([Vector2(256, 384) + d * 60.0, Vector2(256, 384) + d * 80.0]), light_stone.darkened(0.3), 3.0, 13051 + i)
	var door := _arch(256, 470, 60, 384)
	_door(c, door, Color("#cf9566"), 13060, Vector2(296, 426), 24.0)
	var iron := Color("#b1aac8")
	for y in [362.0, 440.0]:
		for piece in Geometry2D.intersect_polygons(Crayon.rounded_rect(Rect2(196, y, 120, 12), 4), door):
			_mark(c, piece, iron, 13065 + int(y), 3.0)
	Crayon.marker_line(c, _circle(Vector2(256, 410), 13.0, 14), iron.darkened(0.2), 4.0, 13070)
	var ivy := Color("#8cc46e")
	var vine := _bez(Vector2(128, 470), Vector2(170, 400), Vector2(110, 330), Vector2(150, 250), 16)
	_pline(c, vine, ivy.darkened(0.25), 4.0, 13080)
	for i in 9:
		var p := _at(vine, 18.0 + i * 26.0)
		var side := 1.0 if i % 2 == 0 else -1.0
		_pen(c, _leaf(p + Vector2(side * 12, -4), 26.0, 18.0, -PI / 2.0 + side * 0.9), ivy, 13081 + i, 3.0)
	_tuft(c, Vector2(116, 470), 13095, 0.9)
	_tuft(c, Vector2(398, 470), 13096, 0.9)
	_tuft(c, Vector2(160, 470), 13097, 0.7)


## Candy Land: a gingerbread house with a pink-iced roof dripping white icing, sweets along
## the roof, a peppermint in the gable and candy-cane posts arching over a mint door.
static func _gingerbread(c: CanvasItem) -> void:
	var ginger := Color("#dca46b")
	var icing := Color("#fdf7f4")
	var icing_line := Color("#d7c4c4")
	var chim := _pv([Vector2(326, 236), Vector2(328, 104), Vector2(370, 102), Vector2(374, 236)])
	_pen(c, chim, ginger, 14001, 5.0)
	_pen(c, _circles([Vector3(334, 98, 12), Vector3(352, 92, 14), Vector3(368, 98, 12)]), icing, 14002, 3.5)
	_gumdrop(c, Vector2(350, 84), 14.0, Color("#9fdcae"), 14003)
	var wall := _pv([Vector2(98, 470), Vector2(100, 282), Vector2(256, 138), Vector2(412, 278), Vector2(414, 470)])
	_pen(c, wall, ginger, 14010, 6.0)
	_shade(c, wall, ginger, 14011, Vector2(-34, 0), 0.12)
	for i in 14:
		var x := 112.0 + i * 22.0
		if x > 186.0 and x < 326.0:
			continue
		c.draw_circle(Vector2(x, 446 + (i % 2) * 6.0), 4.0, Color("#f6a7c4") if i % 3 == 0 else icing)
	var zig := PackedVector2Array()
	for i in 15:
		zig.append(Vector2(104 + i * 21.7, 300.0 + (0.0 if i % 2 == 0 else 14.0)))
	for piece in Geometry2D.intersect_polyline_with_polygon(zig, Geometry2D.offset_polygon(wall, -8.0)[0]):
		_mline(c, piece, icing, 5.0, 14015)
	_peppermint(c, Vector2(256, 228), 30.0, 14020)
	for x in [140.0, 372.0]:
		var win := _circle(Vector2(x, 360), 28.0, 26)
		_lit_window(c, win, Color("#f4a9c4"), 14030 + int(x))
	var door := _arch(256, 470, 52, 374)
	_door(c, door, Color("#9cd9c0"), 14040, Vector2(-1, -1), 0.0)
	Crayon.marker_line(c, door, icing, 5.0, 14041)
	_mark(c, Crayon.heart(Vector2(256, 376), 30.0), Color("#f6a7c4"), 14042, 3.5)
	_gumdrop(c, Vector2(284, 432), 11.0, Color("#f6a7c4"), 14043)
	for side in 2:
		var s := -1.0 if side == 0 else 1.0
		var x := 256.0 + s * 70.0
		_candy_cane(c, _cane_path(Vector2(x, 466), 334.0, 16.0, -s), 8.0, 14050 + side * 40)
	var pink := Color("#f4a9c4")
	var roof := _pv([Vector2(256, 70), Vector2(474, 300), Vector2(444, 330), Vector2(256, 130),
		Vector2(68, 330), Vector2(38, 300)])
	_mark(c, roof, pink, 14100, 7.5)
	_icing_edge(c, Vector2(66, 326), Vector2(256, 126), icing, icing_line, 14110)
	_icing_edge(c, Vector2(256, 126), Vector2(446, 326), icing, icing_line, 14130)
	_pline(c, _pv([Vector2(52, 298), Vector2(256, 84), Vector2(460, 298)]), Color("#fbd0df"), 4.0, 14150)
	var sweets := [0.18, 0.42, 0.66, 0.88]
	for side in 2:
		var o0 := Vector2(256, 70)
		var o1 := Vector2(38, 300) if side == 0 else Vector2(474, 300)
		var i1 := Vector2(68, 330) if side == 0 else Vector2(444, 330)
		for k in sweets.size():
			var t: float = sweets[k]
			var at := o0.lerp(o1, t).lerp(Vector2(256, 130).lerp(i1, t), 0.45)
			if (k + side) % 2 == 0:
				_gumdrop(c, at + Vector2(0, 6), 15.0, [Color("#9fdcae"), Color("#f7d65c"), Color("#b9a2ea")][(k + side) % 3],
					14160 + side * 10 + k)
			else:
				_peppermint(c, at, 14.0, 14180 + side * 10 + k)
	_gumdrop(c, Vector2(256, 72), 18.0, Color("#f28aa0"), 14200)
	for g in [[Vector2(78, 470), Color("#9fdcae")], [Vector2(112, 470), Color("#f6a7c4")], [Vector2(400, 470), Color("#f7d65c")],
			[Vector2(434, 470), Color("#b9a2ea")]]:
		_gumdrop(c, g[0] + Vector2(0, -2), 16.0, g[1], 14210 + int((g[0] as Vector2).x))


# --- Decorations -----------------------------------------------------------------------------

## A red mailbox on a wooden post, its yellow flag up, a heart on the side.
static func _mailbox(c: CanvasItem) -> void:
	var wood := Color("#c99a6c")
	_pen(c, Crayon.rounded_rect(Rect2(238, 290, 34, 180), 5), wood, 21001, 5.0)
	_shade(c, Crayon.rounded_rect(Rect2(238, 290, 34, 180), 5), wood, 21002, Vector2(-10, 0), 0.16)
	_pen(c, Crayon.rounded_rect(Rect2(178, 296, 176, 18), 5), wood.darkened(0.06), 21003, 4.5)
	var red := Color("#e8655f")
	var yellow := Color("#f6cf5c")
	_pen(c, _band(_pv([Vector2(352, 286), Vector2(352, 166)]), 6.0), yellow.darkened(0.1), 21010, 3.5)
	_mark(c, _pv([Vector2(352, 162), Vector2(406, 168), Vector2(404, 198), Vector2(352, 194)]), yellow, 21011, 4.5)
	var side := _top_round(Rect2(194, 186, 176, 114), 56)
	_mark(c, side, red, 21020, 7.0)
	_gleam(c, side, 21021, Vector2(0, 18), 0.3)
	_mark(c, Crayon.heart(Vector2(298, 246), 30.0), Color("#fbd3d0"), 21022, 3.5)
	var face := _arch(190, 300, 50, 236)
	_mark(c, face, red.lightened(0.1), 21030, 6.5)
	_pline(c, _arch(190, 292, 38, 238), red.darkened(0.25), 3.0, 21031)
	_mark(c, Crayon.rounded_rect(Rect2(176, 228, 28, 12), 5), Color("#e9e6f0"), 21032, 3.5)
	_tuft(c, Vector2(232, 470), 21040, 0.9)
	_tuft(c, Vector2(282, 470), 21041, 0.8)


## A little toadstool to sit on: a fat cream stem, a red cap with white spots.
static func _mushroom_stool(c: CanvasItem) -> void:
	var stem_col := Color("#f3e5c9")
	var stem := _smooth(_pv([Vector2(196, 470), Vector2(198, 466), Vector2(208, 410), Vector2(214, 350),
		Vector2(298, 350), Vector2(304, 410), Vector2(314, 466), Vector2(316, 470), Vector2(256, 470)]), 2)
	_pen(c, stem, stem_col, 22001, 5.5)
	_shade(c, stem, stem_col, 22002, Vector2(-22, 0), 0.12)
	var under := Crayon.ellipse(Vector2(256, 344), Vector2(140, 22), 32)
	_pen(c, under, Color("#ecd5b6"), 22003, 4.0)
	var red := Color("#e66a5c")
	var cap := PackedVector2Array()
	cap.append_array(_arc(Vector2(256, 336), Vector2(160, 112), PI, TAU, 36))
	cap.append_array(_arc(Vector2(256, 336), Vector2(160, 12), 0.0, PI, 18).slice(1, 18))
	_pen(c, cap, red, 22010, 6.0)
	var spot_col := Color("#fcf4ea")
	for i in 6:
		var v: Vector3 = [Vector3(190, 290, 24), Vector3(270, 250, 28), Vector3(344, 298, 20), Vector3(234, 322, 13),
			Vector3(116, 326, 12), Vector3(392, 324, 11)][i]
		var blob := _smooth(Crayon.blob(Vector2(v.x, v.y), Vector2(v.z, v.z * 0.8), 22020 + i, 12, 0.12), 2)
		for piece in Geometry2D.intersect_polygons(blob, cap):
			if piece.size() >= 3:
				_pfill(c, piece, spot_col, 22030 + i)
				Crayon.pencil_line(c, piece, Color("#efc8bd"), 3.0, 22040 + i)
	_shade(c, cap, red, 22050, Vector2(-30, -20), 0.14)
	_gleam(c, cap, 22051, Vector2(16, 18), 0.32)
	Crayon.pencil_line(c, cap, red.darkened(0.45), 6.0, 22052)
	_tuft(c, Vector2(196, 470), 22060, 0.8)
	_tuft(c, Vector2(318, 470), 22061, 0.8)


## A log bench: a fat log seat resting on two stumps, a sprout growing from it.
static func _log_bench(c: CanvasItem) -> void:
	var bark := Color("#c69a6c")
	var ring := Color("#efd5a8")
	for x in [146.0, 366.0]:
		var side := _drum_side(Vector2(x, 384), Vector2(48, 14), Vector2(x, 466), Vector2(52, 12))
		_pen(c, side, bark.darkened(0.05), 23001 + int(x), 5.0)
		for k in 3:
			var dx := -26.0 + k * 26.0
			_pline(c, _pv([Vector2(x + dx, 404), Vector2(x + dx + 2, 456)]), bark.darkened(0.3), 2.5, 23002 + int(x) + k)
	var seat := _capsule(Vector2(96, 342), Vector2(400, 342), 40.0)
	_pen(c, seat, bark, 23010, 5.5)
	_shade(c, seat, bark, 23011, Vector2(0, -16), 0.16)
	for i in 6:
		var x := 128.0 + i * 46.0
		var y := 326.0 + Crayon.noise(23012, i) * 16.0
		_pline(c, _pv([Vector2(x, y), Vector2(x + 30, y + 3)]), bark.darkened(0.3), 3.0, 23013 + i)
	_pline(c, _pv([Vector2(110, 308), Vector2(390, 306)]), Color("#e2c093"), 4.0, 23020)
	var face := Crayon.ellipse(Vector2(404, 342), Vector2(22, 38), 24)
	_pen(c, face, ring, 23021, 4.5)
	_pline(c, Crayon.ellipse(Vector2(404, 342), Vector2(13, 24), 18), Color("#d4ae7a"), 2.5, 23022)
	_pline(c, Crayon.ellipse(Vector2(404, 342), Vector2(5, 10), 12), Color("#d4ae7a"), 2.5, 23023)
	_pline(c, _pv([Vector2(170, 304), Vector2(166, 270)]), Color("#7fbf6a").darkened(0.15), 4.0, 23030)
	_pen(c, _leaf(Vector2(152, 268), 34.0, 16.0, -2.6), Color("#8cc96c"), 23031, 3.0)
	_pen(c, _leaf(Vector2(182, 262), 34.0, 16.0, -0.6), Color("#8cc96c"), 23032, 3.0)
	_tuft(c, Vector2(100, 470), 23040, 0.8)
	_tuft(c, Vector2(412, 470), 23041, 0.8)


## A sandcastle on a heap of sand: three towers, a doorway, shells and a tiny pink flag.
static func _sandcastle(c: CanvasItem) -> void:
	var sand := Color("#efcf94")
	_pen(c, _arc(Vector2(256, 470), Vector2(214, 40), PI, TAU, 28), sand.lightened(0.05), 24001, 5.0)
	_pen(c, _band(_pv([Vector2(256, 214), Vector2(256, 120)]), 3.0), Color("#c9a37a"), 24002, 3.0)
	_mark(c, _pv([Vector2(259, 122), Vector2(304, 134), Vector2(259, 148)]), Color("#f39ab6"), 24003, 4.0)
	var mid := _crenellated(206, 306, 224, 18, 5, 360)
	_pen(c, mid, sand, 24010, 5.5)
	_shade(c, mid, sand, 24011, Vector2(-18, 0), 0.12)
	var wall := _crenellated(134, 378, 330, 16, 9, 452)
	_pen(c, wall, sand, 24020, 5.5)
	_shade(c, wall, sand, 24021, Vector2(-30, 0), 0.12)
	for x in [116.0, 396.0]:
		var tower := _crenellated(x - 38, x + 38, 286, 18, 5, 454)
		_pen(c, tower, sand.lightened(0.03), 24030 + int(x), 5.5)
		_shade(c, tower, sand, 24031 + int(x), Vector2(-16, 0), 0.12)
		_pen(c, _arch(x, 344, 9, 330), INSIDE, 24032 + int(x), 3.0)
		for k in 2:
			_pline(c, _pv([Vector2(x - 30, 400 + k * 26.0), Vector2(x + 30, 401 + k * 26.0)]), sand.darkened(0.2), 2.5,
				24033 + int(x) + k)
	_pen(c, _arch(256, 300, 12, 284), INSIDE, 24040, 3.0)
	var door := _arch(256, 452, 32, 412)
	_pen(c, door, INSIDE, 24041, 4.0)
	_shade(c, door, INSIDE, 24042, Vector2(0, 14), 0.1)
	for i in 5:
		var at := Vector2(170 + i * 40.0, 368 + (i % 2) * 14.0)
		if absf(at.x - 256.0) < 40.0:
			continue
		c.draw_circle(at, 4.0, sand.darkened(0.15))
	_pen(c, _shell_shape(Vector2(166, 458), 15.0), Color("#f6b8bd"), 24050, 3.0)
	_mark(c, Crayon.star(Vector2(352, 456), 15.0, 24051), Color("#f59a7f"), 24052, 3.0)
	_pen(c, _shell_shape(Vector2(222, 404), 10.0), Color("#fbe3d0"), 24053, 2.5)


## A chair shaped like a scallop shell: a ribbed pink fan for a back, a plump aqua cushion,
## little pearly feet.
static func _seashell_chair(c: CanvasItem) -> void:
	var pearl := Color("#e7dcf3")
	for x in [170.0, 342.0]:
		_mark(c, _circle(Vector2(x, 450), 20.0, 18), pearl, 24501 + int(x), 4.0)
	var hinge := Vector2(256, 404)
	var ribs := 9
	var a0 := PI + 0.22
	var a1 := TAU - 0.22
	var fan := PackedVector2Array([hinge + Vector2(-34, 10)])
	for k in ribs:
		for j in 7:
			var u := j / 6.0
			var a := lerpf(a0, a1, (k + u) / ribs)
			var r := 196.0 + sin(u * PI) * 14.0
			fan.append(hinge + Vector2(cos(a) * r, sin(a) * r * 0.98))
	fan.append(hinge + Vector2(34, 10))
	var pink := Color("#f6b3b8")
	var peach := Color("#f9ccb4")
	_pfill(c, fan, peach, 24510)
	for k in ribs:
		if k % 2 == 1:
			continue
		var wedge := PackedVector2Array([hinge])
		for j in 7:
			var a := lerpf(a0, a1, (k + j / 6.0) / ribs)
			wedge.append(hinge + Vector2(cos(a), sin(a)) * 240.0)
		_clip_fill(c, wedge, fan, pink, 24520 + k, false)
	for k in range(1, ribs):
		var a := lerpf(a0, a1, float(k) / ribs)
		_pline(c, _pv([hinge + Vector2(cos(a), sin(a)) * 40.0, hinge + Vector2(cos(a), sin(a)) * 194.0]), pink.darkened(0.3),
			3.0, 24530 + k)
	_gleam(c, fan, 24540, Vector2(20, 24), 0.35)
	Crayon.pencil_line(c, fan, pink.darkened(0.45), 5.5, 24541)
	var base := Crayon.rounded_rect(Rect2(132, 404, 248, 44), 18)
	_pen(c, base, peach.darkened(0.05), 24550, 5.0)
	var cushion := _smooth(_pv([Vector2(128, 404), Vector2(150, 370), Vector2(256, 360), Vector2(362, 370),
		Vector2(384, 404), Vector2(362, 426), Vector2(256, 432), Vector2(150, 426)]), 2)
	var aqua := Color("#8fd3cf")
	_pen(c, cushion, aqua, 24560, 5.0)
	_gleam(c, cushion, 24561, Vector2(10, 14), 0.4)
	_pline(c, _arc(Vector2(256, 396), Vector2(90, 14), 0.3, PI - 0.3, 12), aqua.darkened(0.25), 3.0, 24562)
	c.draw_circle(Vector2(256, 398), 6.0, Color("#fdfbff"))


## A soft heap of snow, a couple of snowballs in front and one on top.
static func _snow_pile(c: CanvasItem) -> void:
	var pile := _ground_cut(_circles([Vector3(256, 432, 112), Vector3(150, 446, 72), Vector3(362, 446, 76),
		Vector3(206, 374, 72), Vector3(304, 378, 66), Vector3(96, 462, 40), Vector3(420, 462, 40)]))
	_pen(c, pile, SNOW, 26001, 5.5)
	_shade(c, pile, Color("#c9d6f0"), 26002, Vector2(-34, -24), 0.0)
	_gleam(c, pile, 26003, Vector2(20, 24), 0.55)
	Crayon.pencil_line(c, pile, Color("#8f9fc8"), 5.5, 26004)
	for b in [Vector3(262, 296, 34), Vector3(170, 448, 26), Vector3(352, 444, 30), Vector3(400, 458, 16)]:
		var v: Vector3 = b
		var ball := Crayon.blob(Vector2(v.x, v.y), Vector2(v.z, v.z * 0.94), 26010 + int(v.x), 18, 0.04)
		_pfill(c, ball, SNOW, 26020 + int(v.x))
		_shade(c, ball, Color("#c9d6f0"), 26030 + int(v.x), Vector2(-v.z * 0.4, -v.z * 0.4), 0.0)
		Crayon.pencil_line(c, ball, Color("#8f9fc8"), 4.5, 26040 + int(v.x))
		c.draw_circle(Vector2(v.x - v.z * 0.35, v.y - v.z * 0.35), v.z * 0.15, Color(1, 1, 1, 0.9))
	_twinkle(c, Vector2(150, 360), 12.0, Color("#9fb6e0"), 26050)
	_twinkle(c, Vector2(380, 340), 10.0, Color("#9fb6e0"), 26051)


## A glowing crystal cluster in a little stone dish on a stand, rays round it.
static func _crystal_lamp(c: CanvasItem) -> void:
	_rays(c, Vector2(256, 250), Vector2(124, 120), 26.0, [PI + 0.25, PI + 0.85, PI + 1.57, PI + 2.29, PI + 2.89, 0.35,
		PI - 0.35], Color("#f6d46a"), 27001, 6.0)
	_crystal(c, Vector2(196, 342), 112.0, 46.0, -0.62, Color("#f4a8c8"), 27010)
	_crystal(c, Vector2(318, 342), 120.0, 48.0, 0.58, Color("#b9a6f0"), 27020)
	_crystal(c, Vector2(232, 346), 176.0, 66.0, -0.2, Color("#97dce4"), 27030)
	_crystal(c, Vector2(284, 350), 136.0, 54.0, 0.22, Color("#c4b2f2"), 27035)
	var stone := Color("#c6bcdc")
	var dish := PackedVector2Array()
	dish.append_array(_arc(Vector2(256, 336), Vector2(104, 66), 0.0, PI, 24))
	_pen(c, dish, stone, 27040, 5.0)
	_shade(c, dish, stone, 27041, Vector2(-20, -10), 0.12)
	_pen(c, Crayon.ellipse(Vector2(256, 338), Vector2(106, 14), 28), stone.lightened(0.15), 27042, 4.5)
	_pen(c, Crayon.rounded_rect(Rect2(234, 398, 44, 44), 6), stone.darkened(0.04), 27043, 4.5)
	_pen(c, _top_round(Rect2(190, 436, 132, 34), 14), stone, 27044, 5.0)
	_twinkle(c, Vector2(164, 196), 13.0, Color("#e2b45a"), 27050, Color("#fbe8a2"))
	_twinkle(c, Vector2(352, 168), 10.0, Color("#e2b45a"), 27051, Color("#fbe8a2"))


## A round paper lantern hanging from a short shepherd's-hook pole, glowing warm yellow.
static func _lantern(c: CanvasItem) -> void:
	var wood := Color("#c99a6c")
	var hook := PackedVector2Array([Vector2(196, 466), Vector2(196, 150)])
	hook.append_array(_arc(Vector2(234, 150), Vector2(38, 38), PI, TAU, 12).slice(1))
	hook.append(Vector2(272, 168))
	_pen(c, _band(hook, 7.0), wood, 28001, 4.5)
	_pen(c, Crayon.rounded_rect(Rect2(170, 454, 52, 16), 5), wood.darkened(0.06), 28002, 4.0)
	_pline(c, _pv([Vector2(272, 168), Vector2(272, 196)]), Color("#b99a72"), 3.0, 28003)
	var ctr := Vector2(272, 278)
	_rays(c, ctr, Vector2(84, 96), 22.0, [PI + 0.4, PI + 1.1, -0.6, -0.1, 0.5, PI - 0.5, PI + 0.0, 1.2, PI - 1.2],
		Color("#f6d46a"), 28010, 6.0)
	var body := Crayon.ellipse(ctr, Vector2(66, 78), 36)
	var orange := Color("#f6a866")
	_pen(c, body, orange, 28020, 5.5)
	Crayon.pencil_fill(c, Crayon.blob(ctr + Vector2(-6, 4), Vector2(38, 50), 28021, 16, 0.05), Color("#fde8a0"), 28022)
	for k in 5:
		var y := -56.0 + k * 28.0
		var hw := 66.0 * sqrt(maxf(0.0, 1.0 - pow(y / 78.0, 2)))
		_pline(c, _pv([ctr + Vector2(-hw + 3, y), ctr + Vector2(0, y + 5), ctr + Vector2(hw - 3, y)]), orange.darkened(0.2), 3.0, 28023 + k)
	_pline(c, _arc(ctr, Vector2(30, 76), PI * 0.55, PI * 1.45, 10), orange.darkened(0.15), 2.5, 28030)
	_pline(c, _arc(ctr, Vector2(30, 76), -PI * 0.45, PI * 0.45, 10), orange.darkened(0.15), 2.5, 28031)
	var cap_col := Color("#e2b45a")
	_pen(c, Crayon.rounded_rect(Rect2(244, 192, 56, 16), 5), cap_col, 28040, 4.0)
	_pen(c, Crayon.rounded_rect(Rect2(244, 348, 56, 16), 5), cap_col, 28041, 4.0)
	_pline(c, _pv([Vector2(272, 364), Vector2(272, 392)]), Color("#e8605a"), 4.0, 28042)
	_mark(c, _pv([Vector2(264, 388), Vector2(280, 388), Vector2(286, 420), Vector2(258, 420)]), Color("#ec7a72"), 28043, 3.0)
	_tuft(c, Vector2(196, 470), 28050, 0.8)


## A big round lily pad seen low across the water, a pink water lily open on it, a bud beside.
static func _lily_pad(c: CanvasItem) -> void:
	var green := Color("#8cc96c")
	var edge := Crayon.ellipse(Vector2(256, 444), Vector2(214, 26), 48)
	_pen(c, edge, green.darkened(0.1), 29001, 5.0)
	var pad := Crayon.ellipse(Vector2(256, 434), Vector2(212, 30), 48)
	var notch := _pv([Vector2(256, 434), Vector2(340, 474), Vector2(388, 474)])
	var lily := _biggest(Geometry2D.clip_polygons(pad, notch))
	_pen(c, lily, green, 29002, 5.0)
	for k in 9:
		var a := PI * 0.1 + TAU * k / 10.0
		if a > 0.3 and a < 0.75:
			continue
		_pline(c, _pv([Vector2(256, 434) + Vector2(cos(a), sin(a)) * Vector2(30, 4),
			Vector2(256, 434) + Vector2(cos(a), sin(a)) * Vector2(180, 24)]), green.darkened(0.2), 2.5, 29010 + k)
	_gleam(c, lily, 29020, Vector2(16, 6), 0.3)
	var pink := Color("#f4a6c4")
	var at := Vector2(232, 420)
	for k in 5:
		var a := -PI / 2.0 + (k - 2) * 0.55
		_pen(c, _leaf(at + Vector2(cos(a), sin(a)) * 46.0, 96.0, 42.0, a), pink.darkened(0.05), 29030 + k, 4.0)
	for k in 4:
		var a := -PI / 2.0 + (k - 1.5) * 0.42
		_pen(c, _leaf(at + Vector2(cos(a), sin(a)) * 34.0 + Vector2(0, 6), 74.0, 38.0, a), pink.lightened(0.12), 29040 + k, 3.5)
	_pen(c, Crayon.ellipse(at + Vector2(0, -8), Vector2(22, 9), 16), Color("#f7d65c"), 29050, 3.0)
	_pen(c, _leaf(Vector2(356, 378), 64.0, 30.0, -PI / 2.0 + 0.2), pink, 29060, 3.5)
	_pline(c, _pv([Vector2(352, 410), Vector2(350, 432)]), green.darkened(0.15), 4.0, 29061)
	_pen(c, _leaf(Vector2(348, 400), 26.0, 14.0, -2.2), green, 29062, 2.5)


## A bench made of a fluffy cloud: a puffy back standing up behind a wide puffy seat, two
## puffs for legs.
static func _cloud_bench(c: CanvasItem) -> void:
	for x in [150.0, 362.0]:
		var leg := _ground_cut(_circles([Vector3(x, 412, 30), Vector3(x - 8, 446, 28), Vector3(x + 10, 450, 24)]))
		_cloud_pen(c, leg, 30010 + int(x))
	var back := _circles([Vector3(148, 236, 42), Vector3(204, 204, 52), Vector3(272, 196, 56), Vector3(340, 212, 50),
		Vector3(386, 248, 38), Vector3(256, 256, 60), Vector3(130, 276, 30), Vector3(390, 284, 28)])
	_cloud_pen(c, back, 30001)
	_mark(c, Crayon.heart(Vector2(262, 226), 30.0), Color("#f6b3cc"), 30030, 3.5)
	var seat := _circles([Vector3(104, 344, 36), Vector3(160, 326, 42), Vector3(228, 318, 44), Vector3(296, 318, 44),
		Vector3(358, 326, 42), Vector3(410, 344, 36), Vector3(256, 360, 40), Vector3(170, 364, 30), Vector3(344, 364, 30)])
	_pfill(c, seat, CLOUD, 30020)
	_shade(c, seat, Color("#cbd8f2"), 30021, Vector2(0, -26), 0.0)
	Crayon.pencil_line(c, seat, CLOUD_LINE, 5.0, 30022)
	_twinkle(c, Vector2(92, 180), 12.0, Color("#e2b45a"), 30040, Color("#fbe8a2"))
	_twinkle(c, Vector2(428, 188), 10.0, Color("#e2b45a"), 30041, Color("#fbe8a2"))


## A flag planted in a little cratered moon rock: pink with a yellow star, held out on a rod.
static func _moon_flag(c: CanvasItem) -> void:
	var silver := Color("#c9cbe4")
	_pen(c, _band(_pv([Vector2(232, 430), Vector2(232, 92)]), 6.0), silver, 31001, 3.5)
	_pen(c, _band(_pv([Vector2(232, 100), Vector2(398, 100)]), 4.0), silver, 31002, 3.0)
	_mark(c, _circle(Vector2(232, 86), 10.0, 14), Color("#f6d47a"), 31003, 3.5)
	var flag := PackedVector2Array()
	for i in 11:
		var t := i / 10.0
		flag.append(Vector2(238 + t * 158.0, 104 + sin(t * TAU * 1.5) * 4.0))
	for i in 11:
		var t := 1.0 - i / 10.0
		flag.append(Vector2(238 + t * 158.0, 210 + sin(t * TAU * 1.5 + 0.6) * 6.0))
	var pink := Color("#f39ab9")
	_mfill(c, flag, pink, 31010)
	_clip_fill(c, _pv([Vector2(230, 182), Vector2(400, 182), Vector2(400, 220), Vector2(230, 220)]), flag, Color("#b9a6f0"), 31011)
	Crayon.marker_line(c, flag, pink.darkened(0.45), 5.5, 31012)
	_mark(c, Crayon.star(Vector2(316, 146), 28.0, 31013), Color("#f7d867"), 31014, 4.0)
	var stone := Color("#cdc8e0")
	var rock := _ground_cut(Crayon.blob(Vector2(240, 460), Vector2(124, 58), 31020, 22, 0.08))
	_pen(c, rock, stone, 31021, 5.5)
	_shade(c, rock, stone, 31022, Vector2(-30, -16), 0.15)
	for v in [Vector3(170, 440, 16), Vector3(300, 434, 20), Vector3(236, 456, 10)]:
		var w: Vector3 = v
		var crater := Crayon.ellipse(Vector2(w.x, w.y), Vector2(w.z, w.z * 0.45), 16)
		_pen(c, crater, stone.darkened(0.08), 31030 + int(w.x), 3.0)
		_pline(c, _arc(Vector2(w.x, w.y + 1), Vector2(w.z * 0.8, w.z * 0.3), 0.2, PI - 0.2, 8), stone.lightened(0.3), 2.5, 31031 + int(w.x))


## A candy-cane lamp post, a glowing lemon gumdrop hanging from its hook.
static func _candy_lamp(c: CanvasItem) -> void:
	var base := _drum_side(Vector2(206, 446), Vector2(58, 14), Vector2(206, 462), Vector2(58, 14))
	_mark(c, base, Color("#f4a9c4"), 32001, 5.0)
	_mark(c, Crayon.ellipse(Vector2(206, 446), Vector2(58, 14), 24), Color("#f8c6d8"), 32002, 4.5)
	_candy_cane(c, _cane_path(Vector2(206, 450), 124.0, 50.0, 1.0), 14.0, 32010)
	_pline(c, _pv([Vector2(306, 150), Vector2(306, 194)]), Color("#c7b4b8"), 4.0, 32050)
	var ctr := Vector2(306, 216)
	_rays(c, ctr, Vector2(74, 66), 20.0, [PI + 0.3, PI - 0.3, PI + 1.0, -1.0, -0.3, 0.3, 1.0, PI - 1.0, PI / 2.0],
		Color("#f6d46a"), 32060, 6.0)
	_gumdrop(c, ctr + Vector2(0, 40), 54.0, Color("#f8d667"), 32070)
	Crayon.pencil_fill(c, Crayon.blob(ctr + Vector2(-4, 6), Vector2(26, 22), 32071, 14, 0.06), Color("#fff4c8"), 32072)


## A round hay bale lying on its side: the rolled-up spiral end towards us, twine round it.
static func _hay_bale(c: CanvasItem) -> void:
	var hay := Color("#eccb6e")
	var front := Vector2(196, 362)
	var back := Vector2(332, 350)
	var r := Vector2(98, 108)
	var body := PackedVector2Array([front + Vector2(0, -r.y)])
	body.append_array(_arc(back, r, -PI / 2.0, PI / 2.0, 20))
	body.append(front + Vector2(0, r.y))
	_pen(c, body, hay.darkened(0.04), 33001, 5.5)
	for i in 12:
		var y := 268.0 + i * 16.0
		var x0 := 214.0 + Crayon.noise(33002, i) * 10.0
		_pline(c, _pv([Vector2(x0, y), Vector2(x0 + 70, y - 4), Vector2(x0 + 150, y - 8 + Crayon.noise(33003, i) * 4.0)]),
			hay.darkened(0.25), 2.5, 33004 + i)
	_shade(c, body, hay, 33020, Vector2(0, -24), 0.15)
	for x in [262.0, 312.0]:
		var twine := _arc(Vector2(x, 356 - (x - 196) * 0.09), Vector2(30, 106), -PI / 2.0, PI / 2.0, 14)
		_pline(c, twine, Color("#c99a6c"), 5.0, 33030 + int(x))
	var face := Crayon.ellipse(front, r, 40)
	_pen(c, face, hay.lightened(0.08), 33040, 5.5)
	var spiral := PackedVector2Array()
	for i in 60:
		var t := i / 59.0
		var a := t * TAU * 3.2
		spiral.append(front + Vector2(cos(a) * r.x, sin(a) * r.y) * (0.06 + t * 0.82))
	_pline(c, spiral, hay.darkened(0.28), 3.0, 33041)
	for i in 10:
		var a := TAU * i / 10.0 + 0.2
		if sin(a) > 0.55:
			continue
		var p := front + Vector2(cos(a) * r.x, sin(a) * r.y)
		_pline(c, _pv([p, p + Vector2(cos(a + 0.4), sin(a + 0.4)) * 16.0]), hay.darkened(0.15), 3.0, 33050 + i)
	_tuft(c, Vector2(120, 470), 33060, 0.8)
	_tuft(c, Vector2(380, 470), 33061, 0.8)


# --- House parts -----------------------------------------------------------------------------

## A doorway or window shape: straight sides from `bottom` up to `spring`, a round top above.
static func _arch(cx: float, bottom: float, hw: float, spring: float, rise := -1.0) -> PackedVector2Array:
	var r := hw if rise < 0.0 else rise
	var out := PackedVector2Array([Vector2(cx - hw, bottom)])
	out.append_array(_arc(Vector2(cx, spring), Vector2(hw, r), PI, TAU, 18))
	out.append(Vector2(cx + hw, bottom))
	return out


## A rectangle with only its top corners rounded (stands flat on the ground).
static func _top_round(rect: Rect2, r: float) -> PackedVector2Array:
	var out := PackedVector2Array([Vector2(rect.position.x, rect.end.y)])
	out.append_array(_arc(rect.position + Vector2(r, r), Vector2(r, r), PI, PI * 1.5, 8))
	out.append_array(_arc(Vector2(rect.end.x - r, rect.position.y + r), Vector2(r, r), PI * 1.5, TAU, 8))
	out.append(rect.end)
	return out


## A window lit from inside: a frame round it, warm yellow glass, glazing bars, never dark.
static func _lit_window(c: CanvasItem, poly: PackedVector2Array, frame: Color, seed: int, cross := true,
		frame_w := 7.0) -> void:
	var grown := Geometry2D.offset_polygon(poly, frame_w)
	if not grown.is_empty():
		_pen(c, grown[0], frame, seed, 4.0)
	_pfill(c, poly, LIGHT, seed + 1)
	var r := Crayon.bounds(poly)
	Crayon.pencil_fill(c, Crayon.blob(r.get_center() + Vector2(-r.size.x * 0.08, r.size.y * 0.06), r.size * 0.26, seed + 2,
		12, 0.08), Color("#fff8dc"), seed + 3)
	if cross:
		var mid := r.get_center()
		var bars := [[Vector2(mid.x, r.position.y - 4), Vector2(mid.x, r.end.y + 4)],
			[Vector2(r.position.x - 4, mid.y), Vector2(r.end.x + 4, mid.y)]]
		for i in 2:
			var seg: Array = bars[i]
			for piece in Geometry2D.intersect_polyline_with_polygon(_pv(seg), poly):
				_pline(c, piece, frame.darkened(0.1), clampf(r.size.x * 0.09, 3.0, 6.0), seed + 4 + i)
	Crayon.pencil_line(c, poly, frame.darkened(0.4), 3.5, seed + 6)
	if r.size.x > 24.0:
		var a := r.position + r.size * Vector2(0.22, 0.3)
		_pline(c, _pv([a, a + Vector2(r.size.x * 0.14, -r.size.y * 0.14)]), Color(1, 1, 1, 0.85), 3.0, seed + 7)


## A door: planks, a little shading at the hinge side, a round brass knob.
static func _door(c: CanvasItem, poly: PackedVector2Array, col: Color, seed: int, knob: Vector2,
		planks := 26.0) -> void:
	_pen(c, poly, col, seed, 5.5)
	_shade(c, poly, col, seed + 1, Vector2(-14, 0), 0.14)
	if planks > 0.0:
		_plank_lines(c, poly, planks, col.darkened(0.28), 3.0, seed + 2, true)
	if knob.x < 0.0:
		return
	_mark(c, _circle(knob, 8.0, 14), Color("#f2cf62"), seed + 3, 3.5)
	c.draw_circle(knob + Vector2(-2.5, -2.5), 2.5, Color(1, 1, 1, 0.85))


## Board lines across a shape, clipped inside it - vertical for doors, horizontal for walls.
static func _plank_lines(c: CanvasItem, poly: PackedVector2Array, step: float, color: Color, width: float,
		seed: int, vertical := true) -> void:
	var inner := Geometry2D.offset_polygon(poly, -4.0)
	if inner.is_empty():
		return
	var area: PackedVector2Array = inner[0]
	var r := Crayon.bounds(poly)
	var i := 0
	var at := (r.position.x if vertical else r.position.y) + step
	var end := r.end.x if vertical else r.end.y
	while at < end - 4.0:
		var seg := _pv([Vector2(at, r.position.y - 2), Vector2(at + 1, r.end.y + 2)]) if vertical \
			else _pv([Vector2(r.position.x - 2, at), Vector2(r.end.x + 2, at + 1)])
		for piece in Geometry2D.intersect_polyline_with_polygon(seg, area):
			_pline(c, piece, color, width, seed + i)
		at += step
		i += 1


## Two rows of roof tiles: little scallops along a roof slope between its outer edge o0-o1
## and inner edge i0-i1.
static func _tile_rows(c: CanvasItem, o0: Vector2, o1: Vector2, i0: Vector2, i1: Vector2, rows: int,
		count: int, color: Color, seed: int) -> void:
	for r in rows:
		var s := (r + 1.0) / (rows + 1.0)
		var shift := 0.5 if r % 2 == 1 else 0.0
		var path := PackedVector2Array()
		for k in count + 1:
			var t0 := (k - shift) / count
			var t1 := (k + 1 - shift) / count
			for j in 6:
				var u := clampf(lerpf(t0, t1, j / 5.0), 0.04, 0.97)
				var o := o0.lerp(o1, u)
				var i := i0.lerp(i1, u)
				path.append(o.lerp(i, s) + (i - o).normalized() * sin(j / 5.0 * PI) * 9.0)
		_pline(c, path, color, 3.0, seed + r)


## Round stones packed in rows to fill `area` - stone walls and chimneys.
static func _stones_in(c: CanvasItem, area: PackedVector2Array, cols: Array, seed: int, w: float, h: float,
		outline: Color) -> void:
	var r := Crayon.bounds(area)
	var row := 0
	var y := r.position.y + h * 0.45
	while y < r.end.y + h * 0.5:
		var x := r.position.x - (0.0 if row % 2 == 0 else w * 0.5)
		var k := 0
		while x < r.end.x:
			var s := seed + row * 37 + k * 5
			var center := Vector2(x + w * 0.5 + Crayon.noise(s, 1) * w * 0.08, y + Crayon.noise(s, 2) * h * 0.08)
			var size := Vector2(w * (0.46 + 0.04 * Crayon.noise(s, 3)), h * (0.44 + 0.04 * Crayon.noise(s, 4)))
			var stone := Crayon.blob(center, size, s, 12, 0.1)
			var col: Color = cols[int(absf(Crayon.noise(s, 7)) * 97.0) % cols.size()]
			for piece in Geometry2D.intersect_polygons(stone, area):
				if piece.size() >= 3:
					_pfill(c, piece, col, s + 5)
					Crayon.pencil_line(c, piece, outline, 3.0, s + 6)
			x += w
			k += 1
		y += h
		row += 1


## Square-cut stone blocks: courses across the shape, joints staggered course by course.
static func _blocks(c: CanvasItem, area: PackedVector2Array, h: float, w: float, color: Color, seed: int) -> void:
	var inner := Geometry2D.offset_polygon(area, -5.0)
	if inner.is_empty():
		return
	var shape: PackedVector2Array = inner[0]
	var r := Crayon.bounds(area)
	var row := 0
	var y := r.position.y + h
	while y < r.end.y:
		for piece in Geometry2D.intersect_polyline_with_polygon(_pv([Vector2(r.position.x, y), Vector2(r.end.x, y + 1)]), shape):
			_pline(c, piece, color, 2.5, seed + row)
		var x := r.position.x + (w * 0.5 if row % 2 == 1 else 0.0) + w * 0.6
		var k := 0
		while x < r.end.x:
			for piece in Geometry2D.intersect_polyline_with_polygon(_pv([Vector2(x, y - h), Vector2(x, y)]), shape):
				_pline(c, piece, color, 2.5, seed + 100 + row * 13 + k)
			x += w
			k += 1
		y += h
		row += 1
	var top_y := r.position.y
	var x2 := r.position.x + w * 0.6
	while x2 < r.end.x:
		for piece in Geometry2D.intersect_polyline_with_polygon(_pv([Vector2(x2, top_y), Vector2(x2, top_y + h)]), shape):
			_pline(c, piece, color, 2.5, seed + 500 + int(x2))
		x2 += w


## The courses of snow blocks over a dome (or the tunnel), joints staggered course by course.
static func _igloo_blocks(c: CanvasItem, ctr: Vector2, rad: Vector2, rows: int, color: Color, seed: int) -> void:
	for k in range(1, rows + 1):
		var f := float(k) / (rows + 1)
		var y := ctr.y - rad.y * f
		var hw := rad.x * sqrt(1.0 - f * f) - 6.0
		if hw < 12.0:
			continue
		var line := PackedVector2Array()
		for i in 17:
			var u := -1.0 + i / 8.0
			line.append(Vector2(ctr.x + u * hw, y + (1.0 - u * u) * 9.0))
		_pline(c, line, color, 3.0, seed + k)
	for k in rows + 1:
		var f0 := float(k) / (rows + 1)
		var f1 := float(k + 1) / (rows + 1)
		var fm := (f0 + f1) * 0.5
		var hw := rad.x * sqrt(maxf(0.0, 1.0 - fm * fm))
		var n := maxi(2, roundi(hw / 34.0))
		for j in n:
			var phi := -PI / 2.0 + PI * (j + 0.5 + (0.5 if k % 2 == 1 else 0.0)) / (n + (1 if k % 2 == 1 else 0))
			if absf(phi) > 1.35:
				continue
			var s := sin(phi)
			var y0 := ctr.y - rad.y * f0
			var y1 := ctr.y - rad.y * f1
			var x0 := ctr.x + s * rad.x * sqrt(maxf(0.0, 1.0 - f0 * f0))
			var x1 := ctr.x + s * rad.x * sqrt(maxf(0.0, 1.0 - f1 * f1))
			var sag0 := (1.0 - s * s) * 9.0
			_pline(c, _pv([Vector2(x0, y0 + sag0 - 3.0), Vector2(x1, y1 + sag0 + 3.0)]), color, 3.0, seed + 40 + k * 10 + j)


## A wooden log end poking out of a wall: a pale ring of cut wood.
static func _log_end(c: CanvasItem, at: Vector2, r: float, wood: Color, seed: int) -> void:
	_pen(c, _circle(at, r, 14), wood.lightened(0.25), seed, 3.5)
	_pline(c, _arc(at, Vector2(r * 0.45, r * 0.45), 0.0, TAU * 0.8, 8), wood.darkened(0.1), 2.0, seed + 1)


## A bamboo pole from a to b with its joints marked.
static func _bamboo(c: CanvasItem, a: Vector2, b: Vector2, half: float, col: Color, seed: int) -> void:
	_pen(c, _band(_pv([a, b]), half, false), col, seed, 4.0)
	var length := a.distance_to(b)
	var n := maxi(1, int(length / 46.0))
	for i in range(1, n + 1):
		var p := a.lerp(b, i / (n + 1.0))
		_pline(c, _pv([p + Vector2(-half + 2, 0), p + Vector2(half - 2, 2)]), col.darkened(0.3), 3.0, seed + i)


## A crystal: a pointed six-sided prism, a pale facet down one side.
static func _crystal(c: CanvasItem, base: Vector2, h: float, w: float, angle: float, col: Color, seed: int) -> void:
	var pts := _pv([Vector2(-w / 2.0, 0), Vector2(-w / 2.0, -h * 0.74), Vector2(0, -h), Vector2(w / 2.0, -h * 0.74),
		Vector2(w / 2.0, 0)])
	var poly := PackedVector2Array()
	for p in pts:
		poly.append(base + p.rotated(angle))
	_pen(c, poly, col, seed, 4.5)
	var facet := PackedVector2Array()
	for p in [Vector2(-w / 2.0, 0), Vector2(-w / 2.0, -h * 0.74), Vector2(0, -h), Vector2(-w * 0.1, -h * 0.74),
			Vector2(-w * 0.1, 0)]:
		facet.append(base + (p as Vector2).rotated(angle))
	Crayon.pencil_fill(c, facet, Color(1, 1, 1, 0.55), seed + 1)
	_pline(c, _pv([base + Vector2(-w * 0.1, 0).rotated(angle), base + Vector2(-w * 0.1, -h * 0.74).rotated(angle),
		base + Vector2(0, -h).rotated(angle)]), col.darkened(0.3), 2.5, seed + 2)
	_pline(c, _pv([base + Vector2(w * 0.22, -h * 0.2).rotated(angle), base + Vector2(w * 0.22, -h * 0.5).rotated(angle)]),
		Color(1, 1, 1, 0.8), 3.0, seed + 3)


## A small glowing mushroom by a cave door.
static func _glow_shroom(c: CanvasItem, base: Vector2, k: float, seed: int) -> void:
	_pen(c, _band(_pv([base, base + Vector2(0, -36 * k)]), 6.0 * k), Color("#efe4d2"), seed, 3.0)
	var cap := _arc(base + Vector2(0, -34 * k), Vector2(24 * k, 20 * k), PI, TAU, 12)
	_mark(c, cap, Color("#8fdcdf"), seed + 1, 3.5)
	c.draw_circle(base + Vector2(-6 * k, -44 * k), 3.0 * k, Color("#f3fdfd"))


## A tiny red toadstool for the foot of the mushroom house.
static func _tiny_toadstool(c: CanvasItem, base: Vector2, k: float, seed: int) -> void:
	_pen(c, Crayon.rounded_rect(Rect2(base.x - 9 * k, base.y - 40 * k, 18 * k, 40 * k), 5 * k), Color("#f3e5c9"), seed, 3.5)
	var cap := _arc(base + Vector2(0, -36 * k), Vector2(32 * k, 28 * k), PI, TAU, 14)
	_pen(c, cap, Color("#e66a5c"), seed + 1, 4.0)
	c.draw_circle(base + Vector2(-10 * k, -50 * k), 5.0 * k, Color("#fcf4ea"))
	c.draw_circle(base + Vector2(10 * k, -46 * k), 4.0 * k, Color("#fcf4ea"))


## Reeds and a cattail or two at the edge of the swamp.
static func _reeds(c: CanvasItem, base: Vector2, k: float, seed: int) -> void:
	var reed := Color("#86bd6c")
	for i in 4:
		var dx := (i - 1.5) * 14.0 * k
		var top := base + Vector2(dx * 1.6 + Crayon.noise(seed, i) * 8.0, -(110.0 + 40.0 * absf(Crayon.noise(seed + 1, i))) * k)
		_pline(c, _pv([base + Vector2(dx, 0), base.lerp(top, 0.5) + Vector2(dx + 3, 0), top]), reed.darkened(0.15), 5.0, seed + 2 + i)
		if i % 2 == 0:
			_pen(c, _band(_pv([top.lerp(base, 0.1), top.lerp(base, 0.3)]), 8.0 * k), Color("#c58f62"), seed + 8 + i, 3.0)
	_pen(c, _leaf(base + Vector2(-14, -40) * k, 90.0 * k, 16.0 * k, -1.9), reed, seed + 20, 3.0)
	_pen(c, _leaf(base + Vector2(16, -44) * k, 96.0 * k, 16.0 * k, -1.2), reed, seed + 21, 3.0)


## A puffy cloud shape: a rectangle with round bumps along its sides and top.
static func _puffy(rect: Rect2, bump: float, seed: int) -> PackedVector2Array:
	var parts := [Crayon.rounded_rect(rect, bump)]
	var n := maxi(2, roundi(rect.size.x / (bump * 1.5)))
	for i in n + 1:
		var x := rect.position.x + rect.size.x * i / n
		parts.append(_circle(Vector2(x, rect.position.y + 4), bump * (1.0 + 0.15 * Crayon.noise(seed, i)), 18))
	var m := maxi(2, roundi(rect.size.y / (bump * 1.6)))
	for i in m + 1:
		var y := rect.position.y + rect.size.y * i / m
		parts.append(_circle(Vector2(rect.position.x + 2, y), bump * (0.9 + 0.15 * Crayon.noise(seed + 1, i)), 18))
		parts.append(_circle(Vector2(rect.end.x - 2, y), bump * (0.9 + 0.15 * Crayon.noise(seed + 2, i)), 18))
	return _union(parts)


## A cloud in pencil: white with a cool blue shadow and a soft blue outline.
static func _cloud_pen(c: CanvasItem, poly: PackedVector2Array, seed: int) -> void:
	_pfill(c, poly, CLOUD, seed)
	_shade(c, poly, Color("#cbd8f2"), seed + 1, Vector2(-24, -20), 0.0)
	Crayon.pencil_line(c, poly, CLOUD_LINE, 5.0, seed + 2)


## A pennant on a little pole, its foot at `foot`.
static func _flag(c: CanvasItem, foot: Vector2, col: Color, seed: int) -> void:
	_pen(c, _band(_pv([foot, foot + Vector2(0, -44)]), 3.0), Color("#c9a37a"), seed, 2.5)
	_mark(c, _pv([foot + Vector2(3, -44), foot + Vector2(44, -34), foot + Vector2(3, -22)]), col, seed + 1, 4.0)


## A gumdrop: a sugared dome with a flat foot at `foot`.
static func _gumdrop(c: CanvasItem, foot: Vector2, r: float, col: Color, seed: int) -> void:
	var dome := PackedVector2Array()
	dome.append_array(_arc(foot + Vector2(0, -r * 0.2), Vector2(r, r * 1.05), PI, TAU, 16))
	dome.append(foot + Vector2(r, 0))
	dome.append(foot + Vector2(-r, 0))
	_mark(c, dome, col, seed, clampf(r * 0.22, 3.0, 5.0))
	for i in 5:
		var p := foot + Vector2(Crayon.noise(seed, i) * r * 0.6, -r * (0.25 + 0.6 * absf(Crayon.noise(seed + 1, i))))
		c.draw_circle(p, maxf(1.5, r * 0.07), Color(1, 1, 1, 0.9))
	c.draw_arc(foot + Vector2(0, -r * 0.2), r * 0.7, PI * 1.15, PI * 1.4, 8, Color(1, 1, 1, 0.85), maxf(2.0, r * 0.12), true)


## A round peppermint: red swirls on white.
static func _peppermint(c: CanvasItem, at: Vector2, r: float, seed: int) -> void:
	var disc := _circle(at, r, 24)
	_mfill(c, disc, Color("#fbf6f2"), seed)
	for k in 4:
		var a := TAU * k / 4.0
		var swirl := PackedVector2Array([at])
		for j in 7:
			var t := j / 6.0
			swirl.append(at + Vector2(cos(a + t * 0.9), sin(a + t * 0.9)) * r * 1.1)
		_clip_fill(c, swirl, disc, Color("#ec6f78"), seed + 1 + k)
	Crayon.marker_line(c, disc, Color("#c0525c"), clampf(r * 0.14, 3.0, 4.5), seed + 6)


## White icing along a roof edge, with drips hanging off it.
static func _icing_edge(c: CanvasItem, a: Vector2, b: Vector2, icing: Color, line: Color, seed: int) -> void:
	var path := PackedVector2Array()
	for i in 13:
		var t := i / 12.0
		var n := (b - a).normalized().orthogonal()
		path.append(a.lerp(b, t) + n * sin(t * PI * 6.0) * 3.0)
	var band := _band(path, 8.0)
	for i in 6:
		var p := a.lerp(b, (i + 0.5) / 6.0)
		var len := 16.0 + 14.0 * absf(Crayon.noise(seed, i))
		band = _biggest(Geometry2D.merge_polygons(band, _capsule(p, p + Vector2(0, len), 6.5)))
	_pfill(c, band, icing, seed + 1)
	Crayon.pencil_line(c, band, line, 3.5, seed + 2)


## The centre line of a candy cane: straight up from `foot` to `top_y`, hooked over by
## radius `r` towards `dir` (1 right, -1 left), the hook's end hanging down a little.
static func _cane_path(foot: Vector2, top_y: float, r: float, dir: float) -> PackedVector2Array:
	var path := PackedVector2Array([foot, Vector2(foot.x, top_y)])
	var hub := Vector2(foot.x + r * dir, top_y)
	for i in range(1, 13):
		var a := PI - PI * i / 12.0 if dir > 0.0 else PI * i / 12.0
		path.append(hub + Vector2(cos(a) * r, -sin(a) * r))
	path.append(path[path.size() - 1] + Vector2(0, r * 0.5))
	return path


## A candy cane along `path`: white with slanted red stripes, a shine down one side.
static func _candy_cane(c: CanvasItem, path: PackedVector2Array, half: float, seed: int) -> void:
	var cane := _band(path, half)
	var red := Color("#e8606a")
	_mfill(c, cane, Color("#fbf6f2"), seed)
	var total := _path_len(path)
	var sw := half * 1.1
	var d := 4.0
	var i := 0
	while d < total:
		var p := _at(path, d)
		var dir := _dir(path, d)
		var n := dir.orthogonal()
		var h2 := half * 1.6
		var s := half * 0.7
		var stripe := _pv([p - n * h2 - dir * s, p - n * h2 - dir * s + dir * sw, p + n * h2 + dir * s + dir * sw,
			p + n * h2 + dir * s])
		_clip_fill(c, stripe, cane, red, seed + 2 + i)
		d += sw * 2.2
		i += 1
	Crayon.marker_line(c, cane, red.darkened(0.42), clampf(half * 0.45, 3.5, 5.5), seed + 1)


## A ring segment between two radii, angles a0 to a1.
static func _annulus(center: Vector2, r_out: float, r_in: float, a0: float, a1: float) -> PackedVector2Array:
	var out := _arc(center, Vector2(r_out, r_out), a0, a1, 14)
	var inner := _arc(center, Vector2(r_in, r_in), a0, a1, 10)
	inner.reverse()
	out.append_array(inner)
	return out


## A little scallop shell, hinge at the bottom.
static func _shell_shape(at: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array([at + Vector2(-r * 0.3, r * 0.5), at + Vector2(r * 0.3, r * 0.5)])
	for i in 13:
		var a := -0.15 - (PI - 0.3) * i / 12.0
		var k := 1.0 + 0.08 * sin(i * PI / 2.0)
		pts.append(at + Vector2(cos(a), sin(a)) * r * k)
	return pts


## A bubble: pale aqua, a blue rim and a white shine.
static func _bubble(c: CanvasItem, at: Vector2, r: float, seed: int) -> void:
	var circ := _circle(at, r, 20)
	c.draw_colored_polygon(circ, Color("#e2f4f9"))
	Crayon.marker_line(c, circ, Color("#86c3d8"), clampf(r * 0.18, 2.5, 4.5), seed)
	c.draw_arc(at, r * 0.6, PI * 1.1, PI * 1.45, 8, Color(1, 1, 1, 0.95), clampf(r * 0.2, 2.0, 5.0), true)


## Short rays round something that glows, drawn as solid strokes the way a kid draws light.
static func _rays(c: CanvasItem, center: Vector2, radius: Vector2, length: float, angles: Array, color: Color,
		seed: int, width := 6.0) -> void:
	for i in angles.size():
		var a: float = angles[i]
		var dir := Vector2(cos(a), sin(a))
		var from := center + dir * radius
		_pline(c, _pv([from, from + dir * length]), color, width, seed + i)


## A curl of smoke or steam rising from `base`.
static func _curl(c: CanvasItem, base: Vector2, h: float, turn: float, col: Color, seed: int, width := 8.0) -> void:
	var path := PackedVector2Array()
	for k in 14:
		var t := k / 13.0
		path.append(base + Vector2(sin(t * TAU * 0.9) * 10.0 * (0.4 + t), -t * h))
	var tip := path[path.size() - 1]
	var hub := tip + Vector2(11.0 * turn, 0)
	for k in range(1, 11):
		var a := (PI if turn > 0.0 else 0.0) + turn * PI * 1.4 * k / 10.0
		path.append(hub + Vector2(cos(a), sin(a)) * 11.0 * (1.0 - k / 28.0))
	_mline(c, path, col, width, seed)


## A flower head: five round petals round a middle.
static func _flower(c: CanvasItem, at: Vector2, r: float, petal: Color, middle: Color, seed: int) -> void:
	var parts := []
	for k in 5:
		var a := -PI / 2.0 + TAU * k / 5.0 + seed * 0.37
		parts.append(_circle(at + Vector2(cos(a), sin(a)) * r, r * 0.82, 14))
	parts.append(_circle(at, r, 14))
	_mark(c, _union(parts), petal, seed, clampf(r * 0.3, 3.0, 4.5))
	_mark(c, _circle(at, r * 0.5, 12), middle, seed + 1, 3.0)


## A flower stem from the ground up to its head, a leaf on it.
static func _stem(c: CanvasItem, root: Vector2, head: Vector2, seed: int) -> void:
	var green := Color("#7fbf6a")
	var lift := (root.y - head.y) * 0.4
	_pline(c, _bez(root, root + Vector2(0, -lift), head + Vector2(0, lift), head, 8), green.darkened(0.15), 5.0, seed)
	_pen(c, _leaf(root.lerp(head, 0.45) + Vector2(10, 0), 28.0, 12.0, -0.5), green, seed + 1, 3.0)


## Cut a shape off at the ground line.
static func _ground_cut(poly: PackedVector2Array) -> PackedVector2Array:
	var ground := _pv([Vector2(-20, -20), Vector2(532, -20), Vector2(532, 470), Vector2(-20, 470)])
	return _biggest(Geometry2D.intersect_polygons(poly, ground))


# --- Brushes (the same as ArtThings) ---------------------------------------------------------
# Thin wrappers over Crayon that lay a solid, lighter coat of the colour under the strokes, so
# a thing is opaque in a place (a house must hide what is behind it) but still reads as pencil
# or marker on paper.

## A shape in coloured pencil, outlined in a darker shade of its own colour.
static func _pen(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		lw := 5.0) -> void:
	if poly.size() < 3:
		return
	_pfill(c, poly, color, seed)
	Crayon.pencil_line(c, poly, color.darkened(0.45), lw, seed + 31)


## Coloured pencil fill only.
static func _pfill(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int) -> void:
	if poly.size() < 3:
		return
	c.draw_colored_polygon(poly, color.lerp(PAPER, 0.68))
	Crayon.pencil_fill(c, poly, color, seed)


## A shape in marker, outlined in a darker shade of its own colour.
static func _mark(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		lw := 7.0) -> void:
	if poly.size() < 3:
		return
	_mfill(c, poly, color, seed)
	Crayon.marker_line(c, poly, color.darkened(0.48), lw, seed + 31)


## Marker fill only; the stroke shrinks for small shapes so they still get streaks.
static func _mfill(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int) -> void:
	if poly.size() < 3:
		return
	var r := Crayon.bounds(poly)
	var stroke := clampf(minf(r.size.x, r.size.y) * 0.3, 7.0, 22.0)
	c.draw_colored_polygon(poly, color.lerp(PAPER, 0.55))
	Crayon.marker_fill(c, poly, color, seed, stroke)


## Pencil shading along one side: the part of the shape not covered by itself moved by
## `offset`. Offset up-left shades the lower right.
static func _shade(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		offset := Vector2(-26, -22), amount := 0.2) -> void:
	for piece in Geometry2D.clip_polygons(poly, _move(poly, offset)):
		if piece.size() >= 3:
			Crayon.pencil_fill(c, piece, color.darkened(amount), seed, 4.0, 2.0)


## A pale gleam along the upper left (or wherever `offset` points away from).
static func _gleam(c: CanvasItem, poly: PackedVector2Array, seed: int, offset := Vector2(16, 16),
		alpha := 0.5) -> void:
	for piece in Geometry2D.clip_polygons(poly, _move(poly, offset)):
		if piece.size() >= 3:
			Crayon.pencil_fill(c, piece, Color(1, 1, 1, alpha), seed, 4.0, 2.0)


## Fill the parts of `shape` that `pattern` covers - stripes, bands, checks.
static func _clip_fill(c: CanvasItem, pattern: PackedVector2Array, shape: PackedVector2Array,
		color: Color, seed: int, marker := true) -> void:
	var i := 0
	for piece in Geometry2D.intersect_polygons(pattern, shape):
		if piece.size() >= 3:
			if marker:
				_mfill(c, piece, color, seed + i)
			else:
				_pfill(c, piece, color, seed + i)
		i += 1


static func _pline(c: CanvasItem, points: PackedVector2Array, color: Color, width: float,
		seed: int) -> void:
	Crayon.pencil_line(c, points, color, width, seed, false)


static func _mline(c: CanvasItem, points: PackedVector2Array, color: Color, width: float,
		seed: int) -> void:
	Crayon.marker_line(c, points, color, width, seed, false)


## A tuft of grass at the foot of something, so it sits on the ground.
static func _tuft(c: CanvasItem, base: Vector2, seed: int, size := 1.0) -> void:
	var green := Color("#86c46e")
	for i in 5:
		var dx := (i - 2) * 7.0 * size
		var top := base + Vector2(dx * 1.9 + Crayon.noise(seed, i) * 5.0,
			-(22.0 + 12.0 * absf(Crayon.noise(seed + 1, i))) * size * (1.0 - absf(i - 2) * 0.18))
		_pline(c, _pv([base + Vector2(dx, 0), (base + Vector2(dx, 0)).lerp(top, 0.5) + Vector2(2, 0), top]),
			green.darkened(0.2), 4.0, seed + 10 + i)


## A small four-pointed sparkle.
static func _sparkle(center: Vector2, size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 8:
		var r := size if i % 2 == 0 else size * 0.28
		var a := -PI / 2.0 + i * PI / 4.0
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts


## A sparkle: pale inside, edged in a tint of whatever it sparkles on (not grey).
static func _twinkle(c: CanvasItem, center: Vector2, size: float, edge: Color, seed: int,
		fill := Color("#fffbea")) -> void:
	var star := _sparkle(center, size)
	_mfill(c, star, fill, seed)
	Crayon.marker_line(c, star, edge, clampf(size * 0.14, 2.5, 4.0), seed + 1)


# --- Geometry --------------------------------------------------------------------------------

static func _pv(points: Array) -> PackedVector2Array:
	return PackedVector2Array(points)


static func _circle(center: Vector2, r: float, count := 36) -> PackedVector2Array:
	return Crayon.ellipse(center, Vector2(r, r), count)


static func _move(poly: PackedVector2Array, d: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(p + d)
	return out


static func _rot(poly: PackedVector2Array, center: Vector2, angle: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(center + (p - center).rotated(angle))
	return out


## Points round part of an ellipse, angle a0 to a1 (radians, y down: PI/2 is the bottom).
static func _arc(center: Vector2, radius: Vector2, a0: float, a1: float, n := 16) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n + 1:
		var a := lerpf(a0, a1, i / float(n))
		out.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	return out


static func _bez(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, n := 24) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n + 1:
		var t := i / float(n)
		var u := 1.0 - t
		out.append(p0 * u * u * u + p1 * 3.0 * u * u * t + p2 * 3.0 * u * t * t + p3 * t * t * t)
	return out


## Chaikin corner-cutting: turns a few hand-placed points into a soft, drawn-looking shape.
static func _smooth(points: PackedVector2Array, iterations := 2, closed := true) -> PackedVector2Array:
	var pts := points
	for _it in iterations:
		var out := PackedVector2Array()
		var n := pts.size()
		if not closed:
			out.append(pts[0])
		var count := n if closed else n - 1
		for i in count:
			var a := pts[i]
			var b := pts[(i + 1) % n]
			out.append(a.lerp(b, 0.25))
			out.append(a.lerp(b, 0.75))
		if not closed:
			out.append(pts[n - 1])
		pts = out
	return pts


## A thick line as a polygon - posts, poles, stems.
static func _band(points: PackedVector2Array, half: float, round_ends := true) -> PackedVector2Array:
	if points.size() == 2 and round_ends:
		return _capsule(points[0], points[1], half)
	var res := Geometry2D.offset_polyline(points, half, Geometry2D.JOIN_ROUND,
		Geometry2D.END_ROUND if round_ends else Geometry2D.END_BUTT)
	return _biggest(res)


## A straight band with properly round ends.
static func _capsule(a: Vector2, b: Vector2, r: float) -> PackedVector2Array:
	var ang := (b - a).angle()
	var out := PackedVector2Array()
	var n := clampi(int(r / 2.0), 6, 14)
	for i in n + 1:
		var t := ang - PI / 2.0 + PI * i / n
		out.append(b + Vector2(cos(t), sin(t)) * r)
	for i in n + 1:
		var t := ang + PI / 2.0 + PI * i / n
		out.append(a + Vector2(cos(t), sin(t)) * r)
	return out


static func _biggest(polys: Array) -> PackedVector2Array:
	var best := PackedVector2Array()
	var best_area := -1.0
	for p in polys:
		var poly: PackedVector2Array = p
		var r := Crayon.bounds(poly)
		if r.get_area() > best_area:
			best_area = r.get_area()
			best = poly
	return best


## Several overlapping shapes merged into one outline.
static func _union(polys: Array) -> PackedVector2Array:
	var acc: PackedVector2Array = polys[0]
	var pending := polys.slice(1)
	while not pending.is_empty():
		var waiting := []
		for p in pending:
			var next: PackedVector2Array = p
			if Geometry2D.intersect_polygons(acc, next).is_empty():
				waiting.append(next)
			else:
				acc = _biggest(Geometry2D.merge_polygons(acc, next))
		if waiting.size() == pending.size():
			break
		pending = waiting
	return acc


static func _circles(list: Array) -> PackedVector2Array:
	var polys := []
	for item in list:
		var v: Vector3 = item
		polys.append(_circle(Vector2(v.x, v.y), v.z, 32))
	return _union(polys)


## A pointed leaf: stem end at -length/2, tip at +length/2, then turned by `angle`.
static func _leaf(center: Vector2, length: float, width: float, angle: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := 12
	for i in n + 1:
		var t := i / float(n)
		pts.append(Vector2(lerpf(-length / 2.0, length / 2.0, t), -sin(pow(t, 0.8) * PI) * width / 2.0))
	for i in range(n - 1, 0, -1):
		var t := i / float(n)
		pts.append(Vector2(lerpf(-length / 2.0, length / 2.0, t), sin(pow(t, 0.8) * PI) * width / 2.0))
	var out := PackedVector2Array()
	for p in pts:
		out.append(center + p.rotated(angle))
	return out


static func _path_len(path: PackedVector2Array) -> float:
	var total := 0.0
	for i in path.size() - 1:
		total += path[i].distance_to(path[i + 1])
	return total


static func _at(path: PackedVector2Array, d: float) -> Vector2:
	var left := d
	for i in path.size() - 1:
		var seg := path[i].distance_to(path[i + 1])
		if left <= seg:
			return path[i].lerp(path[i + 1], left / maxf(seg, 0.001))
		left -= seg
	return path[path.size() - 1]


static func _dir(path: PackedVector2Array, d: float) -> Vector2:
	var total := _path_len(path)
	return (_at(path, minf(d + 3.0, total)) - _at(path, maxf(d - 3.0, 0.0))).normalized()


## The side of an upright cylinder: the front half of the top ellipse down to the front half of
## the bottom one.
static func _drum_side(top: Vector2, top_r: Vector2, bottom: Vector2, bottom_r: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in 21:
		var a := PI - PI * i / 20.0
		out.append(bottom + Vector2(cos(a) * bottom_r.x, sin(a) * bottom_r.y))
	for i in 21:
		var a := PI * i / 20.0
		out.append(top + Vector2(cos(a) * top_r.x, sin(a) * top_r.y))
	return out


## A castle wall from x0 to x1: `merlons` battlements of `tooth` height on top of `top`,
## down to `bottom`.
static func _crenellated(x0: float, x1: float, top: float, tooth: float, merlons: int,
		bottom: float) -> PackedVector2Array:
	var wall := PackedVector2Array([Vector2(x0, bottom), Vector2(x0, top)])
	var w := (x1 - x0) / merlons
	for i in merlons:
		var a := x0 + i * w
		if i % 2 == 0:
			wall.append_array(_pv([Vector2(a, top - tooth), Vector2(a + w, top - tooth), Vector2(a + w, top)]))
		else:
			wall.append(Vector2(a + w, top))
	wall.append(Vector2(x1, bottom))
	return wall
