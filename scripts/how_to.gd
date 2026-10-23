class_name HowTo
extends Control
## "How to play", shown rather than told: a drawn hand (ui_point) does the move on the screen -
## taps the spot, holds it, pulls left and lets go right, flicks - with one big line saying it.
## Players start at 7 and many barely read, so every game shows one where the move happens,
## before or while it counts down; it goes when the game says, or after `seconds`.
##
## Set the fields, then add it over the game (a full-screen Control in the game's HUD layer; it
## never takes a touch). `dismiss()` fades it away.
##
##   gesture  "tap"    - pokes `at`, a ring pops (tap anywhere, a button, a target)
##            "taps"   - pokes each of `targets` in turn (tricks: the cards, in order)
##            "hold"   - presses `at` and stays, a ring filling
##            "drag"   - presses `at`, slides to `to`, back again, over and over
##            "swipe"  - flicks from `at` to `to`
##            "follow" - keeps its fingertip on `follow` (a moving target), pressed
##
## Anywhere a point is wanted, a Callable returning one works too, so the hand can stay on a
## thing that moves (a button that pops up, the guide on the tug-of-war rope). Points are in the
## HUD's (screen) space: for something in a camera's world, pass
## `node.get_global_transform_with_canvas().origin`. `sound` plays and `on_press` is called each
## time the hand presses, so the game can show what a press does: the pet hops, the ring flashes.
##
## `phase`, when set, says where the GAME is in its own cycle (0..1) and the hand moves to that
## instead of its own clock, pressing at 0.5 - so it taps exactly when the ring is green, or on
## the drum. With `until_touch` it goes at the kid's first touch (it never takes the touch).
## Showing it again when the kid rests is the game's job: only the game knows which input counts.
##
## Rules for a game: one sentence on screen at a time (hide your own instruction label while a
## HowTo is up), captions of six words or fewer, and the hand shows the real cue - never a move
## that does not work.

var gesture := "tap"
var caption := ""
var at: Variant = Vector2(640, 420)
var to: Variant = Vector2(840, 420)
var targets: Array = []
var follow := Callable()
## One go of the move, in seconds.
var period := 1.3
## Where the game is in its own cycle, 0..1, pressing at 0.5 (see above). Empty: its own clock.
var phase := Callable()
## Goes at the kid's first touch.
var until_touch := false
## 0 to stay until dismissed.
var seconds := 0.0
var sound := ""
var on_press := Callable()
## Where the caption sits, from the top of the screen.
var caption_y := 150.0
var hand_height := 150.0

## Leans a little, the way a real finger comes at a screen.
const LEAN := -0.32
## Nearer the bottom of the screen than this, the hand reaches down from above instead, or it
## would be off the screen with only its fingertip showing (buttons along the bottom).
const FROM_ABOVE := 190.0

var _t := 0.0
var _finger := Vector2.ZERO
var _press := 0.0
var _was_pressed := false
var _last_u := 0.0
var _turn := 0
var _hand: Texture2D
var _pivot := Vector2.ZERO
var _label: Label
var _going := false
var _trail: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hand = Items.art_texture("ui_point")
	_pivot = Items.art_pivot("ui_point", _hand.get_image())
	if caption != "":
		_label = UI.title(caption, 46)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_label.offset_top = caption_y
		add_child(_label)
	_step(0.0)


## True for the first `n` times it is asked about `key` (and remembers asking), so a hint can show
## for a kid's first few goes at something and then leave them be.
static func first_times(profile: Profile, key: String, n: int) -> bool:
	for i in n:
		if profile.first_time("%s_%d" % [key, i]):
			return true
	return false


func _input(event: InputEvent) -> void:
	if until_touch and event is InputEventMouseButton and event.pressed:
		dismiss()


## Starts the move from the beginning (a replay).
func restart() -> void:
	_t = 0.0
	_turn = 0
	_trail.clear()


func _process(delta: float) -> void:
	_t += delta
	if seconds > 0.0 and _t >= seconds:
		dismiss()
	_step(delta)
	queue_redraw()


static func _point(p: Variant) -> Vector2:
	if p is Callable:
		return (p as Callable).call()
	return p


## Where the fingertip is and how hard it is pressing, this moment of the move.
func _step(delta: float) -> void:
	var u := fmod(_t, period) / period
	if phase.is_valid():
		# The game's cycle, shifted so the press (u near 0.5) lands on its moment.
		u = fposmod(float(phase.call()), 1.0)
	var spot := _point(at)
	var lift := Vector2(26, -46) if _down_from_above(spot) else Vector2(26, 46)
	match gesture:
		"tap", "taps":
			if gesture == "taps" and not targets.is_empty():
				spot = _point(targets[_turn % targets.size()])
			# Comes down, pokes, goes back up.
			var down := _bump(u, 0.3, 0.55)
			_finger = spot + lift * (1.0 - down)
			_press = 1.0 if u > 0.42 and u < 0.62 else 0.0
		"hold":
			var down := _bump(u, 0.15, 0.85)
			_finger = spot + lift * (1.0 - down)
			_press = clampf((u - 0.2) / 0.6, 0.0, 1.0) if u > 0.2 and u < 0.85 else 0.0
		"drag":
			# Pressed the whole time: across to `to`, then back to `at`.
			var k := 0.5 - 0.5 * cos(u * TAU)
			_finger = spot.lerp(_point(to), k)
			_press = 1.0
		"swipe":
			var k := clampf((u - 0.2) / 0.3, 0.0, 1.0)
			k = k * k * (3.0 - 2.0 * k)
			_finger = spot.lerp(_point(to), k) + lift * (1.0 if u < 0.15 or u > 0.65 else 0.0)
			_press = 1.0 if u >= 0.15 and u <= 0.55 else 0.0
		"follow":
			_finger = _point(follow) if follow.is_valid() else spot
			_press = 1.0
	# A press, once per press: the game's sound and reaction.
	var pressed := _press > 0.0
	# "taps" moves on to the next target each time round.
	if u < _last_u:
		_turn += 1
	_last_u = u
	if gesture in ["tap", "taps", "hold", "swipe"] and pressed and not _was_pressed:
		if sound != "":
			Sounds.play(sound)
		if on_press.is_valid():
			on_press.call()
	_was_pressed = pressed
	if pressed and gesture in ["drag", "swipe", "follow"]:
		_trail.append([_finger, 0.5])
	for p in _trail:
		p[1] -= delta
	_trail = _trail.filter(func(p): return p[1] > 0.0)


func _down_from_above(p: Vector2) -> bool:
	return p.y > size.y - FROM_ABOVE


## 0 -> 1 -> 0 over [a, b] of the cycle.
static func _bump(u: float, a: float, b: float) -> float:
	if u <= a or u >= b:
		return 0.0
	return sin((u - a) / (b - a) * PI)


func _draw() -> void:
	# A soft marker trail where the finger slid, and a ring popping where it presses.
	for i in _trail.size():
		var tp: Vector2 = _trail[i][0]
		Crayon.marker_line(self, PackedVector2Array([tp, tp + Vector2(0.5, 0.0)]),
			Color(UI.ACCENT, float(_trail[i][1]) * 0.7), 16.0, i, false)
	if _press > 0.0:
		var r := 22.0 + 16.0 * (_press if gesture == "hold" else fmod(_t * 3.0, 1.0))
		Crayon.marker_line(self, Crayon.ellipse(_finger, Vector2(r, r), 24), Color(UI.ACCENT, 0.85), 6.0, 7)
		if gesture == "hold":
			var arc := PackedVector2Array()
			for i in 25:
				arc.append(_finger + Vector2.from_angle(-PI / 2.0 + TAU * _press * i / 24.0) * 40.0)
			Crayon.marker_line(self, arc, UI.GOOD, 8.0, 8, false)
	if _hand == null:
		return
	var k := hand_height / maxf(float(_hand.get_height()), 1.0)
	draw_set_transform(_finger, PI - LEAN if _down_from_above(_finger) else LEAN, Vector2(k, k))
	draw_texture(_hand, -_pivot)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Fades away, then is gone.
func dismiss() -> void:
	if _going:
		return
	_going = true
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.35)
	t.tween_callback(queue_free)
