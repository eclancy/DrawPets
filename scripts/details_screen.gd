class_name DetailsScreen
extends Control
## Name, size and favourite place. The preview stands the creature next to a stick-figure kid
## so "Giant" visibly means taller than you, and the size changes live as it is picked.

const NAMES := ["Blorp", "Squish", "Nubbin", "Pickle", "Zorp", "Mochi", "Gloop", "Fizz",
	"Wobbles", "Noodle", "Bean", "Sprocket"]

var pet: Dictionary
## For which places are still locked - a locked place can be a favourite (a dream), it just
## cannot be lived in until it is bought.
var profile: Profile
var on_done := Callable()
## "Back to drawing", when set: the pet's sheet again, to add or fix a part.
var on_back := Callable()

var _name: LineEdit
var _place_words: Label
var _preview: Preview
var _size_buttons := {}
var _place_buttons := {}


func _ready() -> void:
	add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	add_child(UI.full_rect(UI.margin(row, 20)))

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.7
	left.add_theme_constant_override("separation", 10)
	row.add_child(left)

	left.add_child(UI.label("What's its name?", 26))
	_name = LineEdit.new()
	_name.placeholder_text = "Name me!"
	_name.max_length = 18
	_name.text = pet.get("name", "")
	_name.custom_minimum_size = Vector2(0, 66)
	_name.text_changed.connect(_named)
	left.add_child(_name)

	left.add_child(UI.label("How big is it?", 26))
	var sizes := HBoxContainer.new()
	var size_group := ButtonGroup.new()
	for id in Creature.SIZE_ORDER:
		var words: Array = Creature.SIZE_LABELS[id]
		var b := UI.icon_button("size_" + id, words[0], pick_size.bind(id), 44, Vector2(0, 84))
		b.toggle_mode = true
		b.button_group = size_group
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_size_buttons[id] = b
		sizes.add_child(b)
	left.add_child(sizes)

	left.add_child(UI.label("Where does it love to live?", 26))
	var places := GridContainer.new()
	places.columns = 5
	places.size_flags_vertical = Control.SIZE_EXPAND_FILL
	places.add_theme_constant_override("h_separation", 8)
	places.add_theme_constant_override("v_separation", 8)
	var place_group := ButtonGroup.new()
	for id in Places.ORDER:
		places.add_child(_place_button(id, place_group))
	left.add_child(places)
	_place_words = UI.label("", 19)
	_place_words.add_theme_color_override("font_color", UI.INK_SOFT)
	left.add_child(_place_words)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(right)
	_preview = Preview.new()
	_preview.pet = pet
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_preview)
	if on_back.is_valid():
		right.add_child(UI.icon_button("tool_back", "Back to drawing", _back, 32, Vector2(0, 64)))
	right.add_child(UI.big_button("Next", press_next))

	pick_size(pet.get("size", "medium"))
	set_place(pet.get("place", "meadow"))


func _place_button(id: String, group: ButtonGroup) -> Button:
	var locked := profile != null and not profile.place_unlocked(id)
	var b := UI.place_button(id, Places.display_name(id), Vector2(120, 80), locked)
	b.toggle_mode = true
	b.button_group = group
	b.size_flags_vertical = Control.SIZE_EXPAND_FILL
	b.pressed.connect(set_place.bind(id))
	_place_buttons[id] = b
	return b


func pick_size(id: String) -> void:
	pet["size"] = id
	_size_buttons[id].button_pressed = true
	_preview.refresh()


func set_place(id: String) -> void:
	pet["place"] = id
	_place_buttons[id].button_pressed = true
	var words := ", ".join(Places.tags(id))
	if profile != null and not profile.place_unlocked(id):
		_place_words.text = "%s: %s. A dream place - buy it in the shop so it can live there!" % [
			Places.display_name(id), words]
	else:
		_place_words.text = "%s: %s. It loves places like this." % [Places.display_name(id), words]


func set_pet_name(text: String) -> void:
	_name.text = text


## The name as it is typed, kept on the pet - so a pet saved for later from here keeps it too.
func _named(text: String) -> void:
	pet["name"] = text.strip_edges()


## Back to the drawing, keeping the name typed so far.
func _back() -> void:
	if _name.text.strip_edges() != "":
		pet["name"] = _name.text.strip_edges()
	on_back.call()


func press_next() -> void:
	var n := _name.text.strip_edges()
	if n == "":
		n = NAMES[randi() % NAMES.size()]
		_name.text = n
	pet["name"] = n
	on_done.call()


## The creature next to a stick-figure kid, standing on a line.
class Preview extends Control:
	const KID_HEIGHT := 300.0
	var pet: Dictionary
	var _creature: Creature

	func _ready() -> void:
		clip_contents = true
		_creature = Creature.new()
		_creature.wander = false
		_creature.confine = false
		_creature.depth_scale = false
		add_child(_creature)
		_creature.setup(pet, 120.0)
		resized.connect(_layout)
		_layout()

	func refresh() -> void:
		if _creature == null:
			return
		var f: float = Creature.SIZES.get(pet.get("size", "medium"), 1.0)
		_creature.set_display_height(120.0 * f)
		queue_redraw()

	func _layout() -> void:
		_creature.position = Vector2(size.x * 0.62, size.y - 30.0)
		queue_redraw()

	func _draw() -> void:
		var ground := size.y - 30.0
		draw_line(Vector2(10, ground), Vector2(size.x - 10, ground), UI.INK_SOFT, 3.0, true)
		# A stick-figure kid, for scale. Drawn in soft indigo - black belongs to the drawings.
		var x := size.x * 0.16
		var h := KID_HEIGHT
		var c := UI.INK_SOFT
		var head := Vector2(x, ground - h + 26.0)
		draw_arc(head, 26.0, 0, TAU, 32, c, 4.0, true)
		var hip := Vector2(x, ground - h * 0.42)
		draw_line(head + Vector2(0, 26), hip, c, 4.0, true)
		draw_line(hip, Vector2(x - 26, ground), c, 4.0, true)
		draw_line(hip, Vector2(x + 26, ground), c, 4.0, true)
		var shoulder := Vector2(x, ground - h * 0.72)
		draw_line(shoulder, shoulder + Vector2(-34, 60), c, 4.0, true)
		draw_line(shoulder, shoulder + Vector2(34, 60), c, 4.0, true)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(x - 20, ground + 26), "You", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, c)
