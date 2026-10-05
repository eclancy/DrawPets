class_name WordPickerScreen
extends Control
## "What's it like?" - the kid taps a few describing words instead of typing a description.
## The words are what the game reads (.ai/pet-life.md): a "bouncy" toy bounces, a "cozy" bed
## gets napped on, a "sporty" pet trains speed faster.

var category := "toy"
var question := ""
var picture: Texture2D
var max_pick := 2
var picked: Array = []
var on_done := Callable()

var _buttons := {}
var _done: Button


func _ready() -> void:
	add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 28)
	add_child(UI.full_rect(UI.margin(row, 26)))

	if picture != null:
		var art := TextureRect.new()
		art.texture = picture
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(art)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_stretch_ratio = 1.6
	col.add_theme_constant_override("separation", 12)
	row.add_child(col)
	col.add_child(UI.title(question, 36))
	var hint := UI.label("Pick %s - they change how it plays!" % ("one" if max_pick == 1 else "up to %d" % max_pick), 22)
	hint.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(hint)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	for word in Words.table(category):
		var b := UI.button("%s\n%s" % [word, Words.hint(category, word)], toggle.bind(word), Vector2(0, 76), 20)
		b.toggle_mode = true
		b.button_pressed = picked.has(word)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_buttons[word] = b
		grid.add_child(b)
	col.add_child(grid)
	_done = UI.big_button("Done", press_done)
	col.add_child(_done)
	_refresh()


func toggle(word: String) -> void:
	if picked.has(word):
		picked.erase(word)
	else:
		picked.append(word)
		if picked.size() > max_pick:
			var dropped: String = picked.pop_front()
			_buttons[dropped].set_pressed_no_signal(false)
	_refresh()


func _refresh() -> void:
	for w in _buttons:
		_buttons[w].set_pressed_no_signal(picked.has(w))
	_done.disabled = picked.is_empty()


func press_done() -> void:
	if not picked.is_empty():
		on_done.call(picked.duplicate())
