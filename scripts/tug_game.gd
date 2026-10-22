class_name TugGame
extends Node2D
## Tug-of-War Cup - STRENGTH (.ai/competitions.md). Three rounds, one rival each, weakest
## first; lose a round and the cup is over. Drag the ribbon to your line to win.
##
## Pull like a real tug of war: heave, ease, heave. The rope's handle lies across the sky over the
## field, where a thumb (and the hint's hand) has room, and a guide ring slides along it in time - LEFT (pull!)
## then back RIGHT (let go) - with a drum on every pull. Thumb on the handle, slide it left with
## the guide, let it back right, again. Pulling with the guide adds to the pet's strength; out of
## time it adds nothing (and costs nothing), so a strong pet still does well with a clumsy pull.
##
## Round 1 shows how first: a drawn hand works the handle for two beats ("Watch!"), then the kid
## tries for two beats ("Your turn!") before the rope is live. If the thumb rests for two beats
## while it counts, the hand comes back to show it again.

signal finished(scores: Array)

## How far the ribbon has to go to win, at first. After LINES_WAIT seconds of a stuck round the
## lines walk in to LINE_MIN, so every round ends.
const LINE := 150.0
const LINE_MIN := 60.0
const LINES_WAIT := 20.0
## The beat: the first half pulls, the second lets go.
const BEAT := 1.4
## The handle's slide, in screen px - 1 to 1 under the thumb.
const STROKE := 320.0
const BAR_Y := 330.0
const BAR_LEFT := 480.0
const BAR_RIGHT := 800.0
## What a pull in time adds to the pet's pull (its strength gives 0.8 a point), and a rival's
## heave. Pulling in time all the way through is worth about 20 strength points over a rival who
## heaves now and then - enough to beat a cup's first rival with any pet, and the later ones with
## a trained one.
const HEAVE_K := 50.0
const RIVAL_HEAVE_K := 30.0
## How fast the rope moves for a difference in pull.
const DRAG := 1.8
## How near the handle must be to the guide (as a share of the slide): this near counts fully,
## and it fades to nothing by NEAR_ZERO further.
const NEAR := 0.08
const NEAR_ZERO := 0.45
## A thumb follows a moving thing a moment late: being where the guide was this long ago counts.
const LAG := 0.25

const PULL_GREEN := Color("#5fb85a")
const LET_GO := Color("#e9a94e")

var screen: CompetitionScreen

var _round := 0
var _wins := 0
var _m := 0.0
var _t := 0.0
var _live_t := 0.0
var _line := LINE
var _over := false
## The handle: 0 let out (right), 1 pulled (left). Held by a thumb, or paying out on its own.
var _h := 0.0
var _prev_h := 0.0
var _vel := 0.0
var _held := false
var _down_x := 0.0
var _down_h := 0.0
var _idle := 0.0
## This beat's pull: how far the handle went left, and how near the guide it stayed.
var _travel := 0.0
var _near_sum := 0.0
var _near_time := 0.0
var _half := 0
var _heave := 0.0
var _rival_heave := 0.0
var _rival_pulls := false
var _player: Creature
var _rival: Creature
var _player_x := 400.0
var _rival_x := 880.0
var _rope: Sprite2D
var _bar: PullBar
var _word: Label
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
	_heave = 0.0
	_rival_heave = 0.0
	_rival_pulls = false
	_h = 0.0
	_prev_h = 0.0
	_vel = 0.0
	_travel = 0.0
	_near_sum = 0.0
	_near_time = 0.0
	_over = false
	# Round 1: two beats of watching the hand, two of trying. Then just two to get ready.
	_t = -(4.0 if _round == 0 else 2.0) * BEAT
	_half = _half_at(_t)
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
		_show_hint("Watch!", "follow")
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
	_msg = UI.title("", 52)
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = 130
	_hud.add_child(_msg)
	_bar = PullBar.new()
	_hud.add_child(UI.full_rect(_bar))
	# PULL! / let go, flipping in time, just over the handle.
	_word = UI.title("", 40)
	_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_word.position = Vector2(440, 248)
	_word.size = Vector2(400, 50)
	_word.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_word)


# --- The thumb ---------------------------------------------------------------------------------
# Mouse events, which a phone also makes from the first finger. The drag is relative, so a thumb
# anywhere works; it does not have to land on the handle.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			press(event.position.x)
		else:
			release()
	elif event is InputEventMouseMotion and _held:
		drag(event.position.x)


func press(x: float) -> void:
	if _over:
		return
	_held = true
	_down_x = x
	_down_h = _h
	_idle = 0.0
	if _hint != null:
		_hint.dismiss()
		_hint = null
		# Still watching the hand? Straight on to trying it.
		if _t < -2.0 * BEAT:
			_t += ceilf((-2.0 * BEAT - _t) / BEAT) * BEAT


func drag(x: float) -> void:
	if not _held or _over:
		return
	_h = clampf(_down_h + (_down_x - x) / STROKE, 0.0, 1.0)
	# Pinned at an end: the next move the other way answers at once.
	if _h <= 0.0 or _h >= 1.0:
		_down_x = x
		_down_h = _h
	_idle = 0.0


## Safe to call twice: a lifted finger can arrive as a mouse release and a touch release.
func release() -> void:
	_held = false


## The guide at time `t`: 0 let out (right) to 1 pulled (left). Pulls during the first half of
## each beat, eases back during the second.
static func guide_at(t: float) -> float:
	var p := fposmod(t, BEAT) / BEAT
	if p < 0.5:
		var k := p / 0.5
		return 1.0 - (1.0 - k) * (1.0 - k)
	var e := (p - 0.5) / 0.5
	return 1.0 - e * e * (3.0 - 2.0 * e)


## How near a handle at `h` is to the guide at `t`, 0..1 - or to where it was a moment ago.
static func nearness(h: float, t: float) -> float:
	var off := 1.0
	for k in 4:
		off = minf(off, absf(h - guide_at(t - LAG * k / 3.0)))
	return 1.0 - clampf((off - NEAR) / NEAR_ZERO, 0.0, 1.0)


static func is_pull(t: float) -> bool:
	return fposmod(t, BEAT) < BEAT * 0.5


static func _half_at(t: float) -> int:
	return int(floor(t / (BEAT * 0.5)))


static func bar_x(h: float) -> float:
	return lerpf(BAR_RIGHT, BAR_LEFT, h)


## The guide ring's spot on the screen, for the hint's hand to ride.
func guide_point() -> Vector2:
	return Vector2(bar_x(guide_at(_t)), BAR_Y)


func _show_hint(text: String, gesture: String) -> void:
	if _hint != null:
		_hint.dismiss()
	_hint = HowTo.new()
	_hint.gesture = gesture
	_hint.follow = guide_point
	_hint.caption = text
	_hint.caption_y = 130.0
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
	var watching := _t < -2.0 * BEAT and _round == 0
	var live := _t >= 0.0
	_msg.modulate.a = maxf(0.0, _msg.modulate.a - delta * (0.0 if _t < 0.0 else 1.2))

	# The handle: the hand works it while the kid watches; otherwise the thumb, or it pays out.
	if watching:
		_h = guide_at(_t)
	elif not _held:
		_h = move_toward(_h, 0.0, delta * 2.5)
		_idle += delta
	var dh := _h - _prev_h
	_prev_h = _h
	_vel = lerpf(_vel, dh / maxf(delta, 0.001), minf(1.0, delta * 12.0))

	# A new half-beat: grade the pull just finished, roll the rival's, the drum, the countdown.
	var half := _half_at(_t)
	if half != _half:
		_half = half
		_new_half(watching)

	var near := nearness(_h, _t)
	var pulling := is_pull(_t)
	var target := 0.0
	if pulling:
		if dh > 0.0:
			_travel += dh
		_near_sum += near * delta
		_near_time += delta
		# Following the guide left, at its pace - but wiggling back and forth for extra counts none.
		var v := maxf(0.0, _vel) if _travel <= 1.05 else 0.0
		target = near * clampf(v / (0.7 / (0.5 * BEAT)), 0.0, 1.0)
	_heave = move_toward(_heave, target, delta * 8.0)
	_rival_heave = move_toward(_rival_heave, 1.0 if pulling and _rival_pulls else 0.0, delta * 8.0)
	_player.effort = _heave if not watching else (0.8 if pulling else 0.0)
	_rival.effort = _rival_heave

	# PULL! / let go, in time.
	_word.text = "PULL!" if pulling else "let go..."
	_word.add_theme_color_override("font_color", PULL_GREEN if pulling else LET_GO)
	_word.add_theme_font_size_override("font_size", 46 if pulling else 32)
	_bar.t = _t
	_bar.h = _h
	_bar.near = near

	if _t < 0.0:
		# The rope is still: keep the ribbon right in the middle, so it starts there.
		var mid := (_player.mouth_global().x + _rival.mouth_global().x) / 2.0
		_player_x += 640.0 - mid
		_rival_x += 640.0 - mid
		_place_pets()
		# The hand comes back if the thumb rests while it counts.
		if not watching and not _held and _idle > 2.0 * BEAT and _hint == null:
			_show_hint("Pull left, let go, again!", "follow")
		_place_rope()
		return

	_live_t += delta
	if _live_t > LINES_WAIT:
		var line := lerpf(LINE, LINE_MIN, clampf((_live_t - LINES_WAIT) / LINES_WAIT, 0.0, 1.0))
		if absf(line - _line) > 1.0:
			_line = line
			queue_redraw()
	if not _held and _idle > 2.0 * BEAT and _hint == null:
		_show_hint("Pull left, let go, again!", "follow")
	var r: Dictionary = screen.rivals[_round]
	var player_pull := 30.0 + Stats.value(screen.pet, "strength") * 0.8 + _heave * HEAVE_K
	var rival_pull := 30.0 + Stats.value(r["pet"], "strength") * 0.8 + _rival_heave * RIVAL_HEAVE_K \
		+ sin(_t * 1.3) * 3.0
	_m += (rival_pull - player_pull) * DRAG * delta
	_place_pets()
	# Won or lost when the ribbon itself reaches a line.
	var ribbon := (_player.mouth_global().x + _rival.mouth_global().x) / 2.0 - 640.0
	if live and ribbon <= -_line:
		_end_round(true)
	elif live and ribbon >= _line:
		_end_round(false)


func _new_half(watching: bool) -> void:
	var pull_starts := is_pull(_t)
	if not pull_starts:
		# A pull just ended: how was it?
		var grade := minf(_travel, 1.0) * (_near_sum / maxf(_near_time, 0.001))
		if not watching and (_t >= -2.0 * BEAT or _round > 0):
			if grade >= 0.7:
				_say("HEAVE!" if _t >= 0.0 else "Yes!", PULL_GREEN)
				_bar.flash = 1.0
				Sounds.play("heave")
				if _t >= 0.0:
					Voice.speak(screen.pet, "tug", _player)
			elif grade >= 0.35:
				_say("Pull!", PULL_GREEN.darkened(0.15))
				Sounds.play_varied("tug", 1.0, 0.1)
		_travel = 0.0
		_near_sum = 0.0
		_near_time = 0.0
		return
	Sounds.play("drum_beat")
	if _t >= 0.0:
		var r: Dictionary = screen.rivals[_round]
		_rival_pulls = _rng.randf() < 0.3 + Stats.value(r["pet"], "strength") / 200.0
	# The countdown, a beat at a time: watch, your turn, ready, GO - always on a pull.
	var beat := int(floor(_t / BEAT + 0.01))
	if beat == -2 and _round == 0:
		if _hint != null:
			_hint.dismiss()
			_hint = null
		_say("Your turn - try it!")
	elif beat == -1:
		_say("Ready...")
		Sounds.play("count_tick")
	elif beat == 0:
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
	_held = false
	_player.effort = 0.0
	_rival.effort = 0.0
	if _hint != null:
		_hint.dismiss()
		_hint = null
	_word.text = ""
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
	await get_tree().create_timer(1.8).timeout
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


## The rope's handle: a rope to slide along, the guide ring sliding in time, the kid's knot,
## and the two arrows - green PULL one way, soft let-go the other. The owner sets `t` (the
## rhythm's clock), `h` (the knot, 0 let out to 1 pulled), `near` and `flash` every frame; `y`,
## `pulled_x` and `loose_x` say where it lies (pulled to the left by default - flip them to pull
## right). Used by the cup (TugGame) and the rope tug at home (PlaceScreen).
class PullBar extends Control:
	var t := 0.0
	var h := 0.0
	var near := 0.0
	var flash := 0.0
	var y := TugGame.BAR_Y
	var pulled_x := TugGame.BAR_LEFT
	var loose_x := TugGame.BAR_RIGHT

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		flash = maxf(0.0, flash - delta * 2.5)
		queue_redraw()

	func x_of(k: float) -> float:
		return lerpf(loose_x, pulled_x, k)

	func _draw() -> void:
		var pulling := TugGame.is_pull(t)
		var way := signf(pulled_x - loose_x)
		var lo := minf(pulled_x, loose_x)
		var hi := maxf(pulled_x, loose_x)
		# A paper strip for the rope to lie on, so it reads over the grass.
		Crayon.fill(self, Crayon.rounded_rect(Rect2(lo - 130, y - 40, hi - lo + 260, 80), 30.0),
			Color(1, 0.99, 0.95, 0.85), 41, 9.0)
		Crayon.line(self, Vector2(lo - 30, y), Vector2(hi + 30, y), Color("#c9a26b"), 12.0, 42, 1.5)
		# The arrows: the one for now is big and bright.
		_arrow(Vector2(pulled_x + way * 82, y), way, TugGame.PULL_GREEN, pulling)
		_arrow(Vector2(loose_x - way * 82, y), -way, TugGame.LET_GO, not pulling)
		# The guide ring, sliding in time.
		var g := Vector2(x_of(TugGame.guide_at(t)), y)
		var gc := TugGame.PULL_GREEN if pulling else TugGame.LET_GO
		Crayon.marker_line(self, Crayon.ellipse(g, Vector2(34, 34), 24), gc, 7.0, 43)
		# The kid's knot: glowing green while it keeps up with the guide.
		var knot := Vector2(x_of(h), y)
		if near > 0.5:
			Crayon.marker_line(self, Crayon.ellipse(knot, Vector2(30, 30), 24),
				Color(TugGame.PULL_GREEN, near), 8.0, 44)
		Crayon.fill_blob(self, knot, Vector2(22, 22), UI.ACCENT, 45)
		Crayon.marker_line(self, Crayon.ellipse(knot, Vector2(22, 22), 20), UI.ACCENT.darkened(0.35), 4.0, 46)
		if flash > 0.0:
			Crayon.marker_line(self, Crayon.ellipse(knot, Vector2(46, 46), 28), Color(1, 0.85, 0.3, flash), 9.0, 47)

	func _arrow(at: Vector2, dir: float, col: Color, lit: bool) -> void:
		var k := 1.25 if lit else 0.8
		var c := col if lit else Color(col, 0.35)
		var pts := PackedVector2Array()
		for p in [Vector2(-34, -14), Vector2(4, -14), Vector2(4, -32), Vector2(40, 0), Vector2(4, 32),
				Vector2(4, 14), Vector2(-34, 14)]:
			pts.append(at + Vector2(p.x * dir, p.y) * k)
		Crayon.fill(self, pts, c, 48 + int(dir), 7.0)
		Crayon.marker_line(self, pts, c.darkened(0.3), 4.0, 50 + int(dir))
