class_name ArtRivals
extends RefCounted
## The rival pets who turn up at competitions - drawn as if OTHER KIDS drew them, in marker
## with black outlines, part by part, exactly the way the game asks a kid to draw. Each rival
## is assembled at runtime by the same PetBuilder.add_parts a kid's pet goes through.
## Baked to res://art/rivals/ by tools/bake_art.gd.
##
## Rivals are creatures, so - unlike every other made-for-the-game drawing - they DO use black
## outlines: creatures own black (.ai/art-direction.md). Marker fills, a kid's wobble.
##
## Each part is drawn on the sheet a kid would get for it, from the same red dot, at the same
## zoom (PartTypes.TYPES). The dot is the asset's pivot. Ids are "<rival>_<type>".
## A rival's ROSTER entry says how many of each part it has; each part type is drawn once.

## Where each part type's dot is on the sheet, and its zoom, copied from PartTypes so the baker
## does not depend on it. Draw the part starting at the dot, in the direction noted.
const DOTS := {
	"body": Vector2(-1, -1),        # no dot - "center"; draw it big, ~400 x 260, facing right
	"head": Vector2(200, 410),      # zoom 1.0 - neck at the dot, head up and to the right
	"eye": Vector2(256, 256),       # zoom 3.0 - one eye round the dot, ~130-160 px across
	"mouth": Vector2(256, 256),     # zoom 2.5 - drawn WIDE OPEN round the dot, ~150-200 across
	"ear": Vector2(256, 430),       # zoom 1.8 - grows UP from the dot
	"horn": Vector2(256, 440),      # zoom 1.8 - UP
	"antenna": Vector2(256, 450),   # zoom 1.5 - UP, a bobble on the end
	"hair": Vector2(300, 400),      # zoom 1.3 - UP, a tuft or crest
	"leg": Vector2(256, 70),        # zoom 1.0 - hangs DOWN, foot at the bottom, ~180-260 long
	"arm": Vector2(256, 70),        # zoom 1.2 - hangs DOWN from the shoulder
	"wing": Vector2(300, 440),      # zoom 1.0 - UP
	"tail": Vector2(440, 256),      # zoom 1.0 - goes LEFT from the dot
	"fin": Vector2(256, 430),       # zoom 1.3 - UP
	"spike": Vector2(256, 440),     # zoom 1.5 - UP
	"tentacle": Vector2(256, 60),   # zoom 1.0 - dangles DOWN
}

## Who the rivals are and what they are made of. Names and parts are fixed (game code uses
## them); how each part looks is up to its drawing.
const ROSTER := {
	"biscuit": {"name": "Biscuit", "look": "friendly tan puppy, brown patches",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "leg": 4, "tail": 1}},
	"zippy": {"name": "Zippy", "look": "long green lizard, yellow belly",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "leg": 4, "tail": 1, "spike": 4}},
	"puffles": {"name": "Puffles", "look": "round purple fluffball, no legs - it hops",
		"parts": {"eye": 2, "mouth": 1, "antenna": 2}},
	"captain_fins": {"name": "Captain Fins", "look": "orange fish standing on two legs",
		"parts": {"eye": 1, "mouth": 1, "fin": 2, "tail": 1, "leg": 2}},
	"duchess": {"name": "Duchess", "look": "fancy pink bird, curly crest, beak as the mouth",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "wing": 2, "leg": 2, "hair": 1}},
	"rocky": {"name": "Rocky", "look": "chunky blue-grey rock monster, three eyes",
		"parts": {"eye": 3, "mouth": 1, "arm": 2, "leg": 2}},
	"noodle": {"name": "Noodle", "look": "long yellow-green caterpillar, lots of little legs",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "leg": 8, "antenna": 2}},
	"mango": {"name": "Mango", "look": "orange stripy cat",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "leg": 4, "tail": 1}},
}

## One asset per rival per part type, plus its body.
static func assets() -> Dictionary:
	var out := {}
	for rival in ROSTER:
		out[rival + "_body"] = {"pivot": "center"}
		for type in ROSTER[rival]["parts"]:
			out["%s_%s" % [rival, type]] = {"pivot": DOTS[type]}
	return out


const INK := Color("#1f1d24")
const PAPER := Color("#fffdf8")
const MOUTH_IN := Color("#c9405e")
const TONGUE := Color("#ff92ab")
const O := Vector2(256, 256)   # the eye and mouth dot

# Line widths: about the same thickness once each sheet is shrunk by its zoom.
const W_BODY := 9.0
const W_EYE := 15.0
const W_MOUTH := 14.0
const W_EAR := 13.0
const W_ANT := 12.0
const W_FIN := 11.0
const W_ARM := 10.0


static func draw(id: String, c: CanvasItem) -> void:
	match id:
		"biscuit_body": _biscuit_body(c)
		"biscuit_head": _biscuit_head(c)
		"biscuit_eye": _biscuit_eye(c)
		"biscuit_mouth": _biscuit_mouth(c)
		"biscuit_ear": _biscuit_ear(c)
		"biscuit_leg": _biscuit_leg(c)
		"biscuit_tail": _biscuit_tail(c)
		"zippy_body": _zippy_body(c)
		"zippy_head": _zippy_head(c)
		"zippy_eye": _zippy_eye(c)
		"zippy_mouth": _zippy_mouth(c)
		"zippy_leg": _zippy_leg(c)
		"zippy_tail": _zippy_tail(c)
		"zippy_spike": _zippy_spike(c)
		"puffles_body": _puffles_body(c)
		"puffles_eye": _puffles_eye(c)
		"puffles_mouth": _puffles_mouth(c)
		"puffles_antenna": _puffles_antenna(c)
		"captain_fins_body": _fins_body(c)
		"captain_fins_eye": _fins_eye(c)
		"captain_fins_mouth": _fins_mouth(c)
		"captain_fins_fin": _fins_fin(c)
		"captain_fins_tail": _fins_tail(c)
		"captain_fins_leg": _fins_leg(c)
		"duchess_body": _duchess_body(c)
		"duchess_head": _duchess_head(c)
		"duchess_eye": _duchess_eye(c)
		"duchess_mouth": _duchess_mouth(c)
		"duchess_wing": _duchess_wing(c)
		"duchess_leg": _duchess_leg(c)
		"duchess_hair": _duchess_hair(c)
		"rocky_body": _rocky_body(c)
		"rocky_eye": _rocky_eye(c)
		"rocky_mouth": _rocky_mouth(c)
		"rocky_arm": _rocky_arm(c)
		"rocky_leg": _rocky_leg(c)
		"noodle_body": _noodle_body(c)
		"noodle_head": _noodle_head(c)
		"noodle_eye": _noodle_eye(c)
		"noodle_mouth": _noodle_mouth(c)
		"noodle_leg": _noodle_leg(c)
		"noodle_antenna": _noodle_antenna(c)
		"mango_body": _mango_body(c)
		"mango_head": _mango_head(c)
		"mango_eye": _mango_eye(c)
		"mango_mouth": _mango_mouth(c)
		"mango_ear": _mango_ear(c)
		"mango_leg": _mango_leg(c)
		"mango_tail": _mango_tail(c)


# --- Kid-drawing helpers ---------------------------------------------------------------------

## Marker colour on white paper: an opaque paper-tinted base so parts never show through each
## other, then the felt-tip streaks over it.
static func _fill(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		stroke := 22.0) -> void:
	if poly.size() < 3:
		return
	c.draw_colored_polygon(poly, color.lerp(Color.WHITE, 0.3))
	Crayon.marker_fill(c, poly, color, seed, stroke)


## Coloured in, then gone round in black marker.
static func _part(c: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		width := W_BODY, stroke := 22.0) -> void:
	_fill(c, poly, color, seed, stroke)
	Crayon.marker_line(c, poly, INK, width, seed + 1)


## A patch coloured only where it overlaps `inside` - a kid colouring a spot inside the lines.
static func _clip_fill(c: CanvasItem, shape: PackedVector2Array, inside: PackedVector2Array,
		color: Color, seed: int, stroke := 16.0, outline := 0.0) -> void:
	var k := 0
	for piece in Geometry2D.intersect_polygons(shape, inside):
		_fill(c, piece, color, seed + k, stroke)
		if outline > 0.0:
			Crayon.marker_line(c, piece, INK, outline, seed + 50 + k)
		k += 1


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


## Points along a straight line.
static func _seg(a: Vector2, b: Vector2, n := 6) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n + 1:
		out.append(a.lerp(b, i / float(n)))
	return out


## A sausage round a path, `w0` thick at its start and `w1` at its end, with round ends.
static func _tube(path: PackedVector2Array, w0: float, w1: float, cap0 := 1.0,
		cap1 := 1.0) -> PackedVector2Array:
	var n := path.size()
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	for i in n:
		var w := lerpf(w0, w1, i / float(n - 1))
		var d: Vector2
		if i == 0:
			d = path[1] - path[0]
		elif i == n - 1:
			d = path[n - 1] - path[n - 2]
		else:
			d = path[i + 1] - path[i - 1]
		var nrm := d.normalized().orthogonal()
		left.append(path[i] + nrm * w)
		right.append(path[i] - nrm * w)
	var out := PackedVector2Array()
	out.append_array(left)
	var de := (path[n - 1] - path[n - 2]).normalized()
	var ne := de.orthogonal()
	for k in range(1, 9):
		var a := PI * k / 9.0
		out.append(path[n - 1] + ne * cos(a) * w1 + de * sin(a) * w1 * cap1)
	for i in range(n - 1, -1, -1):
		out.append(right[i])
	var ds := (path[1] - path[0]).normalized()
	var ns := ds.orthogonal()
	for k in range(1, 9):
		var a := PI * k / 9.0
		out.append(path[0] - ns * cos(a) * w0 - ds * sin(a) * w0 * cap0)
	return out


static func _area(p: PackedVector2Array) -> float:
	var s := 0.0
	for i in p.size():
		var a := p[i]
		var b := p[(i + 1) % p.size()]
		s += a.x * b.y - b.x * a.y
	return absf(s) * 0.5


## Two overlapping shapes as one outline (the outer boundary of their union).
static func _merge(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	var best := a
	var best_area := -1.0
	for p in Geometry2D.merge_polygons(a, b):
		var ar := _area(p)
		if ar > best_area:
			best_area = ar
			best = p
	return best


static func _merge_all(shapes: Array) -> PackedVector2Array:
	var out: PackedVector2Array = shapes[0]
	for i in range(1, shapes.size()):
		out = _merge(out, shapes[i])
	return out


## A lumpy egg: round at the front (right), narrowing towards the back (left).
static func _egg(center: Vector2, r: Vector2, taper: float, seed: int, count := 26,
		lumpy := 0.035) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in count:
		var a := TAU * i / count
		var x := cos(a)
		var f := 1.0
		if x < 0.0:
			f = 1.0 - taper * pow(-x, 1.6)
		var k := 1.0 + Crayon.noise(seed, i) * lumpy
		pts.append(center + Vector2(x * r.x, sin(a) * r.y * f) * k)
	return pts


## A rounded-square blob (superellipse), optionally furry: every other point pushed in.
static func _squircle(center: Vector2, r: Vector2, e: float, seed: int, count := 40,
		lumpy := 0.03, fur := 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in count:
		var a := TAU * i / count
		var cx := cos(a)
		var sy := sin(a)
		var x := signf(cx) * pow(absf(cx), 2.0 / e)
		var y := signf(sy) * pow(absf(sy), 2.0 / e)
		var k := 1.0 + Crayon.noise(seed, i) * lumpy - (fur if i % 2 == 1 else 0.0)
		pts.append(center + Vector2(x * r.x, y * r.y) * k)
	return pts


## A band straight across a path at fraction `t`, for stripes, collars and socks.
static func _band(path: PackedVector2Array, t: float, half_len: float,
		thick: float, slant := 0.0) -> PackedVector2Array:
	var i := clampi(roundi(t * (path.size() - 1)), 1, path.size() - 1)
	var p := path[i]
	var d := (path[i] - path[i - 1]).normalized()
	var n := d.orthogonal()
	return PackedVector2Array([p - d * thick + n * half_len + d * slant,
		p + d * thick + n * half_len + d * slant, p + d * thick - n * half_len - d * slant,
		p - d * thick - n * half_len - d * slant])


## The ink box the baker will crop a drawing to, near enough (outline included).
static func _box(poly: PackedVector2Array, width: float) -> Rect2:
	return Crayon.bounds(poly).grow(width * 0.5 + 1.5)


## One eye round the dot: white, an optional coloured iris, a black pupil with a shine.
static func _eye(c: CanvasItem, seed: int, r: Vector2, iris: Color, iris_r: float,
		pupil: Vector2, look := Vector2(8, 4)) -> PackedVector2Array:
	var white := Crayon.blob(O, r, seed, 24, 0.035)
	c.draw_colored_polygon(white, PAPER)
	if iris_r > 0.0:
		var ir := Crayon.blob(O + look, Vector2(iris_r, iris_r * 1.04), seed + 2, 18, 0.04)
		_fill(c, ir, iris, seed + 3, 14.0)
		Crayon.marker_line(c, ir, INK, 6.0, seed + 4)
	var pc := O + look * 1.2
	c.draw_colored_polygon(Crayon.blob(pc, pupil, seed + 5, 16, 0.04), INK)
	c.draw_circle(pc + Vector2(-pupil.x * 0.4, -pupil.y * 0.42), minf(pupil.x, pupil.y) * 0.34,
		Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, seed + 6)
	return white


## A mouth drawn wide open round the dot: flat-ish top, round bottom, centred top-to-bottom.
## `flat` is how deep the top edge bows compared with the bottom.
static func _mouth_shape(half: Vector2, flat: float, seed: int, n := 30) -> PackedVector2Array:
	var shift := (half.y - half.y * flat) * 0.5
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		var ry := half.y if sin(a) > 0.0 else half.y * flat
		var k := 1.0 + Crayon.noise(seed, i) * 0.03
		pts.append(O + Vector2(cos(a) * half.x * k, sin(a) * ry * k - shift))
	return pts


## The usual open mouth: dark pink inside, a tongue, maybe teeth along the top.
static func _open_mouth(c: CanvasItem, seed: int, half: Vector2, flat := 0.3, teeth := 0,
		fangs := false, tongue := true) -> PackedVector2Array:
	var m := _mouth_shape(half, flat, seed)
	_fill(c, m, MOUTH_IN, seed + 1, 18.0)
	var b := Crayon.bounds(m)
	if tongue:
		var tg := Crayon.blob(Vector2(O.x + half.x * 0.12, b.end.y - half.y * 0.32),
			Vector2(half.x * 0.52, half.y * 0.5), seed + 2, 16, 0.05)
		_clip_fill(c, tg, m, TONGUE, seed + 3, 16.0)
	for k in teeth:
		var x := O.x + (k - (teeth - 1) * 0.5) * half.x * 0.42
		var tooth := Crayon.rounded_rect(Rect2(x - half.x * 0.17, b.position.y - 10.0,
			half.x * 0.34, half.y * 0.55), 8.0)
		_clip_fill(c, tooth, m, PAPER, seed + 10 + k, 12.0, 6.0)
	if fangs:
		for s in [-1.0, 1.0]:
			var x: float = O.x + s * half.x * 0.42
			var y := b.position.y + half.y * flat * 0.6
			var fang := PackedVector2Array([Vector2(x - 16, y - 20), Vector2(x + 16, y - 20),
				Vector2(x + 2, y + half.y * 0.42)])
			_clip_fill(c, fang, m, PAPER, seed + 20 + int(s), 12.0, 6.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, seed + 5)
	return m


# --- Biscuit: friendly tan puppy, brown patches ----------------------------------------------

const B_TAN := Color("#e8c48f")
const B_BROWN := Color("#b07a4a")

## Marker fill, then a black marker outline, then a few patches - drawn the way a kid would.
static func _biscuit_body(c: CanvasItem) -> void:
	var body := Crayon.blob(Vector2(256, 270), Vector2(200, 120), 61, 20, 0.05)
	_fill(c, body, B_TAN, 62)
	for spot in [[Vector2(190, 240), Vector2(46, 32)], [Vector2(320, 300), Vector2(38, 26)]]:
		var patch := Crayon.blob(spot[0], spot[1], 63, 12, 0.2)
		_clip_fill(c, patch, body, B_BROWN, 64)
	Crayon.marker_line(c, body, INK, W_BODY, 65)


static func _biscuit_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(270, 314), Vector2(100, 92), 101, 20, 0.05)
	var snout := Crayon.blob(Vector2(352, 352), Vector2(66, 48), 102, 16, 0.05)
	var neck_path := _seg(Vector2(208, 410), Vector2(244, 362), 6)
	var neck := _tube(neck_path, 34.0, 34.0)
	var head := _merge_all([skull, neck, snout])
	_fill(c, head, B_TAN, 103)
	_clip_fill(c, Crayon.blob(Vector2(296, 292), Vector2(44, 38), 104, 12, 0.2), head, B_BROWN, 105)
	# a red collar with a gold tag
	_clip_fill(c, _band(neck_path, 0.4, 60.0, 11.0), head, Color("#ff6f7d"), 106, 12.0, 6.0)
	var tag := neck_path[2] + (neck_path[1] - neck_path[0]).normalized().orthogonal() * -30.0
	var tag_poly := Crayon.blob(tag + Vector2(4, 14), Vector2(12, 12), 107, 10, 0.05)
	_part(c, tag_poly, Color("#ffd35c"), 108, 5.0, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 109)
	var nose := Crayon.blob(Vector2(408, 334), Vector2(22, 16), 110, 12, 0.05)
	c.draw_colored_polygon(nose, INK)
	c.draw_circle(Vector2(401, 329), 5.0, Color(1, 1, 1, 0.8))


static func _biscuit_eye(c: CanvasItem) -> void:
	_eye(c, 121, Vector2(64, 70), Color("#8a5a34"), 42.0, Vector2(26, 28), Vector2(8, 6))


static func _biscuit_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 131, Vector2(84, 72), 0.45)


static func _biscuit_ear(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 444), Vector2(256, 400), Vector2(244, 352), Vector2(228, 318), 10)
	var ear := _tube(path, 22.0, 36.0)
	_fill(c, ear, B_BROWN, 141)
	var inner := _tube(_bez(Vector2(252, 420), Vector2(250, 390), Vector2(242, 360), Vector2(232, 330), 8), 8.0, 16.0)
	_clip_fill(c, inner, ear, Color("#d9a675"), 142, 12.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 143)


static func _biscuit_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 214), 6), 30.0, 30.0)
	var paw := Crayon.blob(Vector2(272, 226), Vector2(50, 30), 151, 14, 0.04)
	var shape := _merge(leg, paw)
	_part(c, shape, B_TAN, 152)
	_ink(c, _seg(Vector2(286, 214), Vector2(288, 240), 2), 6.0, 153)
	_ink(c, _seg(Vector2(304, 216), Vector2(306, 240), 2), 6.0, 154)


static func _biscuit_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(474, 262), Vector2(400, 264), Vector2(338, 236), Vector2(318, 150), 14)
	var tail := _tube(path, 25.0, 16.0)
	_fill(c, tail, B_TAN, 161)
	_clip_fill(c, Crayon.blob(Vector2(318, 150), Vector2(38, 44), 162, 12, 0.1), tail, B_BROWN, 163)
	Crayon.marker_line(c, tail, INK, W_BODY, 164)


# --- Zippy: long green lizard, yellow belly --------------------------------------------------

const Z_GREEN := Color("#86d27c")
const Z_DARK := Color("#56a964")
const Z_BELLY := Color("#f6e47c")
const Z_SPIKE := Color("#ffb45c")

static func _zippy_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 262), Vector2(228, 82), 0.35, 201, 28, 0.03)
	_fill(c, body, Z_GREEN, 202)
	_clip_fill(c, Crayon.blob(Vector2(262, 322), Vector2(238, 50), 203, 18, 0.04), body, Z_BELLY, 204)
	var spots := [[Vector2(120, 238), 15.0], [Vector2(190, 222), 20.0], [Vector2(268, 226), 17.0],
		[Vector2(338, 232), 21.0], [Vector2(230, 270), 12.0], [Vector2(306, 268), 13.0]]
	for i in spots.size():
		var at: Vector2 = spots[i][0]
		var r: float = spots[i][1]
		_clip_fill(c, Crayon.blob(at, Vector2(r * 1.2, r), 205 + i, 10, 0.15), body, Z_DARK, 215 + i, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 225)


static func _zippy_head(c: CanvasItem) -> void:
	var back := Crayon.blob(Vector2(286, 350), Vector2(88, 72), 231, 18, 0.04)
	var snout := Crayon.blob(Vector2(376, 366), Vector2(88, 46), 232, 16, 0.04)
	var neck := _tube(_seg(Vector2(206, 414), Vector2(248, 376), 6), 36.0, 36.0)
	var head := _merge_all([back, neck, snout])
	_fill(c, head, Z_GREEN, 233)
	var box := _box(head, W_BODY)
	for i in 3:
		var at := box.position + box.size * Vector2(0.32 + i * 0.1, 0.22 + (i % 2) * 0.06)
		_clip_fill(c, Crayon.blob(at, Vector2(14, 11), 234 + i, 10, 0.15), head, Z_DARK, 240 + i, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 245)
	c.draw_circle(Vector2(446, 350), 6.0, INK)


static func _zippy_eye(c: CanvasItem) -> void:
	_eye(c, 251, Vector2(74, 76), Color("#ffd23f"), 44.0, Vector2(24, 26), Vector2(10, 2))


static func _zippy_mouth(c: CanvasItem) -> void:
	var m := _mouth_shape(Vector2(94, 64), 0.55, 261)
	_fill(c, m, MOUTH_IN, 262, 18.0)
	var tongue := _merge_all([
		_tube(_seg(Vector2(244, 268), Vector2(392, 262), 8), 14.0, 12.0),
		_tube(_seg(Vector2(390, 262), Vector2(428, 240), 4), 10.0, 8.0),
		_tube(_seg(Vector2(390, 262), Vector2(428, 286), 4), 10.0, 8.0)])
	Crayon.marker_line(c, m, INK, W_MOUTH, 263)
	_part(c, tongue, TONGUE, 264, 9.0, 12.0)


static func _zippy_leg(c: CanvasItem) -> void:
	var leg := _tube(_bez(Vector2(256, 66), Vector2(248, 130), Vector2(248, 170), Vector2(262, 208), 8), 28.0, 23.0)
	var foot := Crayon.blob(Vector2(276, 218), Vector2(36, 20), 271, 12, 0.04)
	var toes := []
	for t in [[Vector2(318, 204), 0], [Vector2(322, 232), 1], [Vector2(298, 248), 2]]:
		var tip: Vector2 = t[0]
		toes.append(_tube(_seg(Vector2(282, 220), tip, 4), 10.0, 11.0))
	var shape := _merge_all([leg, foot] + toes)
	_part(c, shape, Z_GREEN, 272)
	_clip_fill(c, Crayon.blob(Vector2(242, 140), Vector2(12, 10), 273, 10, 0.1), shape, Z_DARK, 274, 8.0)


static func _zippy_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(482, 260), Vector2(390, 274), Vector2(250, 268), Vector2(140, 206), 20)
	var tail := _tube(path, 40.0, 8.0)
	_fill(c, tail, Z_GREEN, 281)
	for k in 4:
		var t := 0.28 + k * 0.17
		_clip_fill(c, _band(path, t, 60.0, 9.0 - k), tail, Z_DARK, 282 + k, 10.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 290)


static func _zippy_spike(c: CanvasItem) -> void:
	var left := _bez(Vector2(204, 470), Vector2(214, 420), Vector2(226, 390), Vector2(238, 350), 6)
	var right := _bez(Vector2(238, 350), Vector2(262, 384), Vector2(290, 420), Vector2(306, 470), 6)
	var spike := PackedVector2Array()
	spike.append_array(left)
	right.remove_at(0)
	spike.append_array(right)
	_part(c, spike, Z_SPIKE, 291, W_ANT)


# --- Puffles: round purple fluffball, no legs - it hops --------------------------------------

const P_PURPLE := Color("#c5a6f2")
const P_DARK := Color("#9a78dc")
const P_BLUSH := Color("#f6a2cc")

static func _puffles_body(c: CanvasItem) -> void:
	var ctr := Vector2(256, 262)
	var body := _squircle(ctr, Vector2(194, 174), 3.3, 301, 64, 0.02, 0.055)
	_fill(c, body, P_PURPLE, 302)
	var box := _box(body, W_BODY)
	_clip_fill(c, Crayon.blob(box.position + box.size * Vector2(0.71, 0.46), Vector2(26, 15), 305, 12, 0.08),
		body, P_BLUSH, 306, 10.0)
	# fur flicks round the edge in darker purple, the way a kid scribbles fluff
	for i in 9:
		var a := PI * 0.62 + i * 0.36 + Crayon.noise(308, i) * 0.08
		var dir := Vector2(cos(a), sin(a))
		var at := ctr + Vector2(dir.x * 150.0, dir.y * 134.0)
		Crayon.line(c, at, at + dir * 22.0, P_DARK, 6.0, 310 + i, 1.0)
	Crayon.marker_line(c, body, INK, W_BODY, 307)


static func _puffles_eye(c: CanvasItem) -> void:
	_eye(c, 321, Vector2(70, 76), Color(), 0.0, Vector2(40, 44), Vector2(8, 6))
	c.draw_circle(O + Vector2(28, 28), 8.0, Color.WHITE)


static func _puffles_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 331, Vector2(70, 64), 0.45)


static func _puffles_antenna(c: CanvasItem) -> void:
	var stalk := _bez(Vector2(256, 454), Vector2(250, 390), Vector2(296, 340), Vector2(292, 282), 10)
	_ink(c, stalk, W_ANT, 341)
	var heart := Crayon.heart(Vector2(294, 256), 64.0)
	_part(c, heart, Color("#ff94bf"), 342, W_ANT, 14.0)
	c.draw_circle(Vector2(280, 244), 6.0, Color(1, 1, 1, 0.85))


# --- Captain Fins: orange fish standing on two legs ------------------------------------------

const F_ORANGE := Color("#ff9e5e")
const F_FIN := Color("#93d3ff")
const F_BOOT := Color("#6fb3ee")

static func _fins_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 256), Vector2(208, 128), 0.5, 401, 28, 0.03)
	_fill(c, body, F_ORANGE, 402)
	for i in 2:
		var x := 186.0 + i * 128.0
		var stripe := PackedVector2Array([Vector2(x - 24, 100), Vector2(x + 18, 100),
			Vector2(x + 30, 180), Vector2(x + 22, 260), Vector2(x + 30, 340), Vector2(x + 20, 420),
			Vector2(x - 22, 420), Vector2(x - 12, 340), Vector2(x - 20, 260), Vector2(x - 12, 180)])
		_clip_fill(c, stripe, body, PAPER, 403 + i, 14.0, 6.0)
	Crayon.marker_line(c, body, INK, W_BODY, 410)
	# gill line
	_ink(c, _bez(Vector2(360, 190), Vector2(342, 230), Vector2(342, 290), Vector2(362, 330), 10), 7.0, 411)
	# the captain's anchor badge
	var navy := Color("#3d5a99")
	var a0 := Vector2(252, 222)
	c.draw_arc(a0, 9.0, 0.0, TAU, 16, navy, 5.0, true)
	Crayon.line(c, a0 + Vector2(0, 9), a0 + Vector2(0, 62), navy, 6.0, 415, 1.0)
	Crayon.line(c, a0 + Vector2(-16, 22), a0 + Vector2(16, 22), navy, 6.0, 416, 1.0)
	c.draw_arc(a0 + Vector2(0, 40), 24.0, 0.25, PI - 0.25, 14, navy, 6.0, true)


static func _fins_eye(c: CanvasItem) -> void:
	_eye(c, 421, Vector2(70, 72), Color("#5fa8e8"), 44.0, Vector2(24, 26), Vector2(8, 2))


static func _fins_mouth(c: CanvasItem) -> void:
	var lips := Crayon.blob(O, Vector2(80, 70), 431, 22, 0.035)
	_fill(c, lips, Color("#ff7f9e"), 432, 18.0)
	var hole := Crayon.blob(O + Vector2(4, 0), Vector2(48, 40), 433, 18, 0.05)
	_fill(c, hole, Color("#b23a58"), 434, 14.0)
	Crayon.marker_line(c, hole, INK, 9.0, 435)
	Crayon.marker_line(c, lips, INK, W_MOUTH, 436)
	c.draw_circle(O + Vector2(-34, -40), 8.0, Color(1, 1, 1, 0.8))


static func _fins_fin(c: CanvasItem) -> void:
	var lead := _bez(Vector2(186, 466), Vector2(184, 400), Vector2(196, 336), Vector2(214, 300), 10)
	var trail := _bez(Vector2(214, 300), Vector2(262, 330), Vector2(312, 380), Vector2(326, 466), 10)
	var fin := PackedVector2Array()
	fin.append_array(lead)
	trail.remove_at(0)
	fin.append_array(trail)
	_fill(c, fin, F_FIN, 441)
	for i in 3:
		var base := Vector2(214 + i * 34, 466)
		var tip := Vector2(214 + i * 26, 336 + i * 18)
		_ink(c, _seg(base.lerp(tip, 0.15), base.lerp(tip, 0.82), 4), 6.0, 442 + i)
	Crayon.marker_line(c, fin, INK, W_FIN, 446)


static func _fins_tail(c: CanvasItem) -> void:
	var fan := PackedVector2Array([Vector2(474, 236), Vector2(400, 238), Vector2(340, 196),
		Vector2(290, 156), Vector2(256, 140), Vector2(262, 196), Vector2(292, 256),
		Vector2(262, 316), Vector2(256, 372), Vector2(290, 356), Vector2(340, 316),
		Vector2(400, 274), Vector2(474, 276)])
	fan = Crayon.wobbled(fan, 451, 1.2, true)
	fan.remove_at(fan.size() - 1)
	_fill(c, fan, F_FIN, 452)
	var tips := [Vector2(284, 172), Vector2(306, 256), Vector2(284, 340)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		_ink(c, _seg(Vector2(390, 256), tip, 5), 6.0, 453 + i)
	Crayon.marker_line(c, fan, INK, W_BODY, 457)


static func _fins_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 62), Vector2(256, 196), 6), 16.0, 16.0)
	_part(c, leg, F_ORANGE, 461)
	var boot := _merge(Crayon.rounded_rect(Rect2(214, 176, 82, 86), 20.0),
		Crayon.blob(Vector2(296, 240), Vector2(48, 24), 462, 14, 0.04))
	_fill(c, boot, F_BOOT, 463)
	var cuff := PackedVector2Array([Vector2(200, 170), Vector2(320, 170), Vector2(320, 196),
		Vector2(200, 196)])
	_clip_fill(c, cuff, boot, Color("#bfe0ff"), 464, 10.0)
	Crayon.marker_line(c, boot, INK, W_BODY, 465)


# --- Duchess: fancy pink bird, curly crest, beak as the mouth --------------------------------

const D_PINK := Color("#f7a9cd")
const D_CREAM := Color("#fff0dc")
const D_WING := Color("#e6b2f0")
const D_BEAK := Color("#ffbf52")
const D_CREST := Color("#d983d6")

static func _duchess_body(c: CanvasItem) -> void:
	# tail feathers first, the body goes over them
	var tips := [Vector2(48, 176), Vector2(34, 236), Vector2(52, 296)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		var f := _tube(_seg(Vector2(150, 252), tip, 8), 16.0, 26.0)
		_part(c, f, D_WING if i != 1 else D_CREST, 501 + i * 3)
	var body := _egg(Vector2(280, 262), Vector2(188, 128), 0.45, 511, 26, 0.035)
	_fill(c, body, D_PINK, 512)
	_clip_fill(c, Crayon.blob(Vector2(392, 300), Vector2(84, 74), 513, 16, 0.06), body, D_CREAM, 514)
	Crayon.marker_line(c, body, INK, W_BODY, 515)
	# a fancy little bow where the tail feathers join
	var bow := Vector2(150, 236)
	for s in [-1.0, 1.0]:
		var loop := PackedVector2Array([bow + Vector2(s * 4, 0), bow + Vector2(s * 32, -22),
			bow + Vector2(s * 38, 0), bow + Vector2(s * 34, 20)])
		_part(c, loop, Color("#ff7fae"), 518 + int(s), 6.0, 10.0)
	_part(c, Crayon.blob(bow, Vector2(10, 10), 520, 10, 0.05), Color("#ff7fae"), 521, 6.0, 10.0)


static func _duchess_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(276, 318), Vector2(92, 88), 521, 20, 0.04)
	var neck_path := _seg(Vector2(210, 412), Vector2(246, 366), 6)
	var head := _merge(skull, _tube(neck_path, 34.0, 34.0))
	_fill(c, head, D_PINK, 522)
	var box := _box(head, W_BODY)
	_clip_fill(c, Crayon.blob(box.position + box.size * Vector2(0.6, 0.6), Vector2(22, 14), 523, 10, 0.08),
		head, Color("#ff7fae"), 524, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 525)
	# a pearl necklace across the neck
	var d := (neck_path[6] - neck_path[0]).normalized()
	var n := d.orthogonal()
	var mid := neck_path[2]
	for i in 6:
		var s := (i - 2.5) / 2.5
		var p := mid + n * s * 34.0 + d * (absf(s) * absf(s) * 10.0 - 6.0)
		c.draw_circle(p, 9.0, PAPER)
		c.draw_arc(p, 9.0, 0.0, TAU, 14, INK, 3.5, true)


static func _duchess_eye(c: CanvasItem) -> void:
	_eye(c, 531, Vector2(62, 68), Color(), 0.0, Vector2(30, 34), Vector2(10, 6))
	for i in 3:
		var a := -PI * 0.5 + (i - 0.6) * 0.42
		var root := O + Vector2(cos(a) * 62.0, sin(a) * 68.0)
		var tip := root + Vector2(cos(a), sin(a)) * 40.0 + Vector2(10, -6)
		_ink(c, _bez(root, root.lerp(tip, 0.5) + Vector2(-4, -4), tip, tip, 4), 9.0, 532 + i)


static func _duchess_mouth(c: CanvasItem) -> void:
	var inside := PackedVector2Array([Vector2(204, 256), Vector2(398, 228), Vector2(386, 296)])
	_fill(c, inside, MOUTH_IN, 541, 14.0)
	var upper := PackedVector2Array([Vector2(186, 198), Vector2(260, 200), Vector2(330, 214),
		Vector2(410, 234), Vector2(330, 248), Vector2(250, 252), Vector2(196, 258)])
	var lower := PackedVector2Array([Vector2(196, 258), Vector2(250, 264), Vector2(320, 274),
		Vector2(388, 292), Vector2(320, 302), Vector2(250, 310), Vector2(186, 314)])
	_part(c, lower, D_BEAK.darkened(0.08), 542, W_MOUTH, 16.0)
	_part(c, upper, D_BEAK, 544, W_MOUTH, 16.0)
	c.draw_circle(Vector2(256, 220), 6.0, INK)


static func _duchess_wing(c: CanvasItem) -> void:
	var lead := _bez(Vector2(334, 462), Vector2(372, 400), Vector2(366, 320), Vector2(312, 262), 12)
	var back := _bez(Vector2(312, 262), Vector2(226, 266), Vector2(196, 380), Vector2(266, 462), 24)
	var mid := Vector2(296, 380)
	var wing := PackedVector2Array()
	wing.append_array(lead)
	for i in range(1, back.size()):
		var p := back[i]
		var bump := absf(sin(i / float(back.size() - 1) * PI * 4.0)) * 14.0
		wing.append(p + (p - mid).normalized() * bump)
	_fill(c, wing, D_WING, 551)
	for i in 3:
		var tip := Vector2(262 + i * 24, 300 + i * 6)
		_ink(c, _bez(Vector2(300, 452), Vector2(296, 420), tip + Vector2(10, 40), tip, 6), 5.0, 552 + i)
	Crayon.marker_line(c, wing, INK, W_BODY, 556)


static func _duchess_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 64), Vector2(256, 236), 8), 11.0, 11.0)
	var toes := [_tube(_seg(Vector2(256, 238), Vector2(312, 254), 4), 9.0, 8.0),
		_tube(_seg(Vector2(256, 240), Vector2(294, 264), 4), 9.0, 8.0),
		_tube(_seg(Vector2(256, 238), Vector2(212, 252), 4), 9.0, 8.0)]
	var shape := _merge_all([leg] + toes)
	_part(c, shape, Color("#ffab55"), 561)


static func _duchess_hair(c: CanvasItem) -> void:
	var plumes := [
		[Vector2(286, 426), Vector2(270, 370), Vector2(226, 340), Vector2(222, 290)],
		[Vector2(300, 426), Vector2(302, 370), Vector2(288, 310), Vector2(302, 256)],
		[Vector2(314, 426), Vector2(332, 372), Vector2(374, 344), Vector2(382, 296)]]
	for i in plumes.size():
		var pl: Array = plumes[i]
		var path := _bez(pl[0], pl[1], pl[2], pl[3], 10)
		_part(c, _tube(path, 11.0, 15.0), D_CREST, 571 + i * 4, W_FIN)
		var tip: Vector2 = pl[3]
		var ball := Crayon.blob(tip, Vector2(26, 26), 572 + i * 4, 14, 0.05)
		_part(c, ball, Color("#eea6ea"), 573 + i * 4, W_FIN, 14.0)
		var curl := PackedVector2Array()
		for k in 14:
			var t := k / 13.0
			var a := -PI * 0.5 + t * TAU * 1.2
			curl.append(tip + Vector2(cos(a), sin(a)) * lerpf(18.0, 3.0, t))
		_ink(c, curl, 6.0, 574 + i * 4)


# --- Rocky: chunky blue-grey rock monster, three eyes ----------------------------------------

const R_GREY := Color("#a9b9cc")
const R_DARK := Color("#7f8fa6")
const R_MOSS := Color("#a7d68c")

static func _rocky_body(c: CanvasItem) -> void:
	var base := Crayon.rounded_rect(Rect2(46, 72, 420, 372), 110.0)
	var ctr := Vector2(256, 258)
	var rock := PackedVector2Array()
	# walk the outline, putting a corner every so often: a boulder has facets, not lumps
	var per := 0.0
	for i in base.size():
		per += base[i].distance_to(base[(i + 1) % base.size()])
	var step := per / 22.0
	var travelled := 0.0
	var next := 0.0
	var k := 0
	for i in base.size():
		var a := base[i]
		var b := base[(i + 1) % base.size()]
		var seg_len := a.distance_to(b)
		while next <= travelled + seg_len and k < 22:
			var p := a.lerp(b, (next - travelled) / seg_len)
			rock.append(p + (p - ctr).normalized() * Crayon.noise(601, k) * 9.0)
			k += 1
			next += step
		travelled += seg_len
	_fill(c, rock, R_GREY, 602)
	_clip_fill(c, Crayon.blob(Vector2(150, 84), Vector2(100, 40), 603, 14, 0.15), rock, R_MOSS, 604)
	for s in [[Vector2(120, 330), 12.0], [Vector2(170, 380), 8.0], [Vector2(230, 300), 10.0],
			[Vector2(100, 220), 9.0], [Vector2(300, 400), 11.0], [Vector2(205, 180), 7.0]]:
		var at: Vector2 = s[0]
		var r: float = s[1]
		c.draw_colored_polygon(Crayon.blob(at, Vector2(r, r * 0.85), 605, 10, 0.2), R_DARK)
	Crayon.marker_line(c, rock, INK, W_BODY + 1.0, 610)
	_ink(c, PackedVector2Array([Vector2(88, 150), Vector2(112, 176), Vector2(104, 204),
		Vector2(126, 226)]), 5.0, 611)
	_ink(c, PackedVector2Array([Vector2(190, 432), Vector2(212, 404), Vector2(240, 410),
		Vector2(258, 384)]), 5.0, 612)
	_ink(c, PackedVector2Array([Vector2(286, 92), Vector2(296, 120), Vector2(318, 128)]), 5.0, 613)


static func _rocky_eye(c: CanvasItem) -> void:
	_eye(c, 621, Vector2(62, 64), Color(), 0.0, Vector2(30, 32), Vector2(6, 6))


static func _rocky_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 631, Vector2(94, 70), 0.3, 2)


static func _rocky_arm(c: CanvasItem) -> void:
	# Down to the elbow, then a big fist held out in front - it leaves the body's outline, so
	# it reads as an arm and not as a nose hanging under the eyes.
	var path := _seg(Vector2(256, 72), Vector2(258, 176), 6)
	path.remove_at(path.size() - 1)
	path.append_array(_bez(Vector2(258, 176), Vector2(260, 222), Vector2(292, 236), Vector2(334, 236), 6))
	path.remove_at(path.size() - 1)
	path.append_array(_seg(Vector2(334, 236), Vector2(396, 240), 4))
	var arm := _tube(path, 25.0, 32.0, 0.35)
	var fist := Crayon.blob(Vector2(426, 238), Vector2(50, 48), 641, 14, 0.06)
	var shape := _merge(arm, fist)
	_part(c, shape, R_GREY, 642, W_ARM)
	c.draw_colored_polygon(Crayon.blob(Vector2(250, 130), Vector2(10, 9), 648, 10, 0.2), R_DARK)
	for i in 3:
		var y := 216.0 + i * 22.0
		_ink(c, _seg(Vector2(446, y), Vector2(468, y + 2), 2), 5.0, 643 + i)
	_ink(c, PackedVector2Array([Vector2(300, 222), Vector2(318, 238), Vector2(312, 256)]), 5.0, 647)


static func _rocky_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 124), 6), 42.0, 44.0)
	var foot := Crayon.blob(Vector2(270, 146), Vector2(66, 32), 651, 14, 0.06)
	var shape := _merge(leg, foot)
	_part(c, shape, R_GREY, 652)
	c.draw_colored_polygon(Crayon.blob(Vector2(244, 104), Vector2(9, 8), 653, 10, 0.2), R_DARK)


# --- Noodle: long yellow-green caterpillar, lots of little legs ------------------------------

const N_LIME := Color("#cfe56c")
const N_LIME2 := Color("#b5dc62")
const N_SPOT := Color("#ffb04d")
const N_SHOE := Color("#ff7d6e")

static func _noodle_body(c: CanvasItem) -> void:
	var lift := [10.0, -6.0, 8.0, -4.0, 2.0]
	for i in 5:
		var ctr := Vector2(86 + i * 74, 262 + lift[i])
		var seg := Crayon.blob(ctr, Vector2(80, 84), 701 + i, 18, 0.05)
		_part(c, seg, N_LIME if i % 2 == 0 else N_LIME2, 710 + i * 4)
		c.draw_colored_polygon(Crayon.blob(ctr + Vector2(4, -42), Vector2(15, 13), 730 + i, 10, 0.1), N_SPOT)
		c.draw_arc(ctr + Vector2(4, -42), 15.0, 0.0, TAU, 14, INK, 4.0, true)


static func _noodle_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(282, 312), Vector2(102, 98), 741, 20, 0.04)
	var head := _merge(skull, _tube(_seg(Vector2(208, 412), Vector2(244, 364), 6), 36.0, 36.0))
	_fill(c, head, N_LIME, 742)
	var box := _box(head, W_BODY)
	for x in [0.5, 0.95]:
		_clip_fill(c, Crayon.blob(box.position + box.size * Vector2(x, 0.6), Vector2(20, 14), 743, 10, 0.08),
			head, Color("#ffa2b8"), 744, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 745)


static func _noodle_eye(c: CanvasItem) -> void:
	_eye(c, 751, Vector2(70, 74), Color(), 0.0, Vector2(36, 40), Vector2(8, 4))


static func _noodle_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 761, Vector2(84, 70), 0.35)


static func _noodle_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 132), 4), 19.0, 19.0)
	_part(c, leg, N_LIME2, 771)
	var shoe := Crayon.blob(Vector2(266, 146), Vector2(36, 22), 772, 14, 0.05)
	_part(c, shoe, N_SHOE, 773)
	c.draw_circle(Vector2(282, 140), 5.0, PAPER)


static func _noodle_antenna(c: CanvasItem) -> void:
	var stalk := _bez(Vector2(256, 452), Vector2(250, 390), Vector2(284, 350), Vector2(282, 300), 10)
	_ink(c, stalk, W_ANT, 781)
	var ball := Crayon.blob(Vector2(284, 276), Vector2(26, 26), 782, 14, 0.05)
	_part(c, ball, N_SPOT, 783, W_ANT, 14.0)
	c.draw_circle(Vector2(276, 268), 6.0, Color(1, 1, 1, 0.85))


# --- Mango: orange stripy cat -----------------------------------------------------------------

const M_ORANGE := Color("#f9aa4f")
const M_STRIPE := Color("#e3762b")
const M_CREAM := Color("#fff0d4")
const M_PINK := Color("#f7a3b7")

static func _stripe(x: float, top: float, length: float, w: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x - w, top), Vector2(x + w, top),
		Vector2(x + w * 0.6, top + length * 0.5), Vector2(x + w * 0.2, top + length),
		Vector2(x - w * 0.3, top + length), Vector2(x - w * 0.6, top + length * 0.5)])


static func _mango_body(c: CanvasItem) -> void:
	var body := Crayon.blob(Vector2(256, 262), Vector2(206, 102), 801, 22, 0.04)
	_fill(c, body, M_ORANGE, 802)
	_clip_fill(c, Crayon.blob(Vector2(384, 330), Vector2(84, 52), 803, 14, 0.1), body, M_CREAM, 804)
	for i in 5:
		_clip_fill(c, _stripe(104.0 + i * 64.0, 140.0, 104.0, 16.0), body, M_STRIPE, 805 + i, 12.0)
	Crayon.marker_line(c, body, INK, W_BODY, 812)


static func _mango_head(c: CanvasItem) -> void:
	var ctr := Vector2(284, 312)
	var pts := PackedVector2Array()
	var n := 36
	for i in n:
		var a := TAU * i / n
		var deg := rad_to_deg(a)
		var k := 1.0 + Crayon.noise(821, i) * 0.03
		if ((deg > 5.0 and deg < 50.0) or (deg > 130.0 and deg < 175.0)) and i % 2 == 0:
			k += 0.11
		pts.append(ctr + Vector2(cos(a) * 112.0, sin(a) * 90.0) * k)
	var head := _merge(pts, _tube(_seg(Vector2(208, 412), Vector2(242, 370), 6), 34.0, 34.0))
	_fill(c, head, M_ORANGE, 822)
	var box := _box(head, W_BODY)
	for i in 3:
		_clip_fill(c, _stripe(ctr.x - 34.0 + i * 34.0, box.position.y - 4.0, 50.0 - absf(i - 1) * 12.0, 11.0),
			head, M_STRIPE, 823 + i, 10.0)
	var mouth := box.position + box.size * Vector2(0.82, 0.72)
	_clip_fill(c, Crayon.blob(mouth + Vector2(-6, -10), Vector2(54, 40), 827, 14, 0.06), head, M_CREAM, 828)
	Crayon.marker_line(c, head, INK, W_BODY, 829)
	var nose := PackedVector2Array([mouth + Vector2(-12, -44), mouth + Vector2(12, -44), mouth + Vector2(0, -32)])
	_part(c, nose, M_PINK, 830, 5.0, 8.0)
	for i in 2:
		var y := mouth.y - 30.0 + i * 14.0
		_ink(c, _seg(Vector2(mouth.x - 46, y), Vector2(mouth.x - 96, y - 8 + i * 12), 3), 4.0, 831 + i)


static func _mango_eye(c: CanvasItem) -> void:
	var white := Crayon.blob(O, Vector2(64, 70), 841, 24, 0.035)
	c.draw_colored_polygon(white, PAPER)
	var ir := Crayon.blob(O + Vector2(8, 4), Vector2(46, 50), 842, 18, 0.04)
	_fill(c, ir, Color("#8fd36b"), 843, 14.0)
	Crayon.marker_line(c, ir, INK, 6.0, 844)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(10, 4), Vector2(10, 36), 845, 12, 0.03), INK)
	c.draw_circle(O + Vector2(-8, -18), 9.0, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 846)


static func _mango_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 851, Vector2(78, 68), 0.45, 0, true)


static func _mango_ear(c: CanvasItem) -> void:
	var lead := _bez(Vector2(206, 450), Vector2(214, 380), Vector2(238, 310), Vector2(262, 270), 8)
	var trail := _bez(Vector2(262, 270), Vector2(286, 320), Vector2(304, 384), Vector2(308, 450), 8)
	var ear := PackedVector2Array()
	ear.append_array(lead)
	trail.remove_at(0)
	ear.append_array(trail)
	ear.append(Vector2(256, 462))
	_fill(c, ear, M_ORANGE, 861)
	var inner := PackedVector2Array([Vector2(232, 440), Vector2(260, 322), Vector2(284, 440)])
	_clip_fill(c, inner, ear, M_PINK, 862, 12.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 863)


static func _mango_leg(c: CanvasItem) -> void:
	var path := _seg(Vector2(256, 66), Vector2(256, 236), 8)
	var leg := _tube(path, 26.0, 24.0)
	_fill(c, leg, M_ORANGE, 871)
	for k in 2:
		_clip_fill(c, _band(path, 0.3 + k * 0.28, 40.0, 8.0), leg, M_STRIPE, 872 + k, 10.0)
	Crayon.marker_line(c, leg, INK, W_BODY, 875)
	var paw := Crayon.blob(Vector2(268, 244), Vector2(42, 26), 876, 14, 0.05)
	_part(c, paw, M_CREAM, 877)
	_ink(c, _seg(Vector2(272, 232), Vector2(274, 254), 2), 5.0, 878)
	_ink(c, _seg(Vector2(290, 234), Vector2(292, 254), 2), 5.0, 879)


static func _mango_tail(c: CanvasItem) -> void:
	var low := _bez(Vector2(476, 262), Vector2(390, 270), Vector2(300, 262), Vector2(276, 170), 14)
	var high := _bez(Vector2(276, 170), Vector2(266, 110), Vector2(286, 66), Vector2(330, 70), 10)
	high.remove_at(0)
	var path := PackedVector2Array()
	path.append_array(low)
	path.append_array(high)
	var tail := _tube(path, 22.0, 17.0)
	_fill(c, tail, M_ORANGE, 881)
	for k in 4:
		_clip_fill(c, _band(path, 0.3 + k * 0.15, 40.0, 8.0), tail, M_STRIPE, 882 + k, 10.0)
	_clip_fill(c, Crayon.blob(path[path.size() - 1], Vector2(30, 30), 887, 12, 0.1), tail, M_STRIPE, 888, 10.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 889)
