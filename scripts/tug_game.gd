class_name TugGame
extends Node2D
## Tug-of-War Cup - STRENGTH (.ai/competitions.md). Three rounds, one rival each, weakest
## first; lose a round and the cup is over. Pull the ribbon to your flag to win.
##
## Pull like a real tug of war: a big sign in the sky says TAP! (green, a drum boom) - tap tap tap
## as fast as you can and your pet heaves the rope your way - then STOP (red, an open hand): keep
## still while it rests, or it slips back. Then TAP! again. Tapping in time adds to the pet's
## strength; tapping while it says STOP takes a little away, so tapping all the time is not the
## way. A strong pet still does well with a clumsy kid.
##
## Round 1 shows how first: a drawn hand taps the sign, then keeps still on STOP ("Watch!"), then
## the kid tries a go ("Your turn!") before the rope is live. If the kid stops tapping for a whole
## go, the hand comes back to show it again.

signal finished(scores: Array)

## How far the ribbon has to go to win, at first. After LINES_WAIT seconds of a stuck round the
## lines walk in to LINE_MIN, so every round ends.
const LINE := 150.0
const LINE_MIN := 60.0
const LINES_WAIT := 20.0
## A go: TAP for this long, then STOP for this long.
const TAP_TIME := 2.4
const STOP_TIME := 2.0
const CYCLE := TAP_TIME + STOP_TIME
## Tap faster, pull harder: the pull is how many taps came in the last RATE_WINDOW seconds,
## full at FULL_TAPS (about five a second). Each tap on STOP slips this much.
const RATE_WINDOW := 0.8
const FULL_TAPS := 4.0
const SLIP_PER_TAP := 0.6
const SLIP_FADE := 1.5
## Everyone stops a moment late: taps this soon after STOP comes up count for nothing either way.
const STOP_GRACE := 0.3
## Taps closer together than this are one (a finger bouncing).
const TAP_GAP := 0.06
## What tapping in time adds to the pet's pull (its strength gives 0.8 a point), what slipping
## takes off, and a rival's heave. Tapping fast all through a TAP is worth about 20 strength
## points over a rival who heaves now and then - enough to beat a cup's first rival with any pet,
## and the later ones with a trained one. Tapping on STOP costs more than it gains, so a kid who
## never stops tapping loses even to the first rival.
const HEAVE_K := 50.0
const SLIP_K := 70.0
const RIVAL_HEAVE_K := 30.0
## How fast the rope moves for a difference in pull.
const DRAG := 1.8
## Taps in one TAP! that make a great pull.
const GREAT := 6
## The sign, in the sky over the middle of the field.
const SIGN_AT := Vector2(640, 300)

const PULL_GREEN := Color("#5fb85a")
const STOP_RED := Color("#e8664e")

var screen: CompetitionScreen

var _round := 0
var _wins := 0
var _m := 0.0
var _t := 0.0
var _live_t := 0.0
var _line := LINE
var _over := false
## How hard the kid has the pet pulling now (0-1), and how far it has slipped.
var _power := 0.0
var _slip := 0.0
var _taps := 0
var _stop_taps := 0
## When the last few taps on TAP! came (the rhythm's clock).
var _tap_times: Array = []
var _last_tap := -10.0
var _idle := 0.0
var _phase := 0
var _rival_heave := 0.0
var _rival_pulls := false
var _player: Creature
var _rival: Creature
var _player_x := 400.0
var _rival_x := 880.0
var _rope: Sprite2D
var _sign: TapSign
var _msg: Label
var _round_label: Label
var _hint: HowTo
var _hud: Control
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = Events.seed_of(screen.event, screen.tier) + 7
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	_rope = Sprite2D.new()
	_rope.texture = Items.art_texture("prop_rope_long")
	_rope.z_index = 2
	add_child(_rope)
	_player = CompetitionScreen.racer(screen.pet)
	_player.z_index = 1
	add_child(_player)
	_build_hud()
	_new_round()


func _new_round() -> void:
	if _rival != null:
		_rival.queue_free()
	var r: Dictionary = screen.rivals[_round]
	_rival = CompetitionScreen.racer(r["pet"])
	_rival.facing = -1.0
	_rival.z_index = 1
	add_child(_rival)
	_m = 0.0
	_line = LINE
	_live_t = 0.0
	_power = 0.0
	_slip = 0.0
	_tap_times.clear()
	_last_tap = -1000.0  # the clock starts again each round
	_taps = 0
	_stop_taps = 0
	_rival_heave = 0.0
	_rival_pulls = false
	_over = false
	# Round 1: a go of watching the hand, a go of trying. Later rounds: a STOP to get ready.
	_t = -2.0 * CYCLE if _round == 0 else -STOP_TIME
	_phase = phase_index(_t)
	_round_label.text = "Round %d of 3 - vs %s" % [_round + 1, r["name"]]
	_player.perform("tug", 999.0)
	_rival.perform("tug", 999.0)
	# The ribbon starts exactly in the middle, so it reaches a line exactly when the round is won.
	_player_x = 400.0
	_rival_x = 880.0
	_player.position = Vector2(_player_x, 610)
	_rival.position = Vector2(_rival_x, 610)
	var mid := (_player.mouth_global().x + _rival.mouth_global().x) / 2.0
	_player_x += 640.0 - mid
	_rival_x += 640.0 - mid
	_place_pets()
	queue_redraw()
	if _round == 0:
		_show_hint("Watch!")
	else:
		_say("Get ready...")


func _draw() -> void:
	Crayon.sky(self, Rect2(-300, -100, 1880, 560), Color("#a9d8f2"), Color("#e9f6fa"))
	var hills := PackedVector2Array([Vector2(-300, 470)])
	for i in 22:
		hills.append(Vector2(-300 + i * 90, 430.0 - 40.0 * (0.6 + 0.4 * sin(i * 0.8))))
	hills.append(Vector2(1700, 470))
	Crayon.fill(self, hills, Color("#b5df95"), 9, 14.0, 0.0, 7.0)
	draw_rect(Rect2(-300, 455, 1880, 400), Color("#c6e89d"))
	# Your side of the field, softly in your colour, with your flag on the line to reach.
	Crayon.fill(self, PackedVector2Array([Vector2(-300, 520), Vector2(640, 520), Vector2(640, 640),
		Vector2(-300, 640)]), Color(UI.ACCENT, 0.18), 21, 12.0, 0.0, 5.0)
	for side: float in [-1.0, 1.0]:
		var x := 640.0 + side * _line
		Crayon.line(self, Vector2(x, 520), Vector2(x, 630), Color(1, 1, 1, 0.9), 7.0, int(side) + 3, 2.0)
		Crayon.line(self, Vector2(x, 520), Vector2(x, 450), Color("#a07b52"), 5.0, int(side) + 5, 1.0)
		var flag := PackedVector2Array([Vector2(x, 450), Vector2(x + 52.0 * -side, 466), Vector2(x, 482)])
		Crayon.fill(self, flag, UI.ACCENT if side < 0.0 else Color("#b9b0d8"), int(side) + 7, 6.0)
	Crayon.line(self, Vector2(640, 540), Vector2(640, 630), Color(1, 1, 1, 0.5), 4.0, 2, 2.0)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Control.new()
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.full_rect(_hud))
	_round_label = UI.title("", 34)
	_round_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_round_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_round_label.offset_top = 20
	_hud.add_child(_round_label)
	_msg = UI.title("", 46)
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = 120
	_hud.add_child(_msg)
	_sign = TapSign.new()
	_sign.position = SIGN_AT - TapSign.BOX / 2.0
	_hud.add_child(_sign)


# --- Taps ----------------------------------------------------------------------------------------
# A press anywhere is a tap (mouse events, which a phone also makes from the first finger).

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tap()


func tap() -> void:
	if _over or _t - _last_tap < TAP_GAP:
		return
	_last_tap = _t
	_idle = 0.0
	if _hint != null:
		_hint.dismiss()
		_hint = null
		# Still watching the hand? Straight on to trying it.
		if _t < -CYCLE:
			_t += ceilf((-CYCLE - _t) / CYCLE) * CYCLE
			_phase = phase_index(_t)
	_tapped(is_pull(_t), true)


## A tap - the kid's, or the hand's while it shows how - lands on TAP! (a pull) or on STOP (a slip).
func _tapped(pulling: bool, kid: bool) -> void:
	if pulling:
		_tap_times.append(_t)
		_taps += 1
		_sign.pop = 1.0
		Sounds.play_varied("tug", 1.0 + 0.06 * (_taps % 4), 0.04)
	elif fposmod(_t, CYCLE) - TAP_TIME >= STOP_GRACE:
		_slip = minf(1.0, _slip + SLIP_PER_TAP)
		_stop_taps += 1
		_sign.shake = 1.0
		if kid:
			_say("STOP! Keep still...", STOP_RED)
			Sounds.play("ui_nope")


## The hand taps while it shows how: before the rope is live, the pet pulls for it, as it will for
## the kid. Once it is live the hand's taps only bounce the sign - they never pull for the kid.
func _hint_tapped() -> void:
	if _t < 0.0:
		_tapped(is_pull(_t), false)
	elif is_pull(_t):
		_sign.pop = 1.0


## How hard the taps in `times` pull at time `now`: those in the last RATE_WINDOW seconds, out of
## FULL_TAPS (older ones are dropped from `times`).
static func rate_power(times: Array, now: float) -> float:
	while not times.is_empty() and float(times[0]) < now - RATE_WINDOW:
		times.pop_front()
	return clampf(times.size() / FULL_TAPS, 0.0, 1.0)


## TAP! or STOP at time `t`: each go starts with TAP!.
static func is_pull(t: float) -> bool:
	return fposmod(t, CYCLE) < TAP_TIME


## Which TAP! or STOP this is (counting up, two to a go).
static func phase_index(t: float) -> int:
	return int(floor(t / CYCLE)) * 2 + (0 if is_pull(t) else 1)


## How much of this TAP! or STOP is left, 1 down to 0.
static func phase_left(t: float) -> float:
	var p := fposmod(t, CYCLE)
	return 1.0 - (p / TAP_TIME if p < TAP_TIME else (p - TAP_TIME) / STOP_TIME)


## Where the hand is in its poke (HowTo's phase: it presses at 0.5) - quick taps on TAP!, and up
## and still on STOP.
static func hint_phase(t: float) -> float:
	if not is_pull(t):
		return 0.0
	return fmod(fposmod(t, CYCLE), 0.36) / 0.36


func _hint_phase() -> float:
	return hint_phase(_t)


func _sign_point() -> Vector2:
	return SIGN_AT + Vector2(0, 16)


func _show_hint(text: String) -> void:
	if _hint != null:
		_hint.dismiss()
	_hint = HowTo.new()
	_hint.gesture = "tap"
	_hint.at = _sign_point
	_hint.phase = _hint_phase
	_hint.on_press = _hint_tapped
	_hint.caption = text
	_hint.caption_y = 120.0
	_hud.add_child(_hint)


func _say(text: String, color := UI.INK) -> void:
	_msg.text = text
	_msg.modulate.a = 1.0
	_msg.add_theme_color_override("font_color", color)


# --- Each frame ----------------------------------------------------------------------------------

func _process(delta: float) -> void:
	if _over:
		_msg.modulate.a = maxf(0.0, _msg.modulate.a - delta * 0.8)
		return
	_t += delta
	var live := _t >= 0.0
	var watching := _round == 0 and _t < -CYCLE
	_msg.modulate.a = maxf(0.0, _msg.modulate.a - delta * (0.0 if _t < 0.0 else 0.9))
	if not watching:
		_idle += delta

	var phase := phase_index(_t)
	if phase != _phase:
		_phase = phase
		_new_phase(live)

	var pulling := is_pull(_t)
	_power = move_toward(_power, rate_power(_tap_times, _t) if pulling else 0.0, delta * 5.0)
	_slip = maxf(0.0, _slip - delta * SLIP_FADE)
	_rival_heave = move_toward(_rival_heave, 1.0 if pulling and _rival_pulls else 0.0, delta * 8.0)
	_player.effort = _power
	_rival.effort = _rival_heave
	_sign.t = _t

	if _t < 0.0:
		# The rope is still: keep the ribbon right in the middle, so it starts there.
		var mid := (_player.mouth_global().x + _rival.mouth_global().x) / 2.0
		_player_x += 640.0 - mid
		_rival_x += 640.0 - mid
		_place_pets()
		return

	_live_t += delta
	if _live_t > LINES_WAIT:
		var line := lerpf(LINE, LINE_MIN, clampf((_live_t - LINES_WAIT) / LINES_WAIT, 0.0, 1.0))
		if absf(line - _line) > 1.0:
			_line = line
			queue_redraw()
	# A whole go with no tap: the hand comes back to show it again.
	if _idle > CYCLE and _hint == null:
		_show_hint("TAP TAP TAP, then STOP!")
	var r: Dictionary = screen.rivals[_round]
	var player_pull := 30.0 + Stats.value(screen.pet, "strength") * 0.8 + _power * HEAVE_K - _slip * SLIP_K
	var rival_pull := 30.0 + Stats.value(r["pet"], "strength") * 0.8 + _rival_heave * RIVAL_HEAVE_K \
		+ sin(_t * 1.3) * 3.0
	_m += (rival_pull - player_pull) * DRAG * delta
	_place_pets()
	# Won or lost when the ribbon itself reaches a line.
	var ribbon := (_player.mouth_global().x + _rival.mouth_global().x) / 2.0 - 640.0
	if ribbon <= -_line:
		_end_round(true)
	elif ribbon >= _line:
		_end_round(false)


## A TAP! or a STOP begins: how did the last TAP! go, the drum, the rival's heave, the countdown.
func _new_phase(live: bool) -> void:
	var pulling := is_pull(_t)
	var trying := _t >= -CYCLE
	if not pulling:
		# A TAP! just ended: how was it?
		if trying and _hint == null:
			if _taps >= GREAT:
				_say("Great pulling!" if live else "Yes! Now STOP!", PULL_GREEN)
				_sign.pop = 1.0
				Sounds.play("heave")
				if live:
					Voice.speak(screen.pet, "tug", _player)
			elif _taps >= 2:
				_say("Tap faster!" if live else "Now STOP!", PULL_GREEN.darkened(0.15))
			elif not live and _round == 0:
				_say("Now STOP!")
		_taps = 0
		Sounds.play("slide")
		return
	_stop_taps = 0
	Sounds.play("drum_beat")
	if live:
		var r: Dictionary = screen.rivals[_round]
		_rival_pulls = _rng.randf() < 0.3 + Stats.value(r["pet"], "strength") / 200.0
	# The countdown, a go at a time: watch, your turn, GO - always on a TAP!.
	var go := int(floor(_t / CYCLE + 0.01))
	if go == -1 and _round == 0:
		if _hint != null:
			_hint.dismiss()
			_hint = null
		_say("Your turn! TAP TAP TAP!")
	elif go == 0:
		_say("GO!", PULL_GREEN)
		Sounds.play("count_go")


func _place_pets() -> void:
	_player.position = Vector2(_player_x + _m, 610)
	_rival.position = Vector2(_rival_x + _m, 610)
	_place_rope()


func _place_rope() -> void:
	if _player == null or _rival == null:
		return
	var a := _player.mouth_global()
	var b := _rival.mouth_global()
	var tex := _rope.texture
	_rope.position = (a + b) / 2.0
	_rope.rotation = (b - a).angle()
	var k := (b - a).length() / maxf(tex.get_width(), 1.0)
	_rope.scale = Vector2(k, clampf(k, 0.2, 0.6))


func _end_round(won: bool) -> void:
	_over = true
	_player.effort = 0.0
	_rival.effort = 0.0
	if _hint != null:
		_hint.dismiss()
		_hint = null
	_player.interrupt()
	_rival.interrupt()
	if won:
		_wins += 1
		_player.perform("celebrate", 1.5)
		_say("You win round %d!" % (_round + 1), PULL_GREEN)
		Sounds.play("cheer")
		_player.say("star")
	else:
		_rival.perform("celebrate", 1.5)
		_say("%s wins!" % screen.rivals[_round]["name"])
		Sounds.play("ui_nope")
		_rival.say("star")
	await _pause(1.8)
	if won and _round < 2:
		_round += 1
		_new_round()
		return
	# Places: beat all three = 1st; the rival who knocked you out finishes above you.
	var scores := [{"who": "player", "score": _wins + 0.5}]
	for i in 3:
		var s := float(i)
		if not won and i == _round:
			s = 3.0
		scores.append({"who": i, "score": s})
	finished.emit(scores)


## Waits on a timer of the game's own, so a kid who leaves with Stop in the meantime leaves
## nothing behind to wake up: the timer goes with the game, and the wait with it.
func _pause(seconds: float) -> Signal:
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = seconds
	add_child(t)
	t.start()
	t.timeout.connect(t.queue_free)
	return t.timeout


## The big sign: a green TAP! circle with a tapping finger, or a red STOP with an open hand, and a
## ring round it running down the time left. `t` is the rhythm's clock (set by the owner every
## frame); `pop` bounces it (a tap in time), `shake` wobbles it (a tap on STOP). Used by the cup,
## the cup's how-to picture and the rope tug at home.
class TapSign extends Control:
	const BOX := Vector2(220, 220)
	const RADIUS := 74.0
	var t := 0.0
	var pop := 0.0
	var shake := 0.0
	## Off: just the word, still (before a game starts).
	var radius := RADIUS
	var _word: Label
	var _icon: TextureRect
	var _was := -1

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = BOX
		_icon = UI.icon("ui_point", 40, "none")
		_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_icon)
		_word = UI.title("", 40)
		_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_word.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_word.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_word.add_theme_color_override("font_color", UI.CARD)
		_word.add_theme_color_override("font_outline_color", UI.INK)
		_word.add_theme_constant_override("outline_size", 8)
		add_child(_word)

	func _process(delta: float) -> void:
		pop = maxf(0.0, pop - delta * 4.0)
		shake = maxf(0.0, shake - delta * 3.0)
		var pulling := TugGame.is_pull(t)
		var now := 0 if pulling else 1
		if now != _was:
			_was = now
			_word.text = "TAP!" if pulling else "STOP"
			_icon.texture = Items.art_texture("ui_point" if pulling else "tool_hand")
		var k := radius / RADIUS
		_word.add_theme_font_size_override("font_size", int(40 * k))
		_word.position = size / 2.0 - Vector2(radius, radius * 0.55)
		_word.size = Vector2(radius * 2.0, radius * 0.7)
		var ic := 40.0 * k
		_icon.size = Vector2(ic, ic)
		_icon.position = size / 2.0 + Vector2(-ic / 2.0, radius * 0.18)
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0 + Vector2(sin(shake * 40.0) * 10.0 * shake, 0.0)
		var r := radius * (1.0 + 0.12 * pop)
		var pulling := TugGame.is_pull(t)
		var col := TugGame.PULL_GREEN if pulling else TugGame.STOP_RED
		var shape := PackedVector2Array()
		var corners := 24 if pulling else 8
		for i in corners:
			var a := TAU * (i + (0.0 if pulling else 0.5)) / corners
			shape.append(c + Vector2.from_angle(a) * r)
		Crayon.marker_fill(self, shape, col, 61 if pulling else 62)
		Crayon.marker_line(self, shape, col.darkened(0.35), 6.0, 63)
		# The time left, as a ring running down.
		var left := TugGame.phase_left(t)
		var arc := PackedVector2Array()
		var n := maxi(2, int(40.0 * left))
		for i in n + 1:
			arc.append(c + Vector2.from_angle(-PI / 2.0 + TAU * left * i / n) * (r + 14.0))
		Crayon.marker_line(self, arc, Color(col, 0.75), 7.0, 64, false)
