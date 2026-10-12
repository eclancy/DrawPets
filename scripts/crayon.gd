class_name Crayon
extends RefCounted
## Drawing helpers that make code-drawn things look hand-made: crayon hatching that runs past
## the edge, lumpy blobs, scribbled clouds. Ported from DrawFight's CrayonBrush.
##
## Every wobble is hashed from a seed, never rolled from a random number generator. A place
## redraws when the window resizes, and a shape that re-rolls its jitter on each redraw
## shimmers - which reads as a rendering bug, not as hand-drawn.


## Deterministic value noise in roughly -1..1. Same inputs, same output, always.
static func noise(seed: int, index: int) -> float:
	var n := (seed * 73856093) ^ (index * 19349663)
	n = (n << 13) ^ n
	var m := (n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff
	return 1.0 - m / 1073741824.0


## A hand-wobbled stroke between two points. Ends wobble less, so corners stay corners.
static func line(canvas: CanvasItem, from: Vector2, to: Vector2, color: Color, width: float,
		seed: int, wobble := 2.2) -> void:
	var length := from.distance_to(to)
	if length < 0.5:
		return
	var segments := maxi(2, roundi(length / 26.0))
	var normal := (to - from).normalized().orthogonal()
	var points := PackedVector2Array()
	for i in segments + 1:
		var t := i / float(segments)
		var taper := sin(t * PI)
		points.append(from.lerp(to, t) + normal * noise(seed, i) * wobble * (0.35 + taper * 0.65))
	canvas.draw_polyline(points, color, width, true)


## Points round a lumpy ellipse, for anything round a kid would draw freehand.
static func blob(center: Vector2, radius: Vector2, seed: int, count := 18,
		lumpy := 0.1) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in count:
		var a := TAU * i / count
		var r := 1.0 + noise(seed, i) * lumpy
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y) * r)
	return points


## A shape filled the way a crayon fills it: a pale wash so no paper shows through as holes,
## then diagonal strokes of uneven pressure that run a little past the edge. The overshoot is
## the whole point - colouring outside the lines is what reads as a child did this.
static func fill(canvas: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		spacing := 10.0, overshoot := 4.0, width := 6.0) -> void:
	if poly.size() < 3:
		return
	var wash := color
	wash.a *= 0.6
	canvas.draw_colored_polygon(poly, wash)
	var grown := Geometry2D.offset_polygon(poly, overshoot)
	if grown.is_empty():
		return
	var area: PackedVector2Array = grown[0]
	var rect := bounds(area)
	var strokes := maxi(1, roundi((rect.size.x + rect.size.y) / spacing))
	for i in strokes:
		var x := rect.position.x + i * spacing
		var a := Vector2(x, rect.position.y)
		var b := Vector2(x - rect.size.y, rect.end.y)
		var c := color
		c.a *= 0.55 + 0.45 * absf(noise(seed, i))
		var jitter := Vector2(noise(seed + 7, i) * 2.0, noise(seed + 11, i) * 2.0)
		for piece in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([a, b]), area):
			if piece.size() >= 2:
				canvas.draw_line(piece[0] + jitter, piece[piece.size() - 1] + jitter, c, width, true)


## A crayon-filled lumpy ellipse - the workhorse for bushes, rocks, suns and clouds.
static func fill_blob(canvas: CanvasItem, center: Vector2, radius: Vector2, color: Color,
		seed: int, lumpy := 0.1) -> void:
	var spacing := clampf(minf(radius.x, radius.y) * 0.35, 4.0, 11.0)
	fill(canvas, blob(center, radius, seed, 18, lumpy), color, seed, spacing, 3.0,
		clampf(spacing * 0.6, 2.5, 6.0))


## Light from a lamp or a glowy toy at night: soft rings of pale yellow pencil, stronger to the
## middle. `strength` 0-1 (Clock.night()).
static func glow(canvas: CanvasItem, center: Vector2, radius: float, strength: float, seed: int) -> void:
	if strength <= 0.01:
		return
	for i in 3:
		var r := radius * (1.0 - i * 0.28)
		fill_blob(canvas, center, Vector2(r, r), Color(Clock.GLOW, 0.14 * strength), seed + i, 0.08)


## A loose scribbled loop, for clouds and smoke.
static func scribble(canvas: CanvasItem, center: Vector2, size: Vector2, color: Color,
		seed: int, width := 8.0, loops := 9) -> void:
	var points := PackedVector2Array()
	var count := loops * 4
	for i in count:
		var t := i / float(count - 1)
		var angle := t * TAU * loops * 0.22
		var radius := 0.42 + 0.28 * absf(noise(seed, i))
		points.append(center + Vector2(cos(angle) * size.x * radius, sin(angle) * size.y * radius))
	canvas.draw_polyline(points, color, width, true)


## A vertical gradient, faked as bands because a CanvasItem cannot draw one directly.
static func sky(canvas: CanvasItem, area: Rect2, top: Color, bottom: Color, bands := 40) -> void:
	var step := area.size.y / bands
	for i in bands:
		var t := i / float(bands - 1)
		canvas.draw_rect(Rect2(area.position.x, area.position.y + i * step, area.size.x, step + 1.0),
			top.lerp(bottom, t))


## A heart, for emotes. Classic parametric heart, point down.
static func heart(center: Vector2, size: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 28:
		var t := TAU * i / 28.0
		var x := 16.0 * pow(sin(t), 3)
		var y := 13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)
		points.append(center + Vector2(x, -y) * size / 32.0)
	return points


## A five-pointed star.
static func star(center: Vector2, size: float, seed := 0) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 10:
		var r := size if i % 2 == 0 else size * 0.45
		r *= 1.0 + noise(seed, i) * 0.06
		var a := -PI / 2.0 + TAU * i / 10.0
		points.append(center + Vector2(cos(a), sin(a)) * r)
	return points


# --- Coloured pencil and marker --------------------------------------------------------------
# The two looks every made-for-the-game drawing uses (.ai/art-direction.md). Pencil is fine,
# close strokes with paper showing through; marker is broad translucent strokes that go darker
# where they overlap. Both are hashed from a seed like everything else here.

## Coloured pencil: steep fine strokes of uneven pressure, a lighter cross-hatch over them,
## flecks of paper showing through, and a faint wash underneath so the shape reads as filled.
static func pencil_fill(canvas: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		spacing := 4.0, width := 2.0) -> void:
	if poly.size() < 3:
		return
	var wash := color
	wash.a *= 0.38
	canvas.draw_colored_polygon(poly, wash)
	_hatch(canvas, poly, color, seed, spacing, width, 0.55)
	var light := color
	light.a *= 0.45
	_hatch(canvas, poly, light, seed + 5, spacing * 1.8, width * 0.8, -0.85)
	paper_tooth(canvas, poly, seed + 9)


## One direction of pencil strokes clipped to a shape. `slope` is x travelled per unit of y.
static func _hatch(canvas: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		spacing: float, width: float, slope: float) -> void:
	var r := bounds(poly)
	var run := r.size.y * slope
	var x0 := r.position.x + minf(0.0, run) - spacing
	var x1 := r.end.x + maxf(0.0, run) + spacing
	var count := int((x1 - x0) / spacing)
	for i in count:
		var x := x0 + i * spacing + noise(seed, i) * spacing * 0.35
		var a := Vector2(x, r.position.y - 2.0)
		var b := Vector2(x - run, r.end.y + 2.0)
		var c := color
		c.a *= 0.45 + 0.55 * absf(noise(seed + 3, i))
		for piece in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([a, b]), poly):
			canvas.draw_polyline(piece, c, width, true)


## Flecks of paper showing through pencil - the grain of the page catching the lead.
static func paper_tooth(canvas: CanvasItem, poly: PackedVector2Array, seed: int,
		density := 0.012) -> void:
	var r := bounds(poly)
	var count := int(r.size.x * r.size.y * density / 10.0)
	for i in count:
		var p := r.position + Vector2(absf(noise(seed, i)) * r.size.x, absf(noise(seed + 1, i)) * r.size.y)
		if Geometry2D.is_point_in_polygon(p, poly):
			canvas.draw_circle(p, 0.9 + absf(noise(seed + 2, i)), Color(1, 1, 1, 0.32))


## A pencil outline: the line gone over twice, the second pass lighter and not quite on top.
static func pencil_line(canvas: CanvasItem, points: PackedVector2Array, color: Color,
		width := 3.0, seed := 0, closed := true) -> void:
	var first := color
	first.a *= 0.92
	canvas.draw_polyline(wobbled(points, seed, 1.1, closed), first, width, true)
	var second := color
	second.a *= 0.5
	canvas.draw_polyline(wobbled(points, seed + 17, 1.8, closed), second, width * 0.6, true)


## Marker: broad translucent strokes side by side that overlap a little, so the overlaps go
## darker in streaks - the way a felt-tip fills a shape. Strokes stay inside the shape (they
## are clipped to it shrunk by half a stroke) and a wash underneath closes the gaps.
static func marker_fill(canvas: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		stroke := 22.0) -> void:
	if poly.size() < 3:
		return
	var wash := color
	wash.a *= 0.72
	canvas.draw_colored_polygon(poly, wash)
	var shrunk := Geometry2D.offset_polygon(poly, -stroke * 0.45)
	if shrunk.is_empty():
		return
	var area: PackedVector2Array = shrunk[0]
	var r := bounds(poly)
	var tilt := r.size.x * 0.06
	var count := int(r.size.y / (stroke * 0.78)) + 2
	for i in count:
		var y := r.position.y + i * stroke * 0.78 + noise(seed, i) * 2.5
		var a := Vector2(r.position.x - 20.0, y - tilt)
		var b := Vector2(r.end.x + 20.0, y + tilt)
		var c := color
		c.a = 0.3 + 0.12 * absf(noise(seed + 4, i))
		for piece in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([a, b]), area):
			canvas.draw_polyline(piece, c, stroke, false)


## A marker outline: one confident stroke with round joins, a little wobble, never retraced.
static func marker_line(canvas: CanvasItem, points: PackedVector2Array, color: Color,
		width := 6.0, seed := 0, closed := true) -> void:
	var pts := wobbled(points, seed, 1.0, closed)
	canvas.draw_polyline(pts, color, width, true)
	for p in pts:
		canvas.draw_circle(p, width * 0.48, color)


## Points every ~10 px along a path, each pushed sideways a little: a hand, not a ruler.
static func wobbled(points: PackedVector2Array, seed: int, amount: float,
		closed := false) -> PackedVector2Array:
	var path := points.duplicate()
	if closed and path.size() > 2 and path[0] != path[path.size() - 1]:
		path.append(path[0])
	var out := PackedVector2Array()
	var k := 0
	for i in path.size() - 1:
		var a := path[i]
		var b := path[i + 1]
		var steps := maxi(1, int(a.distance_to(b) / 10.0))
		var normal := (b - a).normalized().orthogonal()
		for s in steps:
			out.append(a.lerp(b, s / float(steps)) + normal * noise(seed, k) * amount)
			k += 1
	out.append(path[path.size() - 1])
	if closed:
		out[out.size() - 1] = out[0]
	return out


## Points round an ellipse.
static func ellipse(center: Vector2, radius: Vector2, count := 40) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in count:
		var a := TAU * i / count
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	return points


## Points round a rectangle with rounded corners.
static func rounded_rect(rect: Rect2, radius: float) -> PackedVector2Array:
	var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	var points := PackedVector2Array()
	var corners := [rect.position + Vector2(rect.size.x - r, r), rect.end - Vector2(r, r),
		rect.position + Vector2(r, rect.size.y - r), rect.position + Vector2(r, r)]
	for c in 4:
		for i in 6:
			var a := -PI / 2.0 + c * PI / 2.0 + i * (PI / 2.0) / 5.0
			points.append(corners[c] + Vector2(cos(a), sin(a)) * r)
	return points


## A shape in coloured pencil: fill, then the outline in a darker shade of the same colour.
## Made-for-the-game art never outlines in black - black belongs to the kids' drawings.
static func pencil_shape(canvas: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		line_width := 3.5) -> void:
	pencil_fill(canvas, poly, color, seed)
	pencil_line(canvas, poly, color.darkened(0.45), line_width, seed + 31)


## A shape in marker: fill, then a darker outline of the same colour.
static func marker_shape(canvas: CanvasItem, poly: PackedVector2Array, color: Color, seed: int,
		line_width := 5.0) -> void:
	marker_fill(canvas, poly, color, seed)
	marker_line(canvas, poly, color.darkened(0.5), line_width, seed + 31)


## Undoes premultiplied alpha. Anything rendered into a transparent viewport comes out with its
## colour already multiplied by its alpha, so a soft edge saved as-is turns into a dark fringe.
## Call on any drawing read back from a viewport before it is saved or used as a texture.
static func unpremultiply(img: Image) -> void:
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	var data := img.get_data()
	for i in range(0, data.size(), 4):
		var a := data[i + 3]
		if a == 0 or a == 255:
			continue
		var k := 255.0 / a
		data[i] = mini(255, int(data[i] * k))
		data[i + 1] = mini(255, int(data[i + 1] * k))
		data[i + 2] = mini(255, int(data[i + 2] * k))
	img.set_data(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8, data)


static func bounds(points: PackedVector2Array) -> Rect2:
	if points.is_empty():
		return Rect2()
	var r := Rect2(points[0], Vector2.ZERO)
	for p in points:
		r = r.expand(p)
	return r
