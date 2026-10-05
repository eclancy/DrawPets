class_name ArtAdoptD
extends RefCounted
## Dinosaurs, monsters and magic - pets a kid can meet and adopt in the shop's Adopt tab. Drawn as if OTHER KIDS
## drew them, in marker with black outlines, part by part, exactly the way the game asks a kid
## to draw, and assembled by the same PetBuilder.add_parts a kid's own pet goes through
## (Roster.assemble). Baked to res://art/adopt_d/ by tools/bake_art.gd; the assembled view is
## .shots/art_adopt_d_assembled.png.
##
## Style reference: scripts/art_rivals.gd - read it first. Marker fills on an opaque base, black
## (#1f1d24) marker outlines (creatures own black), a kid's wobble, simple patches and spots.
##
## Each part is drawn on the sheet a kid would get for it, starting from the same red dot, at
## the same zoom - PartTypes.TYPES[type]["dot"] and ["zoom"] (scripts/part_types.gd). The dot is
## the asset's pivot. Ids are "<creature>_<part key>"; a key like "claw_on_arm" is a claw drawn
## for an arm (drawn exactly like any other claw). The body has no dot (pivot "center").

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
const W_HAND := 13.0
const W_FOOT := 13.0
const W_CLAW := 15.0

## Who they are and what they are made of. Names and parts are fixed (game code uses them); how
## each part looks is up to its drawing.
const ROSTER := {
	"rumble": {"name": "Rumble", "look": "friendly green T-rex, tiny arms with claws, big legs with feet, back spikes",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "arm": 2, "claw_on_arm": 2, "leg": 2, "foot": 1, "tail": 1, "spike": 4}},
	"trixie": {"name": "Trixie", "look": "purple triceratops, frill (hair), three horns, sturdy feet",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "horn": 3, "hair": 1, "leg": 4, "foot": 1, "tail": 1}},
	"marshmallow": {"name": "Marshmallow", "look": "fluffy white yeti, little horns, arms with big hands, legs with feet",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "horn": 2, "arm": 2, "hand": 1, "leg": 2, "foot": 1}},
	"sparkle": {"name": "Sparkle", "look": "pastel unicorn pony, horn, rainbow mane and tail",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "ear": 2, "horn": 1, "hair": 1, "leg": 4, "tail": 1}},
	"bolt": {"name": "Bolt", "look": "a boxy robot pup a kid drew - bolts, an antenna, square ears",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "antenna": 1, "ear": 2, "leg": 4, "tail": 1}},
	"cactus_jack": {"name": "Cactus Jack", "look": "a cheerful cactus with cactus arms, spikes and a flower on top, no head",
		"parts": {"eye": 2, "mouth": 1, "arm": 2, "spike": 6, "hair": 1, "leg": 2, "foot": 1}},
	"gummy": {"name": "Gummy", "look": "a red gummy bear, stubby arms and legs",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "arm": 2, "leg": 2}},
	"ember": {"name": "Ember", "look": "orange fire salamander with flame-shaped back spikes",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "spike": 5, "leg": 4, "tail": 1}},
	"crystal": {"name": "Crystal", "look": "chunky purple rock golem with crystal horns, arms with hands",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "horn": 3, "arm": 2, "hand": 1, "leg": 2}},
	"mo": {"name": "Mo", "look": "a classic friendly monster: three eyes, huge mouth, horns, fuzzy tuft, no separate head",
		"parts": {"eye": 3, "mouth": 1, "horn": 2, "hair": 1, "arm": 2, "hand": 1, "leg": 2, "foot": 1}},
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
		"rumble_body": _rumble_body(c)
		"rumble_head": _rumble_head(c)
		"rumble_eye": _rumble_eye(c)
		"rumble_mouth": _rumble_mouth(c)
		"rumble_arm": _rumble_arm(c)
		"rumble_claw_on_arm": _rumble_claw(c)
		"rumble_leg": _rumble_leg(c)
		"rumble_foot": _rumble_foot(c)
		"rumble_tail": _rumble_tail(c)
		"rumble_spike": _rumble_spike(c)
		"trixie_body": _trixie_body(c)
		"trixie_head": _trixie_head(c)
		"trixie_eye": _trixie_eye(c)
		"trixie_mouth": _trixie_mouth(c)
		"trixie_horn": _trixie_horn(c)
		"trixie_hair": _trixie_hair(c)
		"trixie_leg": _trixie_leg(c)
		"trixie_foot": _trixie_foot(c)
		"trixie_tail": _trixie_tail(c)
		"marshmallow_body": _marsh_body(c)
		"marshmallow_head": _marsh_head(c)
		"marshmallow_eye": _marsh_eye(c)
		"marshmallow_mouth": _marsh_mouth(c)
		"marshmallow_horn": _marsh_horn(c)
		"marshmallow_arm": _marsh_arm(c)
		"marshmallow_hand": _marsh_hand(c)
		"marshmallow_leg": _marsh_leg(c)
		"marshmallow_foot": _marsh_foot(c)
		"sparkle_body": _sparkle_body(c)
		"sparkle_head": _sparkle_head(c)
		"sparkle_eye": _sparkle_eye(c)
		"sparkle_mouth": _sparkle_mouth(c)
		"sparkle_ear": _sparkle_ear(c)
		"sparkle_horn": _sparkle_horn(c)
		"sparkle_hair": _sparkle_hair(c)
		"sparkle_leg": _sparkle_leg(c)
		"sparkle_tail": _sparkle_tail(c)
		"bolt_body": _bolt_body(c)
		"bolt_head": _bolt_head(c)
		"bolt_eye": _bolt_eye(c)
		"bolt_mouth": _bolt_mouth(c)
		"bolt_antenna": _bolt_antenna(c)
		"bolt_ear": _bolt_ear(c)
		"bolt_leg": _bolt_leg(c)
		"bolt_tail": _bolt_tail(c)
		"cactus_jack_body": _jack_body(c)
		"cactus_jack_eye": _jack_eye(c)
		"cactus_jack_mouth": _jack_mouth(c)
		"cactus_jack_arm": _jack_arm(c)
		"cactus_jack_spike": _jack_spike(c)
		"cactus_jack_hair": _jack_hair(c)
		"cactus_jack_leg": _jack_leg(c)
		"cactus_jack_foot": _jack_foot(c)
		"gummy_body": _gummy_body(c)
		"gummy_head": _gummy_head(c)
		"gummy_eye": _gummy_eye(c)
		"gummy_mouth": _gummy_mouth(c)
		"gummy_ear": _gummy_ear(c)
		"gummy_arm": _gummy_arm(c)
		"gummy_leg": _gummy_leg(c)
		"ember_body": _ember_body(c)
		"ember_head": _ember_head(c)
		"ember_eye": _ember_eye(c)
		"ember_mouth": _ember_mouth(c)
		"ember_spike": _ember_spike(c)
		"ember_leg": _ember_leg(c)
		"ember_tail": _ember_tail(c)
		"crystal_body": _crystal_body(c)
		"crystal_head": _crystal_head(c)
		"crystal_eye": _crystal_eye(c)
		"crystal_mouth": _crystal_mouth(c)
		"crystal_horn": _crystal_horn(c)
		"crystal_arm": _crystal_arm(c)
		"crystal_hand": _crystal_hand(c)
		"crystal_leg": _crystal_leg(c)
		"mo_body": _mo_body(c)
		"mo_eye": _mo_eye(c)
		"mo_mouth": _mo_mouth(c)
		"mo_horn": _mo_horn(c)
		"mo_hair": _mo_hair(c)
		"mo_arm": _mo_arm(c)
		"mo_hand": _mo_hand(c)
		"mo_leg": _mo_leg(c)
		"mo_foot": _mo_foot(c)


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


## Round spots coloured inside a shape: each entry is [centre, radius].
static func _spots(c: CanvasItem, inside: PackedVector2Array, spots: Array, color: Color,
		seed: int, outline := 0.0) -> void:
	for i in spots.size():
		var at: Vector2 = spots[i][0]
		var r: float = spots[i][1]
		_clip_fill(c, Crayon.blob(at, Vector2(r * 1.15, r), seed + i, 10, 0.15), inside, color,
			seed + 20 + i, 10.0, outline)


## An open black marker stroke.
static func _ink(c: CanvasItem, pts: PackedVector2Array, width: float, seed: int) -> void:
	Crayon.marker_line(c, pts, INK, width, seed, false)


## An open stroke, only where it lies inside a shape.
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


## Two open paths end to end as one closed outline (the second's first point is dropped).
static func _join(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	var out := a.duplicate()
	for i in range(1, b.size()):
		out.append(b[i])
	return out


## A smooth closed curve through some points (Catmull-Rom), for flames, boots and plates.
static func _smooth(pts: PackedVector2Array, per := 6) -> PackedVector2Array:
	var n := pts.size()
	var out := PackedVector2Array()
	for i in n:
		var p0: Vector2 = pts[(i - 1 + n) % n]
		var p1: Vector2 = pts[i]
		var p2: Vector2 = pts[(i + 1) % n]
		var p3: Vector2 = pts[(i + 2) % n]
		for s in per:
			var t := s / float(per)
			var t2 := t * t
			var t3 := t2 * t
			out.append(0.5 * ((2.0 * p1) + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2
				+ (3.0 * p1 - p0 - 3.0 * p2 + p3) * t3))
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


static func _signed_area(p: PackedVector2Array) -> float:
	var s := 0.0
	for i in p.size():
		var a := p[i]
		var b := p[(i + 1) % p.size()]
		s += a.x * b.y - b.x * a.y
	return s * 0.5


## Two overlapping shapes as one outline (the outer boundary of their union).
static func _merge(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	var best := a
	var best_area := -1.0
	for p in Geometry2D.merge_polygons(a, b):
		var ar := absf(_signed_area(p))
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


## A tilted lumpy ellipse - petals, leaves.
static func _oval(center: Vector2, r: Vector2, angle: float, seed: int, n := 16,
		lumpy := 0.04) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		var k := 1.0 + Crayon.noise(seed, i) * lumpy
		pts.append(center + Vector2(cos(a) * r.x, sin(a) * r.y).rotated(angle) * k)
	return pts


## Points evenly spaced round a closed outline.
static func _resample(poly: PackedVector2Array, step: float) -> PackedVector2Array:
	var n := poly.size()
	var per := 0.0
	for i in n:
		per += poly[i].distance_to(poly[(i + 1) % n])
	var count := maxi(8, int(per / step))
	if count % 2 == 1:
		count += 1
	var gap := per / count
	var out := PackedVector2Array()
	var travelled := 0.0
	var next := 0.0
	for i in n:
		var a := poly[i]
		var b := poly[(i + 1) % n]
		var seg_len := a.distance_to(b)
		while next < travelled + seg_len and out.size() < count:
			out.append(a.lerp(b, (next - travelled) / seg_len))
			next += gap
		travelled += seg_len
	return out


## Fur: every other point round the outline pushed outwards into a little tuft.
static func _fuzz(poly: PackedVector2Array, step: float, depth: float, seed: int) -> PackedVector2Array:
	var pts := _resample(poly, step)
	var n := pts.size()
	var sgn := 1.0 if _signed_area(pts) > 0.0 else -1.0
	var out := PackedVector2Array()
	for i in n:
		var p := pts[i]
		if i % 2 == 1:
			var d := (pts[(i + 1) % n] - pts[(i - 1 + n) % n]).normalized()
			p += d.orthogonal() * sgn * depth * (0.75 + 0.25 * Crayon.noise(seed, i))
		out.append(p)
	return out


## A shape grown or shrunk about a point.
static func _scaled(poly: PackedVector2Array, k: float, about: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(about + (p - about) * k)
	return out


## A shape leaned over: points moved sideways by how far above `y0` they are.
static func _skew(poly: PackedVector2Array, k: float, y0: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(Vector2(p.x + (y0 - p.y) * k, p.y))
	return out


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


## A white shine streak round part of an ellipse - the glint on something glossy.
static func _shine(c: CanvasItem, center: Vector2, r: Vector2, a0: float, a1: float,
		width: float) -> void:
	var pts := PackedVector2Array()
	for i in 9:
		var a := lerpf(a0, a1, i / 8.0)
		pts.append(center + Vector2(cos(a) * r.x, sin(a) * r.y))
	c.draw_polyline(pts, Color(1, 1, 1, 0.8), width, true)
	for p in [pts[0], pts[8]]:
		c.draw_circle(p, width * 0.5, Color(1, 1, 1, 0.8))


## A flame, its base at `base`, about 200 * s tall, tilted by `angle`.
static func _flame(base: Vector2, s: float, angle := 0.0) -> PackedVector2Array:
	var ctrl := [Vector2(-54, 0), Vector2(-68, -48), Vector2(-58, -98), Vector2(-40, -136),
		Vector2(-28, -100), Vector2(-14, -150), Vector2(4, -200), Vector2(16, -150), Vector2(30, -112),
		Vector2(48, -152), Vector2(66, -98), Vector2(68, -46), Vector2(50, 0), Vector2(0, 12)]
	var pts := PackedVector2Array()
	for p in ctrl:
		var q: Vector2 = p * s
		pts.append(base + q.rotated(angle))
	return _smooth(pts, 5)


## A crystal shard standing on `base`: h tall, 2w wide, its point leaning by `lean`.
static func _shard(base: Vector2, h: float, w: float, lean: float) -> PackedVector2Array:
	return PackedVector2Array([base + Vector2(-w, 0), base + Vector2(-w * 1.05 + lean * 0.5, -h * 0.62),
		base + Vector2(lean, -h), base + Vector2(w * 1.05 + lean * 0.5, -h * 0.62), base + Vector2(w, 0)])


## A little cut gem: a hexagon with one lighter face.
static func _gem(c: CanvasItem, at: Vector2, s: float, color: Color, seed: int) -> void:
	var g := PackedVector2Array([at + Vector2(0, -s), at + Vector2(s * 0.75, -s * 0.35),
		at + Vector2(s * 0.6, s * 0.6), at + Vector2(0, s), at + Vector2(-s * 0.6, s * 0.6),
		at + Vector2(-s * 0.75, -s * 0.35)])
	_fill(c, g, color, seed, 10.0)
	var face := PackedVector2Array([at + Vector2(-s, -s), at + Vector2(0, -s), at + Vector2(0, s),
		at + Vector2(-s, s)])
	_clip_fill(c, face, g, color.lightened(0.45), seed + 1, 8.0)
	Crayon.marker_line(c, g, INK, maxf(4.0, s * 0.2), seed + 2)


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


## Eyelashes flicked up off the top right of an eye of radius `r`.
static func _lashes(c: CanvasItem, seed: int, r: Vector2, count := 3) -> void:
	for i in count:
		var a := -PI * 0.5 + (i - 0.1) * 0.42
		var root := O + Vector2(cos(a) * r.x, sin(a) * r.y)
		var tip := root + Vector2(cos(a), sin(a)) * 36.0 + Vector2(6, -4)
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


# --- Rumble: friendly green T-rex -------------------------------------------------------------

const RU_GREEN := Color("#9bd86a")
const RU_DARK := Color("#72bb58")
const RU_BELLY := Color("#eef6b0")
const RU_PLATE := Color("#ffb54d")
const RU_NAIL := Color("#fff4dc")

static func _rumble_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(262, 262), Vector2(196, 120), 0.5, 1001, 28, 0.03)
	_fill(c, body, RU_GREEN, 1002)
	_clip_fill(c, Crayon.blob(Vector2(336, 344), Vector2(150, 62), 1003, 16, 0.05), body, RU_BELLY, 1004)
	_spots(c, body, [[Vector2(150, 236), 17.0], [Vector2(214, 196), 22.0], [Vector2(296, 186), 17.0],
		[Vector2(250, 250), 13.0], [Vector2(110, 262), 11.0], [Vector2(372, 212), 14.0],
		[Vector2(186, 286), 12.0]], RU_DARK, 1005)
	Crayon.marker_line(c, body, INK, W_BODY, 1030)
	for i in 3:
		var x := 304.0 + i * 36.0
		_ink_in(c, _bez(Vector2(x, 312), Vector2(x + 6, 324), Vector2(x + 6, 338), Vector2(x, 352), 6),
			body, 5.0, 1031 + i)


static func _rumble_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(292, 298), Vector2(96, 82), 1041, 20, 0.04)
	var snout := Crayon.blob(Vector2(386, 318), Vector2(92, 54), 1042, 18, 0.04)
	var jaw := Crayon.blob(Vector2(378, 370), Vector2(84, 40), 1043, 16, 0.04)
	var neck := _tube(_seg(Vector2(202, 414), Vector2(252, 352), 6), 42.0, 42.0)
	var head := _merge_all([skull, neck, snout, jaw])
	_fill(c, head, RU_GREEN, 1044)
	_spots(c, head, [[Vector2(262, 250), 14.0], [Vector2(306, 238), 11.0], [Vector2(238, 300), 11.0],
		[Vector2(216, 368), 10.0]], RU_DARK, 1045)
	Crayon.marker_line(c, head, INK, W_BODY, 1070)
	c.draw_circle(Vector2(454, 296), 6.0, INK)


static func _rumble_eye(c: CanvasItem) -> void:
	_eye(c, 1081, Vector2(64, 68), Color("#ffcf4a"), 42.0, Vector2(22, 26), Vector2(8, 3))


static func _rumble_mouth(c: CanvasItem) -> void:
	var m := _mouth_shape(Vector2(98, 72), 0.4, 1091)
	_fill(c, m, MOUTH_IN, 1092, 18.0)
	var b := Crayon.bounds(m)
	var tg := Crayon.blob(Vector2(O.x + 12, b.end.y - 24), Vector2(52, 34), 1093, 16, 0.05)
	_clip_fill(c, tg, m, TONGUE, 1094, 16.0)
	for k in 4:
		var x := O.x + (k - 1.5) * 44.0
		var tooth := PackedVector2Array([Vector2(x - 17, b.position.y - 12),
			Vector2(x + 17, b.position.y - 12), Vector2(x, b.position.y + 32)])
		_clip_fill(c, tooth, m, PAPER, 1095 + k, 12.0, 6.0)
	for k in 2:
		var x := O.x + (k - 0.5) * 84.0
		var tooth := PackedVector2Array([Vector2(x - 15, b.end.y + 12), Vector2(x, b.end.y - 30),
			Vector2(x + 15, b.end.y + 12)])
		_clip_fill(c, tooth, m, PAPER, 1100 + k, 12.0, 6.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 1103)


## Really tiny, ending in a little paw the two claws hang from.
static func _rumble_arm(c: CanvasItem) -> void:
	var arm := _tube(_seg(Vector2(256, 66), Vector2(262, 110), 4), 19.0, 18.0)
	var paw := Crayon.blob(Vector2(264, 122), Vector2(27, 19), 1111, 14, 0.04)
	_part(c, _merge(arm, paw), RU_GREEN, 1112, W_ARM)


static func _rumble_claw(c: CanvasItem) -> void:
	var claw := _join(_bez(Vector2(232, 104), Vector2(230, 160), Vector2(248, 196), Vector2(278, 216), 8),
		_bez(Vector2(278, 216), Vector2(284, 180), Vector2(286, 140), Vector2(282, 104), 8))
	_part(c, claw, RU_NAIL, 1121, W_CLAW, 14.0)


static func _rumble_leg(c: CanvasItem) -> void:
	var thigh := Crayon.blob(Vector2(250, 126), Vector2(64, 70), 1131, 18, 0.04)
	var shin := _tube(_seg(Vector2(250, 150), Vector2(258, 248), 6), 38.0, 32.0)
	var leg := _merge(thigh, shin)
	_fill(c, leg, RU_GREEN, 1132)
	_spots(c, leg, [[Vector2(234, 112), 18.0], [Vector2(274, 150), 12.0]], RU_DARK, 1133)
	Crayon.marker_line(c, leg, INK, W_BODY, 1160)


static func _rumble_foot(c: CanvasItem) -> void:
	var ankle := Crayon.rounded_rect(Rect2(124, 116, 132, 84), 26.0)
	var pad := Crayon.blob(Vector2(254, 208), Vector2(124, 46), 1171, 18, 0.03)
	var toes := []
	for t in [Vector2(368, 184), Vector2(384, 214), Vector2(362, 242)]:
		toes.append(Crayon.blob(t, Vector2(30, 24), 1172, 12, 0.04))
	var foot := _merge_all([ankle, pad] + toes)
	_fill(c, foot, RU_GREEN, 1173)
	_spots(c, foot, [[Vector2(206, 166), 15.0], [Vector2(290, 196), 11.0]], RU_DARK, 1174)
	Crayon.marker_line(c, foot, INK, W_FOOT, 1200)
	var tips := [Vector2(398, 182), Vector2(414, 214), Vector2(390, 246)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		var nail := PackedVector2Array([tip + Vector2(-12, -14), tip + Vector2(26, 0), tip + Vector2(-12, 14)])
		_part(c, nail, RU_NAIL, 1201 + i * 2, 8.0, 10.0)


static func _rumble_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(452, 258), Vector2(376, 266), Vector2(270, 262), Vector2(128, 212), 20)
	var tail := _tube(path, 60.0, 10.0)
	_fill(c, tail, RU_GREEN, 1211)
	_spots(c, tail, [[Vector2(346, 242), 16.0], [Vector2(268, 238), 14.0], [Vector2(200, 226), 11.0],
		[Vector2(310, 282), 10.0]], RU_DARK, 1212)
	Crayon.marker_line(c, tail, INK, W_BODY, 1240)


static func _rumble_spike(c: CanvasItem) -> void:
	var plate := _smooth(PackedVector2Array([Vector2(198, 462), Vector2(214, 410), Vector2(238, 362),
		Vector2(256, 338), Vector2(274, 362), Vector2(298, 410), Vector2(314, 462), Vector2(256, 472)]), 5)
	_fill(c, plate, RU_PLATE, 1251, 16.0)
	Crayon.marker_line(c, plate, INK, W_ANT, 1252)


# --- Trixie: purple triceratops ---------------------------------------------------------------

const TX_PURPLE := Color("#b896f0")
const TX_DARK := Color("#9576d8")
const TX_BELLY := Color("#e6dbff")
const TX_FRILL := Color("#ff9fc6")
const TX_FRILL2 := Color("#ffd3e5")
const TX_DOT := Color("#ffe066")
const TX_HORN := Color("#fff0cf")

static func _trixie_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 264), Vector2(204, 126), 0.3, 1301, 28, 0.03)
	_fill(c, body, TX_PURPLE, 1302)
	_clip_fill(c, Crayon.blob(Vector2(290, 362), Vector2(206, 56), 1303, 16, 0.05), body, TX_BELLY, 1304)
	_spots(c, body, [[Vector2(150, 220), 24.0], [Vector2(236, 192), 28.0], [Vector2(330, 204), 22.0],
		[Vector2(200, 270), 15.0], [Vector2(290, 260), 17.0], [Vector2(392, 250), 13.0],
		[Vector2(96, 270), 12.0]], TX_DARK, 1305)
	Crayon.marker_line(c, body, INK, W_BODY, 1330)


static func _trixie_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(298, 350), Vector2(100, 74), 1341, 20, 0.04)
	var snout := Crayon.blob(Vector2(396, 374), Vector2(74, 50), 1342, 16, 0.04)
	var neck := _tube(_seg(Vector2(200, 414), Vector2(260, 372), 6), 42.0, 42.0)
	var head := _merge_all([skull, neck, snout])
	_fill(c, head, TX_PURPLE, 1343)
	_clip_fill(c, Crayon.blob(Vector2(466, 384), Vector2(30, 46), 1344, 12, 0.05), head, TX_DARK, 1345)
	_clip_fill(c, Crayon.blob(Vector2(338, 396), Vector2(24, 15), 1346, 10, 0.08), head, TX_FRILL, 1347, 10.0)
	_spots(c, head, [[Vector2(262, 318), 13.0], [Vector2(300, 304), 10.0], [Vector2(232, 360), 10.0]],
		TX_DARK, 1348)
	Crayon.marker_line(c, head, INK, W_BODY, 1370)
	c.draw_circle(Vector2(444, 356), 6.0, INK)


static func _trixie_eye(c: CanvasItem) -> void:
	_eye(c, 1381, Vector2(62, 68), Color("#7fcf6a"), 40.0, Vector2(22, 26), Vector2(8, 4))
	_lashes(c, 1388, Vector2(62, 68))


static func _trixie_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1391, Vector2(84, 64), 0.4)


static func _trixie_horn(c: CanvasItem) -> void:
	var horn := _join(_bez(Vector2(214, 462), Vector2(220, 392), Vector2(250, 338), Vector2(300, 300), 10),
		_bez(Vector2(300, 300), Vector2(290, 346), Vector2(294, 404), Vector2(298, 462), 10))
	_fill(c, horn, TX_HORN, 1401, 16.0)
	for i in 2:
		var y := 424.0 - i * 46.0
		_ink_in(c, _bez(Vector2(200, y - 4), Vector2(240, y + 8), Vector2(280, y + 6), Vector2(320, y - 8), 6),
			horn, 5.0, 1402 + i)
	Crayon.marker_line(c, horn, INK, W_EAR, 1405)


## The frill: a scalloped fan swept back over the neck, drawn behind the head.
static func _trixie_hair(c: CanvasItem) -> void:
	var piv := Vector2(312, 428)
	var fan := PackedVector2Array()
	var n := 48
	for i in n + 1:
		var t := i / float(n)
		var a := lerpf(PI * 0.9, PI * 1.33, t)
		var rr := 1.0 + absf(sin(t * PI * 6.0)) * 0.07 + Crayon.noise(1411, i) * 0.01
		fan.append(piv + Vector2(cos(a) * 244.0, sin(a) * 226.0) * rr)
	fan.append(piv + Vector2(36, -16))
	fan.append(piv + Vector2(30, 26))
	_fill(c, fan, TX_FRILL, 1412)
	var inner := PackedVector2Array()
	for i in 25:
		var a := lerpf(PI * 0.85, PI * 1.4, i / 24.0)
		inner.append(piv + Vector2(cos(a) * 154.0, sin(a) * 142.0))
	inner.append(piv + Vector2(60, 20))
	_clip_fill(c, inner, fan, TX_FRILL2, 1413, 16.0)
	for i in 6:
		var a := lerpf(PI * 0.95, PI * 1.28, i / 5.0)
		var at := piv + Vector2(cos(a) * 204.0, sin(a) * 188.0)
		var dot := Crayon.blob(at, Vector2(16, 16), 1414 + i, 10, 0.08)
		_part(c, dot, TX_DOT, 1420 + i * 2, 5.0, 10.0)
	Crayon.marker_line(c, fan, INK, W_FIN, 1435)


static func _trixie_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 64), Vector2(256, 196), 6), 46.0, 44.0)
	_fill(c, leg, TX_PURPLE, 1441)
	_spots(c, leg, [[Vector2(240, 114), 16.0]], TX_DARK, 1442)
	Crayon.marker_line(c, leg, INK, W_BODY, 1450)


static func _trixie_foot(c: CanvasItem) -> void:
	var ankle := Crayon.rounded_rect(Rect2(102, 116, 176, 84), 28.0)
	var pad := Crayon.blob(Vector2(230, 202), Vector2(126, 54), 1461, 18, 0.03)
	var foot := _merge(ankle, pad)
	_part(c, foot, TX_PURPLE, 1462, W_FOOT)
	for a in [0.12, 0.55, 1.0]:
		var at := Vector2(230, 202) + Vector2(cos(a) * 122.0, sin(a) * 50.0)
		var nail := Crayon.blob(at + Vector2(-6, -6), Vector2(22, 17), 1464, 12, 0.05)
		_part(c, nail, Color("#fff7e8"), 1465, 7.0, 10.0)


static func _trixie_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(452, 262), Vector2(370, 272), Vector2(280, 270), Vector2(186, 242), 16)
	var tail := _tube(path, 56.0, 12.0)
	_fill(c, tail, TX_PURPLE, 1471)
	_spots(c, tail, [[Vector2(356, 248), 16.0], [Vector2(286, 250), 13.0], [Vector2(230, 242), 10.0]],
		TX_DARK, 1472)
	Crayon.marker_line(c, tail, INK, W_BODY, 1490)


# --- Marshmallow: fluffy white yeti -----------------------------------------------------------

const MM_WHITE := Color("#f8faff")
const MM_SHADE := Color("#d6e4f8")
const MM_SKIN := Color("#a4cbf4")
const MM_SKIN_DARK := Color("#6f9fdc")
const MM_HORN := Color("#cdb8ec")

## Little blue fur flicks a kid scribbles on white fur.
static func _flicks(c: CanvasItem, inside: PackedVector2Array, area: Rect2, count: int, seed: int) -> void:
	for i in count:
		var at := area.position + Vector2((Crayon.noise(seed, i) * 0.5 + 0.5) * area.size.x,
			(Crayon.noise(seed + 1, i) * 0.5 + 0.5) * area.size.y)
		if not Geometry2D.is_point_in_polygon(at, inside):
			continue
		var pts := PackedVector2Array([at + Vector2(-9, -8), at, at + Vector2(8, -10)])
		Crayon.marker_line(c, pts, MM_SKIN_DARK, 4.0, seed + 5 + i, false)


static func _marsh_body(c: CanvasItem) -> void:
	var body := _fuzz(_squircle(Vector2(256, 262), Vector2(150, 172), 2.4, 1501, 40, 0.02), 18.0, 13.0, 1502)
	_fill(c, body, MM_WHITE, 1503)
	_clip_fill(c, Crayon.blob(Vector2(236, 410), Vector2(170, 60), 1504, 16, 0.05), body, MM_SHADE, 1505)
	_clip_fill(c, Crayon.blob(Vector2(330, 300), Vector2(70, 92), 1507, 16, 0.05), body, MM_SHADE, 1508)
	_flicks(c, body, Rect2(120, 120, 180, 260), 10, 1506)
	Crayon.marker_line(c, body, INK, W_BODY, 1530)


static func _marsh_head(c: CanvasItem) -> void:
	var skull := _fuzz(_squircle(Vector2(284, 338), Vector2(108, 98), 2.4, 1541, 36, 0.02), 18.0, 12.0, 1542)
	var neck := _tube(_seg(Vector2(204, 412), Vector2(232, 390), 6), 46.0, 46.0)
	var head := _merge(skull, neck)
	_fill(c, head, MM_WHITE, 1543)
	_clip_fill(c, Crayon.blob(Vector2(336, 360), Vector2(78, 76), 1545, 18, 0.05), head, MM_SKIN, 1546, 16.0, 6.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1560)
	var nose := Crayon.blob(Vector2(390, 362), Vector2(14, 10), 1561, 10, 0.05)
	_part(c, nose, MM_SKIN_DARK, 1562, 5.0, 8.0)


static func _marsh_eye(c: CanvasItem) -> void:
	_eye(c, 1571, Vector2(58, 64), Color(), 0.0, Vector2(30, 34), Vector2(6, 4))


static func _marsh_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1581, Vector2(78, 62), 0.4, 2)


static func _marsh_horn(c: CanvasItem) -> void:
	var horn := _join(_bez(Vector2(222, 462), Vector2(222, 404), Vector2(236, 362), Vector2(278, 336), 8),
		_bez(Vector2(278, 336), Vector2(270, 370), Vector2(284, 414), Vector2(290, 462), 8))
	_fill(c, horn, MM_HORN, 1591, 14.0)
	_ink_in(c, _seg(Vector2(200, 424), Vector2(320, 412), 4), horn, 5.0, 1592)
	_ink_in(c, _seg(Vector2(200, 390), Vector2(320, 376), 4), horn, 5.0, 1593)
	Crayon.marker_line(c, horn, INK, W_EAR, 1594)


static func _marsh_arm(c: CanvasItem) -> void:
	var arm := _fuzz(_tube(_seg(Vector2(256, 66), Vector2(282, 158), 8), 38.0, 34.0), 16.0, 10.0, 1601)
	_fill(c, arm, MM_WHITE, 1602)
	_clip_fill(c, _tube(_seg(Vector2(232, 96), Vector2(254, 156), 6), 10.0, 10.0), arm, MM_SHADE, 1603, 10.0)
	_flicks(c, arm, Rect2(250, 90, 40, 70), 3, 1604)
	Crayon.marker_line(c, arm, INK, W_ARM, 1610)


static func _marsh_hand(c: CanvasItem) -> void:
	var parts := [Crayon.blob(Vector2(258, 150), Vector2(66, 54), 1621, 18, 0.04)]
	for f in [[Vector2(226, 180), Vector2(218, 230)], [Vector2(258, 186), Vector2(258, 240)],
			[Vector2(290, 180), Vector2(298, 230)]]:
		parts.append(_tube(_seg(f[0], f[1], 4), 19.0, 18.0))
	parts.append(_tube(_seg(Vector2(306, 132), Vector2(344, 168), 4), 18.0, 17.0))
	var hand := _scaled(_merge_all(parts), 1.35, Vector2(256, 96))
	_part(c, hand, MM_SKIN, 1622, W_HAND)
	var cuff := _fuzz(Crayon.blob(Vector2(256, 94), Vector2(88, 36), 1623, 18, 0.03), 16.0, 11.0, 1624)
	_part(c, cuff, MM_WHITE, 1625, W_HAND)


static func _marsh_leg(c: CanvasItem) -> void:
	var leg := _fuzz(_tube(_seg(Vector2(256, 64), Vector2(256, 206), 6), 52.0, 48.0), 18.0, 11.0, 1631)
	_fill(c, leg, MM_WHITE, 1632)
	_clip_fill(c, _tube(_seg(Vector2(222, 90), Vector2(222, 210), 4), 12.0, 12.0), leg, MM_SHADE, 1633, 10.0)
	Crayon.marker_line(c, leg, INK, W_BODY, 1640)


static func _marsh_foot(c: CanvasItem) -> void:
	var pad := Crayon.blob(Vector2(250, 198), Vector2(122, 46), 1651, 18, 0.03)
	var toes := []
	for t in [Vector2(364, 176), Vector2(382, 204), Vector2(366, 232)]:
		toes.append(Crayon.blob(t, Vector2(28, 24), 1652, 12, 0.04))
	var foot := _merge_all([pad] + toes)
	_part(c, foot, MM_SKIN, 1653, W_FOOT)
	var cuff := _fuzz(Crayon.blob(Vector2(190, 140), Vector2(104, 36), 1654, 18, 0.03), 18.0, 12.0, 1655)
	_part(c, cuff, MM_WHITE, 1656, W_FOOT)


# --- Sparkle: pastel unicorn pony -------------------------------------------------------------

const SP_PINK := Color("#ffd8eb")
const SP_SPOT := Color("#ffb3d6")
const SP_MUZZLE := Color("#fff0f7")
const SP_HOOF := Color("#c8a6f2")
const SP_GOLD := Color("#ffe17a")
const RAINBOW := [Color("#ff8a8a"), Color("#ffbd6b"), Color("#fff07a"), Color("#9fe38c"),
	Color("#8cc8ff"), Color("#c49cf2")]

static func _sparkle_body(c: CanvasItem) -> void:
	var body := Crayon.blob(Vector2(256, 262), Vector2(194, 104), 1701, 22, 0.035)
	_fill(c, body, SP_PINK, 1702)
	_spots(c, body, [[Vector2(110, 250), 13.0], [Vector2(136, 294), 10.0], [Vector2(330, 300), 12.0],
		[Vector2(380, 230), 10.0], [Vector2(250, 312), 9.0]], SP_SPOT, 1703)
	Crayon.marker_line(c, body, INK, W_BODY, 1720)
	_part(c, Crayon.star(Vector2(158, 232), 32.0, 1721), SP_GOLD, 1722, 5.0, 10.0)


static func _sparkle_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(286, 300), Vector2(96, 86), 1731, 20, 0.03)
	var snout := Crayon.blob(Vector2(380, 348), Vector2(68, 50), 1732, 16, 0.04)
	var neck := _tube(_seg(Vector2(200, 414), Vector2(252, 334), 6), 44.0, 42.0)
	var head := _merge_all([skull, snout, neck])
	_fill(c, head, SP_PINK, 1733)
	_clip_fill(c, Crayon.blob(Vector2(400, 352), Vector2(54, 44), 1734, 14, 0.05), head, SP_MUZZLE, 1735)
	_clip_fill(c, Crayon.blob(Vector2(330, 352), Vector2(22, 14), 1736, 10, 0.08), head, SP_SPOT, 1737, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1738)
	_ink(c, _bez(Vector2(424, 332), Vector2(428, 322), Vector2(438, 322), Vector2(440, 332), 4), 5.0, 1739)


static func _sparkle_eye(c: CanvasItem) -> void:
	_eye(c, 1741, Vector2(62, 68), Color("#b490f0"), 44.0, Vector2(22, 26), Vector2(6, 4))
	_lashes(c, 1748, Vector2(62, 68))


static func _sparkle_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 1751, Vector2(68, 56), 0.45)


static func _sparkle_ear(c: CanvasItem) -> void:
	var ear := _join(_bez(Vector2(224, 458), Vector2(214, 400), Vector2(236, 350), Vector2(264, 316), 8),
		_bez(Vector2(264, 316), Vector2(290, 356), Vector2(298, 410), Vector2(290, 458), 8))
	_fill(c, ear, SP_PINK, 1761)
	var inner := _join(_bez(Vector2(244, 450), Vector2(240, 410), Vector2(250, 372), Vector2(264, 348), 6),
		_bez(Vector2(264, 348), Vector2(278, 378), Vector2(282, 414), Vector2(276, 450), 6))
	_clip_fill(c, inner, ear, SP_SPOT, 1762, 12.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 1763)


static func _sparkle_horn(c: CanvasItem) -> void:
	var horn := _join(_bez(Vector2(226, 462), Vector2(238, 380), Vector2(258, 300), Vector2(282, 232), 10),
		_bez(Vector2(282, 232), Vector2(284, 300), Vector2(290, 380), Vector2(290, 462), 10))
	_fill(c, horn, SP_GOLD, 1771, 14.0)
	for i in 4:
		var y := 432.0 - i * 46.0
		_ink_in(c, _seg(Vector2(200, y + 14), Vector2(320, y - 14), 4), horn, 6.0, 1772 + i)
	Crayon.marker_line(c, horn, INK, W_EAR, 1780)


## The mane: rainbow locks arching up and back over the neck, drawn behind the head.
static func _sparkle_hair(c: CanvasItem) -> void:
	for j in RAINBOW.size():
		var k: int = RAINBOW.size() - 1 - j
		var p0 := Vector2(318 - k * 6, 446)
		var p1 := Vector2(310 - k * 10, 290 + k * 22)
		var p2 := Vector2(176 - k * 6, 240 + k * 30)
		var p3 := Vector2(128 - k * 4, 360 + k * 20)
		var lock := _tube(_bez(p0, p1, p2, p3, 16), 22.0, 12.0)
		_part(c, lock, RAINBOW[k], 1791 + k * 3, 8.0, 14.0)


static func _sparkle_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 64), Vector2(256, 206), 6), 25.0, 22.0)
	_part(c, leg, SP_PINK, 1811)
	var hoof := Crayon.rounded_rect(Rect2(226, 198, 64, 44), 12.0)
	_part(c, hoof, SP_HOOF, 1812)


static func _sparkle_tail(c: CanvasItem) -> void:
	for j in RAINBOW.size():
		var k: int = RAINBOW.size() - 1 - j
		var p0 := Vector2(456, 246 + k * 6)
		var p1 := Vector2(370, 222 + k * 10)
		var p2 := Vector2(262, 230 + k * 24)
		var p3 := Vector2(176 - k * 6, 320 + k * 28)
		var lock := _tube(_bez(p0, p1, p2, p3, 16), 19.0, 10.0)
		_part(c, lock, RAINBOW[k], 1821 + k * 3, 8.0, 12.0)


# --- Bolt: a boxy robot pup -------------------------------------------------------------------

const BO_SILVER := Color("#c9d3df")
const BO_DARK := Color("#9aa8b9")
const BO_ORANGE := Color("#ffb44f")
const BO_RED := Color("#ff6f6f")
const BO_BLUE := Color("#8fd0ff")

## A bolt head: a grey dot with a cross on it.
static func _bolt_dot(c: CanvasItem, at: Vector2, r: float, seed: int) -> void:
	var dot := Crayon.blob(at, Vector2(r, r), seed, 10, 0.05)
	_part(c, dot, BO_DARK, seed + 1, 4.0, 8.0)
	_ink(c, _seg(at - Vector2(r * 0.5, 0), at + Vector2(r * 0.5, 0), 1), 3.0, seed + 2)
	_ink(c, _seg(at - Vector2(0, r * 0.5), at + Vector2(0, r * 0.5), 1), 3.0, seed + 3)


static func _box_shape(rect: Rect2, radius: float, seed: int) -> PackedVector2Array:
	var pts := Crayon.wobbled(Crayon.rounded_rect(rect, radius), seed, 1.4, true)
	pts.remove_at(pts.size() - 1)
	return pts


static func _bolt_body(c: CanvasItem) -> void:
	var body := _box_shape(Rect2(62, 150, 388, 224), 46.0, 1901)
	_fill(c, body, BO_SILVER, 1902)
	_clip_fill(c, Crayon.rounded_rect(Rect2(40, 334, 430, 60), 4.0), body, BO_DARK, 1903)
	Crayon.marker_line(c, body, INK, W_BODY, 1904)
	_ink(c, _seg(Vector2(66, 334), Vector2(446, 334), 12), 5.0, 1905)
	_part(c, Crayon.rounded_rect(Rect2(196, 192, 152, 112), 20.0), BO_ORANGE, 1906, 6.0, 14.0)
	_part(c, Crayon.heart(Vector2(272, 250), 72.0), BO_RED, 1908, 5.0, 12.0)
	var bolts := [Vector2(100, 186), Vector2(412, 186), Vector2(110, 300), Vector2(402, 300)]
	for i in bolts.size():
		_bolt_dot(c, bolts[i], 11.0, 1910 + i * 4)


static func _bolt_head(c: CanvasItem) -> void:
	var neck_path := _seg(Vector2(200, 414), Vector2(234, 368), 4)
	var neck := _tube(neck_path, 34.0, 34.0)
	var skull := _box_shape(Rect2(194, 222, 226, 168), 32.0, 1931)
	var snout := Crayon.rounded_rect(Rect2(370, 316, 90, 100), 22.0)
	var head := _merge_all([skull, neck, snout])
	_fill(c, head, BO_SILVER, 1932)
	_clip_fill(c, _band(neck_path, 0.4, 50.0, 6.0), head, BO_DARK, 1933, 10.0, 4.0)
	_clip_fill(c, Crayon.rounded_rect(Rect2(150, 200, 300, 26), 4.0), head, BO_ORANGE, 1934, 12.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1935)
	_ink(c, _seg(Vector2(198, 228), Vector2(416, 228), 10), 5.0, 1936)
	c.draw_colored_polygon(Crayon.rounded_rect(Rect2(428, 320, 28, 22), 8.0), INK)
	_bolt_dot(c, Vector2(250, 336), 11.0, 1937)


static func _bolt_eye(c: CanvasItem) -> void:
	var white := Crayon.rounded_rect(Rect2(O.x - 60, O.y - 64, 120, 128), 34.0)
	c.draw_colored_polygon(white, PAPER)
	var ir := Crayon.blob(O + Vector2(8, 4), Vector2(40, 42), 1941, 18, 0.04)
	_fill(c, ir, BO_BLUE, 1942, 14.0)
	Crayon.marker_line(c, ir, INK, 6.0, 1943)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(10, 5), Vector2(22, 24), 1944, 14, 0.04), INK)
	c.draw_circle(O + Vector2(0, -6), 8.0, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 1945)


static func _bolt_mouth(c: CanvasItem) -> void:
	var m := Crayon.rounded_rect(Rect2(O.x - 86, O.y - 54, 172, 108), 34.0)
	_fill(c, m, MOUTH_IN, 1951, 18.0)
	_clip_fill(c, Crayon.blob(Vector2(O.x + 10, O.y + 36), Vector2(52, 30), 1952, 16, 0.05), m, TONGUE, 1953, 16.0)
	for k in 4:
		var x := O.x - 66.0 + k * 34.0
		var tooth := PackedVector2Array([Vector2(x, O.y - 60), Vector2(x + 30, O.y - 60),
			Vector2(x + 30, O.y - 22), Vector2(x, O.y - 22)])
		_clip_fill(c, tooth, m, PAPER, 1954 + k, 12.0, 6.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 1960)


static func _bolt_antenna(c: CanvasItem) -> void:
	var spring := PackedVector2Array()
	for i in 10:
		var p := Vector2(256, 448).lerp(Vector2(292, 302), i / 9.0)
		var side := 0.0 if i == 0 or i == 9 else (16.0 if i % 2 == 0 else -16.0)
		spring.append(p + Vector2(side, 0))
	_ink(c, spring, W_ANT, 1971)
	_part(c, Crayon.rounded_rect(Rect2(230, 434, 52, 28), 10.0), BO_DARK, 1972, 8.0, 12.0)
	var bulb := Crayon.blob(Vector2(294, 276), Vector2(30, 30), 1973, 14, 0.04)
	_part(c, bulb, BO_RED, 1974, W_ANT, 14.0)
	c.draw_circle(Vector2(284, 266), 7.0, Color(1, 1, 1, 0.85))


static func _bolt_ear(c: CanvasItem) -> void:
	var ear := _skew(Crayon.rounded_rect(Rect2(222, 318, 70, 138), 16.0), 0.28, 456.0)
	_fill(c, ear, BO_SILVER, 1981)
	var inner := _skew(Crayon.rounded_rect(Rect2(240, 340, 34, 90), 8.0), 0.28, 456.0)
	_clip_fill(c, inner, ear, BO_ORANGE, 1982, 12.0, 5.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 1983)


static func _bolt_leg(c: CanvasItem) -> void:
	var path := _seg(Vector2(256, 64), Vector2(256, 206), 6)
	var leg := _tube(path, 22.0, 22.0)
	_fill(c, leg, BO_SILVER, 1991)
	for k in 2:
		_clip_fill(c, _band(path, 0.35 + k * 0.3, 40.0, 7.0), leg, BO_DARK, 1992 + k, 10.0)
	Crayon.marker_line(c, leg, INK, W_BODY, 1995)
	_part(c, Crayon.rounded_rect(Rect2(214, 196, 104, 50), 16.0), BO_ORANGE, 1996)
	_bolt_dot(c, Vector2(244, 220), 8.0, 1998)


static func _bolt_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(452, 258), Vector2(380, 262), Vector2(330, 226), Vector2(322, 150), 14)
	var tail := _tube(path, 14.0, 12.0)
	_fill(c, tail, BO_SILVER, 2001)
	Crayon.marker_line(c, tail, INK, W_ARM, 2002)
	for i in range(3, 13, 2):
		var p := path[i]
		var d := (path[i + 1] - path[i - 1]).normalized()
		var nrm := d.orthogonal()
		_ink(c, _seg(p - nrm * 13.0 - d * 5.0, p + nrm * 13.0 + d * 5.0, 2), 4.0, 2003 + i)
	var ball := Crayon.blob(path[path.size() - 1] + Vector2(0, -14), Vector2(28, 28), 2020, 14, 0.04)
	_part(c, ball, BO_ORANGE, 2021, W_ARM, 14.0)


# --- Cactus Jack: a cheerful cactus in cowboy boots -------------------------------------------

const CJ_GREEN := Color("#88d08e")
const CJ_DARK := Color("#5fae72")
const CJ_SPINE := Color("#fff3c8")
const CJ_PINK := Color("#ff92c2")
const CJ_YELLOW := Color("#ffd94d")
const CJ_BOOT := Color("#d6955a")
const CJ_BOOT2 := Color("#a8703f")

static func _jack_body(c: CanvasItem) -> void:
	var ctr := Vector2(256, 256)
	var r := Vector2(150, 206)
	var body := _squircle(ctr, r, 2.5, 2101, 48, 0.015)
	_fill(c, body, CJ_GREEN, 2102)
	for k in 3:
		var f := -0.66 + k * 0.38
		var rib := PackedVector2Array()
		for i in 13:
			var t := -0.86 + i * (1.72 / 12.0)
			var w := pow(1.0 - pow(absf(t), 2.5), 1.0 / 2.5)
			rib.append(ctr + Vector2(f * r.x * w, t * r.y))
		Crayon.marker_line(c, rib, CJ_DARK, 7.0, 2103 + k, false)
	Crayon.marker_line(c, body, INK, W_BODY, 2110)
	for i in 9:
		var at := ctr + Vector2(-60.0 + Crayon.noise(2111, i) * 80.0, Crayon.noise(2112, i) * 164.0)
		_ink(c, PackedVector2Array([at + Vector2(-7, -7), at, at + Vector2(7, -7)]), 3.5, 2113 + i)


static func _jack_eye(c: CanvasItem) -> void:
	_eye(c, 2131, Vector2(62, 66), Color(), 0.0, Vector2(30, 34), Vector2(6, 4))


static func _jack_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 2141, Vector2(80, 62), 0.4)


## A saguaro arm: down from the shoulder, out to the side under the mouth, then bending up at
## the elbow. A cactus has no head, so its shoulder sits on the trunk just under its eyes; where
## the arm lies over the trunk it is only lined in rib-green, and gone round in black where it
## leaves it - so it grows out of the cactus's side instead of crossing its face.
static func _jack_arm(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 80), Vector2(250, 130), Vector2(250, 196), Vector2(300, 206), 8)
	path.remove_at(path.size() - 1)
	path.append_array(_seg(Vector2(300, 206), Vector2(356, 208), 3))
	path.remove_at(path.size() - 1)
	path.append_array(_bez(Vector2(356, 208), Vector2(392, 210), Vector2(390, 180), Vector2(388, 108), 8))
	var arm := _tube(path, 17.0, 22.0)
	_fill(c, arm, CJ_GREEN, 2151, 10.0)
	var rib := PackedVector2Array()
	for i in range(9, path.size() - 1):
		rib.append(path[i])
	Crayon.marker_line(c, rib, CJ_DARK, 5.0, 2152, false)
	Crayon.marker_line(c, arm, CJ_DARK, 6.0, 2154)
	var ring := arm.duplicate()
	ring.append(arm[0])
	var outside := PackedVector2Array([Vector2(350, -20), Vector2(530, -20), Vector2(530, 320), Vector2(350, 320)])
	_ink_in(c, ring, outside, W_ARM, 2153)


static func _jack_spike(c: CanvasItem) -> void:
	var needle := _join(_bez(Vector2(240, 458), Vector2(244, 420), Vector2(252, 392), Vector2(262, 366), 6),
		_bez(Vector2(262, 366), Vector2(266, 392), Vector2(270, 420), Vector2(272, 458), 6))
	_part(c, needle, CJ_SPINE, 2161, 7.0, 10.0)


## The flower on top: a stem and five pink petals.
static func _jack_hair(c: CanvasItem) -> void:
	_part(c, _tube(_seg(Vector2(300, 440), Vector2(302, 330), 6), 11.0, 10.0), CJ_GREEN, 2171, W_FIN, 12.0)
	_part(c, _oval(Vector2(338, 384), Vector2(30, 14), -0.5, 2173), CJ_GREEN, 2174, 8.0, 12.0)
	var fc := Vector2(302, 290)
	for i in 5:
		var a := -PI * 0.5 + i * TAU / 5.0
		var petal := _oval(fc + Vector2(cos(a), sin(a)) * 38.0, Vector2(32, 24), a, 2176 + i)
		_part(c, petal, CJ_PINK, 2181 + i * 2, W_FIN, 14.0)
	_part(c, Crayon.blob(fc, Vector2(25, 25), 2191, 14, 0.05), CJ_YELLOW, 2192, W_FIN, 14.0)


static func _jack_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 64), Vector2(256, 160), 6), 30.0, 28.0)
	_part(c, leg, CJ_GREEN, 2201)


## A cowboy boot, toe pointing right, with a star on it.
static func _jack_foot(c: CanvasItem) -> void:
	var k := 1.2
	var at := Vector2(190, 120)
	var heel := _scaled(Crayon.rounded_rect(Rect2(128, 262, 62, 36), 8.0), k, at)
	_part(c, heel, CJ_BOOT2, 2211, W_FOOT, 14.0)
	var shaft := Crayon.rounded_rect(Rect2(130, 112, 120, 128), 14.0)
	var toe := _smooth(PackedVector2Array([Vector2(140, 216), Vector2(250, 212), Vector2(318, 226),
		Vector2(370, 250), Vector2(378, 270), Vector2(330, 282), Vector2(150, 282), Vector2(128, 262)]), 5)
	var boot := _scaled(_merge(shaft, toe), k, at)
	_fill(c, boot, CJ_BOOT, 2213)
	_clip_fill(c, Crayon.rounded_rect(Rect2(110, 96, 160, 34), 4.0), boot, CJ_BOOT2, 2214, 12.0)
	_ink_in(c, _scaled(_bez(Vector2(250, 236), Vector2(290, 238), Vector2(330, 250), Vector2(360, 268), 8), k, at),
		boot, 4.0, 2215)
	Crayon.marker_line(c, boot, INK, W_FOOT, 2216)
	_part(c, Crayon.star(Vector2(190, 194), 36.0, 2217), CJ_YELLOW, 2218, 6.0, 10.0)


# --- Gummy: a red gummy bear ------------------------------------------------------------------

const GU_RED := Color("#ff7474")
const GU_LIGHT := Color("#ffaba6")

static func _gummy_body(c: CanvasItem) -> void:
	var ctr := Vector2(256, 264)
	var body := Crayon.blob(ctr, Vector2(156, 132), 2301, 24, 0.03)
	_fill(c, body, GU_RED, 2302)
	_clip_fill(c, Crayon.blob(Vector2(322, 300), Vector2(74, 72), 2303, 16, 0.05), body, GU_LIGHT, 2304)
	Crayon.marker_line(c, body, INK, W_BODY, 2305)
	_shine(c, ctr, Vector2(118, 98), PI * 1.1, PI * 1.36, 13.0)
	c.draw_circle(ctr + Vector2(cos(PI * 1.45) * 118.0, sin(PI * 1.45) * 98.0), 7.0, Color(1, 1, 1, 0.8))


static func _gummy_head(c: CanvasItem) -> void:
	var ctr := Vector2(288, 328)
	var skull := Crayon.blob(ctr, Vector2(114, 104), 2311, 20, 0.03)
	var muzzle := Crayon.blob(Vector2(378, 380), Vector2(60, 46), 2312, 16, 0.04)
	var neck := _tube(_seg(Vector2(204, 414), Vector2(232, 392), 6), 40.0, 40.0)
	var head := _merge_all([skull, neck, muzzle])
	_fill(c, head, GU_RED, 2313)
	_clip_fill(c, Crayon.blob(Vector2(384, 384), Vector2(52, 40), 2314, 14, 0.05), head, GU_LIGHT, 2315)
	Crayon.marker_line(c, head, INK, W_BODY, 2316)
	_shine(c, ctr, Vector2(84, 76), PI * 1.08, PI * 1.36, 11.0)
	c.draw_colored_polygon(Crayon.blob(Vector2(420, 358), Vector2(17, 13), 2317, 10, 0.05), INK)


static func _gummy_eye(c: CanvasItem) -> void:
	_eye(c, 2321, Vector2(56, 62), Color(), 0.0, Vector2(32, 36), Vector2(6, 4))
	c.draw_circle(O + Vector2(22, 24), 6.0, Color.WHITE)


static func _gummy_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 2331, Vector2(70, 58), 0.45)


static func _gummy_ear(c: CanvasItem) -> void:
	var ear := _merge(Crayon.blob(Vector2(256, 392), Vector2(54, 52), 2341, 16, 0.03),
		_tube(_seg(Vector2(256, 468), Vector2(256, 410), 4), 34.0, 34.0))
	_fill(c, ear, GU_RED, 2342)
	_clip_fill(c, Crayon.blob(Vector2(258, 398), Vector2(28, 26), 2343, 12, 0.05), ear, GU_LIGHT, 2344, 12.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 2345)


static func _gummy_arm(c: CanvasItem) -> void:
	var arm := _tube(_seg(Vector2(256, 64), Vector2(268, 168), 6), 36.0, 34.0)
	_part(c, arm, GU_RED, 2351, W_ARM)
	c.draw_polyline(_seg(Vector2(240, 82), Vector2(248, 150), 3), Color(1, 1, 1, 0.8), 10.0, true)


static func _gummy_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 64), Vector2(256, 150), 6), 44.0, 46.0)
	var foot := Crayon.blob(Vector2(270, 172), Vector2(58, 38), 2361, 16, 0.04)
	_part(c, _merge(leg, foot), GU_RED, 2362)
	c.draw_polyline(_seg(Vector2(232, 84), Vector2(232, 140), 3), Color(1, 1, 1, 0.8), 10.0, true)


# --- Ember: orange fire salamander ------------------------------------------------------------

const EM_ORANGE := Color("#ffa14f")
const EM_SPOT := Color("#ffe04f")
const EM_BELLY := Color("#ffe6a3")
const EM_RED := Color("#ff6248")
const EM_FLAME_IN := Color("#ffe066")

static func _ember_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 266), Vector2(212, 108), 0.3, 2401, 28, 0.03)
	_fill(c, body, EM_ORANGE, 2402)
	_clip_fill(c, Crayon.blob(Vector2(280, 346), Vector2(222, 50), 2403, 16, 0.05), body, EM_BELLY, 2404)
	_spots(c, body, [[Vector2(124, 240), 14.0], [Vector2(186, 214), 18.0], [Vector2(262, 204), 16.0],
		[Vector2(336, 212), 18.0], [Vector2(404, 238), 13.0], [Vector2(226, 262), 11.0],
		[Vector2(304, 256), 11.0]], EM_SPOT, 2405, 4.0)
	Crayon.marker_line(c, body, INK, W_BODY, 2430)


static func _ember_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(312, 342), Vector2(122, 80), 2441, 20, 0.03)
	var jaw := Crayon.blob(Vector2(366, 384), Vector2(82, 40), 2442, 16, 0.04)
	var neck := _tube(_seg(Vector2(202, 414), Vector2(252, 372), 6), 44.0, 44.0)
	var head := _merge_all([skull, jaw, neck])
	_fill(c, head, EM_ORANGE, 2443)
	_spots(c, head, [[Vector2(262, 290), 12.0], [Vector2(300, 276), 9.0], [Vector2(232, 340), 10.0]],
		EM_SPOT, 2444, 4.0)
	_clip_fill(c, Crayon.blob(Vector2(330, 392), Vector2(22, 14), 2450, 10, 0.08), head, Color("#ff8a7a"), 2451, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 2452)
	c.draw_circle(Vector2(420, 316), 5.0, INK)
	c.draw_circle(Vector2(404, 310), 5.0, INK)


static func _ember_eye(c: CanvasItem) -> void:
	_eye(c, 2461, Vector2(62, 68), Color("#ffd23f"), 42.0, Vector2(22, 26), Vector2(8, 4))


static func _ember_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 2471, Vector2(98, 62), 0.3)


static func _ember_spike(c: CanvasItem) -> void:
	var outer := _flame(Vector2(256, 456), 0.68)
	_fill(c, outer, EM_RED, 2481, 16.0)
	_clip_fill(c, _flame(Vector2(258, 452), 0.4), outer, EM_FLAME_IN, 2482, 12.0)
	Crayon.marker_line(c, outer, INK, W_ANT, 2483)


static func _ember_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 64), Vector2(262, 158), 6), 30.0, 26.0)
	var foot := Crayon.blob(Vector2(280, 176), Vector2(46, 22), 2491, 12, 0.04)
	var toes := []
	for t in [Vector2(322, 162), Vector2(330, 184), Vector2(308, 198)]:
		toes.append(Crayon.blob(t, Vector2(13, 13), 2492, 10, 0.05))
	var shape := _merge_all([leg, foot] + toes)
	_fill(c, shape, EM_ORANGE, 2493)
	_spots(c, shape, [[Vector2(246, 110), 11.0]], EM_SPOT, 2494, 4.0)
	Crayon.marker_line(c, shape, INK, W_BODY, 2499)


static func _ember_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(452, 262), Vector2(360, 276), Vector2(220, 272), Vector2(110, 196), 18)
	var tail := _tube(path, 52.0, 14.0)
	_fill(c, tail, EM_ORANGE, 2501)
	_spots(c, tail, [[path[5] + Vector2(0, -16), 14.0], [path[9] + Vector2(0, -12), 11.0],
		[path[13] + Vector2(4, -6), 8.0]], EM_SPOT, 2502, 4.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 2510)
	var end := path[path.size() - 1]
	var dir := (end - path[path.size() - 3]).normalized()
	var fl := _flame(end - dir * 6.0, 0.36, dir.angle() + PI * 0.5)
	_fill(c, fl, EM_RED, 2511, 12.0)
	_clip_fill(c, _flame(end - dir * 2.0, 0.2, dir.angle() + PI * 0.5), fl, EM_FLAME_IN, 2512, 10.0)
	Crayon.marker_line(c, fl, INK, W_BODY, 2513)


# --- Crystal: chunky rock golem with crystal horns --------------------------------------------

const KR_STONE := Color("#ab9fcd")
const KR_DARK := Color("#8b7db5")
const KR_GEM := Color("#8ef0ec")
const KR_GEM2 := Color("#ffa6d8")

static func _crystal_body(c: CanvasItem) -> void:
	# crystals growing out of its back first; the rock covers their roots
	var shards := [[Vector2(150, 180), 70.0, 18.0, -16.0, KR_GEM], [Vector2(196, 166), 98.0, 22.0, -4.0, KR_GEM2],
		[Vector2(244, 160), 64.0, 16.0, 10.0, KR_GEM]]
	for i in shards.size():
		var sh: Array = shards[i]
		var p := _shard(sh[0], sh[1], sh[2], sh[3])
		_fill(c, p, sh[4], 2601 + i * 3, 12.0)
		var tip: Vector2 = p[2]
		_ink_in(c, _seg(tip, tip.lerp((p[0] + p[4]) * 0.5, 1.0), 4), p, 5.0, 2602 + i * 3)
		Crayon.marker_line(c, p, INK, W_BODY, 2603 + i * 3)
	var body := _egg(Vector2(256, 264), Vector2(200, 134), 0.3, 2611, 13, 0.06)
	_fill(c, body, KR_STONE, 2612)
	var facets := [PackedVector2Array([Vector2(126, 230), Vector2(196, 214), Vector2(160, 290)]),
		PackedVector2Array([Vector2(300, 320), Vector2(372, 296), Vector2(352, 372)]),
		PackedVector2Array([Vector2(230, 340), Vector2(276, 300), Vector2(282, 370)])]
	for i in facets.size():
		_clip_fill(c, facets[i], body, KR_DARK, 2613 + i, 12.0)
	Crayon.marker_line(c, body, INK, W_BODY + 1.0, 2620)
	_ink(c, PackedVector2Array([Vector2(330, 160), Vector2(344, 190), Vector2(332, 212), Vector2(350, 236)]), 5.0, 2621)
	_ink(c, PackedVector2Array([Vector2(110, 300), Vector2(136, 316), Vector2(130, 340)]), 5.0, 2622)
	_gem(c, Vector2(400, 256), 16.0, KR_GEM, 2623)


static func _crystal_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(290, 326), Vector2(100, 84), 2631, 10, 0.07)
	var jaw := Crayon.rounded_rect(Rect2(296, 342, 116, 76), 16.0)
	var neck := _tube(_seg(Vector2(202, 414), Vector2(236, 374), 6), 42.0, 42.0)
	var head := _merge_all([skull, jaw, neck])
	_fill(c, head, KR_STONE, 2632)
	_clip_fill(c, PackedVector2Array([Vector2(200, 300), Vector2(250, 260), Vector2(244, 330)]), head, KR_DARK, 2633, 12.0)
	_clip_fill(c, PackedVector2Array([Vector2(206, 380), Vector2(270, 360), Vector2(250, 420)]), head, KR_DARK, 2634, 12.0)
	Crayon.marker_line(c, head, INK, W_BODY + 1.0, 2635)
	_ink(c, PackedVector2Array([Vector2(236, 262), Vector2(248, 284), Vector2(240, 300)]), 5.0, 2636)


static func _crystal_eye(c: CanvasItem) -> void:
	_eye(c, 2641, Vector2(60, 64), Color("#5fd8e0"), 40.0, Vector2(22, 24), Vector2(6, 4))


static func _crystal_mouth(c: CanvasItem) -> void:
	_open_mouth(c, 2651, Vector2(82, 58), 0.3, 2)


static func _crystal_horn(c: CanvasItem) -> void:
	var base := Vector2(256, 462)
	var s := _shard(base, 196.0, 34.0, 14.0)
	_fill(c, s, KR_GEM, 2661, 16.0)
	var face := PackedVector2Array([base + Vector2(-44, 10), base + Vector2(-44, -210), base + Vector2(14, -210),
		base + Vector2(4, 10)])
	_clip_fill(c, face, s, KR_GEM.lightened(0.5), 2662, 12.0)
	_ink_in(c, _seg(base + Vector2(4, 0), base + Vector2(14, -196), 4), s, 6.0, 2663)
	Crayon.marker_line(c, s, INK, W_EAR, 2664)
	c.draw_polyline(_seg(base + Vector2(-20, -40), base + Vector2(-14, -110), 2), Color(1, 1, 1, 0.85), 9.0, true)


static func _crystal_arm(c: CanvasItem) -> void:
	var arm := _tube(_seg(Vector2(256, 66), Vector2(262, 206), 6), 46.0, 40.0)
	_fill(c, arm, KR_STONE, 2671)
	_clip_fill(c, PackedVector2Array([Vector2(206, 150), Vector2(262, 130), Vector2(236, 200)]), arm, KR_DARK, 2672, 12.0)
	Crayon.marker_line(c, arm, INK, W_ARM, 2673)
	_ink(c, PackedVector2Array([Vector2(280, 110), Vector2(270, 130), Vector2(284, 148)]), 5.0, 2674)
	_gem(c, Vector2(248, 86), 15.0, KR_GEM2, 2675)


static func _crystal_hand(c: CanvasItem) -> void:
	var parts := [Crayon.rounded_rect(Rect2(184, 62, 146, 118), 30.0)]
	for f in [[Vector2(212, 168), Vector2(208, 224)], [Vector2(256, 172), Vector2(256, 234)],
			[Vector2(300, 168), Vector2(304, 224)]]:
		parts.append(_tube(_seg(f[0], f[1], 4), 23.0, 22.0))
	parts.append(_tube(_seg(Vector2(322, 104), Vector2(358, 148), 4), 22.0, 21.0))
	var k := 1.22
	var at := Vector2(256, 80)
	var hand := _scaled(_merge_all(parts), k, at)
	_fill(c, hand, KR_STONE, 2681)
	Crayon.marker_line(c, hand, INK, W_HAND, 2682)
	_ink(c, _scaled(_seg(Vector2(234, 196), Vector2(234, 170), 2), k, at), 6.0, 2683)
	_ink(c, _scaled(_seg(Vector2(278, 196), Vector2(278, 170), 2), k, at), 6.0, 2684)
	_gem(c, at + (Vector2(252, 116) - at) * k, 28.0, KR_GEM2, 2685)


static func _crystal_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 64), Vector2(256, 160), 6), 52.0, 54.0)
	var foot := Crayon.rounded_rect(Rect2(192, 150, 146, 56), 18.0)
	var shape := _merge(leg, foot)
	_fill(c, shape, KR_STONE, 2691)
	_clip_fill(c, PackedVector2Array([Vector2(196, 90), Vector2(250, 76), Vector2(222, 140)]), shape, KR_DARK, 2692, 12.0)
	Crayon.marker_line(c, shape, INK, W_BODY + 1.0, 2693)
	_ink(c, _seg(Vector2(296, 206), Vector2(296, 184), 2), 6.0, 2694)
	_ink(c, _seg(Vector2(318, 206), Vector2(318, 186), 2), 6.0, 2695)


# --- Mo: a classic friendly monster -----------------------------------------------------------

const MO_BLUE := Color("#7fc9f6")
const MO_SPOT := Color("#b394f2")
const MO_HORN := Color("#fff1b8")
const MO_TUFT := Color("#ff9fd2")
const MO_PAD := Color("#c6e9ff")

static func _mo_body(c: CanvasItem) -> void:
	var body := _fuzz(_squircle(Vector2(256, 262), Vector2(164, 152), 2.3, 2701, 44, 0.02), 18.0, 12.0, 2702)
	_fill(c, body, MO_BLUE, 2703)
	_spots(c, body, [[Vector2(132, 232), 25.0], [Vector2(176, 326), 21.0], [Vector2(118, 330), 14.0],
		[Vector2(204, 182), 17.0], [Vector2(240, 384), 16.0], [Vector2(160, 160), 11.0],
		[Vector2(246, 272), 12.0]], MO_SPOT, 2704)
	Crayon.marker_line(c, body, INK, W_BODY, 2730)


static func _mo_eye(c: CanvasItem) -> void:
	_eye(c, 2741, Vector2(62, 66), Color("#a6e36b"), 40.0, Vector2(20, 23), Vector2(6, 4))


static func _mo_mouth(c: CanvasItem) -> void:
	var half := Vector2(120, 92)
	var m := _mouth_shape(half, 0.25, 2751)
	_fill(c, m, MOUTH_IN, 2752, 18.0)
	var b := Crayon.bounds(m)
	_clip_fill(c, Crayon.blob(Vector2(O.x + 14, b.end.y - 30), Vector2(68, 42), 2753, 16, 0.05), m, TONGUE, 2754, 16.0)
	for s in [-1.0, 1.0]:
		var x: float = O.x + s * 62.0
		var fang := PackedVector2Array([Vector2(x - 21, b.position.y - 12), Vector2(x + 21, b.position.y - 12),
			Vector2(x + s * 2.0, b.position.y + 48)])
		_clip_fill(c, fang, m, PAPER, 2755 + int(s), 12.0, 6.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 2760)


static func _mo_horn(c: CanvasItem) -> void:
	var horn := _join(_bez(Vector2(222, 462), Vector2(218, 392), Vector2(238, 332), Vector2(290, 302), 8),
		_bez(Vector2(290, 302), Vector2(278, 346), Vector2(288, 410), Vector2(292, 462), 8))
	_fill(c, horn, MO_HORN, 2771, 14.0)
	for i in 2:
		var y := 420.0 - i * 44.0
		_ink_in(c, _seg(Vector2(200, y + 6), Vector2(320, y - 8), 4), horn, 5.0, 2772 + i)
	Crayon.marker_line(c, horn, INK, W_EAR, 2775)


## A fuzzy tuft: pointy strands fanning up from the dot.
static func _mo_hair(c: CanvasItem) -> void:
	var shapes := []
	for i in 5:
		var a := -PI * 0.5 - 0.16 + (i - 2) * 0.3
		var base := Vector2(296 + (i - 2) * 12, 440)
		var reach := 118.0 + 26.0 * (1.0 - absf(i - 2) / 2.0) + Crayon.noise(2781, i) * 8.0
		var tip := base + Vector2(cos(a), sin(a)) * reach
		var mid := base.lerp(tip, 0.55) + Vector2(cos(a - 0.6), sin(a - 0.6)) * 12.0
		shapes.append(_tube(_bez(base, base.lerp(mid, 0.6), mid, tip, 8), 26.0, 8.0))
	_part(c, _merge_all(shapes), MO_TUFT, 2782, W_FIN)


static func _mo_arm(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 86), Vector2(256, 130), Vector2(250, 164), Vector2(242, 196), 8)
	var arm := _fuzz(_tube(path, 16.0, 27.0), 15.0, 8.0, 2791)
	_fill(c, arm, MO_BLUE, 2792)
	_spots(c, arm, [[Vector2(240, 160), 10.0]], MO_SPOT, 2793)
	Crayon.marker_line(c, arm, INK, W_ARM, 2799)


static func _mo_hand(c: CanvasItem) -> void:
	var parts := [Crayon.blob(Vector2(256, 138), Vector2(64, 56), 2801, 18, 0.04)]
	var fingers := [[Vector2(224, 166), Vector2(216, 218)], [Vector2(256, 172), Vector2(256, 228)],
		[Vector2(288, 166), Vector2(296, 218)]]
	for f in fingers:
		parts.append(_tube(_seg(f[0], f[1], 4), 19.0, 18.0))
	parts.append(_tube(_seg(Vector2(306, 120), Vector2(344, 150), 4), 17.0, 16.0))
	var hand := _merge_all(parts)
	_fill(c, hand, MO_BLUE, 2802)
	for i in fingers.size():
		var tip: Vector2 = fingers[i][1]
		_clip_fill(c, Crayon.blob(tip + Vector2(0, 4), Vector2(14, 12), 2803 + i, 10, 0.05), hand, MO_PAD, 2806 + i, 8.0)
	Crayon.marker_line(c, hand, INK, W_HAND, 2810)


static func _mo_leg(c: CanvasItem) -> void:
	var leg := _fuzz(_tube(_seg(Vector2(256, 64), Vector2(256, 140), 6), 42.0, 40.0), 16.0, 9.0, 2821)
	_part(c, leg, MO_BLUE, 2822)


static func _mo_foot(c: CanvasItem) -> void:
	var ankle := Crayon.rounded_rect(Rect2(98, 116, 184, 84), 30.0)
	var pad := Crayon.blob(Vector2(240, 204), Vector2(124, 48), 2831, 18, 0.03)
	var toes := []
	var tips := [Vector2(360, 186), Vector2(376, 216), Vector2(356, 244)]
	for t in tips:
		toes.append(Crayon.blob(t, Vector2(30, 26), 2832, 12, 0.04))
	var foot := _merge_all([ankle, pad] + toes)
	_fill(c, foot, MO_BLUE, 2833)
	_spots(c, foot, [[Vector2(170, 160), 14.0]], MO_SPOT, 2834)
	Crayon.marker_line(c, foot, INK, W_FOOT, 2840)
	for i in tips.size():
		var tip: Vector2 = tips[i]
		_part(c, Crayon.blob(tip + Vector2(22, 0), Vector2(12, 9), 2841 + i, 10, 0.05), MO_HORN, 2845 + i * 2, 6.0, 8.0)
