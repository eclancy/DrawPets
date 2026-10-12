class_name TrickGame
extends Node2D
## Trick Show - SMARTS (.ai/competitions.md). The pet performs a run of tricks, one card at a
## time; the kid taps the cards back in the same order. Each round adds a trick. Smarts makes
## the cards stay up longer, and a clever pet (smarts level 5+) hints the first card of each
## answer. Five rounds is a perfect show.
##
## The cards are the pet's own (Tricks): every trick it knows, on the card the kid drew for it,
## topped up with the game's cards to at least four.

signal finished(scores: Array)

## The fewest cards a show is played with.
const DECK := 4

var screen: CompetitionScreen

var _pet: Creature
var _round := 0
var _sequence: Array = []
var _answer := 0
var _state := "intro"
var _card: TextureRect
var _msg: Label
var _buttons := {}
var _rng := RandomNumberGenerator.new()
var _deck: Array = []


func _ready() -> void:
	_rng.seed = Events.seed_of(screen.event, screen.tier) + 3
	_deck = Tricks.known(screen.pet)
	for t in ["spin", "jump", "sit", "wave", "roll", "bow", "dance"]:
		if _deck.size() >= DECK:
			break
		if not _deck.has(t):
			_deck.append(t)
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	_pet = CompetitionScreen.racer(screen.pet)
	_pet.driven = false
	_pet.wander = false
	_pet.position = Vector2(640, 600)
	add_child(_pet)
	_build_hud()
	await get_tree().create_timer(1.0).timeout
	_next_round()


func _draw() -> void:
	draw_rect(Rect2(-100, -100, 1480, 920), Color("#e9e0f4"))
	draw_rect(Rect2(-100, 520, 1480, 300), Color("#e8cfa9"))
	for i in 16:
		Crayon.line(self, Vector2(-100, 540 + i * 18), Vector2(1380, 540 + i * 18), Color("#d9bc94"), 3.0, i, 2.0)
	var spot := Crayon.ellipse(Vector2(640, 610), Vector2(240, 46))
	draw_colored_polygon(spot, Color(1, 0.97, 0.75, 0.6))
	for side: float in [-1.0, 1.0]:
		var x0 := 640.0 + side * 640.0
		var x1 := 640.0 + side * 470.0
		var curtain := PackedVector2Array([Vector2(x0, -100), Vector2(x1, -100), Vector2(x1 + side * 30.0, 300),
			Vector2(x1 - side * 20.0, 560), Vector2(x0, 560)])
		Crayon.pencil_fill(self, curtain, Color("#ef9aa8"), 31 + int(side))
	Crayon.pencil_fill(self, PackedVector2Array([Vector2(-100, -100), Vector2(1380, -100), Vector2(1380, 30),
		Vector2(-100, 30)]), Color("#ef9aa8"), 33)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.full_rect(root))
	_msg = UI.title("Watch closely!", 38)
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = 40
	root.add_child(_msg)
	_card = TextureRect.new()
	_card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_card.offset_left = -90
	_card.offset_right = 90
	_card.offset_top = 100
	_card.offset_bottom = 280
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_card)
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	row.grow_horizontal = Control.GROW_DIRECTION_BOTH
	row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	row.offset_bottom = -16
	row.add_theme_constant_override("separation", 10)
	for t in _deck:
		var b := _card_button(t)
		b.disabled = true
		_buttons[t] = b
		row.add_child(b)
	root.add_child(row)


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
	pic.texture = Tricks.card_texture(screen.pet, t)
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


func _next_round() -> void:
	_round += 1
	_sequence.append(_deck[_rng.randi_range(0, _deck.size() - 1)])
	_state = "show"
	_msg.text = "Round %d - watch!" % _round
	_set_buttons(false)
	var hold := 0.7 + Stats.value(screen.pet, "smarts") / 140.0
	for t in _sequence:
		_card.texture = Tricks.card_texture(screen.pet, t)
		Sounds.play_varied("card_flip", 1.0, 0.05)
		_perform(t)
		await get_tree().create_timer(hold).timeout
		_card.texture = null
		await get_tree().create_timer(0.25).timeout
	_state = "answer"
	_answer = 0
	_msg.text = "Your turn! Tap them in order."
	_set_buttons(true)
	_hint()


## A clever pet nudges you towards the next card.
func _hint() -> void:
	if Stats.level(Stats.value(screen.pet, "smarts")) < 5 or _answer >= _sequence.size():
		return
	var b: Button = _buttons[_sequence[_answer]]
	var tween := b.create_tween()
	tween.tween_property(b, "modulate", Color(1.2, 1.1, 0.7), 0.25)
	tween.tween_property(b, "modulate", Color.WHITE, 0.25)


func _set_buttons(on: bool) -> void:
	for t in _buttons:
		_buttons[t].disabled = not on


func press(trick: String) -> void:
	if _state != "answer":
		return
	_perform(trick)
	if trick != _sequence[_answer]:
		_state = "done"
		_set_buttons(false)
		_msg.text = "Oops! That was %s." % Tricks.display_name(_sequence[_answer])
		Sounds.play("wrong")
		_finish()
		return
	_answer += 1
	if _answer >= _sequence.size():
		_state = "between"
		_set_buttons(false)
		_pet.say("star")
		Sounds.play("correct")
		if _round >= 5:
			_msg.text = "A perfect show!"
			Sounds.play("cheer")
			_finish()
		else:
			_msg.text = "Yes! Next round..."
			await get_tree().create_timer(1.2).timeout
			_next_round()
	else:
		_hint()


## The pet acts out a trick with the motions every creature has.
func _perform(trick: String) -> void:
	_pet.do_trick(trick)


func _finish() -> void:
	var passed := _round - 1 if _state == "done" else _round
	var scores := [{"who": "player", "score": passed + Stats.value(screen.pet, "smarts") / 200.0}]
	for i in screen.rivals.size():
		var smarts := Stats.value(screen.rivals[i]["pet"], "smarts")
		scores.append({"who": i, "score": clampf(0.5 + smarts / 20.0 + _rng.randf_range(-0.6, 0.9), 0.0, 5.2)})
	await get_tree().create_timer(1.5).timeout
	finished.emit(scores)
