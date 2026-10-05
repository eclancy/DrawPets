class_name PlacePainter
extends Node2D
## Draws any place from its data in Places: sky, a far layer, the ground, the props, and a
## drift of weather (snow, bubbles, petals). One renderer for every place - a new place is a
## new entry in Places.DATA, and a new kind of thing in it is a new prop here.
##
## Backgrounds carry no outlines, only crayon fill, and nothing darker than ~30% value
## (.ai/art-direction.md). The creature is the only thing on screen drawn in black.

## Everything a zoomed-out camera can see, in world pixels.
const WORLD := Rect2(-700, -420, 2680, 1560)

var place_id := "meadow"
var animate := true
var _place: Dictionary
var _drift: Drift


func _ready() -> void:
	_place = Places.get_place(place_id)
	if animate and _place.get("drift", "") != "":
		_drift = Drift.new()
		_drift.kind = _place["drift"]
		add_child(_drift)


func _draw() -> void:
	var p := _place
	var horizon := Places.HORIZON
	var sky_colors: Array = p["sky"]
	Crayon.sky(self, Rect2(WORLD.position, Vector2(WORLD.size.x, horizon - WORLD.position.y + 60)),
		sky_colors[0], sky_colors[1])

	# Props that belong in the sky are drawn before the far layer so hills can hide them.
	for prop in p["props"]:
		if prop[0] in ["sun", "cloud", "planet", "star", "vine"]:
			_prop(prop[0], Vector2(prop[1], prop[2]), prop[3], int(prop[1]) * 7 + int(prop[2]))

	_far(p.get("far_shape", "hills"), p["far"], horizon)

	var ground: Color = p["ground"]
	draw_rect(Rect2(WORLD.position.x, horizon, WORLD.size.x, WORLD.end.y - horizon), ground)
	# A few long crayon strokes across the ground, so it is not a flat slab.
	for i in 26:
		var y := horizon + 14.0 + i * 24.0 + Crayon.noise(5, i) * 6.0
		var c := ground.darkened(0.06 + 0.04 * absf(Crayon.noise(9, i)))
		c.a = 0.55
		var x0 := WORLD.position.x + absf(Crayon.noise(13, i)) * 400.0
		Crayon.line(self, Vector2(x0, y), Vector2(WORLD.end.x - absf(Crayon.noise(17, i)) * 400.0, y),
			c, 5.0, i * 31, 3.0)

	for prop in p["props"]:
		if prop[0] not in ["sun", "cloud", "planet", "star", "vine"]:
			_prop(prop[0], Vector2(prop[1], prop[2]), prop[3], int(prop[1]) * 7 + int(prop[2]))


func _far(shape: String, color: Color, horizon: float) -> void:
	var pts := PackedVector2Array()
	var left := WORLD.position.x
	var right := WORLD.end.x
	match shape:
		"sea":
			Crayon.fill(self, PackedVector2Array([Vector2(left, horizon - 70), Vector2(right, horizon - 70),
				Vector2(right, horizon + 2), Vector2(left, horizon + 2)]), color, 41, 12.0, 0.0, 7.0)
			for i in 12:
				var x := left + 220.0 * i
				Crayon.line(self, Vector2(x, horizon - 40), Vector2(x + 60, horizon - 40),
					Color(1, 1, 1, 0.6), 4.0, i)
			return
		"clouds":
			for i in 14:
				var x := left + i * 200.0
				Crayon.fill_blob(self, Vector2(x, horizon - 10), Vector2(140, 60), color, i * 3, 0.15)
			return
		"stalactites":
			for i in 22:
				var x := left + i * 125.0
				var depth := 90.0 + absf(Crayon.noise(77, i)) * 150.0
				Crayon.fill(self, PackedVector2Array([Vector2(x, WORLD.position.y),
					Vector2(x + 110, WORLD.position.y), Vector2(x + 55, depth)]), color, i, 9.0, 3.0, 5.0)
			shape = "hills"
		"craters":
			shape = "hills"
		"battlements":
			var wall := PackedVector2Array([Vector2(left, horizon + 40)])
			var x := left
			while x <= right:
				wall.append(Vector2(x, horizon - 150))
				wall.append(Vector2(x + 34, horizon - 150))
				wall.append(Vector2(x + 34, horizon - 120))
				wall.append(Vector2(x + 68, horizon - 120))
				wall.append(Vector2(x + 68, horizon - 150))
				x += 68
			wall.append(Vector2(x, horizon + 40))
			Crayon.fill(self, wall, color, 77, 12.0, 0.0, 7.0)
			for i in 30:
				var bx := left + (i % 15) * 180.0 + (i / 15) * 90.0
				var by := horizon - 95.0 + (i / 15) * 40.0
				Crayon.line(self, Vector2(bx, by), Vector2(bx + 70, by), color.darkened(0.08), 4.0, i, 1.0)
			return
	var step := 60.0
	var bump := 70.0 if shape == "hills" else 45.0
	var period := 0.006 if shape == "hills" else 0.004
	pts.append(Vector2(left, horizon + 40))
	var x := left
	while x <= right:
		var h := bump * (0.55 + 0.45 * sin(x * period + 1.3)) + 20.0 * Crayon.noise(23, int(x))
		pts.append(Vector2(x, horizon - h))
		x += step
	pts.append(Vector2(right, horizon + 40))
	Crayon.fill(self, pts, color, 99, 12.0, 0.0, 7.0)


func _prop(kind: String, at: Vector2, s: float, seed: int) -> void:
	match kind:
		"sun":
			Crayon.fill_blob(self, at, Vector2(55, 55) * s, Color("#ffd75e"), seed, 0.04)
			for i in 10:
				var a := TAU * i / 10.0
				Crayon.line(self, at + Vector2(cos(a), sin(a)) * 72.0 * s,
					at + Vector2(cos(a), sin(a)) * 100.0 * s, Color("#ffcf4a"), 6.0, seed + i, 1.5)
		"cloud":
			for i in 4:
				var o := Vector2((i - 1.5) * 50.0, -absf(Crayon.noise(seed, i)) * 25.0) * s
				Crayon.fill_blob(self, at + o, Vector2(55, 38) * s, Color(1, 1, 1, 0.85), seed + i, 0.12)
		"tree":
			_trunk(at, Vector2(26, 130) * s, Color("#c9a27c"), seed)
			Crayon.fill_blob(self, at + Vector2(0, -170) * s, Vector2(95, 80) * s, Color("#8cc977"), seed, 0.14)
		"pine":
			_trunk(at, Vector2(20, 60) * s, Color("#c9a27c"), seed)
			for i in 3:
				var w := (90.0 - i * 22.0) * s
				var y := at.y - (40.0 + i * 55.0) * s
				Crayon.fill(self, PackedVector2Array([Vector2(at.x - w, y), Vector2(at.x + w, y),
					Vector2(at.x, y - 90.0 * s)]), Color("#7fbf8a"), seed + i, 8.0, 3.0, 5.0)
		"bush":
			Crayon.fill_blob(self, at + Vector2(0, -40) * s, Vector2(80, 50) * s, Color("#9ad083"), seed, 0.18)
		"flower":
			Crayon.line(self, at, at + Vector2(0, -50) * s, Color("#8cc977"), 5.0 * s, seed, 1.5)
			var head := at + Vector2(0, -55) * s
			var petal: Color = [Color("#f7a6c8"), Color("#ffd166"), Color("#b9a4f2")][absi(seed) % 3]
			for i in 5:
				var a := TAU * i / 5.0
				Crayon.fill_blob(self, head + Vector2(cos(a), sin(a)) * 13.0 * s, Vector2(10, 10) * s,
					petal, seed + i, 0.1)
			Crayon.fill_blob(self, head, Vector2(8, 8) * s, Color("#ffcf4a"), seed, 0.05)
		"rock":
			Crayon.fill_blob(self, at + Vector2(0, -22) * s, Vector2(60, 30) * s, Color("#c4bfcf"), seed, 0.16)
		"cactus":
			var c := Color("#93c98a")
			_rounded(at + Vector2(-18, -150) * s, Vector2(36, 150) * s, c, seed)
			_rounded(at + Vector2(-58, -110) * s, Vector2(26, 50) * s, c, seed + 1)
			_rounded(at + Vector2(32, -125) * s, Vector2(26, 60) * s, c, seed + 2)
		"palm":
			var top := at + Vector2(30, -230) * s
			Crayon.line(self, at, top, Color("#d8b48a"), 22.0 * s, seed, 8.0)
			for i in 5:
				var a := -PI * 0.95 + PI * 0.95 * i / 4.0
				var tip := top + Vector2(cos(a) * 120.0, sin(a) * 50.0 + 45.0) * s
				Crayon.fill(self, PackedVector2Array([top, top.lerp(tip, 0.5) + Vector2(0, -20) * s, tip,
					top.lerp(tip, 0.5) + Vector2(0, 12) * s]), Color("#8fcf7f"), seed + i, 6.0, 2.0, 4.0)
		"seaweed":
			var pts := PackedVector2Array()
			for i in 9:
				pts.append(at + Vector2(sin(i * 0.9 + seed) * 14.0, -i * 28.0) * s)
			draw_polyline(pts, Color("#86c79a"), 16.0 * s, true)
		"coral":
			var c := Color("#f6a7a0")
			for i in 5:
				var a := -PI / 2.0 + (i - 2) * 0.35
				Crayon.line(self, at, at + Vector2(cos(a), sin(a)) * (60.0 + 25.0 * absf(Crayon.noise(seed, i))) * s,
					c, 14.0 * s, seed + i, 4.0)
		"shell":
			for i in 5:
				var a := PI + PI * i / 4.0
				Crayon.line(self, at, at + Vector2(cos(a), sin(a)) * 22.0 * s, Color("#f3c6b5"), 9.0 * s,
					seed + i, 1.0)
		"mushroom":
			_rounded(at + Vector2(-10, -40) * s, Vector2(20, 40) * s, Color("#f2e6d0"), seed)
			Crayon.fill(self, PackedVector2Array([at + Vector2(-42, -38) * s, at + Vector2(-30, -70) * s,
				at + Vector2(0, -82) * s, at + Vector2(30, -70) * s, at + Vector2(42, -38) * s]),
				Color("#f08a8a"), seed, 6.0, 2.0, 4.0)
			for i in 3:
				draw_circle(at + Vector2(-18 + i * 17, -58 - (i % 2) * 8) * s, 5.0 * s, Color(1, 1, 1, 0.9))
		"crystal":
			for i in 3:
				var o := Vector2((i - 1) * 34.0, 0) * s
				var h := (90.0 + 50.0 * absf(Crayon.noise(seed, i))) * s
				Crayon.fill(self, PackedVector2Array([at + o + Vector2(-16, 0) * s, at + o + Vector2(-12 * s, -h * 0.8),
					at + o + Vector2(0, -h), at + o + Vector2(12 * s, -h * 0.8), at + o + Vector2(16, 0) * s]),
					[Color("#b7a6f0"), Color("#9fdcf0"), Color("#f2b6e4")][i], seed + i, 6.0, 2.0, 4.0)
		"peak":
			var w := 260.0 * s
			var h := 260.0 * s
			Crayon.fill(self, PackedVector2Array([at + Vector2(-w, 0), at + Vector2(0, -h), at + Vector2(w, 0)]),
				Color("#c8d6ea"), seed, 12.0, 2.0, 7.0)
			Crayon.fill(self, PackedVector2Array([at + Vector2(-w * 0.32, -h * 0.68), at + Vector2(0, -h),
				at + Vector2(w * 0.32, -h * 0.68), at + Vector2(w * 0.12, -h * 0.6),
				at + Vector2(-w * 0.1, -h * 0.66)]), Color(1, 1, 1, 0.95), seed + 1, 6.0, 2.0, 5.0)
		"volcano":
			var w := 300.0 * s
			var h := 240.0 * s
			Crayon.fill(self, PackedVector2Array([at + Vector2(-w, 0), at + Vector2(-w * 0.22, -h),
				at + Vector2(w * 0.22, -h), at + Vector2(w, 0)]), Color("#d9a99a"), seed, 12.0, 2.0, 7.0)
			Crayon.fill(self, PackedVector2Array([at + Vector2(-w * 0.22, -h), at + Vector2(w * 0.22, -h),
				at + Vector2(w * 0.12, -h * 0.75), at + Vector2(-w * 0.05, -h * 0.85)]),
				Color("#ff9a52"), seed + 1, 6.0, 2.0, 5.0)
			for i in 3:
				Crayon.scribble(self, at + Vector2(i * 25.0, -h - 60.0 - i * 50.0) * Vector2(1, 1),
					Vector2(90, 60) * s, Color(0.85, 0.8, 0.85, 0.7), seed + i, 6.0)
		"rainbow":
			var colors := [Color("#f7a1a1"), Color("#f9c98a"), Color("#f7e48a"), Color("#a9dd9a"),
				Color("#9cc9ef"), Color("#c3a9ec")]
			for i in colors.size():
				draw_arc(at + Vector2(0, 40), (330.0 - i * 18.0) * s, PI, TAU, 64, colors[i], 18.0 * s, true)
		"puddle":
			Crayon.fill_blob(self, at, Vector2(110, 26) * s, Color("#b9a98a"), seed, 0.12)
		"reed":
			for i in 3:
				var base := at + Vector2((i - 1) * 14.0, 0) * s
				var tip := base + Vector2((i - 1) * 8.0, -120.0 - i * 15.0) * s
				Crayon.line(self, base, tip, Color("#9bbf7a"), 5.0 * s, seed + i, 2.0)
				_rounded(tip + Vector2(-7, 0) * s, Vector2(14, 34) * s, Color("#c9a27c"), seed + i)
		"crater":
			Crayon.fill_blob(self, at, Vector2(90, 24) * s, Color("#d2cde2"), seed, 0.1)
			Crayon.fill_blob(self, at + Vector2(0, 4) * s, Vector2(70, 15) * s, Color("#c7c1da"), seed + 1, 0.1)
		"planet":
			Crayon.fill_blob(self, at, Vector2(70, 70) * s, Color("#a6d4f2"), seed, 0.03)
			Crayon.fill_blob(self, at + Vector2(-18, -10) * s, Vector2(28, 20) * s, Color("#a9dd9a"), seed + 1, 0.3)
			Crayon.fill_blob(self, at + Vector2(25, 22) * s, Vector2(20, 14) * s, Color("#a9dd9a"), seed + 2, 0.3)
		"star":
			Crayon.fill(self, Crayon.star(at, 18.0 * s, seed), Color("#fff3a8"), seed, 4.0, 1.0, 3.0)
		"tower":
			var w := 70.0 * s
			var h := 300.0 * s
			Crayon.fill(self, PackedVector2Array([at + Vector2(-w, 0), at + Vector2(-w, -h),
				at + Vector2(w, -h), at + Vector2(w, 0)]), Color("#d8d1e6"), seed, 10.0, 2.0, 6.0)
			Crayon.fill(self, PackedVector2Array([at + Vector2(-w * 1.25, -h), at + Vector2(0, -h - 150.0 * s),
				at + Vector2(w * 1.25, -h)]), Color("#b9a6e6"), seed + 1, 8.0, 2.0, 5.0)
			Crayon.fill_blob(self, at + Vector2(0, -h * 0.6), Vector2(16, 26) * s, Color("#fff3c4"), seed + 2, 0.05)
			Crayon.line(self, at + Vector2(0, -h - 150.0 * s), at + Vector2(0, -h - 200.0 * s),
				Color("#c9a27c"), 4.0, seed, 0.5)
			Crayon.fill(self, PackedVector2Array([at + Vector2(0, -h - 200.0 * s), at + Vector2(45, -h - 185.0 * s) ,
				at + Vector2(0, -h - 170.0 * s)]), Color("#f08a8a"), seed + 3, 5.0, 1.0, 3.0)
		"flag":
			var colors := [Color("#f7a6c8"), Color("#9cc9ef"), Color("#ffd166"), Color("#a9dd9a")]
			for i in 9:
				var x0 := at.x - 420.0 * s + i * 95.0 * s
				var y0 := at.y + sin(i * 0.7) * 16.0
				Crayon.fill(self, PackedVector2Array([Vector2(x0, y0), Vector2(x0 + 70.0 * s, y0 + 4),
					Vector2(x0 + 35.0 * s, y0 + 60.0 * s)]), colors[i % 4], seed + i, 5.0, 1.0, 3.0)
			Crayon.line(self, at + Vector2(-430, 0) * s, at + Vector2(440, 10) * s, Color("#c9a27c"), 3.0, seed, 4.0)
		"lollipop":
			Crayon.line(self, at, at + Vector2(0, -170) * s, Color("#f5efe6"), 12.0 * s, seed, 1.0)
			var head := at + Vector2(0, -220) * s
			Crayon.fill_blob(self, head, Vector2(62, 62) * s, Color("#f7a6c8"), seed, 0.04)
			for i in 3:
				draw_arc(head, (14.0 + i * 16.0) * s, 0.0, TAU * 0.85, 24, Color("#fff3f8"), 6.0 * s, true)
		"candy_cane":
			var pts := PackedVector2Array()
			for i in 10:
				pts.append(at + Vector2(0, -i * 22.0) * s)
			for i in 9:
				var a := PI - PI * i / 8.0
				pts.append(at + Vector2(30 + cos(a) * 30, -220 - sin(a) * 30) * s)
			draw_polyline(pts, Color("#fff6f6"), 22.0 * s, true)
			for i in range(0, pts.size() - 1, 2):
				draw_line(pts[i], pts[i + 1], Color("#f28a8a"), 22.0 * s, true)
		"gumdrop":
			var c: Color = [Color("#a9dd9a"), Color("#f9c98a"), Color("#c3a9ec")][absi(seed) % 3]
			Crayon.fill(self, PackedVector2Array([at + Vector2(-50, 0) * s, at + Vector2(-38, -50) * s,
				at + Vector2(0, -68) * s, at + Vector2(38, -50) * s, at + Vector2(50, 0) * s]), c, seed, 6.0, 2.0, 4.0)
			for i in 5:
				draw_circle(at + Vector2(-25 + i * 12, -30 - (i % 2) * 14) * s, 3.0 * s, Color(1, 1, 1, 0.8))
		"vine":
			var pts := PackedVector2Array()
			for i in 12:
				pts.append(Vector2(at.x + sin(i * 0.8 + seed) * 12.0, WORLD.position.y + i * 60.0 * s))
			draw_polyline(pts, Color("#8fc98a"), 9.0, true)
			for i in range(2, 12, 2):
				Crayon.fill_blob(self, pts[i] + Vector2(12, 0), Vector2(14, 8), Color("#9ad083"), seed + i, 0.2)


func _trunk(at: Vector2, size: Vector2, color: Color, seed: int) -> void:
	Crayon.fill(self, PackedVector2Array([at + Vector2(-size.x * 0.5, 0), at + Vector2(-size.x * 0.35, -size.y),
		at + Vector2(size.x * 0.35, -size.y), at + Vector2(size.x * 0.5, 0)]), color, seed, 6.0, 2.0, 4.0)


func _rounded(top_left: Vector2, size: Vector2, color: Color, seed: int) -> void:
	var r := minf(size.x, size.y) * 0.5
	var pts := PackedVector2Array()
	for i in 9:
		var a := PI + PI * i / 8.0
		pts.append(top_left + Vector2(r, r) + Vector2(cos(a), sin(a)) * r)
	pts.append(top_left + size)
	pts.append(top_left + Vector2(0, size.y))
	Crayon.fill(self, pts, color, seed, 6.0, 2.0, 4.0)


## Weather that drifts across a place: snow, bubbles, petals, leaves, embers, sparkles.
class Drift extends Node2D:
	var kind := ""
	var _bits: Array[Vector3] = []   # x, y, phase

	func _ready() -> void:
		for i in 36:
			_bits.append(Vector3(randf_range(-200, 1480), randf_range(-100, 720), randf() * TAU))

	func _process(delta: float) -> void:
		var fall: float = {"snow": 40.0, "sprinkles": 35.0, "petals": 30.0, "leaves": 45.0, "bubbles": -50.0, "embers": -35.0,
			"sparkles": 0.0, "fireflies": 0.0, "twinkle": 0.0}.get(kind, 20.0)
		for i in _bits.size():
			var b := _bits[i]
			b.z += delta
			b.y += fall * delta
			b.x += sin(b.z * 1.3) * 18.0 * delta + (12.0 if kind in ["petals", "leaves"] else 0.0) * delta
			if b.y > 760.0:
				b.y = -40.0
			elif b.y < -60.0:
				b.y = 740.0
			if b.x > 1500.0:
				b.x = -200.0
			_bits[i] = b
		queue_redraw()

	func _draw() -> void:
		for i in _bits.size():
			var b := _bits[i]
			var p := Vector2(b.x, b.y)
			match kind:
				"snow":
					draw_circle(p, 4.0, Color(1, 1, 1, 0.9))
				"bubbles":
					draw_arc(p, 7.0, 0, TAU, 16, Color(1, 1, 1, 0.75), 2.0, true)
				"petals":
					draw_circle(p, 4.0, Color("#f7b6d2"))
				"leaves":
					draw_circle(p, 5.0, Color("#a8d47f"))
				"embers":
					draw_circle(p, 3.0, Color(1.0, 0.6, 0.3, 0.6 + 0.4 * sin(b.z * 5.0)))
				"sparkles", "twinkle":
					var a := 0.5 + 0.5 * sin(b.z * 3.0)
					Crayon.line(self, p - Vector2(5, 0), p + Vector2(5, 0), Color(1, 1, 1, a), 2.0, i, 0.0)
					Crayon.line(self, p - Vector2(0, 5), p + Vector2(0, 5), Color(1, 1, 1, a), 2.0, i + 1, 0.0)
				"fireflies":
					draw_circle(p, 4.0, Color(1.0, 0.95, 0.5, 0.4 + 0.5 * sin(b.z * 4.0)))
				"sprinkles":
					var c: Color = [Color("#f28a8a"), Color("#9cc9ef"), Color("#ffd166"), Color("#a9dd9a")][i % 4]
					draw_line(p, p + Vector2(cos(b.z), sin(b.z)) * 7.0, c, 3.0, true)
