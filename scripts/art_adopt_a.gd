class_name ArtAdoptA
extends RefCounted
## Meadow and forest friends - pets a kid can meet and adopt in the shop's Adopt tab. Drawn as if OTHER KIDS
## drew them, in marker with black outlines, part by part, exactly the way the game asks a kid
## to draw, and assembled by the same PetBuilder.add_parts a kid's own pet goes through
## (Roster.assemble). Baked to res://art/adopt_a/ by tools/bake_art.gd; the assembled view is
## .shots/art_adopt_a_assembled.png.
##
## Style reference: scripts/art_rivals.gd - read it first. Marker fills on an opaque base, black
## (#1f1d24) marker outlines (creatures own black), a kid's wobble, simple patches and spots.
##
## Each part is drawn on the sheet a kid would get for it, starting from the same red dot, at
## the same zoom - PartTypes.TYPES[type]["dot"] and ["zoom"] (scripts/part_types.gd). The dot is
## the asset's pivot. Ids are "<creature>_<part key>"; a key like "claw_on_arm" is a claw drawn
## for an arm (drawn exactly like any other claw). The body has no dot (pivot "center").

const INK := Color("#1f1d24")

## Who they are and what they are made of. Names and parts are fixed (game code uses them); how
## each part looks is up to its drawing.
const ROSTER := {
	"pip": {"name": "Pip", "look": "tiny cream mouse-bunny, enormous round ears, pink nose",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "nose": 1, "leg": 4, "tail": 1}},
	"bramble": {"name": "Bramble", "look": "brown hedgehog with a back full of spikes",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "nose": 1, "leg": 4, "spike": 5}},
	"moss": {"name": "Moss", "look": "green turtle with a mossy shell on its back (the shell is its other part)",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "leg": 4, "other": 1, "tail": 1}},
	"clover": {"name": "Clover", "look": "little spotted fawn with flowery antlers",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "horn": 2, "leg": 4, "tail": 1}},
	"tank": {"name": "Tank", "look": "chunky blue-grey rhino-armadillo with one big horn and stompy feet",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "horn": 1, "leg": 4, "foot": 1, "tail": 1}},
	"waffles": {"name": "Waffles", "look": "fluffy cream sheepdog, a mane of hair flopping over its eyes",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "hair": 1, "leg": 4, "tail": 1}},
	"sprocket": {"name": "Sprocket", "look": "orange fox with a giant white-tipped tail",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "nose": 1, "leg": 4, "tail": 1}},
	"pudding": {"name": "Pudding", "look": "round pink pig, snout nose, curly tail",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "nose": 1, "leg": 4, "tail": 1}},
	"boulder": {"name": "Boulder", "look": "huge gentle shaggy yak, curved horns, big hooves",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "horn": 2, "hair": 1, "leg": 4, "foot": 1, "tail": 1}},
	"dottie": {"name": "Dottie", "look": "red ladybug-puppy with spots, two antennae and six little legs",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "antenna": 2, "leg": 6}},
}


static func assets() -> Dictionary:
	var out := {}
	for id in ROSTER:
		out[id + "_body"] = {"pivot": "center"}
		for key in ROSTER[id]["parts"]:
			var type: String = Roster.split_key(key)[0]
			out["%s_%s" % [id, key]] = {"pivot": PartTypes.info(type)["dot"]}
	return out


static func draw(id: String, c: CanvasItem) -> void:
	match id:
		"pip_body": _pip_body(c)
		"pip_head": _pip_head(c)
		"pip_eye": _pip_eye(c)
		"pip_mouth": _pip_mouth(c)
		"pip_ear": _pip_ear(c)
		"pip_nose": _pip_nose(c)
		"pip_leg": _pip_leg(c)
		"pip_tail": _pip_tail(c)
		"bramble_body": _bramble_body(c)
		"bramble_head": _bramble_head(c)
		"bramble_eye": _bramble_eye(c)
		"bramble_mouth": _bramble_mouth(c)
		"bramble_nose": _bramble_nose(c)
		"bramble_leg": _bramble_leg(c)
		"bramble_spike": _bramble_spike(c)
		"moss_body": _moss_body(c)
		"moss_head": _moss_head(c)
		"moss_eye": _moss_eye(c)
		"moss_mouth": _moss_mouth(c)
		"moss_leg": _moss_leg(c)
		"moss_other": _moss_other(c)
		"moss_tail": _moss_tail(c)
		"clover_body": _clover_body(c)
		"clover_head": _clover_head(c)
		"clover_eye": _clover_eye(c)
		"clover_mouth": _clover_mouth(c)
		"clover_ear": _clover_ear(c)
		"clover_horn": _clover_horn(c)
		"clover_leg": _clover_leg(c)
		"clover_tail": _clover_tail(c)
		"tank_body": _tank_body(c)
		"tank_head": _tank_head(c)
		"tank_eye": _tank_eye(c)
		"tank_mouth": _tank_mouth(c)
		"tank_horn": _tank_horn(c)
		"tank_leg": _tank_leg(c)
		"tank_foot": _tank_foot(c)
		"tank_tail": _tank_tail(c)
		"waffles_body": _waffles_body(c)
		"waffles_head": _waffles_head(c)
		"waffles_eye": _waffles_eye(c)
		"waffles_mouth": _waffles_mouth(c)
		"waffles_ear": _waffles_ear(c)
		"waffles_hair": _waffles_hair(c)
		"waffles_leg": _waffles_leg(c)
		"waffles_tail": _waffles_tail(c)
		"sprocket_body": _sprocket_body(c)
		"sprocket_head": _sprocket_head(c)
		"sprocket_eye": _sprocket_eye(c)
		"sprocket_mouth": _sprocket_mouth(c)
		"sprocket_ear": _sprocket_ear(c)
		"sprocket_nose": _sprocket_nose(c)
		"sprocket_leg": _sprocket_leg(c)
		"sprocket_tail": _sprocket_tail(c)
		"pudding_body": _pudding_body(c)
		"pudding_head": _pudding_head(c)
		"pudding_eye": _pudding_eye(c)
		"pudding_mouth": _pudding_mouth(c)
		"pudding_ear": _pudding_ear(c)
		"pudding_nose": _pudding_nose(c)
		"pudding_leg": _pudding_leg(c)
		"pudding_tail": _pudding_tail(c)
		"boulder_body": _boulder_body(c)
		"boulder_head": _boulder_head(c)
		"boulder_eye": _boulder_eye(c)
		"boulder_mouth": _boulder_mouth(c)
		"boulder_horn": _boulder_horn(c)
		"boulder_hair": _boulder_hair(c)
		"boulder_leg": _boulder_leg(c)
		"boulder_foot": _boulder_foot(c)
		"boulder_tail": _boulder_tail(c)
		"dottie_body": _dottie_body(c)
		"dottie_head": _dottie_head(c)
		"dottie_eye": _dottie_eye(c)
		"dottie_mouth": _dottie_mouth(c)
		"dottie_antenna": _dottie_antenna(c)
		"dottie_leg": _dottie_leg(c)
		_:
			pass


# --- Kid-drawing helpers (the same kit as ArtRivals, kept here so this file stands alone) -----

const PAPER := Color("#fffdf8")
const MOUTH_IN := Color("#c9405e")
const TONGUE := Color("#ff92ab")
const O := Vector2(256, 256)   # the eye and mouth dot

# Line widths: about the same thickness once each sheet is shrunk by its zoom.
const W_BODY := 9.0
const W_EYE := 15.0
const W_MOUTH := 14.0
const W_NOSE := 13.0
const W_EAR := 13.0
const W_HORN := 13.0
const W_FOOT := 13.0
const W_ANT := 12.0
const W_SPIKE := 12.0
const W_HAIR := 11.0


## Marker colour on white paper: an opaque paper-tinted base, then the felt-tip streaks over it.
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


## Solid black (or any flat colour) only where it overlaps `inside` - ladybug spots.
static func _clip_solid(c: CanvasItem, shape: PackedVector2Array, inside: PackedVector2Array,
		color: Color) -> void:
	for piece in Geometry2D.intersect_polygons(shape, inside):
		c.draw_colored_polygon(piece, color)


## An open black marker stroke.
static func _ink(c: CanvasItem, pts: PackedVector2Array, width: float, seed: int) -> void:
	Crayon.marker_line(c, pts, INK, width, seed, false)


## An open stroke, only the bits of it that fall inside `inside`.
static func _ink_in(c: CanvasItem, pts: PackedVector2Array, inside: PackedVector2Array,
		width: float, seed: int, color := INK) -> void:
	var k := 0
	for piece in Geometry2D.intersect_polyline_with_polygon(pts, inside):
		if piece.size() >= 2:
			Crayon.marker_line(c, piece, color, width, seed + k, false)
		k += 1


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


## A rounded-square blob (superellipse).
static func _squircle(center: Vector2, r: Vector2, e: float, seed: int, count := 40,
		lumpy := 0.03) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in count:
		var a := TAU * i / count
		var cx := cos(a)
		var sy := sin(a)
		var x := signf(cx) * pow(absf(cx), 2.0 / e)
		var y := signf(sy) * pow(absf(sy), 2.0 / e)
		var k := 1.0 + Crayon.noise(seed, i) * lumpy
		pts.append(center + Vector2(x * r.x, y * r.y) * k)
	return pts


## A fluffy cloud of a shape: an ellipse whose edge is a row of round bumps - fur, a mop, a
## pom-pom, a flower's petals.
static func _fluffy(center: Vector2, r: Vector2, seed: int, bumps: int, depth: float,
		count := 96, lumpy := 0.02, phase := 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in count:
		var a := TAU * i / count
		var bump := pow(absf(sin((a + phase) * bumps * 0.5)), 0.6)
		var k := 1.0 - depth + depth * bump + Crayon.noise(seed, i) * lumpy
		pts.append(center + Vector2(cos(a) * r.x, sin(a) * r.y) * k)
	return pts


## A band straight across a path at fraction `t`, for stripes, cuffs and rings.
static func _band(path: PackedVector2Array, t: float, half_len: float,
		thick: float, slant := 0.0) -> PackedVector2Array:
	var i := clampi(roundi(t * (path.size() - 1)), 1, path.size() - 1)
	var p := path[i]
	var d := (path[i] - path[i - 1]).normalized()
	var n := d.orthogonal()
	return PackedVector2Array([p - d * thick + n * half_len + d * slant,
		p + d * thick + n * half_len + d * slant, p + d * thick - n * half_len - d * slant,
		p - d * thick - n * half_len - d * slant])


## One side of a shape from a to b, bowed outward (away from `inside`) by `bulge` of its length.
static func _side(a: Vector2, b: Vector2, inside: Vector2, bulge: float, n := 10) -> PackedVector2Array:
	var d := b - a
	var nrm := d.orthogonal().normalized()
	if nrm.dot(inside - (a + b) * 0.5) > 0.0:
		nrm = -nrm
	var k := d.length() * bulge
	return _bez(a, a + d * 0.3 + nrm * k, a + d * 0.7 + nrm * k, b, n)


## A pointy shape - an ear, a quill: up one side to the tip, down the other, flat across the base.
static func _point(bl: Vector2, br: Vector2, tip: Vector2, bulge := 0.12) -> PackedVector2Array:
	var mid := (bl + br + tip) / 3.0
	var out := _side(bl, tip, mid, bulge)
	var down := _side(tip, br, mid, bulge)
	down.remove_at(0)
	out.append_array(down)
	return out


## A leaf, pointed at both ends.
static func _leaf(a: Vector2, b: Vector2, bulge := 0.3) -> PackedVector2Array:
	var mid := (a + b) * 0.5
	var d := (b - a).orthogonal().normalized()
	var one := _side(a, b, mid + d, bulge)
	var two := _side(b, a, mid - d, bulge)
	two.remove_at(0)
	two.remove_at(two.size() - 1)
	one.append_array(two)
	return one


## A little five-petal flower with a round middle.
static func _flower(c: CanvasItem, at: Vector2, r: float, petal: Color, middle: Color, seed: int,
		width: float) -> void:
	var petals := _fluffy(at, Vector2(r, r), seed, 5, 0.45, 60, 0.02, 0.3)
	_part(c, petals, petal, seed + 1, width, 10.0)
	var mid := Crayon.blob(at, Vector2(r * 0.36, r * 0.36), seed + 2, 10, 0.06)
	_part(c, mid, middle, seed + 3, width * 0.6, 8.0)


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


## Eyelashes flicking up off the top of an eye of radius `r`.
static func _lashes(c: CanvasItem, seed: int, r: Vector2, n := 3) -> void:
	for i in n:
		var a := -PI * 0.5 + (i - 0.4) * 0.42
		var root := O + Vector2(cos(a) * r.x, sin(a) * r.y)
		var tip := root + Vector2(cos(a), sin(a)) * 36.0 + Vector2(10, -6)
		_ink(c, _bez(root, root.lerp(tip, 0.5) + Vector2(-4, -4), tip, tip, 4), 9.0, seed + i)


## A mouth drawn wide open round the dot: flat-ish top, round bottom, centred top-to-bottom.
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


## A round black nose with a shine, sticking out to the right of the nose dot (180, 256).
static func _button_nose(c: CanvasItem, seed: int, r: Vector2) -> void:
	var nose := Crayon.blob(Vector2(178 + r.x, 256), r, seed, 14, 0.04)
	c.draw_colored_polygon(nose, INK)
	Crayon.marker_line(c, nose, INK, W_NOSE, seed + 1)
	c.draw_circle(Vector2(178 + r.x * 0.7, 256 - r.y * 0.4), r.y * 0.24, Color(1, 1, 1, 0.85))


## Hair drawn lock by lock, back to front: each a tapering curl along [base, c1, c2, tip] with
## its own outline and a strand down the middle.
static func _locks(c: CanvasItem, curves: Array, color: Color, strand: Color, seed: int,
		w0 := 28.0, w1 := 5.0, width := W_HAIR) -> void:
	for i in curves.size():
		var k: Array = curves[i]
		var path := _bez(k[0], k[1], k[2], k[3], 12)
		var lock := _tube(path, w0, w1, 1.0, 1.4 if w1 < 10.0 else 1.0)
		_fill(c, lock, color, seed + i * 4, 18.0)
		Crayon.marker_line(c, path.slice(3, 9), strand, 4.0, seed + i * 4 + 1, false)
		Crayon.marker_line(c, lock, INK, width, seed + i * 4 + 2)


## A few wavy fur strokes, kept inside `inside`.
static func _fur(c: CanvasItem, spots: Array, inside: PackedVector2Array, color: Color, seed: int,
		length := 34.0, width := 5.0) -> void:
	var room := Geometry2D.offset_polygon(inside, -10.0)
	if room.is_empty():
		return
	var area: PackedVector2Array = room[0]
	for i in spots.size():
		var at: Vector2 = spots[i]
		var s := _bez(at, at + Vector2(length * 0.3, length * 0.3), at + Vector2(-length * 0.3, length * 0.6),
			at + Vector2(length * 0.1, length), 6)
		_ink_in(c, s, area, width, seed + i * 3, color)


# --- Pip: tiny cream mouse-bunny, enormous round ears, pink nose -----------------------------

const PI_CREAM := Color("#f5dcb8")
const PI_LIGHT := Color("#fff5e6")
const PI_TAN := Color("#e8bf8c")
const PI_PINK := Color("#f9a9c0")
const PI_ROSE := Color("#f47f9f")

static func _pip_body(c: CanvasItem) -> void:
	var body := Crayon.blob(Vector2(256, 262), Vector2(164, 122), 1001, 22, 0.05)
	_fill(c, body, PI_CREAM, 1002)
	_clip_fill(c, Crayon.blob(Vector2(326, 320), Vector2(104, 66), 1003, 14, 0.08), body, PI_LIGHT, 1004)
	_clip_fill(c, Crayon.blob(Vector2(186, 210), Vector2(44, 32), 1005, 12, 0.18), body, PI_TAN, 1006)
	_clip_fill(c, Crayon.blob(Vector2(244, 174), Vector2(24, 18), 1007, 10, 0.18), body, PI_TAN, 1008)
	Crayon.marker_line(c, body, INK, W_BODY, 1009)


static func _pip_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(282, 306), Vector2(104, 96), 1011, 22, 0.04)
	var muzzle := Crayon.blob(Vector2(360, 344), Vector2(50, 40), 1012, 14, 0.05)
	var neck := _tube(_seg(Vector2(206, 412), Vector2(246, 362), 6), 32.0, 32.0)
	var head := _merge_all([skull, neck, muzzle])
	_fill(c, head, PI_CREAM, 1013)
	_clip_fill(c, Crayon.blob(Vector2(368, 352), Vector2(46, 34), 1014, 12, 0.06), head, PI_LIGHT, 1015)
	_clip_fill(c, Crayon.blob(Vector2(306, 354), Vector2(24, 15), 1016, 10, 0.08), head, PI_PINK, 1017, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1018)


static func _pip_eye(c: CanvasItem) -> void:
	_eye(c, 1021, Vector2(60, 66), Color(), 0.0, Vector2(42, 48), Vector2(6, 6))
	c.draw_circle(O + Vector2(24, 30), 8.0, Color.WHITE)


static func _pip_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1031, Vector2(68, 60), 0.35, 2)


static func _pip_ear(c: CanvasItem) -> void:
	# one big round ear sitting right down on the head - no stalk, so it reads as attached
	var ear := Crayon.blob(Vector2(228, 306), Vector2(156, 158), 1041, 24, 0.035)
	_fill(c, ear, PI_CREAM, 1042)
	_clip_fill(c, Crayon.blob(Vector2(232, 302), Vector2(106, 110), 1043, 18, 0.05), ear, PI_PINK, 1044, 18.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 1045)


static func _pip_nose(c: CanvasItem) -> void:
	var angles := [-0.55, -0.2, 0.2, 0.55]
	for i in angles.size():
		var a: float = angles[i]
		var from := Vector2(244, 256)
		_ink(c, _seg(from, from + Vector2(cos(a), sin(a)) * 112.0, 4), 6.0, 1051 + i)
	var nose := Crayon.blob(Vector2(222, 256), Vector2(44, 38), 1055, 14, 0.05)
	_part(c, nose, PI_ROSE, 1056, W_NOSE, 14.0)
	c.draw_circle(Vector2(210, 242), 9.0, Color(1, 1, 1, 0.85))


static func _pip_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 140), 6), 30.0, 28.0)
	var paw := Crayon.blob(Vector2(270, 154), Vector2(46, 28), 1061, 14, 0.04)
	_part(c, _merge(leg, paw), PI_CREAM, 1062)
	_ink(c, _seg(Vector2(286, 146), Vector2(288, 172), 2), 6.0, 1063)
	_ink(c, _seg(Vector2(302, 148), Vector2(304, 172), 2), 6.0, 1064)


static func _pip_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(476, 262), Vector2(404, 296), Vector2(310, 296), Vector2(282, 212), 14)
	_part(c, _tube(path, 13.0, 9.0), PI_PINK, 1071)
	var pom := _fluffy(Vector2(280, 190), Vector2(50, 48), 1072, 9, 0.16)
	_part(c, pom, PI_LIGHT, 1073)


# --- Bramble: brown hedgehog with a back full of spikes --------------------------------------

const BR_SAND := Color("#e0ad78")
const BR_QUILL := Color("#94643f")
const BR_TIP := Color("#f7e4bf")
const BR_FACE := Color("#f8e2bb")
const BR_PAW := Color("#c98f5d")
const BR_PINK := Color("#f6a8a8")

static func _bramble_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 270), Vector2(204, 114), 0.2, 1101, 28, 0.03)
	_fill(c, body, BR_SAND, 1102)
	_clip_fill(c, Crayon.blob(Vector2(372, 334), Vector2(116, 56), 1103, 14, 0.06), body, BR_FACE, 1104)
	# the quilly back: darker brown over the top, a zig-zag where it meets the tummy
	var back := PackedVector2Array([Vector2(10, 20), Vector2(502, 20), Vector2(502, 168)])
	for i in 19:
		var t := i / 18.0
		var p := Vector2(476, 182).lerp(Vector2(26, 318), t)
		back.append(p + Vector2(0, 14.0 if i % 2 == 1 else -10.0))
	back.append(Vector2(10, 330))
	_clip_fill(c, back, body, BR_QUILL, 1105)
	var inner := Geometry2D.offset_polygon(body, -16.0)
	if not inner.is_empty():
		var room: PackedVector2Array = inner[0]
		var k := 0
		for row in 5:
			for col in 13:
				var p := Vector2(66 + col * 30 + (row % 2) * 15, 176 + row * 28)
				if Geometry2D.is_point_in_polygon(p + Vector2(0, 18), back) \
						and Geometry2D.is_point_in_polygon(p, room) \
						and Geometry2D.is_point_in_polygon(p + Vector2(-14, -12), room):
					Crayon.line(c, p, p + Vector2(-14, -12), BR_TIP, 5.0, 1110 + k, 0.6)
					k += 1
	Crayon.marker_line(c, body, INK, W_BODY, 1109)


static func _bramble_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(268, 318), Vector2(92, 86), 1121, 20, 0.04)
	var snout := _tube(_seg(Vector2(322, 336), Vector2(424, 342), 6), 46.0, 20.0)
	var neck := _tube(_seg(Vector2(206, 412), Vector2(240, 366), 6), 34.0, 34.0)
	var head := _merge_all([skull, neck, snout])
	_fill(c, head, BR_FACE, 1122)
	# a prickly cap over the back of the head
	var cap := PackedVector2Array([Vector2(120, 180), Vector2(300, 180)])
	for i in 11:
		var t := i / 10.0
		var p := Vector2(306, 214).lerp(Vector2(196, 432), t)
		cap.append(p + Vector2(14.0 if i % 2 == 1 else -8.0, 0))
	cap.append(Vector2(120, 470))
	_clip_fill(c, cap, head, BR_QUILL, 1123)
	_clip_fill(c, Crayon.blob(Vector2(330, 374), Vector2(22, 14), 1124, 10, 0.08), head, BR_PINK, 1125, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1126)


static func _bramble_eye(c: CanvasItem) -> void:
	_eye(c, 1131, Vector2(64, 68), Color(), 0.0, Vector2(38, 42), Vector2(8, 4))


static func _bramble_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1141, Vector2(66, 56), 0.4)


static func _bramble_nose(c: CanvasItem) -> void:
	_button_nose(c, 1151, Vector2(44, 40))


static func _bramble_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 146), 6), 26.0, 24.0)
	var foot := Crayon.blob(Vector2(268, 160), Vector2(42, 22), 1161, 12, 0.05)
	_part(c, _merge(leg, foot), BR_PAW, 1162)
	_ink(c, _seg(Vector2(284, 152), Vector2(286, 176), 2), 5.0, 1163)
	_ink(c, _seg(Vector2(298, 154), Vector2(300, 176), 2), 5.0, 1164)


static func _bramble_spike(c: CanvasItem) -> void:
	# a little fan of quills, swept back the way a hedgehog's lie
	var quills := [[Vector2(226, 470), Vector2(282, 470), Vector2(160, 338)],
		[Vector2(236, 470), Vector2(296, 470), Vector2(308, 342)],
		[Vector2(222, 470), Vector2(290, 470), Vector2(230, 306)]]
	for i in quills.size():
		var q: Array = quills[i]
		var bl: Vector2 = q[0]
		var br: Vector2 = q[1]
		var tip: Vector2 = q[2]
		var shape := _point(bl, br, tip, 0.06)
		_fill(c, shape, BR_QUILL, 1171 + i * 4)
		_clip_fill(c, Crayon.blob(tip, Vector2(34, 42), 1172 + i * 4, 10, 0.05), shape, BR_TIP, 1173 + i * 4, 12.0)
		Crayon.marker_line(c, shape, INK, W_SPIKE, 1174 + i * 4)


# --- Moss: green turtle with a mossy shell ---------------------------------------------------

const MO_GREEN := Color("#b2db7a")
const MO_DARK := Color("#8bc463")
const MO_BELLY := Color("#f3e9a4")
const MO_SHELL := Color("#c9a46b")
const MO_PLATE := Color("#dcbb80")
const MO_RIM := Color("#ecd39c")
const MO_MOSS := Color("#7fc95f")
const MO_FLOWER := Color("#ff9ec4")
const MO_YELLOW := Color("#ffd65c")

static func _moss_body(c: CanvasItem) -> void:
	var body := Crayon.blob(Vector2(256, 268), Vector2(208, 92), 1201, 22, 0.04)
	_fill(c, body, MO_GREEN, 1202)
	_clip_fill(c, Crayon.blob(Vector2(256, 338), Vector2(224, 42), 1203, 16, 0.04), body, MO_BELLY, 1204)
	var spots := [Vector2(86, 282), Vector2(140, 304), Vector2(376, 302), Vector2(430, 280)]
	for i in spots.size():
		var at: Vector2 = spots[i]
		_clip_fill(c, Crayon.blob(at, Vector2(18, 12), 1205 + i, 10, 0.15), body, MO_DARK, 1210 + i, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1215)


## The shell is Moss's "other" part: a dome over its back with moss growing on top.
static func _moss_other(c: CanvasItem) -> void:
	var shell := PackedVector2Array()
	for i in 25:
		var a := PI + PI * i / 24.0
		var k := 1.0 + Crayon.noise(1221, i) * 0.03
		shell.append(Vector2(256, 294) + Vector2(cos(a) * 164.0, sin(a) * 190.0) * k)
	var under := _bez(Vector2(420, 294), Vector2(380, 318), Vector2(132, 318), Vector2(92, 294), 10)
	under.remove_at(0)
	under.remove_at(under.size() - 1)
	shell.append_array(under)
	_fill(c, shell, MO_SHELL, 1222)
	# shell plates: one big one in the middle, lines out to the rim
	var plate := PackedVector2Array()
	for i in 6:
		var a := TAU * i / 6.0
		plate.append(Vector2(256, 214) + Vector2(cos(a) * 64.0, sin(a) * 44.0))
	_clip_fill(c, plate, shell, MO_PLATE, 1223, 14.0, 6.0)
	for i in 6:
		var a := TAU * i / 6.0
		var from := Vector2(256, 214) + Vector2(cos(a) * 64.0, sin(a) * 44.0)
		_ink_in(c, _seg(from, from + Vector2(cos(a) * 160.0, sin(a) * 120.0), 4), shell, 6.0, 1224 + i * 2)
	# moss over the top
	var moss := _fluffy(Vector2(256, 128), Vector2(150, 64), 1240, 11, 0.22)
	_clip_fill(c, moss, shell, MO_MOSS, 1241, 16.0)
	for i in 6:
		var at := Vector2(160 + i * 38, 126 + (i % 2) * 18)
		if Geometry2D.is_point_in_polygon(at, shell):
			c.draw_circle(at, 6.0, MO_DARK.darkened(0.15))
	# the rim
	var rim := PackedVector2Array([Vector2(60, 270), Vector2(452, 270), Vector2(452, 340), Vector2(60, 340)])
	_clip_fill(c, rim, shell, MO_RIM, 1250, 14.0)
	_ink_in(c, _seg(Vector2(60, 270), Vector2(452, 270), 12), shell, 6.0, 1251)
	for i in 5:
		var x := 140.0 + i * 58.0
		_ink_in(c, _seg(Vector2(x, 272), Vector2(x - 2, 320), 2), shell, 5.0, 1253 + i)
	Crayon.marker_line(c, shell, INK, W_BODY, 1260)
	# a little flower growing out of the moss
	_ink(c, _bez(Vector2(300, 112), Vector2(304, 96), Vector2(312, 84), Vector2(318, 64), 6), 6.0, 1261)
	_part(c, _leaf(Vector2(306, 96), Vector2(340, 82), 0.35), MO_DARK, 1262, 5.0, 10.0)
	_flower(c, Vector2(318, 56), 24.0, MO_FLOWER, MO_YELLOW, 1264, 7.0)


static func _moss_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(338, 320), Vector2(90, 74), 1271, 20, 0.04)
	var jaw := Crayon.blob(Vector2(372, 362), Vector2(58, 38), 1272, 14, 0.04)
	var neck := _tube(_bez(Vector2(204, 414), Vector2(228, 388), Vector2(256, 364), Vector2(292, 350), 8), 34.0, 38.0)
	var head := _merge_all([skull, jaw, neck])
	_fill(c, head, MO_GREEN, 1273)
	_clip_fill(c, Crayon.blob(Vector2(300, 274), Vector2(16, 12), 1274, 10, 0.15), head, MO_DARK, 1275, 10.0)
	_clip_fill(c, Crayon.blob(Vector2(338, 262), Vector2(12, 9), 1276, 10, 0.15), head, MO_DARK, 1277, 10.0)
	_clip_fill(c, Crayon.blob(Vector2(328, 372), Vector2(20, 12), 1278, 10, 0.08), head, Color("#f7a8b0"), 1279, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1280)


static func _moss_eye(c: CanvasItem) -> void:
	_eye(c, 1281, Vector2(60, 64), Color("#a8703e"), 38.0, Vector2(20, 22), Vector2(8, 4))


static func _moss_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1291, Vector2(78, 56), 0.3)


static func _moss_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 140), 6), 36.0, 34.0)
	var foot := Crayon.blob(Vector2(266, 156), Vector2(50, 26), 1301, 14, 0.04)
	var shape := _merge(leg, foot)
	_fill(c, shape, MO_GREEN, 1302)
	_clip_fill(c, Crayon.blob(Vector2(244, 100), Vector2(13, 10), 1303, 10, 0.15), shape, MO_DARK, 1304, 8.0)
	Crayon.marker_line(c, shape, INK, W_BODY, 1305)
	for i in 3:
		var x := 274.0 + i * 16.0
		_ink(c, _seg(Vector2(x, 166), Vector2(x + 2, 180), 2), 5.0, 1306 + i)


static func _moss_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(476, 262), Vector2(420, 272), Vector2(372, 278), Vector2(332, 254), 10)
	_part(c, _tube(path, 26.0, 6.0), MO_GREEN, 1311)


# --- Clover: little spotted fawn with flowery antlers ----------------------------------------

const CL_TAN := Color("#eca96a")
const CL_CREAM := Color("#fbe5c6")
const CL_SPOT := Color("#fffaf0")
const CL_PINK := Color("#f7b0ac")
const CL_HOOF := Color("#7f5b49")
const CL_ANTLER := Color("#b98758")
const CL_LEAF := Color("#9ad67a")
const CL_DAISY := Color("#fffaf2")
const CL_YELLOW := Color("#ffd257")
const CL_BLOSSOM := Color("#ff9cc2")
const CL_LILAC := Color("#c9a4f0")

static func _clover_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 262), Vector2(200, 104), 0.25, 1401, 26, 0.035)
	_fill(c, body, CL_TAN, 1402)
	_clip_fill(c, Crayon.blob(Vector2(290, 336), Vector2(170, 46), 1403, 16, 0.05), body, CL_CREAM, 1404)
	var spots := [Vector2(118, 236), Vector2(170, 206), Vector2(226, 224), Vector2(282, 198),
		Vector2(334, 222), Vector2(196, 258), Vector2(268, 254), Vector2(380, 208)]
	for i in spots.size():
		var at: Vector2 = spots[i]
		var r := 12.0 + absf(Crayon.noise(1405, i)) * 6.0
		_clip_fill(c, Crayon.blob(at, Vector2(r * 1.2, r), 1406 + i, 10, 0.12), body, CL_SPOT, 1420 + i, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1430)


static func _clover_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(278, 308), Vector2(92, 84), 1431, 20, 0.04)
	var muzzle := Crayon.blob(Vector2(356, 346), Vector2(58, 40), 1432, 14, 0.05)
	var neck := _tube(_seg(Vector2(208, 412), Vector2(246, 362), 6), 28.0, 30.0)
	var head := _merge_all([skull, neck, muzzle])
	_fill(c, head, CL_TAN, 1433)
	_clip_fill(c, Crayon.blob(Vector2(368, 354), Vector2(50, 34), 1434, 12, 0.06), head, CL_CREAM, 1435)
	_clip_fill(c, Crayon.blob(Vector2(304, 360), Vector2(20, 13), 1436, 10, 0.08), head, CL_PINK, 1437, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1438)
	var nose := Crayon.blob(Vector2(402, 334), Vector2(15, 12), 1439, 10, 0.05)
	c.draw_colored_polygon(nose, INK)
	c.draw_circle(Vector2(398, 330), 3.5, Color(1, 1, 1, 0.8))


static func _clover_eye(c: CanvasItem) -> void:
	_eye(c, 1441, Vector2(64, 70), Color("#8a5a34"), 44.0, Vector2(24, 28), Vector2(8, 4))
	_lashes(c, 1445, Vector2(64, 70))


static func _clover_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1451, Vector2(70, 58), 0.4)


static func _clover_ear(c: CanvasItem) -> void:
	var ear := _point(Vector2(222, 474), Vector2(294, 470), Vector2(160, 284), 0.16)
	_fill(c, ear, CL_TAN, 1461)
	var inner := _point(Vector2(240, 452), Vector2(276, 450), Vector2(184, 320), 0.12)
	_clip_fill(c, inner, ear, CL_PINK, 1462, 12.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 1463)


static func _clover_horn(c: CanvasItem) -> void:
	var stem := _tube(_bez(Vector2(256, 474), Vector2(250, 400), Vector2(270, 310), Vector2(262, 232), 10), 18.0, 13.0)
	var b1 := _tube(_bez(Vector2(260, 392), Vector2(296, 376), Vector2(338, 340), Vector2(362, 300), 6), 13.0, 11.0)
	var b2 := _tube(_bez(Vector2(264, 334), Vector2(234, 318), Vector2(194, 300), Vector2(170, 276), 6), 12.0, 10.0)
	var antler := _merge_all([stem, b1, b2])
	_part(c, _leaf(Vector2(252, 430), Vector2(186, 408), 0.35), CL_LEAF, 1471, 9.0, 12.0)
	_part(c, antler, CL_ANTLER, 1473, W_HORN)
	_flower(c, Vector2(364, 292), 40.0, CL_BLOSSOM, CL_YELLOW, 1475, 11.0)
	_flower(c, Vector2(168, 270), 38.0, CL_LILAC, CL_YELLOW, 1480, 11.0)
	_flower(c, Vector2(262, 208), 50.0, CL_DAISY, CL_YELLOW, 1485, 12.0)


static func _clover_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(258, 222), 8), 21.0, 16.0)
	_part(c, leg, CL_TAN, 1491)
	var hoof := Crayon.rounded_rect(Rect2(232, 214, 56, 40), 12.0)
	_part(c, hoof, CL_HOOF, 1492)


static func _clover_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(476, 258), Vector2(430, 254), Vector2(392, 236), Vector2(376, 190), 10)
	var tail := _tube(path, 24.0, 22.0)
	_fill(c, tail, CL_TAN, 1495)
	_clip_fill(c, Crayon.blob(Vector2(372, 184), Vector2(34, 40), 1496, 12, 0.1), tail, CL_SPOT, 1497, 12.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 1498)


# --- Tank: chunky blue-grey rhino-armadillo, one big horn, stompy feet ------------------------

const TK_BLUE := Color("#a7b9d1")
const TK_BAND := Color("#8499b8")
const TK_BELLY := Color("#d9e2ee")
const TK_HORN := Color("#f5e8c9")
const TK_NAIL := Color("#fbf4e2")
const TK_PINK := Color("#f4b0bd")

static func _tank_body(c: CanvasItem) -> void:
	var body := _squircle(Vector2(256, 262), Vector2(214, 124), 2.6, 1501, 44, 0.025)
	_fill(c, body, TK_BLUE, 1502)
	_clip_fill(c, Crayon.blob(Vector2(256, 374), Vector2(232, 44), 1503, 16, 0.04), body, TK_BELLY, 1504)
	# armadillo bands across the middle
	for i in 4:
		var x := 170.0 + i * 52.0
		var band := PackedVector2Array([Vector2(x - 12, 100), Vector2(x + 12, 100), Vector2(x + 18, 260),
			Vector2(x + 10, 340), Vector2(x - 14, 340), Vector2(x - 6, 260)])
		_clip_fill(c, band, body, TK_BAND, 1505 + i, 12.0)
		_ink_in(c, PackedVector2Array([Vector2(x - 12, 100), Vector2(x - 6, 260), Vector2(x - 14, 340)]),
			body, 5.0, 1510 + i)
	# little scales on the front and back plates
	var scales := [Vector2(84, 220), Vector2(112, 182), Vector2(100, 270), Vector2(392, 196),
		Vector2(424, 240), Vector2(372, 254), Vector2(126, 316), Vector2(404, 300)]
	for s in scales:
		var at: Vector2 = s
		c.draw_arc(at, 10.0, 0.25, PI - 0.25, 8, TK_BAND.darkened(0.25), 4.0, true)
	Crayon.marker_line(c, body, INK, W_BODY, 1520)


static func _tank_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(254, 316), Vector2(80, 80), 1521, 20, 0.04)
	var snout := Crayon.blob(Vector2(342, 350), Vector2(76, 54), 1522, 18, 0.04)
	var neck := _tube(_seg(Vector2(206, 414), Vector2(236, 370), 6), 38.0, 38.0)
	var ear := _point(Vector2(204, 272), Vector2(240, 246), Vector2(186, 214), 0.15)
	var head := _merge_all([skull, snout, neck, ear])
	_fill(c, head, TK_BLUE, 1523)
	_clip_fill(c, _point(Vector2(212, 262), Vector2(230, 252), Vector2(196, 228), 0.1), head, TK_PINK, 1524, 10.0)
	# an armour plate over the top of the head
	var plate := Crayon.blob(Vector2(250, 236), Vector2(70, 36), 1525, 12, 0.05)
	_clip_fill(c, plate, head, TK_BAND, 1526, 14.0)
	_clip_fill(c, Crayon.blob(Vector2(316, 388), Vector2(20, 12), 1527, 10, 0.08), head, TK_PINK, 1528, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1529)
	c.draw_colored_polygon(Crayon.blob(Vector2(398, 338), Vector2(9, 6), 1530, 8, 0.1), INK)


static func _tank_eye(c: CanvasItem) -> void:
	_eye(c, 1531, Vector2(62, 66), Color("#8a6a4a"), 40.0, Vector2(22, 24), Vector2(8, 4))


static func _tank_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1541, Vector2(90, 64), 0.3, 3)


static func _tank_horn(c: CanvasItem) -> void:
	var front := _bez(Vector2(318, 476), Vector2(352, 390), Vector2(334, 286), Vector2(282, 210), 12)
	var back := _bez(Vector2(282, 210), Vector2(290, 296), Vector2(252, 392), Vector2(192, 476), 12)
	back.remove_at(0)
	var horn := PackedVector2Array()
	horn.append_array(front)
	horn.append_array(back)
	_fill(c, horn, TK_HORN, 1551)
	var room := Geometry2D.offset_polygon(horn, -8.0)
	if not room.is_empty():
		for i in 2:
			var y := 404.0 - i * 64.0
			_ink_in(c, _bez(Vector2(170, y + 6), Vector2(240, y + 16), Vector2(300, y + 6), Vector2(380, y - 12), 8),
				room[0], 6.0, 1552 + i * 3)
	Crayon.marker_line(c, horn, INK, W_HORN, 1560)


static func _tank_leg(c: CanvasItem) -> void:
	var path := _seg(Vector2(256, 66), Vector2(256, 160), 6)
	var leg := _tube(path, 42.0, 40.0)
	_fill(c, leg, TK_BLUE, 1561)
	_clip_fill(c, _band(path, 0.4, 60.0, 9.0), leg, TK_BAND, 1562, 12.0)
	Crayon.marker_line(c, leg, INK, W_BODY, 1563)


## A big stompy foot from the ankle dot (190, 140), toes to the right.
static func _tank_foot(c: CanvasItem) -> void:
	var ankle := Crayon.rounded_rect(Rect2(108, 92, 164, 112), 46.0)
	var toe := Crayon.blob(Vector2(240, 206), Vector2(104, 48), 1571, 16, 0.04)
	var foot := _merge(ankle, toe)
	_fill(c, foot, TK_BLUE, 1572)
	_clip_fill(c, PackedVector2Array([Vector2(90, 236), Vector2(370, 236), Vector2(370, 280), Vector2(90, 280)]),
		foot, TK_BAND, 1573, 12.0)
	Crayon.marker_line(c, foot, INK, W_FOOT, 1574)
	var angles := [0.3, 0.78, 1.22]
	for i in angles.size():
		var a: float = angles[i]
		var at := Vector2(240, 206) + Vector2(cos(a) * 94.0, sin(a) * 42.0)
		var nail := Crayon.blob(at, Vector2(17, 13), 1575 + i, 10, 0.05)
		_part(c, nail, TK_NAIL, 1580 + i * 2, 7.0, 10.0)


static func _tank_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(476, 262), Vector2(420, 282), Vector2(360, 286), Vector2(318, 254), 12)
	var tail := _tube(path, 30.0, 8.0)
	_fill(c, tail, TK_BLUE, 1591)
	for k in 2:
		_clip_fill(c, _band(path, 0.35 + k * 0.25, 50.0, 7.0), tail, TK_BAND, 1592 + k, 10.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 1595)


# --- Waffles: fluffy cream sheepdog, hair flopping over its eyes ------------------------------

const WF_WHITE := Color("#faf3e4")
const WF_GREY := Color("#b4bfd2")
const WF_STRAND := Color("#cfc6b2")
const WF_STRAND_GREY := Color("#8f9bb2")

static func _waffles_body(c: CanvasItem) -> void:
	var body := _fluffy(Vector2(256, 262), Vector2(198, 126), 1601, 18, 0.07, 144, 0.012)
	_fill(c, body, WF_WHITE, 1602)
	var patch := _fluffy(Vector2(126, 210), Vector2(176, 132), 1603, 12, 0.1, 96, 0.02)
	_clip_fill(c, patch, body, WF_GREY, 1604)
	var white_spots := [Vector2(300, 190), Vector2(350, 230), Vector2(300, 290), Vector2(380, 300)]
	var grey_spots := [Vector2(110, 200), Vector2(160, 250), Vector2(220, 180), Vector2(100, 290)]
	_fur(c, white_spots, body, WF_STRAND, 1605)
	_fur(c, grey_spots, body, WF_STRAND_GREY, 1620)
	Crayon.marker_line(c, body, INK, W_BODY, 1640)


static func _waffles_head(c: CanvasItem) -> void:
	var skull := _fluffy(Vector2(280, 306), Vector2(106, 98), 1641, 13, 0.07, 104, 0.012)
	var muzzle := Crayon.blob(Vector2(362, 350), Vector2(54, 40), 1642, 14, 0.05)
	var neck := _tube(_seg(Vector2(206, 412), Vector2(246, 362), 6), 34.0, 34.0)
	var head := _merge_all([skull, neck, muzzle])
	_fill(c, head, WF_WHITE, 1643)
	_clip_fill(c, Crayon.blob(Vector2(318, 368), Vector2(22, 14), 1644, 10, 0.08), head, Color("#f7b4c0"), 1645, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1646)
	# the fringe: locks of hair hanging down over the forehead
	var room := Geometry2D.offset_polygon(head, -8.0)
	if not room.is_empty():
		var area: PackedVector2Array = room[0]
		var fringe := PackedVector2Array()
		for i in 31:
			var t := i / 30.0
			var x := lerpf(200.0, 396.0, t)
			var y := lerpf(258.0, 270.0, t) + 20.0 * pow(absf(sin(t * PI * 5.0)), 0.7)
			fringe.append(Vector2(x, y))
		_ink_in(c, fringe, area, 6.0, 1647)
		for i in 5:
			var x := 220.0 + i * 38.0
			_ink_in(c, _bez(Vector2(x - 6, 220), Vector2(x + 4, 236), Vector2(x - 2, 250), Vector2(x + 6, 266), 5),
				area, 4.0, 1650 + i, WF_STRAND)
	var nose := Crayon.blob(Vector2(408, 338), Vector2(17, 13), 1660, 10, 0.05)
	c.draw_colored_polygon(nose, INK)
	c.draw_circle(Vector2(403, 333), 4.0, Color(1, 1, 1, 0.8))


static func _waffles_eye(c: CanvasItem) -> void:
	var white := _eye(c, 1661, Vector2(62, 68), Color("#6b4a3a"), 40.0, Vector2(22, 26), Vector2(6, 10))
	# its fringe flops down over the top of the eye
	var grown := Geometry2D.offset_polygon(white, 9.0)
	if grown.is_empty():
		return
	var cover: PackedVector2Array = grown[0]
	var edge := PackedVector2Array()
	for i in 25:
		var t := i / 24.0
		edge.append(O + Vector2(lerpf(92.0, -92.0, t), -34.0 + 28.0 * pow(absf(sin(t * PI * 3.0)), 0.7)))
	var fringe := PackedVector2Array([O + Vector2(-92, -120), O + Vector2(92, -120)])
	fringe.append_array(edge)
	_clip_fill(c, fringe, cover, WF_WHITE, 1666, 14.0)
	_ink_in(c, edge, cover, 10.0, 1667)
	for i in 3:
		var x := -36.0 + i * 36.0
		_ink_in(c, _seg(O + Vector2(x - 4, -70), O + Vector2(x + 6, -40), 3), cover, 5.0, 1670 + i, WF_STRAND)


static func _waffles_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1681, Vector2(80, 66), 0.4)


## A floppy ear: a little way up from the dot, then flopping over and hanging down the side.
static func _waffles_ear(c: CanvasItem) -> void:
	var stalk := _tube(_seg(Vector2(256, 466), Vector2(250, 424), 4), 28.0, 30.0)
	var fold := Crayon.blob(Vector2(230, 416), Vector2(48, 30), 1691, 14, 0.04)
	var lobe := _fluffy(Vector2(198, 446), Vector2(46, 52), 1692, 7, 0.12, 70, 0.02)
	var ear := _merge_all([stalk, fold, lobe])
	_fill(c, ear, WF_WHITE, 1693)
	_fur(c, [Vector2(192, 420), Vector2(214, 446)], ear, WF_STRAND, 1694, 28.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 1699)


## A shaggy mop of locks, a rounded dome of them, all flopping forward towards its eyes.
static func _waffles_hair(c: CanvasItem) -> void:
	var tips := [Vector2(168, 384), Vector2(206, 330), Vector2(258, 302), Vector2(316, 300),
		Vector2(372, 318), Vector2(420, 352), Vector2(452, 398)]
	var curves := []
	for i in tips.size():
		var tip: Vector2 = tips[i]
		var base := Vector2(206 + i * 26, 446)
		var lean := 1.0 if i > 0 else -1.0
		curves.append([base, base + Vector2(-6 * lean, -66), tip + Vector2(-40 * lean, 4), tip])
	_locks(c, curves, WF_WHITE, WF_STRAND, 1701, 36.0, 20.0)


static func _waffles_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 196), 6), 32.0, 34.0)
	var paw := _fluffy(Vector2(266, 214), Vector2(54, 34), 1721, 8, 0.14, 64, 0.02)
	var shape := _merge(leg, paw)
	_fill(c, shape, WF_WHITE, 1722)
	_fur(c, [Vector2(246, 100), Vector2(262, 150)], shape, WF_STRAND, 1723)
	Crayon.marker_line(c, shape, INK, W_BODY, 1730)


static func _waffles_tail(c: CanvasItem) -> void:
	var stub := _tube(_bez(Vector2(476, 256), Vector2(440, 252), Vector2(412, 232), Vector2(400, 200), 8), 24.0, 28.0)
	var pom := _fluffy(Vector2(392, 170), Vector2(60, 56), 1731, 9, 0.15, 72, 0.02)
	var tail := _merge(stub, pom)
	_part(c, tail, WF_GREY, 1732)


# --- Sprocket: orange fox with a giant white-tipped tail --------------------------------------

const SP_ORANGE := Color("#f89c4e")
const SP_CREAM := Color("#fff2de")
const SP_SOCK := Color("#6f5249")
const SP_DEEP := Color("#e2772f")

static func _sprocket_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 262), Vector2(198, 100), 0.3, 1801, 26, 0.035)
	_fill(c, body, SP_ORANGE, 1802)
	_clip_fill(c, Crayon.blob(Vector2(370, 318), Vector2(108, 60), 1803, 14, 0.08), body, SP_CREAM, 1804)
	_fur(c, [Vector2(150, 200), Vector2(220, 186), Vector2(290, 190)], body, SP_DEEP, 1805, 30.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1815)


static func _sprocket_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(274, 312), Vector2(94, 86), 1821, 20, 0.04)
	var snout := _tube(_seg(Vector2(326, 332), Vector2(420, 338), 6), 50.0, 17.0)
	var neck := _tube(_seg(Vector2(206, 412), Vector2(242, 364), 6), 32.0, 32.0)
	var head := _merge_all([skull, neck, snout])
	_fill(c, head, SP_ORANGE, 1822)
	# white cheeks and chin under a zig-zag
	var cheek := PackedVector2Array([Vector2(160, 470), Vector2(160, 384)])
	for i in 13:
		var t := i / 12.0
		var p := Vector2(196, 374).lerp(Vector2(446, 344), t)
		cheek.append(p + Vector2(0, -12.0 if i % 2 == 1 else 6.0))
	cheek.append(Vector2(470, 470))
	_clip_fill(c, cheek, head, SP_CREAM, 1823)
	Crayon.marker_line(c, head, INK, W_BODY, 1824)


static func _sprocket_eye(c: CanvasItem) -> void:
	_eye(c, 1831, Vector2(60, 64), Color("#f4b23a"), 40.0, Vector2(20, 26), Vector2(8, 4))


static func _sprocket_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1841, Vector2(74, 60), 0.4, 0, true)


static func _sprocket_ear(c: CanvasItem) -> void:
	var ear := _point(Vector2(204, 474), Vector2(310, 474), Vector2(262, 236), 0.08)
	_fill(c, ear, SP_ORANGE, 1851)
	_clip_fill(c, _point(Vector2(232, 460), Vector2(286, 460), Vector2(262, 306), 0.06), ear, SP_CREAM, 1852, 12.0)
	_clip_fill(c, PackedVector2Array([Vector2(150, 200), Vector2(370, 200), Vector2(370, 300), Vector2(150, 316)]),
		ear, SP_SOCK, 1853, 12.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 1854)


static func _sprocket_nose(c: CanvasItem) -> void:
	_button_nose(c, 1861, Vector2(40, 32))


static func _sprocket_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 212), 8), 24.0, 20.0)
	var paw := Crayon.blob(Vector2(268, 226), Vector2(36, 22), 1871, 12, 0.05)
	var shape := _merge(leg, paw)
	_fill(c, shape, SP_ORANGE, 1872)
	var sock := PackedVector2Array()
	for i in 9:
		var x := lerpf(196.0, 340.0, i / 8.0)
		sock.append(Vector2(x, 150.0 + (8.0 if i % 2 == 1 else -4.0)))
	sock.append(Vector2(340, 280))
	sock.append(Vector2(196, 280))
	_clip_fill(c, sock, shape, SP_SOCK, 1873)
	Crayon.marker_line(c, shape, INK, W_BODY, 1874)


## The giant bushy tail: a run of overlapping puffs along a curve, the end dipped in white.
static func _sprocket_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(474, 262), Vector2(370, 300), Vector2(210, 310), Vector2(128, 182), 16)
	var puffs := []
	for i in path.size():
		var t := i / float(path.size() - 1)
		var r := 20.0 + 58.0 * sin(minf(t * 1.3, 1.0) * PI * 0.5)
		if t > 0.85:
			r *= lerpf(1.0, 0.8, (t - 0.85) / 0.15)
		puffs.append(Crayon.blob(path[i], Vector2(r, r), 1881 + i, 14, 0.06))
	var tail := _merge_all(puffs)
	_fill(c, tail, SP_ORANGE, 1900)
	_fur(c, [Vector2(330, 262), Vector2(260, 260), Vector2(200, 240)], tail, SP_DEEP, 1901, 32.0)
	var tip := _fluffy(Vector2(122, 174), Vector2(98, 98), 1910, 9, 0.14, 72, 0.02)
	_clip_fill(c, tip, tail, SP_CREAM, 1911)
	Crayon.marker_line(c, tail, INK, W_BODY, 1912)


# --- Pudding: round pink pig, snout nose, curly tail ------------------------------------------

const PD_PINK := Color("#f9aabb")
const PD_DEEP := Color("#f088a2")
const PD_LIGHT := Color("#fdd5de")
const PD_HOOF := Color("#a07580")
const PD_HOLE := Color("#8f4058")

static func _pudding_body(c: CanvasItem) -> void:
	var body := Crayon.blob(Vector2(256, 260), Vector2(192, 138), 2001, 24, 0.035)
	_fill(c, body, PD_PINK, 2002)
	_clip_fill(c, Crayon.blob(Vector2(300, 354), Vector2(150, 56), 2003, 16, 0.05), body, PD_LIGHT, 2004)
	_clip_fill(c, Crayon.blob(Vector2(168, 200), Vector2(48, 36), 2005, 12, 0.15), body, PD_DEEP, 2006)
	_clip_fill(c, Crayon.blob(Vector2(268, 180), Vector2(30, 22), 2007, 10, 0.15), body, PD_DEEP, 2008)
	_clip_fill(c, Crayon.blob(Vector2(108, 288), Vector2(26, 20), 2009, 10, 0.15), body, PD_DEEP, 2010)
	Crayon.marker_line(c, body, INK, W_BODY, 2011)


static func _pudding_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(284, 306), Vector2(100, 94), 2021, 22, 0.035)
	var cheek := Crayon.blob(Vector2(330, 360), Vector2(66, 46), 2022, 16, 0.04)
	var neck := _tube(_seg(Vector2(206, 412), Vector2(246, 362), 6), 34.0, 34.0)
	var head := _merge_all([skull, cheek, neck])
	_fill(c, head, PD_PINK, 2023)
	_clip_fill(c, Crayon.blob(Vector2(298, 364), Vector2(24, 15), 2024, 10, 0.08), head, PD_DEEP, 2025, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 2026)


static func _pudding_eye(c: CanvasItem) -> void:
	_eye(c, 2031, Vector2(56, 60), Color(), 0.0, Vector2(30, 34), Vector2(6, 4))


static func _pudding_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 2041, Vector2(76, 60), 0.35)


static func _pudding_ear(c: CanvasItem) -> void:
	# a pig's ear points up and tips forward
	var ear := _point(Vector2(204, 474), Vector2(300, 474), Vector2(338, 296), 0.14)
	_fill(c, ear, PD_PINK, 2051)
	_clip_fill(c, _point(Vector2(230, 462), Vector2(286, 462), Vector2(318, 338), 0.1), ear, PD_DEEP, 2052, 12.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 2053)


## The snout: a short pink plug sticking out of the face, its flat front with two nostrils.
static func _pudding_nose(c: CanvasItem) -> void:
	var stem := Crayon.rounded_rect(Rect2(174, 190, 100, 132), 30.0)
	var front := Crayon.blob(Vector2(274, 256), Vector2(48, 74), 2061, 18, 0.03)
	var snout := _merge(stem, front)
	_part(c, snout, PD_PINK, 2062, W_NOSE)
	_part(c, front, PD_DEEP, 2064, W_NOSE)
	for y in [226.0, 286.0]:
		c.draw_colored_polygon(Crayon.blob(Vector2(278, y), Vector2(11, 17), 2066, 10, 0.08), PD_HOLE)
	c.draw_circle(Vector2(256, 206), 8.0, Color(1, 1, 1, 0.8))


static func _pudding_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 126), 6), 34.0, 32.0)
	_part(c, leg, PD_PINK, 2071)
	var hoof := Crayon.rounded_rect(Rect2(218, 136, 78, 42), 12.0)
	_part(c, hoof, PD_HOOF, 2072)
	_ink(c, _seg(Vector2(258, 140), Vector2(260, 176), 2), 5.0, 2074)


## A curly piggy tail - drawn in short runs, each inked then coloured, so where the curl crosses
## itself the later loop sits on top with its own outline.
static func _pudding_tail(c: CanvasItem) -> void:
	var pts := PackedVector2Array()
	for k in 61:
		var t := k / 60.0
		var th := t * TAU * 2.2
		pts.append(Vector2(470 - 160.0 * t - 28.0 * sin(th), 262 - 28.0 * (1.0 - cos(th)) - 10.0 * t))
	var i := 0
	while i < pts.size() - 1:
		var run := pts.slice(i, mini(i + 7, pts.size()))
		Crayon.marker_line(c, run, INK, 28.0, 2081 + i, false)
		var back := pts.slice(maxi(0, i - 2), mini(i + 7, pts.size()))
		Crayon.marker_line(c, back, PD_PINK, 13.0, 2082 + i, false)
		i += 6


# --- Boulder: huge gentle shaggy yak, curved horns, big hooves -------------------------------

const BO_BROWN := Color("#a0705a")
const BO_SHAG := Color("#bd8f71")
const BO_DARK := Color("#7f5747")
const BO_FACE := Color("#f3e4cc")
const BO_LID := Color("#dcc3a2")
const BO_HORN := Color("#f3e5c6")
const BO_RING := Color("#d8c39b")
const BO_HOOF := Color("#83808f")
const BO_NOSE := Color("#dba79f")

static func _boulder_body(c: CanvasItem) -> void:
	var ctr := Vector2(256, 262)
	var pts := PackedVector2Array()
	var n := 76
	for i in n:
		var a := TAU * i / n
		var s := sin(a)
		var k := 1.0 + Crayon.noise(2101, i) * 0.025
		if s > -0.3:
			k += 0.075 if i % 2 == 0 else -0.01
		pts.append(ctr + Vector2(cos(a) * 204.0, s * 118.0) * k)
	var hump := Crayon.blob(Vector2(236, 168), Vector2(132, 64), 2102, 18, 0.04)
	var body := _merge(pts, hump)
	_fill(c, body, BO_BROWN, 2103)
	# a lighter shaggy mantle over the hump, hanging down in a fringe
	var shag := PackedVector2Array([Vector2(40, 60), Vector2(470, 60)])
	for i in 23:
		var x := lerpf(470.0, 40.0, i / 22.0)
		shag.append(Vector2(x, 194.0 + (18.0 if i % 2 == 1 else -6.0) + absf(x - 240.0) * 0.1))
	_clip_fill(c, shag, body, BO_SHAG, 2105)
	var spots := []
	for i in 9:
		spots.append(Vector2(84 + i * 40, 222 + Crayon.noise(2106, i) * 14.0 + (i % 2) * 40.0))
	_fur(c, spots, body, BO_DARK, 2110, 52.0, 5.0)
	Crayon.marker_line(c, body, INK, W_BODY, 2140)


static func _boulder_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(276, 312), Vector2(92, 86), 2141, 20, 0.04)
	var muzzle := Crayon.blob(Vector2(352, 356), Vector2(62, 46), 2142, 16, 0.04)
	var neck := _tube(_seg(Vector2(206, 414), Vector2(244, 366), 6), 38.0, 38.0)
	var head := _merge_all([skull, neck, muzzle])
	_fill(c, head, BO_BROWN, 2143)
	_clip_fill(c, Crayon.blob(Vector2(342, 336), Vector2(84, 72), 2144, 14, 0.1), head, BO_FACE, 2145)
	_clip_fill(c, Crayon.blob(Vector2(396, 346), Vector2(26, 22), 2146, 12, 0.08), head, BO_NOSE, 2147, 12.0)
	Crayon.marker_line(c, head, INK, W_BODY, 2148)
	c.draw_colored_polygon(Crayon.blob(Vector2(404, 340), Vector2(6, 9), 2149, 8, 0.1), INK)
	_fur(c, [Vector2(214, 300), Vector2(236, 360)], head, BO_DARK, 2150, 40.0)


static func _boulder_eye(c: CanvasItem) -> void:
	var white := _eye(c, 2161, Vector2(60, 64), Color("#7a4f35"), 38.0, Vector2(20, 22), Vector2(6, 10))
	# a soft sleepy lid - it's a gentle giant
	var lid := PackedVector2Array([O + Vector2(-110, -110), O + Vector2(110, -110), O + Vector2(110, -16),
		O + Vector2(-110, -26)])
	_clip_fill(c, lid, white, BO_LID, 2165, 14.0)
	_ink(c, _seg(O + Vector2(-64, -25), O + Vector2(64, -17), 4), 12.0, 2166)
	Crayon.marker_line(c, white, INK, W_EYE, 2167)


static func _boulder_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 2171, Vector2(84, 62), 0.4)


## A curved horn: out to the front, then hooking back up.
static func _boulder_horn(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 462), Vector2(326, 420), Vector2(412, 326), Vector2(332, 222), 18)
	var horn := _tube(path, 36.0, 9.0, 1.0, 0.6)
	_fill(c, horn, BO_HORN, 2181)
	for k in 3:
		_clip_fill(c, _band(path, 0.2 + k * 0.17, 60.0, 5.0), horn, BO_RING, 2182 + k, 8.0)
	Crayon.marker_line(c, horn, INK, W_HORN, 2190)


## A shaggy forelock swept back over the top of its head.
static func _boulder_hair(c: CanvasItem) -> void:
	var curves := [
		[Vector2(256, 434), Vector2(226, 380), Vector2(190, 346), Vector2(128, 344)],
		[Vector2(282, 434), Vector2(268, 364), Vector2(226, 306), Vector2(166, 292)],
		[Vector2(310, 434), Vector2(308, 360), Vector2(280, 300), Vector2(226, 262)],
		[Vector2(336, 434), Vector2(346, 380), Vector2(332, 324), Vector2(292, 288)]]
	_locks(c, curves, BO_DARK, BO_SHAG, 2191, 34.0)


static func _boulder_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 160), 6), 40.0, 36.0)
	_fill(c, leg, BO_BROWN, 2201)
	_fur(c, [Vector2(240, 60), Vector2(270, 90)], leg, BO_DARK, 2202, 50.0)
	Crayon.marker_line(c, leg, INK, W_BODY, 2209)


## A big hoof from the ankle dot (190, 140), with a shaggy cuff of fur round the ankle.
static func _boulder_foot(c: CanvasItem) -> void:
	var hoof := PackedVector2Array([Vector2(118, 156), Vector2(272, 156), Vector2(336, 238),
		Vector2(326, 262), Vector2(110, 262), Vector2(102, 236)])
	_part(c, hoof, BO_HOOF, 2211, W_FOOT)
	_ink(c, _seg(Vector2(240, 176), Vector2(250, 262), 3), 8.0, 2213)
	Crayon.line(c, Vector2(140, 200), Vector2(150, 240), Color(1, 1, 1, 0.45), 8.0, 2214, 1.0)
	var cuff := PackedVector2Array([Vector2(104, 72), Vector2(276, 72)])
	for i in 13:
		var x := lerpf(286.0, 96.0, i / 12.0)
		cuff.append(Vector2(x, 182.0 if i % 2 == 0 else 160.0))
	_part(c, cuff, BO_BROWN, 2215, W_FOOT)
	_fur(c, [Vector2(150, 90), Vector2(206, 96)], cuff, BO_DARK, 2217, 50.0, 6.0)


static func _boulder_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(474, 250), Vector2(400, 262), Vector2(334, 292), Vector2(304, 350), 12)
	_part(c, _tube(path, 16.0, 11.0), BO_BROWN, 2221)
	var tassel := _fluffy(Vector2(298, 388), Vector2(46, 56), 2223, 8, 0.22, 64, 0.02)
	_part(c, tassel, BO_DARK, 2224)


# --- Dottie: red ladybug-puppy, spots, two antennae, six little legs --------------------------

const DT_RED := Color("#f66e66")
const DT_CREAM := Color("#ffe8d4")
const DT_LEG := Color("#625c76")
const DT_PAW := Color("#fff6ec")

static func _dottie_body(c: CanvasItem) -> void:
	var body := PackedVector2Array()
	for i in 40:
		var a := TAU * i / 40.0
		var s := sin(a)
		var k := 1.0 + Crayon.noise(2301, i) * 0.025
		body.append(Vector2(256, 296) + Vector2(cos(a) * 204.0, s * (144.0 if s < 0.0 else 72.0)) * k)
	_fill(c, body, DT_RED, 2302)
	_clip_fill(c, Crayon.blob(Vector2(256, 384), Vector2(230, 42), 2303, 16, 0.04), body, DT_CREAM, 2304)
	var spots := [[Vector2(116, 254), 24.0], [Vector2(188, 196), 28.0], [Vector2(278, 178), 24.0],
		[Vector2(356, 214), 26.0], [Vector2(244, 266), 22.0], [Vector2(324, 296), 18.0],
		[Vector2(414, 268), 16.0], [Vector2(162, 312), 18.0]]
	for i in spots.size():
		var at: Vector2 = spots[i][0]
		var r: float = spots[i][1]
		_clip_solid(c, Crayon.blob(at, Vector2(r, r * 0.92), 2305 + i, 12, 0.08), body, INK)
	Crayon.marker_line(c, body, INK, W_BODY, 2320)


static func _dottie_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(278, 310), Vector2(94, 88), 2331, 20, 0.04)
	var muzzle := Crayon.blob(Vector2(356, 350), Vector2(58, 42), 2332, 14, 0.05)
	var neck := _tube(_seg(Vector2(206, 412), Vector2(244, 364), 6), 32.0, 32.0)
	var head := _merge_all([skull, neck, muzzle])
	_fill(c, head, DT_RED, 2333)
	_clip_fill(c, Crayon.blob(Vector2(366, 358), Vector2(52, 36), 2334, 12, 0.06), head, DT_CREAM, 2335)
	_clip_solid(c, Crayon.blob(Vector2(336, 258), Vector2(13, 12), 2336, 10, 0.08), head, INK)
	# a floppy puppy ear
	var ear := _tube(_bez(Vector2(236, 238), Vector2(222, 262), Vector2(208, 292), Vector2(208, 330), 8), 16.0, 30.0)
	_clip_fill(c, ear, head, DT_LEG, 2337, 14.0, 7.0)
	Crayon.marker_line(c, head, INK, W_BODY, 2340)
	var nose := Crayon.blob(Vector2(404, 338), Vector2(16, 13), 2341, 10, 0.05)
	c.draw_colored_polygon(nose, INK)
	c.draw_circle(Vector2(399, 333), 4.0, Color(1, 1, 1, 0.8))


static func _dottie_eye(c: CanvasItem) -> void:
	_eye(c, 2351, Vector2(64, 70), Color("#7d4b2f"), 46.0, Vector2(26, 30), Vector2(8, 6))
	c.draw_circle(O + Vector2(24, 30), 7.0, Color.WHITE)


static func _dottie_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 2361, Vector2(74, 62), 0.4)


static func _dottie_antenna(c: CanvasItem) -> void:
	var stalk := _bez(Vector2(256, 454), Vector2(250, 396), Vector2(292, 356), Vector2(288, 304), 10)
	_ink(c, stalk, W_ANT, 2371)
	var ball := Crayon.blob(Vector2(290, 278), Vector2(30, 30), 2372, 14, 0.05)
	_part(c, ball, DT_RED, 2373, W_ANT, 14.0)
	c.draw_colored_polygon(Crayon.blob(Vector2(298, 286), Vector2(9, 9), 2375, 8, 0.1), INK)
	c.draw_circle(Vector2(280, 268), 6.0, Color(1, 1, 1, 0.85))


static func _dottie_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 66), Vector2(256, 146), 6), 17.0, 16.0)
	_part(c, leg, DT_LEG, 2381)
	var paw := Crayon.blob(Vector2(266, 160), Vector2(32, 20), 2382, 12, 0.05)
	_part(c, paw, DT_PAW, 2383)
	_ink(c, _seg(Vector2(280, 150), Vector2(282, 172), 2), 4.0, 2385)
