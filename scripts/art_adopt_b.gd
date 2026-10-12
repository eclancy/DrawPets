class_name ArtAdoptB
extends RefCounted
## Fliers - pets a kid can meet and adopt in the shop's Adopt tab. Drawn as if OTHER KIDS
## drew them, in marker with black outlines, part by part, exactly the way the game asks a kid
## to draw, and assembled by the same PetBuilder.add_parts a kid's own pet goes through
## (Roster.assemble). Baked to res://art/adopt_b/ by tools/bake_art.gd; the assembled view is
## .shots/art_adopt_b_assembled.png.
##
## Style reference: scripts/art_rivals.gd - read it first. Marker fills on an opaque base, black
## (#1f1d24) marker outlines (creatures own black), a kid's wobble, simple patches and spots.
##
## Each part is drawn on the sheet a kid would get for it, starting from the same red dot, at
## the same zoom - PartTypes.TYPES[type]["dot"] and ["zoom"] (scripts/part_types.gd). The dot is
## the asset's pivot. Ids are "<creature>_<part key>"; a key like "claw_on_arm" is a claw drawn
## for an arm (drawn exactly like any other claw). The body has no dot (pivot "center").
##
## Every creature's face is its own: no shared eye or mouth drawing, and no shared neck. Eyes
## are drawn centred on their dot (they blink by squashing to 8% about it); mouths are drawn
## open, centred top-to-bottom on theirs (shown squashed to 14%); a head's neck - long, S-bent,
## short or none - is part of the head drawing from its dot. The ROSTER "layout" puts each face
## where that creature's own drawing has it.
##
## Faces follow the game's face convention (scripts/part_types.gd, above TYPES): Hoot, Blaze,
## Petal, Comet, Gizmo and Twinkle are turned three-quarters to the right, the way they walk -
## both eyes in the right-hand part of the head, the far one near the outline; the nose under
## them nearer the far eye (Blaze's and Petal's on a snout or muzzle poking out to the right);
## the mouth under the nose; the near ear, horn or antenna at the back-left, the far one behind
## the top right. Skye, Zephyr, Pelly and Ptera are drawn in true profile - a long snout or beak
## pointing right - and stay that way.

const INK := Color("#1f1d24")

## Hoot's eyes sit close together in its facial disc; the body draws the disc round them.
const HOOT_EYE_U := 0.75
const HOOT_EYE_V := 0.31
const HOOT_EYE_SPREAD := 0.115
## Its beak goes under the eyes, nearer the far (right) one - the face is turned to the right.
const HOOT_BEAK_U := 0.77

## Gizmo's nose, drawn by its body, and its mouth under it: between the eyes, nearer the far one.
const GIZMO_NOSE_U := 0.785


## Who they are and what they are made of. Names and parts are fixed (game code uses them); how
## each part looks is up to its drawing. "layout" moves parts off the spot every creature would
## otherwise share (PetBuilder.layout_on_host): anchors are fractions of the host's cropped ink
## box, matched to where each drawing puts its skull, snout or face.
const ROSTER := {
	"skye": {"name": "Skye", "look": "puffy pale-blue cloud whale with tiny wings and a tail fluke, no head",
		"parts": {"eye": 1, "mouth": 1, "wing": 2, "tail": 1},
		# a whale's face: the long mouth low along the front, the little eye low and back over
		# the end of it
		"layout": {"eye": {"anchor": [0.555, 0.575]}, "mouth": {"anchor": [0.76, 0.71]}}},
	"hoot": {"name": "Hoot", "look": "round brown owl, huge eyes, ear tufts, wings, two legs with claws, no separate head",
		"parts": {"eye": 2, "mouth": 1, "ear": 2, "wing": 2, "leg": 2, "claw": 3},
		# turned three-quarters to the right: eyes touching in the facial disc the body draws
		# round them, up in the right of the body with the far one near the outline; the beak
		# under them, nearer the far eye; an ear tuft at the back-left of the top and one peeking
		# up behind the top right
		"layout": {"eye": {"anchor": [HOOT_EYE_U, HOOT_EYE_V], "spread": HOOT_EYE_SPREAD},
			"mouth": {"anchor": [HOOT_BEAK_U, 0.46]},
			"ear": {"anchor": [HOOT_EYE_U - 0.17, 0.5], "far": [0.34, 0.0]}}},
	"zephyr": {"name": "Zephyr", "look": "teal dragonfly-lizard, four see-through wings, long tail",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "wing": 4, "leg": 4, "tail": 1},
		# no neck: the head pokes straight out of the front of the body, low; the bug eyes
		# bulge up off the top of the skull, nearly touching
		"layout": {"head": {"anchor": [0.95, 0.56], "edge": [1, 0]},
			"eye": {"anchor": [0.39, 0.5], "edge": [0, -1], "spread": 0.08},
			"mouth": {"anchor": [0.74, 0.76]}}},
	"blaze": {"name": "Blaze", "look": "baby red-orange dragon, horns, wings, back spikes, little clawed arms",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "horn": 2, "wing": 2, "spike": 3, "tail": 1, "leg": 2, "arm": 2, "claw_on_arm": 3},
		# the head is up at the top of its S-curve neck, turned three-quarters to the right: the
		# eyes either side of BLAZE_FACE, the grin along the snout (BLAZE_MOUTH), the near horn
		# at the back-left of the skull and the far one behind its top right
		"layout": {"eye": {"anchor": [0.532, 0.18], "spread": 0.104}, "mouth": {"anchor": [0.74, 0.36]},
			"horn": {"anchor": [0.18, 0.5], "far": [0.544, 0.0]}}},
	"petal": {"name": "Petal", "look": "kitten with butterfly wings",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "ear": 2, "wing": 2, "leg": 4, "tail": 1},
		# a round head straight up on a short neck at the front, turned three-quarters to the
		# right: the eyes either side of PETAL_FACE, the mouth under the nose on the muzzle
		# (PETAL_MOUTH), the near ear at the back-left of the head and the far one behind its top
		# right
		"layout": {"head": {"anchor": [0.84, 0.5]}, "eye": {"anchor": [0.578, 0.232], "spread": 0.104},
			"mouth": {"anchor": [0.737, 0.439]}, "ear": {"anchor": [0.235, 0.5], "far": [0.534, 0.0]}}},
	"comet": {"name": "Comet", "look": "a yellow star-shaped critter with antennae and tiny wings, no head",
		"parts": {"eye": 2, "mouth": 1, "antenna": 2, "wing": 2},
		# the face turned three-quarters to the right, in the front half of the star; an antenna
		# up out of each shoulder of the top point - the near one left of the eyes, the far one
		# right of them - and the little wings further back, clear of the near antenna
		"layout": {"eye": {"anchor": [0.68, 0.44], "spread": 0.09}, "mouth": {"anchor": [0.72, 0.62]},
			"antenna": {"anchor": [0.47, 0.5], "far": [0.34, 0.0]}, "wing": {"anchor": [0.36, 0.5]}}},
	"pelly": {"name": "Pelly", "look": "white pelican, giant pouchy beak as its mouth, webbed feet",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "wing": 2, "leg": 2, "foot": 1},
		# the head sits on top of its folded neck; the beak grows off the front of it
		"layout": {"head": {"anchor": [0.76, 0.5]}, "eye": {"anchor": [0.783, 0.296]},
			"mouth": {"anchor": [1.11, 0.382]}}},
	"gizmo": {"name": "Gizmo", "look": "little purple bat, enormous ears, leathery wings, no separate head",
		"parts": {"eye": 2, "mouth": 1, "ear": 2, "wing": 2, "leg": 2},
		# turned three-quarters to the right: eyes close together up in the right of the body,
		# the nose the body draws under them nearer the far eye (GIZMO_NOSE_U), the little mouth
		# under it, the near ear at the back-left of the top and the far one behind the top right
		"layout": {"eye": {"anchor": [0.75, 0.31], "spread": 0.075},
			"mouth": {"anchor": [GIZMO_NOSE_U, 0.53]}, "ear": {"anchor": [0.58, 0.5], "far": [0.34, 0.0]}}},
	"twinkle": {"name": "Twinkle", "look": "candy-pink fairy moth, fluffy hair tuft, four pastel wings",
		"parts": {"head": 1, "eye": 2, "mouth": 1, "antenna": 2, "hair": 1, "wing": 4, "leg": 2},
		# no neck - the head sits in its fluffy collar on the front of the body, turned
		# three-quarters to the right: the eyes either side of TWINKLE_FACE, the mouth under them
		# (TWINKLE_MOUTH), the near antenna just past the hair at the back-left and the far one
		# behind the top right
		"layout": {"head": {"anchor": [0.86, 0.5]}, "eye": {"anchor": [0.737, 0.333], "spread": 0.1},
			"mouth": {"anchor": [0.789, 0.556]}, "antenna": {"anchor": [0.507, 0.5], "far": [0.385, 0.0]}}},
	"ptera": {"name": "Ptera", "look": "pterodactyl, head crest, long beak, big leathery wings, clawed feet",
		"parts": {"head": 1, "eye": 1, "mouth": 1, "horn": 1, "wing": 2, "leg": 2, "claw": 3, "tail": 1},
		# drawn in profile: the long neck reaches forward off the front of the body; one eye, the
		# beak along the snout and the crest sweeping back off the back of the skull go on the
		# head at the end of it (a zero "far" keeps the lone crest on its anchor at the back of
		# the skull, not moved forward between where a pair would go)
		"layout": {"head": {"anchor": [0.92, 0.42], "edge": [1, 0]}, "eye": {"anchor": [0.762, 0.251]},
			"mouth": {"anchor": [1.044, 0.34]}, "horn": {"anchor": [0.575, 0.5], "far": [0.0, 0.0]}}},
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
		"skye_body": _skye_body(c)
		"skye_eye": _skye_eye(c)
		"skye_mouth": _skye_mouth(c)
		"skye_wing": _skye_wing(c)
		"skye_tail": _skye_tail(c)
		"hoot_body": _hoot_body(c)
		"hoot_eye": _hoot_eye(c)
		"hoot_mouth": _hoot_mouth(c)
		"hoot_ear": _hoot_ear(c)
		"hoot_wing": _hoot_wing(c)
		"hoot_leg": _hoot_leg(c)
		"hoot_claw": _hoot_claw(c)
		"zephyr_body": _zephyr_body(c)
		"zephyr_head": _zephyr_head(c)
		"zephyr_eye": _zephyr_eye(c)
		"zephyr_mouth": _zephyr_mouth(c)
		"zephyr_wing": _zephyr_wing(c)
		"zephyr_leg": _zephyr_leg(c)
		"zephyr_tail": _zephyr_tail(c)
		"blaze_body": _blaze_body(c)
		"blaze_head": _blaze_head(c)
		"blaze_eye": _blaze_eye(c)
		"blaze_mouth": _blaze_mouth(c)
		"blaze_horn": _blaze_horn(c)
		"blaze_wing": _blaze_wing(c)
		"blaze_spike": _blaze_spike(c)
		"blaze_tail": _blaze_tail(c)
		"blaze_leg": _blaze_leg(c)
		"blaze_arm": _blaze_arm(c)
		"blaze_claw_on_arm": _blaze_claw(c)
		"petal_body": _petal_body(c)
		"petal_head": _petal_head(c)
		"petal_eye": _petal_eye(c)
		"petal_mouth": _petal_mouth(c)
		"petal_ear": _petal_ear(c)
		"petal_wing": _petal_wing(c)
		"petal_leg": _petal_leg(c)
		"petal_tail": _petal_tail(c)
		"comet_body": _comet_body(c)
		"comet_eye": _comet_eye(c)
		"comet_mouth": _comet_mouth(c)
		"comet_antenna": _comet_antenna(c)
		"comet_wing": _comet_wing(c)
		"pelly_body": _pelly_body(c)
		"pelly_head": _pelly_head(c)
		"pelly_eye": _pelly_eye(c)
		"pelly_mouth": _pelly_mouth(c)
		"pelly_wing": _pelly_wing(c)
		"pelly_leg": _pelly_leg(c)
		"pelly_foot": _pelly_foot(c)
		"gizmo_body": _gizmo_body(c)
		"gizmo_eye": _gizmo_eye(c)
		"gizmo_mouth": _gizmo_mouth(c)
		"gizmo_ear": _gizmo_ear(c)
		"gizmo_wing": _gizmo_wing(c)
		"gizmo_leg": _gizmo_leg(c)
		"twinkle_body": _twinkle_body(c)
		"twinkle_head": _twinkle_head(c)
		"twinkle_eye": _twinkle_eye(c)
		"twinkle_mouth": _twinkle_mouth(c)
		"twinkle_antenna": _twinkle_antenna(c)
		"twinkle_hair": _twinkle_hair(c)
		"twinkle_wing": _twinkle_wing(c)
		"twinkle_leg": _twinkle_leg(c)
		"ptera_body": _ptera_body(c)
		"ptera_head": _ptera_head(c)
		"ptera_eye": _ptera_eye(c)
		"ptera_mouth": _ptera_mouth(c)
		"ptera_horn": _ptera_horn(c)
		"ptera_wing": _ptera_wing(c)
		"ptera_leg": _ptera_leg(c)
		"ptera_claw": _ptera_claw(c)
		"ptera_tail": _ptera_tail(c)


# --- Kid-drawing helpers (the same marker kit as art_rivals.gd) -------------------------------

const PAPER := Color("#fffdf8")
const MOUTH_IN := Color("#c9405e")
const TONGUE := Color("#ff92ab")
const O := Vector2(256, 256)   # the eye and mouth dot

# Line widths: about the same thickness once each sheet is shrunk by its zoom.
const W_BODY := 9.0    # zoom 1.0
const W_EYE := 15.0    # zoom 3.0
const W_MOUTH := 14.0  # zoom 2.5
const W_EAR := 13.0    # zoom 1.8 (ear, horn, foot)
const W_ANT := 12.0    # zoom 1.5 (antenna, spike)
const W_FIN := 11.0    # zoom 1.3 (hair)
const W_ARM := 10.0    # zoom 1.2
const W_CLAW := 15.0   # zoom 3.0


## Marker colour on white paper: an opaque paper-tinted base, then felt-tip streaks over it.
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


## A coloured marker stroke, only where it is inside `inside`.
static func _clip_line(c: CanvasItem, pts: PackedVector2Array, inside: PackedVector2Array,
		color: Color, width: float, seed: int) -> void:
	var k := 0
	for piece in Geometry2D.intersect_polyline_with_polygon(pts, inside):
		if piece.size() >= 2:
			Crayon.marker_line(c, piece, color, width, seed + k, false)
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


## Paths end to end, each one starting where the last stopped.
static func _join(paths: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in paths.size():
		var p: PackedVector2Array = paths[i]
		if i > 0 and p.size() > 0:
			p = p.slice(1)
		out.append_array(p)
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


## A lumpy ellipse turned to `angle`.
static func _rblob(center: Vector2, r: Vector2, angle: float, seed: int, count := 22,
		lumpy := 0.03) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in count:
		var a := TAU * i / count
		var k := 1.0 + Crayon.noise(seed, i) * lumpy
		pts.append(center + (Vector2(cos(a) * r.x, sin(a) * r.y) * k).rotated(angle))
	return pts


## An oval petal running from `root` to `tip`, `width` across.
static func _lobe(root: Vector2, tip: Vector2, width: float, seed: int) -> PackedVector2Array:
	return _rblob((root + tip) * 0.5, Vector2(root.distance_to(tip) * 0.5, width * 0.5),
		(tip - root).angle(), seed)


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


## A tapering stripe hanging down from `top`.
static func _stripe(x: float, top: float, length: float, w: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x - w, top), Vector2(x + w, top),
		Vector2(x + w * 0.6, top + length * 0.5), Vector2(x + w * 0.2, top + length),
		Vector2(x - w * 0.3, top + length), Vector2(x - w * 0.6, top + length * 0.5)])


## The ink box the baker will crop a drawing to, near enough (outline included).
static func _box(poly: PackedVector2Array, width: float) -> Rect2:
	return Crayon.bounds(poly).grow(width * 0.5 + 1.5)


## A closed outline as an open path that comes back to its start (for clipped lines).
static func _loop(poly: PackedVector2Array) -> PackedVector2Array:
	var out := poly.duplicate()
	out.append(poly[0])
	return out


## A little "v" or "u" mark, the way a kid draws feathers and fur.
static func _vee(at: Vector2, w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([at + Vector2(-w, -h), at + Vector2(0, h * 0.6), at + Vector2(w, -h)])


static func _cup(at: Vector2, w: float, h: float) -> PackedVector2Array:
	return _bez(at + Vector2(-w, -h * 0.4), at + Vector2(-w * 0.8, h), at + Vector2(w * 0.8, h),
		at + Vector2(w, -h * 0.4), 8)


## Points along part of an ellipse, from angle `a0` to `a1` (radians; y points down).
static func _arc(center: Vector2, r: Vector2, a0: float, a1: float, n := 10) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n + 1:
		var a := lerpf(a0, a1, i / float(n))
		out.append(center + Vector2(cos(a) * r.x, sin(a) * r.y))
	return out


## A four-pointed twinkle, the way a kid draws a sparkle.
static func _sparkle(at: Vector2, s: float, seed: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in 8:
		var a := -PI * 0.5 + TAU * i / 8.0
		var r := s if i % 2 == 0 else s * 0.3
		out.append(at + Vector2(cos(a), sin(a)) * r * (1.0 + Crayon.noise(seed, i) * 0.05))
	return out


## A ring of flame tongues round `at`: `n` points between `r_in` and `r_out`, every one licking a
## little clockwise.
static func _flames(at: Vector2, r_out: float, r_in: float, n: int, seed: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n * 2:
		var a := TAU * i / (n * 2.0) + (0.12 if i % 2 == 0 else 0.0)
		var r := (r_out if i % 2 == 0 else r_in) * (1.0 + Crayon.noise(seed, i) * 0.08)
		out.append(at + Vector2(cos(a), sin(a)) * r)
	return out


## One lash: a tapering black flick out from `root` along `dir`, bending by `bend` at its tip.
static func _lash(c: CanvasItem, root: Vector2, dir: Vector2, length: float, bend: Vector2,
		seed: int, w := 7.0) -> void:
	var tip := root + dir * length + bend
	var path := _bez(root - dir * 6.0, root + dir * length * 0.45, tip - dir * length * 0.2 + bend * 0.2, tip, 8)
	var lash := _tube(path, w, 1.6)
	c.draw_colored_polygon(lash, INK)
	Crayon.marker_line(c, lash, INK, 3.0, seed)


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


## A wing edge with feather bumps: `lead` runs root -> tip, `back` tip -> root, and each point
## of `back` is pushed out from `mid` in `bumps` scallops.
static func _feather_wing(lead: PackedVector2Array, back: PackedVector2Array, mid: Vector2,
		bumps: float, size: float) -> PackedVector2Array:
	var wing := PackedVector2Array()
	wing.append_array(lead)
	for i in range(1, back.size()):
		var p := back[i]
		var t := i / float(back.size() - 1)
		var bump := absf(sin(t * PI * bumps)) * size
		wing.append(p + (p - mid).normalized() * bump)
	return wing


## A bat or dragon wing growing up from its root: the arm runs up the front edge to the wrist,
## fingers fan out from the wrist to `tips`, and the skin sags in scallops between them.
static func _bat_wing(c: CanvasItem, root_r: Vector2, root_l: Vector2, wrist: Vector2,
		tips: Array, skin: Color, bone: Color, seed: int, sag := 0.3,
		thumb := PAPER) -> PackedVector2Array:
	var t0: Vector2 = tips[0]
	var arm := _bez(root_r, root_r.lerp(wrist, 0.4) + Vector2(16, 0), wrist + Vector2(14, 30), wrist, 8)
	var finger := _bez(wrist, wrist.lerp(t0, 0.35) + Vector2(6, -8), t0.lerp(wrist, 0.25), t0, 10)
	var paths := [arm, finger]
	var pts: Array = tips.duplicate()
	pts.append(root_l)
	for i in range(1, pts.size()):
		var a: Vector2 = pts[i - 1]
		var b: Vector2 = pts[i]
		var s := sag if i < pts.size() - 1 else sag * 0.6
		paths.append(_bez(a, a.lerp(wrist, s), b.lerp(wrist, s), b, 10))
	var wing := _join(paths)
	_fill(c, wing, skin, seed)
	# finger bones in a darker shade, then the arm bone along the front edge
	for i in range(1, tips.size()):
		var tip: Vector2 = tips[i]
		_clip_line(c, _seg(wrist, tip, 6), wing, bone, 8.0, seed + 10 + i)
	_clip_line(c, _join([arm, finger]), wing, bone, 10.0, seed + 20)
	Crayon.marker_line(c, wing, INK, W_BODY, seed + 1)
	# a little thumb claw at the wrist
	var d := (t0 - wrist).normalized()
	var claw := PackedVector2Array([wrist - d.orthogonal() * 10.0, wrist + d * 6.0 + d.orthogonal() * 4.0,
		wrist + Vector2(28, -22)])
	_part(c, claw, thumb, seed + 30, 6.0, 10.0)
	return wing


# --- Skye: puffy pale-blue cloud whale with tiny wings and a tail fluke, no head --------------

const SK_BLUE := Color("#b5d9ff")
const SK_DEEP := Color("#82b4ec")
const SK_BELLY := Color("#eef6ff")
const SK_WING := Color("#fbfcff")

static func _skye_body(c: CanvasItem) -> void:
	var shapes := [_egg(Vector2(262, 286), Vector2(194, 106), 0.42, 1001, 28, 0.03)]
	var puffs := [[Vector2(124, 242), 46.0], [Vector2(190, 204), 58.0], [Vector2(270, 186), 64.0],
		[Vector2(348, 204), 56.0]]
	for i in puffs.size():
		var at: Vector2 = puffs[i][0]
		var r: float = puffs[i][1]
		shapes.append(Crayon.blob(at, Vector2(r * 1.05, r), 1002 + i, 16, 0.05))
	var body := _merge_all(shapes)
	_fill(c, body, SK_BLUE, 1010)
	_clip_fill(c, Crayon.blob(Vector2(300, 386), Vector2(196, 62), 1011, 18, 0.04), body, SK_BELLY, 1012)
	for k in 3:
		var y := 348.0 + k * 15.0
		_clip_line(c, _bez(Vector2(236 + k * 16, y), Vector2(290, y + 6), Vector2(350, y + 6),
			Vector2(396 - k * 26, y - 4), 8), body, SK_DEEP, 5.0, 1013 + k)
	# a cloud curl on each puff
	for i in puffs.size():
		var at: Vector2 = puffs[i][0]
		var r: float = puffs[i][1]
		var curl := PackedVector2Array()
		for k in 10:
			var t := k / 9.0
			var a := PI * 1.05 + t * PI * 1.3
			curl.append(at + Vector2(4, 14) + Vector2(cos(a), sin(a)) * r * lerpf(0.5, 0.26, t))
		_clip_line(c, curl, body, SK_DEEP, 5.0, 1020 + i)
	Crayon.marker_line(c, body, INK, W_BODY, 1032)


## A whale's eye: small, a shiny dark bead in a pale rim with sky caught in the bottom of it, and
## one lash curling up and back. It sits low and back on the body (ROSTER layout).
static func _skye_eye(c: CanvasItem) -> void:
	var r := Vector2(64, 56)
	var rim := Crayon.blob(O, r, 1041, 20, 0.035)
	_fill(c, rim, Color("#e8f4ff"), 1042, 14.0)
	var bc := O + Vector2(7, 4)
	var bead := Crayon.blob(bc, Vector2(45, 41), 1043, 18, 0.04)
	c.draw_colored_polygon(bead, INK)
	_clip_line(c, _arc(bc, Vector2(32, 28), PI * 0.3, PI * 0.8, 8), bead, SK_DEEP, 9.0, 1044)
	_clip_line(c, _arc(bc, Vector2(29, 25), PI * 1.08, PI * 1.5, 8), bead, Color.WHITE, 11.0, 1045)
	c.draw_circle(bc + Vector2(18, -12), 6.0, Color.WHITE)
	Crayon.marker_line(c, rim, INK, W_EYE, 1046)
	var a := deg_to_rad(-138.0)
	_lash(c, O + Vector2(cos(a) * r.x, sin(a) * r.y), Vector2(cos(a), sin(a)).rotated(0.35), 44.0, Vector2(-22, 2), 1047, 12.0)


## A whale's long low smile, drawn open: it runs back along the front of the body and its back
## corner turns up in a dimple.
static func _skye_mouth(c: CanvasItem) -> void:
	var top := _bez(Vector2(424, 262), Vector2(330, 286), Vector2(190, 280), Vector2(104, 232), 16)
	var bottom := _bez(Vector2(104, 232), Vector2(150, 330), Vector2(320, 356), Vector2(424, 262), 16)
	var m := _join([top, bottom])
	_fill(c, m, MOUTH_IN, 1051, 18.0)
	_clip_fill(c, Crayon.blob(Vector2(272, 326), Vector2(84, 22), 1052, 16, 0.05), m, TONGUE, 1053, 14.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 1054)
	_ink(c, _bez(Vector2(106, 234), Vector2(88, 222), Vector2(84, 202), Vector2(98, 192), 5), 11.0, 1055)


static func _skye_wing(c: CanvasItem) -> void:
	var lead := _bez(Vector2(322, 450), Vector2(348, 388), Vector2(332, 304), Vector2(262, 262), 12)
	var back := _bez(Vector2(262, 262), Vector2(192, 272), Vector2(194, 392), Vector2(278, 450), 20)
	var wing := _feather_wing(lead, back, Vector2(292, 380), 3.0, 14.0)
	_fill(c, wing, SK_WING, 1061)
	for i in 2:
		var tip := Vector2(236 + i * 28, 314 + i * 32)
		_clip_line(c, _bez(Vector2(308, 440), Vector2(302, 410), tip + Vector2(14, 30), tip, 6), wing,
			SK_DEEP, 6.0, 1062 + i)
	Crayon.marker_line(c, wing, INK, W_BODY, 1066)


static func _skye_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(478, 262), Vector2(410, 274), Vector2(338, 262), Vector2(304, 212), 12)
	var e := path[path.size() - 1]
	var fluke_a := _lobe(e + Vector2(14, 8), e + Vector2(-112, -22), 68.0, 1071)
	var fluke_b := _lobe(e + Vector2(8, 14), e + Vector2(40, -112), 68.0, 1072)
	var tail := _merge_all([_tube(path, 48.0, 28.0), fluke_a, fluke_b])
	_fill(c, tail, SK_BLUE, 1073)
	_clip_fill(c, Crayon.blob(e + Vector2(-100, -22), Vector2(32, 28), 1074, 12, 0.1), tail, SK_DEEP, 1075, 12.0)
	_clip_fill(c, Crayon.blob(e + Vector2(38, -100), Vector2(28, 32), 1076, 12, 0.1), tail, SK_DEEP, 1077, 12.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 1078)


# --- Hoot: round brown owl, huge eyes, ear tufts, wings, two legs with claws, no head ---------

const H_BROWN := Color("#c8925f")
const H_DARK := Color("#9b6b44")
const H_CREAM := Color("#f8e7c9")
const H_FACE := Color("#f3d8b2")
const H_BEAK := Color("#ffbd45")
const H_TALON := Color("#ffc85a")
const H_NAIL := Color("#6c6678")

static func _hoot_body(c: CanvasItem) -> void:
	var body := _squircle(Vector2(256, 264), Vector2(166, 170), 2.5, 1101, 44, 0.025)
	_fill(c, body, H_BROWN, 1102)
	_clip_fill(c, Crayon.blob(Vector2(300, 356), Vector2(120, 96), 1103, 18, 0.05), body, H_CREAM, 1104)
	var marks := [Vector2(262, 336), Vector2(314, 330), Vector2(364, 340), Vector2(288, 374),
		Vector2(340, 378), Vector2(312, 412)]
	for i in marks.size():
		var at: Vector2 = marks[i]
		_clip_line(c, _vee(at, 13.0, 7.0), body, H_DARK, 5.0, 1105 + i)
	var back := [Vector2(130, 250), Vector2(118, 312), Vector2(166, 300), Vector2(150, 364),
		Vector2(200, 352), Vector2(186, 410)]
	for i in back.size():
		var at: Vector2 = back[i]
		_clip_line(c, _cup(at, 16.0, 12.0), body, H_DARK, 5.0, 1112 + i)
	# the pale facial disc the eyes sit in (at the ROSTER's eye anchor and spread), with a
	# feathery ruff round it and a dark line down the middle between the eyes
	var box := _box(body, W_BODY)
	var e1 := box.position + box.size * Vector2(HOOT_EYE_U - HOOT_EYE_SPREAD, HOOT_EYE_V)
	var e2 := box.position + box.size * Vector2(HOOT_EYE_U + HOOT_EYE_SPREAD, HOOT_EYE_V)
	var face := _merge_all([_squircle(e1, Vector2(60, 62), 2.0, 1120, 30, 0.03, 0.07),
		_squircle(e2, Vector2(60, 62), 2.0, 1121, 30, 0.03, 0.07),
		_squircle((e1 + e2) * 0.5 + Vector2(0, 50), Vector2(58, 42), 2.0, 1122, 24, 0.03, 0.07)])
	_clip_fill(c, face, body, H_FACE, 1123, 14.0)
	_clip_line(c, _loop(face), body, H_DARK, 7.0, 1124)
	var mid := (e1 + e2) * 0.5
	var beak_x := box.position.x + box.size.x * HOOT_BEAK_U
	_clip_line(c, _bez(mid + Vector2(0, -60), mid + Vector2(-4, -30), mid + Vector2(4, -6), Vector2(beak_x, mid.y + 14.0), 6),
		face, H_DARK, 6.0, 1126)
	Crayon.marker_line(c, body, INK, W_BODY, 1125)


## An owl's eye: no white at all - a huge, thick orange ring round a big black pupil, and a
## feathery brown brow arching over the top.
static func _hoot_eye(c: CanvasItem) -> void:
	var brow := PackedVector2Array()
	var n := 10
	for i in n + 1:
		var a := deg_to_rad(lerpf(214.0, 326.0, i / float(n)))
		var rr := 156.0 if i % 2 == 0 else 134.0
		brow.append(O + Vector2(cos(a) * rr, sin(a) * rr * 0.92))
	for i in range(n, -1, -1):
		var a := deg_to_rad(lerpf(218.0, 322.0, i / float(n)))
		brow.append(O + Vector2(cos(a) * 110.0, sin(a) * 112.0))
	_part(c, brow, H_DARK, 1137, 10.0, 14.0)
	var ring := Crayon.blob(O, Vector2(110, 112), 1131, 28, 0.025)
	_fill(c, ring, Color("#ff9a1f"), 1132, 18.0)
	_clip_fill(c, Crayon.blob(O + Vector2(3, 3), Vector2(80, 82), 1133, 22, 0.03), ring, Color("#ffcf3a"), 1134, 14.0)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(4, 4), Vector2(55, 57), 1135, 20, 0.03), INK)
	c.draw_circle(O + Vector2(-14, -16), 16.0, Color.WHITE)
	Crayon.marker_line(c, ring, INK, W_EYE + 2.0, 1136)


static func _hoot_mouth(c: CanvasItem) -> void:
	var inside := PackedVector2Array([Vector2(200, 236), Vector2(330, 230), Vector2(300, 288),
		Vector2(206, 284)])
	_fill(c, inside, MOUTH_IN, 1141, 14.0)
	var lower := PackedVector2Array([Vector2(196, 262), Vector2(250, 266), Vector2(300, 276),
		Vector2(318, 290), Vector2(284, 312), Vector2(228, 318), Vector2(200, 304)])
	var upper := PackedVector2Array([Vector2(190, 214), Vector2(236, 194), Vector2(290, 196),
		Vector2(334, 218), Vector2(360, 252), Vector2(352, 286), Vector2(334, 256),
		Vector2(290, 244), Vector2(240, 246), Vector2(196, 250)])
	_part(c, lower, H_BEAK.darkened(0.08), 1142, W_MOUTH, 16.0)
	_part(c, upper, H_BEAK, 1144, W_MOUTH, 16.0)
	c.draw_circle(Vector2(262, 214), 6.0, INK)


static func _hoot_ear(c: CanvasItem) -> void:
	var tuft := PackedVector2Array([Vector2(208, 456), Vector2(212, 404), Vector2(222, 356),
		Vector2(214, 318), Vector2(246, 344), Vector2(262, 304), Vector2(258, 272),
		Vector2(290, 312), Vector2(304, 366), Vector2(308, 456)])
	_fill(c, tuft, H_BROWN, 1151)
	var inner := PackedVector2Array([Vector2(238, 460), Vector2(250, 384), Vector2(266, 330),
		Vector2(280, 384), Vector2(284, 460)])
	_clip_fill(c, inner, tuft, H_DARK, 1152, 12.0)
	Crayon.marker_line(c, tuft, INK, W_EAR, 1153)


static func _hoot_wing(c: CanvasItem) -> void:
	var lead := _bez(Vector2(318, 452), Vector2(334, 404), Vector2(290, 330), Vector2(190, 296), 14)
	var back := _bez(Vector2(190, 296), Vector2(130, 322), Vector2(160, 424), Vector2(268, 452), 22)
	var wing := _feather_wing(lead, back, Vector2(250, 400), 3.0, 13.0)
	_fill(c, wing, H_DARK, 1161)
	var spots := [Vector2(236, 332), Vector2(270, 360), Vector2(200, 352), Vector2(236, 388),
		Vector2(292, 404)]
	for i in spots.size():
		var at: Vector2 = spots[i]
		_clip_fill(c, Crayon.blob(at, Vector2(14, 9), 1162 + i, 10, 0.1), wing, H_CREAM, 1170 + i, 10.0)
	for i in 3:
		var tip := Vector2(160 + i * 26, 360 + i * 28)
		_clip_line(c, _bez(Vector2(296, 444), Vector2(286, 426), tip + Vector2(36, 12), tip, 6), wing,
			INK, 4.0, 1178 + i)
	Crayon.marker_line(c, wing, INK, W_BODY, 1182)


static func _hoot_leg(c: CanvasItem) -> void:
	var leg := _squircle(Vector2(256, 110), Vector2(42, 58), 3.0, 1191, 28, 0.03)
	_fill(c, leg, H_CREAM, 1192)
	var marks := [Vector2(244, 92), Vector2(270, 116), Vector2(246, 144)]
	for i in marks.size():
		var at: Vector2 = marks[i]
		_clip_line(c, _vee(at, 10.0, 6.0), leg, H_DARK, 5.0, 1193 + i)
	Crayon.marker_line(c, leg, INK, W_BODY, 1197)


static func _hoot_claw(c: CanvasItem) -> void:
	_part(c, _talon(Vector2(258, 176), 1.0), H_NAIL, 1201, 11.0, 12.0)
	var toe := _tube(_seg(Vector2(256, 100), Vector2(258, 172), 5), 28.0, 26.0)
	_part(c, toe, H_TALON, 1203, W_CLAW)
	_ink(c, _seg(Vector2(240, 140), Vector2(274, 142), 2), 5.0, 1205)


## A hooked claw tip curling forward (right) from the end of a toe at `at`.
static func _talon(at: Vector2, k: float) -> PackedVector2Array:
	var outer := _bez(at + Vector2(-26, -8) * k, at + Vector2(-26, 40) * k, at + Vector2(6, 74) * k,
		at + Vector2(48, 82) * k, 8)
	var inner := _bez(at + Vector2(48, 82) * k, at + Vector2(28, 58) * k, at + Vector2(24, 26) * k,
		at + Vector2(24, -8) * k, 8)
	return _join([outer, inner])


# --- Zephyr: teal dragonfly-lizard, four see-through wings, long tail ------------------------

const ZE_TEAL := Color("#5fd0c4")
const ZE_DARK := Color("#38a7a3")
const ZE_BELLY := Color("#d9f7e4")
const ZE_VEIN := Color("#62b8d4")
const ZE_EYE := Color("#b9e84a")
const ZE_EYE_DARK := Color("#86c43a")
const ZE_CELL := Color("#5e9a2a")

static func _zephyr_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 262), Vector2(206, 84), 0.3, 1301, 28, 0.03)
	_fill(c, body, ZE_TEAL, 1302)
	_clip_fill(c, Crayon.blob(Vector2(276, 332), Vector2(214, 40), 1303, 18, 0.04), body, ZE_BELLY, 1304)
	for i in 4:
		_clip_fill(c, _stripe(92.0 + i * 52.0, 164.0, 124.0, 12.0), body, ZE_DARK, 1305 + i, 10.0)
	var spots := [[Vector2(318, 220), 12.0], [Vector2(356, 246), 9.0], [Vector2(300, 262), 8.0]]
	for i in spots.size():
		var at: Vector2 = spots[i][0]
		var r: float = spots[i][1]
		_clip_fill(c, Crayon.blob(at, Vector2(r * 1.2, r), 1310 + i, 10, 0.15), body, ZE_DARK, 1314 + i, 8.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1318)


## No neck at all: a flat lizard head drawn straight over the dot and reaching forward, so it
## pokes out low from the front of the body (ROSTER layout).
static func _zephyr_head(c: CanvasItem) -> void:
	var skull := Crayon.blob(Vector2(250, 394), Vector2(80, 56), 1321, 20, 0.04)
	var snout := Crayon.blob(Vector2(334, 410), Vector2(80, 38), 1322, 16, 0.04)
	var head := _merge(skull, snout)
	_fill(c, head, ZE_TEAL, 1323)
	var dots := [Vector2(204, 384), Vector2(222, 412), Vector2(196, 418)]
	for i in dots.size():
		var at: Vector2 = dots[i]
		_clip_fill(c, Crayon.blob(at, Vector2(11, 9), 1324 + i, 10, 0.15), head, ZE_DARK, 1328 + i, 8.0)
	_clip_fill(c, Crayon.blob(Vector2(318, 444), Vector2(80, 14), 1332, 12, 0.08), head, ZE_BELLY, 1333, 10.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1334)
	c.draw_circle(Vector2(398, 396), 5.5, INK)


## A dragonfly's compound eye: a big glossy dome covered in little hexagon cells, no pupil at
## all. Two of them sit on top of the head, bulging up over it (ROSTER layout).
static func _zephyr_eye(c: CanvasItem) -> void:
	var dome := Crayon.blob(O, Vector2(86, 80), 1341, 28, 0.02)
	_fill(c, dome, ZE_EYE, 1342, 18.0)
	_clip_fill(c, Crayon.blob(O + Vector2(14, 56), Vector2(96, 46), 1343, 18, 0.04), dome, ZE_EYE_DARK, 1344, 14.0)
	var s := 25.0
	var h := s * sqrt(3.0)
	var k := 0
	for col in range(-5, 6):
		for row in range(-4, 5):
			var at := O + Vector2(col * s * 1.5, row * h + (h * 0.5 if absi(col) % 2 == 1 else 0.0))
			if at.distance_to(O) > 104.0:
				continue
			var hex := PackedVector2Array()
			for q in 7:
				hex.append(at + Vector2(cos(PI / 3.0 * q), sin(PI / 3.0 * q)) * s)
			_clip_line(c, hex, dome, ZE_CELL, 6.0, 13500 + k)
			k += 1
	_clip_fill(c, _rblob(O + Vector2(-28, -42), Vector2(34, 13), -0.45, 1345), dome, Color(1, 1, 1, 0.9), 1346, 10.0)
	c.draw_circle(O + Vector2(10, -56), 6.0, Color(1, 1, 1, 0.9))
	Crayon.marker_line(c, dome, INK, W_EYE, 1347)


## A lizard's thin smile, drawn open: long and narrow with its back corner turned up, and a
## little pink tongue flicking out of the front.
static func _zephyr_mouth(c: CanvasItem) -> void:
	var top := _bez(Vector2(372, 250), Vector2(300, 258), Vector2(196, 256), Vector2(140, 228), 14)
	var bottom := _bez(Vector2(140, 228), Vector2(176, 280), Vector2(300, 292), Vector2(372, 250), 14)
	var m := _join([top, bottom])
	_fill(c, m, MOUTH_IN, 1351, 18.0)
	var flick := _bez(Vector2(330, 264), Vector2(380, 264), Vector2(414, 252), Vector2(426, 224), 10)
	_part(c, _tube(flick, 11.0, 14.0), TONGUE, 1352, 7.0, 12.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 1354)
	_ink(c, _bez(Vector2(142, 230), Vector2(128, 222), Vector2(126, 208), Vector2(134, 200), 4), 10.0, 1355)


static func _zephyr_wing(c: CanvasItem) -> void:
	var path := _bez(Vector2(300, 448), Vector2(290, 372), Vector2(246, 252), Vector2(196, 150), 16)
	var tip := path[path.size() - 1]
	var dt := (path[path.size() - 1] - path[path.size() - 2]).normalized()
	var blade := _lobe(path[4], tip + dt * 22.0, 92.0, 1360)
	var wing := _merge(blade, _tube(path.slice(0, 7), 12.0, 16.0))
	c.draw_colored_polygon(wing, Color(0.88, 0.97, 1.0, 0.62))
	Crayon.marker_fill(c, wing, Color(0.72, 0.9, 1.0, 0.4), 1361, 20.0)
	_clip_line(c, path, wing, ZE_VEIN, 5.0, 1362)
	# side veins branching off towards the tip, like a leaf
	for k in 4:
		var i := 6 + k * 2
		var p := path[i]
		var d := (path[i + 1] - path[i - 1]).normalized()
		var n := d.orthogonal()
		for s in [-1.0, 1.0]:
			var end: Vector2 = p + n * s * 50.0 + d * 34.0
			_clip_line(c, _bez(p, p + d * 8.0 + n * s * 16.0, end - d * 10.0, end, 4), wing, ZE_VEIN, 3.5,
				1363 + k * 2 + int(s > 0.0))
	_clip_fill(c, Crayon.blob(tip - dt * 6.0 + dt.orthogonal() * 30.0, Vector2(14, 10), 1370, 10, 0.1),
		wing, ZE_DARK, 1371, 8.0)
	Crayon.marker_line(c, wing, INK, W_BODY, 1372)


static func _zephyr_leg(c: CanvasItem) -> void:
	var leg := _tube(_bez(Vector2(256, 64), Vector2(244, 118), Vector2(246, 160), Vector2(262, 194), 8), 22.0, 16.0)
	var foot := Crayon.blob(Vector2(276, 204), Vector2(28, 15), 1381, 12, 0.04)
	var shapes := [leg, foot]
	var tips := [Vector2(318, 194), Vector2(322, 220), Vector2(298, 232)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		shapes.append(_tube(_seg(Vector2(280, 206), tip, 4), 8.0, 9.0))
	var shape := _merge_all(shapes)
	_fill(c, shape, ZE_TEAL, 1382)
	_clip_fill(c, Crayon.blob(Vector2(244, 130), Vector2(11, 9), 1383, 10, 0.1), shape, ZE_DARK, 1384, 8.0)
	Crayon.marker_line(c, shape, INK, W_BODY, 1385)


static func _zephyr_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(482, 258), Vector2(380, 268), Vector2(230, 268), Vector2(130, 220), 22)
	var e := path[path.size() - 1]
	var d := (path[path.size() - 1] - path[path.size() - 2]).normalized()
	var fin_a := _lobe(e - d * 6.0, e + d.rotated(0.75) * 58.0, 30.0, 1391)
	var fin_b := _lobe(e - d * 6.0, e + d.rotated(-0.75) * 58.0, 30.0, 1392)
	var tail := _merge_all([_tube(path, 34.0, 12.0), fin_a, fin_b])
	_fill(c, tail, ZE_TEAL, 1393)
	for k in 6:
		_clip_fill(c, _band(path, 0.22 + k * 0.12, 50.0, 6.0), tail, ZE_DARK, 1394 + k, 10.0)
	_clip_fill(c, _merge(fin_a, fin_b), tail, ZE_DARK, 1401, 10.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 1402)


# --- Blaze: baby red-orange dragon, horns, wings, back spikes, little clawed arms ------------

const BL_RED := Color("#ff8656")
const BL_DARK := Color("#e8633d")
const BL_BELLY := Color("#ffd768")
const BL_HORN := Color("#fff0c2")
const BL_WING := Color("#ffbd59")
const BL_SPIKE := Color("#ffcf3f")

static func _blaze_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 262), Vector2(188, 126), 0.35, 1501, 28, 0.03)
	_fill(c, body, BL_RED, 1502)
	var belly := Crayon.blob(Vector2(320, 336), Vector2(118, 86), 1503, 18, 0.05)
	_clip_fill(c, belly, body, BL_BELLY, 1504)
	for k in 4:
		var y := 284.0 + k * 30.0
		_clip_line(c, _bez(Vector2(200, y - 8), Vector2(260, y + 6), Vector2(360, y + 6), Vector2(440, y - 12), 8),
			Geometry2D.intersect_polygons(belly, body)[0], BL_DARK, 5.0, 1505 + k)
	var spots := [[Vector2(140, 214), 14.0], [Vector2(196, 186), 18.0], [Vector2(118, 280), 11.0],
		[Vector2(176, 248), 10.0]]
	for i in spots.size():
		var at: Vector2 = spots[i][0]
		var r: float = spots[i][1]
		_clip_fill(c, Crayon.blob(at, Vector2(r * 1.2, r), 1510 + i, 10, 0.15), body, BL_DARK, 1515 + i, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1520)


## Blaze's face is turned three-quarters to the right, the way it walks (head sheet pixels): the
## middle between its eyes, set in the right-hand part of the head, and the grin along the snout
## that pokes out to the right of the skull, under the nostrils at its front. The ROSTER layout
## puts the eyes either side of BLAZE_FACE and the mouth on BLAZE_MOUTH.
const BLAZE_FACE := Vector2(288, 146)
const BLAZE_SNOUT := Vector2(342, 196)
const BLAZE_MOUTH := Vector2(340, 216)

## An S-curve neck: forward off the dot, back again, then up into a round head turned
## three-quarters to the right, its snout poking out in front, with yellow belly scales running
## up the front of the neck.
static func _blaze_head(c: CanvasItem) -> void:
	var low := _bez(Vector2(200, 420), Vector2(276, 398), Vector2(286, 336), Vector2(238, 306), 10)
	var high := _bez(Vector2(238, 306), Vector2(190, 276), Vector2(176, 226), Vector2(226, 192), 10)
	var path := _join([low, high])
	var neck := _tube(path, 40.0, 32.0)
	var skull := Crayon.blob(Vector2(262, 156), Vector2(84, 72), 1521, 20, 0.04)
	var snout := Crayon.blob(BLAZE_SNOUT, Vector2(58, 36), 1522, 16, 0.04)
	var head := _merge_all([neck, skull, snout])
	_fill(c, head, BL_RED, 1523)
	# belly scales up the front of the neck, stopping under the chin: a yellow strip with a line
	# across every so often
	var front := PackedVector2Array()
	for i in path.size():
		var d := (path[mini(i + 1, path.size() - 1)] - path[maxi(i - 1, 0)]).normalized()
		front.append(path[i] - d.orthogonal() * 22.0)
	var strip := _tube(front.slice(0, 16), 16.0, 13.0)
	_clip_fill(c, strip, head, BL_BELLY, 1524, 12.0)
	for k in 4:
		var i := 2 + k * 4
		var n := (front[i + 1] - front[i - 1]).normalized().orthogonal()
		_clip_line(c, _seg(front[i] + n * 20.0, front[i] - n * 20.0, 2), strip, BL_DARK, 5.0, 1525 + k)
	_clip_fill(c, Crayon.blob(Vector2(186, 270), Vector2(12, 10), 1528, 10, 0.12), head, BL_DARK, 1529, 8.0)
	_clip_fill(c, Crayon.blob(Vector2(236, 106), Vector2(12, 10), 1530, 10, 0.12), head, BL_DARK, 1531, 8.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1532)
	# two nostrils near the front of the snout - the far one smaller, right at its tip
	var sn := BLAZE_SNOUT
	c.draw_colored_polygon(_rblob(sn + Vector2(24, -16), Vector2(7, 5), 0.3, 1533, 10, 0.1), INK)
	c.draw_colored_polygon(_rblob(sn + Vector2(43, -13), Vector2(5, 4), 0.2, 1534, 10, 0.1), INK)


## A fiery dragon eye: a flame-coloured iris licking round a slit pupil, and a thick brow pulled
## down low and level across the top of the eye - determined.
static func _blaze_eye(c: CanvasItem) -> void:
	var white := Crayon.blob(O, Vector2(72, 68), 1541, 24, 0.035)
	c.draw_colored_polygon(white, PAPER)
	var ic := O + Vector2(8, 8)
	_clip_fill(c, _flames(ic, 58.0, 45.0, 9, 1542), white, Color("#ff5a24"), 1543, 14.0)
	_clip_fill(c, _flames(ic, 36.0, 26.0, 7, 1544), white, Color("#ffd23a"), 1545, 12.0)
	var slit := _join([_bez(ic + Vector2(0, -48), ic + Vector2(15, -20), ic + Vector2(15, 20), ic + Vector2(0, 50), 8),
		_bez(ic + Vector2(0, 50), ic + Vector2(-15, 20), ic + Vector2(-15, -20), ic + Vector2(0, -48), 8)])
	c.draw_colored_polygon(slit, INK)
	c.draw_circle(ic + Vector2(-18, 0), 7.5, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 1547)
	var brow := _tube(_bez(O + Vector2(-82, -46), O + Vector2(-34, -76), O + Vector2(34, -76), O + Vector2(82, -46), 10),
		16.0, 16.0)
	_part(c, brow, Color("#c94a2a"), 1549, 10.0, 12.0)


## A wide toothy grin, corners turned up: little teeth all along the top and two big fangs.
static func _blaze_mouth(c: CanvasItem) -> void:
	var top := _bez(Vector2(146, 228), Vector2(196, 254), Vector2(316, 254), Vector2(366, 228), 14)
	var bottom := _bez(Vector2(366, 228), Vector2(344, 302), Vector2(168, 302), Vector2(146, 228), 14)
	var m := _join([top, bottom])
	_fill(c, m, MOUTH_IN, 1551, 18.0)
	_clip_fill(c, Crayon.blob(Vector2(262, 290), Vector2(54, 18), 1552, 14, 0.05), m, TONGUE, 1553, 14.0)
	for k in 7:
		var at := top[1 + k * 2]
		var fang := k == 1 or k == 5
		var w := 15.0 if fang else 11.0
		var tooth := PackedVector2Array([at + Vector2(-w, -8), at + Vector2(w, -8),
			at + Vector2(1, 38.0 if fang else 16.0)])
		_clip_fill(c, tooth, m, PAPER, 1554 + k, 10.0, 5.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 1562)


static func _blaze_horn(c: CanvasItem) -> void:
	var left := _bez(Vector2(222, 458), Vector2(222, 400), Vector2(208, 352), Vector2(196, 316), 8)
	var right := _bez(Vector2(196, 316), Vector2(240, 342), Vector2(282, 392), Vector2(290, 458), 8)
	var horn := _join([left, right])
	_fill(c, horn, BL_HORN, 1561)
	for k in 2:
		var y := 420.0 - k * 44.0
		_clip_line(c, _bez(Vector2(196, y + 6), Vector2(230, y - 8), Vector2(260, y - 6), Vector2(300, y + 10), 6),
			horn, Color("#e8c98a"), 6.0, 1562 + k)
	Crayon.marker_line(c, horn, INK, W_EAR, 1565)


static func _blaze_wing(c: CanvasItem) -> void:
	_bat_wing(c, Vector2(322, 452), Vector2(272, 452), Vector2(298, 266),
		[Vector2(236, 196), Vector2(148, 236), Vector2(136, 322), Vector2(198, 404)],
		BL_WING, BL_RED, 1571, 0.3, BL_HORN)


static func _blaze_spike(c: CanvasItem) -> void:
	var left := _bez(Vector2(208, 460), Vector2(216, 412), Vector2(234, 372), Vector2(252, 338), 6)
	var right := _bez(Vector2(252, 338), Vector2(274, 372), Vector2(296, 412), Vector2(304, 460), 6)
	_part(c, _join([left, right]), BL_SPIKE, 1581, W_ANT)


static func _blaze_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(480, 262), Vector2(380, 286), Vector2(250, 272), Vector2(150, 196), 18)
	var e := path[path.size() - 1]
	var d := (path[path.size() - 1] - path[path.size() - 2]).normalized()
	var n := d.orthogonal()
	var spade := PackedVector2Array([e - d * 12.0 + n * 38.0, e + d * 62.0, e - d * 12.0 - n * 38.0,
		e + d * 4.0])
	var tail := _merge(_tube(path, 46.0, 14.0), spade)
	_fill(c, tail, BL_RED, 1591)
	_clip_fill(c, PackedVector2Array([e - d * 4.0 + n * 60.0, e + d * 80.0, e - d * 4.0 - n * 60.0]),
		tail, BL_SPIKE, 1592, 12.0)
	for k in 3:
		var at := path[4 + k * 4]
		_clip_fill(c, Crayon.blob(at + Vector2(0, -16), Vector2(12, 9), 1593 + k, 10, 0.12), tail, BL_DARK,
			1597 + k, 8.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 1600)


static func _blaze_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 62), Vector2(258, 150), 6), 36.0, 34.0)
	var foot := Crayon.blob(Vector2(276, 176), Vector2(58, 32), 1601, 14, 0.04)
	var shape := _merge(leg, foot)
	_part(c, shape, BL_RED, 1602)
	_clip_fill(c, Crayon.blob(Vector2(244, 100), Vector2(12, 10), 1604, 10, 0.12), shape, BL_DARK, 1605, 8.0)
	for i in 3:
		var x := 300.0 + i * 14.0
		var y := 196.0 - i * 10.0
		var toe := PackedVector2Array([Vector2(x - 8, y - 8), Vector2(x + 10, y - 4), Vector2(x + 22, y + 10)])
		_part(c, toe, BL_HORN, 1606 + i * 2, 5.0, 8.0)


static func _blaze_arm(c: CanvasItem) -> void:
	var path := _bez(Vector2(256, 66), Vector2(248, 96), Vector2(252, 118), Vector2(262, 132), 8)
	var arm := _tube(path, 26.0, 22.0)
	var paw := Crayon.blob(Vector2(264, 142), Vector2(30, 24), 1611, 12, 0.04)
	var shape := _merge(arm, paw)
	_part(c, shape, BL_RED, 1612, W_ARM)


static func _blaze_claw(c: CanvasItem) -> void:
	var left := _bez(Vector2(232, 112), Vector2(232, 150), Vector2(242, 178), Vector2(266, 200), 6)
	var right := _bez(Vector2(266, 200), Vector2(270, 170), Vector2(278, 140), Vector2(280, 112), 6)
	_part(c, _join([left, right]), BL_HORN, 1621, W_CLAW, 12.0)


# --- Petal: kitten with butterfly wings -------------------------------------------------------

const PE_GREY := Color("#c9c7da")
const PE_DARK := Color("#a29fbf")
const PE_WHITE := Color("#fffaf3")
const PE_PINK := Color("#ffa6c2")
const PE_WING := Color("#ffa8d4")
const PE_WING2 := Color("#c3aef7")
const PE_DOT := Color("#ffe27a")

static func _petal_body(c: CanvasItem) -> void:
	var body := Crayon.blob(Vector2(256, 266), Vector2(198, 104), 1701, 22, 0.04)
	_fill(c, body, PE_GREY, 1702)
	_clip_fill(c, Crayon.blob(Vector2(404, 320), Vector2(72, 64), 1703, 14, 0.08), body, PE_WHITE, 1704)
	for i in 4:
		_clip_fill(c, _stripe(110.0 + i * 62.0, 150.0, 86.0, 14.0), body, PE_DARK, 1705 + i, 12.0)
	Crayon.marker_line(c, body, INK, W_BODY, 1710)


## Petal's face is turned three-quarters to the right, the way it walks (head sheet pixels):
## the middle between its eyes, set in the right-hand part of the round head; the nose under
## them, nearer the far eye, on a little muzzle that pokes out past the right cheek; and the
## mouth under the nose. The ROSTER layout puts the eyes either side of PETAL_FACE and the mouth
## on PETAL_MOUTH.
const PETAL_FACE := Vector2(294, 228)
const PETAL_NOSE := Vector2(330, 262)
const PETAL_MOUTH := Vector2(334, 292)

## A round head on a short, thick neck going straight up from the dot, with a pink collar and a
## little bell where the neck meets the head. Fur fluffs out of the back cheek; the front cheek
## is the muzzle.
static func _petal_head(c: CanvasItem) -> void:
	var ctr := Vector2(262, 254)
	var pts := PackedVector2Array()
	var n := 36
	for i in n:
		var a := TAU * i / n
		var deg := rad_to_deg(a)
		var k := 1.0 + Crayon.noise(1711, i) * 0.03
		if deg > 125.0 and deg < 165.0 and i % 2 == 0:
			k += 0.1
		pts.append(ctr + Vector2(cos(a) * 100.0, sin(a) * 90.0) * k)
	var neck_path := _seg(Vector2(206, 418), Vector2(222, 336), 6)
	var nose := PETAL_NOSE
	var muzzle := Crayon.blob(nose + Vector2(8, 22), Vector2(38, 26), 1716, 14, 0.04)
	var head := _merge_all([pts, _tube(neck_path, 42.0, 42.0), muzzle])
	_fill(c, head, PE_GREY, 1712)
	var f := PETAL_FACE
	for i in 3:
		_clip_fill(c, _stripe(f.x - 36.0 + i * 28.0, ctr.y - 96.0, 44.0 - absf(i - 1) * 12.0, 10.0),
			head, PE_DARK, 1713 + i, 10.0)
	var m := PETAL_MOUTH
	# a white muzzle under the eyes, poking out at the front, and a pink blush on the near cheek
	_clip_fill(c, Crayon.blob(nose + Vector2(6, 22), Vector2(40, 28), 1717, 14, 0.06), head, PE_WHITE, 1718)
	_clip_fill(c, Crayon.blob(Vector2(f.x - 28.0, m.y - 22.0), Vector2(18, 11), 1719, 10, 0.08), head,
		PE_PINK, 1720, 10.0)
	var collar := _band(neck_path, 0.62, 48.0, 11.0)
	_clip_fill(c, collar, head, Color("#ff7fb0"), 1735, 12.0)
	Crayon.marker_line(c, head, INK, W_BODY, 1721)
	_clip_line(c, _loop(collar), head, INK, 5.0, 1736)
	var bell := Crayon.blob(Vector2(250, 384), Vector2(15, 14), 1737, 12, 0.06)
	_part(c, bell, Color("#ffd84a"), 1738, 5.0, 8.0)
	_ink(c, _seg(Vector2(250, 384), Vector2(250, 396), 1), 4.0, 1740)
	# the nose, pointing down, with a line down to the mouth
	var tri := PackedVector2Array([nose + Vector2(-11, -6), nose + Vector2(13, -7), nose + Vector2(2, 6)])
	_part(c, tri, PE_PINK, 1722, 5.0, 8.0)
	_ink(c, _seg(nose + Vector2(2, 6), Vector2(m.x - 2.0, m.y - 6.0), 2), 4.0, 1723)
	# whiskers across the near cheek, and shorter ones poking out past the front of the muzzle
	for i in 2:
		var y := m.y - 20.0 + i * 13.0
		_ink(c, _seg(Vector2(m.x - 34.0, y), Vector2(m.x - 86.0, y - 8.0 + i * 13.0), 3), 4.0, 1724 + i)
		_ink(c, _seg(Vector2(m.x + 36.0, y - 2.0), Vector2(m.x + 64.0, y - 8.0 + i * 11.0), 2), 4.0, 1726 + i)


## Big sparkly eyes: a tall eye nearly all iris, deep blue fading to sky at the bottom, and
## four-pointed sparkles for glints.
static func _petal_eye(c: CanvasItem) -> void:
	var white := Crayon.blob(O, Vector2(60, 76), 1731, 24, 0.03)
	c.draw_colored_polygon(white, PAPER)
	var ic := O + Vector2(6, 6)
	var iris := Crayon.blob(ic, Vector2(48, 62), 1732, 20, 0.03)
	_clip_fill(c, iris, white, Color("#4f72e0"), 1733, 14.0)
	_clip_fill(c, Crayon.blob(ic + Vector2(0, 46), Vector2(46, 30), 1734, 14, 0.05),
		Geometry2D.intersect_polygons(iris, white)[0], Color("#8fe0ff"), 1735, 12.0)
	c.draw_colored_polygon(Crayon.blob(ic + Vector2(0, -4), Vector2(27, 36), 1736, 16, 0.04), INK)
	c.draw_colored_polygon(_sparkle(ic + Vector2(-16, -24), 24.0, 1737), Color.WHITE)
	c.draw_colored_polygon(_sparkle(ic + Vector2(20, 26), 13.0, 1738), Color.WHITE)
	c.draw_circle(ic + Vector2(-22, 22), 4.0, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 1739)


## A tiny cat mouth, drawn open: its top lip is a "w" and one little fang pokes down.
static func _petal_mouth(c: CanvasItem) -> void:
	var lip := _join([_bez(Vector2(200, 240), Vector2(208, 260), Vector2(248, 260), Vector2(256, 242), 8),
		_bez(Vector2(256, 242), Vector2(264, 260), Vector2(304, 260), Vector2(312, 240), 8)])
	var m := _join([lip, _bez(Vector2(312, 240), Vector2(318, 296), Vector2(194, 296), Vector2(200, 240), 12)])
	_fill(c, m, MOUTH_IN, 1741, 14.0)
	_clip_fill(c, Crayon.blob(Vector2(256, 282), Vector2(32, 13), 1742, 12, 0.06), m, TONGUE, 1743, 12.0)
	var fang := PackedVector2Array([Vector2(276, 246), Vector2(296, 246), Vector2(288, 280)])
	_clip_fill(c, fang, m, PAPER, 1744, 10.0, 5.0)
	Crayon.marker_line(c, m, INK, 11.0, 1745)


static func _petal_ear(c: CanvasItem) -> void:
	var lead := _bez(Vector2(208, 452), Vector2(214, 392), Vector2(232, 332), Vector2(252, 292), 8)
	var trail := _bez(Vector2(252, 292), Vector2(278, 332), Vector2(300, 392), Vector2(306, 452), 8)
	var ear := _join([lead, trail])
	ear.append(Vector2(256, 462))
	_fill(c, ear, PE_GREY, 1751)
	var inner := PackedVector2Array([Vector2(232, 444), Vector2(256, 336), Vector2(282, 444)])
	_clip_fill(c, inner, ear, PE_PINK, 1752, 12.0)
	Crayon.marker_line(c, ear, INK, W_EAR, 1753)


static func _petal_wing(c: CanvasItem) -> void:
	var fore := _lobe(Vector2(306, 456), Vector2(180, 150), 190.0, 1761)
	var hind := _lobe(Vector2(300, 456), Vector2(146, 376), 112.0, 1762)
	var wing := _merge(fore, hind)
	_fill(c, wing, PE_WING, 1763)
	_clip_fill(c, hind, wing, PE_WING2, 1764)
	# a deeper pink rim round the top of the big wing
	_clip_fill(c, Crayon.blob(Vector2(184, 168), Vector2(80, 70), 1765, 14, 0.06), fore, Color("#ff86c0"), 1766)
	var spots := [[Vector2(196, 196), 24.0, PE_DOT], [Vector2(250, 268), 18.0, PE_DOT],
		[Vector2(214, 330), 14.0, Color.WHITE], [Vector2(196, 386), 16.0, PE_DOT]]
	for i in spots.size():
		var at: Vector2 = spots[i][0]
		var r: float = spots[i][1]
		var col: Color = spots[i][2]
		var dot := Crayon.blob(at, Vector2(r, r), 1767 + i, 12, 0.08)
		_part(c, dot, col, 1771 + i * 2, 5.0, 10.0)
	Crayon.marker_line(c, wing, INK, W_BODY, 1780)


static func _petal_leg(c: CanvasItem) -> void:
	var path := _seg(Vector2(256, 66), Vector2(256, 226), 8)
	var leg := _tube(path, 24.0, 22.0)
	_fill(c, leg, PE_GREY, 1781)
	_clip_fill(c, _band(path, 0.45, 40.0, 7.0), leg, PE_DARK, 1782, 10.0)
	Crayon.marker_line(c, leg, INK, W_BODY, 1783)
	var paw := Crayon.blob(Vector2(268, 236), Vector2(40, 25), 1784, 14, 0.05)
	_part(c, paw, PE_WHITE, 1785)
	_ink(c, _seg(Vector2(274, 224), Vector2(276, 246), 2), 5.0, 1787)
	_ink(c, _seg(Vector2(292, 226), Vector2(294, 246), 2), 5.0, 1788)


static func _petal_tail(c: CanvasItem) -> void:
	var low := _bez(Vector2(476, 262), Vector2(392, 270), Vector2(300, 262), Vector2(272, 176), 14)
	var high := _bez(Vector2(272, 176), Vector2(260, 116), Vector2(284, 74), Vector2(326, 80), 10)
	var path := _join([low, high])
	var tail := _tube(path, 22.0, 18.0)
	_fill(c, tail, PE_GREY, 1791)
	for k in 3:
		_clip_fill(c, _band(path, 0.32 + k * 0.17, 40.0, 8.0), tail, PE_DARK, 1792 + k, 10.0)
	_clip_fill(c, Crayon.blob(path[path.size() - 1], Vector2(32, 32), 1796, 12, 0.1), tail, PE_WHITE, 1797, 10.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 1798)


# --- Comet: a yellow star-shaped critter with antennae and tiny wings, no head ---------------

const CO_YEL := Color("#ffe25e")
const CO_ORANGE := Color("#ffad3b")
const CO_WING := Color("#e9ddff")

## A chubby star the way a kid draws one - not quite even. `angles` (degrees, clockwise from
## the top point) and `arms` (lengths) give each point; the dips between them sit at `r_in`.
static func _star_body(center: Vector2, angles: Array, arms: Array, r_in: float, seed: int,
		n := 100, sharp := 1.6) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var m := angles.size()
	var a0: float = angles[0]
	for i in n:
		var a := a0 + 360.0 * i / n
		var j := 0
		while j < m - 1 and a >= float(angles[j + 1]):
			j += 1
		var lo: float = angles[j]
		var hi: float = angles[j + 1] if j < m - 1 else a0 + 360.0
		var u := (a - lo) / (hi - lo)
		var k := pow((1.0 + cos(TAU * u)) * 0.5, sharp)
		var r_out: float = arms[j] if u < 0.5 else arms[(j + 1) % m]
		var r := lerpf(r_in, r_out, k) * (1.0 + Crayon.noise(seed, i) * 0.008)
		pts.append(center + Vector2(cos(deg_to_rad(a)), sin(deg_to_rad(a))) * r)
	return pts


static func _comet_body(c: CanvasItem) -> void:
	var ctr := Vector2(272, 262)
	# leaning back with its long back point streaming out behind, so the face sits on the
	# middle and the front point (where the eyes and mouth land)
	var body := _star_body(ctr, [-99.0, -33.0, 39.0, 111.0, 183.0], [212.0, 208.0, 202.0, 202.0, 262.0],
		134.0, 1801)
	_fill(c, body, CO_YEL, 1802)
	# the long back point streams like a comet's tail
	for i in 3:
		var y := 240.0 + i * 20.0
		_clip_line(c, _seg(Vector2(36 + i * 10, y), Vector2(150 - i * 8, y + 2 - i * 2), 4), body,
			CO_ORANGE, 6.0, 1803 + i)
	var freckles := [Vector2(220, 330), Vector2(190, 300), Vector2(236, 388), Vector2(196, 150)]
	for i in freckles.size():
		var at: Vector2 = freckles[i]
		_clip_fill(c, Crayon.star(at, 13.0, 1807 + i), body, CO_ORANGE, 1811 + i, 8.0)
	_clip_line(c, _bez(Vector2(150, 160), Vector2(170, 140), Vector2(196, 128), Vector2(214, 124), 6), body,
		Color(1, 1, 1, 0.85), 7.0, 1817)
	Crayon.marker_line(c, body, INK, W_BODY, 1818)


## A round white eye whose pupil is a chubby black star, with one glint on it. Comet's face sits
## in the front half of its star, turned a little to the right (ROSTER layout).
static func _comet_eye(c: CanvasItem) -> void:
	var white := Crayon.blob(O, Vector2(76, 80), 1821, 24, 0.035)
	c.draw_colored_polygon(white, PAPER)
	var pc := O + Vector2(4, 6)
	var star := PackedVector2Array()
	for i in 40:
		var a := -PI * 0.5 + TAU * i / 40.0
		var k := pow((1.0 + cos(a * 5.0 + PI * 2.5)) * 0.5, 1.4)
		star.append(pc + Vector2(cos(a), sin(a)) * lerpf(27.0, 60.0, k) * (1.0 + Crayon.noise(1822, i) * 0.02))
	c.draw_colored_polygon(star, INK)
	c.draw_circle(pc + Vector2(-10, -10), 9.0, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 1823)


## A big round "O" of wonder, drawn open: dark inside, a throat, a little tongue at the bottom.
static func _comet_mouth(c: CanvasItem) -> void:
	var m := Crayon.blob(O, Vector2(60, 70), 1831, 24, 0.03)
	_fill(c, m, MOUTH_IN, 1832, 16.0)
	c.draw_colored_polygon(Crayon.blob(O + Vector2(0, -10), Vector2(32, 34), 1833, 16, 0.05), Color("#9a2846"))
	_clip_fill(c, Crayon.blob(O + Vector2(2, 54), Vector2(42, 26), 1834, 14, 0.05), m, TONGUE, 1835, 12.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 1836)


static func _comet_antenna(c: CanvasItem) -> void:
	var stalk := _bez(Vector2(256, 456), Vector2(244, 390), Vector2(300, 352), Vector2(292, 296), 10)
	_ink(c, stalk, W_ANT, 1841)
	_part(c, Crayon.star(Vector2(292, 268), 46.0, 1842), CO_ORANGE, 1843, 10.0, 12.0)
	c.draw_circle(Vector2(282, 258), 6.0, Color(1, 1, 1, 0.85))


static func _comet_wing(c: CanvasItem) -> void:
	var lead := _bez(Vector2(318, 450), Vector2(328, 410), Vector2(280, 358), Vector2(200, 348), 10)
	var back := _bez(Vector2(200, 348), Vector2(160, 370), Vector2(190, 438), Vector2(276, 450), 16)
	var wing := _feather_wing(lead, back, Vector2(262, 410), 3.0, 10.0)
	_fill(c, wing, CO_WING, 1851)
	var sparks := [[Vector2(238, 386), 14.0], [Vector2(206, 412), 9.0], [Vector2(290, 424), 8.0]]
	for i in sparks.size():
		var at: Vector2 = sparks[i][0]
		var r: float = sparks[i][1]
		_clip_fill(c, Crayon.star(at, r, 1852 + i), wing, CO_YEL, 1856 + i, 8.0, 3.0)
	Crayon.marker_line(c, wing, INK, W_BODY, 1860)


# --- Pelly: white pelican, giant pouchy beak as its mouth, webbed feet ------------------------

const PL_WHITE := Color("#fbfaf6")
const PL_GREY := Color("#cfd6e2")
const PL_PEACH := Color("#ffdcc2")
const PL_BEAK := Color("#ffcf55")
const PL_POUCH := Color("#ffa36b")
const PL_FOOT := Color("#ff9d45")
const PL_TIP := Color("#a9b2c6")

static func _pelly_body(c: CanvasItem) -> void:
	var tips := [Vector2(48, 212), Vector2(34, 256), Vector2(52, 300)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		var f := _tube(_seg(Vector2(150, 258), tip, 8), 16.0, 24.0)
		_fill(c, f, PL_WHITE, 1901 + i * 3)
		_clip_fill(c, Crayon.blob(tip, Vector2(30, 26), 1902 + i * 3, 10, 0.1), f, PL_GREY, 1903 + i * 3, 10.0)
		Crayon.marker_line(c, f, INK, W_BODY, 1910 + i)
	var body := _egg(Vector2(276, 270), Vector2(180, 114), 0.45, 1911, 28, 0.03)
	_fill(c, body, PL_WHITE, 1912)
	_clip_fill(c, Crayon.blob(Vector2(400, 314), Vector2(78, 70), 1913, 16, 0.06), body, PL_PEACH, 1914)
	var marks := [Vector2(170, 240), Vector2(206, 272), Vector2(240, 236), Vector2(196, 316),
		Vector2(250, 300)]
	for i in marks.size():
		var at: Vector2 = marks[i]
		_clip_line(c, _cup(at, 15.0, 10.0), body, PL_GREY, 5.0, 1915 + i)
	Crayon.marker_line(c, body, INK, W_BODY, 1921)


## A pelican resting: a thick neck folded in a tight S - back off the dot, then forward under
## the head - so the big head sits low, tucked over its chest, with a scruffy crest at the back.
static func _pelly_head(c: CanvasItem) -> void:
	var low := _bez(Vector2(206, 424), Vector2(150, 408), Vector2(128, 356), Vector2(160, 322), 10)
	var high := _bez(Vector2(160, 322), Vector2(190, 292), Vector2(232, 296), Vector2(246, 262), 10)
	var neck := _tube(_join([low, high]), 46.0, 42.0)
	var ball := Crayon.blob(Vector2(264, 234), Vector2(88, 74), 1931, 20, 0.04)
	var shapes := [neck, ball]
	var wisps := [[Vector2(212, 176), Vector2(150, 150)], [Vector2(222, 168), Vector2(166, 124)],
		[Vector2(236, 164), Vector2(196, 118)]]
	for w in wisps:
		var root: Vector2 = w[0]
		var tip: Vector2 = w[1]
		shapes.append(_tube(_bez(root, root.lerp(tip, 0.4) + Vector2(0, -10), tip + Vector2(12, 6), tip, 8), 13.0, 5.0))
	var head := _merge_all(shapes)
	_fill(c, head, PL_WHITE, 1934)
	_clip_fill(c, Crayon.blob(Vector2(178, 146), Vector2(44, 30), 1932, 12, 0.08), head, Color("#fff0b0"), 1933, 10.0)
	_clip_fill(c, Crayon.blob(Vector2(246, 330), Vector2(50, 40), 1935, 12, 0.08), head, PL_PEACH, 1936, 12.0)
	var marks := [Vector2(140, 372), Vector2(166, 404), Vector2(146, 336)]
	for i in marks.size():
		var at: Vector2 = marks[i]
		_clip_line(c, _cup(at, 12.0, 8.0), head, PL_GREY, 5.0, 1937 + i)
	Crayon.marker_line(c, head, INK, W_BODY, 1941)


## A side eye: a small dark pupil in a pale yellow ring, slid to the front, with bare pink skin
## round it the way a real pelican has, and a heavy sleepy lid.
static func _pelly_eye(c: CanvasItem) -> void:
	var skin := Crayon.blob(O + Vector2(-6, 4), Vector2(86, 70), 1942, 20, 0.05)
	_fill(c, skin, Color("#ffc2b0"), 1943, 16.0)
	var ring := Crayon.blob(O, Vector2(52, 50), 1944, 20, 0.035)
	_fill(c, ring, Color("#fff2a8"), 1945, 14.0)
	var pc := O + Vector2(18, 8)
	c.draw_circle(pc, 15.0, INK)
	c.draw_circle(pc + Vector2(-5, -6), 4.5, Color.WHITE)
	var lid := PackedVector2Array([O + Vector2(-80, -80), O + Vector2(80, -80), O + Vector2(80, -12),
		O + Vector2(0, -6), O + Vector2(-80, -14)])
	_clip_fill(c, lid, ring, Color("#ffb19b"), 1946, 12.0)
	Crayon.marker_line(c, ring, INK, W_EYE, 1947)
	var lid_edge := _bez(O + Vector2(-50, -14), O + Vector2(-20, -4), O + Vector2(22, -4), O + Vector2(52, -12), 8)
	_ink(c, lid_edge, W_EYE, 1948)
	_ink(c, _bez(O + Vector2(-44, -30), O + Vector2(-14, -20), O + Vector2(16, -20), O + Vector2(44, -28), 8), 6.0, 1949)


static func _pelly_mouth(c: CanvasItem) -> void:
	var inside := PackedVector2Array([Vector2(150, 226), Vector2(466, 140), Vector2(466, 272),
		Vector2(300, 294), Vector2(150, 280)])
	_fill(c, inside, MOUTH_IN, 1951, 14.0)
	var tongue := Crayon.blob(Vector2(246, 266), Vector2(66, 16), 1952, 12, 0.06)
	_clip_fill(c, tongue, inside, TONGUE, 1953, 12.0)
	# the big stretchy pouch under the bottom beak
	var pouch := PackedVector2Array([Vector2(146, 262), Vector2(260, 270), Vector2(380, 270),
		Vector2(466, 262), Vector2(484, 272), Vector2(462, 310), Vector2(412, 362),
		Vector2(334, 394), Vector2(250, 390), Vector2(184, 356), Vector2(146, 306)])
	_fill(c, pouch, PL_POUCH, 1954)
	_clip_fill(c, PackedVector2Array([Vector2(130, 250), Vector2(500, 250), Vector2(500, 284),
		Vector2(130, 290)]), pouch, PL_BEAK.darkened(0.04), 1955, 12.0)
	for k in 2:
		var y := 322.0 + k * 26.0
		_clip_line(c, _bez(Vector2(190 + k * 30, y - 8), Vector2(260, y + 8), Vector2(340, y + 6),
			Vector2(420 - k * 40, y - 18), 8), pouch, Color("#ee7a4a"), 6.0, 1956 + k)
	Crayon.marker_line(c, pouch, INK, W_MOUTH, 1958)
	var upper := PackedVector2Array([Vector2(136, 184), Vector2(240, 162), Vector2(350, 138),
		Vector2(452, 116), Vector2(484, 120), Vector2(492, 146), Vector2(480, 168),
		Vector2(464, 156), Vector2(352, 184), Vector2(242, 212), Vector2(142, 240)])
	_part(c, upper, PL_BEAK, 1959, W_MOUTH, 16.0)
	_ink(c, _seg(Vector2(190, 192), Vector2(330, 162), 4), 5.0, 1961)


static func _pelly_wing(c: CanvasItem) -> void:
	var lead := _bez(Vector2(330, 452), Vector2(368, 380), Vector2(342, 252), Vector2(236, 168), 14)
	var back := _bez(Vector2(236, 168), Vector2(176, 218), Vector2(194, 380), Vector2(272, 452), 26)
	var wing := _feather_wing(lead, back, Vector2(290, 360), 5.0, 13.0)
	_fill(c, wing, PL_WHITE, 1971)
	_clip_fill(c, Crayon.blob(Vector2(218, 216), Vector2(74, 66), 1972, 14, 0.08), wing, PL_TIP, 1973)
	for i in 3:
		var tip := Vector2(200 + i * 18, 262 + i * 50)
		_clip_line(c, _bez(Vector2(306, 444), Vector2(296, 420), tip + Vector2(34, 20), tip, 6), wing,
			PL_GREY.darkened(0.15), 5.0, 1974 + i)
	Crayon.marker_line(c, wing, INK, W_BODY, 1978)


static func _pelly_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 60), Vector2(256, 150), 6), 13.0, 12.0)
	_part(c, leg, PL_FOOT, 1981)


static func _pelly_foot(c: CanvasItem) -> void:
	var hub := Vector2(206, 172)
	var tips := [Vector2(250, 276), Vector2(330, 270), Vector2(386, 214)]
	var ankle := _tube(_seg(Vector2(190, 120), hub, 3), 17.0, 18.0)
	var web := PackedVector2Array([hub + Vector2(-10, 6)])
	for i in tips.size():
		var tip: Vector2 = tips[i]
		web.append(tip)
		if i < tips.size() - 1:
			var nxt: Vector2 = tips[i + 1]
			web.append(tip.lerp(nxt, 0.5).lerp(hub, 0.18))
	web.append(hub + Vector2(12, -12))
	var shapes := [ankle, web]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		shapes.append(_tube(_seg(hub, tip, 4), 12.0, 11.0))
	var foot := _merge_all(shapes)
	_fill(c, foot, PL_FOOT, 1991)
	_clip_fill(c, web, foot, Color("#ffbe7a"), 1992, 14.0)
	for i in tips.size():
		var tip: Vector2 = tips[i]
		_clip_line(c, _seg(hub.lerp(tip, 0.2), hub.lerp(tip, 0.92), 4), foot, Color("#e8822e"), 6.0, 1993 + i)
	Crayon.marker_line(c, foot, INK, W_EAR, 1997)


# --- Gizmo: little purple bat, enormous ears, leathery wings, no separate head ---------------

const GZ_PURPLE := Color("#b59ae8")
const GZ_DARK := Color("#8f71d6")
const GZ_BELLY := Color("#e6dafc")
const GZ_PINK := Color("#ffb3d1")
const GZ_WING := Color("#a68de0")

static func _gizmo_body(c: CanvasItem) -> void:
	var ctr := Vector2(256, 264)
	var body := _squircle(ctr, Vector2(160, 150), 2.4, 2001, 56, 0.02, 0.04)
	_fill(c, body, GZ_PURPLE, 2002)
	_clip_fill(c, Crayon.blob(Vector2(306, 344), Vector2(100, 74), 2003, 16, 0.06), body, GZ_BELLY, 2004)
	for i in 8:
		var a := PI * 0.6 + i * 0.3 + Crayon.noise(2005, i) * 0.08
		var dir := Vector2(cos(a), sin(a))
		var at := ctr + Vector2(dir.x * 120.0, dir.y * 112.0)
		Crayon.line(c, at, at + dir * 20.0, GZ_DARK, 6.0, 2006 + i, 1.0)
	# a little squashed bat nose between the eyes, nearer the far one, over the mouth (ROSTER)
	var box := _box(body, W_BODY)
	var nose := box.position + box.size * Vector2(GIZMO_NOSE_U, 0.43)
	var snout := Crayon.blob(nose, Vector2(22, 14), 2015, 12, 0.06)
	_part(c, snout, GZ_PINK, 2016, 5.0, 10.0)
	c.draw_circle(nose + Vector2(-7, 1), 3.5, INK)
	c.draw_circle(nose + Vector2(8, 1), 3.5, INK)
	Crayon.marker_line(c, body, INK, W_BODY, 2017)


## A bat's eye: big, round and all black - no white at all - with one tiny glint and a dim
## purple shine along the bottom.
static func _gizmo_eye(c: CanvasItem) -> void:
	var ball := Crayon.blob(O, Vector2(60, 64), 2021, 24, 0.03)
	c.draw_colored_polygon(ball, INK)
	_clip_line(c, _arc(O, Vector2(42, 46), PI * 0.2, PI * 0.75, 8), ball, Color("#5d4a92"), 8.0, 2022)
	c.draw_circle(O + Vector2(-20, -24), 9.0, Color.WHITE)
	Crayon.marker_line(c, ball, INK, W_EYE, 2023)


## A little open mouth with two tiny fangs at the top, and no tongue showing.
static func _gizmo_mouth(c: CanvasItem) -> void:
	var m := _mouth_shape(Vector2(44, 34), 0.3, 2031)
	_fill(c, m, MOUTH_IN, 2032, 14.0)
	var b := Crayon.bounds(m)
	for s in [-1.0, 1.0]:
		var x: float = O.x + s * 20.0
		var fang := PackedVector2Array([Vector2(x - 11, b.position.y - 6), Vector2(x + 11, b.position.y - 6),
			Vector2(x, b.position.y + 28)])
		_clip_fill(c, fang, m, PAPER, 2033 + int(s), 10.0, 5.0)
	Crayon.marker_line(c, m, INK, W_MOUTH, 2036)


static func _gizmo_ear(c: CanvasItem) -> void:
	var lead := _bez(Vector2(196, 458), Vector2(190, 370), Vector2(214, 262), Vector2(262, 184), 10)
	var trail := _bez(Vector2(262, 184), Vector2(310, 250), Vector2(330, 360), Vector2(318, 458), 10)
	var ear := _join([lead, trail])
	_fill(c, ear, GZ_PURPLE, 2041)
	var in_l := _bez(Vector2(224, 450), Vector2(220, 380), Vector2(236, 300), Vector2(262, 246), 8)
	var in_r := _bez(Vector2(262, 246), Vector2(290, 296), Vector2(298, 380), Vector2(290, 450), 8)
	var inner := _join([in_l, in_r])
	_clip_fill(c, inner, ear, GZ_PINK, 2042, 14.0)
	for i in 2:
		var y := 330.0 + i * 50.0
		_clip_line(c, _bez(Vector2(236, y + 12), Vector2(248, y), Vector2(262, y - 2), Vector2(278, y + 6), 6),
			inner, Color("#e88ab3"), 5.0, 2043 + i)
	Crayon.marker_line(c, ear, INK, W_EAR, 2046)


static func _gizmo_wing(c: CanvasItem) -> void:
	_bat_wing(c, Vector2(318, 452), Vector2(262, 452), Vector2(262, 262),
		[Vector2(190, 168), Vector2(94, 222), Vector2(66, 322), Vector2(146, 410)],
		GZ_WING, GZ_DARK, 2051, 0.3)


static func _gizmo_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 60), Vector2(256, 124), 4), 15.0, 13.0)
	var foot := Crayon.blob(Vector2(268, 136), Vector2(26, 13), 2061, 12, 0.04)
	var shapes := [leg, foot]
	var tips := [Vector2(300, 128), Vector2(304, 144), Vector2(290, 154)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		shapes.append(_tube(_seg(Vector2(276, 138), tip, 3), 6.0, 6.0))
	_part(c, _merge_all(shapes), GZ_DARK, 2062)


# --- Twinkle: candy-pink fairy moth, fluffy hair tuft, four pastel wings ----------------------

const TW_PINK := Color("#ff9fcd")
const TW_LIGHT := Color("#ffd1e8")
const TW_FLUFF := Color("#fff3fa")
const TW_LILAC := Color("#c8b6ff")
const TW_MINT := Color("#b2efd4")
const TW_BUTTER := Color("#fff0a0")
const TW_SKY := Color("#a9dcff")
const TW_ORCHID := Color("#e08ae6")

static func _twinkle_body(c: CanvasItem) -> void:
	var ctr := Vector2(256, 266)
	var body := _squircle(ctr, Vector2(186, 110), 2.2, 2101, 52, 0.02, 0.045)
	_fill(c, body, TW_PINK, 2102)
	for i in 3:
		_clip_fill(c, _stripe(96.0 + i * 52.0, 140.0, 260.0, 14.0), body, TW_LIGHT, 2103 + i, 12.0)
	var ruff := _squircle(Vector2(404, 214), Vector2(76, 60), 2.0, 2107, 24, 0.03, 0.08)
	_clip_fill(c, ruff, body, TW_FLUFF, 2108)
	for i in 7:
		var a := PI * 0.75 + i * 0.3 + Crayon.noise(2109, i) * 0.08
		var dir := Vector2(cos(a), sin(a))
		var at := ctr + Vector2(dir.x * 150.0, dir.y * 82.0)
		Crayon.line(c, at, at + dir * 18.0, Color("#e57fb6"), 6.0, 2110 + i, 1.0)
	Crayon.marker_line(c, body, INK, W_BODY, 2118)


## Twinkle's face is turned three-quarters to the right, the way it flies (head sheet pixels):
## the middle between its eyes, set in the right-hand part of the round head, and the mouth under
## them, nearer the far eye. A blush goes on the near cheek, and a little one peeks round the far
## side. The ROSTER layout puts the eyes either side of TWINKLE_FACE and the mouth on
## TWINKLE_MOUTH.
const TWINKLE_FACE := Vector2(306, 298)
const TWINKLE_MOUTH := Vector2(320, 350)

## No neck: the round head sits straight on the dot, and a fluffy collar puffs out all round
## where it meets the body.
static func _twinkle_head(c: CanvasItem) -> void:
	var skull := _squircle(Vector2(262, 318), Vector2(100, 90), 2.1, 2121, 40, 0.02, 0.03)
	_fill(c, skull, TW_PINK, 2122)
	var f := TWINKLE_FACE
	_clip_fill(c, Crayon.blob(Vector2(f.x - 40.0, 340), Vector2(20, 13), 2123, 10, 0.08), skull,
		Color("#ff7fb5"), 2124, 10.0)
	_clip_fill(c, Crayon.blob(Vector2(f.x + 50.0, 336), Vector2(13, 11), 2125, 10, 0.08), skull,
		Color("#ff7fb5"), 2126, 10.0)
	Crayon.marker_line(c, skull, INK, W_BODY, 2127)
	var puffs := []
	for i in 7:
		var t := i / 6.0
		var at := Vector2(lerpf(150.0, 336.0, t), 404.0 + sin(t * PI) * 22.0 - t * 14.0)
		puffs.append(Crayon.blob(at, Vector2(34, 30), 2128 + i, 12, 0.08))
	var ruff := _merge_all(puffs)
	_fill(c, ruff, TW_FLUFF, 2136)
	for i in 3:
		var at := Vector2(194 + i * 58, 414 + (8 if i == 1 else 0))
		_clip_line(c, _arc(at, Vector2(12, 10), PI * 0.9, PI * 2.3, 8), ruff, Color("#f5b3d6"), 5.0, 2137 + i)
	Crayon.marker_line(c, ruff, INK, W_BODY, 2140)


## Big glossy dark eyes - deep plum, nearly black, with a shine across the top - and three long
## lashes sweeping up and out.
static func _twinkle_eye(c: CanvasItem) -> void:
	var r := Vector2(58, 70)
	var eye := Crayon.blob(O, r, 2131, 24, 0.03)
	c.draw_colored_polygon(eye, Color("#3b2156"))
	c.draw_colored_polygon(Crayon.blob(O + Vector2(4, 4), Vector2(34, 42), 2132, 16, 0.04), INK)
	_clip_fill(c, Crayon.blob(O + Vector2(0, 60), Vector2(50, 26), 2133, 14, 0.05), eye, Color("#9a6fd8"), 2134, 12.0)
	c.draw_colored_polygon(_rblob(O + Vector2(-18, -28), Vector2(20, 11), -0.6, 2135), Color.WHITE)
	c.draw_circle(O + Vector2(20, 22), 6.0, Color.WHITE)
	Crayon.marker_line(c, eye, INK, W_EYE, 2136)
	for i in 3:
		var a := deg_to_rad(-84.0 + i * 28.0)
		var out := Vector2(cos(a), sin(a))
		_lash(c, O + Vector2(cos(a) * r.x, sin(a) * r.y), out, 66.0 - i * 8.0, out.orthogonal() * -18.0 + Vector2(0, -8),
			2137 + i, 10.0)


## A tiny smile, drawn open, with a curl at its back corner.
static func _twinkle_mouth(c: CanvasItem) -> void:
	var top := _bez(Vector2(204, 238), Vector2(230, 252), Vector2(282, 252), Vector2(306, 238), 10)
	var bottom := _bez(Vector2(306, 238), Vector2(296, 292), Vector2(214, 292), Vector2(204, 238), 10)
	var m := _join([top, bottom])
	_fill(c, m, MOUTH_IN, 2142, 14.0)
	_clip_fill(c, Crayon.blob(O + Vector2(4, 24), Vector2(26, 12), 2143, 12, 0.06), m, TONGUE, 2144, 10.0)
	Crayon.marker_line(c, m, INK, 11.0, 2145)
	_ink(c, _bez(Vector2(206, 240), Vector2(184, 230), Vector2(178, 206), Vector2(196, 198), 8), 10.0, 2146)


static func _twinkle_antenna(c: CanvasItem) -> void:
	var stalk := _bez(Vector2(256, 456), Vector2(246, 392), Vector2(292, 344), Vector2(304, 262), 14)
	var vane := _tube(stalk.slice(5), 9.0, 28.0)
	_fill(c, vane, TW_ORCHID, 2151, 14.0)
	for i in range(6, 14):
		var p := stalk[i]
		var d := (stalk[i + 1] - stalk[i - 1]).normalized()
		var n := d.orthogonal()
		var w := lerpf(9.0, 28.0, (i - 5) / 9.0)
		_clip_line(c, _seg(p, p + n * w * 1.1 + d * 10.0, 2), vane, INK, 3.5, 2152 + i)
		_clip_line(c, _seg(p, p - n * w * 1.1 + d * 10.0, 2), vane, INK, 3.5, 2170 + i)
	_ink(c, stalk, 9.0, 2190)
	Crayon.marker_line(c, vane, INK, 8.0, 2191)


static func _twinkle_hair(c: CanvasItem) -> void:
	var puffs := [[Vector2(300, 386), 36.0], [Vector2(266, 350), 38.0], [Vector2(312, 328), 42.0],
		[Vector2(352, 360), 30.0], [Vector2(284, 298), 30.0]]
	var shapes := []
	for i in puffs.size():
		var at: Vector2 = puffs[i][0]
		var r: float = puffs[i][1]
		shapes.append(Crayon.blob(at, Vector2(r, r), 2201 + i, 14, 0.06))
	var tuft := _merge_all(shapes)
	_fill(c, tuft, TW_BUTTER, 2207)
	for i in 3:
		var at: Vector2 = puffs[i + 1][0]
		var curl := PackedVector2Array()
		for k in 10:
			var t := k / 9.0
			var a := PI * 0.9 + t * PI * 1.5
			curl.append(at + Vector2(cos(a), sin(a)) * lerpf(18.0, 6.0, t))
		_clip_line(c, curl, tuft, Color("#f2c24a"), 5.0, 2208 + i)
	Crayon.marker_line(c, tuft, INK, W_FIN, 2212)


static func _twinkle_wing(c: CanvasItem) -> void:
	var lead := _bez(Vector2(324, 452), Vector2(348, 396), Vector2(310, 296), Vector2(222, 254), 14)
	var back := _bez(Vector2(222, 254), Vector2(152, 252), Vector2(152, 384), Vector2(270, 452), 22)
	var wing := _join([lead, back])
	_fill(c, wing, TW_MINT, 2221)
	var shrunk := Geometry2D.offset_polygon(wing, -18.0)
	if not shrunk.is_empty():
		var inner: PackedVector2Array = shrunk[0]
		_fill(c, inner, TW_LILAC, 2222)
	var spot := Crayon.blob(Vector2(234, 320), Vector2(28, 28), 2223, 14, 0.06)
	_part(c, spot, TW_BUTTER, 2224, 5.0, 12.0)
	_part(c, Crayon.blob(Vector2(236, 322), Vector2(12, 12), 2226, 10, 0.08), Color("#ff9fcd"), 2227, 4.0, 10.0)
	var dots := [Vector2(290, 396), Vector2(222, 390), Vector2(288, 318)]
	for i in dots.size():
		var at: Vector2 = dots[i]
		_clip_fill(c, Crayon.blob(at, Vector2(13, 13), 2229 + i, 10, 0.08), wing, TW_SKY, 2233 + i, 8.0, 3.0)
	Crayon.marker_line(c, wing, INK, W_BODY, 2237)


static func _twinkle_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 60), Vector2(258, 196), 6), 13.0, 12.0)
	_part(c, leg, Color("#f08cc0"), 2241)
	var shoe := Crayon.blob(Vector2(272, 206), Vector2(34, 18), 2243, 14, 0.04)
	_part(c, shoe, TW_LILAC, 2244)
	for s in [-1.0, 1.0]:
		var loop := PackedVector2Array([Vector2(262, 192), Vector2(262 + s * 18.0, 180),
			Vector2(262 + s * 20.0, 196)])
		_part(c, loop, Color("#ff7fb5"), 2246 + int(s), 4.0, 8.0)


# --- Ptera: pterodactyl, head crest, long beak, big leathery wings, clawed feet ---------------

const PT_GREEN := Color("#a9d38c")
const PT_DARK := Color("#80b46a")
const PT_BELLY := Color("#eef4c6")
const PT_CREST := Color("#ff9e5c")
const PT_BEAK := Color("#ffd66e")
const PT_WING := Color("#ffc596")
const PT_BONE := Color("#e8925f")
const PT_NAIL := Color("#fff3d6")

static func _ptera_body(c: CanvasItem) -> void:
	var body := _egg(Vector2(256, 266), Vector2(180, 100), 0.45, 2301, 28, 0.03)
	_fill(c, body, PT_GREEN, 2302)
	_clip_fill(c, Crayon.blob(Vector2(300, 336), Vector2(150, 50), 2303, 16, 0.05), body, PT_BELLY, 2304)
	var spots := [[Vector2(150, 236), 13.0], [Vector2(206, 210), 16.0], [Vector2(266, 200), 12.0],
		[Vector2(236, 254), 10.0], [Vector2(120, 270), 9.0]]
	for i in spots.size():
		var at: Vector2 = spots[i][0]
		var r: float = spots[i][1]
		_clip_fill(c, Crayon.blob(at, Vector2(r * 1.2, r), 2305 + i, 10, 0.15), body, PT_DARK, 2311 + i, 10.0)
	Crayon.marker_line(c, body, INK, W_BODY, 2317)


## A long thin neck reaching diagonally FORWARD off the dot - out in front, not up - to a small
## head stretched out at the end of it.
static func _ptera_head(c: CanvasItem) -> void:
	var path := _bez(Vector2(200, 416), Vector2(262, 392), Vector2(316, 358), Vector2(366, 330), 14)
	var neck := _tube(path, 30.0, 22.0)
	var skull := Crayon.blob(Vector2(394, 312), Vector2(80, 56), 2321, 20, 0.04)
	var head := _merge(neck, skull)
	_fill(c, head, PT_GREEN, 2322)
	_clip_fill(c, _tube(_bez(Vector2(196, 446), Vector2(266, 424), Vector2(330, 384), Vector2(392, 362), 14), 14.0, 12.0),
		head, PT_BELLY, 2323, 12.0)
	var dots := [Vector2(250, 384), Vector2(296, 360), Vector2(380, 296), Vector2(214, 404)]
	for i in dots.size():
		var at: Vector2 = dots[i]
		_clip_fill(c, Crayon.blob(at, Vector2(10, 8), 2324 + i, 10, 0.15), head, PT_DARK, 2328 + i, 8.0)
	Crayon.marker_line(c, head, INK, W_BODY, 2333)


## A narrowed, sly eye: an almond squeezed thin from top and bottom, the pupil slid right to the
## front, and one brow cocked up at the back.
static func _ptera_eye(c: CanvasItem) -> void:
	var top := _bez(Vector2(186, 262), Vector2(214, 226), Vector2(290, 220), Vector2(330, 246), 10)
	var bottom := _bez(Vector2(330, 246), Vector2(298, 280), Vector2(222, 286), Vector2(186, 262), 10)
	var white := _join([top, bottom])
	c.draw_colored_polygon(white, PAPER)
	var ic := Vector2(292, 252)
	_clip_fill(c, Crayon.blob(ic, Vector2(30, 30), 2341, 14, 0.04), white, Color("#ffb04a"), 2342, 12.0)
	c.draw_colored_polygon(Crayon.blob(ic + Vector2(4, 0), Vector2(14, 15), 2343, 12, 0.05), INK)
	c.draw_circle(ic + Vector2(-4, -6), 4.5, Color.WHITE)
	Crayon.marker_line(c, white, INK, W_EYE, 2344)
	_ink(c, _bez(Vector2(180, 258), Vector2(214, 222), Vector2(292, 216), Vector2(338, 240), 10), W_EYE + 4.0, 2345)
	var brow := _join([_bez(Vector2(170, 214), Vector2(196, 160), Vector2(240, 152), Vector2(270, 176), 8),
		_bez(Vector2(270, 176), Vector2(296, 190), Vector2(318, 196), Vector2(338, 196), 6)])
	_part(c, _tube(brow, 13.0, 9.0), PT_DARK.darkened(0.2), 2346, 7.0, 10.0)


static func _ptera_mouth(c: CanvasItem) -> void:
	var inside := PackedVector2Array([Vector2(180, 246), Vector2(440, 228), Vector2(420, 282),
		Vector2(180, 278)])
	_fill(c, inside, MOUTH_IN, 2351, 14.0)
	_clip_fill(c, Crayon.blob(Vector2(250, 272), Vector2(60, 13), 2352, 12, 0.06), inside, TONGUE, 2353, 12.0)
	var lower := PackedVector2Array([Vector2(170, 264), Vector2(300, 270), Vector2(420, 282),
		Vector2(458, 292), Vector2(410, 306), Vector2(290, 316), Vector2(176, 320)])
	var upper := PackedVector2Array([Vector2(164, 190), Vector2(300, 204), Vector2(420, 220),
		Vector2(498, 238), Vector2(420, 244), Vector2(300, 248), Vector2(170, 252)])
	_part(c, lower, PT_BEAK.darkened(0.08), 2354, W_MOUTH, 16.0)
	_part(c, upper, PT_BEAK, 2356, W_MOUTH, 16.0)
	c.draw_circle(Vector2(232, 214), 6.0, INK)


static func _ptera_horn(c: CanvasItem) -> void:
	var front := _bez(Vector2(294, 458), Vector2(288, 390), Vector2(240, 322), Vector2(92, 262), 12)
	var back := _bez(Vector2(92, 262), Vector2(170, 326), Vector2(214, 384), Vector2(222, 458), 10)
	var crest := _join([front, back])
	_fill(c, crest, PT_CREST, 2361)
	_clip_line(c, _bez(Vector2(258, 450), Vector2(250, 390), Vector2(200, 330), Vector2(110, 270), 10), crest,
		Color("#ffd27a"), 9.0, 2362)
	Crayon.marker_line(c, crest, INK, W_EAR, 2363)


static func _ptera_wing(c: CanvasItem) -> void:
	_bat_wing(c, Vector2(330, 452), Vector2(206, 452), Vector2(318, 244),
		[Vector2(132, 52), Vector2(92, 250), Vector2(150, 384)], PT_WING, PT_BONE, 2371, 0.24, PT_NAIL)


static func _ptera_leg(c: CanvasItem) -> void:
	var leg := _tube(_seg(Vector2(256, 62), Vector2(258, 170), 6), 20.0, 17.0)
	var pad := Crayon.blob(Vector2(260, 182), Vector2(34, 18), 2381, 12, 0.04)
	var shape := _merge(leg, pad)
	_part(c, shape, PT_GREEN, 2382)
	_clip_fill(c, Crayon.blob(Vector2(250, 110), Vector2(9, 8), 2384, 10, 0.15), shape, PT_DARK, 2385, 8.0)


static func _ptera_claw(c: CanvasItem) -> void:
	_part(c, _talon(Vector2(258, 176), 1.15), PT_NAIL, 2391, 11.0, 12.0)
	var toe := _tube(_seg(Vector2(256, 100), Vector2(258, 172), 5), 26.0, 24.0)
	_part(c, toe, PT_GREEN, 2393, W_CLAW)


static func _ptera_tail(c: CanvasItem) -> void:
	var path := _bez(Vector2(478, 260), Vector2(340, 272), Vector2(220, 252), Vector2(130, 214), 18)
	var e := path[path.size() - 1]
	var d := (path[path.size() - 1] - path[path.size() - 2]).normalized()
	var n := d.orthogonal()
	var vane := PackedVector2Array([e + d * 52.0, e + n * 32.0 - d * 6.0, e - d * 30.0, e - n * 32.0 - d * 6.0])
	var tail := _merge(_tube(path, 24.0, 8.0), vane)
	_fill(c, tail, PT_GREEN, 2401)
	_clip_fill(c, Geometry2D.offset_polygon(vane, 4.0)[0], tail, PT_CREST, 2402, 12.0)
	Crayon.marker_line(c, tail, INK, W_BODY, 2403)
