class_name RingMeter
extends Control
## The timing ring every competition uses, drawn in crayon colours. Two looks:
##   "sweep" - a hand goes round; tap while it is in the GREEN arc (Dash Race).
##   "pulse" - a ring swells and shrinks; tap when it is BIG (Tug-of-War, Marathon's drum).
## `value` is 0..1 through the current cycle; the game sets it every frame.

var style := "sweep"
var value := 0.0
var zone := Vector2(0.72, 0.92)
var flash := 0.0
var label := ""


func _ready() -> void:
	custom_minimum_size = Vector2(150, 150)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	flash = maxf(0.0, flash - delta * 3.0)
	queue_redraw()


func _draw() -> void:
	var c := size / 2.0
	var r := minf(size.x, size.y) * 0.42
	draw_circle(c, r + 8.0, Color(1, 1, 1, 0.85))
	if style == "sweep":
		draw_arc(c, r, 0.0, TAU, 48, Color("#e2dcef"), 14.0, true)
		draw_arc(c, r, -PI / 2.0 + zone.x * TAU, -PI / 2.0 + zone.y * TAU, 16, Color("#7cc96b"), 16.0, true)
		var a := -PI / 2.0 + value * TAU
		draw_line(c, c + Vector2(cos(a), sin(a)) * r, UI.INK, 6.0, true)
		draw_circle(c, 8.0, UI.INK)
	else:
		var k := 0.35 + 0.65 * value
		var good := value >= zone.x
		draw_arc(c, r, 0.0, TAU, 48, Color("#e2dcef"), 6.0, true)
		draw_circle(c, r * k, Color("#7cc96b") if good else Color("#f7c37a"))
		draw_arc(c, r * k, 0.0, TAU, 40, UI.INK, 4.0, true)
	if flash > 0.0:
		draw_arc(c, r + 14.0, 0.0, TAU, 48, Color(1, 0.85, 0.3, flash), 10.0, true)
	if label != "":
		var font := ThemeDB.fallback_font
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		draw_string_outline(font, Vector2(c.x - w / 2.0, size.y + 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 8, UI.PAPER)
		draw_string(font, Vector2(c.x - w / 2.0, size.y + 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, UI.INK)
