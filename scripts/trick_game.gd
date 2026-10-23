class_name TrickGame
extends Node2D
## Trick Show - SMARTS (.ai/competitions.md). Simon says, with trick cards: the pet shows a run
## of tricks one card at a time, then the kid taps the same cards back in the same order. Each
## round adds a card to the run; five rounds (the five rings at the top) is a perfect show.
##
## Players start at 7 and many barely read, so WATCH and YOUR TURN look nothing alike. Every
## show starts with 3, 2, 1 on a blank card, where the trick cards will come. While the pet
## shows, an eye says watch, the row of cards to tap goes pale and switched off, and each card
## flips in big at the top while the pet does the trick. A slot appears under it for every card
## shown - and the same card twice gets two slots, with a gap and a flip between, so a repeat
## reads as two. Then the slots turn face down and the row pops up bright with the GO sound:
## your turn. Each right tap turns the next slot back over with a tick, so the kid sees how many
## are left; a ring marks the slot to fill next.
##
## A drawn hand (HowTo) shows the move rather than telling it: the very first time, a two-card
## run that the hand then taps back; and in every show, round 1's turn, tapping that one card.
## After that the kid knows the move, so resting on a turn means the run slipped away: the pet
## shows it again ("Let's watch again!"), free - the heart stays. The help is always another
## look, never the answer, so remembering stays the game and a pet's smarts still count.
## A wrong card is not the end: its slot shows the card it was, that card lights up in the row
## while the others go pale, and once a show (the heart at the top) the pet does the run again.
## The second miss ends the show, with a bow.
##
## The stage is drawn wider than 1280 x 720 and the card sits in the middle of the screen, not
## at x 640, since most phones are wider than 16:9 and show more stage at the sides.
##
## The stat: smarts keeps each card up longer, a clever pet (smarts level 5+) lights up the
## card to tap next after every right one, and the score is rounds passed + smarts/200. The
## cards are the pet's own (Tricks): every trick it knows, on the card the kid drew for it,
## topped up with the game's cards to at least four.
##
## The show runs as steps that each start the next (count-in, show, your turn, oops, end), and a
## step only ever waits on the game's own timer (`_wait`) - never on another step or a tween. So
## a game left in the middle (Stop) just goes: nothing wakes up on a game that is gone, and
## nothing is left waiting forever (Godot leaks a step that waits on another when its node goes).

signal finished(scores: Array)

## The fewest cards a show is played with.
const DECK := 4
## Rounds in a show: the last run is this many cards long.
const ROUNDS := 5
## Seconds of rest on the kid's turn before the pet shows the run again. Longer than a beat
## game's two cycles: remembering a run takes a moment, and that is the game.
const REST := 5.0
## The empty beat between two cards, so the same card twice reads as two.
const GAP := 0.4
## How long the big card takes to turn round, in or away.
const TURN := 0.15
## The card the pet holds up (in the middle of the screen, this far down), the slots under it,
## and where the pet stands - high enough that the row of cards to tap does not hide its feet.
## The row sits up off the bottom edge, so the hint's hand (which reaches up from below) shows
## as it taps.
const CARD_Y := 180.0
const CARD_SIZE := Vector2(140, 160)
const SLOT_Y := 314.0
const SLOT_SIZE := Vector2(58, 66)
const SLOT_GAP := 14.0
const PET_Y := 548.0
const ROW_BOTTOM := 44.0
const CARD_EDGE := Color("#8f7cc4")
const CARD_BACK := Color("#b9a6e3")
const GLOW := Color(1.0, 0.78, 0.2)
const HEART := Color("#f2557a")
const YES := Color("#4f9d45")
## The row while the pet shows: pale and soft, plainly not for tapping yet.
const ROW_OFF := Color(0.92, 0.9, 0.97, 0.38)

var screen: CompetitionScreen

var _pet: Creature
var _round := 0
## Rounds done right: the score, with a little smarts.
var _passed := 0
var _sequence: Array = []
var _answer := 0
## intro (the how-to and the count-in), show, answer, between, oops, done.
var _state := "intro"
## One more go, once a show (the heart).
var _retries := 1
var _replaying := false
var _idle := 0.0
var _clock := 0.0
var _rng := RandomNumberGenerator.new()
## The rivals' scores have their own dice, so they do not shift with how far the kid got.
var _rival_rng := RandomNumberGenerator.new()
var _deck: Array = []
var _tex := {}
var _hud: Control
var _board: Control
var _top: HBoxContainer
var _eye: TextureRect
var _msg: Label
var _count: Label
var _row: HBoxContainer
var _buttons := {}
## Each card's own tween (a bounce, a fade), so two never fight over one card.
var _card_tw := {}
## Over the stage while it is not the kid's turn: takes the touches the row must not (see
## _on_stage_touch).
var _catcher: Control
var _hint: HowTo
var _hint_tricks: Array = []
var _hint_presses := 0
## The card up top: its picture (none for the blank one) and how far round it has turned.
var _card_tex: Texture2D
var _card_open := 0.0
var _card_turn: Tween
## A slot per card in the run: {trick, face: up / down / done / miss, was, flip, pop}.
var _slots: Array = []
var _glow := ""
var _glow_t := 0.0
var _heart_pop := 0.0
var _say_pop := 0.0
var _nudge := 0.0
var _demo := false
var _skip := false
var _waiting: Timer


func _ready() -> void:
	_rng.seed = Events.seed_of(screen.event, screen.tier) + 3
	_rival_rng.seed = Events.seed_of(screen.event, screen.tier) + 4
	_deck = Tricks.known(screen.pet)
	for t in ["spin", "jump", "sit", "wave", "roll", "bow", "dance"]:
		if _deck.size() >= DECK:
			break
		if not _deck.has(t):
			_deck.append(t)
	for t in _deck:
		_tex[t] = Tricks.card_texture(screen.pet, t)
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	_pet = CompetitionScreen.racer(screen.pet)
	_pet.driven = false
	_pet.wander = false
	_pet.position = Vector2(640, PET_Y)
	_pet.emote.connect(_on_emote)
	add_child(_pet)
	_build_hud()
	_dim_row(0.0)
	await _wait(0.5).timeout
	if screen.game != null and HowTo.first_times(screen.game.profile, "howto_tricks", 1):
		_how_demo()
	else:
		_count_in()


func _draw() -> void:
	# Well past 1280 x 720 all round: a wide phone shows more at the sides, a tablet more above
	# and below, and the stage must reach every edge.
	draw_rect(Rect2(-700, -400, 2680, 1520), Color("#e9e0f4"))
	draw_rect(Rect2(-700, 520, 2680, 600), Color("#e8cfa9"))
	for i in 24:
		Crayon.line(self, Vector2(-700, 540 + i * 18), Vector2(1980, 540 + i * 18), Color("#d9bc94"), 3.0, i, 2.0)
	var spot := Crayon.ellipse(Vector2(640, PET_Y + 10.0), Vector2(240, 46))
	draw_colored_polygon(spot, Color(1, 0.97, 0.75, 0.6))
	for side: float in [-1.0, 1.0]:
		var x0 := 640.0 + side * 1340.0
		var x1 := 640.0 + side * 470.0
		var curtain := PackedVector2Array([Vector2(x0, -400), Vector2(x1, -400), Vector2(x1 + side * 30.0, 300),
			Vector2(x1 - side * 20.0, 560), Vector2(x0, 560)])
		Crayon.pencil_fill(self, curtain, Color("#ef9aa8"), 31 + int(side))
	Crayon.pencil_fill(self, PackedVector2Array([Vector2(-700, -400), Vector2(1980, -400), Vector2(1980, 30),
		Vector2(-700, 30)]), Color("#ef9aa8"), 33)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Control.new()
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.full_rect(_hud))
	# Drawn under the rest: the rounds, the heart, the card up top and its slots.
	_board = Control.new()
	_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.draw.connect(_draw_board)
	_hud.add_child(UI.full_rect(_board))
	# One line at the top, with an eye beside it while it is time to watch.
	_top = HBoxContainer.new()
	_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top.alignment = BoxContainer.ALIGNMENT_CENTER
	_top.add_theme_constant_override("separation", 12)
	_top.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_top.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_top.offset_top = 28
	_eye = UI.icon("part_eye", 52)
	_top.add_child(_eye)
	_msg = UI.title("", 42)
	_msg.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_top.add_child(_msg)
	_hud.add_child(_top)
	# 3, 2, 1 on the blank card, where the trick cards will come.
	_count = UI.title("", 110)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_count.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_count.grow_vertical = Control.GROW_DIRECTION_BOTH
	_count.offset_left = -CARD_SIZE.x / 2.0
	_count.offset_right = CARD_SIZE.x / 2.0
	_count.offset_top = CARD_Y - CARD_SIZE.y / 2.0
	_count.offset_bottom = CARD_Y + CARD_SIZE.y / 2.0
	_hud.add_child(_count)
	_row = HBoxContainer.new()
	_row.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_row.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_row.offset_bottom = -ROW_BOTTOM
	_row.add_theme_constant_override("separation", 10)
	for t in _deck:
		var b := _card_button(t)
		b.disabled = true
		_buttons[t] = b
		_row.add_child(b)
	_hud.add_child(_row)
	# On top of the row, but only while the kid watches (see _process). The screen's Stop sits on
	# a layer above this one, so it still gets its own taps.
	_catcher = Control.new()
	_catcher.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_catcher.gui_input.connect(_on_stage_touch)
	_hud.add_child(UI.full_rect(_catcher))


## A card to tap: the kid's own drawing if the pet knows the trick, else the game's.
func _card_button(t: String) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(118, 112)
	b.pressed.connect(press.bind(t))
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	UI.full_rect(col)
	var pic := TextureRect.new()
	pic.texture = _tex[t]
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = Vector2(64, 64)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(pic)
	var l := UI.label(Tricks.display_name(t), 18)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(l)
	b.add_child(col)
	return b


# --- The show ----------------------------------------------------------------------------------

## The very first time: a two-card run, then the hand taps the same two cards back and their
## slots fill in. Any touch on the stage skips straight on to the real thing (_on_stage_touch).
func _how_demo() -> void:
	_demo = true
	var pair: Array = [_deck[0], _deck[1]]
	_say("Watch!", UI.INK, true)
	for t in pair:
		if _skip:
			break
		_card_up(t)
		await _wait(TURN + 0.9).timeout
		if _skip:
			break
		_turn_card(0.0)
		await _wait(TURN + GAP).timeout
	if not _skip:
		_slots_down()
		await _wait(0.4).timeout
	if not _skip:
		_pop_row(true)
		_show_hint(pair, "TAP the same cards!", _demo_press)
		await _wait(_hint.period * pair.size() + 0.3).timeout
	_hide_hint()
	if not _skip:
		Sounds.play("correct")
		_pet.say("star")
		_say("Like that!", YES)
		await _wait(1.2).timeout
	_demo = false
	_skip = false
	_count_in()


## Every show starts the same: a blank card up top with 3, 2, 1 on it - the cards come there.
func _count_in() -> void:
	_state = "intro"
	_slots.clear()
	_dim_row()
	_card_tex = null
	_say("Watch the card!", UI.INK, true)
	_turn_card(1.0)
	await _wait(TURN).timeout
	for n in [3, 2, 1]:
		_count.text = str(n)
		_pop(_count, 1.4)
		Sounds.play("count_tick")
		await _wait(0.6).timeout
	_count.text = ""
	_turn_card(0.0)
	await _wait(TURN).timeout
	_next_round()


func _next_round() -> void:
	_round += 1
	_sequence.append(_deck[_rng.randi_range(0, _deck.size() - 1)])
	_replaying = false
	_show_run()


## The pet shows the whole run, one card at a time; a slot appears for each. Then your turn.
func _show_run() -> void:
	_state = "show"
	_hide_hint()
	_slots.clear()
	_dim_row()
	_say("Watch!", UI.INK, true)
	var hold := 0.7 + Stats.value(screen.pet, "smarts") / 140.0
	for t in _sequence:
		_card_up(t)
		await _wait(TURN + hold).timeout
		# The card turns away, and a blank beat, before the next.
		_turn_card(0.0)
		await _wait(TURN + GAP).timeout
	_slots_down()
	await _wait(0.4).timeout
	_your_turn()


## A card flips in up top while the pet does its trick, and its slot comes in under it.
func _card_up(t: String) -> void:
	_card_tex = _tex[t]
	_slots.append({"trick": t, "face": "up", "was": "up", "flip": 0.0, "pop": 1.0})
	Sounds.play_varied("card_flip", 1.0, 0.05)
	_perform(t)
	_turn_card(1.0)


## The big card turns round to face us (1) or away (0), over TURN seconds.
func _turn_card(to: float) -> void:
	if _card_turn != null:
		_card_turn.kill()
	_card_turn = create_tween()
	_card_turn.tween_property(self, "_card_open", to, TURN)


## The run is over: the slots turn face down - now remember them.
func _slots_down() -> void:
	Sounds.play_varied("card_flip", 0.85, 0.05)
	for i in _slots.size():
		_flip_slot(i, "down")


## Your turn: the row pops up bright with the GO sound. In round 1 the hand taps the card, so
## every show starts by showing what to do.
func _your_turn() -> void:
	_state = "answer"
	_answer = 0
	_idle = 0.0
	_catch_stage()
	_pop_row(true)
	Sounds.play("count_go")
	_say("Your turn - tap!", UI.INK)
	if _round == 1 and not _replaying:
		_show_hint(_sequence.duplicate(), "Tap the same card!", _hint_press)
	_clever_hint()


func press(trick: String) -> void:
	if _state == "oops" and trick == _glow:
		# The lit card answers a tap while it shows - the pet does it - but nothing is counted.
		_perform(trick)
		_bounce(trick, Color(1.2, 1.12, 0.75))
		return
	if _state != "answer":
		return
	_hide_hint()
	_idle = 0.0
	var want: String = _sequence[_answer]
	if trick != want:
		_miss(want)
		return
	_perform(trick)
	_bounce(trick, Color(0.85, 1.25, 0.85))
	_flip_slot(_answer, "done")
	_answer += 1
	if _answer < _sequence.size():
		Sounds.play_varied("good", 1.0, 0.04)
		_clever_hint()
		return
	# The whole run, right.
	_state = "between"
	_passed = _round
	_set_buttons(false)
	_pet.say("star")
	Sounds.play("correct")
	if _round >= ROUNDS:
		_say("A perfect show!", YES)
		Sounds.play("cheer")
		_finish()
		return
	_say("Yes!", YES)
	await _wait(1.3).timeout
	_next_round()


## A wrong card: the slot shows the card it was, and that card lights up in the row while the
## others go pale. Once a show the pet does the run again; the second time, the show is over -
## with a bow, not a buzzer.
func _miss(want: String) -> void:
	_state = "oops"
	# Only the lit card stays bright - and answers a tap (see press), if there is another go.
	# The rest go pale and off, so nothing looks tappable that does nothing.
	for t in _buttons:
		var b: Button = _buttons[t]
		b.disabled = _retries == 0 or t != want
		if t != want:
			_fade_card(t, ROW_OFF)
	Sounds.play("ui_nope")
	_pet.perform("look", 1.4)
	_flip_slot(_answer, "miss")
	_glow_button(want, 2.0)
	_say("It was this one!", UI.INK)
	await _wait(2.0).timeout
	if _retries > 0:
		_retries -= 1
		_heart_pop = 1.0
		_say("Let's watch again!", UI.INK)
		await _wait(1.2).timeout
		_replaying = true
		_show_run()
		return
	_say("What a show!", YES)
	_pet.do_trick("bow")
	_finish()


## Resting on your turn. Round 1's hand has shown the move, so a rest means the run slipped
## away: the pet shows it again, free - the heart stays. Another look, never the answer:
## remembering is the game, and the hand tapping the rest would win a cup for just waiting.
func _watch_again() -> void:
	_state = "between"
	_dim_row()
	_say("Let's watch again!", UI.INK, true)
	await _wait(1.0).timeout
	_replaying = true
	_show_run()


# --- The hand ----------------------------------------------------------------------------------

## The hand taps `tricks`' cards in the row, in order, with one line saying it. Our own line
## hides while it is up: one sentence on screen at a time.
func _show_hint(tricks: Array, caption: String, on_press: Callable) -> void:
	_hide_hint()
	_hint = HowTo.new()
	_hint.gesture = "taps"
	for t in tricks:
		_hint.targets.append(_card_point.bind(t))
	_hint.caption = caption
	_hint.caption_y = 26.0
	_hint.on_press = on_press
	_hint_tricks = tricks
	_hint_presses = 0
	_hud.add_child(_hint)
	_top.visible = false


## The hand goes at once rather than fading: a fading hand still presses (the pet would do a
## trick nobody tapped), and its line would sit over ours.
func _hide_hint() -> void:
	if _hint != null:
		_hint.on_press = Callable()
		UI.retire(_hint)
		_hint = null
	_top.visible = true


## Where the hand pokes a card in the row: high on its picture, so the hand shows below it.
func _card_point(t: String) -> Vector2:
	var b: Button = _buttons[t]
	return b.get_global_transform() * Vector2(b.size.x * 0.5, b.size.y * 0.3)


## The hand pressed a card: it squashes, as it would under a finger.
func _hint_press() -> void:
	var t: String = _hint_tricks[_hint_presses % _hint_tricks.size()]
	_hint_presses += 1
	_bounce(t, Color(1.15, 1.1, 0.85))


## In the first-time show the hand's presses play out for real: the pet does the trick and its
## slot turns back over with a tick.
func _demo_press() -> void:
	var i := _hint_presses % _hint_tricks.size()
	var t: String = _hint_tricks[i]
	_hint_presses += 1
	_bounce(t, Color(0.85, 1.25, 0.85))
	_perform(t)
	_flip_slot(i, "done")
	Sounds.play_varied("good", 1.0, 0.04)


## A clever pet nudges you towards the card to tap next.
func _clever_hint() -> void:
	if Stats.level(Stats.value(screen.pet, "smarts")) < 5 or _answer >= _sequence.size():
		return
	_glow_button(_sequence[_answer], 0.7, false)


# --- Little helpers ------------------------------------------------------------------------------

func _say(text: String, color := UI.INK, eye := false) -> void:
	_msg.text = text
	_msg.add_theme_color_override("font_color", color)
	_eye.visible = eye
	_say_pop = 1.0


func _set_buttons(on: bool) -> void:
	for t in _buttons:
		_buttons[t].disabled = not on


## Watching: the row goes pale and switched off - all of it, as one (any card faded on its own
## after a miss comes back first).
func _dim_row(seconds := 0.25) -> void:
	_set_buttons(false)
	for t in _buttons:
		_stop_card(t)
		var b: Button = _buttons[t]
		b.modulate = Color.WHITE
		b.scale = Vector2.ONE
	if seconds <= 0.0:
		_row.modulate = ROW_OFF
		return
	var tw := _row.create_tween()
	tw.tween_property(_row, "modulate", ROW_OFF, seconds)


## Your turn: the row pops up bright.
func _pop_row(on: bool) -> void:
	_set_buttons(on)
	_row.modulate = Color.WHITE
	_pop(_row, 0.82)


## Springs a control from `k` times its size back to its own.
func _pop(c: Control, k: float) -> void:
	c.pivot_offset = c.size / 2.0
	c.scale = Vector2(k, k)
	var tw := c.create_tween()
	tw.tween_property(c, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## A new tween for card `t`, stopping the one it had - so a bounce never brings back a card
## that has just gone pale.
func _card_tween(t: String) -> Tween:
	_stop_card(t)
	var b: Button = _buttons[t]
	var tw := b.create_tween()
	_card_tw[t] = tw
	return tw


func _stop_card(t: String) -> void:
	var old: Tween = _card_tw.get(t)
	if old != null and old.is_valid():
		old.kill()
	_card_tw.erase(t)


func _bounce(t: String, tint: Color) -> void:
	if not _buttons.has(t):
		return
	var b: Button = _buttons[t]
	b.pivot_offset = b.size / 2.0
	var tw := _card_tween(t)
	tw.tween_property(b, "scale", Vector2(1.14, 1.14), 0.08)
	tw.parallel().tween_property(b, "modulate", tint, 0.08)
	tw.tween_property(b, "scale", Vector2.ONE, 0.2)
	tw.parallel().tween_property(b, "modulate", Color.WHITE, 0.3)


## A card in the row fades to `tint` (and back to its own size, if it was bouncing).
func _fade_card(t: String, tint: Color) -> void:
	var b: Button = _buttons[t]
	var tw := _card_tween(t)
	tw.tween_property(b, "modulate", tint, 0.25)
	tw.parallel().tween_property(b, "scale", Vector2.ONE, 0.15)


## A card in the row lights up with a ring for a while (and bounces, unless `bounce` is off).
func _glow_button(t: String, seconds: float, bounce := true) -> void:
	_glow = t
	_glow_t = seconds
	if bounce:
		_bounce(t, Color(1.2, 1.12, 0.75))


func _flip_slot(i: int, face: String) -> void:
	if i < 0 or i >= _slots.size():
		return
	var s: Dictionary = _slots[i]
	s["was"] = s["face"]
	s["face"] = face
	s["flip"] = 1.0


## A timer of the game's own for a step to wait on (`await _wait(s).timeout`), so a game left in
## the middle takes its waits with it - a tree timer would wake a game that is gone - and Stop's
## pause holds them too. A touch can cut the first-time show's wait short (_on_stage_touch).
func _wait(seconds: float) -> Timer:
	var t := Timer.new()
	t.one_shot = true
	t.timeout.connect(t.queue_free)
	add_child(t)
	t.start(seconds)
	_waiting = t
	return t


## The stage takes touches only while the kid watches - the count-in, the pet's show and the
## first-time show - and the row underneath gets them the rest of the time. Set straight away
## when it becomes the kid's turn, so not even one frame's tap is lost.
func _catch_stage() -> void:
	var watching := _state == "show" or _state == "intro"
	_catcher.mouse_filter = Control.MOUSE_FILTER_STOP if watching else Control.MOUSE_FILTER_IGNORE


## A touch on the stage while the first-time show plays skips it. A touch while the cards count
## in or the pet shows makes the eye and the card nod: watch first. (Only the stage: the
## screen's Stop button is not a touch on the stage, so it never skips the first-time show.)
func _on_stage_touch(event: InputEvent) -> void:
	var touch := event as InputEventMouseButton
	if touch == null or not touch.pressed or touch.button_index != MOUSE_BUTTON_LEFT:
		return
	if _demo and not _skip:
		_skip = true
		# Wakes the step that is waiting now, which sees _skip and goes on to the count-in.
		if is_instance_valid(_waiting) and not _waiting.is_stopped():
			_waiting.stop()
			_waiting.timeout.emit()
	elif _state == "show" or _state == "intro":
		_nudge = 1.0


func _on_emote(kind: String, at: Vector2) -> void:
	var e := Emote.new()
	e.kind = kind
	e.position = at
	add_child(e)


## The pet acts out a trick with the motions every creature has.
func _perform(trick: String) -> void:
	_pet.do_trick(trick)


func _finish() -> void:
	_state = "done"
	_hide_hint()
	_set_buttons(false)
	var scores := [{"who": "player", "score": _passed + Stats.value(screen.pet, "smarts") / 200.0}]
	for i in screen.rivals.size():
		var smarts := Stats.value(screen.rivals[i]["pet"], "smarts")
		scores.append({"who": i, "score": clampf(0.5 + smarts / 20.0 + _rival_rng.randf_range(-0.6, 0.9), 0.0, 5.2)})
	await _wait(1.8).timeout
	finished.emit(scores)


# --- Each frame ----------------------------------------------------------------------------------

func _process(delta: float) -> void:
	_clock += delta
	for s in _slots:
		s["flip"] = maxf(0.0, float(s["flip"]) - delta * 5.0)
		s["pop"] = maxf(0.0, float(s["pop"]) - delta * 4.0)
	_glow_t = maxf(0.0, _glow_t - delta)
	_heart_pop = maxf(0.0, _heart_pop - delta * 1.2)
	_nudge = maxf(0.0, _nudge - delta * 3.0)
	_say_pop = maxf(0.0, _say_pop - delta * 4.0)
	_top.pivot_offset = _top.size / 2.0
	_top.scale = Vector2.ONE * (1.0 + 0.15 * _say_pop * _say_pop + 0.18 * sin(_nudge * PI))
	_catch_stage()
	# Resting on your turn (and round 1's hand is not up): the pet shows the run again.
	if _state == "answer":
		_idle += delta
		if _idle > REST and _hint == null:
			_watch_again()
	_board.queue_redraw()


func _draw_board() -> void:
	var c := _board
	# The rounds along the top: a gold star for each one done, a ring for each to come.
	for i in ROUNDS:
		var p := Vector2(190.0 + UI.safe_insets.x + i * 38.0, 62.0)
		if i < _passed:
			var star := Crayon.star(p, 17.0, i)
			Crayon.fill(c, star, Color("#ffd23f"), 60 + i, 4.0, 2.0, 3.0)
			Crayon.marker_line(c, star, Color("#d99a1c"), 3.0, 65 + i)
		else:
			var now := i == _round - 1 and _state != "done"
			Crayon.marker_line(c, Crayon.ellipse(p, Vector2(12, 12), 20),
				Color(UI.INK_SOFT, 0.9 if now else 0.35), 4.0 if now else 3.0, 70 + i)
	# The heart: one more go, once a show. Used, it floats up and fades. In the top right corner,
	# however wide the screen.
	var hp := Vector2(c.size.x - 192.0 - UI.safe_insets.z, 62.0)
	if _retries > 0:
		Crayon.fill(c, Crayon.heart(hp, 40.0), HEART, 80, 5.0, 2.0, 3.0)
		Crayon.marker_line(c, Crayon.heart(hp, 40.0), HEART.darkened(0.3), 3.0, 81)
	else:
		Crayon.marker_line(c, Crayon.heart(hp, 40.0), Color(UI.INK_SOFT, 0.3), 3.0, 82)
		if _heart_pop > 0.0:
			var gone := 1.0 - _heart_pop
			Crayon.fill(c, Crayon.heart(hp + Vector2(0, -40.0 * gone), 40.0 * (1.0 + 0.6 * gone)),
				Color(HEART, _heart_pop), 83, 5.0, 2.0, 3.0)
	# The card up top, thin then full as it turns round.
	if _card_open > 0.02:
		var nod := 1.0 + 0.08 * sin(_nudge * PI)
		c.draw_set_transform(Vector2(c.size.x * 0.5, CARD_Y), 0.0, Vector2(_card_open * nod, nod))
		_card_face(c, Rect2(-CARD_SIZE / 2.0, CARD_SIZE), _card_tex, 90, 6.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# The slots: one per card in the run, turning over as they flip.
	var n := _slots.size()
	for i in n:
		var s: Dictionary = _slots[i]
		var at := _slot_at(i, n)
		var flip: float = s["flip"]
		var face: String = s["was"] if flip > 0.5 else s["face"]
		var k := 1.0 + 0.3 * float(s["pop"])
		c.draw_set_transform(at, 0.0, Vector2(absf(1.0 - 2.0 * flip) * k, k))
		var r := Rect2(-SLOT_SIZE / 2.0, SLOT_SIZE)
		if face == "down":
			_card_back(c, r, 100 + i)
		else:
			var trick: String = s["trick"]
			_card_face(c, r, _tex[trick], 100 + i, 4.0)
		if face == "done":
			_tick(c, r.end - Vector2(7, 7), 110 + i)
		elif face == "miss":
			Crayon.marker_line(c, Crayon.rounded_rect(r.grow(7.0), 14.0),
				Color(GLOW, 0.6 + 0.4 * sin(_clock * 9.0)), 7.0, 120 + i)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# The one to fill next, on your turn.
		if _state == "answer" and i == _answer:
			Crayon.marker_line(c, Crayon.rounded_rect(Rect2(at - SLOT_SIZE / 2.0, SLOT_SIZE).grow(7.0), 14.0),
				Color(UI.ACCENT, 0.75 + 0.25 * sin(_clock * 6.0)), 6.0, 130 + i)
	# A card in the row lit up: the one it should have been, or a clever pet's nudge.
	if _glow_t > 0.0 and _buttons.has(_glow):
		var b: Button = _buttons[_glow]
		var a := minf(1.0, _glow_t / 0.3) * (0.65 + 0.35 * sin(_clock * 9.0))
		Crayon.marker_line(c, Crayon.rounded_rect(b.get_global_rect().grow(9.0), 24.0), Color(GLOW, a), 9.0, 140)


## Slot `i` of `n`, in a row under the card, in the middle of the screen.
func _slot_at(i: int, n: int) -> Vector2:
	return Vector2(_board.size.x * 0.5 + (i - (n - 1) / 2.0) * (SLOT_SIZE.x + SLOT_GAP), SLOT_Y)


## A paper card with a trick's picture on it (a blank one for the count-in).
func _card_face(c: CanvasItem, r: Rect2, tex: Texture2D, seed: int, edge: float) -> void:
	var shape := Crayon.rounded_rect(r, r.size.x * 0.14)
	Crayon.fill(c, shape, UI.CARD, seed, 7.0, 0.0, 5.0)
	Crayon.fill(c, shape, UI.CARD, seed + 1, 9.0, 0.0, 5.0)
	if tex != null:
		c.draw_texture_rect(tex, _fit(tex, r.grow(-r.size.x * 0.1)), false)
	Crayon.marker_line(c, shape, CARD_EDGE, edge, seed + 2)


## A card face down: lilac with a pale star.
func _card_back(c: CanvasItem, r: Rect2, seed: int) -> void:
	var shape := Crayon.rounded_rect(r, r.size.x * 0.14)
	Crayon.fill(c, shape, CARD_BACK, seed, 6.0, 0.0, 4.0)
	Crayon.fill(c, Crayon.star(r.get_center(), r.size.x * 0.26, seed), Color("#f4eeff"), seed + 3, 4.0, 1.0, 2.5)
	Crayon.marker_line(c, shape, CARD_EDGE.darkened(0.15), 4.0, seed + 4)


## A green tick in a card's corner: tapped back right.
func _tick(c: CanvasItem, p: Vector2, seed: int) -> void:
	Crayon.fill_blob(c, p, Vector2(14, 14), UI.GOOD, seed)
	Crayon.marker_line(c, PackedVector2Array([p + Vector2(-7, 0), p + Vector2(-2, 6), p + Vector2(8, -6)]),
		UI.CARD, 4.0, seed, false)


## `tex` as big as fits in `box`, keeping its shape.
static func _fit(tex: Texture2D, box: Rect2) -> Rect2:
	var s := tex.get_size()
	var k := minf(box.size.x / s.x, box.size.y / s.y)
	return Rect2(box.get_center() - s * k / 2.0, s * k)
