class_name ArtBrand
extends RefCounted
## The face of the game: the app icon on a phone, the Windows exe and installer, the taskbar. A
## pet a kid drew - close up, smiling, hugging the coloured pencil it was drawn with, which has
## just drawn a heart. Baked to res://art/brand/ by tools/bake_art.gd; tools/app_icon.py makes
## every icon size from it (icon/).
##
## It is a creature, so it owns black (.ai/art-direction.md): marker fills and black marker
## outlines, the way the rival pets are drawn - including the pencil it holds, which is part of
## the same kid's drawing. The background behind it is light, as everything outside a creature is.
##
## Two layers, because an Android launcher wants them apart (an adaptive icon slides and masks
## the front one): icon_back is the plain square behind, icon_pet the pet on nothing. All three
## fill the whole 512 sheet, so they line up when put together. icon_pet_round is the same pet
## smaller, for Android's front layer: a launcher shows only the middle circle of it (two thirds
## across) and may slide it about, so the ears and heart sit inside that circle and the body runs
## well off the bottom.

const INK := Color("#1f1d24")
const FUR := Color("#ffad5a")
const FUR_DARK := Color("#f0873a")
const CREAM := Color("#fff1d6")
const EAR_PINK := Color("#ffb3c8")
const BLUSH := Color(1.0, 0.56, 0.67, 0.55)
const MOUTH := Color("#c43d5c")
const TONGUE := Color("#ff7f9e")
const PENCIL := Color("#ffd23f")
const PENCIL_STRIPE := Color("#ffe58a")
const WOOD := Color("#f5cf9c")
const LEAD := Color("#9b5de5")
const ERASER := Color("#ff9fb5")
const FERRULE := Color("#c9c3e6")
const HEART := Color("#f2557a")
const SKY := Color("#d6ecfb")
const W := 13.0         # the outline round the big shapes
const W_DETAIL := 9.0   # toes, whiskers, the pencil's bands


static func assets() -> Dictionary:
	return {
		"icon_back": {"pivot": "center", "look": "the light sky-blue square behind the icon pet, coloured-pencil texture"},
		"icon_pet": {"pivot": "center", "look": "an orange kid-drawn cat-like pet, close up and smiling, hugging a yellow coloured pencil that has just drawn a heart"},
		"icon_pet_round": {"pivot": "center", "look": "icon_pet, smaller, for an Android launcher's round mask"},
	}


static func draw(id: String, c: CanvasItem) -> void:
	match id:
		"icon_back":
			_back(c)
		"icon_pet":
			_pet(c)
		"icon_pet_round":
			# Scaled about the middle; the visible circle is 2/3 of the sheet across (288 of 432).
			var k := 0.58
			c.draw_set_transform(Vector2(256, 256) * (1.0 - k), 0.0, Vector2(k, k))
			_pet(c)
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Pinned to the whole sheet (invisible), so the baker's crop keeps both layers the same size.
	c.draw_rect(Rect2(0, 0, 1, 1), Color(1, 1, 1, 0.004))
	c.draw_rect(Rect2(511, 511, 1, 1), Color(1, 1, 1, 0.004))


static func _back(c: CanvasItem) -> void:
	var square := PackedVector2Array([Vector2(0, 0), Vector2(512, 0), Vector2(512, 512), Vector2(0, 512)])
	c.draw_colored_polygon(square, SKY)
	Crayon.pencil_fill(c, square, SKY.darkened(0.06), 2201)


static func _pet(c: CanvasItem) -> void:
	# Ears first, so the head covers their bases.
	for e in [[Vector2(96, 170), Vector2(112, 18), Vector2(214, 96), 2301], [Vector2(298, 96), Vector2(400, 18), Vector2(416, 170), 2311]]:
		var ear := PackedVector2Array([e[0], e[1], e[2]])
		_part(c, ear, FUR, e[3])
		var mid: Vector2 = (e[0] + e[1] + e[2]) / 3.0
		var inner := PackedVector2Array()
		for p in [e[0], e[1], e[2]]:
			inner.append(mid + (p - mid) * 0.55 + Vector2(0, 8))
		_fill(c, inner, EAR_PINK, e[3] + 5, 14.0)

	# Shoulders and a cream chest, running off the bottom of the icon: this close, there is no
	# room for legs.
	var body := Crayon.blob(Vector2(256, 560), Vector2(215, 205), 2321, 26)
	_part(c, body, FUR, 2322)
	_fill(c, Crayon.ellipse(Vector2(256, 520), Vector2(118, 120)), CREAM, 2323, 16.0)

	# The head: big, round, a little wider at the cheeks.
	var head := PackedVector2Array()
	for i in 44:
		var a := TAU * i / 44.0
		var cheeks := 1.0 + 0.07 * maxf(0.0, sin(a)) * absf(cos(a)) * 2.0
		head.append(Vector2(256, 232) + Vector2(cos(a) * 182.0 * cheeks, sin(a) * 152.0))
	head = Crayon.wobbled(head, 2331, 2.0, true)
	_part(c, head, FUR, 2332)
	# three tabby stripes on the forehead
	for i in 3:
		var x := 216.0 + i * 40.0
		var stripe := PackedVector2Array([Vector2(x - 9, 92), Vector2(x + 9, 92), Vector2(x + 4, 140 - absf(i - 1) * 14.0),
			Vector2(x - 4, 140 - absf(i - 1) * 14.0)])
		_fill(c, stripe, FUR_DARK, 2340 + i, 10.0)

	_face(c)
	_pencil_and_paws(c)


static func _face(c: CanvasItem) -> void:
	# Blush, under everything else on the face.
	for x in [148.0, 364.0]:
		c.draw_colored_polygon(Crayon.ellipse(Vector2(x, 282), Vector2(34, 20)), BLUSH)

	# Big round eyes, looking right at you, each with two catchlights.
	for x in [186.0, 326.0]:
		var eye := Crayon.wobbled(Crayon.ellipse(Vector2(x, 210), Vector2(35, 40), 28), 2400 + int(x), 0.8, true)
		c.draw_colored_polygon(eye, INK)
		Crayon.marker_line(c, eye, INK, 5.0, 2410 + int(x))
		c.draw_circle(Vector2(x - 12, 194), 15.0, Color.WHITE)
		c.draw_circle(Vector2(x + 13, 226), 6.5, Color.WHITE)

	# A little pink nose.
	var nose := PackedVector2Array([Vector2(240, 254), Vector2(272, 254), Vector2(256, 272)])
	_fill(c, nose, EAR_PINK.darkened(0.08), 2420, 10.0)
	Crayon.marker_line(c, nose, INK, 7.0, 2421)

	# The smile: wide open, a tongue in it.
	var mouth := PackedVector2Array([Vector2(206, 290)])
	for p in _bez(Vector2(206, 290), Vector2(212, 352), Vector2(300, 352), Vector2(306, 290), 14):
		mouth.append(p)
	for p in _bez(Vector2(306, 290), Vector2(280, 300), Vector2(232, 300), Vector2(206, 290), 8):
		mouth.append(p)
	c.draw_colored_polygon(mouth, MOUTH)
	var tongue := Crayon.ellipse(Vector2(256, 330), Vector2(34, 20))
	var tongue_in := Geometry2D.intersect_polygons(tongue, mouth)
	for piece in tongue_in:
		c.draw_colored_polygon(piece, TONGUE)
	Crayon.marker_line(c, mouth, INK, 9.0, 2430)
	# the line down from the nose into the smile
	_ink(c, PackedVector2Array([Vector2(256, 272), Vector2(256, 296)]), 7.0, 2431)

	# Whiskers.
	for side in [-1.0, 1.0]:
		for k in 3:
			var from := Vector2(256 + side * 112.0, 262 + k * 16.0)
			var to := Vector2(256 + side * 176.0, 246 + k * 22.0)
			_ink(c, PackedVector2Array([from, (from + to) / 2.0 + Vector2(0, -3), to]), 5.0, 2440 + k + int(side * 10))


## The pencil across its chest, held in both paws, and the heart it has just drawn.
static func _pencil_and_paws(c: CanvasItem) -> void:
	var back := Vector2(62, 486)
	var tip := Vector2(418, 350)
	var along := (tip - back).normalized()
	var across := Vector2(-along.y, along.x)
	var half := 31.0
	var length := back.distance_to(tip)
	var at := func(t: float, side: float) -> Vector2:
		return back + along * (length * t) + across * (half * side)

	# Eraser, metal band, the painted body, the sharpened wood, the lead.
	var eraser := PackedVector2Array([at.call(0.0, -1.0), at.call(0.1, -1.0), at.call(0.1, 1.0), at.call(0.0, 1.0)])
	_part(c, eraser, ERASER, 2501, W_DETAIL)
	var band := PackedVector2Array([at.call(0.1, -1.0), at.call(0.17, -1.0), at.call(0.17, 1.0), at.call(0.1, 1.0)])
	_part(c, band, FERRULE, 2502, W_DETAIL)
	var body := PackedVector2Array([at.call(0.17, -1.0), at.call(0.78, -1.0), at.call(0.78, 1.0), at.call(0.17, 1.0)])
	_part(c, body, PENCIL, 2503, W)
	_fill(c, PackedVector2Array([at.call(0.19, -0.25), at.call(0.76, -0.25), at.call(0.76, 0.2), at.call(0.19, 0.2)]),
		PENCIL_STRIPE, 2504, 10.0)
	var wood := PackedVector2Array([at.call(0.78, -1.0), at.call(0.93, -0.32), at.call(0.93, 0.32), at.call(0.78, 1.0)])
	_part(c, wood, WOOD, 2505, W_DETAIL)
	var lead := PackedVector2Array([at.call(0.93, -0.32), at.call(1.0, 0.0), at.call(0.93, 0.32)])
	_part(c, lead, LEAD, 2506, W_DETAIL)

	# The heart it has just drawn, in the pencil's own colour, and the last stroke trailing off it.
	var heart := Crayon.heart(Vector2(438, 290), 76.0)
	_fill(c, heart, HEART, 2510, 14.0)
	Crayon.marker_line(c, heart, HEART.darkened(0.35), 7.0, 2511)
	Crayon.marker_line(c, PackedVector2Array([tip + along * 6.0, Vector2(434, 336), Vector2(446, 326)]), LEAD, 6.0, 2512, false)

	# Two paws wrapped over it, toes towards you.
	for t in [0.33, 0.66]:
		var centre: Vector2 = at.call(t, -0.35)
		var paw := Crayon.blob(centre, Vector2(37, 33), 2520 + int(t * 100), 18)
		_part(c, paw, FUR, 2530 + int(t * 100), W)
		for k in [-1.0, 1.0]:
			var toe: Vector2 = centre + along * (k * 13.0) + across * 4.0
			_ink(c, PackedVector2Array([toe + across * 4.0, toe + across * 20.0]), 6.0, 2540 + int(t * 100) + int(k))


# --- Drawing helpers, the same as the rival pets' (art_rivals.gd) ----------------------------

static func _fill(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int, stroke := 22.0) -> void:
	if poly.size() < 3:
		return
	c.draw_colored_polygon(poly, color.lerp(Color.WHITE, 0.3))
	Crayon.marker_fill(c, poly, color, seed, stroke)


## Coloured in, then gone round in black marker.
static func _part(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int, width := W) -> void:
	_fill(c, poly, color, seed)
	Crayon.marker_line(c, poly, INK, width, seed + 1)


## An open black marker stroke.
static func _ink(c: CanvasItem, pts: PackedVector2Array, width: float, seed: int) -> void:
	Crayon.marker_line(c, pts, INK, width, seed, false)


## Points along a cubic curve.
static func _bez(a: Vector2, b: Vector2, d: Vector2, e: Vector2, n := 16) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n + 1:
		var t := i / float(n)
		var u := 1.0 - t
		out.append(a * u * u * u + b * 3.0 * u * u * t + d * 3.0 * u * t * t + e * t * t * t)
	return out
