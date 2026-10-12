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
## them); how each part looks is up to its drawing. "layout" moves a part off its PartTypes
## spot (PetBuilder.layout_on_host: anchor, edge, spread, far) so no two faces sit the same.
##
## Faces follow PartTypes' face convention. Biscuit, Puffles, Rocky, Noodle and Mango are
## THREE-QUARTER faces turned to the right, the way their bodies face: both eyes in the right
## part of the head, the far one near the right outline; the nose (if any) between them but
## nearer the far eye, a little lower, on a muzzle poking out past the outline; the mouth under
## it; the near ear or antenna at the back-left of the head, the far one at the top right.
## Zippy, Captain Fins and Duchess are drawn in true PROFILE - one eye, a snout or beak pointing
## right, the mouth along it - and have nothing paired on the face.
const ROSTER := {
	"biscuit": {"name": "Biscuit", "look": "friendly tan puppy, brown patches",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "leg": 4, "tail": 1},
		"layout": {"eye": {"anchor": [BISCUIT_NOSE.x - 0.072, BISCUIT_NOSE.y - 0.149], "spread": 0.094},
			"mouth": {"anchor": [BISCUIT_NOSE.x + 0.03, BISCUIT_NOSE.y + 0.112]},
			"ear": {"anchor": [BISCUIT_NOSE.x - 0.504, 0.5], "far": [0.571, 0.0]}}},
	"zippy": {"name": "Zippy", "look": "long green lizard, yellow belly",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "leg": 4, "tail": 1, "spike": 4},
		"layout": {"head": {"anchor": [0.9, 0.45], "edge": [1, 0]}, "eye": {"anchor": [0.41, 0.23]},
			"mouth": {"anchor": [0.78, 0.7]}}},
	"puffles": {"name": "Puffles", "look": "round purple fluffball, no legs - it hops",
		"parts": {"eye": 2, "mouth": 1, "antenna": 2},
		"layout": {"eye": {"anchor": [PUFFLES_FACE.x, 0.4], "spread": 0.12},
			"mouth": {"anchor": [PUFFLES_FACE.x + 0.025, 0.6]},
			"antenna": {"anchor": [PUFFLES_FACE.x - 0.28, 0.5], "far": [0.48, 0.0]}}},
	"captain_fins": {"name": "Captain Fins", "look": "orange fish standing on two legs",
		"parts": {"eye": 1, "mouth": 1, "fin": 2, "tail": 1, "leg": 2},
		"layout": {"eye": {"anchor": [0.835, 0.43]}, "mouth": {"anchor": [0.93, 0.56]}}},
	"duchess": {"name": "Duchess", "look": "fancy pink bird, curly crest, beak as the mouth",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "wing": 2, "leg": 2, "hair": 1},
		"layout": {"eye": {"anchor": [0.72, 0.18]}, "mouth": {"anchor": [0.88, 0.28]},
			"hair": {"anchor": [0.5, 0.3], "edge": [0, -1]}}},
	"rocky": {"name": "Rocky", "look": "chunky blue-grey rock monster, three eyes",
		"parts": {"eye": 3, "mouth": 1, "arm": 2, "leg": 2},
		"layout": {"eye": {"anchor": [0.78, 0.28], "spread": 0.12}, "mouth": {"anchor": [0.8, 0.5]}}},
	"noodle": {"name": "Noodle", "look": "long yellow-green caterpillar, lots of little legs",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "leg": 8, "antenna": 2},
		"layout": {"head": {"anchor": [0.88, 0.5], "edge": [0, -1]},
			"eye": {"anchor": [0.73, 0.26], "spread": 0.1}, "mouth": {"anchor": [0.72, 0.46]},
			"antenna": {"anchor": [0.39, 0.5], "far": [0.51, 0.0]}}},
	"mango": {"name": "Mango", "look": "orange stripy cat",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "leg": 4, "tail": 1},
		"layout": {"eye": {"anchor": [MANGO_NOSE.x - 0.061, MANGO_NOSE.y - 0.145], "spread": 0.105},
			"mouth": {"anchor": [MANGO_NOSE.x + 0.022, MANGO_NOSE.y + 0.116]},
			"ear": {"anchor": [MANGO_NOSE.x - 0.384, 0.5], "far": [0.482, 0.0]}}},
}

## Where the face sits, as a fraction of its host's ink box: the nose on Biscuit's and Mango's
## heads, and the middle of the eyes on Puffles' body. The drawing puts its nose (or blushing
## cheeks) there, and ROSTER puts the eyes, mouth and ears round it - so the face holds together
## when the head changes.
const BISCUIT_NOSE := Vector2(0.741, 0.391)
const MANGO_NOSE := Vector2(0.748, 0.505)
const PUFFLES_FACE := Vector2(0.72, 0.4)

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


## The biggest piece of `shape` that lies inside `inside`.
static func _cut(shape: PackedVector2Array, inside: PackedVector2Array) -> PackedVector2Array:
	var best := PackedVector2Array()
	var best_area := -1.0
	for p in Geometry2D.intersect_polygons(shape, inside):
		var ar := _area(p)
		if ar > best_area:
			best_area = ar
			best = p
	return best


## Everything of a sheet above the line from `a` to `b` (a at the left), for lids and brows.
static func _above(a: Vector2, b: Vector2) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-10, -10), Vector2(522, -10), Vector2(522, b.y), b, a,
		Vector2(-10, a.y)])


## A lens round a vertical line - a slit pupil, `half_w` wide at its middle.
static func _slit(top: Vector2, bottom: Vector2, half_w: float, n := 10) -> PackedVector2Array:
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	for i in n + 1:
		var t := i / float(n)
		var p := top.lerp(bottom, t)
		var w := sin(t * PI) * half_w
		left.append(p - Vector2(w, 0))
		right.append(p + Vector2(w, 0))
	right.reverse()
	right.remove_at(0)
	right.remove_at(right.size() - 1)
	left.append_array(right)
	return left


## Two curves (each running left to right) closed into one shape: `top` then `bottom` back.
static func _between(top: PackedVector2Array, bottom: PackedVector2Array) -> PackedVector2Array:
	var out := top.duplicate()
	var back := bottom.duplicate()
	back.reverse()
	back.remove_at(0)
	back.remove_at(back.size() - 1)
	out.append_array(back)
	return out


# There is deliberately no shared eye or mouth: each rival draws its own face in its section
# below, so no two of them come out with the same eyes, mouth or neck.

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


## An eager puppy holds its head up high: the neck rises almost straight up from the dot to a
## round head turned three-quarters to the right, like the rest of it. The face is in the right
## part of the head: a pale muzzle pokes out past the outline with the big black nose on top of
## it (BISCUIT_NOSE), nearer the far eye; the back of the head is plain but for a brown patch
## that runs round the near eye.
static func _biscuit_head(c: CanvasItem) -> void:
	var neck_path := _bez(Vector2(200, 414), Vector2(203, 382), Vector2(210, 350), Vector2(222, 316), 8)
	var neck := _tube(neck_path, 36.0, 33.0)
	var skull := Crayon.blob(Vector2(244, 240), Vector2(110, 98), 101, 22, 0.05)
	var muzzle := Crayon.blob(Vector2(330, 284), Vector2(56, 38), 112, 16, 0.05)
	var head := _merge_all([skull, neck, muzzle])
	var box := _box(head, W_BODY)
	var nose_at := box.position + box.size * BISCUIT_NOSE
	_fill(c, head, B_TAN, 103)
	# the patch goes round the near eye, which ROSTER puts up and to the left of the nose
	_clip_fill(c, Crayon.blob(nose_at + Vector2(-54, -50), Vector2(48, 40), 104, 12, 0.2), head, B_BROWN, 105)
	_clip_fill(c, Crayon.blob(nose_at + Vector2(4, 26), Vector2(50, 32), 102, 14, 0.06), head,
		Color("#f8e6c6"), 111)
	# a red collar with a gold tag hanging at the front
	_clip_fill(c, _band(neck_path, 0.5, 60.0, 11.0), head, Color("#ff6f7d"), 106, 12.0, 6.0)
	var tag_poly := Crayon.blob(neck_path[4] + Vector2(30, 26), Vector2(13, 13), 107, 10, 0.05)
	_part(c, tag_poly, Color("#ffd35c"), 108, 5.0, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 109)
	var nose := Crayon.blob(nose_at, Vector2(24, 16), 110, 12, 0.05)
	c.draw_colored_polygon(nose, INK)
	c.draw_circle(nose_at + Vector2(-8, -5), 5.0, Color(1, 1, 1, 0.8))


const B_EYE := Color("#6b4428")

## A round puppy eye that is all warm brown (no black pupil), gazing UP at you from under a big
## raised eyebrow.
static func _biscuit_eye(c: CanvasItem) -> void:
	var white := Crayon.blob(O, Vector2(58, 62), 121, 24, 0.035)
	c.draw_colored_polygon(white, PAPER)
	var iris := Crayon.blob(O + Vector2(8, -16), Vector2(42, 44), 122, 18, 0.04)
	_clip_fill(c, iris, white, B_EYE, 123, 14.0, 6.0)
	c.draw_circle(O + Vector2(-6, -30), 13.0, Color.WHITE)
	c.draw_circle(O + Vector2(24, 0), 6.0, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 124)
	var brow := _bez(Vector2(192, 186), Vector2(210, 146), Vector2(284, 132), Vector2(328, 162), 10)
	c.draw_colored_polygon(_tube(brow, 11.0, 15.0), INK)
	Crayon.marker_line(c, brow, INK, 16.0, 125, false)


## Panting: a wide happy mouth, corners up, with the tongue lolling out over the bottom lip.
## Shut, the tip of the tongue still pokes out under the line.
static func _biscuit_mouth(c: CanvasItem) -> void:
	var top := _bez(Vector2(166, 200), Vector2(204, 228), Vector2(308, 228), Vector2(346, 200), 12)
	var bottom := _bez(Vector2(166, 200), Vector2(180, 350), Vector2(332, 350), Vector2(346, 200), 14)
	var m := _between(top, bottom)
	_fill(c, m, MOUTH_IN, 131, 18.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 132)
	var tongue := _tube(_seg(Vector2(264, 280), Vector2(270, 342), 6), 40.0, 42.0)
	_part(c, tongue, TONGUE, 133, 11.0, 16.0)
	_ink(c, _seg(Vector2(267, 300), Vector2(270, 358), 3), 6.0, 134)


## A perky puppy ear standing up and leaning back a little, the way both ears sweep back on a
## head turned to the right.
static func _biscuit_ear(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 440), Vector2(256, 408), Vector2(250, 374), Vector2(240, 346), 10)
	var ear := _tube(path, 22.0, 34.0)
	_fill(c, ear, B_BROWN, 141)
	var inner := _tube(_bez(Vector2(255, 418), Vector2(254, 396), Vector2(249, 372), Vector2(243, 354), 8), 8.0, 16.0)
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


## No neck at all: the head carries straight on from the front of the body, low and level, so
## it is drawn to the RIGHT of the dot, not above it. Its back end tucks over the body.
static func _zippy_head(c: CanvasItem) -> void:
	var back := Crayon.blob(Vector2(258, 404), Vector2(80, 60), 231, 18, 0.04)
	var snout := Crayon.blob(Vector2(366, 416), Vector2(98, 42), 232, 16, 0.04)
	var head := _merge(back, snout)
	_fill(c, head, Z_GREEN, 233)
	# the yellow belly carries on under the chin
	_clip_fill(c, Crayon.blob(Vector2(330, 466), Vector2(170, 30), 236, 16, 0.04), head, Z_BELLY, 237)
	for i in 3:
		var at := Vector2(214 + i * 34, 372 + (i % 2) * 14)
		_clip_fill(c, Crayon.blob(at, Vector2(14, 11), 234 + i, 10, 0.15), head, Z_DARK, 240 + i, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 245)
	c.draw_circle(Vector2(450, 400), 6.0, INK)


## A lizard's eye: a green scaly bump with a round YELLOW eye in it, a black slit for a pupil and
## a heavy green lid over the top.
static func _zippy_eye(c: CanvasItem) -> void:
	var bump := Crayon.blob(O, Vector2(86, 78), 251, 22, 0.05)
	_fill(c, bump, Z_GREEN, 252)
	var ball := Crayon.blob(O + Vector2(6, 6), Vector2(54, 52), 253, 20, 0.035)
	_fill(c, ball, Color("#ffd23f"), 254, 14.0)
	c.draw_colored_polygon(_slit(O + Vector2(14, -40), O + Vector2(14, 54), 10.0), INK)
	c.draw_circle(O + Vector2(-16, 16), 8.0, Color.WHITE)
	var lid := _cut(_above(Vector2(150, 236), Vector2(370, 222)), ball)
	_fill(c, lid, Z_DARK, 255, 12.0)
	Crayon.marker_line(c, ball, INK, 9.0, 256)
	_ink(c, _seg(Vector2(196, 234), Vector2(318, 224), 4), 9.0, 257)
	for i in 5:
		var a := PI * 0.75 + i * 0.38
		var at := O + Vector2(cos(a) * 70.0, sin(a) * 64.0)
		c.draw_arc(at, 8.0, a - 1.2, a + 1.2, 6, Z_DARK.darkened(0.25), 4.0, true)
	Crayon.marker_line(c, bump, INK, W_EYE, 258)


static func _zippy_mouth(c: CanvasItem) -> void:
	var m := _mouth_shape(Vector2(108, 72), 0.6, 261)
	_fill(c, m, MOUTH_IN, 262, 18.0)
	var tongue := _merge_all([
		_tube(_seg(Vector2(244, 266), Vector2(414, 262), 8), 14.0, 12.0),
		_tube(_seg(Vector2(412, 262), Vector2(450, 240), 4), 10.0, 8.0),
		_tube(_seg(Vector2(412, 262), Vector2(450, 286), 4), 10.0, 8.0)])
	Crayon.marker_line(c, m, INK, W_MOUTH, 263)
	_part(c, tongue, TONGUE, 264, 9.0, 12.0)


## Short, bent and splayed - an alligator's leg - so Zippy sits low on its belly, not up on
## stilts.
static func _zippy_leg(c: CanvasItem) -> void:
	var leg := _tube(_bez(Vector2(256, 66), Vector2(236, 92), Vector2(244, 116), Vector2(266, 124), 8), 30.0, 22.0)
	var foot := Crayon.blob(Vector2(282, 132), Vector2(34, 17), 271, 12, 0.04)
	var toes := []
	for t in [[Vector2(324, 120), 0], [Vector2(330, 142), 1], [Vector2(306, 156), 2]]:
		var tip: Vector2 = t[0]
		toes.append(_tube(_seg(Vector2(288, 134), tip, 4), 10.0, 10.0))
	var shape := _merge_all([leg, foot] + toes)
	_part(c, shape, Z_GREEN, 272)
	_clip_fill(c, Crayon.blob(Vector2(246, 96), Vector2(11, 9), 273, 10, 0.1), shape, Z_DARK, 274, 8.0)


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
	# rosy cheeks out past the huge eyes (round PUFFLES_FACE, where ROSTER puts them) - the far
	# one tucked closer, as the face is turned three-quarters to the right
	var box := _box(body, W_BODY)
	for i in 2:
		var at := box.position + box.size * Vector2(PUFFLES_FACE.x - 0.21 + i * 0.38, 0.57)
		_clip_fill(c, Crayon.blob(at, Vector2(28, 16), 305 + i * 2, 12, 0.08), body, P_BLUSH, 306 + i * 2, 10.0)
	# fur flicks round the edge in darker purple, the way a kid scribbles fluff
	for i in 9:
		var a := PI * 0.62 + i * 0.36 + Crayon.noise(308, i) * 0.08
		var dir := Vector2(cos(a), sin(a))
		var at := ctr + Vector2(dir.x * 150.0, dir.y * 134.0)
		Crayon.line(c, at, at + dir * 22.0, P_DARK, 6.0, 310 + i, 1.0)
	Crayon.marker_line(c, body, INK, W_BODY, 307)


## HUGE dark eyes with no white at all: deep ink, a purple glow coming up from the bottom, and
## THREE shines - a big one, a middle one and a tiny one.
static func _puffles_eye(c: CanvasItem) -> void:
	var eye := Crayon.blob(O, Vector2(92, 104), 321, 28, 0.025)
	c.draw_colored_polygon(eye, INK)
	var glow := _cut(Crayon.blob(O + Vector2(4, 66), Vector2(76, 44), 322, 18, 0.04), eye)
	_fill(c, glow, Color("#8a63d6"), 323, 14.0)
	c.draw_colored_polygon(_cut(Crayon.blob(O + Vector2(2, 26), Vector2(84, 58), 324, 20, 0.03), eye), INK)
	Crayon.marker_line(c, eye, INK, W_EYE, 325)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(-32, -42), Vector2(26, 30), 326, 14, 0.04), Color.WHITE)
	c.draw_circle(O + Vector2(36, 42), 14.0, Color.WHITE)
	c.draw_circle(O + Vector2(38, -50), 8.0, Color.WHITE)


## A tiny ":3" - two puffy little lobes, like a 3 lying on its back, over a small round
## mouth that only shows when it opens.
static func _puffles_mouth(c: CanvasItem) -> void:
	var m := Crayon.blob(O + Vector2(0, 16), Vector2(30, 46), 331, 16, 0.04)
	_fill(c, m, MOUTH_IN, 332, 14.0)
	_clip_fill(c, Crayon.blob(O + Vector2(2, 50), Vector2(24, 16), 333, 14, 0.05), m, TONGUE, 334, 12.0)
	Crayon.marker_line(c, m, INK, 12.0, 335)
	var lobes := _merge(Crayon.blob(O + Vector2(-27, -40), Vector2(30, 24), 336, 16, 0.03),
		Crayon.blob(O + Vector2(27, -40), Vector2(30, 24), 337, 16, 0.03))
	_part(c, lobes, Color("#e3d0fb"), 338, 12.0, 14.0)


## A wiggly stalk that ends right above where it starts, so the pair stands up straight on
## either side of the eyes instead of both leaning the same way.
static func _puffles_antenna(c: CanvasItem) -> void:
	var stalk := _bez(Vector2(256, 454), Vector2(236, 392), Vector2(282, 344), Vector2(262, 282), 10)
	_ink(c, stalk, W_ANT, 341)
	var heart := Crayon.heart(Vector2(262, 256), 64.0)
	_part(c, heart, Color("#ff94bf"), 342, W_ANT, 14.0)
	c.draw_circle(Vector2(248, 244), 6.0, Color(1, 1, 1, 0.85))


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


## One round fish eye, nearly all pupil, under a big BUSHY white captain's eyebrow that dips
## at the front - stern, but kind.
static func _fins_eye(c: CanvasItem) -> void:
	var white := Crayon.blob(O, Vector2(62, 62), 421, 24, 0.03)
	c.draw_colored_polygon(white, PAPER)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(8, 8), Vector2(42, 42), 422, 18, 0.03), INK)
	c.draw_circle(O + Vector2(-8, -8), 11.0, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 423)
	var tufts := []
	for i in 7:
		var t := i / 6.0
		var at := Vector2(lerpf(176.0, 340.0, t), lerpf(164.0, 192.0, t) - sin(t * PI) * 20.0)
		tufts.append(Crayon.blob(at, Vector2(36, 30) * (1.0 - t * 0.16), 424 + i, 12, 0.08))
	var brow := _merge_all(tufts)
	_part(c, brow, Color("#dfe5ee"), 432, 12.0, 14.0)
	for i in 5:
		var at := Vector2(194.0 + i * 32.0, 160.0 + i * 5.0 - sin(i / 4.0 * PI) * 16.0)
		_ink(c, _seg(at, at + Vector2(18, -10), 2), 5.0, 433 + i)


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


## A long, graceful swan neck: up and a little back from the dot, then curving forward into the
## head - not a straight tube.
static func _duchess_head(c: CanvasItem) -> void:
	var neck_path := _bez(Vector2(200, 414), Vector2(168, 340), Vector2(158, 252), Vector2(228, 198), 14)
	var skull := Crayon.blob(Vector2(276, 180), Vector2(82, 74), 521, 20, 0.04)
	var head := _merge(skull, _tube(neck_path, 32.0, 24.0))
	_fill(c, head, D_PINK, 522)
	Crayon.marker_line(c, head, INK, W_BODY, 525)
	# a pearl necklace low on the neck
	var d := (neck_path[3] - neck_path[1]).normalized()
	var n := d.orthogonal()
	var mid := neck_path[2]
	for i in 6:
		var s := (i - 2.5) / 2.5
		var p := mid + n * s * 32.0 + d * (absf(s) * absf(s) * 10.0 - 6.0)
		c.draw_circle(p, 9.0, PAPER)
		c.draw_arc(p, 9.0, 0.0, TAU, 14, INK, 3.5, true)


## Haughty: a heavy lavender lid half way down, the pupil looking down its beak at you, and
## winged liner flicked out at the back with three long lashes sweeping off it.
static func _duchess_eye(c: CanvasItem) -> void:
	var white := Crayon.blob(O, Vector2(64, 54), 531, 24, 0.03)
	c.draw_colored_polygon(white, PAPER)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(20, 18), Vector2(24, 28), 532, 16, 0.04), INK)
	c.draw_circle(O + Vector2(12, 16), 7.0, Color.WHITE)
	_clip_fill(c, _above(Vector2(150, 254), Vector2(370, 246)), white, Color("#b48be8"), 533, 14.0)
	Crayon.marker_line(c, white, INK, W_EYE, 534)
	_ink(c, _bez(Vector2(322, 246), Vector2(272, 256), Vector2(222, 258), Vector2(184, 244), 8), 15.0, 535)
	# long lashes fanned out from the back corner of the lid
	for i in 3:
		var root := Vector2(194.0 + i * 15.0, 252.0 - i * 2.0)
		var a := PI + 0.25 + i * 0.4
		var dir := Vector2(cos(a), sin(a))
		var tip := root + dir * (72.0 - i * 8.0)
		_ink(c, _bez(root, root + dir * 30.0, tip + Vector2(0, 12), tip, 6), 10.0, 536 + i)


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


## A small beady eye down in a dark hollow, under a chunky ROCK BROW with a crack in it. Three
## of these side by side make one craggy ridge.
static func _rocky_eye(c: CanvasItem) -> void:
	var hollow := Crayon.blob(O + Vector2(0, 8), Vector2(70, 58), 621, 16, 0.08)
	_fill(c, hollow, R_DARK, 622, 14.0)
	var white := Crayon.blob(O + Vector2(4, 16), Vector2(38, 38), 623, 18, 0.04)
	c.draw_colored_polygon(white, PAPER)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(10, 20), Vector2(22, 24), 624, 14, 0.04), INK)
	c.draw_circle(O + Vector2(2, 10), 7.0, Color.WHITE)
	Crayon.marker_line(c, white, INK, 11.0, 625)
	var brow := PackedVector2Array([Vector2(168, 240), Vector2(176, 194), Vector2(212, 166),
		Vector2(268, 160), Vector2(324, 174), Vector2(352, 212), Vector2(346, 242),
		Vector2(300, 234), Vector2(256, 248), Vector2(206, 246)])
	_part(c, brow, R_GREY, 626, W_EYE)
	c.draw_colored_polygon(Crayon.blob(Vector2(306, 198), Vector2(10, 8), 627, 10, 0.2), R_DARK)
	_ink(c, PackedVector2Array([Vector2(236, 170), Vector2(246, 190), Vector2(236, 208),
		Vector2(248, 224)]), 6.0, 628)


## A wide, FLAT, toothy grin: a long slot with blocky stone teeth along the top and the bottom.
static func _rocky_mouth(c: CanvasItem) -> void:
	var slot := Crayon.rounded_rect(Rect2(148, 196, 216, 110), 34.0)
	var m := PackedVector2Array()
	for p in slot:
		var t := (p.x - 256.0) / 108.0
		m.append(p + Vector2(0, -t * t * 14.0 + 6.0))
	_fill(c, m, MOUTH_IN, 631, 18.0)
	for k in 5:
		var x := 162.0 + k * 38.0
		var h := 30.0 + Crayon.noise(632, k) * 6.0
		var tooth := Crayon.rounded_rect(Rect2(x, 180, 36, 40 + h), 6.0)
		_clip_fill(c, tooth, m, Color("#eef1f5"), 633 + k, 10.0, 6.0)
	for k in 4:
		var x := 180.0 + k * 38.0
		var h := 26.0 + Crayon.noise(640, k) * 6.0
		var tooth := Crayon.rounded_rect(Rect2(x, 308 - h, 36, h + 48), 6.0)
		_clip_fill(c, tooth, m, Color("#eef1f5"), 641 + k, 10.0, 6.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 646)


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

## Every segment the same size (NOODLE_SEG), each showing the same amount: they overlap only a
## little, so the front one does not look bigger than the rest. The raised neck segment in the
## head drawing is the same size again.
const NOODLE_SEG := Vector2(62, 64)

static func _noodle_body(c: CanvasItem) -> void:
	var lift := [8.0, -5.0, 7.0, -3.0, 2.0]
	for i in 5:
		var ctr := Vector2(70 + i * 93, 262 + lift[i])
		var seg := Crayon.blob(ctr, NOODLE_SEG, 701 + i, 18, 0.05)
		_part(c, seg, N_LIME if i % 2 == 0 else N_LIME2, 710 + i * 4)
		c.draw_colored_polygon(Crayon.blob(ctr + Vector2(4, -34), Vector2(13, 11), 730 + i, 10, 0.1), N_SPOT)
		c.draw_arc(ctr + Vector2(4, -34), 13.0, 0.0, TAU, 14, INK, 4.0, true)


## Rearing up: one more segment rises straight UP from the front of the body, with the head
## sitting on top of it - drawn as round segments, like the body.
static func _noodle_head(c: CanvasItem) -> void:
	var neck := Crayon.blob(Vector2(210, 362), NOODLE_SEG, 741, 18, 0.05)
	_part(c, neck, N_LIME2, 742)
	c.draw_colored_polygon(Crayon.blob(Vector2(170, 350), Vector2(11, 13), 743, 10, 0.1), N_SPOT)
	c.draw_arc(Vector2(170, 350), 12.0, 0.0, TAU, 14, INK, 4.0, true)
	var head := Crayon.blob(Vector2(236, 250), Vector2(78, 74), 744, 20, 0.04)
	_part(c, head, N_LIME, 745)


## Big round eyes, a bit tall, with TINY pupils - always a little surprised.
static func _noodle_eye(c: CanvasItem) -> void:
	var white := Crayon.blob(O, Vector2(60, 76), 751, 24, 0.03)
	c.draw_colored_polygon(white, PAPER)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(12, -4), Vector2(13, 14), 752, 12, 0.04), INK)
	c.draw_circle(O + Vector2(8, -9), 4.0, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 753)


## A banana of a grin, pointed and curled up at the corners, with a little tongue in it.
static func _noodle_mouth(c: CanvasItem) -> void:
	var top := _bez(Vector2(170, 204), Vector2(214, 248), Vector2(298, 248), Vector2(342, 204), 12)
	var bottom := _bez(Vector2(170, 204), Vector2(190, 340), Vector2(322, 340), Vector2(342, 204), 14)
	var m := _between(top, bottom)
	_fill(c, m, MOUTH_IN, 761, 16.0)
	_clip_fill(c, Crayon.blob(Vector2(266, 292), Vector2(38, 22), 762, 14, 0.05), m, TONGUE, 763, 14.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 764)


static func _noodle_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 132), 4), 19.0, 19.0)
	_part(c, leg, N_LIME2, 771)
	var shoe := Crayon.blob(Vector2(266, 146), Vector2(36, 22), 772, 14, 0.05)
	_part(c, shoe, N_SHOE, 773)
	c.draw_circle(Vector2(282, 140), 5.0, PAPER)


## Nearly straight up with a little wiggle, the bobble right over the root, so the pair stands
## on either side of the eyes instead of both leaning the same way.
static func _noodle_antenna(c: CanvasItem) -> void:
	var stalk := _bez(Vector2(256, 452), Vector2(246, 392), Vector2(270, 348), Vector2(260, 300), 10)
	_ink(c, stalk, W_ANT, 781)
	var ball := Crayon.blob(Vector2(260, 276), Vector2(26, 26), 782, 14, 0.05)
	_part(c, ball, N_SPOT, 783, W_ANT, 14.0)
	c.draw_circle(Vector2(252, 268), 6.0, Color(1, 1, 1, 0.85))


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


## A short neck - the head sits low and level, just up and forward of the dot - turned
## three-quarters to the right like the rest of it. The fluffy cheek tufts are on the back
## (left) of the head; on the right a little muzzle pokes out past the outline, with the pink
## nose on it (MANGO_NOSE), nearer the far eye, on two cream whisker pads. The near whiskers
## sweep back across the cheek; the far ones are short, foreshortened.
static func _mango_head(c: CanvasItem) -> void:
	var ctr := Vector2(300, 340)
	var pts := PackedVector2Array()
	var n := 36
	for i in n:
		var a := TAU * i / n
		var deg := rad_to_deg(a)
		var k := 1.0 + Crayon.noise(821, i) * 0.03
		if deg > 130.0 and deg < 175.0 and i % 2 == 0:
			k += 0.11
		pts.append(ctr + Vector2(cos(a) * 112.0, sin(a) * 90.0) * k)
	var muzzle := Crayon.blob(Vector2(394, 366), Vector2(38, 30), 838, 14, 0.04)
	var head := _merge_all([pts, muzzle, _tube(_seg(Vector2(200, 414), Vector2(226, 392), 4), 34.0, 34.0)])
	_fill(c, head, M_ORANGE, 822)
	var box := _box(head, W_BODY)
	# forehead stripes over the middle of the turned face, not the middle of the head
	for i in 3:
		_clip_fill(c, _stripe(ctr.x - 4.0 + i * 34.0, box.position.y - 4.0, 50.0 - absf(i - 1) * 12.0, 11.0),
			head, M_STRIPE, 823 + i, 10.0)
	var nose_at := box.position + box.size * MANGO_NOSE
	var pads := _merge(Crayon.blob(nose_at + Vector2(-14, 19), Vector2(26, 20), 827, 14, 0.06),
		Crayon.blob(nose_at + Vector2(20, 18), Vector2(28, 21), 834, 14, 0.06))
	_clip_fill(c, pads, head, M_CREAM, 828)
	Crayon.marker_line(c, head, INK, W_BODY, 829)
	# whiskers stay inside the head so its ink box stays the head's
	for i in 2:
		var near := nose_at + Vector2(-30.0, 14.0 + i * 12.0)
		_ink(c, _seg(near, near + Vector2(-54.0, -8.0 + i * 14.0), 3), 4.0, 831 + i)
		var far := nose_at + Vector2(36.0, 14.0 + i * 12.0)
		_ink(c, _seg(far, far + Vector2(22.0, -4.0 + i * 8.0), 2), 4.0, 833 + i)
	_ink(c, _seg(nose_at + Vector2(0, 6), nose_at + Vector2(0, 18), 2), 4.0, 836)
	var nose := PackedVector2Array([nose_at + Vector2(-13, -7), nose_at + Vector2(13, -7), nose_at + Vector2(0, 7)])
	_part(c, nose, M_PINK, 830, 5.0, 8.0)


## A green ALMOND - pointed at both ends and tipped up at the front - all green, no white,
## with a tall black slit for a pupil.
static func _mango_eye(c: CanvasItem) -> void:
	var top := _bez(Vector2(186, 274), Vector2(207, 216), Vector2(286, 200), Vector2(328, 242), 12)
	var bottom := _bez(Vector2(186, 274), Vector2(226, 309), Vector2(300, 298), Vector2(328, 242), 12)
	var eye := _between(top, bottom)
	_fill(c, eye, Color("#8fd36b"), 841, 14.0)
	_clip_fill(c, Crayon.blob(O + Vector2(4, 26), Vector2(68, 23), 842, 14, 0.05), eye, Color("#5fae4a"), 843, 12.0)
	c.draw_colored_polygon(_cut(_slit(Vector2(263, 210), Vector2(261, 302), 11.0), eye), INK)
	c.draw_circle(Vector2(238, 240), 8.0, Color.WHITE)
	Crayon.marker_line(c, eye, INK, W_EYE, 846)


## The cat "w": the top lip dips twice and meets under the nose; one fang hangs off it.
static func _mango_mouth(c: CanvasItem) -> void:
	var top := _bez(Vector2(176, 214), Vector2(184, 244), Vector2(242, 248), Vector2(256, 212), 8)
	var right := _bez(Vector2(256, 212), Vector2(270, 248), Vector2(328, 244), Vector2(336, 214), 8)
	right.remove_at(0)
	top.append_array(right)
	var bottom := _bez(Vector2(176, 214), Vector2(194, 330), Vector2(318, 330), Vector2(336, 214), 14)
	var m := _between(top, bottom)
	_fill(c, m, MOUTH_IN, 851, 16.0)
	_clip_fill(c, Crayon.blob(Vector2(262, 282), Vector2(44, 22), 852, 14, 0.05), m, TONGUE, 853, 14.0)
	var fang := PackedVector2Array([Vector2(282, 224), Vector2(314, 224), Vector2(300, 276)])
	_clip_fill(c, fang, m, PAPER, 854, 12.0, 6.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 855)


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
