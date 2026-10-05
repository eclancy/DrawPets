class_name ArtAdoptC
extends RefCounted
## Water folk and oddballs - pets a kid can meet and adopt in the shop's Adopt tab. Drawn as if OTHER KIDS
## drew them, in marker with black outlines, part by part, exactly the way the game asks a kid
## to draw, and assembled by the same PetBuilder.add_parts a kid's own pet goes through
## (Roster.assemble). Baked to res://art/adopt_c/ by tools/bake_art.gd; the assembled view is
## .shots/art_adopt_c_assembled.png.
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
	"bubbles": {"name": "Bubbles", "look": "pink jellyfish, round bell body, six wavy tentacles, no head",
		"parts": {"eye": 2, "mouth": 1, "tentacle": 6}},
	"squidge": {"name": "Squidge", "look": "purple octopus, big round body, eight curly tentacles, no head",
		"parts": {"eye": 2, "mouth": 1, "tentacle": 8}},
	"shelly": {"name": "Shelly", "look": "red crab, eye-stalk antennae, two arms with big pincer claws, six legs, no head",
		"parts": {"eye": 2, "mouth": 1, "antenna": 2, "arm": 2, "claw_on_arm": 2, "leg": 6}},
	"finnegan": {"name": "Finnegan", "look": "grey seal, whiskery nose, flipper fins and flipper arms, tail flipper",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "nose": 1, "fin": 2, "arm": 2, "tail": 1}},
	"puddles": {"name": "Puddles", "look": "green frog, wide mouth, eyes on top, arms with hands, legs with big webbed feet, no head",
		"parts": {"eye": 2, "mouth": 1, "arm": 2, "hand": 1, "leg": 2, "foot": 1}},
	"coral": {"name": "Coral", "look": "orange seahorse, curly tail, back fin, spiky crest",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "fin": 2, "tail": 1, "spike": 3}},
	"gloop": {"name": "Gloop", "look": "lime-green slime blob, one big eye, a drip on its side, no head or legs",
		"parts": {"eye": 1, "mouth": 1, "other": 1}},
	"sir_snail": {"name": "Sir Snail", "look": "snail with a spiral shell (its other part) and eye-stalk antennae, no head or legs",
		"parts": {"eye": 2, "mouth": 1, "antenna": 2, "other": 1}},
	"nessie": {"name": "Nessie", "look": "long-necked green lake monster, little horn nubs, four flipper fins, back spikes",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "horn": 2, "fin": 4, "spike": 4, "tail": 1}},
	"axel": {"name": "Axel", "look": "pink axolotl, frilly gills as hair, four little legs, tail fin",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "hair": 2, "leg": 4, "tail": 1, "fin": 1}},
}


static func assets() -> Dictionary:
	var out := {}
	for id in ROSTER:
		out[id + "_body"] = {"pivot": "center"}
		for key in ROSTER[id]["parts"]:
			var type: String = Roster.split_key(key)[0]
			out["%s_%s" % [id, key]] = {"pivot": PartTypes.info(type)["dot"]}
	return out


const PAPER := Color("#fffdf8")
const MOUTH_IN := Color("#c9405e")
const TONGUE := Color("#ff92ab")
const BLUSH := Color("#ff7fae")
const O := Vector2(256, 256)   # the eye, mouth and "other" dot

# Line widths: about the same thickness once each sheet is shrunk by its zoom.
const W_BODY := 9.0    # zoom 1.0: body, head, leg, tail, tentacle
const W_ARM := 10.0    # zoom 1.2
const W_FIN := 11.0    # zoom 1.3: fin, hair
const W_ANT := 12.0    # zoom 1.5: antenna, spike
const W_EAR := 13.0    # zoom 1.8: horn, foot
const W_HAND := 13.0   # zoom 2.0
const W_MOUTH := 14.0  # zoom 2.5: mouth, nose
const W_EYE := 15.0    # zoom 3.0: eye, claw
const W_CLAW := 15.0


static func draw(id: String, c: CanvasItem) -> void:
	match id:
		"bubbles_body": _bubbles_body(c)
		"bubbles_eye": _bubbles_eye(c)
		"bubbles_mouth": _bubbles_mouth(c)
		"bubbles_tentacle": _bubbles_tentacle(c)
		"squidge_body": _squidge_body(c)
		"squidge_eye": _squidge_eye(c)
		"squidge_mouth": _squidge_mouth(c)
		"squidge_tentacle": _squidge_tentacle(c)
		"shelly_body": _shelly_body(c)
		"shelly_eye": _shelly_eye(c)
		"shelly_mouth": _shelly_mouth(c)
		"shelly_antenna": _shelly_antenna(c)
		"shelly_arm": _shelly_arm(c)
		"shelly_claw_on_arm": _shelly_claw(c)
		"shelly_leg": _shelly_leg(c)
		"finnegan_body": _finnegan_body(c)
		"finnegan_head": _finnegan_head(c)
		"finnegan_eye": _finnegan_eye(c)
		"finnegan_mouth": _finnegan_mouth(c)
		"finnegan_nose": _finnegan_nose(c)
		"finnegan_fin": _finnegan_fin(c)
		"finnegan_arm": _finnegan_arm(c)
		"finnegan_tail": _finnegan_tail(c)
		"puddles_body": _puddles_body(c)
		"puddles_eye": _puddles_eye(c)
		"puddles_mouth": _puddles_mouth(c)
		"puddles_arm": _puddles_arm(c)
		"puddles_hand": _puddles_hand(c)
		"puddles_leg": _puddles_leg(c)
		"puddles_foot": _puddles_foot(c)
		"coral_body": _coral_body(c)
		"coral_head": _coral_head(c)
		"coral_eye": _coral_eye(c)
		"coral_mouth": _coral_mouth(c)
		"coral_fin": _coral_fin(c)
		"coral_tail": _coral_tail(c)
		"coral_spike": _coral_spike(c)
		"gloop_body": _gloop_body(c)
		"gloop_eye": _gloop_eye(c)
		"gloop_mouth": _gloop_mouth(c)
		"gloop_other": _gloop_other(c)
		"sir_snail_body": _snail_body(c)
		"sir_snail_eye": _snail_eye(c)
		"sir_snail_mouth": _snail_mouth(c)
		"sir_snail_antenna": _snail_antenna(c)
		"sir_snail_other": _snail_shell(c)
		"nessie_body": _nessie_body(c)
		"nessie_head": _nessie_head(c)
		"nessie_eye": _nessie_eye(c)
		"nessie_mouth": _nessie_mouth(c)
		"nessie_horn": _nessie_horn(c)
		"nessie_fin": _nessie_fin(c)
		"nessie_spike": _nessie_spike(c)
		"nessie_tail": _nessie_tail(c)
		"axel_body": _axel_body(c)
		"axel_head": _axel_head(c)
		"axel_eye": _axel_eye(c)
		"axel_mouth": _axel_mouth(c)
		"axel_hair": _axel_hair(c)
		"axel_leg": _axel_leg(c)
		"axel_tail": _axel_tail(c)
		"axel_fin": _axel_fin(c)
		_:
			pass


# --- Kid-drawing helpers (the same marker kit as ArtRivals) ---------------------------------

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


## An open marker stroke, only where it crosses `inside`.
static func _clip_ink(c: CanvasItem, line: PackedVector2Array, inside: PackedVector2Array,
		width: float, seed: int, color := INK) -> void:
	var k := 0
	for piece in Geometry2D.intersect_polyline_with_polygon(line, inside):
		if piece.size() >= 2:
			Crayon.marker_line(c, piece, color, width, seed + k, false)
		k += 1


## An open black marker stroke.
static func _ink(c: CanvasItem, pts: PackedVector2Array, width: float, seed: int) -> void:
	Crayon.marker_line(c, pts, INK, width, seed, false)


## A white shine stroke, the way a kid leaves a gap of paper.
static func _shine(c: CanvasItem, pts: PackedVector2Array, width: float, seed: int) -> void:
	Crayon.marker_line(c, pts, Color(1, 1, 1, 0.88), width, seed, false)


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


## Two paths end to end (the second starts where the first stops).
static func _join(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	var out := a.duplicate()
	for i in range(1, b.size()):
		out.append(b[i])
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


## The point at angle `a` round a superellipse of exponent `e` (2 = a circle, more = squarer).
static func _super(a: float, e: float) -> Vector2:
	var cx := cos(a)
	var sy := sin(a)
	return Vector2(signf(cx) * pow(absf(cx), 2.0 / e), signf(sy) * pow(absf(sy), 2.0 / e))


## A rounded-square blob (superellipse).
static func _squircle(center: Vector2, r: Vector2, e: float, seed: int, count := 40,
		lumpy := 0.03) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in count:
		var k := 1.0 + Crayon.noise(seed, i) * lumpy
		pts.append(center + _super(TAU * i / count, e) * r * k)
	return pts


## A band straight across a path at fraction `t`, for stripes and rings.
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


## A spot in a box, by fraction - the same sums PetBuilder uses to place parts.
static func _at(box: Rect2, uv: Vector2) -> Vector2:
	return box.position + box.size * uv


## Dark spots of `color` inside `shape`: [[centre, radius], ...].
static func _spots(c: CanvasItem, shape: PackedVector2Array, list: Array, color: Color, seed: int,
		outline := 0.0) -> void:
	for i in list.size():
		var at: Vector2 = list[i][0]
		var r: float = list[i][1]
		_clip_fill(c, Crayon.blob(at, Vector2(r * 1.1, r), seed + i, 12, 0.12), shape, color,
			seed + 20 + i, 10.0, outline)


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


## Lashes flicked up off the top of an eye.
static func _lashes(c: CanvasItem, seed: int, r: Vector2, n := 3, length := 34.0) -> void:
	for i in n:
		var a := -PI * 0.5 + (i - (n - 1) * 0.5) * 0.45 + 0.3
		var root := O + Vector2(cos(a) * r.x, sin(a) * r.y)
		var tip := root + Vector2(cos(a), sin(a)) * length + Vector2(8, -4)
		_ink(c, _bez(root, root.lerp(tip, 0.5) + Vector2(-4, -4), tip, tip, 4), 9.0, seed + i)


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


## A pointy spike or crest scale growing up from the dot at (256, 440).
static func _spike_shape(half_w: float, height: float, lean := 0.0) -> PackedVector2Array:
	var base := 452.0
	var tip := Vector2(256 + lean, base - height)
	var l := _bez(Vector2(256 - half_w, base), Vector2(256 - half_w * 0.8, base - height * 0.35),
		tip + Vector2(-half_w * 0.3, height * 0.25), tip, 6)
	var r := _bez(tip, tip + Vector2(half_w * 0.3, height * 0.25),
		Vector2(256 + half_w * 0.8, base - height * 0.35), Vector2(256 + half_w, base), 6)
	return _join(l, r)


# --- Bubbles: pink jellyfish, round bell body, six wavy tentacles ----------------------------

const BB_PINK := Color("#f8a5d5")
const BB_RIM := Color("#d3a9f5")
const BB_SPOT := Color("#ffe2f2")
const BB_TENT := Color("#dfb3f7")

## A bell: a squarish dome on top, short straight sides, a scalloped rim along the bottom.
static func _bubbles_shape() -> PackedVector2Array:
	var ctr := Vector2(256, 262)
	var rx := 190.0
	var ry := 168.0
	var pts := PackedVector2Array()
	var n := 24
	for i in n + 1:
		var k := 1.0 + Crayon.noise(901, i) * 0.025
		pts.append(ctr + _super(PI + PI * i / n, 2.8) * Vector2(rx, ry) * k)
	var bottom := ctr.y + 52.0
	var bumps := 5
	var bw := rx * 2.0 / bumps
	for b in bumps:
		var depth := 30.0 + Crayon.noise(902, b) * 6.0
		for j in range(1, 8):
			var t := j / 7.0
			pts.append(Vector2(ctr.x + rx - (b + t) * bw, bottom + sin(t * PI) * depth))
	return pts


static func _bubbles_body(c: CanvasItem) -> void:
	var body := _bubbles_shape()
	_fill(c, body, BB_PINK, 903)
	var box := _box(body, W_BODY)
	var wave := PackedVector2Array()
	for i in 14:
		wave.append(Vector2(40.0 + i * 34.0, 302.0 + sin(i * 1.4) * 6.0))
	var rim := wave.duplicate()
	rim.append(Vector2(482, 440))
	rim.append(Vector2(40, 440))
	_clip_fill(c, rim, body, BB_RIM, 904)
	_spots(c, body, [[Vector2(150, 172), 26.0], [Vector2(222, 128), 16.0], [Vector2(110, 246), 18.0],
		[Vector2(208, 216), 13.0], [Vector2(262, 172), 10.0]], BB_SPOT, 905, 5.0)
	_clip_fill(c, Crayon.blob(_at(box, Vector2(0.7, 0.47)), Vector2(24, 13), 916, 12, 0.08), body,
		BLUSH, 917, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 918)
	_clip_ink(c, wave, body, 6.0, 919)
	_shine(c, _bez(Vector2(102, 214), Vector2(106, 166), Vector2(136, 130), Vector2(176, 112), 8), 11.0, 920)


static func _bubbles_eye(c: CanvasItem) -> void:
	_eye(c, 931, Vector2(66, 72), Color(), 0.0, Vector2(36, 42), Vector2(6, 6))
	c.draw_circle(O + Vector2(24, 28), 7.0, Color.WHITE)
	_lashes(c, 935, Vector2(66, 72))


static func _bubbles_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 941, Vector2(70, 62), 0.55)


## A ribbon that waves more the further down it goes.
static func _bubbles_tentacle(c: CanvasItem) -> void:
	var path := PackedVector2Array()
	var n := 26
	for i in n + 1:
		var t := i / float(n)
		path.append(Vector2(256.0 + sin(t * TAU * 1.4) * 24.0 * minf(1.0, t * 2.5), 56.0 + t * 252.0))
	var shape := _tube(path, 18.0, 9.0, 0.3)
	_fill(c, shape, BB_TENT, 921)
	_clip_ink(c, path.slice(3, n - 1), shape, 6.0, 922, BB_PINK.darkened(0.15))
	Crayon.marker_line(c, shape, INK, W_BODY, 923)


# --- Squidge: purple octopus, big round body, eight curly tentacles --------------------------

const SQ_PURPLE := Color("#b69df3")
const SQ_DARK := Color("#9078e0")
const SQ_PALE := Color("#ddd0fd")
const SQ_SUCKER := Color("#f6e0ff")

static func _squidge_shape() -> PackedVector2Array:
	var ctr := Vector2(256, 282)
	var pts := PackedVector2Array()
	var n := 40
	for i in n:
		var a := TAU * i / n
		var up := sin(a) < 0.0
		var p := _super(a, 2.6 if up else 2.8)
		var k := 1.0 + Crayon.noise(1001, i) * 0.03
		var q := Vector2(p.x * 190.0, p.y * (196.0 if up else 108.0)) * k
		if up:
			q.x -= q.y * 0.09   # the big round head leans forward a little
		pts.append(ctr + q)
	return pts


static func _squidge_body(c: CanvasItem) -> void:
	var body := _squidge_shape()
	_fill(c, body, SQ_PURPLE, 1002)
	var box := _box(body, W_BODY)
	_clip_fill(c, Crayon.blob(Vector2(256, 410), Vector2(230, 50), 1003, 18, 0.05), body, SQ_PALE, 1004)
	_spots(c, body, [[Vector2(128, 186), 26.0], [Vector2(196, 136), 18.0], [Vector2(104, 268), 16.0],
		[Vector2(196, 222), 13.0], [Vector2(256, 160), 9.0], [Vector2(150, 330), 10.0]], SQ_DARK, 1005)
	_clip_fill(c, Crayon.blob(_at(box, Vector2(0.72, 0.5)), Vector2(24, 13), 1012, 12, 0.08), body,
		BLUSH, 1013, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1014)
	_shine(c, _bez(Vector2(96, 236), Vector2(98, 180), Vector2(126, 140), Vector2(170, 118), 8), 12.0, 1015)


static func _squidge_eye(c: CanvasItem) -> void:
	_eye(c, 1031, Vector2(72, 78), Color("#ffd45e"), 50.0, Vector2(23, 29), Vector2(8, 4))


static func _squidge_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1041, Vector2(80, 64), 0.35)


## Down in a wiggle, then a curl at the tip - suckers along the front.
static func _squidge_tentacle(c: CanvasItem) -> void:
	var path := PackedVector2Array()
	var n := 14
	for i in n + 1:
		var t := i / float(n)
		path.append(Vector2(256.0 + sin(t * PI * 1.6) * 26.0 * t, 54.0 + t * 190.0))
	var cc := path[n] + Vector2(36, 4)
	var steps := 14
	for i in range(1, steps + 1):
		var t := i / float(steps)
		var a := PI - t * PI * 1.35
		path.append(cc + Vector2(cos(a), sin(a)) * lerpf(36.0, 18.0, t))
	var shape := _tube(path, 19.0, 6.0, 0.3)
	_fill(c, shape, SQ_PURPLE, 1051)
	for k in 5:
		var i := 3 + k * 2
		var p := path[i]
		var d := (path[i + 1] - path[i - 1]).normalized()
		var w := lerpf(19.0, 6.0, i / float(path.size() - 1))
		var at := p + d.orthogonal() * (w - 8.0)
		var s := Crayon.blob(at, Vector2(8, 7), 1052 + k, 10, 0.08)
		c.draw_colored_polygon(s, SQ_SUCKER)
		Crayon.marker_line(c, s, INK, 4.0, 1060 + k)
	Crayon.marker_line(c, shape, INK, W_BODY, 1070)


# --- Shelly: red crab, eye-stalk antennae, two arms with big pincers, six legs ---------------

const SH_RED := Color("#ff8a78")
const SH_CLAW := Color("#fb6a5a")
const SH_DARK := Color("#e65a50")
const SH_PALE := Color("#ffbdad")
const SH_BELLY := Color("#ffd8c6")
const SH_TIP := Color("#c9443e")

static func _shelly_body(c: CanvasItem) -> void:
	var body := _squircle(Vector2(256, 262), Vector2(202, 108), 2.8, 1101, 44, 0.03)
	_fill(c, body, SH_RED, 1102)
	var box := _box(body, W_BODY)
	_clip_fill(c, Crayon.blob(Vector2(262, 374), Vector2(232, 56), 1103, 18, 0.04), body, SH_BELLY, 1104)
	_spots(c, body, [[Vector2(116, 214), 18.0], [Vector2(172, 186), 13.0], [Vector2(232, 204), 16.0],
		[Vector2(150, 254), 11.0], [Vector2(92, 282), 9.0], [Vector2(280, 176), 9.0]], SH_PALE, 1105, 5.0)
	_clip_fill(c, Crayon.blob(_at(box, Vector2(0.74, 0.5)), Vector2(22, 12), 1112, 12, 0.08), body,
		BLUSH, 1113, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1114)
	# a row of little shell bumps along the bottom edge
	for i in 4:
		var x := 120.0 + i * 52.0
		_ink(c, _bez(Vector2(x, 330), Vector2(x + 8, 342), Vector2(x + 24, 342), Vector2(x + 32, 330), 4), 5.0, 1115 + i)


static func _shelly_eye(c: CanvasItem) -> void:
	_eye(c, 1171, Vector2(64, 70), Color(), 0.0, Vector2(32, 38), Vector2(6, 4))


static func _shelly_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1161, Vector2(76, 60), 0.35)


## A stalk boinging up with a round bobble on top.
static func _shelly_antenna(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 458), Vector2(252, 400), Vector2(276, 350), Vector2(270, 304), 10)
	var stalk := _tube(path, 12.0, 10.0, 0.4)
	_part(c, stalk, SH_RED, 1151, W_ANT)
	var knob := Crayon.blob(Vector2(270, 280), Vector2(30, 28), 1153, 14, 0.05)
	_part(c, knob, Color("#ffc65a"), 1154, W_ANT, 14.0)
	c.draw_circle(Vector2(260, 270), 7.0, Color(1, 1, 1, 0.85))


## A short arm and a big round palm held in front of its tummy. Each arm gets TWO claws
## (claw_on_arm: 2), one at each side of the palm's underside, so the pair makes the pincer.
static func _shelly_arm(c: CanvasItem) -> void:
	var arm := _tube(_seg(Vector2(256, 66), Vector2(242, 116), 4), 20.0, 22.0, 0.5)
	var palm := Crayon.blob(Vector2(232, 162), Vector2(62, 52), 1121, 18, 0.03)
	var shape := _merge(arm, palm)
	_fill(c, shape, SH_CLAW, 1122)
	_clip_fill(c, Crayon.blob(Vector2(208, 142), Vector2(18, 13), 1123, 10, 0.1), shape, SH_PALE, 1124, 10.0)
	Crayon.marker_line(c, shape, INK, W_ARM, 1125)
	_spots(c, shape, [[Vector2(256, 178), 7.0], [Vector2(224, 188), 5.0]], SH_TIP, 1126)


## One fat pincer prong poking down; a pair of them on a palm is the claw.
static func _shelly_claw(c: CanvasItem) -> void:
	var left := _bez(Vector2(196, 112), Vector2(184, 216), Vector2(212, 300), Vector2(266, 346), 10)
	var right := _bez(Vector2(266, 346), Vector2(306, 296), Vector2(326, 214), Vector2(316, 112), 10)
	var top := _bez(Vector2(316, 112), Vector2(306, 86), Vector2(206, 86), Vector2(196, 112), 6)
	var claw := _join(_join(left, right), top)
	claw.remove_at(claw.size() - 1)
	_fill(c, claw, SH_CLAW, 1181)
	_clip_fill(c, PackedVector2Array([Vector2(160, 282), Vector2(360, 266), Vector2(360, 380),
		Vector2(160, 380)]), claw, SH_TIP, 1182, 14.0)
	Crayon.marker_line(c, claw, INK, W_CLAW, 1183)
	_shine(c, _bez(Vector2(218, 132), Vector2(210, 170), Vector2(212, 214), Vector2(224, 246), 6), 12.0, 1184)


## A pointy jointed crab leg: out to the knee, then down to a tip.
static func _shelly_leg(c: CanvasItem) -> void:
	var path := _join(_bez(Vector2(256, 64), Vector2(266, 92), Vector2(282, 108), Vector2(300, 122), 6),
		_bez(Vector2(300, 122), Vector2(312, 146), Vector2(310, 170), Vector2(296, 196), 6))
	var leg := _tube(path, 17.0, 5.0, 0.4)
	_fill(c, leg, SH_RED, 1141)
	_clip_fill(c, Crayon.blob(Vector2(300, 122), Vector2(22, 20), 1142, 10, 0.05), leg, SH_DARK, 1143, 10.0)
	Crayon.marker_line(c, leg, INK, W_BODY, 1144)


# --- Finnegan: grey seal, whiskery nose, flippers, tail flipper ------------------------------

const FN_GREY := Color("#b7c4d2")
const FN_DARK := Color("#8e9eb3")
const FN_PALE := Color("#e8eef4")
const FN_NOSE := Color("#3b3646")

static func _finnegan_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 268), Vector2(206, 110), 0.5, 1201, 28, 0.03)
	_fill(c, body, FN_GREY, 1202)
	_clip_fill(c, Crayon.blob(Vector2(300, 354), Vector2(190, 62), 1203, 18, 0.05), body, FN_PALE, 1204)
	_spots(c, body, [[Vector2(140, 238), 13.0], [Vector2(196, 206), 16.0], [Vector2(262, 196), 11.0],
		[Vector2(214, 256), 9.0], [Vector2(104, 272), 8.0], [Vector2(306, 222), 10.0]], FN_DARK, 1205)
	Crayon.marker_line(c, body, INK, W_BODY, 1212)


static func _finnegan_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(272, 298), Vector2(104, 94), 1221, 20, 0.04)
	var muzzle := Crayon.blob(Vector2(360, 336), Vector2(70, 48), 1222, 16, 0.04)
	var neck := _tube(_seg(Vector2(204, 414), Vector2(244, 364), 6), 38.0, 38.0)
	var head := _merge_all([skull, neck, muzzle])
	_fill(c, head, FN_GREY, 1223)
	_clip_fill(c, Crayon.blob(Vector2(362, 352), Vector2(58, 36), 1224, 14, 0.06), head, FN_PALE, 1225)
	_spots(c, head, [[Vector2(232, 246), 14.0], [Vector2(206, 300), 9.0]], FN_DARK, 1226)
	Crayon.marker_line(c, head, INK, W_BODY, 1229)
	for i in 3:
		c.draw_circle(Vector2(336 + i * 14, 352 + (i % 2) * 9), 3.5, INK)


static func _finnegan_eye(c: CanvasItem) -> void:
	_eye(c, 1261, Vector2(62, 68), Color(), 0.0, Vector2(42, 48), Vector2(4, 4))
	c.draw_circle(O + Vector2(20, 26), 7.0, Color(1, 1, 1, 0.9))


static func _finnegan_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1271, Vector2(74, 60), 0.45)


## A round black nose sticking out to the right, whiskers fanning both ways.
static func _finnegan_nose(c: CanvasItem) -> void:
	var tips := [Vector2(330, 236), Vector2(342, 282), Vector2(320, 328), Vector2(112, 262), Vector2(116, 304)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		var root := Vector2(206 + (i % 3) * 6, 274 + (i % 3) * 6)
		_ink(c, _bez(root, root.lerp(tip, 0.4) + Vector2(0, -8), tip.lerp(root, 0.2), tip, 6), 7.0, 1231 + i)
	var nose := Crayon.blob(Vector2(222, 248), Vector2(46, 34), 1237, 16, 0.05)
	_part(c, nose, FN_NOSE, 1238, 10.0, 14.0)
	c.draw_circle(Vector2(206, 236), 9.0, Color(1, 1, 1, 0.8))


## A flipper hanging down from the shoulder, its tip turned forward.
static func _finnegan_arm(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 66), Vector2(250, 136), Vector2(252, 196), Vector2(294, 236), 10)
	var flip := _tube(path, 22.0, 38.0, 0.4, 0.8)
	_fill(c, flip, FN_GREY, 1241)
	var end := path[path.size() - 1]
	_clip_fill(c, Crayon.blob(end, Vector2(46, 46), 1242, 12, 0.08), flip, FN_DARK, 1243, 12.0)
	Crayon.marker_line(c, flip, INK, W_ARM, 1244)
	var d := (end - path[path.size() - 3]).normalized()
	var n := d.orthogonal()
	for i in 3:
		var s := (i - 1) * 0.5
		_ink(c, _seg(end + n * s * 30.0 - d * 14.0, end + n * s * 30.0 + d * 18.0, 2), 5.0, 1245 + i)


## A little round flipper leaning back.
static func _finnegan_fin(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 446), Vector2(254, 410), Vector2(242, 380), Vector2(218, 358), 8)
	var fin := _tube(path, 26.0, 30.0, 0.5, 1.0)
	_fill(c, fin, FN_GREY, 1251)
	_clip_fill(c, Crayon.blob(Vector2(218, 356), Vector2(30, 28), 1252, 12, 0.08), fin, FN_DARK, 1253, 12.0)
	Crayon.marker_line(c, fin, INK, W_FIN, 1254)


## A short stub, then a two-lobed flipper fanning back.
static func _finnegan_tail(c: CanvasItem) -> void:
	var stub := _tube(_seg(Vector2(450, 256), Vector2(352, 258), 6), 34.0, 28.0)
	var up := _tube(_bez(Vector2(362, 252), Vector2(320, 240), Vector2(290, 212), Vector2(250, 188), 8), 22.0, 34.0)
	var dn := _tube(_bez(Vector2(362, 262), Vector2(320, 276), Vector2(290, 304), Vector2(250, 328), 8), 22.0, 34.0)
	var tail := _merge_all([stub, up, dn])
	_fill(c, tail, FN_GREY, 1281)
	_clip_fill(c, Crayon.blob(Vector2(240, 258), Vector2(50, 96), 1282, 14, 0.06), tail, FN_DARK, 1283)
	Crayon.marker_line(c, tail, INK, W_BODY, 1284)
	for i in 2:
		var y := 188.0 + i * 140.0
		_ink(c, _seg(Vector2(262, y + (8 if i == 0 else -8)), Vector2(236, y), 2), 5.0, 1285 + i)


# --- Puddles: green frog, wide mouth, eyes on top, hands and big webbed feet -----------------

const PD_GREEN := Color("#9bd96e")
const PD_DARK := Color("#68b850")
const PD_BELLY := Color("#f4f1a6")
const PD_WEB := Color("#c4ec92")

## A squat frog, its back higher than its nose.
static func _puddles_base() -> PackedVector2Array:
	var back := Crayon.blob(Vector2(200, 270), Vector2(150, 108), 1301, 22, 0.03)
	var front := Crayon.blob(Vector2(296, 314), Vector2(152, 88), 1302, 22, 0.03)
	return _merge(back, front)


## The base with a bump for each eye, round where PetBuilder will put the eyes so they bulge
## out of the top like a frog's.
static func _puddles_shape() -> PackedVector2Array:
	var base := _puddles_base()
	var box := _box(base, W_BODY)
	var shape := base
	for u in [0.66, 0.9]:
		var e := _at(box, Vector2(u, 0.3))
		shape = _merge(shape, Crayon.blob(e + Vector2(-6, -8), Vector2(40, 38), 1303, 16, 0.03))
	return shape


static func _puddles_body(c: CanvasItem) -> void:
	var body := _puddles_shape()
	_fill(c, body, PD_GREEN, 1305)
	var box := _box(body, W_BODY)
	_clip_fill(c, Crayon.blob(_at(box, Vector2(0.64, 0.9)), Vector2(140, 60), 1306, 18, 0.05), body, PD_BELLY, 1307)
	_spots(c, body, [[Vector2(124, 214), 20.0], [Vector2(188, 172), 15.0], [Vector2(96, 292), 14.0],
		[Vector2(170, 252), 11.0], [Vector2(236, 214), 12.0], [Vector2(210, 316), 9.0]], PD_DARK, 1308, 5.0)
	_clip_fill(c, Crayon.blob(_at(box, Vector2(0.6, 0.47)), Vector2(22, 12), 1320, 12, 0.08), body,
		BLUSH, 1321, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1322)


static func _puddles_eye(c: CanvasItem) -> void:
	_eye(c, 1341, Vector2(74, 78), Color("#ffd94a"), 50.0, Vector2(32, 18), Vector2(6, 4))


static func _puddles_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1331, Vector2(100, 56), 0.3)


## A front leg: down from the shoulder, elbow out in front, down to the ground.
static func _puddles_arm(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 66), Vector2(306, 150), Vector2(300, 226), Vector2(268, 298), 12)
	var arm := _tube(path, 28.0, 19.0, 0.5)
	_part(c, arm, PD_GREEN, 1351, W_ARM)
	_spots(c, arm, [[Vector2(286, 150), 9.0], [Vector2(288, 236), 6.0]], PD_DARK, 1353)


## Three fingers with round sticky pads, webbing between, spread out on the ground.
static func _puddles_hand(c: CanvasItem) -> void:
	var root := Vector2(256, 98)
	var tips := [Vector2(196, 160), Vector2(262, 184), Vector2(326, 162)]
	var web := PackedVector2Array([root + Vector2(-24, -6), tips[0], tips[0].lerp(tips[1], 0.5) + Vector2(4, -14),
		tips[1], tips[1].lerp(tips[2], 0.5) + Vector2(-4, -14), tips[2], root + Vector2(24, -6)])
	_part(c, web, PD_WEB, 1361, 9.0, 14.0)
	var fingers := [Crayon.blob(root, Vector2(34, 28), 1362, 12, 0.05)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		fingers.append(_tube(_seg(root + Vector2(0, 8), tip, 5), 14.0, 13.0))
		fingers.append(Crayon.blob(tip, Vector2(21, 19), 1363 + i, 12, 0.05))
	_part(c, _merge_all(fingers), PD_GREEN, 1370, W_HAND, 14.0)


## A big fat folded-up frog leg: a round thigh bulging back, the shin tucked under it.
static func _puddles_leg(c: CanvasItem) -> void:
	var thigh := Crayon.blob(Vector2(228, 112), Vector2(56, 58), 1370, 18, 0.04)
	var top := _tube(_seg(Vector2(256, 62), Vector2(240, 100), 3), 34.0, 40.0)
	var shin := _tube(_bez(Vector2(212, 150), Vector2(214, 174), Vector2(232, 182), Vector2(252, 180), 6), 24.0, 22.0)
	var leg := _merge_all([thigh, top, shin])
	_part(c, leg, PD_GREEN, 1371)
	_spots(c, leg, [[Vector2(214, 100), 11.0], [Vector2(246, 130), 7.0], [Vector2(196, 140), 6.0]], PD_DARK, 1373, 5.0)
	_ink(c, _bez(Vector2(190, 150), Vector2(206, 166), Vector2(236, 166), Vector2(262, 150), 6), 6.0, 1376)


## A big webbed foot, toes out to the right.
static func _puddles_foot(c: CanvasItem) -> void:
	var ankle := Vector2(196, 146)
	var tips := [Vector2(410, 128), Vector2(440, 176), Vector2(404, 218)]
	var web := PackedVector2Array([ankle + Vector2(10, -24), tips[0],
		tips[0].lerp(tips[1], 0.5) + Vector2(-22, 0), tips[1], tips[1].lerp(tips[2], 0.5) + Vector2(-22, 0),
		tips[2], ankle + Vector2(20, 30)])
	_part(c, web, PD_WEB, 1381, W_EAR, 14.0)
	var toes := [Crayon.blob(ankle + Vector2(16, 6), Vector2(42, 32), 1382, 12, 0.05)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		toes.append(_tube(_seg(ankle + Vector2(24, 4), tip, 6), 15.0, 13.0))
		toes.append(Crayon.blob(tip, Vector2(22, 20), 1383 + i, 12, 0.05))
	_part(c, _merge_all(toes), PD_GREEN, 1390, W_EAR, 14.0)


# --- Coral: orange seahorse, curly tail, back fin, spiky crest -------------------------------

const CO_ORANGE := Color("#ffab5e")
const CO_DARK := Color("#f08a3e")
const CO_BELLY := Color("#ffe4a6")
const CO_FIN := Color("#8fe0de")
const CO_SPIKE := Color("#ffd65a")
const CO_LIPS := Color("#ff8db0")

## A chubby upright bean: round belly at the front, the back curving down to the tail.
static func _coral_shape() -> PackedVector2Array:
	var back := _egg(Vector2(236, 256), Vector2(130, 140), 0.3, 1401, 26, 0.03)
	var belly := Crayon.blob(Vector2(282, 302), Vector2(108, 100), 1402, 20, 0.03)
	return _merge(back, belly)


static func _coral_body(c: CanvasItem) -> void:
	var body := _coral_shape()
	_fill(c, body, CO_ORANGE, 1403)
	var belly := Crayon.blob(Vector2(330, 304), Vector2(84, 108), 1404, 16, 0.05)
	_clip_fill(c, belly, body, CO_BELLY, 1405)
	var inside := Geometry2D.intersect_polygons(belly, body)
	if not inside.is_empty():
		var patch: PackedVector2Array = inside[0]
		for i in 6:
			var y := 220.0 + i * 32.0
			_clip_ink(c, _seg(Vector2(220, y - 6), Vector2(460, y + 10), 4), patch, 5.0, 1406 + i)
	_spots(c, body, [[Vector2(160, 214), 10.0], [Vector2(200, 170), 8.0], [Vector2(140, 290), 9.0],
		[Vector2(214, 252), 7.0]], CO_DARK, 1412)
	Crayon.marker_line(c, body, INK, W_BODY, 1418)


static func _coral_head(c: CanvasItem) -> void:
	var neck := _tube(_bez(Vector2(202, 414), Vector2(212, 384), Vector2(234, 352), Vector2(262, 326), 6), 42.0, 40.0)
	var skull := Crayon.blob(Vector2(300, 278), Vector2(100, 88), 1421, 20, 0.04)
	var snout := _tube(_seg(Vector2(350, 318), Vector2(408, 350), 6), 27.0, 22.0)
	var tip := Crayon.blob(Vector2(414, 356), Vector2(30, 26), 1422, 12, 0.05)
	var bump := Crayon.blob(Vector2(228, 214), Vector2(34, 30), 1423, 12, 0.05)
	var head := _merge_all([skull, neck, snout, tip, bump])
	_fill(c, head, CO_ORANGE, 1424)
	_spots(c, head, [[Vector2(250, 236), 9.0], [Vector2(282, 214), 7.0], [Vector2(236, 284), 8.0]], CO_DARK, 1425)
	_clip_fill(c, Crayon.blob(Vector2(318, 330), Vector2(22, 13), 1430, 12, 0.08), head, BLUSH, 1431, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1432)
	for i in 2:
		var t := 0.3 + i * 0.28
		var p := Vector2(350, 318).lerp(Vector2(408, 350), t)
		_ink(c, _seg(p + Vector2(-10, 22), p + Vector2(10, -22), 2), 5.0, 1433 + i)


static func _coral_eye(c: CanvasItem) -> void:
	_eye(c, 1441, Vector2(70, 74), Color("#5fc4dc"), 44.0, Vector2(22, 26), Vector2(8, 4))
	_lashes(c, 1446, Vector2(70, 74))


## A round puckered "o", the way a seahorse slurps.
static func _coral_mouth(c: CanvasItem) -> void:
	var lips := Crayon.blob(O, Vector2(76, 68), 1451, 22, 0.035)
	_fill(c, lips, CO_LIPS, 1452, 18.0)
	var hole := Crayon.blob(O + Vector2(4, 2), Vector2(44, 38), 1453, 18, 0.05)
	_fill(c, hole, MOUTH_IN.darkened(0.15), 1454, 14.0)
	_clip_fill(c, Crayon.blob(O + Vector2(8, 26), Vector2(26, 16), 1455, 12, 0.06), hole, TONGUE, 1456, 12.0)
	Crayon.marker_line(c, hole, INK, 9.0, 1457)
	Crayon.marker_line(c, lips, INK, W_MOUTH, 1458)
	c.draw_circle(O + Vector2(-36, -40), 8.0, Color(1, 1, 1, 0.8))


## A fan with rays, scalloped round the top.
static func _coral_fin(c: CanvasItem) -> void:
	var base := Vector2(256, 450)
	var fan := PackedVector2Array([base + Vector2(-34, 0)])
	var n := 14
	for i in n + 1:
		var a := PI + 0.28 + (PI - 0.56) * i / n
		var k := 1.0 if i % 2 == 0 else 0.9
		fan.append(base + Vector2(cos(a) * 76.0, sin(a) * 118.0) * k)
	fan.append(base + Vector2(34, 0))
	_fill(c, fan, CO_FIN, 1461)
	for i in 4:
		var a := PI + 0.55 + (PI - 1.1) * i / 3.0
		_ink(c, _seg(base + Vector2(0, -14), base + Vector2(cos(a) * 64.0, sin(a) * 100.0), 3), 5.0, 1462 + i)
	Crayon.marker_line(c, fan, INK, W_FIN, 1467)


static func _coral_spike(c: CanvasItem) -> void:
	_part(c, _spike_shape(40.0, 92.0, 6.0), CO_SPIKE, 1471, W_ANT)


## Out to the left, then curled round underneath into a spiral, with rings.
static func _coral_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(450, 256), Vector2(400, 258), Vector2(340, 262), Vector2(300, 290), 10)
	var cc := Vector2(300, 350)
	var steps := 26
	for i in range(1, steps + 1):
		var t := i / float(steps)
		var a := -PI * 0.5 - t * TAU * 0.85
		path.append(cc + Vector2(cos(a), sin(a)) * lerpf(60.0, 30.0, t))
	var tail := _tube(path, 38.0, 11.0, 0.3)
	_fill(c, tail, CO_ORANGE, 1481)
	for k in 6:
		_clip_fill(c, _band(path, 0.12 + k * 0.13, 50.0, 6.0), tail, CO_DARK, 1482 + k, 10.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 1490)


# --- Gloop: lime-green slime blob, one big eye, a drip on its side ---------------------------

const GL_LIME := Color("#c9ec5c")
const GL_DARK := Color("#a3d23e")
const GL_PALE := Color("#e6f7a6")
const GL_DRIP := Color("#9edb45")

## A wobbly dome sitting in its own puddle of slime, a slimy trail behind it.
static func _gloop_shape() -> PackedVector2Array:
	var ctr := Vector2(322, 250)
	var dome := PackedVector2Array()
	var n := 34
	for i in n:
		var a := TAU * i / n
		var s := sin(a)
		var rx := lerpf(140.0, 158.0, (s + 1.0) * 0.5)
		var ry := 150.0 if s < 0.0 else 108.0
		var k := 1.0 + Crayon.noise(1501, i) * 0.04
		dome.append(ctr + Vector2(cos(a) * rx, s * ry) * k)
	var trail := Crayon.blob(Vector2(176, 340), Vector2(146, 32), 1502, 18, 0.06)
	return _merge(dome, trail)


static func _gloop_body(c: CanvasItem) -> void:
	var body := _gloop_shape()
	_fill(c, body, GL_LIME, 1503)
	_clip_fill(c, Crayon.blob(Vector2(140, 350), Vector2(130, 30), 1504, 16, 0.08), body, GL_PALE, 1505, 12.0)
	_clip_fill(c, Crayon.blob(Vector2(330, 372), Vector2(150, 26), 1506, 16, 0.08), body, GL_DARK, 1507, 12.0)
	var bubbles := [[Vector2(320, 316), 12.0], [Vector2(372, 296), 7.0], [Vector2(96, 346), 8.0],
		[Vector2(210, 340), 6.0], [Vector2(420, 324), 8.0], [Vector2(300, 140), 6.0]]
	for i in bubbles.size():
		var at: Vector2 = bubbles[i][0]
		var r: float = bubbles[i][1]
		var b := Crayon.blob(at, Vector2(r, r), 1508 + i, 10, 0.05)
		c.draw_colored_polygon(b, GL_PALE)
		Crayon.marker_line(c, b, INK, 4.0, 1520 + i)
	Crayon.marker_line(c, body, INK, W_BODY, 1530)
	_shine(c, _bez(Vector2(208, 210), Vector2(212, 162), Vector2(240, 126), Vector2(280, 112), 8), 13.0, 1531)
	c.draw_circle(Vector2(204, 238), 7.0, Color(1, 1, 1, 0.88))


static func _gloop_eye(c: CanvasItem) -> void:
	_eye(c, 1541, Vector2(88, 94), Color("#7fd0ff"), 54.0, Vector2(28, 32), Vector2(8, 6))
	c.draw_circle(O + Vector2(32, 36), 8.0, Color.WHITE)


static func _gloop_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1551, Vector2(88, 68), 0.3, 2)


## A dollop of goo sliding down its side, three drips hanging off it.
static func _gloop_other(c: CanvasItem) -> void:
	var goo := [Crayon.blob(Vector2(256, 236), Vector2(54, 30), 1561, 16, 0.1)]
	var drips := [[Vector2(220, 244), 40.0, 13.0], [Vector2(258, 252), 78.0, 18.0], [Vector2(294, 242), 30.0, 11.0]]
	for i in drips.size():
		var at: Vector2 = drips[i][0]
		var length: float = drips[i][1]
		var r: float = drips[i][2]
		goo.append(_tube(_seg(at, at + Vector2(0, length), 4), r * 0.75, r))
	var drip := _merge_all(goo)
	_part(c, drip, GL_DRIP, 1562)
	_shine(c, _bez(Vector2(224, 226), Vector2(232, 218), Vector2(246, 216), Vector2(258, 218), 4), 7.0, 1564)
	for i in drips.size():
		var at: Vector2 = drips[i][0]
		var length: float = drips[i][1]
		var r: float = drips[i][2]
		c.draw_circle(at + Vector2(-r * 0.35, length - r * 0.1), r * 0.28, Color(1, 1, 1, 0.85))


# --- Sir Snail: a spiral shell (its other part), eye-stalk antennae --------------------------

const SN_BODY := Color("#f6dc92")
const SN_DARK := Color("#e5bd62")
const SN_SHELL := Color("#8fcaf2")
const SN_SWIRL := Color("#5ea9e0")
const SN_GOLD := Color("#ffd447")
const SN_BOW := Color("#ff6f86")

## A long soft foot, the front of it rising up into a big round head end.
static func _snail_shape() -> PackedVector2Array:
	var foot := _tube(_bez(Vector2(30, 356), Vector2(150, 364), Vector2(300, 356), Vector2(428, 344), 14), 10.0, 36.0)
	var neck := _squircle(Vector2(346, 238), Vector2(126, 124), 2.4, 1601, 40, 0.025)
	return _merge(foot, neck)


## Where the shell's middle goes on its own sheet. Its dot lands on the body at (0.5, 0.45)
## of the body's box, only just behind the eyes, so a shell centred on it would cover the face.
## The dot is on the shell's front rim instead and the shell sits back over the foot.
static func _snail_shell_center() -> Vector2:
	var box := _box(_snail_shape(), W_BODY)
	return O + _at(box, Vector2(0.27, 0.43)) - _at(box, Vector2(0.5, 0.45))


static func _snail_body(c: CanvasItem) -> void:
	var body := _snail_shape()
	_fill(c, body, SN_BODY, 1603)
	var box := _box(body, W_BODY)
	_clip_fill(c, _tube(_bez(Vector2(10, 388), Vector2(150, 396), Vector2(300, 388), Vector2(480, 376), 14), 14.0, 14.0),
		body, SN_DARK, 1604)
	_spots(c, body, [[Vector2(300, 170), 8.0], [Vector2(272, 214), 6.0], [Vector2(120, 352), 7.0],
		[Vector2(200, 356), 6.0]], SN_DARK, 1605)
	_clip_fill(c, Crayon.blob(_at(box, Vector2(0.76, 0.5)), Vector2(20, 12), 1612, 12, 0.08), body,
		BLUSH, 1613, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1614)
	# a smart red bow tie
	var bow := _at(box, Vector2(0.8, 0.8))
	for s in [-1.0, 1.0]:
		var wing := PackedVector2Array([bow + Vector2(s * 6, 0), bow + Vector2(s * 34, -18),
			bow + Vector2(s * 36, 18)])
		_part(c, wing, SN_BOW, 1615 + int(s), 6.0, 10.0)
	_part(c, Crayon.blob(bow, Vector2(10, 10), 1618, 10, 0.05), SN_BOW, 1619, 6.0, 10.0)


static func _snail_eye(c: CanvasItem) -> void:
	var white := _eye(c, 1641, Vector2(64, 70), Color("#8a6a4a"), 42.0, Vector2(22, 26), Vector2(6, 10))
	# a sleepy, dignified lid
	var lid := PackedVector2Array([Vector2(170, 150), Vector2(342, 150), Vector2(342, 236), Vector2(170, 222)])
	_clip_fill(c, lid, white, SN_BODY, 1642, 14.0)
	Crayon.marker_line(c, white, INK, W_EYE, 1643)
	_clip_ink(c, _seg(Vector2(170, 222), Vector2(342, 236), 6), white, 12.0, 1644)


static func _snail_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1651, Vector2(70, 56), 0.45)


## A soft stalk with a round blob on the end.
static func _snail_antenna(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 458), Vector2(256, 400), Vector2(276, 356), Vector2(272, 314), 10)
	var stalk := _tube(path, 15.0, 11.0, 0.4)
	var knob := Crayon.blob(Vector2(272, 292), Vector2(26, 25), 1631, 14, 0.05)
	var shape := _merge(stalk, knob)
	_fill(c, shape, SN_BODY, 1632)
	_clip_fill(c, Crayon.blob(Vector2(272, 288), Vector2(18, 17), 1633, 12, 0.06), shape, SN_DARK, 1634, 10.0)
	Crayon.marker_line(c, shape, INK, W_ANT, 1635)


## The shell: a swirl winding out from the middle, a shine, and a little gold crown.
static func _snail_shell(c: CanvasItem) -> void:
	var ctr := _snail_shell_center()
	var shell := Crayon.blob(ctr, Vector2(114, 110), 1621, 26, 0.03)
	_fill(c, shell, SN_SHELL, 1622)
	var swirl := PackedVector2Array()
	var steps := 64
	for i in steps + 1:
		var t := i / float(steps)
		var a := -PI * 0.5 + t * TAU * 2.2
		var r := lerpf(12.0, 90.0, t)
		swirl.append(ctr + Vector2(cos(a) * r, sin(a) * r * 0.96))
	_clip_fill(c, _tube(swirl, 5.0, 15.0), shell, SN_SWIRL, 1623, 12.0)
	_clip_ink(c, swirl, shell, 8.0, 1624)
	Crayon.marker_line(c, shell, INK, W_BODY, 1625)
	_shine(c, _bez(ctr + Vector2(-92, -6), ctr + Vector2(-92, -50), ctr + Vector2(-60, -84), ctr + Vector2(-22, -96), 8), 10.0, 1626)
	var top := ctr + Vector2(14, -104)
	var crown := PackedVector2Array([top + Vector2(-34, 6), top + Vector2(-36, -32), top + Vector2(-17, -14),
		top + Vector2(0, -44), top + Vector2(17, -14), top + Vector2(36, -32), top + Vector2(34, 6)])
	_part(c, crown, SN_GOLD, 1627, 7.0, 10.0)
	c.draw_circle(top + Vector2(0, -6), 6.0, Color("#ff5d7a"))


# --- Nessie: long-necked lake monster, horn nubs, four flippers, back spikes -----------------

const NS_GREEN := Color("#82d6b2")
const NS_DARK := Color("#55b893")
const NS_BELLY := Color("#e4f6c6")
const NS_SPIKE := Color("#bba0f2")
const NS_HORN := Color("#fff0b8")
const NS_FIN := Color("#5fc0a4")

## A plump round body with the long neck rising tall out of the front of it; the head goes
## on the end. The back is kept high all the way along so the spikes and flippers PetBuilder
## stands on it never float.
static func _nessie_shape() -> PackedVector2Array:
	var belly := _egg(Vector2(210, 310), Vector2(156, 124), 0.2, 1701, 26, 0.03)
	var neck := _tube(_bez(Vector2(300, 292), Vector2(350, 250), Vector2(372, 190), Vector2(392, 110), 10), 42.0, 32.0)
	return _merge(belly, neck)


static func _nessie_body(c: CanvasItem) -> void:
	var body := _nessie_shape()
	_fill(c, body, NS_GREEN, 1702)
	_clip_fill(c, Crayon.blob(Vector2(236, 412), Vector2(180, 56), 1703, 18, 0.05), body, NS_BELLY, 1704)
	_clip_fill(c, _tube(_bez(Vector2(330, 330), Vector2(392, 268), Vector2(414, 200), Vector2(432, 120), 10), 22.0, 16.0),
		body, NS_BELLY, 1705)
	_spots(c, body, [[Vector2(110, 290), 13.0], [Vector2(166, 240), 18.0], [Vector2(234, 230), 13.0],
		[Vector2(140, 340), 10.0], [Vector2(206, 296), 9.0], [Vector2(342, 200), 8.0], [Vector2(360, 150), 7.0]],
		NS_DARK, 1706)
	Crayon.marker_line(c, body, INK, W_BODY, 1714)


static func _nessie_head(c: CanvasItem) -> void:
	var neck := _tube(_seg(Vector2(202, 414), Vector2(246, 362), 6), 38.0, 40.0)
	var skull := Crayon.blob(Vector2(282, 304), Vector2(98, 86), 1721, 20, 0.04)
	var snout := Crayon.blob(Vector2(364, 346), Vector2(86, 58), 1722, 16, 0.04)
	var head := _merge_all([skull, neck, snout])
	_fill(c, head, NS_GREEN, 1723)
	_spots(c, head, [[Vector2(246, 244), 13.0], [Vector2(210, 296), 9.0], [Vector2(292, 228), 7.0]], NS_DARK, 1724)
	_clip_fill(c, Crayon.blob(Vector2(322, 370), Vector2(22, 13), 1728, 12, 0.08), head, BLUSH, 1729, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1730)
	c.draw_circle(Vector2(428, 326), 5.0, INK)
	c.draw_circle(Vector2(412, 320), 5.0, INK)


static func _nessie_eye(c: CanvasItem) -> void:
	_eye(c, 1731, Vector2(64, 70), Color("#ffb84d"), 40.0, Vector2(22, 28), Vector2(8, 4))


static func _nessie_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1741, Vector2(80, 62), 0.35, 0, true)


## A little round knob on a short stalk.
static func _nessie_horn(c: CanvasItem) -> void:
	var stalk := _tube(_seg(Vector2(256, 446), Vector2(262, 386), 4), 17.0, 15.0)
	var ball := Crayon.blob(Vector2(264, 372), Vector2(25, 24), 1751, 12, 0.05)
	_part(c, _merge(stalk, ball), NS_HORN, 1752, W_EAR, 14.0)


## A broad leaf of a flipper on a short stem, swept back, with a darker rim.
static func _nessie_fin(c: CanvasItem) -> void:
	var root := Vector2(256, 450)
	var tip := Vector2(190, 352)
	var d := (tip - root).normalized()
	var mid := root.lerp(tip, 0.56)
	var leaf := PackedVector2Array()
	var n := 24
	for i in n:
		var a := TAU * i / n
		var k := 1.0 + Crayon.noise(1760, i) * 0.03
		leaf.append(mid + (d * cos(a) * 58.0 + d.orthogonal() * sin(a) * 38.0) * k)
	var fin := _merge(_tube(_seg(root, mid, 4), 18.0, 22.0), leaf)
	_fill(c, fin, NS_FIN, 1761)
	_clip_fill(c, Crayon.blob(tip + d * -6.0, Vector2(40, 36), 1762, 12, 0.06), fin, NS_DARK, 1763, 12.0)
	_ink(c, _seg(root.lerp(tip, 0.12), root.lerp(tip, 0.85), 5), 5.0, 1764)
	Crayon.marker_line(c, fin, INK, W_FIN, 1765)


static func _nessie_spike(c: CanvasItem) -> void:
	_part(c, _spike_shape(30.0, 104.0, -10.0), NS_SPIKE, 1771, W_ANT)


static func _nessie_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(452, 258), Vector2(380, 268), Vector2(280, 262), Vector2(206, 222), 16)
	var tail := _tube(path, 46.0, 10.0)
	_fill(c, tail, NS_GREEN, 1781)
	for k in 3:
		_clip_fill(c, Crayon.blob(path[4 + k * 4] + Vector2(0, -10), Vector2(14 - k * 2, 11 - k * 2), 1782 + k, 10, 0.1),
			tail, NS_DARK, 1786 + k, 10.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 1790)


# --- Axel: pink axolotl, frilly gills, four little legs, tail fin ---------------------------

const AX_PINK := Color("#ffb6c9")
const AX_DARK := Color("#f48fb1")
const AX_BELLY := Color("#ffe4ec")
const AX_GILL := Color("#ff6fa6")
const AX_FIN := Color("#ffd6e2")

static func _axel_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 272), Vector2(206, 96), 0.35, 1801, 28, 0.03)
	_fill(c, body, AX_PINK, 1802)
	_clip_fill(c, Crayon.blob(Vector2(280, 350), Vector2(200, 46), 1803, 18, 0.05), body, AX_BELLY, 1804)
	_spots(c, body, [[Vector2(130, 260), 8.0], [Vector2(180, 222), 10.0], [Vector2(250, 214), 7.0],
		[Vector2(310, 232), 9.0], [Vector2(214, 272), 6.0], [Vector2(370, 216), 6.0]], AX_DARK, 1805)
	Crayon.marker_line(c, body, INK, W_BODY, 1812)


static func _axel_head(c: CanvasItem) -> void:
	var neck := _tube(_seg(Vector2(202, 414), Vector2(246, 370), 6), 44.0, 44.0)
	var skull := _squircle(Vector2(296, 312), Vector2(136, 108), 2.6, 1811, 40, 0.025)
	var cheek := Crayon.blob(Vector2(370, 368), Vector2(64, 50), 1812, 16, 0.03)
	var head := _merge_all([skull, neck, cheek])
	_fill(c, head, AX_PINK, 1813)
	_spots(c, head, [[Vector2(214, 256), 7.0], [Vector2(246, 230), 6.0], [Vector2(200, 300), 5.0]], AX_DARK, 1814)
	var box := _box(head, W_BODY)
	_clip_fill(c, Crayon.blob(_at(box, Vector2(0.66, 0.62)), Vector2(22, 13), 1818, 12, 0.08), head,
		BLUSH, 1819, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1820)


static func _axel_eye(c: CanvasItem) -> void:
	var e := Crayon.blob(O, Vector2(58, 62), 1861, 20, 0.04)
	c.draw_colored_polygon(e, Color("#2b2633"))
	c.draw_circle(O + Vector2(-16, -20), 17.0, Color.WHITE)
	c.draw_circle(O + Vector2(20, 22), 8.0, Color(1, 1, 1, 0.9))
	Crayon.marker_line(c, e, INK, W_EYE, 1862)


static func _axel_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1871, Vector2(88, 50), 0.22)


## Three feathery gill stalks fanning up and back, frilly bumps all along each.
static func _axel_hair(c: CanvasItem) -> void:
	var root := Vector2(300, 406)
	var tips := [Vector2(160, 352), Vector2(178, 290), Vector2(230, 248)]
	var shapes := [Crayon.blob(root + Vector2(-8, -6), Vector2(30, 26), 1821, 14, 0.04)]
	var paths := []
	for i in tips.size():
		var tip: Vector2 = tips[i]
		var path := _bez(root, root.lerp(tip, 0.35) + Vector2(0, -16), tip + Vector2(20, 10), tip, 10)
		paths.append(path)
		shapes.append(_tube(path, 16.0, 12.0))
		for k in range(4, 10, 2):
			var p := path[k]
			var d := (path[k + 1] - path[k - 1]).normalized()
			var nrm := d.orthogonal()
			for s in [-1.0, 1.0]:
				shapes.append(Crayon.blob(p + nrm * s * 13.0, Vector2(12, 12), 1822 + k + i * 10, 10, 0.05))
	var gill := _merge_all(shapes)
	_fill(c, gill, AX_GILL, 1880)
	for i in paths.size():
		var path: PackedVector2Array = paths[i]
		_clip_ink(c, path.slice(2, path.size() - 1), gill, 5.0, 1882 + i, AX_FIN)
	Crayon.marker_line(c, gill, INK, W_FIN, 1886)


static func _axel_leg(c: CanvasItem) -> void:
	var leg := _tube(_bez(Vector2(256, 66), Vector2(254, 110), Vector2(260, 140), Vector2(266, 168), 6), 24.0, 21.0, 0.4)
	var parts := [leg]
	for tip in [Vector2(308, 186), Vector2(302, 206), Vector2(280, 216), Vector2(248, 206)]:
		parts.append(_tube(_seg(Vector2(268, 176), tip, 3), 9.0, 10.0))
	var shape := _merge_all(parts)
	_part(c, shape, AX_PINK, 1831)
	_spots(c, shape, [[Vector2(250, 112), 6.0]], AX_DARK, 1833)


## A long tapering tail inside a frilly pale fin.
static func _axel_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(452, 262), Vector2(370, 268), Vector2(240, 262), Vector2(110, 218), 18)
	var fin := _tube(path.slice(3), 66.0, 40.0)
	_fill(c, fin, AX_FIN, 1841)
	for k in 7:
		var i := 5 + k * 2
		var p := path[i]
		var d := (path[i + 1] - path[i - 1]).normalized()
		var w := lerpf(66.0, 40.0, (i - 3) / float(path.size() - 4))
		for s in [-1.0, 1.0]:
			_clip_ink(c, _seg(p + d.orthogonal() * s * 20.0, p + d.orthogonal() * s * (w - 6.0), 2), fin,
				4.0, 1846 + k * 2 + int(s), AX_DARK)
	Crayon.marker_line(c, fin, INK, W_BODY, 1842)
	var tail := _tube(path, 40.0, 10.0)
	_part(c, tail, AX_PINK, 1843)
	_spots(c, tail, [[path[6] + Vector2(0, -8), 7.0], [path[10] + Vector2(0, -4), 6.0]], AX_DARK, 1845)


## A low wavy frill along its back.
static func _axel_fin(c: CanvasItem) -> void:
	var pts := PackedVector2Array([Vector2(306, 454)])
	var n := 18
	for i in n + 1:
		var t := i / float(n)
		var h := sin(pow(t, 0.6) * PI) * 72.0 * (1.0 - t * 0.4) + (8.0 if i % 2 == 0 else 0.0)
		pts.append(Vector2(lerpf(300.0, 96.0, t), 446.0 - h))
	pts.append(Vector2(92, 454))
	_part(c, pts, AX_FIN, 1851, W_FIN)
