class_name ArtThings
extends RefCounted
## The game's own drawings of things: furniture and scenery for places, toys, food, and
## competition props. Baked to res://art/things/ by tools/bake_art.gd.
##
## Every drawing is coloured pencil or marker (Crayon.pencil_* / Crayon.marker_*), outlined in
## a darker shade of its own colour - never black, which belongs to the kids' drawings - and
## no darker than about 30% value. Shop items marked shiny get their shine at runtime (Shiny);
## draw them in light, clean colours so the shine has something to work with.
##
## Sheet: 512 x 512, y down. Furniture stands on y = 470 ("bottom" pivot); everything else is
## centred on (256, 256). Wobble is hashed from fixed seeds - never randf().

const ASSETS := {
	# Furniture and scenery - free starter kit.
	"kit_bed": {"pivot": "bottom", "look": "oval pet bed, blue rim, pale pillow"},
	"kit_cushion": {"pivot": "bottom", "look": "round squashy floor cushion, pink, button in the middle"},
	"kit_doghouse": {"pivot": "bottom", "look": "wooden pet house, red roof, round door (pale lavender inside, never black)"},
	"kit_tree": {"pivot": "bottom", "look": "leafy round tree with a brown trunk"},
	"kit_bush": {"pivot": "bottom", "look": "round leafy bush, a couple of berries"},
	"kit_rock": {"pivot": "bottom", "look": "big flat-topped boulder, grey-lavender"},
	"kit_pond": {"pivot": "bottom", "look": "small oval pond seen from the side at an angle, ripples, reeds at one end"},
	"kit_trampoline": {"pivot": "bottom", "look": "round trampoline on short legs, side view, springs"},
	"kit_lamp": {"pivot": "bottom", "look": "standing lamp, warm yellow shade, glow"},
	"kit_campfire": {"pivot": "bottom", "look": "crossed logs, orange and yellow flames, ring of stones"},
	"kit_umbrella": {"pivot": "bottom", "look": "striped beach umbrella on a pole"},
	"kit_fence": {"pivot": "bottom", "look": "short white picket fence section"},
	"kit_flowerpot": {"pivot": "bottom", "look": "terracotta pot of flowers"},
	"kit_sign": {"pivot": "bottom", "look": "wooden signpost with a blank board"},
	"kit_slide": {"pivot": "bottom", "look": "small playground slide with a ladder"},
	"kit_tent": {"pivot": "bottom", "look": "triangle camping tent, flap open (inside pale, not black)"},
	"kit_hammock": {"pivot": "bottom", "look": "hammock slung between two posts"},
	"kit_snowman": {"pivot": "bottom", "look": "three-ball snowman, carrot nose, scarf"},
	"kit_scratch_post": {"pivot": "bottom", "look": "rope-wrapped post on a square base, dangling pom-pom"},
	"kit_drum": {"pivot": "bottom", "look": "toy drum with two drumsticks"},
	"kit_fruit_tree": {"pivot": "bottom", "look": "small tree with red apples"},
	"kit_toybox": {"pivot": "bottom", "look": "open wooden toy chest, a ball peeking out"},
	# Furniture - shop.
	"shop_throne": {"pivot": "bottom", "look": "fancy throne, gold frame (draw pale yellow), red cushion"},
	"shop_rainbow_slide": {"pivot": "bottom", "look": "big slide with rainbow stripes down it"},
	"shop_hot_tub": {"pivot": "bottom", "look": "round wooden hot tub, water, curls of steam"},
	"shop_treehouse": {"pivot": "bottom", "look": "little treehouse on a trunk with a rope ladder"},
	"shop_piano": {"pivot": "bottom", "look": "small upright piano, white and pale-grey keys"},
	"shop_castle_bed": {"pivot": "bottom", "look": "four-poster bed with tiny turret tops and a flag"},
	# Toys - free starter kit.
	"kit_ball": {"pivot": "center", "look": "red and white striped ball"},
	"kit_rope": {"pivot": "center", "look": "rope tug toy, two knots, blue and white twist"},
	"kit_frisbee": {"pivot": "center", "look": "orange flying disc seen at an angle"},
	"kit_stick": {"pivot": "center", "look": "a good stick, with a twig and a leaf"},
	"kit_duck": {"pivot": "center", "look": "yellow rubber squeaky duck"},
	"kit_teddy": {"pivot": "center", "look": "small soft brown teddy bear"},
	"kit_puzzle_ball": {"pivot": "center", "look": "green ball with holes and a treat peeking out"},
	# Toys - shop, shiny at runtime.
	"shiny_ball": {"pivot": "center", "look": "ball with a star on it (gold)"},
	"golden_bone": {"pivot": "center", "look": "chew bone (gold)"},
	"glitter_disc": {"pivot": "center", "look": "flying disc with swirls (glitter)"},
	"rainbow_rope": {"pivot": "center", "look": "rope tug toy, three knots, pale (rainbow)"},
	"crystal_squeaker": {"pivot": "center", "look": "duck made of facets, like a cut gem (silver)"},
	"star_plush": {"pivot": "center", "look": "puffy star plushie with a smile (gold)"},
	"puzzle_cube": {"pivot": "center", "look": "chunky puzzle cube, coloured squares (rainbow)"},
	"rocket_ball": {"pivot": "center", "look": "ball with fins and a flame stripe (gold)"},
	# Food - free starter kit.
	"kit_apple": {"pivot": "center", "look": "red apple, leaf"},
	"kit_bone": {"pivot": "center", "look": "meaty bone, pink meat on it"},
	"kit_fish": {"pivot": "center", "look": "blue-silver fish"},
	"kit_cake": {"pivot": "center", "look": "slice of layer cake, cherry on top"},
	"kit_carrot": {"pivot": "center", "look": "carrot with green leaves"},
	"kit_cookie": {"pivot": "center", "look": "round cookie, chocolate chips (brown, not black)"},
	"kit_bugs": {"pivot": "center", "look": "a leaf with three ladybugs and a beetle on it"},
	"kit_pizza": {"pivot": "center", "look": "slice of pizza, pepperoni"},
	"kit_icecream": {"pivot": "center", "look": "ice-cream cone, two scoops"},
	"kit_chili": {"pivot": "center", "look": "red chili pepper, little flame lines"},
	# Food - shop, shiny at runtime.
	"star_snack": {"pivot": "center", "look": "star-shaped cookie with icing (gold)"},
	# Competition props.
	"prop_finish": {"pivot": "bottom", "look": "finish-line arch, chequered banner in navy and white"},
	"prop_hurdle": {"pivot": "bottom", "look": "striped hurdle bar on two feet"},
	"prop_rope_long": {"pivot": "center", "look": "long tug-of-war rope, horizontal, red ribbon tied in the middle"},
	"prop_podium": {"pivot": "bottom", "look": "three-step podium marked 1 2 3 (2 left, 1 middle tallest, 3 right)"},
	"prop_cone": {"pivot": "bottom", "look": "orange traffic cone with a white stripe"},
	"prop_bunting": {"pivot": "center", "look": "string of triangle flags, many colours, wide and short"},
}

## The paper the pencil and marker sit on: fills get a solid, lighter coat of their colour
## underneath so nothing behind a thing shows through it in a place.
const PAPER := Color("#fffdf7")

## Hand-drawn numerals for the podium, in a unit box: [points, smoothing passes].
const DIGITS := {
	"1": [[Vector2(0.22, 0.3), Vector2(0.56, 0.06), Vector2(0.56, 0.95)], 0],
	"2": [[Vector2(0.14, 0.3), Vector2(0.24, 0.1), Vector2(0.5, 0.03), Vector2(0.78, 0.12),
		Vector2(0.82, 0.34), Vector2(0.62, 0.56), Vector2(0.14, 0.95), Vector2(0.9, 0.95)], 2],
	"3": [[Vector2(0.14, 0.14), Vector2(0.46, 0.02), Vector2(0.8, 0.14), Vector2(0.8, 0.32),
		Vector2(0.6, 0.47), Vector2(0.38, 0.49), Vector2(0.62, 0.5), Vector2(0.86, 0.66),
		Vector2(0.84, 0.86), Vector2(0.56, 0.98), Vector2(0.28, 0.97), Vector2(0.1, 0.86)], 2],
}


static func assets() -> Dictionary:
	return ASSETS


static func draw(id: String, c: CanvasItem) -> void:
	match id:
		"kit_bed":
			_bed(c)
		"kit_cushion":
			_cushion(c)
		"kit_doghouse":
			_doghouse(c)
		"kit_tree":
			_tree(c)
		"kit_bush":
			_bush(c)
		"kit_rock":
			_rock(c)
		"kit_pond":
			_pond(c)
		"kit_trampoline":
			_trampoline(c)
		"kit_lamp":
			_lamp(c)
		"kit_campfire":
			_campfire(c)
		"kit_umbrella":
			_umbrella(c)
		"kit_fence":
			_fence(c)
		"kit_flowerpot":
			_flowerpot(c)
		"kit_sign":
			_sign(c)
		"kit_slide":
			_slide(c)
		"kit_tent":
			_tent(c)
		"kit_hammock":
			_hammock(c)
		"kit_snowman":
			_snowman(c)
		"kit_scratch_post":
			_scratch_post(c)
		"kit_drum":
			_drum(c)
		"kit_fruit_tree":
			_fruit_tree(c)
		"kit_toybox":
			_toybox(c)
		"shop_throne":
			_throne(c)
		"shop_rainbow_slide":
			_rainbow_slide(c)
		"shop_hot_tub":
			_hot_tub(c)
		"shop_treehouse":
			_treehouse(c)
		"shop_piano":
			_piano(c)
		"shop_castle_bed":
			_castle_bed(c)
		"kit_ball":
			_ball(c)
		"kit_rope":
			_rope(c)
		"kit_frisbee":
			_frisbee(c)
		"kit_stick":
			_stick(c)
		"kit_duck":
			_duck(c)
		"kit_teddy":
			_teddy(c)
		"kit_puzzle_ball":
			_puzzle_ball(c)
		"shiny_ball":
			_shiny_ball(c)
		"golden_bone":
			_golden_bone(c)
		"glitter_disc":
			_glitter_disc(c)
		"rainbow_rope":
			_rainbow_rope(c)
		"crystal_squeaker":
			_crystal_squeaker(c)
		"star_plush":
			_star_plush(c)
		"puzzle_cube":
			_puzzle_cube(c)
		"rocket_ball":
			_rocket_ball(c)
		"kit_apple":
			_apple(c)
		"kit_bone":
			_meaty_bone(c)
		"kit_fish":
			_fish(c)
		"kit_cake":
			_cake(c)
		"kit_carrot":
			_carrot(c)
		"kit_cookie":
			_cookie(c)
		"kit_bugs":
			_bugs(c)
		"kit_pizza":
			_pizza(c)
		"kit_icecream":
			_icecream(c)
		"kit_chili":
			_chili(c)
		"star_snack":
			_star_snack(c)
		"prop_finish":
			_finish(c)
		"prop_hurdle":
			_hurdle(c)
		"prop_rope_long":
			_rope_long(c)
		"prop_podium":
			_podium(c)
		"prop_cone":
			_cone(c)
		"prop_bunting":
			_bunting(c)


# --- Examples of the house style -------------------------------------------------------------

## Pencil: an oval bed seen from the front - a padded base, the rim behind, a pale pillow.
## Back to front: what is furthest away is drawn first.
static func _bed(c: CanvasItem) -> void:
	_pen(c, Crayon.ellipse(Vector2(256, 392), Vector2(196, 66)), Color("#7fb2e5"), 11)
	_pen(c, Crayon.ellipse(Vector2(256, 396), Vector2(150, 38)), Color("#e8eefa"), 12)
	_pen(c, Crayon.rounded_rect(Rect2(62, 404, 388, 66), 30), Color("#5f97d1"), 13)


## Marker: a striped ball - white fill, a red band clipped to the ball, the outline, and a
## white shine mark.
static func _ball(c: CanvasItem) -> void:
	var circle := Crayon.ellipse(Vector2(256, 256), Vector2(150, 150), 48)
	_mfill(c, circle, Color("#f4f1ea"), 21)
	var band := Crayon.rounded_rect(Rect2(90, 215, 332, 82), 10)
	for piece in Geometry2D.intersect_polygons(band, circle):
		_mfill(c, piece, Color("#e5484d"), 22)
	Crayon.marker_line(c, circle, Color("#9c2f33"), 7.0, 23)
	c.draw_arc(Vector2(256, 256), 112.0, PI * 1.1, PI * 1.4, 12, Color(1, 1, 1, 0.9), 10.0, true)


# --- Brushes ---------------------------------------------------------------------------------
# Thin wrappers over Crayon that lay a solid, lighter coat of the colour under the strokes, so
# a thing is opaque in a place (a tree must hide what is behind it) but still reads as pencil
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


## A thick line as a polygon - logs, posts, sticks, ropes.
static func _band(points: PackedVector2Array, half: float, round_ends := true) -> PackedVector2Array:
	if points.size() == 2 and round_ends:
		return _capsule(points[0], points[1], half)
	var res := Geometry2D.offset_polyline(points, half, Geometry2D.JOIN_ROUND,
		Geometry2D.END_ROUND if round_ends else Geometry2D.END_BUTT)
	return _biggest(res)


## A straight band with properly round ends (offset_polyline's are square-ish when thin).
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


## Several overlapping shapes merged into one outline (a cloud of circles becomes a treetop).
## A shape that does not touch the outline so far waits for a later pass, so the order of the
## list does not matter as long as everything ends up connected.
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


## Bilinear point in a quad: a top-left, b top-right, cc bottom-right, d bottom-left.
static func _bil(a: Vector2, b: Vector2, cc: Vector2, d: Vector2, u: float, v: float) -> Vector2:
	return a.lerp(b, u).lerp(d.lerp(cc, u), v)


static func _cell(a: Vector2, b: Vector2, cc: Vector2, d: Vector2, u0: float, u1: float,
		v0: float, v1: float) -> PackedVector2Array:
	return _pv([_bil(a, b, cc, d, u0, v0), _bil(a, b, cc, d, u1, v0), _bil(a, b, cc, d, u1, v1),
		_bil(a, b, cc, d, u0, v1)])


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


## Dashed stitching round a closed shape.
static func _stitch(c: CanvasItem, poly: PackedVector2Array, color: Color, width: float,
		seed: int, dash := 12.0, gap := 9.0) -> void:
	var path := poly.duplicate()
	path.append(poly[0])
	var total := _path_len(path)
	var d := 0.0
	var i := 0
	while d < total - dash:
		_pline(c, _pv([_at(path, d), _at(path, d + dash * 0.5), _at(path, d + dash)]), color, width, seed + i)
		d += dash + gap
		i += 1


# --- Furniture and scenery -------------------------------------------------------------------

## Pencil: a squashy round floor cushion - puffy lumps, a piped seam, a button pulling the
## top in.
static func _cushion(c: CanvasItem) -> void:
	var pink := Color("#f3a2bf")
	var body := PackedVector2Array()
	for i in 60:
		var a := TAU * i / 60.0
		var k := 1.0 + 0.035 * cos(a * 6.0) + Crayon.noise(101, i) * 0.006
		body.append(Vector2(256, 380) + Vector2(cos(a) * 204, sin(a) * 86) * k)
	_pen(c, body, pink, 102, 5.5)
	_shade(c, body, pink, 103, Vector2(-20, -30), 0.18)
	_gleam(c, body, 104, Vector2(18, 22), 0.4)
	var seam := _arc(Vector2(256, 372), Vector2(200, 46), 0.06, PI - 0.06, 28)
	_pline(c, seam, Color("#fbd3e0"), 7.0, 105)
	_pline(c, _move(seam, Vector2(0, 4)), pink.darkened(0.3), 3.0, 106)
	var mid := Vector2(256, 330)
	var pucker := pink.darkened(0.3)
	for i in 6:
		var a := TAU * i / 6.0 + 0.25
		var dir := Vector2(cos(a), sin(a))
		var from := mid + dir * Vector2(30, 10)
		var to := mid + dir * Vector2(124, 34)
		_pline(c, _pv([from, from.lerp(to, 0.5) + Vector2(0, -4), to]), pucker, 3.5, 107 + i)
	var button := Crayon.ellipse(mid, Vector2(28, 17), 20)
	_mark(c, button, Color("#e7799f"), 120, 5.0)
	c.draw_circle(mid + Vector2(-8, 0), 3.5, PAPER)
	c.draw_circle(mid + Vector2(8, 0), 3.5, PAPER)


## Pencil walls, marker roof: a wooden pet house with a heart over a pale round doorway.
static func _doghouse(c: CanvasItem) -> void:
	var wood := Color("#e8b47b")
	var wall := _pv([Vector2(140, 470), Vector2(140, 288), Vector2(256, 182), Vector2(372, 288),
		Vector2(372, 470)])
	_pen(c, wall, wood, 201)
	_shade(c, wall, wood, 202, Vector2(-34, 0), 0.14)
	var grain := wood.darkened(0.3)
	for i in 4:
		var y := 326.0 + i * 38.0
		_pline(c, _pv([Vector2(146, y), Vector2(256, y + Crayon.noise(203, i) * 3.0), Vector2(366, y)]),
			grain, 3.0, 204 + i)
	var frame := PackedVector2Array([Vector2(194, 470)])
	for i in 17:
		var a := PI + PI * i / 16.0
		frame.append(Vector2(256, 384) + Vector2(cos(a), sin(a)) * 62.0)
	frame.append(Vector2(318, 470))
	_pen(c, frame, wood.darkened(0.12), 208, 4.5)
	var door := PackedVector2Array([Vector2(206, 470)])
	for i in 17:
		var a := PI + PI * i / 16.0
		door.append(Vector2(256, 384) + Vector2(cos(a), sin(a)) * 50.0)
	door.append(Vector2(306, 470))
	var inside := Color("#e2dcf2")
	_pen(c, door, inside, 209, 4.5)
	_shade(c, door, inside, 210, Vector2(0, 24), 0.12)
	_mark(c, Crayon.heart(Vector2(256, 258), 52.0), Color("#f093b2"), 211, 5.0)
	var roof := _pv([Vector2(256, 144), Vector2(418, 298), Vector2(394, 326), Vector2(256, 194),
		Vector2(118, 326), Vector2(94, 298)])
	_mark(c, roof, Color("#e8675f"), 212, 7.5)
	_pline(c, _pv([Vector2(118, 300), Vector2(256, 170), Vector2(394, 300)]), Color("#f39a90"), 4.0, 213)


## Pencil: a round, cloudy treetop on a sturdy trunk.
static func _tree(c: CanvasItem) -> void:
	var bark := Color("#c29169")
	var trunk := _smooth(_pv([Vector2(200, 470), Vector2(228, 446), Vector2(234, 360), Vector2(222, 300),
		Vector2(292, 300), Vector2(278, 360), Vector2(284, 446), Vector2(312, 470)]), 1)
	_pen(c, trunk, bark, 301)
	_shade(c, trunk, bark, 302, Vector2(-18, 0), 0.16)
	_pline(c, _pv([Vector2(250, 452), Vector2(246, 410), Vector2(252, 372)]), bark.darkened(0.3), 3.0, 303)
	_pline(c, _pv([Vector2(266, 440), Vector2(268, 404)]), bark.darkened(0.3), 3.0, 304)
	var leaf := Color("#8cc96c")
	var crown := _circles([Vector3(256, 182, 112), Vector3(166, 214, 84), Vector3(346, 214, 84),
		Vector3(198, 128, 78), Vector3(314, 128, 80), Vector3(256, 88, 70), Vector3(194, 282, 66),
		Vector3(318, 282, 66), Vector3(256, 292, 70)])
	_pen(c, crown, leaf, 305, 5.5)
	_shade(c, crown, leaf, 306, Vector2(-34, -30), 0.16)
	for i in 3:
		var at: Vector2 = [Vector2(196, 142), Vector2(286, 104), Vector2(150, 222)][i]
		Crayon.pencil_fill(c, Crayon.blob(at, Vector2(38, 28), 307 + i, 14, 0.1), Color("#d4ef9e"), 310 + i)
	_leaf_marks(c, [Vector2(232, 200), Vector2(330, 170), Vector2(180, 266), Vector2(300, 260),
		Vector2(250, 120), Vector2(380, 236), Vector2(130, 200)], leaf.darkened(0.3), 320)


## Little "u" strokes that read as clumps of leaves.
static func _leaf_marks(c: CanvasItem, spots: Array, color: Color, seed: int) -> void:
	for i in spots.size():
		var at: Vector2 = spots[i]
		var r := 14.0 + 4.0 * Crayon.noise(seed, i)
		_pline(c, _arc(at, Vector2(r, r * 0.8), 0.2, PI - 0.2, 6), color, 3.5, seed + i)


## Pencil: a wide leafy bush with a few marker berries.
static func _bush(c: CanvasItem) -> void:
	var leaf := Color("#7fc077")
	var blob := _circles([Vector3(256, 382, 94), Vector3(160, 404, 72), Vector3(352, 404, 72),
		Vector3(204, 338, 70), Vector3(310, 336, 74), Vector3(96, 434, 50), Vector3(416, 434, 50),
		Vector3(256, 316, 56)])
	var ground := _pv([Vector2(0, 0), Vector2(512, 0), Vector2(512, 470), Vector2(0, 470)])
	var bush := _biggest(Geometry2D.intersect_polygons(blob, ground))
	_pen(c, bush, leaf, 401, 5.5)
	_shade(c, bush, leaf, 402, Vector2(-30, -30), 0.16)
	Crayon.pencil_fill(c, Crayon.blob(Vector2(214, 330), Vector2(40, 26), 403, 14, 0.1), Color("#d0edaa"), 404)
	Crayon.pencil_fill(c, Crayon.blob(Vector2(312, 318), Vector2(34, 22), 405, 14, 0.1), Color("#d0edaa"), 406)
	_leaf_marks(c, [Vector2(150, 410), Vector2(260, 380), Vector2(360, 420), Vector2(206, 440),
		Vector2(300, 444)], leaf.darkened(0.3), 410)
	var berries := [Vector2(186, 368), Vector2(300, 352), Vector2(340, 408), Vector2(236, 424),
		Vector2(122, 430), Vector2(392, 446)]
	for i in berries.size():
		var at: Vector2 = berries[i]
		_mark(c, _circle(at, 14.0, 16), Color("#e65a6a"), 420 + i * 3, 4.0)
		c.draw_circle(at + Vector2(-4, -4), 3.5, Color(1, 1, 1, 0.85))


## Pencil: a big flat-topped boulder with a paler top and a crack.
static func _rock(c: CanvasItem) -> void:
	var stone := Color("#b9b3cf")
	var rock := _smooth(_pv([Vector2(66, 470), Vector2(80, 400), Vector2(112, 336), Vector2(166, 300),
		Vector2(260, 290), Vector2(354, 296), Vector2(406, 322), Vector2(432, 382), Vector2(448, 470)]), 2)
	_pen(c, rock, stone, 501, 5.5)
	var top := _smooth(_pv([Vector2(128, 330), Vector2(172, 304), Vector2(260, 296), Vector2(352, 302),
		Vector2(396, 326), Vector2(334, 350), Vector2(206, 352)]), 2)
	Crayon.pencil_fill(c, top, Color("#e2def0"), 502)
	_pline(c, _smooth(_pv([Vector2(122, 336), Vector2(206, 356), Vector2(334, 354), Vector2(402, 330)]), 2, false),
		stone.darkened(0.3), 3.5, 503)
	_shade(c, rock, stone, 504, Vector2(-40, -30), 0.18)
	_pline(c, _pv([Vector2(300, 372), Vector2(316, 398), Vector2(306, 422), Vector2(318, 446)]),
		stone.darkened(0.4), 3.5, 505)
	_pline(c, _pv([Vector2(150, 400), Vector2(170, 416)]), stone.darkened(0.4), 3.5, 506)
	_tuft(c, Vector2(92, 470), 507, 0.9)
	_tuft(c, Vector2(420, 470), 508, 0.8)


## Pencil: a small pond seen at an angle, ripples and a lily pad, reeds at one end.
static func _pond(c: CanvasItem) -> void:
	var bank := Crayon.blob(Vector2(256, 410), Vector2(222, 58), 601, 30, 0.02)
	_pen(c, bank, Color("#b6d98e"), 602, 5.0)
	var water := Crayon.blob(Vector2(250, 406), Vector2(190, 40), 603, 30, 0.02)
	var blue := Color("#8ccbea")
	_pen(c, water, blue, 604, 4.5)
	_shade(c, water, blue, 605, Vector2(0, 14), 0.15)
	var ripple := Color("#f2fbff")
	_pline(c, _arc(Vector2(190, 412), Vector2(52, 10), 0.3, PI - 0.3, 10), ripple, 4.0, 606)
	_pline(c, _arc(Vector2(190, 408), Vector2(26, 5), 0.3, PI - 0.3, 8), ripple, 3.5, 607)
	_pline(c, _arc(Vector2(250, 392), Vector2(30, 6), PI + 0.4, TAU - 0.4, 8), ripple, 3.5, 608)
	var pad := Crayon.ellipse(Vector2(316, 418), Vector2(36, 12), 24)
	var notch := _pv([Vector2(316, 418), Vector2(360, 404), Vector2(360, 420)])
	var lily := _biggest(Geometry2D.clip_polygons(pad, notch))
	_pen(c, lily, Color("#86c46e"), 609, 3.5)
	var petals := _union([Crayon.ellipse(Vector2(306, 410), Vector2(9, 6), 12),
		Crayon.ellipse(Vector2(318, 410), Vector2(9, 6), 12), Crayon.ellipse(Vector2(312, 403), Vector2(7, 7), 12)])
	_mark(c, petals, Color("#f4a6c4"), 610, 3.0)
	for i in 4:
		var stone_at: Vector2 = [Vector2(110, 446), Vector2(150, 458), Vector2(340, 460), Vector2(380, 452)][i]
		_pen(c, Crayon.blob(stone_at, Vector2(16, 10), 611 + i, 10, 0.1), Color("#c9c4dc"), 615 + i, 3.0)
	var reed := Color("#7fbb68")
	var stems := [[Vector2(392, 424), Vector2(388, 236)], [Vector2(414, 430), Vector2(428, 210)],
		[Vector2(434, 432), Vector2(458, 262)], [Vector2(372, 428), Vector2(360, 300)]]
	for i in stems.size():
		var s: Array = stems[i]
		var a: Vector2 = s[0]
		var b: Vector2 = s[1]
		_pline(c, _pv([a, a.lerp(b, 0.5) + Vector2(3, 0), b]), reed.darkened(0.15), 6.0, 620 + i)
	_pen(c, _leaf(Vector2(392, 360), 150, 18, -1.75), reed, 625, 3.5)
	_pen(c, _leaf(Vector2(446, 370), 130, 16, -1.2), reed, 626, 3.5)
	for i in 3:
		var s: Array = stems[i]
		var a: Vector2 = s[0]
		var b: Vector2 = s[1]
		_pen(c, _band(_pv([b.lerp(a, 0.08), b.lerp(a, 0.26)]), 10.0), Color("#c58f62"), 630 + i, 3.5)


## Marker: a round trampoline seen from the side - blue pad, lavender mat, springs, legs.
static func _trampoline(c: CanvasItem) -> void:
	var leg := Color("#a8b6c8")
	for i in 2:
		var x: float = [112.0, 400.0][i]
		_pen(c, _band(_pv([Vector2(x, 330), Vector2(x, 440)]), 7.0), leg.lightened(0.15), 701 + i, 4.0)
	var mid := Vector2(256, 318)
	var rim := Vector2(206, 50)
	var side := _drum_side(mid, rim, mid + Vector2(0, 26), rim)
	var pad := Color("#6db4e6")
	for i in 2:
		var x: float = [156.0, 356.0][i]
		_pen(c, _band(_pv([Vector2(x, 360), Vector2(x, 458)]), 8.0), leg, 705 + i, 4.0)
		_mark(c, Crayon.ellipse(Vector2(x, 462), Vector2(18, 8), 16), leg.darkened(0.1), 707 + i, 4.0)
	_mark(c, side, pad.darkened(0.08), 710, 7.0)
	var top := Crayon.ellipse(mid, rim, 48)
	_mark(c, top, pad, 711, 7.0)
	var mat := Crayon.ellipse(mid + Vector2(0, -2), Vector2(170, 34), 48)
	var mat_col := Color("#cbc4ea")
	_mark(c, mat, mat_col, 712, 5.0)
	_gleam(c, mat, 713, Vector2(0, 10), 0.35)
	var spring := Color("#9aa7bb")
	for i in 18:
		var a := TAU * (i + 0.5) / 18.0
		var dir := Vector2(cos(a), sin(a))
		var from := mid + Vector2(0, -2) + dir * Vector2(170, 34)
		var to := mid + dir * Vector2(197, 45)
		var nrm := (to - from).normalized().orthogonal() * 4.0
		_pline(c, _pv([from, from.lerp(to, 0.25) + nrm, from.lerp(to, 0.5) - nrm, from.lerp(to, 0.75) + nrm, to]),
			spring, 3.0, 720 + i)
	_pline(c, _arc(mid + Vector2(0, 13), Vector2(200, 46), 0.25, PI - 0.25, 20), Color("#e9f5fd"), 3.5, 740)


## Marker shade, pencil pole: a standing lamp, switched on - drawn the way a kid draws light,
## with little rays round the shade (solid strokes, no see-through glow).
static func _lamp(c: CanvasItem) -> void:
	var ray := Color("#f4c64c")
	for i in 6:
		var a: float = [-0.42, 0.08, 0.58, PI - 0.58, PI - 0.08, PI + 0.42][i]
		var dir := Vector2(cos(a), sin(a))
		var from := Vector2(256, 150) + dir * Vector2(150, 118)
		_pline(c, _pv([from, from + dir * 34.0]), ray, 7.0, 790 + i)
	var pole := Color("#b3bfcd")
	_pen(c, _band(_pv([Vector2(256, 214), Vector2(256, 448)]), 8.0), pole, 801, 4.0)
	var base := _arc(Vector2(256, 470), Vector2(82, 30), PI, TAU, 20)
	_mark(c, base, Color("#9fb4cc"), 802, 6.0)
	var glow := Crayon.ellipse(Vector2(256, 218), Vector2(100, 14), 28)
	c.draw_colored_polygon(glow, Color("#fff3c2"))
	var shade := PackedVector2Array()
	for p in _arc(Vector2(256, 86), Vector2(56, 8), PI, TAU, 10):
		shade.append(p)
	for p in _arc(Vector2(256, 214), Vector2(106, 16), 0.0, PI, 20):
		shade.append(p)
	var yellow := Color("#f6cf5c")
	_mark(c, shade, yellow, 803, 7.0)
	for i in 4:
		var f := (i + 1) / 5.0
		_pline(c, _pv([Vector2(lerpf(200, 312, f), 86), Vector2(lerpf(150, 362, f), 214 + sin(f * PI) * 14.0)]),
			yellow.darkened(0.2), 3.0, 804 + i)
	_gleam(c, shade, 808, Vector2(18, 0), 0.45)
	_pline(c, _pv([Vector2(318, 222), Vector2(320, 270)]), pole.darkened(0.25), 3.0, 810)
	c.draw_circle(Vector2(320, 274), 7.0, Color("#f2d27a"))
	Crayon.marker_line(c, _circle(Vector2(320, 274), 7.0, 10), Color("#c49a40"), 3.0, 811)


## Pencil logs and stones, marker flames: a campfire.
static func _campfire(c: CanvasItem) -> void:
	var stones := []
	for i in 12:
		var a := TAU * i / 12.0 + 0.13
		stones.append([Vector2(256, 420) + Vector2(cos(a) * 172, sin(a) * 28), sin(a) >= 0.0, i])
	var greys := [Color("#c4bfd8"), Color("#b5b0ca"), Color("#cfcadf")]
	for s in stones:
		if not s[1]:
			var at: Vector2 = s[0]
			var i: int = s[2]
			_pen(c, Crayon.blob(at, Vector2(30, 19), 900 + i, 12, 0.12), greys[i % 3], 920 + i * 3, 4.5)
	var outer := _smooth(_pv([Vector2(168, 424), Vector2(172, 360), Vector2(196, 300), Vector2(216, 332),
		Vector2(222, 262), Vector2(246, 196), Vector2(258, 142), Vector2(274, 214), Vector2(296, 290),
		Vector2(322, 230), Vector2(342, 316), Vector2(346, 424)]), 2)
	_mark(c, outer, Color("#f6974f"), 960, 7.0)
	var inner := _smooth(_pv([Vector2(212, 424), Vector2(214, 368), Vector2(234, 334), Vector2(242, 296),
		Vector2(258, 236), Vector2(274, 300), Vector2(292, 330), Vector2(302, 372), Vector2(304, 424)]), 2)
	_mark(c, inner, Color("#fbd860"), 961, 5.0)
	var wood := Color("#c99063")
	var logs := [[Vector2(362, 446), Vector2(146, 386)], [Vector2(150, 446), Vector2(366, 386)]]
	for i in 2:
		var l: Array = logs[i]
		var a: Vector2 = l[0]
		var b: Vector2 = l[1]
		var log_poly := _band(_pv([a, b]), 19.0)
		_pen(c, log_poly, wood.darkened(0.06 * i), 965 + i, 5.0)
		_pline(c, _pv([a.lerp(b, 0.2) + Vector2(0, -4), a.lerp(b, 0.55) + Vector2(0, -6)]), wood.darkened(0.35), 3.0, 967 + i)
		for end in [a, b]:
			var e: Vector2 = end
			_pen(c, Crayon.ellipse(e, Vector2(13, 18), 16), Color("#efd5a8"), 970 + i, 4.0)
			_pline(c, _arc(e, Vector2(6, 9), 0.0, TAU * 0.8, 10), Color("#c99a62"), 2.5, 975 + i)
	for s in stones:
		if s[1]:
			var at: Vector2 = s[0]
			var i: int = s[2]
			_pen(c, Crayon.blob(at, Vector2(30, 19), 900 + i, 12, 0.12), greys[i % 3], 920 + i * 3, 4.5)
	_mark(c, _sparkle(Vector2(200, 168), 14), Color("#fbd860"), 990, 3.0)
	_mark(c, _sparkle(Vector2(322, 150), 11), Color("#fbd860"), 991, 3.0)


## Marker: a striped beach umbrella on a pole, sand heaped at its foot.
static func _umbrella(c: CanvasItem) -> void:
	_pen(c, _band(_pv([Vector2(256, 150), Vector2(256, 460)]), 7.0), Color("#d9c3a0"), 1001, 4.0)
	_pen(c, _arc(Vector2(256, 470), Vector2(96, 24), PI, TAU, 18), Color("#f0d9a2"), 1002, 4.5)
	var canopy := PackedVector2Array()
	for i in 25:
		var a := PI + PI * i / 24.0
		canopy.append(Vector2(256, 200) + Vector2(cos(a) * 212, sin(a) * 136))
	var w := 424.0 / 6.0
	for k in 6:
		var x0 := 468.0 - k * w
		var mid := x0 - w / 2.0
		var last := 8 if k < 5 else 7
		for j in range(1, last + 1):
			var b := PI * j / 8.0
			canopy.append(Vector2(mid + cos(b) * w / 2.0, 200 + sin(b) * 20))
	var coral := Color("#f07b7b")
	var cream := Color("#fbefd6")
	_mfill(c, canopy, cream, 1003)
	for k in 6:
		if k % 2 == 1:
			continue
		var x0 := 468.0 - k * w + (24.0 if k == 0 else 0.0)
		var x1 := x0 - w - (24.0 if k == 0 else 0.0)
		var gore := _umbrella_rib(x0)
		gore.append(Vector2(x0, 250))
		gore.append(Vector2(x1, 250))
		var back := _umbrella_rib(x1)
		back.reverse()
		back.remove_at(back.size() - 1)
		gore.append_array(back)
		_clip_fill(c, gore, canopy, coral, 1010 + k)
	for k in range(1, 6):
		_pline(c, _umbrella_rib(468.0 - k * w), coral.darkened(0.3), 3.0, 1020 + k)
	Crayon.marker_line(c, canopy, coral.darkened(0.45), 7.0, 1030)
	_gleam(c, canopy, 1031, Vector2(14, 18), 0.3)
	_mark(c, _circle(Vector2(256, 58), 11.0, 14), Color("#f6d878"), 1032, 4.0)


## One umbrella rib, curving over the dome from the top down to the edge at x.
static func _umbrella_rib(x: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in 13:
		var s := i / 12.0 * PI / 2.0
		out.append(Vector2(256 + (x - 256) * sin(s), 200 - 136 * cos(s)))
	return out


## Pencil: a short white picket fence with grass at its feet.
static func _fence(c: CanvasItem) -> void:
	var rail := Color("#dde2ee")
	for y in [318.0, 404.0]:
		_pen(c, Crayon.rounded_rect(Rect2(66, y, 380, 28), 6), rail, 1101 + int(y), 4.5)
	var white := Color("#f2f3f9")
	for i in 5:
		var x := 82.0 + i * 72.0
		var picket := _pv([Vector2(x, 470), Vector2(x, 262), Vector2(x + 27, 224), Vector2(x + 54, 262),
			Vector2(x + 54, 470)])
		_pen(c, picket, white, 1110 + i * 4, 5.0)
		_shade(c, picket, Color("#c8d0e4"), 1111 + i * 4, Vector2(-16, 0), 0.0)
		for y in [332.0, 418.0]:
			c.draw_circle(Vector2(x + 27, y), 3.5, Color("#a9b2c8"))
	for x in [70.0, 150.0, 226.0, 300.0, 372.0, 444.0]:
		_tuft(c, Vector2(x, 470), 1150 + int(x), 0.9)


## Pencil pot, marker flowers: a terracotta pot of three flowers.
static func _flowerpot(c: CanvasItem) -> void:
	var stem := Color("#7fbf6a")
	var heads := [Vector2(178, 200), Vector2(262, 118), Vector2(340, 196)]
	var roots := [Vector2(226, 320), Vector2(258, 320), Vector2(290, 320)]
	for i in 3:
		var h: Vector2 = heads[i]
		var r: Vector2 = roots[i]
		_pline(c, _bez(r, r + Vector2(0, -60), h + Vector2(0, 60), h, 10), stem.darkened(0.15), 7.0, 1201 + i)
	_pen(c, _leaf(Vector2(196, 270), 74, 30, -2.6), stem, 1205, 4.0)
	_pen(c, _leaf(Vector2(316, 268), 74, 30, -0.5), stem, 1206, 4.0)
	_pen(c, _leaf(Vector2(286, 210), 60, 24, -0.9), stem, 1207, 4.0)
	var terra := Color("#e3906a")
	var pot := _pv([Vector2(182, 334), Vector2(330, 334), Vector2(312, 470), Vector2(200, 470)])
	_pen(c, pot, terra, 1210, 5.0)
	_shade(c, pot, terra, 1211, Vector2(-24, 0), 0.16)
	var rim := Crayon.rounded_rect(Rect2(164, 300, 184, 42), 8)
	_pen(c, rim, terra.lightened(0.06), 1212, 5.0)
	_mark(c, Crayon.heart(Vector2(256, 404), 40.0), Color("#f6c1a6"), 1213, 4.0)
	var petals := [Color("#f394b6"), Color("#f7d65c"), Color("#b9a2ea")]
	var middles := [Color("#f7d65c"), Color("#f39a52"), Color("#f7d65c")]
	for i in 3:
		var h: Vector2 = heads[i]
		var parts := []
		for k in 5:
			var a := -PI / 2.0 + TAU * k / 5.0 + i * 0.3
			parts.append(_circle(h + Vector2(cos(a), sin(a)) * 30.0, 25.0, 18))
		parts.append(_circle(h, 30.0, 18))
		_mark(c, _union(parts), petals[i], 1220 + i * 4, 5.0)
		_mark(c, _circle(h, 15.0, 16), middles[i], 1221 + i * 4, 4.0)


## Pencil: a wooden signpost, its board a little crooked and blank for a name.
static func _sign(c: CanvasItem) -> void:
	var wood := Color("#cf9d6a")
	_pen(c, Crayon.rounded_rect(Rect2(236, 200, 40, 270), 6), wood, 1301, 5.0)
	_shade(c, Crayon.rounded_rect(Rect2(236, 200, 40, 270), 6), wood, 1302, Vector2(-12, 0), 0.16)
	var centre := Vector2(256, 196)
	var board := _rot(Crayon.rounded_rect(Rect2(92, 118, 328, 152), 14), centre, -0.04)
	var face := Color("#ecc48f")
	_pen(c, board, face, 1303, 5.5)
	_shade(c, board, face, 1304, Vector2(0, -16), 0.14)
	var grain := face.darkened(0.28)
	_pline(c, _rot(_pv([Vector2(122, 160), Vector2(180, 156), Vector2(232, 162)]), centre, -0.04), grain, 3.0, 1305)
	_pline(c, _rot(_pv([Vector2(300, 210), Vector2(350, 206), Vector2(392, 212)]), centre, -0.04), grain, 3.0, 1306)
	_pline(c, _rot(_pv([Vector2(150, 236), Vector2(196, 240)]), centre, -0.04), grain, 3.0, 1307)
	for p in _rot(_pv([Vector2(116, 140), Vector2(396, 140), Vector2(116, 248), Vector2(396, 248)]), centre, -0.04):
		c.draw_circle(p, 6.0, Color("#b8b0c8"))
		c.draw_circle(p + Vector2(-1.5, -1.5), 2.0, Color(1, 1, 1, 0.8))
	_tuft(c, Vector2(226, 470), 1310, 1.0)
	_tuft(c, Vector2(290, 470), 1311, 0.9)


## Marker: a small playground slide - blue ladder up the left, yellow chute down the right.
static func _slide(c: CanvasItem) -> void:
	var blue := Color("#76a9df")
	_pen(c, _band(_pv([Vector2(334, 330), Vector2(334, 466)]), 7.0), Color("#b0bccc"), 1401, 4.0)
	var rail_l := [Vector2(110, 466), Vector2(156, 176)]
	var rail_r := [Vector2(172, 466), Vector2(216, 176)]
	for i in 6:
		var t := 0.12 + i * 0.15
		var a: Vector2 = (rail_l[0] as Vector2).lerp(rail_l[1], t)
		var b: Vector2 = (rail_r[0] as Vector2).lerp(rail_r[1], t)
		_mark(c, _band(_pv([a, b]), 6.0), blue.lightened(0.2), 1402 + i, 4.0)
	for rail in [rail_l, rail_r]:
		var a: Vector2 = rail[0]
		var b: Vector2 = rail[1]
		_mark(c, _band(_pv([a, b + Vector2(0, -34)]), 8.0), blue, 1410 + int(a.x), 5.0)
	_mark(c, Crayon.rounded_rect(Rect2(146, 172, 84, 22), 6), blue.darkened(0.08), 1420, 5.0)
	var curve := _bez(Vector2(222, 184), Vector2(312, 184), Vector2(330, 436), Vector2(442, 440), 28)
	curve.append(Vector2(474, 442))
	var yellow := Color("#f7cf55")
	var wall := _band(_move(curve, Vector2(0, 16)), 15.0)
	_mark(c, wall, Color("#eaa944"), 1421, 6.0)
	var chute := _band(curve, 17.0)
	_mark(c, chute, yellow, 1422, 6.0)
	_pline(c, _move(curve, Vector2(0, -6)), Color(1, 1, 1, 0.75), 4.0, 1423)
	_pen(c, Crayon.rounded_rect(Rect2(446, 448, 30, 22), 5), Color("#b0bccc"), 1424, 4.0)


## Marker: a triangle tent from the front, its flaps tied back from a pale doorway.
static func _tent(c: CanvasItem) -> void:
	var rope := Color("#c8a57e")
	_pline(c, _pv([Vector2(170, 300), Vector2(40, 466)]), rope, 3.0, 1501)
	_pen(c, _band(_pv([Vector2(38, 446), Vector2(42, 464)]), 4.0), rope, 1502, 3.0)
	var side := _pv([Vector2(256, 118), Vector2(332, 96), Vector2(486, 440), Vector2(442, 470)])
	var green := Color("#86cba0")
	_mark(c, side, green.darkened(0.14), 1503, 7.0)
	_pen(c, _band(_pv([Vector2(256, 72), Vector2(256, 124)]), 5.0), Color("#c9a37a"), 1504, 3.5)
	_mark(c, _pv([Vector2(256, 74), Vector2(300, 86), Vector2(256, 100)]), Color("#f39ab6"), 1505, 4.0)
	var front := _pv([Vector2(64, 470), Vector2(256, 116), Vector2(448, 470)])
	_mark(c, front, green, 1506, 7.5)
	var door := _pv([Vector2(196, 470), Vector2(256, 250), Vector2(316, 470)])
	var inside := Color("#e6e0f4")
	_pen(c, door, inside, 1507, 4.5)
	_shade(c, door, inside, 1508, Vector2(0, 30), 0.12)
	var flap_col := Color("#c4e8cf")
	var left := _smooth(_pv([Vector2(256, 250), Vector2(198, 466), Vector2(154, 466), Vector2(208, 352)]), 1)
	var right := _smooth(_pv([Vector2(256, 250), Vector2(314, 466), Vector2(358, 466), Vector2(304, 352)]), 1)
	_mark(c, left, flap_col, 1509, 5.0)
	_mark(c, right, flap_col, 1510, 5.0)
	_pline(c, _pv([Vector2(178, 392), Vector2(206, 402)]), rope.darkened(0.15), 5.0, 1511)
	_pline(c, _pv([Vector2(334, 392), Vector2(306, 402)]), rope.darkened(0.15), 5.0, 1512)
	_pline(c, _pv([Vector2(256, 124), Vector2(256, 250)]), green.darkened(0.3), 3.0, 1513)


## Pencil posts, marker hammock: a striped hammock slung between two posts.
static func _hammock(c: CanvasItem) -> void:
	var wood := Color("#c99a6c")
	var rope := Color("#cdb08a")
	for x in [78.0, 434.0]:
		_pen(c, _band(_pv([Vector2(x, 150), Vector2(x, 470)]), 13.0, false), wood, 1601 + int(x), 5.0)
		_mark(c, _circle(Vector2(x, 146), 16.0, 16), wood.lightened(0.1), 1602 + int(x), 5.0)
	var ends := [[Vector2(86, 192), Vector2(132, 284), Vector2(150, 278), Vector2(150, 316)],
		[Vector2(426, 192), Vector2(380, 284), Vector2(362, 278), Vector2(362, 316)]]
	for e in ends:
		var post: Vector2 = e[0]
		var ring: Vector2 = e[1]
		var hi: Vector2 = e[2]
		var lo: Vector2 = e[3]
		_pline(c, _pv([post, ring]), rope.darkened(0.2), 4.0, 1610 + int(post.x))
		for k in 4:
			_pline(c, _pv([ring, hi.lerp(lo, k / 3.0)]), rope.darkened(0.2), 3.0, 1615 + k + int(post.x))
		c.draw_circle(ring, 7.0, rope)
	var top := _bez(Vector2(150, 278), Vector2(196, 360), Vector2(316, 360), Vector2(362, 278), 20)
	var bottom := _bez(Vector2(362, 316), Vector2(320, 430), Vector2(192, 430), Vector2(150, 316), 20)
	var sling := PackedVector2Array()
	sling.append_array(top)
	sling.append_array(bottom)
	var teal := Color("#6ec4c2")
	var cream := Color("#f8eed6")
	_mfill(c, sling, cream, 1630)
	for i in 8:
		if i % 2 == 0:
			var x := 140.0 + i * 30.0
			_clip_fill(c, _pv([Vector2(x, 250), Vector2(x + 30, 250), Vector2(x + 30, 450), Vector2(x, 450)]),
				sling, teal, 1640 + i)
	Crayon.marker_line(c, sling, teal.darkened(0.45), 7.0, 1650)
	for i in 12:
		var p := _at(bottom, 30.0 + i * 22.0)
		_pline(c, _pv([p, p + Vector2(0, 16 + Crayon.noise(1660, i) * 3.0)]), teal.darkened(0.2), 3.5, 1661 + i)
	_tuft(c, Vector2(78, 470), 1680, 0.9)
	_tuft(c, Vector2(434, 470), 1681, 0.9)


## Pencil snow, marker scarf and nose: a three-ball snowman with stick arms.
static func _snowman(c: CanvasItem) -> void:
	var snow := Color("#eaf0fa")
	var twig := Color("#b48a64")
	_pline(c, _pv([Vector2(206, 276), Vector2(160, 248), Vector2(124, 214)]), twig, 7.0, 1701)
	_pline(c, _pv([Vector2(150, 240), Vector2(136, 252)]), twig, 5.0, 1702)
	_pline(c, _pv([Vector2(306, 276), Vector2(352, 246), Vector2(392, 220)]), twig, 7.0, 1703)
	_pline(c, _pv([Vector2(364, 238), Vector2(370, 214)]), twig, 5.0, 1704)
	var shade := Color("#c9d5ef")
	var balls := [[Vector2(256, 396), Vector2(90, 74)], [Vector2(256, 278), Vector2(68, 60)],
		[Vector2(256, 180), Vector2(52, 50)]]
	for i in 3:
		var b: Array = balls[i]
		var poly := Crayon.blob(b[0], b[1], 1710 + i, 24, 0.03)
		_pen(c, poly, snow, 1720 + i, 5.0)
		_shade(c, poly, shade, 1725 + i, Vector2(-22, -20), 0.0)
	var red := Color("#ea6a6a")
	var tail := _pv([Vector2(282, 228), Vector2(314, 232), Vector2(326, 306), Vector2(294, 312)])
	_mark(c, tail, red, 1730, 5.0)
	for y in [256.0, 284.0]:
		_clip_fill(c, _pv([Vector2(270, y), Vector2(340, y), Vector2(340, y + 10), Vector2(270, y + 10)]), tail,
			Color("#fbe9e4"), 1731 + int(y))
	for i in 4:
		var x := 298.0 + i * 8.0
		_pline(c, _pv([Vector2(x, 310), Vector2(x + 1, 324)]), red.darkened(0.2), 4.0, 1740 + i)
	_mark(c, Crayon.rounded_rect(Rect2(196, 212, 120, 30), 13), red, 1745, 5.0)
	var coal := Color("#77728f")
	for e in [Vector2(238, 168), Vector2(276, 168)]:
		c.draw_circle(e, 7.5, coal)
		c.draw_circle(e + Vector2(-2, -2.5), 2.2, Color(1, 1, 1, 0.9))
	_mark(c, _pv([Vector2(254, 178), Vector2(318, 190), Vector2(254, 196)]), Color("#f59a4c"), 1750, 4.0)
	for i in 5:
		var a := PI * (0.25 + 0.125 * i)
		c.draw_circle(Vector2(256, 186) + Vector2(cos(a) * 24, sin(a) * 16), 3.5, coal)
	for y in [262.0, 290.0, 318.0]:
		c.draw_circle(Vector2(256, y), 7.0, coal)


## Pencil: a rope-wrapped scratching post on a carpeted base, a pom-pom on a string.
static func _scratch_post(c: CanvasItem) -> void:
	var rope := Color("#e2c08c")
	var post := _pv([Vector2(214, 112), Vector2(298, 112), Vector2(298, 410), Vector2(214, 410)])
	_pen(c, post, rope, 1801, 5.0)
	for i in 23:
		var y := 122.0 + i * 13.0
		_pline(c, _pv([Vector2(217, y + 5), Vector2(295, y - 5)]), rope.darkened(0.28), 3.0, 1802 + i)
	_shade(c, post, rope, 1830, Vector2(-16, 0), 0.18)
	var carpet := Color("#c3b3e4")
	var top := _pv([Vector2(130, 390), Vector2(382, 390), Vector2(420, 424), Vector2(92, 424)])
	_pen(c, top, carpet.lightened(0.12), 1831, 5.0)
	var front := _pv([Vector2(92, 424), Vector2(420, 424), Vector2(420, 470), Vector2(92, 470)])
	_pen(c, front, carpet, 1832, 5.0)
	_pen(c, _pv([Vector2(212, 392), Vector2(300, 392), Vector2(296, 404), Vector2(216, 404)]), rope.darkened(0.1), 1833, 3.0)
	var perch_top := _pv([Vector2(172, 86), Vector2(340, 86), Vector2(366, 106), Vector2(146, 106)])
	_pen(c, perch_top, carpet.lightened(0.12), 1834, 5.0)
	_pen(c, _pv([Vector2(146, 106), Vector2(366, 106), Vector2(366, 130), Vector2(146, 130)]), carpet, 1835, 5.0)
	var pink := Color("#f3a2c0")
	_pline(c, _bez(Vector2(344, 130), Vector2(350, 170), Vector2(340, 210), Vector2(352, 248), 10),
		pink.darkened(0.25), 3.5, 1836)
	var pom := Crayon.blob(Vector2(354, 274), Vector2(30, 30), 1837, 18, 0.22)
	_pen(c, pom, pink, 1838, 4.0)
	for i in 6:
		var a := TAU * i / 6.0 + 0.4
		var p := Vector2(354, 274) + Vector2(cos(a), sin(a)) * 12.0
		_pline(c, _pv([p, p + Vector2(cos(a), sin(a)) * 12.0]), pink.darkened(0.25), 2.5, 1840 + i)


## Marker: a toy drum with a zigzag cord and two drumsticks resting on top.
static func _drum(c: CanvasItem) -> void:
	var top_c := Vector2(256, 292)
	var top_r := Vector2(138, 38)
	var bot_c := Vector2(256, 440)
	var bot_r := Vector2(138, 30)
	var red := Color("#ec7b78")
	var body := _drum_side(top_c, top_r, bot_c, bot_r)
	_mark(c, body, red, 1901, 7.0)
	var blue := Color("#7aa9de")
	var upper := _drum_side(top_c, top_r, top_c + Vector2(0, 24), top_r)
	_mark(c, upper, blue, 1902, 6.0)
	var lower := _drum_side(bot_c + Vector2(0, -24), bot_r, bot_c, bot_r)
	_mark(c, lower, blue, 1903, 6.0)
	var zig := PackedVector2Array()
	for i in 9:
		var x := 132.0 + i * 31.0
		var k := sqrt(maxf(0.0, 1.0 - pow((x - 256.0) / 138.0, 2)))
		var y := (top_c.y + 26.0 + top_r.y * k) if i % 2 == 0 else (bot_c.y - 26.0 + bot_r.y * k)
		zig.append(Vector2(x, y))
	_mline(c, zig, Color("#fbeccd"), 7.0, 1904)
	var skin := Crayon.ellipse(top_c, top_r, 40)
	_pen(c, skin, Color("#f6ead6"), 1905, 6.0)
	_pline(c, Crayon.ellipse(top_c, top_r - Vector2(14, 5), 32), Color("#e2d0b2"), 3.0, 1906)
	var stick := Color("#e8c48f")
	var tip := Color("#f3a1bb")
	for s in [[Vector2(178, 300), Vector2(344, 168)], [Vector2(334, 304), Vector2(166, 176)]]:
		var a: Vector2 = s[0]
		var b: Vector2 = s[1]
		_mark(c, _band(_pv([a, b]), 7.0), stick, 1910 + int(a.x), 4.5)
		_mark(c, _circle(b, 17.0, 18), tip, 1911 + int(a.x), 5.0)


## Pencil canopy, marker apples: a small round apple tree, one apple fallen.
static func _fruit_tree(c: CanvasItem) -> void:
	var bark := Color("#bf916a")
	var trunk := _smooth(_pv([Vector2(218, 470), Vector2(238, 444), Vector2(242, 330), Vector2(212, 280),
		Vector2(236, 272), Vector2(256, 300), Vector2(280, 270), Vector2(302, 282), Vector2(272, 330),
		Vector2(276, 444), Vector2(296, 470)]), 1)
	_pen(c, trunk, bark, 2001)
	_shade(c, trunk, bark, 2002, Vector2(-14, 0), 0.16)
	var leaf := Color("#9bd174")
	var crown := _circles([Vector3(256, 200, 104), Vector3(176, 222, 72), Vector3(336, 222, 72),
		Vector3(208, 150, 70), Vector3(304, 150, 70), Vector3(256, 116, 60), Vector3(256, 268, 66),
		Vector3(186, 274, 52), Vector3(326, 274, 52)])
	_pen(c, crown, leaf, 2003, 5.5)
	_shade(c, crown, leaf, 2004, Vector2(-30, -28), 0.16)
	Crayon.pencil_fill(c, Crayon.blob(Vector2(214, 150), Vector2(40, 28), 2005, 14, 0.1), Color("#ddf2b0"), 2006)
	_leaf_marks(c, [Vector2(256, 236), Vector2(160, 240), Vector2(342, 180), Vector2(296, 300)],
		leaf.darkened(0.3), 2010)
	var apples := [Vector2(188, 196), Vector2(272, 150), Vector2(336, 224), Vector2(226, 268),
		Vector2(308, 284), Vector2(250, 206), Vector2(160, 262)]
	apples.append(Vector2(338, 454))
	for i in apples.size():
		var at: Vector2 = apples[i]
		var apple := _union([_circle(at + Vector2(-6, 0), 15.0, 16), _circle(at + Vector2(6, 0), 15.0, 16)])
		_mark(c, apple, Color("#e95a5a"), 2020 + i * 3, 4.0)
		c.draw_circle(at + Vector2(-6, -4), 4.0, Color(1, 1, 1, 0.8))
		_pline(c, _pv([at + Vector2(0, -12), at + Vector2(3, -22)]), Color("#9c7a5a"), 3.5, 2050 + i)


## Pencil wood, marker toys: an open toy chest with a ball and a block peeking out. The domed
## lid stands open behind, its pale lining showing.
static func _toybox(c: CanvasItem) -> void:
	var wood := Color("#dfa874")
	var lining := Color("#e3dcf2")
	var lid := PackedVector2Array([Vector2(100, 266)])
	lid.append_array(_arc(Vector2(256, 186), Vector2(156, 66), PI, TAU, 24))
	lid.append(Vector2(412, 266))
	_pen(c, lid, wood.darkened(0.04), 2101, 5.5)
	var inner := PackedVector2Array([Vector2(124, 266)])
	inner.append_array(_arc(Vector2(256, 194), Vector2(132, 46), PI, TAU, 20))
	inner.append(Vector2(388, 266))
	_pen(c, inner, lining, 2102, 4.0)
	_shade(c, inner, lining, 2103, Vector2(0, 16), 0.1)
	var inside := _pv([Vector2(96, 266), Vector2(416, 266), Vector2(424, 300), Vector2(88, 300)])
	_pen(c, inside, lining.darkened(0.06), 2104, 4.0)
	for x in [150.0, 330.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 252, 32, 28), 4), Color("#f1d98a"), 2105 + int(x), 4.0)
	var block := _rot(Crayon.rounded_rect(Rect2(140, 236, 62, 62), 8), Vector2(171, 267), -0.3)
	_mark(c, block, Color("#9fd38b"), 2105, 5.0)
	_mark(c, Crayon.star(Vector2(171, 267), 18.0, 2106), Color("#fbe6a0"), 2107, 3.0)
	var ball := _circle(Vector2(306, 270), 58.0, 40)
	_mfill(c, ball, Color("#ec6b6b"), 2108)
	_clip_fill(c, _pv([Vector2(240, 254), Vector2(380, 254), Vector2(380, 284), Vector2(240, 284)]), ball,
		Color("#fbe08a"), 2109)
	Crayon.marker_line(c, ball, Color("#ec6b6b").darkened(0.48), 6.0, 2110)
	c.draw_arc(Vector2(306, 270), 42.0, PI * 1.12, PI * 1.42, 10, Color(1, 1, 1, 0.85), 7.0, true)
	var front := _pv([Vector2(88, 296), Vector2(424, 296), Vector2(424, 470), Vector2(88, 470)])
	_pen(c, front, wood, 2111, 5.5)
	_shade(c, front, wood, 2112, Vector2(-30, 0), 0.14)
	for y in [354.0, 412.0]:
		_pline(c, _pv([Vector2(94, y), Vector2(256, y + 2), Vector2(418, y)]), wood.darkened(0.3), 3.0, 2113 + int(y))
	_pen(c, Crayon.rounded_rect(Rect2(82, 288, 348, 20), 6), wood.darkened(0.1), 2120, 5.0)
	_mark(c, Crayon.star(Vector2(256, 386), 40.0, 2121), Color("#f7d867"), 2122, 5.0)
	var brass := Color("#f1d98a")
	for corner in [[Vector2(88, 470), Vector2(88, 430), Vector2(128, 470)],
			[Vector2(424, 470), Vector2(424, 430), Vector2(384, 470)]]:
		_mark(c, _pv(corner), brass, 2123, 4.0)


# --- Shop furniture --------------------------------------------------------------------------

## Marker gold, pencil cushions: a throne with a crown-topped back and a red seat.
static func _throne(c: CanvasItem) -> void:
	var gold := Color("#f5e29c")
	var red := Color("#e0646e")
	var back := _pv([Vector2(150, 336), Vector2(150, 146), Vector2(178, 104), Vector2(208, 132),
		Vector2(256, 62), Vector2(304, 132), Vector2(334, 104), Vector2(362, 146), Vector2(362, 336)])
	_mark(c, back, gold, 2201, 7.0)
	_shade(c, back, gold, 2202, Vector2(-22, -10), 0.14)
	for p in [Vector2(178, 96), Vector2(256, 52), Vector2(334, 96)]:
		_mark(c, _circle(p, 13.0, 16), gold, 2203 + int(p.x), 5.0)
		c.draw_circle(p + Vector2(-4, -4), 4.0, Color(1, 1, 1, 0.9))
	var cushion := Crayon.rounded_rect(Rect2(180, 146, 152, 172), 34)
	_pen(c, cushion, red, 2210, 5.0)
	_shade(c, cushion, red, 2211, Vector2(-16, -16), 0.14)
	for p in [Vector2(226, 200), Vector2(286, 200), Vector2(256, 240), Vector2(226, 280), Vector2(286, 280)]:
		c.draw_circle(p, 5.0, red.darkened(0.3))
		c.draw_circle(p + Vector2(-1.5, -1.5), 1.8, Color(1, 1, 1, 0.7))
	for side: float in [-1.0, 1.0]:
		var x0 := 256.0 + side * 150.0
		var post := _pv([Vector2(x0 - 14, 296), Vector2(x0 + 14, 296), Vector2(x0 + 12, 410), Vector2(x0 - 12, 410)])
		_mark(c, post, gold, 2220 + int(side), 5.0)
		var arm := Crayon.rounded_rect(Rect2(minf(x0, 256 + side * 96) - 4, 268, 62, 30), 14)
		_mark(c, arm, gold, 2222 + int(side), 6.0)
		_mark(c, _circle(Vector2(x0 + side * 4, 283), 21.0, 20), gold, 2224 + int(side), 6.0)
		_pline(c, _arc(Vector2(x0 + side * 4, 283), Vector2(10, 10), 0.0, TAU * 0.75, 10), gold.darkened(0.35), 3.0, 2226)
	var seat := Crayon.rounded_rect(Rect2(146, 316, 220, 42), 18)
	_pen(c, seat, red, 2230, 5.0)
	_gleam(c, seat, 2231, Vector2(0, 10), 0.35)
	var apron := _pv([Vector2(136, 352), Vector2(376, 352), Vector2(366, 408), Vector2(146, 408)])
	_mark(c, apron, gold, 2232, 7.0)
	_shade(c, apron, gold, 2233, Vector2(0, -14), 0.14)
	var gem := _pv([Vector2(256, 362), Vector2(278, 380), Vector2(256, 398), Vector2(234, 380)])
	_mark(c, gem, Color("#9cc7f0"), 2234, 4.0)
	for x in [154.0, 330.0]:
		var leg := _pv([Vector2(x, 404), Vector2(x + 28, 404), Vector2(x + 24, 462), Vector2(x + 4, 462)])
		_mark(c, leg, gold, 2240 + int(x), 6.0)
		_mark(c, Crayon.ellipse(Vector2(x + 14, 462), Vector2(20, 8), 16), gold.darkened(0.06), 2241 + int(x), 5.0)


## Marker: a big slide with a ladder tower, its chute striped in rainbow bands.
static func _rainbow_slide(c: CanvasItem) -> void:
	var post := Color("#aab8e2")
	for x in [70.0, 160.0]:
		_mark(c, _band(_pv([Vector2(x, 160), Vector2(x, 468)]), 9.0), post, 2301 + int(x), 5.0)
	for i in 7:
		var y := 200.0 + i * 40.0
		_mark(c, _band(_pv([Vector2(74, y), Vector2(156, y)]), 6.0), post.lightened(0.2), 2305 + i, 4.0)
	_mark(c, _band(_pv([Vector2(115, 140), Vector2(115, 70)]), 4.0), Color("#c9a37a"), 2315, 3.5)
	_mark(c, _pv([Vector2(118, 72), Vector2(168, 86), Vector2(118, 102)]), Color("#f39ab6"), 2316, 4.5)
	_mark(c, Crayon.rounded_rect(Rect2(50, 138, 132, 26), 8), post.darkened(0.1), 2317, 5.0)
	var curve := _bez(Vector2(176, 160), Vector2(296, 160), Vector2(326, 432), Vector2(446, 434), 32)
	curve.append(Vector2(480, 436))
	for x in [314.0, 430.0]:
		var y := 300.0 if x < 400.0 else 440.0
		_pen(c, _band(_pv([Vector2(x, y), Vector2(x, 468)]), 7.0), post, 2320 + int(x), 4.0)
	var wall := _band(_move(curve, Vector2(0, 22)), 18.0)
	_mark(c, wall, Color("#b8a5e2"), 2325, 6.0)
	var chute := _band(curve, 34.0)
	var colors := [Color("#f49a9a"), Color("#f7c28a"), Color("#f7e290"), Color("#a9dba0"),
		Color("#9cc5ef"), Color("#c6aaea")]
	var normals := PackedVector2Array()
	for i in curve.size():
		var a := curve[maxi(i - 1, 0)]
		var b := curve[mini(i + 1, curve.size() - 1)]
		normals.append((b - a).normalized().orthogonal())
	for k in 6:
		var off := -27.5 + k * 11.0
		var line := PackedVector2Array()
		for i in curve.size():
			line.append(curve[i] + normals[i] * off)
		var stripe := _band(line, 6.5, false)
		_clip_fill(c, stripe, chute, colors[k], 2330 + k * 7)
	Crayon.marker_line(c, chute, Color("#9a86c4"), 6.0, 2380)


## Pencil wood, marker water: a round wooden hot tub, steam curling off it.
static func _hot_tub(c: CanvasItem) -> void:
	var wood := Color("#d9a46f")
	var top_c := Vector2(256, 292)
	var top_r := Vector2(196, 46)
	var bot_c := Vector2(256, 438)
	var bot_r := Vector2(190, 32)
	var side := _drum_side(top_c, top_r, bot_c, bot_r)
	_pen(c, side, wood, 2401, 5.5)
	for k in 11:
		var a := PI * (k + 0.5) / 11.0
		var x := cos(a)
		var y0 := top_c.y + sin(a) * top_r.y
		var y1 := bot_c.y + sin(a) * bot_r.y
		_pline(c, _pv([Vector2(256 + x * 195, y0), Vector2(256 + x * 189, y1)]), wood.darkened(0.3), 3.0, 2402 + k)
	_shade(c, side, wood, 2415, Vector2(-40, 0), 0.14)
	var steel := Color("#b9c6d8")
	for dy in [36.0, 104.0]:
		var hoop := _drum_side(top_c + Vector2(0, dy), Vector2(194, 44), top_c + Vector2(0, dy + 14), Vector2(193, 43))
		_mark(c, hoop, steel, 2420 + int(dy), 4.0)
	var rim := Crayon.ellipse(top_c, top_r, 48)
	_pen(c, rim, wood.lightened(0.12), 2430, 5.5)
	var water := Crayon.ellipse(top_c + Vector2(0, 2), Vector2(168, 34), 48)
	var aqua := Color("#97dbe0")
	_mark(c, water, aqua, 2431, 5.0)
	_gleam(c, water, 2432, Vector2(0, 10), 0.4)
	for b in [Vector3(200, 294, 9), Vector3(226, 302, 6), Vector3(316, 286, 8), Vector3(290, 300, 5)]:
		var v: Vector3 = b
		Crayon.marker_line(c, _circle(Vector2(v.x, v.y), v.z, 12), Color("#f2fcfd"), 3.0, 2433 + int(v.x))
	var steam := Color("#d3cdee")
	for i in 3:
		var x0: float = [192.0, 258.0, 324.0][i]
		var h: float = [120.0, 158.0, 112.0][i]
		var path := PackedVector2Array()
		for k in 20:
			var t := k / 19.0
			path.append(Vector2(x0 + sin(t * TAU * 1.1 + i * 1.3) * 15.0 * (0.4 + t), 262.0 - t * h))
		var tip := path[path.size() - 1]
		var turn := 1.0 if i % 2 == 0 else -1.0
		var hub := tip + Vector2(13.0 * turn, 0)
		for k in range(1, 12):
			var a := (PI if turn > 0.0 else 0.0) + turn * PI * 1.45 * k / 11.0
			path.append(hub + Vector2(cos(a), sin(a)) * 13.0 * (1.0 - k / 30.0))
		_mline(c, path, steam, 9.0, 2440 + i)


## Pencil: a little treehouse with a red roof on a big trunk, a rope ladder hanging down.
static func _treehouse(c: CanvasItem) -> void:
	var leaf := Color("#8cc86e")
	var crown := _circles([Vector3(140, 170, 78), Vector3(372, 170, 78), Vector3(256, 116, 100),
		Vector3(190, 90, 70), Vector3(322, 90, 70), Vector3(256, 200, 90)])
	_pen(c, crown, leaf, 2501, 5.5)
	_shade(c, crown, leaf, 2502, Vector2(-30, -30), 0.16)
	_leaf_marks(c, [Vector2(110, 170), Vector2(400, 150), Vector2(180, 70), Vector2(340, 80)],
		leaf.darkened(0.3), 2503)
	var bark := Color("#c29169")
	var trunk := _smooth(_pv([Vector2(196, 470), Vector2(226, 440), Vector2(234, 232), Vector2(278, 232),
		Vector2(286, 440), Vector2(316, 470)]), 1)
	_pen(c, trunk, bark, 2510)
	_shade(c, trunk, bark, 2511, Vector2(-16, 0), 0.16)
	_pline(c, _pv([Vector2(252, 450), Vector2(248, 380), Vector2(254, 320)]), bark.darkened(0.3), 3.0, 2512)
	var plank := Color("#c99464")
	_pen(c, _band(_pv([Vector2(164, 242), Vector2(222, 290)]), 6.0), plank, 2513, 4.0)
	_pen(c, _band(_pv([Vector2(348, 242), Vector2(290, 290)]), 6.0), plank, 2514, 4.0)
	var wall := Color("#ecbd8a")
	var house := _pv([Vector2(164, 140), Vector2(348, 140), Vector2(348, 226), Vector2(164, 226)])
	_pen(c, house, wall, 2515, 5.0)
	for y in [168.0, 196.0]:
		_pline(c, _pv([Vector2(168, y), Vector2(344, y)]), wall.darkened(0.25), 2.5, 2516 + int(y))
	var inside := Color("#e3dcf2")
	var door := PackedVector2Array([Vector2(194, 226)])
	for p in _arc(Vector2(218, 184), Vector2(24, 22), PI, TAU, 10):
		door.append(p)
	door.append(Vector2(242, 226))
	_pen(c, door, inside, 2520, 4.0)
	var window := _circle(Vector2(302, 180), 24.0, 24)
	_pen(c, window, inside, 2521, 4.5)
	_pline(c, _pv([Vector2(302, 158), Vector2(302, 202)]), wall.darkened(0.3), 4.0, 2522)
	_pline(c, _pv([Vector2(280, 180), Vector2(324, 180)]), wall.darkened(0.3), 4.0, 2523)
	var roof := _pv([Vector2(140, 148), Vector2(256, 54), Vector2(372, 148)])
	_mark(c, roof, Color("#e66b62"), 2524, 7.0)
	_pen(c, Crayon.rounded_rect(Rect2(124, 222, 264, 22), 5), plank, 2525, 5.0)
	var rope := Color("#cfb184")
	var rung := Color("#c99464")
	for x in [326.0, 366.0]:
		_pline(c, _pv([Vector2(x, 240), Vector2(x + 3, 340), Vector2(x - 2, 446)]), rope.darkened(0.15), 5.0, 2530 + int(x))
	for i in 6:
		var y := 268.0 + i * 34.0
		_pen(c, Crayon.rounded_rect(Rect2(318, y, 56, 12), 4), rung, 2540 + i, 3.5)


## Pencil: a small wooden upright piano with white and pale grey keys.
static func _piano(c: CanvasItem) -> void:
	var wood := Color("#d49c6e")
	var body := _pv([Vector2(112, 146), Vector2(400, 146), Vector2(400, 452), Vector2(112, 452)])
	_pen(c, body, wood, 2601, 5.5)
	_shade(c, body, wood, 2602, Vector2(-30, 0), 0.14)
	_pen(c, Crayon.rounded_rect(Rect2(98, 118, 316, 32), 8), wood.darkened(0.06), 2603, 5.0)
	var stand := Crayon.rounded_rect(Rect2(166, 178, 180, 84), 8)
	_pen(c, stand, wood.lightened(0.14), 2604, 4.0)
	var sheet := _pv([Vector2(200, 186), Vector2(312, 186), Vector2(312, 252), Vector2(200, 252)])
	_pen(c, sheet, Color("#fbf8f0"), 2605, 3.5)
	for y in [204.0, 220.0, 236.0]:
		_pline(c, _pv([Vector2(208, y), Vector2(304, y)]), Color("#c4c0d8"), 2.0, 2606 + int(y))
	for n in [Vector2(226, 220), Vector2(252, 212), Vector2(280, 228)]:
		c.draw_circle(n, 5.0, Color("#9690b8"))
	var keybed := _pv([Vector2(90, 300), Vector2(422, 300), Vector2(422, 348), Vector2(90, 348)])
	_pen(c, keybed, Color("#f9f6ee"), 2610, 5.0)
	var keys := 15
	var kw := 300.0 / keys
	for i in range(1, keys):
		var x := 106.0 + i * kw
		_pline(c, _pv([Vector2(x, 302), Vector2(x, 346)]), Color("#c8c3d6"), 2.5, 2611 + i)
	for i in range(1, keys):
		if i % 7 == 3 or i % 7 == 0:
			continue
		var x := 106.0 + i * kw
		_mark(c, Crayon.rounded_rect(Rect2(x - 6, 300, 12, 28), 3), Color("#aaa5c2"), 2630 + i, 3.0)
	_pen(c, _pv([Vector2(90, 300), Vector2(108, 300), Vector2(108, 348), Vector2(90, 348)]), wood, 2650, 4.0)
	_pen(c, _pv([Vector2(404, 300), Vector2(422, 300), Vector2(422, 348), Vector2(404, 348)]), wood, 2651, 4.0)
	_pen(c, Crayon.rounded_rect(Rect2(86, 346, 340, 18), 5), wood.darkened(0.08), 2652, 5.0)
	for x in [132.0, 270.0]:
		_pen(c, Crayon.rounded_rect(Rect2(x, 376, 110, 60), 8), wood.lightened(0.1), 2653 + int(x), 3.5)
	for x in [100.0, 362.0]:
		_pen(c, Crayon.rounded_rect(Rect2(x, 446, 50, 24), 5), wood.darkened(0.1), 2660 + int(x), 4.5)
	for x in [238.0, 274.0]:
		_mark(c, Crayon.ellipse(Vector2(x, 458), Vector2(12, 6), 12), Color("#f2da8a"), 2665 + int(x), 3.0)


## Marker: a four-poster bed built like a little castle - turrets on the posts, a flag.
static func _castle_bed(c: CanvasItem) -> void:
	var stone := Color("#cfc7e4")
	var pink := Color("#f28fb0")
	for x in [128.0, 384.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x - 15, 176, 30, 170), 6), stone.darkened(0.08), 2701 + int(x), 5.0)
		_mark(c, _pv([Vector2(x - 24, 180), Vector2(x, 128), Vector2(x + 24, 180)]), pink.darkened(0.06), 2702 + int(x), 5.0)
	_pen(c, _pv([Vector2(142, 194), Vector2(370, 194), Vector2(370, 340), Vector2(142, 340)]), Color("#e4ddf3"), 2709, 4.0)
	var wall := _crenellated(140, 372, 236, 18, 7, 340)
	_mark(c, wall, stone, 2710, 6.0)
	_mark(c, Crayon.heart(Vector2(256, 284), 40.0), pink, 2711, 4.5)
	for x in [198.0, 314.0]:
		_pen(c, Crayon.blob(Vector2(x, 322), Vector2(60, 25), 2712 + int(x), 20, 0.04), Color("#fbf6ec"), 2713 + int(x), 4.5)
	_pen(c, _pv([Vector2(92, 340), Vector2(420, 340), Vector2(420, 440), Vector2(92, 440)]), Color("#f5f1fb"), 2719, 4.0)
	var blue := Color("#8fb4e8")
	var blanket := PackedVector2Array()
	blanket.append_array(_pv([Vector2(90, 344), Vector2(422, 344)]))
	for i in 7:
		var x0 := 422.0 - i * 332.0 / 7.0
		for p in _arc(Vector2(x0 - 332.0 / 14.0, 404), Vector2(332.0 / 14.0, 12), 0.0, PI, 6):
			if p != blanket[blanket.size() - 1]:
				blanket.append(p)
	_mark(c, blanket, blue, 2720, 6.5)
	_mark(c, Crayon.rounded_rect(Rect2(84, 334, 344, 30), 12), Color("#f6f2fb"), 2721, 5.0)
	for p in [Vector2(140, 400), Vector2(212, 392), Vector2(298, 400), Vector2(370, 392)]:
		_mark(c, Crayon.star(p, 14.0, 2722), Color("#f7dc78"), 2723 + int(p.x), 3.5)
	var foot := _crenellated(92, 420, 434, 14, 9, 456)
	_mark(c, foot, stone, 2730, 6.5)
	for x in [104.0, 386.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 452, 22, 18), 4), stone.darkened(0.1), 2732 + int(x), 4.0)
	_mark(c, Crayon.rounded_rect(Rect2(86, 180, 340, 16), 6), stone.darkened(0.04), 2735, 5.0)
	var drape := PackedVector2Array([Vector2(96, 192), Vector2(416, 192)])
	for i in 6:
		var x0 := 416.0 - i * 320.0 / 6.0
		for p in _arc(Vector2(x0 - 320.0 / 12.0, 214), Vector2(320.0 / 12.0, 18), 0.0, PI, 8):
			if p != drape[drape.size() - 1]:
				drape.append(p)
	_mark(c, drape, pink.lightened(0.15), 2736, 5.0)
	for x in [80.0, 432.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x - 20, 186, 40, 284), 6), stone, 2740 + int(x), 6.0)
		_mark(c, _pv([Vector2(x - 30, 192), Vector2(x, 122), Vector2(x + 30, 192)]), pink, 2741 + int(x), 5.5)
		c.draw_circle(Vector2(x, 116), 7.0, Color("#f7d35e"))
	_pen(c, _band(_pv([Vector2(80, 112), Vector2(80, 52)]), 3.0), Color("#c9a37a"), 2750, 3.0)
	_mark(c, _pv([Vector2(83, 52), Vector2(134, 66), Vector2(83, 82)]), Color("#f7d35e"), 2751, 4.5)


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


# --- Toys ------------------------------------------------------------------------------------

## A tug rope along `curve`: a twisted band in alternating colours, knots, frayed tassel ends.
static func _tug_rope(c: CanvasItem, curve: PackedVector2Array, half: float, base: Color,
		stripes: Array, knots: Array, knot_r: float, seed: int) -> void:
	var length := _path_len(curve)
	var outline: Color = (stripes[0] as Color).darkened(0.45)
	for end in 2:
		var d := 0.0 if end == 0 else length
		var p := _at(curve, d)
		var out := _dir(curve, d) * (-1.0 if end == 0 else 1.0)
		for k in 7:
			var dir := out.rotated((k - 3) * 0.2)
			var col: Color = base if k % 2 == 0 else stripes[(k / 2) % stripes.size()]
			var reach := knot_r + 30.0 + Crayon.noise(seed, k + end * 7) * 8.0
			_mline(c, _pv([p + dir * knot_r * 0.3, p + dir * reach]), col.darkened(0.12), 9.0, seed + k + end * 7)
	var band := _band(curve, half)
	_mfill(c, band, base, seed + 20)
	var w := half * 1.15
	var n := int(length / w)
	for i in n:
		if i % 2 == 1:
			continue
		var d0 := i * w
		var d1 := d0 + w
		var p0 := _at(curve, d0)
		var p1 := _at(curve, d1)
		var tg := _dir(curve, (d0 + d1) * 0.5)
		var nrm := tg.orthogonal() * half * 1.6
		var slant := tg * half * 0.8
		var quad := _pv([p0 + nrm + slant, p1 + nrm + slant, p1 - nrm - slant, p0 - nrm - slant])
		_clip_fill(c, quad, band, stripes[(i / 2) % stripes.size()], seed + 30 + i)
	Crayon.marker_line(c, band, outline, 6.0, seed + 90)
	for k in knots.size():
		var f: float = knots[k]
		var at := _at(curve, f * length)
		var col: Color = stripes[k % stripes.size()]
		var knot := Crayon.blob(at, Vector2(knot_r, knot_r * 0.9), seed + 100 + k, 14, 0.08)
		_mark(c, knot, col, seed + 110 + k, 6.0)
		var turn := _dir(curve, f * length).angle()
		for j in 2:
			var arc := _rot(_arc(at, Vector2(knot_r * 0.55, knot_r * 0.8), -1.1, 1.1, 8), at, turn + (j - 0.5) * 0.9)
			_mline(c, arc, base.lerp(col, 0.15), 6.0, seed + 120 + k * 2 + j)
		c.draw_arc(at + Vector2(-knot_r * 0.3, -knot_r * 0.3), knot_r * 0.35, PI * 1.0, PI * 1.5, 8,
			Color(1, 1, 1, 0.8), 5.0, true)


## Marker: a blue and white rope tug toy with a knot at each end.
static func _rope(c: CanvasItem) -> void:
	var curve := _bez(Vector2(126, 330), Vector2(220, 240), Vector2(300, 330), Vector2(388, 184), 30)
	_tug_rope(c, curve, 27.0, Color("#f6f3ec"), [Color("#69a6df")], [0.0, 1.0], 46.0, 3001)


## Marker: an orange flying disc tilted towards us, its thick rim showing underneath.
static func _frisbee(c: CanvasItem) -> void:
	var centre := Vector2(256, 256)
	var tilt := -0.18
	var orange := Color("#f59b4f")
	var under := _rot(Crayon.ellipse(centre + Vector2(0, 16), Vector2(196, 80), 48), centre, tilt)
	_mark(c, under, orange.darkened(0.14), 3101, 7.0)
	var top := _rot(Crayon.ellipse(centre - Vector2(0, 6), Vector2(196, 80), 48), centre, tilt)
	_mark(c, top, orange, 3102, 7.0)
	Crayon.marker_line(c, _rot(Crayon.ellipse(centre - Vector2(0, 8), Vector2(148, 58), 40), centre, tilt),
		orange.darkened(0.3), 5.0, 3103)
	Crayon.marker_line(c, _rot(Crayon.ellipse(centre - Vector2(0, 10), Vector2(86, 32), 32), centre, tilt),
		orange.lightened(0.3), 5.0, 3104)
	_mline(c, _rot(_arc(centre - Vector2(0, 8), Vector2(170, 66), PI * 1.08, PI * 1.38, 10), centre, tilt),
		Color(1, 1, 1, 0.85), 8.0, 3105)


## Pencil: a good stick - a fork, a twig with a leaf, cut ends showing pale wood.
static func _stick(c: CanvasItem) -> void:
	var wood := Color("#c99e72")
	var main := _pv([Vector2(86, 340), Vector2(190, 302), Vector2(300, 278), Vector2(428, 214)])
	var twig := _pv([Vector2(286, 282), Vector2(318, 230), Vector2(330, 196)])
	var nub := _pv([Vector2(170, 310), Vector2(150, 352)])
	var leaf := _leaf(Vector2(352, 152), 100, 50, -1.05)
	var green := Color("#8ccd6e")
	_pen(c, leaf, green, 3201, 4.5)
	_pline(c, _pv([Vector2(330, 196), Vector2(352, 152), Vector2(374, 110)]), green.darkened(0.3), 3.0, 3202)
	var shape := _union([_band(main, 19.0), _band(twig, 10.0), _band(nub, 10.0)])
	_pen(c, shape, wood, 3203, 5.0)
	_shade(c, shape, wood, 3204, Vector2(0, -12), 0.16)
	for s in [[Vector2(120, 330), Vector2(160, 316)], [Vector2(230, 296), Vector2(270, 288)],
			[Vector2(340, 260), Vector2(380, 240)]]:
		_pline(c, _pv([s[0], s[1]]), wood.darkened(0.32), 3.0, 3205 + int((s[0] as Vector2).x))
	_pen(c, Crayon.ellipse(Vector2(214, 296), Vector2(10, 6), 12), wood.darkened(0.15), 3210, 3.0)
	for e in [[Vector2(86, 340), -0.35], [Vector2(428, 214), -0.45]]:
		var at: Vector2 = e[0]
		var cap := _rot(Crayon.ellipse(at, Vector2(8, 15), 14), at, e[1])
		_pen(c, cap, Color("#efd5a9"), 3215 + int(at.x), 3.5)


## Marker: a yellow rubber duck with an orange beak.
static func _duck(c: CanvasItem) -> void:
	var yellow := Color("#f9d65a")
	var tail := _smooth(_pv([Vector2(150, 252), Vector2(92, 208), Vector2(104, 300), Vector2(160, 340)]), 1)
	var body := Crayon.ellipse(Vector2(246, 320), Vector2(148, 90), 40)
	var head := _circle(Vector2(322, 190), 74.0, 36)
	var duck := _union([body, tail, head])
	_mark(c, duck, yellow, 3301, 7.5)
	_shade(c, duck, yellow, 3302, Vector2(-26, -26), 0.12)
	var wing := _rot(_smooth(_pv([Vector2(150, 300), Vector2(210, 264), Vector2(290, 280), Vector2(270, 340),
		Vector2(196, 348)]), 2), Vector2(220, 306), -0.1)
	_mark(c, wing, Color("#f6c443"), 3303, 5.0)
	_pline(c, _pv([Vector2(200, 300), Vector2(250, 296)]), Color("#d7a52e"), 3.0, 3304)
	_pline(c, _pv([Vector2(206, 320), Vector2(256, 318)]), Color("#d7a52e"), 3.0, 3305)
	var beak := _smooth(_pv([Vector2(378, 170), Vector2(446, 180), Vector2(454, 198), Vector2(390, 218)]), 2)
	_mark(c, beak, Color("#f59a4c"), 3306, 5.0)
	_pline(c, _pv([Vector2(390, 197), Vector2(446, 194)]), Color("#d0743a"), 3.0, 3307)
	c.draw_circle(Vector2(344, 170), 11.0, Color("#5f6a8a"))
	c.draw_circle(Vector2(340, 166), 4.0, Color(1, 1, 1, 0.95))
	c.draw_circle(Vector2(352, 210), 13.0, Color(0.96, 0.55, 0.6, 0.35))
	_mline(c, _arc(Vector2(300, 176), Vector2(52, 52), PI * 1.1, PI * 1.4, 8), Color(1, 1, 1, 0.8), 7.0, 3308)


## Pencil: a small soft teddy bear sitting with its legs out.
static func _teddy(c: CanvasItem) -> void:
	var fur := Color("#c99466")
	var pale := Color("#efd0ac")
	for x in [182.0, 330.0]:
		_pen(c, _circle(Vector2(x, 106), 36.0, 24), fur, 3401 + int(x), 5.0)
		_pen(c, _circle(Vector2(x, 108), 18.0, 18), pale, 3402 + int(x), 3.5)
	var body := Crayon.blob(Vector2(256, 330), Vector2(102, 106), 3405, 20, 0.03)
	_pen(c, body, fur, 3406, 5.0)
	_pen(c, Crayon.ellipse(Vector2(256, 344), Vector2(58, 62), 24), pale, 3407, 3.5)
	for side: float in [-1.0, 1.0]:
		var at := Vector2(256 + side * 72, 418)
		var leg := Crayon.ellipse(at, Vector2(52, 42), 24)
		_pen(c, leg, fur, 3410 + int(side), 5.0)
		_pen(c, Crayon.ellipse(at + Vector2(side * 4, 4), Vector2(28, 24), 20), pale, 3412 + int(side), 3.5)
		var arm := _rot(Crayon.ellipse(Vector2(256 + side * 102, 318), Vector2(32, 56), 22), Vector2(256 + side * 102, 318), -side * 0.5)
		_pen(c, arm, fur, 3414 + int(side), 5.0)
	var head := Crayon.blob(Vector2(256, 184), Vector2(100, 86), 3420, 22, 0.025)
	_pen(c, head, fur, 3421, 5.0)
	_shade(c, head, fur, 3422, Vector2(-20, -20), 0.12)
	_pen(c, Crayon.ellipse(Vector2(256, 214), Vector2(44, 32), 22), pale, 3423, 3.5)
	_mark(c, Crayon.ellipse(Vector2(256, 200), Vector2(17, 11), 14), Color("#a87664"), 3424, 3.0)
	_pline(c, _pv([Vector2(256, 210), Vector2(256, 226)]), Color("#8f6656"), 3.5, 3425)
	_pline(c, _arc(Vector2(244, 226), Vector2(12, 8), 0.2, PI - 0.4, 6), Color("#8f6656"), 3.5, 3426)
	_pline(c, _arc(Vector2(268, 226), Vector2(12, 8), 0.4, PI - 0.2, 6), Color("#8f6656"), 3.5, 3427)
	for e in [Vector2(218, 172), Vector2(294, 172)]:
		c.draw_circle(e, 9.5, Color("#6f5650"))
		c.draw_circle(e + Vector2(-3, -3), 3.0, Color(1, 1, 1, 0.9))
	var bow := Color("#f08fae")
	_mark(c, _pv([Vector2(256, 268), Vector2(216, 250), Vector2(216, 288)]), bow, 3430, 4.5)
	_mark(c, _pv([Vector2(256, 268), Vector2(296, 250), Vector2(296, 288)]), bow, 3431, 4.5)
	_mark(c, _circle(Vector2(256, 268), 11.0, 12), bow, 3432, 4.0)


## Marker: a green treat ball with pale holes, a biscuit poking out of one.
static func _puzzle_ball(c: CanvasItem) -> void:
	var green := Color("#91d07d")
	var ball := _circle(Vector2(256, 256), 150.0, 48)
	_mark(c, ball, green, 3501, 7.5)
	_shade(c, ball, green, 3502, Vector2(-30, -30), 0.12)
	var hole := Color("#e4def2")
	for h in [[Vector2(250, 262), Vector2(42, 42), 0.0], [Vector2(140, 228), Vector2(20, 38), 0.2],
			[Vector2(374, 244), Vector2(22, 38), -0.15], [Vector2(244, 144), Vector2(38, 18), 0.05],
			[Vector2(268, 374), Vector2(40, 20), -0.05], [Vector2(170, 340), Vector2(22, 18), 0.6]]:
		var at: Vector2 = h[0]
		var poly := _rot(Crayon.ellipse(at, h[1], 24), at, h[2])
		_pen(c, poly, hole, 3510 + int(at.x), 4.5)
		_shade(c, poly, hole, 3511 + int(at.x), Vector2(0, 10), 0.14)
	var biscuit := Color("#e6b77f")
	var at := Vector2(300, 220)
	var bone := _union([_band(_pv([Vector2(262, 252), Vector2(330, 190)]), 13.0),
		_circle(Vector2(326, 176), 15.0, 14), _circle(Vector2(344, 196), 15.0, 14)])
	_pen(c, bone, biscuit, 3530, 4.5)
	c.draw_circle(at + Vector2(10, -6), 3.0, biscuit.darkened(0.3))
	c.draw_circle(at + Vector2(-6, 8), 3.0, biscuit.darkened(0.3))
	c.draw_arc(Vector2(256, 256), 120.0, PI * 1.12, PI * 1.38, 12, Color(1, 1, 1, 0.85), 10.0, true)


## Marker, gold: a ball with a big star on it.
static func _shiny_ball(c: CanvasItem) -> void:
	var gold := Color("#f6e39c")
	var ball := _circle(Vector2(256, 256), 150.0, 48)
	_mark(c, ball, gold, 3601, 7.5)
	_shade(c, ball, gold, 3602, Vector2(-34, -34), 0.16)
	var star := _smooth(Crayon.star(Vector2(256, 262), 96.0, 3603), 1)
	_mark(c, star, Color("#fffbe8"), 3604, 6.0)
	_gleam(c, ball, 3605, Vector2(20, 20), 0.55)
	c.draw_arc(Vector2(256, 256), 118.0, PI * 1.12, PI * 1.4, 12, Color(1, 1, 1, 0.95), 11.0, true)
	_twinkle(c, Vector2(372, 124), 26.0, Color("#d8b44e"), 3606)


## Marker, gold: a classic chew bone, lying on a slant.
static func _golden_bone(c: CanvasItem) -> void:
	var a := Vector2(150, 334)
	var b := Vector2(362, 178)
	var bone := _bone_shape(a, b, 32.0, 40.0)
	var gold := Color("#f6e39c")
	_mark(c, bone, gold, 3701, 7.5)
	_shade(c, bone, gold, 3702, Vector2(-14, -22), 0.18)
	var t := (b - a).normalized()
	var n := t.orthogonal()
	_mline(c, _pv([a + t * 50 + n * 14, b - t * 50 + n * 14]), Color(1, 1, 1, 0.85), 8.0, 3703)
	_twinkle(c, Vector2(140, 170), 24.0, Color("#d8b44e"), 3704)


## A bone: a bar from a to b with two round knobs at each end.
static func _bone_shape(a: Vector2, b: Vector2, half: float, knob: float) -> PackedVector2Array:
	var t := (b - a).normalized()
	var n := t.orthogonal()
	var parts := [_band(_pv([a, b]), half)]
	for end in [[a, -1.0], [b, 1.0]]:
		var p: Vector2 = end[0]
		var s: float = end[1]
		parts.append(_circle(p + n * knob * 0.72 + t * s * knob * 0.25, knob, 24))
		parts.append(_circle(p - n * knob * 0.72 + t * s * knob * 0.25, knob, 24))
	return _union(parts)


## Marker, glitter: a pale pink flying disc with swirls and sparkles.
static func _glitter_disc(c: CanvasItem) -> void:
	var centre := Vector2(256, 256)
	var tilt := 0.16
	var pink := Color("#f6c3da")
	_mark(c, _rot(Crayon.ellipse(centre + Vector2(0, 16), Vector2(196, 82), 48), centre, tilt), Color("#d9bde9"), 3801, 7.0)
	var top := _rot(Crayon.ellipse(centre - Vector2(0, 6), Vector2(196, 82), 48), centre, tilt)
	_mark(c, top, pink, 3802, 7.0)
	for k in 3:
		var swirl := PackedVector2Array()
		for i in 22:
			var t := i / 21.0
			var a := k * TAU / 3.0 + t * 3.6
			var r := 18.0 + t * 150.0
			swirl.append(centre - Vector2(0, 6) + Vector2(cos(a) * r, sin(a) * r * 0.4))
		swirl = _rot(swirl, centre, tilt)
		var col: Color = [Color("#fdf1f7"), Color("#cdb6ef"), Color("#fdf1f7")][k]
		_mline(c, swirl, col, 7.0, 3803 + k)
	for s in [Vector3(170, 236, 14), Vector3(330, 300, 12), Vector3(300, 220, 9), Vector3(206, 292, 8),
			Vector3(380, 244, 10)]:
		var v: Vector3 = s
		_twinkle(c, Vector2(v.x, v.y), v.z, Color("#d68fbf"), 3810 + int(v.x))
	_twinkle(c, Vector2(404, 140), 26.0, Color("#d68fbf"), 3820)


## Marker, rainbow: a long pale tug rope in pastel bands with three knots.
static func _rainbow_rope(c: CanvasItem) -> void:
	var curve := _bez(Vector2(106, 300), Vector2(196, 170), Vector2(316, 352), Vector2(406, 214), 34)
	var colors := [Color("#f5a6a6"), Color("#f7cf92"), Color("#f4e79a"), Color("#ade0a6"),
		Color("#a3c9f1"), Color("#c9afec")]
	_tug_rope(c, curve, 25.0, Color("#fbf7ef"), colors, [0.0, 0.5, 1.0], 42.0, 3901)


## Marker, silver: a rubber duck cut like a gem, every facet a different pale grey-blue.
static func _crystal_squeaker(c: CanvasItem) -> void:
	var T := Vector2(98, 236)
	var A1 := Vector2(160, 292)
	var A2 := Vector2(250, 298)
	var A3 := Vector2(318, 262)
	var K1 := Vector2(296, 200)
	var K2 := Vector2(322, 136)
	var K3 := Vector2(382, 116)
	var K4 := Vector2(426, 150)
	var K5 := Vector2(426, 222)
	var F1 := Vector2(412, 264)
	var F2 := Vector2(422, 322)
	var U1 := Vector2(372, 382)
	var U2 := Vector2(270, 400)
	var U3 := Vector2(180, 382)
	var U4 := Vector2(122, 328)
	var I1 := Vector2(238, 342)
	var I2 := Vector2(352, 320)
	var I3 := Vector2(362, 182)
	var tris := [[T, A1, U4], [A1, I1, U4], [U4, I1, U3], [U3, I1, U2], [A1, A2, I1], [A2, I2, I1],
		[I1, I2, U2], [U2, I2, U1], [U1, I2, F2], [F2, I2, F1], [A2, A3, I2], [A3, F1, I2],
		[A3, K1, I3], [K1, K2, I3], [K2, K3, I3], [K3, K4, I3], [K4, K5, I3], [K5, F1, I3], [F1, A3, I3]]
	var light := Vector2(-0.6, -0.8)
	var centre := Vector2(270, 270)
	for i in tris.size():
		var tri: Array = tris[i]
		var poly := _pv(tri)
		var mid: Vector2 = ((tri[0] as Vector2) + (tri[1] as Vector2) + (tri[2] as Vector2)) / 3.0
		var k := clampf(0.5 + 0.5 * ((mid - centre).normalized().dot(light)) + Crayon.noise(3950, i) * 0.22, 0.0, 1.0)
		var col := Color("#aebbd2").lerp(Color("#f4f7fc"), k)
		_mfill(c, poly, col, 3960 + i)
	var edge := Color("#8e9cb8")
	for i in tris.size():
		var tri: Array = tris[i]
		Crayon.marker_line(c, _pv(tri), edge.lightened(0.15), 3.0, 4000 + i)
	var beak := _pv([Vector2(420, 166), Vector2(476, 186), Vector2(420, 208)])
	_mfill(c, beak, Color("#c8cfe0"), 4030)
	_mfill(c, _pv([Vector2(420, 166), Vector2(476, 186), Vector2(430, 186)]), Color("#eef1f8"), 4031)
	Crayon.marker_line(c, beak, edge, 4.0, 4032)
	var outline := _pv([T, A1, A2, A3, K1, K2, K3, K4, Vector2(420, 166), Vector2(420, 208), K5, F1, F2, U1, U2, U3, U4])
	Crayon.marker_line(c, outline, Color("#7d8ba8"), 7.0, 4033)
	_mfill(c, _pv([Vector2(384, 158), Vector2(394, 168), Vector2(384, 178), Vector2(374, 168)]), Color("#7d8aa6"), 4034)
	_twinkle(c, Vector2(338, 152), 18.0, Color("#93a3c6"), 4035)
	_twinkle(c, Vector2(196, 312), 14.0, Color("#93a3c6"), 4036)


## Pencil, gold: a puffy star plushie with a sewn seam and a smile.
static func _star_plush(c: CanvasItem) -> void:
	var gold := Color("#f6df92")
	var star := _smooth(Crayon.star(Vector2(256, 270), 214.0, 4101), 3)
	_pen(c, star, gold, 4102, 6.0)
	_shade(c, star, gold, 4103, Vector2(-22, -24), 0.18)
	_gleam(c, star, 4104, Vector2(14, 16), 0.5)
	var seam := Geometry2D.offset_polygon(star, -16.0)
	if not seam.is_empty():
		_stitch(c, seam[0], gold.darkened(0.3), 3.0, 4105)
	var eye := Color("#7d6a55")
	for e in [Vector2(222, 262), Vector2(290, 262)]:
		c.draw_circle(e, 11.0, eye)
		c.draw_circle(e + Vector2(-3.5, -3.5), 3.5, Color(1, 1, 1, 0.95))
	_pline(c, _arc(Vector2(256, 282), Vector2(26, 20), 0.35, PI - 0.35, 10), eye, 5.0, 4106)
	for e in [Vector2(196, 296), Vector2(316, 296)]:
		c.draw_circle(e, 14.0, Color(0.96, 0.6, 0.62, 0.45))


## Marker, rainbow: a chunky puzzle cube, three faces of pastel squares.
static func _puzzle_cube(c: CanvasItem) -> void:
	var top := Vector2(256, 84)
	var left := Vector2(102, 166)
	var right := Vector2(410, 166)
	var mid := Vector2(256, 248)
	var left_b := Vector2(102, 348)
	var right_b := Vector2(410, 348)
	var bottom := Vector2(256, 430)
	var frame := Color("#d8dbe8")
	var faces := [[top, right, mid, left, 0.12], [left, mid, bottom, left_b, 0.0], [mid, right, right_b, bottom, -0.1]]
	var colors := [Color("#f6a5a5"), Color("#f8c98f"), Color("#f5e396"), Color("#a9dca2"),
		Color("#9fc8f0"), Color("#c8aef0")]
	var hull := _pv([top, right, right_b, bottom, left_b, left])
	_mfill(c, hull, frame, 4201)
	for f in faces.size():
		var face: Array = faces[f]
		var a: Vector2 = face[0]
		var b: Vector2 = face[1]
		var cc: Vector2 = face[2]
		var d: Vector2 = face[3]
		var tone: float = face[4]
		for i in 3:
			for j in 3:
				var g := 0.04
				var cell := _round_corners(_cell(a, b, cc, d, i / 3.0 + g, (i + 1) / 3.0 - g, j / 3.0 + g, (j + 1) / 3.0 - g), 0.2)
				var pick := int(absf(Crayon.noise(4210 + f, i * 3 + j)) * 60.0 + f * 2 + i + j) % colors.size()
				var col: Color = colors[pick]
				col = col.lightened(tone) if tone > 0.0 else col.darkened(-tone)
				_mark(c, cell, col, 4220 + f * 9 + i * 3 + j, 3.5)
	Crayon.marker_line(c, _pv([left, mid, right]), frame.darkened(0.3), 5.0, 4260)
	Crayon.marker_line(c, _pv([mid, bottom]), frame.darkened(0.3), 5.0, 4261)
	Crayon.marker_line(c, hull, frame.darkened(0.45), 7.5, 4262)


## Marker, gold: a ball with fins and hot-rod flames, whooshing to the right on a flame trail.
static func _rocket_ball(c: CanvasItem) -> void:
	var peach := Color("#f8c08a")
	var trail := _smooth(_pv([Vector2(186, 206), Vector2(120, 196), Vector2(140, 222), Vector2(56, 226),
		Vector2(108, 256), Vector2(36, 286), Vector2(140, 290), Vector2(120, 316), Vector2(186, 306)]), 2)
	_mark(c, trail, peach, 4301, 5.5)
	var inner := _smooth(_pv([Vector2(190, 230), Vector2(140, 236), Vector2(110, 258), Vector2(140, 278),
		Vector2(190, 284)]), 2)
	_mfill(c, inner, Color("#fdf0bf"), 4302)
	var fin := Color("#f3d58c")
	var top_fin := _pv([Vector2(232, 150), Vector2(150, 92), Vector2(134, 104), Vector2(170, 196)])
	var bot_fin := _pv([Vector2(232, 362), Vector2(150, 420), Vector2(134, 408), Vector2(170, 316)])
	_mark(c, _round_corners(top_fin, 0.15), fin, 4303, 6.0)
	_mark(c, _round_corners(bot_fin, 0.15), fin, 4304, 6.0)
	var centre := Vector2(292, 256)
	var ball := _circle(centre, 134.0, 48)
	var gold := Color("#f7e6a0")
	_mfill(c, ball, gold, 4305)
	var flame := _smooth(_pv([Vector2(140, 176), Vector2(250, 196), Vector2(318, 168), Vector2(296, 214),
		Vector2(392, 220), Vector2(316, 252), Vector2(398, 290), Vector2(300, 292), Vector2(330, 336),
		Vector2(240, 312), Vector2(140, 336)]), 1)
	_clip_fill(c, flame, ball, Color("#f6ae74"), 4306)
	var core := _smooth(_pv([Vector2(140, 222), Vector2(236, 232), Vector2(282, 222), Vector2(262, 252),
		Vector2(300, 276), Vector2(236, 280), Vector2(140, 290)]), 1)
	_clip_fill(c, core, ball, Color("#fbd98c"), 4307)
	_shade(c, ball, gold, 4308, Vector2(-30, -30), 0.16)
	Crayon.marker_line(c, ball, gold.darkened(0.48), 7.5, 4309)
	c.draw_arc(centre, 106.0, PI * 1.14, PI * 1.42, 12, Color(1, 1, 1, 0.95), 10.0, true)


## Rounds a polygon's corners: each corner is cut back by `f` of its edges and bent smooth.
static func _round_corners(poly: PackedVector2Array, f: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var n := poly.size()
	for i in n:
		var p := poly[i]
		var prev := poly[(i - 1 + n) % n]
		var next := poly[(i + 1) % n]
		var a := p.lerp(prev, f)
		var b := p.lerp(next, f)
		for k in 5:
			var t := k / 4.0
			out.append(a.lerp(p, t).lerp(p.lerp(b, t), t))
	return out


# --- Food ------------------------------------------------------------------------------------

## Pencil: a red apple with a stalk and a leaf.
static func _apple(c: CanvasItem) -> void:
	var red := Color("#e8605e")
	var apple := _union([_circle(Vector2(212, 290), 116.0, 40), _circle(Vector2(300, 290), 116.0, 40),
		Crayon.ellipse(Vector2(256, 330), Vector2(120, 90), 32)])
	var green := Color("#8ccd6e")
	_pline(c, _pv([Vector2(256, 196), Vector2(258, 150), Vector2(270, 116)]), Color("#a8805e"), 10.0, 4401)
	_pen(c, apple, red, 4402, 5.5)
	_shade(c, apple, red, 4403, Vector2(-30, -26), 0.18)
	_pfill(c, _rot(Crayon.ellipse(Vector2(186, 250), Vector2(22, 40), 16), Vector2(186, 250), 0.5), Color(1, 1, 1, 0.75), 4404)
	_pline(c, _arc(Vector2(256, 196), Vector2(22, 10), 0.3, PI - 0.3, 6), red.darkened(0.35), 3.5, 4405)
	var leaf := _leaf(Vector2(320, 128), 104, 48, -0.35)
	_pen(c, leaf, green, 4406, 4.5)
	_pline(c, _pv([Vector2(272, 144), Vector2(320, 128), Vector2(366, 112)]), green.darkened(0.3), 3.0, 4407)


## Pencil: a cartoon bone with a fat pink chunk of meat round its middle.
static func _meaty_bone(c: CanvasItem) -> void:
	var bone := _bone_shape(Vector2(128, 318), Vector2(384, 194), 24.0, 32.0)
	var cream := Color("#f3e8d4")
	_pen(c, bone, cream, 4501, 5.0)
	_shade(c, bone, cream, 4502, Vector2(-10, -14), 0.14)
	var meat := _rot(Crayon.blob(Vector2(256, 256), Vector2(112, 80), 4503, 20, 0.06), Vector2(256, 256), -0.45)
	var pink := Color("#f19a9a")
	_pen(c, meat, pink, 4504, 5.5)
	_shade(c, meat, pink, 4505, Vector2(-24, -24), 0.16)
	var fat := Color("#fbdada")
	_pline(c, _rot(_arc(Vector2(250, 250), Vector2(70, 34), PI * 1.1, PI * 1.6, 10), Vector2(256, 256), -0.45), fat, 6.0, 4506)
	_pline(c, _rot(_arc(Vector2(270, 270), Vector2(56, 26), PI * 0.1, PI * 0.5, 8), Vector2(256, 256), -0.45), fat, 5.0, 4507)
	_pfill(c, _rot(Crayon.ellipse(Vector2(214, 226), Vector2(24, 12), 14), Vector2(214, 226), -0.45), Color(1, 1, 1, 0.7), 4508)


## Pencil: a blue-silver fish swimming left, pale belly, scales and fins.
static func _fish(c: CanvasItem) -> void:
	c.draw_set_transform(Vector2(0, 22))
	var blue := Color("#94bfe2")
	var fin := Color("#7fb0dc")
	var tail := _smooth(_pv([Vector2(364, 256), Vector2(444, 184), Vector2(426, 256), Vector2(444, 328)]), 1)
	_pen(c, tail, fin, 4601, 5.0)
	var dorsal := _smooth(_pv([Vector2(196, 186), Vector2(248, 126), Vector2(300, 146), Vector2(316, 196)]), 1)
	_pen(c, dorsal, fin, 4602, 5.0)
	var body := _smooth(_pv([Vector2(92, 262), Vector2(138, 198), Vector2(222, 170), Vector2(304, 184),
		Vector2(366, 232), Vector2(384, 256), Vector2(366, 282), Vector2(304, 322), Vector2(222, 336),
		Vector2(138, 318)]), 2)
	_pfill(c, body, blue, 4603)
	var belly := _pv([Vector2(60, 268), Vector2(420, 268), Vector2(420, 360), Vector2(60, 360)])
	_clip_fill(c, belly, body, Color("#e0ebf5"), 4604, false)
	var scale := blue.darkened(0.22)
	for row in 3:
		for i in 3 - row % 2:
			var at := Vector2(232 + i * 40 + (row % 2) * 20, 210 + row * 24)
			_pline(c, _arc(at, Vector2(11, 12), -PI * 0.55, PI * 0.55, 6), scale, 3.0, 4610 + row * 4 + i)
	Crayon.pencil_line(c, body, blue.darkened(0.45), 5.5, 4620)
	_pline(c, _arc(Vector2(150, 256), Vector2(30, 46), -PI * 0.42, PI * 0.42, 10), blue.darkened(0.35), 4.0, 4621)
	_pen(c, _leaf(Vector2(212, 290), 66, 30, 2.6), fin, 4622, 4.0)
	_pen(c, _circle(Vector2(128, 238), 17.0, 18), Color("#fbfcff"), 4623, 3.5)
	c.draw_circle(Vector2(124, 238), 8.0, Color("#5f6d8f"))
	c.draw_circle(Vector2(121, 235), 2.8, Color(1, 1, 1, 0.95))
	_pline(c, _pv([Vector2(96, 268), Vector2(112, 272)]), blue.darkened(0.4), 3.5, 4624)
	_pline(c, _arc(Vector2(250, 214), Vector2(80, 24), PI * 1.15, PI * 1.6, 8), Color(1, 1, 1, 0.8), 5.0, 4625)
	c.draw_set_transform(Vector2.ZERO)


## Pencil: a slice of layer cake - pink icing, sponge and cream, a cherry on top.
static func _cake(c: CanvasItem) -> void:
	c.draw_set_transform(Vector2(0, -36))
	var t0 := Vector2(96, 302)
	var t2 := Vector2(424, 262)
	var b2 := Vector2(424, 400)
	var b0 := Vector2(96, 426)
	var bands := [[0.0, 0.16, Color("#f6b2c6")], [0.16, 0.44, Color("#f4d48a")], [0.44, 0.56, Color("#fbf0dd")],
		[0.56, 0.62, Color("#ee8aa6")], [0.62, 0.9, Color("#f4d48a")], [0.9, 1.0, Color("#e9be78")]]
	for i in bands.size():
		var band: Array = bands[i]
		var poly := _cell(t0, t2, b2, b0, 0.0, 1.0, band[0], band[1])
		_pfill(c, poly, band[2], 4701 + i)
	var side := _pv([t0, t2, b2, b0])
	for i in 18:
		var p := _bil(t0, t2, b2, b0, 0.05 + i * 0.05, 0.3 + 0.5 * absf(Crayon.noise(4710, i)))
		c.draw_circle(p, 2.5, Color("#dcae62"))
	Crayon.pencil_line(c, side, Color("#d39a5a"), 5.0, 4711)
	var top := PackedVector2Array([t0])
	for p in _bez(Vector2(350, 212), Vector2(384, 216), Vector2(414, 236), t2, 8):
		top.append(p)
	var pink := Color("#f6b8cb")
	var drips := []
	for d in [Vector3(0.12, 26, 12), Vector3(0.3, 12, 9), Vector3(0.49, 34, 13), Vector3(0.68, 16, 10),
			Vector3(0.86, 28, 12)]:
		var v: Vector3 = d
		var p := t0.lerp(t2, v.x)
		drips.append(_band(_pv([p, p + Vector2(0, v.y)]), v.z))
	var icing := _smooth(_union([top] + drips), 1)
	_pen(c, icing, pink, 4721, 5.0)
	_gleam(c, icing, 4722, Vector2(10, 12), 0.4)
	var sprinkles := [Color("#9fc8f0"), Color("#f7dc78"), Color("#a9dca2"), Color("#c8aef0")]
	for i in 8:
		var p := _bil(t0, Vector2(350, 212), t2, t2, 0.25 + 0.6 * absf(Crayon.noise(4730, i)), 0.15 + 0.6 * absf(Crayon.noise(4731, i)))
		var d := Vector2(7, 0).rotated(Crayon.noise(4732, i) * PI)
		_mline(c, _pv([p - d, p + d]), sprinkles[i % 4], 5.0, 4733 + i)
	_pline(c, _bez(Vector2(366, 214), Vector2(370, 190), Vector2(388, 172), Vector2(404, 160), 8), Color("#8fb26a"), 5.0, 4745)
	var cherry := _circle(Vector2(362, 218), 28.0, 24)
	_mark(c, cherry, Color("#e64f5c"), 4746, 5.0)
	c.draw_circle(Vector2(352, 208), 6.0, Color(1, 1, 1, 0.85))
	c.draw_set_transform(Vector2.ZERO)


## Pencil: a carrot on a slant with feathery green leaves.
static func _carrot(c: CanvasItem) -> void:
	var green := Color("#82c46c")
	var a := Vector2(356, 168)
	var b := Vector2(146, 404)
	for l in [[Vector2(384, 100), -0.9], [Vector2(420, 132), -0.45], [Vector2(346, 92), -1.35]]:
		var at: Vector2 = l[0]
		var ang: float = l[1]
		_pline(c, _pv([a, at]), green.darkened(0.2), 6.0, 4801 + int(at.x))
		_pen(c, _leaf(at + Vector2(cos(ang), sin(ang)) * 30, 96, 40, ang), green, 4802 + int(at.x), 4.5)
	var t := (b - a).normalized()
	var n := t.orthogonal()
	var length := a.distance_to(b)
	var pts := PackedVector2Array()
	for k in [[0.0, 46.0], [0.3, 42.0], [0.6, 30.0], [0.85, 15.0]]:
		pts.append(a + t * length * k[0] + n * k[1])
	pts.append(b)
	for k in [[0.85, 15.0], [0.6, 30.0], [0.3, 42.0], [0.0, 46.0]]:
		pts.append(a + t * length * k[0] - n * k[1])
	pts.append(a - t * 22)
	var carrot := _smooth(pts, 2)
	var orange := Color("#f59c4e")
	_pen(c, carrot, orange, 4810, 5.5)
	_shade(c, carrot, orange, 4811, -n * 20, 0.16)
	for i in 6:
		var f := 0.14 + i * 0.13
		var w := lerpf(40.0, 14.0, f) * 0.6
		var side := 1.0 if i % 2 == 0 else -1.0
		var p := a + t * length * f + n * side * w * 0.9
		_pline(c, _pv([p, p - n * side * w * 0.8 + t * 4]), orange.darkened(0.3), 3.5, 4820 + i)


## Pencil: a round golden cookie with a bite out of it and brown chips.
static func _cookie(c: CanvasItem) -> void:
	var cookie := Crayon.blob(Vector2(256, 256), Vector2(160, 156), 4901, 32, 0.035)
	for bite in [Vector3(392, 136, 46), Vector3(424, 190, 38), Vector3(352, 108, 36)]:
		var v: Vector3 = bite
		cookie = _biggest(Geometry2D.clip_polygons(cookie, _circle(Vector2(v.x, v.y), v.z, 20)))
	var tan_col := Color("#e5b46e")
	_pen(c, cookie, tan_col, 4902, 5.5)
	var inner := Geometry2D.offset_polygon(cookie, -20.0)
	if not inner.is_empty():
		for piece in Geometry2D.clip_polygons(cookie, inner[0]):
			Crayon.pencil_fill(c, piece, tan_col.darkened(0.14), 4903)
	var chip := Color("#966448")
	var chips := [Vector2(190, 190), Vector2(270, 170), Vector2(330, 250), Vector2(220, 280),
		Vector2(150, 260), Vector2(290, 330), Vector2(200, 356), Vector2(360, 330), Vector2(256, 234)]
	for i in chips.size():
		var at: Vector2 = chips[i]
		_pen(c, Crayon.blob(at, Vector2(15, 13), 4910 + i, 8, 0.25), chip, 4920 + i, 3.0)
	for i in 10:
		var p := Vector2(200 + absf(Crayon.noise(4940, i)) * 140.0, 180 + absf(Crayon.noise(4941, i)) * 160.0)
		c.draw_circle(p, 2.5, tan_col.darkened(0.3))
	for crumb in [Vector3(430, 120, 8), Vector3(446, 150, 5), Vector3(410, 96, 6)]:
		var v: Vector3 = crumb
		_pen(c, Crayon.blob(Vector2(v.x, v.y), Vector2(v.z, v.z), 4950 + int(v.x), 8, 0.2), tan_col, 4951 + int(v.x), 2.5)


## A ladybird at `at` facing `angle`: marker shell, pale rose-grey head and spots.
static func _ladybird(c: CanvasItem, at: Vector2, angle: float, seed: int) -> void:
	c.draw_set_transform(at, angle)
	var dark := Color("#7f6b8c")
	for side: float in [-1.0, 1.0]:
		for k in 3:
			var x := -14.0 + k * 14.0
			_pline(c, _pv([Vector2(x, side * 20), Vector2(x - 6, side * 38)]), dark, 3.5, seed + k + int(side) * 5)
	_mark(c, _circle(Vector2(30, 0), 16.0, 16), dark.lightened(0.15), seed + 10, 4.0)
	var shell := Crayon.ellipse(Vector2(-4, 0), Vector2(36, 30), 24)
	_mark(c, shell, Color("#e85c5a"), seed + 11, 5.0)
	_mline(c, _pv([Vector2(30, 0), Vector2(-38, 0)]), Color("#a8434a"), 3.5, seed + 12)
	for p in [Vector2(-14, -14), Vector2(-14, 14), Vector2(10, -16), Vector2(10, 16), Vector2(-30, -6), Vector2(-30, 6)]:
		c.draw_circle(p, 5.5, dark)
	for e in [Vector2(36, -7), Vector2(36, 7)]:
		c.draw_circle(e, 3.5, Color(1, 1, 1, 0.95))
	c.draw_arc(Vector2(-4, 0), 24.0, PI * 1.15, PI * 1.45, 6, Color(1, 1, 1, 0.75), 4.0, true)
	c.draw_set_transform(Vector2.ZERO)


## A beetle at `at` facing `angle`: a long teal shell with a split down the middle.
static func _beetle(c: CanvasItem, at: Vector2, angle: float, seed: int) -> void:
	c.draw_set_transform(at, angle)
	var leg := Color("#5f8f8a")
	for side: float in [-1.0, 1.0]:
		for k in 3:
			var x := -20.0 + k * 18.0
			_pline(c, _pv([Vector2(x, side * 22), Vector2(x - 4, side * 34), Vector2(x - 12, side * 42)]), leg, 3.5, seed + k + int(side) * 5)
		_pline(c, _pv([Vector2(50, side * 6), Vector2(66, side * 14), Vector2(74, side * 26)]), leg, 3.0, seed + 8 + int(side))
	_mark(c, _circle(Vector2(46, 0), 13.0, 14), Color("#6aa79f"), seed + 10, 4.0)
	_mark(c, Crayon.ellipse(Vector2(28, 0), Vector2(14, 24), 16), Color("#6fbfb0"), seed + 11, 4.0)
	var shell := Crayon.ellipse(Vector2(-10, 0), Vector2(44, 30), 26)
	_mark(c, shell, Color("#7cc8b8"), seed + 12, 5.0)
	_mline(c, _pv([Vector2(16, 0), Vector2(-52, 0)]), Color("#4f8d84"), 3.5, seed + 13)
	_mline(c, _arc(Vector2(-10, 0), Vector2(30, 18), PI * 1.15, PI * 1.5, 6), Color(1, 1, 1, 0.8), 4.0, seed + 14)
	c.draw_set_transform(Vector2.ZERO)


## Pencil leaf, marker bugs: a big leaf with three ladybirds and a beetle on it.
static func _bugs(c: CanvasItem) -> void:
	var centre := Vector2(256, 262)
	var turn := -0.4
	var green := Color("#9cd27f")
	_pen(c, _band(_pv([centre + Vector2(-196, 0).rotated(turn), centre + Vector2(-236, 10).rotated(turn)]), 6.0), green.darkened(0.15), 5001, 4.0)
	var leaf := _leaf(centre, 400, 220, turn)
	_pen(c, leaf, green, 5002, 5.5)
	_shade(c, leaf, green, 5003, Vector2(-10, -26).rotated(turn), 0.14)
	var vein := green.darkened(0.28)
	_pline(c, _pv([centre + Vector2(-196, 0).rotated(turn), centre + Vector2(176, 0).rotated(turn)]), vein, 4.0, 5004)
	for i in 4:
		var x := -130.0 + i * 80.0
		for side: float in [-1.0, 1.0]:
			var from := centre + Vector2(x, 0).rotated(turn)
			var to := centre + Vector2(x + 50, side * 70 * (1.0 - absf(x) / 260.0)).rotated(turn)
			_pline(c, _pv([from, to]), vein, 3.0, 5010 + i * 2 + int(side))
	_beetle(c, centre + Vector2(-90, 40).rotated(turn), turn + 0.3, 5030)
	_ladybird(c, centre + Vector2(-110, -46).rotated(turn), turn - 0.4, 5050)
	_ladybird(c, centre + Vector2(40, -40).rotated(turn), turn + 0.6, 5070)
	_ladybird(c, centre + Vector2(110, 40).rotated(turn), turn - 0.2, 5090)


## Marker: a slice of pizza pointing down, pepperoni and a cheese drip.
static func _pizza(c: CanvasItem) -> void:
	var arc := _bez(Vector2(104, 140), Vector2(190, 80), Vector2(322, 80), Vector2(408, 140), 20)
	var cheese_poly := PackedVector2Array()
	cheese_poly.append_array(_move(arc, Vector2(0, 18)))
	cheese_poly.append(Vector2(272, 430))
	cheese_poly.append(Vector2(262, 446))
	cheese_poly.append(Vector2(248, 446))
	cheese_poly.append(Vector2(240, 430))
	var drip := _band(_pv([Vector2(336, 286), Vector2(342, 334)]), 12.0)
	var cheese := _union([cheese_poly, drip])
	var yellow := Color("#f7d36c")
	_mark(c, cheese, yellow, 5101, 7.0)
	_gleam(c, cheese, 5102, Vector2(14, 0), 0.35)
	var pepperoni := Color("#e2665c")
	for p in [Vector2(212, 186), Vector2(300, 176), Vector2(260, 270), Vector2(216, 342) + Vector2(30, 10)]:
		var at: Vector2 = p
		_mark(c, _circle(at, 32.0, 24), pepperoni, 5110 + int(at.x), 5.5)
		for k in 3:
			c.draw_circle(at + Vector2(Crayon.noise(5120 + int(at.x), k) * 14, Crayon.noise(5121 + int(at.x), k) * 14), 3.5, pepperoni.darkened(0.22))
	for g in [Vector2(176, 236), Vector2(326, 236), Vector2(256, 208), Vector2(286, 332)]:
		_mline(c, _pv([g, g + Vector2(8, -6)]), Color("#86c46e"), 6.0, 5130 + int(g.x))
	_mark(c, _band(arc, 7.0), Color("#e5675c"), 5140, 3.0)
	var crust := _band(_move(arc, Vector2(0, -12)), 24.0)
	var tan_col := Color("#e9b674")
	_pen(c, crust, tan_col, 5141, 6.0)
	_gleam(c, crust, 5142, Vector2(0, 10), 0.4)


## Marker scoops, pencil cone: an ice-cream cone with two scoops and a cherry.
static func _icecream(c: CanvasItem) -> void:
	var cone := _pv([Vector2(180, 262), Vector2(332, 262), Vector2(262, 452), Vector2(250, 452)])
	var tan_col := Color("#e9b878")
	_pen(c, cone, tan_col, 5201, 5.5)
	for i in 8:
		var x := 140.0 + i * 32.0
		_clip_fill(c, _band(_pv([Vector2(x, 250), Vector2(x + 130, 470)]), 2.0), cone, tan_col.darkened(0.28), 5202 + i, false)
		_clip_fill(c, _band(_pv([Vector2(x + 100, 250), Vector2(x - 30, 470)]), 2.0), cone, tan_col.darkened(0.28), 5212 + i, false)
	var pink := Color("#f6a8c0")
	var low := _union([_circle(Vector2(256, 228), 86.0, 36), Crayon.ellipse(Vector2(256, 262), Vector2(94, 20), 28),
		_band(_pv([Vector2(214, 270), Vector2(214, 300)]), 12.0), _band(_pv([Vector2(300, 270), Vector2(300, 290)]), 11.0)])
	_mark(c, low, pink, 5230, 7.0)
	_gleam(c, low, 5231, Vector2(16, 16), 0.4)
	var mint := Color("#a6dfc2")
	var high := _union([_circle(Vector2(256, 148), 76.0, 36), Crayon.ellipse(Vector2(256, 186), Vector2(84, 18), 28)])
	_mark(c, high, mint, 5232, 7.0)
	_gleam(c, high, 5233, Vector2(16, 16), 0.4)
	var sprinkles := [Color("#f7dc78"), Color("#9fc8f0"), Color("#f49a9a"), Color("#c8aef0")]
	for i in 7:
		var p := Vector2(210 + absf(Crayon.noise(5240, i)) * 90.0, 110 + absf(Crayon.noise(5241, i)) * 70.0)
		var d := Vector2(7, 0).rotated(Crayon.noise(5242, i) * PI)
		_mline(c, _pv([p - d, p + d]), sprinkles[i % 4], 5.0, 5243 + i)
	_pline(c, _bez(Vector2(262, 70), Vector2(264, 50), Vector2(276, 40), Vector2(290, 34), 6), Color("#8fb26a"), 4.5, 5250)
	_mark(c, _circle(Vector2(260, 82), 20.0, 20), Color("#e64f5c"), 5251, 5.0)
	c.draw_circle(Vector2(253, 75), 5.0, Color(1, 1, 1, 0.85))


## Marker: a curly red chilli with a green cap, little flames flicking off it.
static func _chili(c: CanvasItem) -> void:
	var spine := _bez(Vector2(150, 196), Vector2(270, 136), Vector2(410, 214), Vector2(352, 392), 30)
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	for i in spine.size():
		var t := i / float(spine.size() - 1)
		var a := spine[maxi(i - 1, 0)]
		var b := spine[mini(i + 1, spine.size() - 1)]
		var n := (b - a).normalized().orthogonal()
		var hw := 50.0 * pow(1.0 - t, 0.7) + 3.0
		left.append(spine[i] + n * hw)
		right.append(spine[i] - n * hw)
	right.reverse()
	var pepper := PackedVector2Array()
	pepper.append_array(left)
	pepper.append_array(right)
	var red := Color("#e8524f")
	var green := Color("#86c46c")
	_pline(c, _pv([Vector2(150, 196), Vector2(122, 168), Vector2(112, 128)]), green.darkened(0.2), 10.0, 5301)
	_mark(c, pepper, red, 5302, 7.0)
	_shade(c, pepper, red, 5303, Vector2(-14, -20), 0.14)
	_mline(c, _move(_bez(Vector2(196, 180), Vector2(270, 146), Vector2(350, 180), Vector2(366, 236), 12), Vector2(0, -6)),
		Color(1, 1, 1, 0.75), 7.0, 5304)
	var cap := _smooth(_pv([Vector2(122, 164), Vector2(178, 150), Vector2(200, 182), Vector2(176, 214),
		Vector2(186, 248), Vector2(152, 226), Vector2(118, 240), Vector2(130, 206)]), 1)
	_mark(c, cap, green, 5305, 5.0)
	var flames := [[Vector2(436, 288), 60.0, 0.25], [Vector2(430, 378), 46.0, 0.45], [Vector2(306, 414), 40.0, -0.35]]
	for i in flames.size():
		var f: Array = flames[i]
		var at: Vector2 = f[0]
		var h: float = f[1]
		var ang: float = f[2]
		_mark(c, _rot(_flame(at, h), at, ang), Color("#f7a24e"), 5310 + i * 2, 4.5)
		_mfill(c, _rot(_flame(at + Vector2(0, h * 0.08), h * 0.5), at, ang), Color("#fbdc6a"), 5311 + i * 2)
	for i in 2:
		var x := 360.0 + i * 34.0
		var wave := PackedVector2Array()
		for k in 7:
			wave.append(Vector2(x + sin(k * 1.4) * 7.0, 150 - k * 12.0 - i * 10.0))
		_pline(c, wave, Color("#f4a65a"), 4.5, 5320 + i)


## A little flame standing on `at`: a tall tongue and a shorter one beside it, `h` tall.
static func _flame(at: Vector2, h: float) -> PackedVector2Array:
	var w := h * 0.8
	var pts := _pv([Vector2(0, -h), Vector2(w * 0.28, -h * 0.42), Vector2(w * 0.56, -h * 0.64),
		Vector2(w * 0.62, -h * 0.12), Vector2(w * 0.4, h * 0.16), Vector2(0, h * 0.24),
		Vector2(-w * 0.42, h * 0.16), Vector2(-w * 0.56, -h * 0.12), Vector2(-w * 0.26, -h * 0.46)])
	return _move(_smooth(pts, 2), at)


## Marker icing on a pencil biscuit, gold: a star-shaped cookie.
static func _star_snack(c: CanvasItem) -> void:
	var biscuit := _smooth(Crayon.star(Vector2(256, 268), 210.0, 5401), 2)
	var gold := Color("#f2d796")
	_pen(c, biscuit, gold, 5402, 6.0)
	_shade(c, biscuit, gold, 5403, Vector2(-18, -20), 0.2)
	var icing := Geometry2D.offset_polygon(biscuit, -24.0)
	if not icing.is_empty():
		var ice: PackedVector2Array = icing[0]
		_mark(c, ice, Color("#fff6da"), 5404, 5.0)
		_gleam(c, ice, 5405, Vector2(12, 12), 0.6)
		var zig := PackedVector2Array()
		for i in 9:
			zig.append(Vector2(196 + i * 15.0, 270 + (12.0 if i % 2 == 0 else -12.0)))
		_mline(c, zig, Color("#f4dc9c"), 6.0, 5406)
	var dots := [Color("#f6a5a5"), Color("#9fc8f0"), Color("#a9dca2"), Color("#c8aef0")]
	for i in 6:
		var p: Vector2 = [Vector2(256, 176), Vector2(196, 226), Vector2(316, 228), Vector2(220, 326),
			Vector2(292, 326), Vector2(256, 300)][i]
		c.draw_circle(p, 7.0, dots[i % 4])


# --- Competition props -----------------------------------------------------------------------

## Marker: a finish-line arch - two posts and a navy and white chequered banner.
static func _finish(c: CanvasItem) -> void:
	var post := Color("#a8c4e6")
	for x in [76.0, 436.0]:
		_mark(c, _band(_pv([Vector2(x, 96), Vector2(x, 462)]), 13.0), post, 5501 + int(x), 6.0)
		_mark(c, Crayon.rounded_rect(Rect2(x - 26, 448, 52, 22), 6), post.darkened(0.1), 5502 + int(x), 5.0)
		_mark(c, _circle(Vector2(x, 84), 15.0, 16), Color("#f7d867"), 5503 + int(x), 5.0)
	var top := _bez(Vector2(86, 112), Vector2(200, 126), Vector2(312, 126), Vector2(426, 112), 16)
	var bot := _move(top, Vector2(0, 92))
	var navy := Color("#4c5c96")
	var white := Color("#f6f6fb")
	var cols := 8
	for i in cols:
		for j in 2:
			var a := _at(top, _path_len(top) * i / cols)
			var b := _at(top, _path_len(top) * (i + 1) / cols)
			var cell := _pv([a.lerp(a + Vector2(0, 92), j / 2.0), b.lerp(b + Vector2(0, 92), j / 2.0),
				b.lerp(b + Vector2(0, 92), (j + 1) / 2.0), a.lerp(a + Vector2(0, 92), (j + 1) / 2.0)])
			_mfill(c, cell, navy if (i + j) % 2 == 0 else white, 5510 + i * 2 + j)
	var banner := PackedVector2Array()
	banner.append_array(top)
	var rev := bot.duplicate()
	rev.reverse()
	banner.append_array(rev)
	Crayon.marker_line(c, banner, navy.darkened(0.2), 7.0, 5540)


## Marker: a hurdle - a red and white striped bar on two posts with flat feet.
static func _hurdle(c: CanvasItem) -> void:
	var post := Color("#c3cfe2")
	var foot := Color("#8fb2dc")
	for x in [118.0, 394.0]:
		_mark(c, _band(_pv([Vector2(x, 232), Vector2(x, 456)]), 10.0), post, 5601 + int(x), 5.0)
		_mark(c, Crayon.rounded_rect(Rect2(x - 46, 452, 92, 18), 7), foot, 5602 + int(x), 5.0)
	var bar := Crayon.rounded_rect(Rect2(86, 210, 340, 40), 12)
	var white := Color("#f7f3ee")
	var red := Color("#e8615f")
	_mfill(c, bar, white, 5610)
	for i in 6:
		var x := 92.0 + i * 64.0
		_clip_fill(c, _pv([Vector2(x + 14, 200), Vector2(x + 46, 200), Vector2(x + 32, 260), Vector2(x, 260)]),
			bar, red, 5611 + i * 2)
	Crayon.marker_line(c, bar, red.darkened(0.48), 7.0, 5630)


## Pencil rope, marker ribbon: a long tug-of-war rope with a red bow tied in the middle.
static func _rope_long(c: CanvasItem) -> void:
	var curve := _bez(Vector2(74, 242), Vector2(184, 270), Vector2(328, 270), Vector2(438, 242), 40)
	_tug_rope(c, curve, 15.0, Color("#f6e7c8"), [Color("#dcb27c")], [0.0, 1.0], 24.0, 5701)
	var red := Color("#e5565c")
	var mid := Vector2(256, 262)
	for side: float in [-1.0, 1.0]:
		var tail := _pv([mid + Vector2(side * 4, 4), mid + Vector2(side * 18, 4), mid + Vector2(side * 40, 66),
			mid + Vector2(side * 30, 58), mid + Vector2(side * 22, 72)])
		_mark(c, tail, red.darkened(0.06), 5710 + int(side), 5.0)
	for side: float in [-1.0, 1.0]:
		var loop := _smooth(_pv([mid, mid + Vector2(side * 40, -40), mid + Vector2(side * 62, -20),
			mid + Vector2(side * 56, 14), mid + Vector2(side * 20, 8)]), 2)
		_mark(c, loop, red, 5720 + int(side), 5.0)
	_mark(c, Crayon.ellipse(mid, Vector2(15, 17), 14), red.darkened(0.1), 5730, 5.0)


## Marker: the winners' podium - 2 on the left, 1 in the middle and tallest, 3 on the right.
static func _podium(c: CanvasItem) -> void:
	var steps := [["2", Rect2(70, 330, 122, 140), Color("#a9c8ea")], ["1", Rect2(190, 236, 134, 234), Color("#f5d465")],
		["3", Rect2(322, 368, 122, 102), Color("#f2ae7e")]]
	var depth := Vector2(18, -18)
	for i in steps.size():
		var s: Array = steps[i]
		var r: Rect2 = s[1]
		var col: Color = s[2]
		var top := _pv([r.position, r.position + Vector2(r.size.x, 0), r.position + Vector2(r.size.x, 0) + depth, r.position + depth])
		_mark(c, top, col.lightened(0.25), 5801 + i * 5, 6.0)
		var side := _pv([r.position + Vector2(r.size.x, 0), r.position + Vector2(r.size.x, 0) + depth, r.end + depth, r.end])
		_mark(c, side, col.darkened(0.1), 5802 + i * 5, 6.0)
		var front := _pv([r.position, r.position + Vector2(r.size.x, 0), r.end, Vector2(r.position.x, r.end.y)])
		_mark(c, front, col, 5803 + i * 5, 7.0)
		var dh := minf(84.0, r.size.y * 0.62)
		var box := Rect2(r.get_center().x - dh * 0.3, r.position.y + minf(30.0, r.size.y * 0.16), dh * 0.6, dh)
		_digit(c, s[0], box, col, 5804 + i * 5)
	_mark(c, Crayon.star(Vector2(266, 186), 30.0, 5820), Color("#fbe48a"), 5821, 4.5)


static func _digit(c: CanvasItem, ch: String, box: Rect2, col: Color, seed: int) -> void:
	var spec: Array = DIGITS[ch]
	var raw: Array = spec[0]
	var pts := PackedVector2Array()
	for v in raw:
		var p: Vector2 = v
		pts.append(box.position + p * box.size)
	pts = _smooth(pts, spec[1], false)
	Crayon.marker_line(c, pts, col.darkened(0.45), 20.0, seed, false)
	Crayon.marker_line(c, pts, PAPER, 10.0, seed, false)


## Marker: an orange traffic cone with a white band, on a square foot.
static func _cone(c: CanvasItem) -> void:
	var orange := Color("#f79b50")
	_mark(c, Crayon.rounded_rect(Rect2(118, 436, 276, 34), 8), orange.darkened(0.1), 5901, 7.0)
	var body := PackedVector2Array([Vector2(162, 444), Vector2(232, 106)])
	for p in _arc(Vector2(256, 106), Vector2(24, 14), PI, TAU, 8):
		body.append(p)
	body.append(Vector2(280, 106))
	body.append(Vector2(350, 444))
	_mfill(c, body, orange, 5902)
	_clip_fill(c, _pv([Vector2(100, 236), Vector2(412, 236), Vector2(412, 300), Vector2(100, 300)]), body,
		Color("#f8f5ee"), 5903)
	_clip_fill(c, _pv([Vector2(100, 362), Vector2(412, 362), Vector2(412, 392), Vector2(100, 392)]), body,
		Color("#f8f5ee"), 5904)
	_shade(c, body, orange, 5905, Vector2(-34, 0), 0.12)
	Crayon.marker_line(c, body, orange.darkened(0.48), 7.0, 5906)
	_mline(c, _pv([Vector2(226, 140), Vector2(206, 226)]), Color(1, 1, 1, 0.75), 8.0, 5907)
	_mline(c, _pv([Vector2(198, 312), Vector2(188, 350)]), Color(1, 1, 1, 0.75), 8.0, 5908)


## Marker flags, pencil string: bunting - a wide, short string of triangle flags.
static func _bunting(c: CanvasItem) -> void:
	var string := _bez(Vector2(12, 196), Vector2(170, 252), Vector2(342, 252), Vector2(500, 196), 40)
	var colors := [Color("#f4a3bf"), Color("#f7d86a"), Color("#8fc0ea"), Color("#a6d98f"),
		Color("#c3a6ea"), Color("#f6b27a")]
	var length := _path_len(string)
	var flags := 9
	var step := (length - 40.0) / flags
	for i in flags:
		var d0 := 20.0 + i * step + 4.0
		var d1 := d0 + step - 8.0
		var a := _at(string, d0)
		var b := _at(string, d1)
		var tip := a.lerp(b, 0.5) + Vector2(0, 86)
		var flag := _pv([a, b, tip])
		var col: Color = colors[i % colors.size()]
		_mark(c, flag, col, 6001 + i * 3, 5.5)
		if i % 2 == 0:
			var mid := (a + b + tip) / 3.0
			c.draw_circle(mid + Vector2(-8, -10), 5.0, Color(1, 1, 1, 0.75))
			c.draw_circle(mid + Vector2(10, -6), 4.0, Color(1, 1, 1, 0.75))
			c.draw_circle(mid + Vector2(0, 14), 4.0, Color(1, 1, 1, 0.75))
	Crayon.pencil_line(c, string, Color("#b49a86"), 5.0, 6050, false)
