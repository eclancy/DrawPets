class_name RingMeter
extends Control
## The timing ring the track races tap to, drawn in crayon. Three looks:
##   "sweep" - a hand goes round. While it is in the green arc (`zone`) the WHOLE ring lights up
##             green and swells: tap now (Dash Race).
##   "pulse" - a ring swells and shrinks; it is green while big (value >= zone.x) - tap then.
##   "drum"  - a drum in the middle of a pulse ring. The ring is biggest and green on each BOOM,
##             and the drum squashes with rings going out when the game sets `beat` (Big
##             Marathon), so a phone with the sound off still shows the rhythm.
## `value` is 0..1 through the current cycle; the game sets it every frame. `lit()` is the one
## rule for "now!": the game scores a tap by it too, so what the ring shows is what counts.

var style := "sweep"
var value := 0.0
var zone := Vector2(0.72, 0.92)
## A good tap: a yellow ring flashes round it, then fades.
var flash := 0.0
## A drum hit: set to 1 on each BOOM, then dies away (the drum's squash, the rings going out).
var beat := 0.0
var label := ""

const GREEN := Color("#7cc96b")
const GREEN_DEEP := Color("#4f9e47")
const TRACK := Color("#e2dcef")
const SOFT := Color("#f7c37a")

var _drum: Texture2D


func _ready() -> void:
	custom_minimum_size = Vector2(150, 150)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	flash = maxf(0.0, flash - delta * 3.0)
	beat = maxf(0.0, beat - delta * 4.0)
	queue_redraw()


## True when a tap now is a good one - the moment the ring is green.
func lit() -> bool:
	if style == "sweep":
		return value >= zone.x and value <= zone.y
	return value >= zone.x


func _draw() -> void:
	var c := size / 2.0
	var r := minf(size.x, size.y) * 0.42
	var on := lit()
	match style:
		"sweep":
			_sweep(c, r * (1.06 if on else 1.0), on)
		"drum":
			_drum_ring(c, r, on)
		_:
			_pulse(c, r, on)
	if flash > 0.0:
		Crayon.marker_line(self, Crayon.ellipse(c, Vector2(r + 18.0, r + 18.0), 48), Color(1, 0.85, 0.3, flash), 10.0, 9)
	if label != "":
		var font := ThemeDB.fallback_font
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		draw_string_outline(font, Vector2(c.x - w / 2.0, size.y + 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 8, UI.PAPER)
		draw_string(font, Vector2(c.x - w / 2.0, size.y + 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, UI.INK)


## Dash: a paper face with a green arc and a hand going round. In the green, the face itself goes
## green and a glow spreads round it, so "tap when it lights up GREEN" is plainly true.
func _sweep(c: Vector2, r: float, on: bool) -> void:
	if on:
		Crayon.marker_line(self, Crayon.ellipse(c, Vector2(r + 16.0, r + 16.0), 48), Color(GREEN, 0.55), 14.0, 1)
	Crayon.fill_blob(self, c, Vector2(r + 8.0, r + 8.0), GREEN.lightened(0.25) if on else Color(1, 1, 1, 0.9), 2, 0.02)
	Crayon.marker_line(self, Crayon.ellipse(c, Vector2(r, r), 48), GREEN_DEEP if on else TRACK, 14.0, 3)
	var arc := PackedVector2Array()
	for i in 13:
		var a := -PI / 2.0 + lerpf(zone.x, zone.y, i / 12.0) * TAU
		arc.append(c + Vector2(cos(a), sin(a)) * r)
	Crayon.marker_line(self, arc, GREEN_DEEP if on else GREEN, 20.0, 4, false)
	var hand := -PI / 2.0 + value * TAU
	Crayon.line(self, c, c + Vector2(cos(hand), sin(hand)) * r * 0.92, UI.INK, 8.0, 5, 1.0)
	Crayon.fill_blob(self, c, Vector2(10, 10), UI.INK, 6)


## A ring that swells and shrinks: green while it is big.
func _pulse(c: Vector2, r: float, on: bool) -> void:
	var k := 0.35 + 0.65 * value
	Crayon.fill_blob(self, c, Vector2(r + 8.0, r + 8.0), Color(1, 1, 1, 0.85), 2, 0.02)
	Crayon.marker_line(self, Crayon.ellipse(c, Vector2(r, r), 48), TRACK, 6.0, 3)
	var col := GREEN if on else SOFT
	Crayon.fill_blob(self, c, Vector2(r * k, r * k), col, 7, 0.03)
	Crayon.marker_line(self, Crayon.ellipse(c, Vector2(r * k, r * k), 40), col.darkened(0.4), 4.0, 8)


## Marathon: the drum (the game's own drawing of one, as on the event's how-to card), with the
## ring swelling out from behind it to the edge - and going green - on every BOOM; on the hit it
## squashes flat, then hops back up, and rings go out from it.
func _drum_ring(c: Vector2, r: float, on: bool) -> void:
	Crayon.fill_blob(self, c, Vector2(r + 8.0, r + 8.0), Color(1, 1, 1, 0.85), 2, 0.02)
	Crayon.marker_line(self, Crayon.ellipse(c, Vector2(r, r), 48), GREEN_DEEP if on else TRACK, 6.0, 3)
	var k := 0.5 + 0.5 * value
	var col := GREEN if on else Color(SOFT, 0.7)
	Crayon.fill_blob(self, c, Vector2(r * k, r * k), col, 7, 0.03)
	Crayon.marker_line(self, Crayon.ellipse(c, Vector2(r * k, r * k), 40), col.darkened(0.35), 5.0, 8)
	if _drum == null:
		_drum = Items.art_texture("kit_drum")
	var h := r * 1.2
	var w := h * _drum.get_width() / maxf(_drum.get_height(), 1.0)
	var foot := c + Vector2(0, h * 0.52)
	# `beat` runs 1 -> 0 over a quarter of a second: flat on the BOOM, up in the air halfway.
	var squash := clampf((beat - 0.6) / 0.4, 0.0, 1.0)
	var hop := sin(beat * PI) * r * 0.12 * (1.0 - squash)
	draw_set_transform(foot - Vector2(0, hop), 0.0, Vector2(1.0 + 0.14 * squash, 1.0 - 0.2 * squash))
	draw_texture_rect(_drum, Rect2(-w / 2.0, -h, w, h), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if beat > 0.0:
		var mid := foot + Vector2(0, -h * 0.4)
		for i in 2:
			var rr := r * 0.7 + (1.0 - beat) * r * 0.45 + i * 14.0
			Crayon.marker_line(self, Crayon.ellipse(mid, Vector2(rr, rr * 0.6), 40), Color(UI.ACCENT, beat * 0.8), 5.0, 11 + i)
