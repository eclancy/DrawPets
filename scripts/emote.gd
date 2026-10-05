class_name Emote
extends Node2D
## A little crayon symbol that floats up off a creature and fades: a heart when it is happy,
## a star when it gets something it loves, a note when it is called, zzz when it sleeps.
## Never black (black is the kids'), and never words - the creature can't talk.

var kind := "heart"
var life := 1.5
var _age := 0.0
var _drift := Vector2(0, -70)
var _seed := 0


func _ready() -> void:
	_seed = randi() % 997
	_drift.x = randf_range(-30.0, 30.0)
	z_index = 50


func _process(delta: float) -> void:
	_age += delta
	position += _drift * delta
	_drift.y *= 1.0 - delta * 0.6
	modulate.a = 1.0 - smoothstep(life * 0.55, life, _age)
	scale = Vector2.ONE * minf(1.0, 0.4 + _age * 5.0)
	if _age >= life:
		queue_free()


func _draw() -> void:
	match kind:
		"heart":
			var pts := Crayon.heart(Vector2.ZERO, 34.0)
			Crayon.fill(self, pts, Color("#f2557a"), _seed, 5.0, 2.0, 3.0)
			pts.append(pts[0])
			draw_polyline(pts, Color("#c23a62"), 3.0, true)
		"star":
			var pts := Crayon.star(Vector2.ZERO, 22.0, _seed)
			Crayon.fill(self, pts, Color("#ffd23f"), _seed, 4.0, 2.0, 3.0)
			pts.append(pts[0])
			draw_polyline(pts, Color("#d19a12"), 3.0, true)
		"note":
			var c := Color("#8a4fd1")
			draw_circle(Vector2(-6, 8), 8.0, c)
			draw_line(Vector2(1, 8), Vector2(1, -18), c, 3.5, true)
			draw_line(Vector2(1, -18), Vector2(12, -10), c, 3.5, true)
		"zzz":
			var c := Color("#6a7fd1")
			for i in 3:
				var o := Vector2(i * 12.0, -i * 14.0)
				var s := 7.0 + i * 2.0
				draw_polyline(PackedVector2Array([o + Vector2(-s, -s), o + Vector2(s, -s),
					o + Vector2(-s, s), o + Vector2(s, s)]), c, 3.0, true)
		"question":
			var font := ThemeDB.fallback_font
			draw_string_outline(font, Vector2(-10, 12), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, 8,
				UI.PAPER)
			draw_string(font, Vector2(-10, 12), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, UI.INK)
		"drop":
			for i in 3:
				var p := Vector2((i - 1) * 14.0, -absf(Crayon.noise(_seed, i)) * 10.0)
				draw_colored_polygon(PackedVector2Array([p + Vector2(0, -9), p + Vector2(6, 2), p + Vector2(0, 7),
					p + Vector2(-6, 2)]), Color("#8fcdea"))
		"crumb":
			for i in 4:
				draw_circle(Vector2(Crayon.noise(_seed, i) * 14.0, Crayon.noise(_seed + 3, i) * 8.0),
					3.5, Color("#c98d4a"))
