class_name LetGoScreen
extends Control
## Letting a pet go to live in the wild - removing it for good (.ai/pet-life.md). It is gentle
## and it is final: the pet waves, says goodbye and wanders off happily, and its folder is
## deleted. Because it cannot be undone, the button has to be HELD for two seconds; a stray tap
## never sends a pet away. An adopted pet goes back to the shop, so it can be adopted again.

const HOLD := 2.0

var game: GameRoot
var pet: Dictionary
var home: Dictionary
var on_cancel := Callable()

var _creature: Creature
var _held := 0.0
var _holding := false
var _gone := false
var _bar: ProgressBar
var _buttons: Control
var _text: Label


func _ready() -> void:
	var stage := UI.place_button(home.get("place", "meadow"), "", Vector2(1280, 720))
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(UI.full_rect(stage))
	_creature = Creature.new()
	_creature.wander = false
	_creature.confine = false
	_creature.depth_scale = false
	_creature.bounds = Rect2(-400, 500, 2200, 200)
	_creature.position = Vector2(470, 600)
	add_child(_creature)
	_creature.setup(pet, 260.0)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.offset_right = -40
	panel.custom_minimum_size = Vector2(560, 0)
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	panel.add_child(col)
	var top := HBoxContainer.new()
	top.add_child(UI.icon("ui_let_go", 64))
	top.add_child(UI.title("Let %s go?" % pet["name"], 40))
	col.add_child(top)
	_text = UI.label("%s will go off to live in the wild, happy and free. You can't get %s back." % [
		pet["name"], pet["name"]], 22, true)
	col.add_child(_text)
	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 12)
	col.add_child(_buttons)
	var hold := UI.big_icon_button("ui_let_go", "Hold to say goodbye", func(): pass)
	hold.button_down.connect(func(): _holding = true)
	hold.button_up.connect(func(): _holding = false)
	_buttons.add_child(hold)
	_bar = ProgressBar.new()
	_bar.max_value = HOLD
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(0, 18)
	_buttons.add_child(_bar)
	_buttons.add_child(UI.icon_button("tool_back", "Keep %s" % pet["name"], func(): on_cancel.call(), 44,
		Vector2(0, 96)))


func _process(delta: float) -> void:
	if _gone:
		return
	if _holding:
		_held += delta
		if int(_held * 4.0) != int((_held - delta) * 4.0):
			Sounds.play("ui_tap", 1.0 + _held * 0.3)
	else:
		_held = maxf(0.0, _held - delta * 3.0)
	_bar.value = _held
	if _held >= HOLD:
		goodbye()


## Waves, says goodbye, and wanders off - then it is gone.
func goodbye() -> void:
	_gone = true
	_buttons.visible = false
	_text.text = "Bye bye, %s! Have fun out there!" % pet["name"]
	_creature.perform("greet", 1.6)
	_creature.say("heart")
	Sounds.play("goodbye")
	await get_tree().create_timer(1.8).timeout
	_creature.go_to(Vector2(1700, 610), Callable(), false)
	await get_tree().create_timer(3.2).timeout
	var p := game.profile
	for h in p.homes():
		h["pets"].erase(pet["id"])
	var from: String = pet.get("adopted_from", "")
	if from != "":
		p.adopted().erase(from)
	p.save()
	PetStore.delete_pet(pet["id"])
	game.toast("%s went off to live in the wild." % pet["name"], "ui_let_go")
	game.go_home()
