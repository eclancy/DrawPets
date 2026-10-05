class_name PartPickerScreen
extends Control
## "How many heads, arms and legs?" - the only parts asked about up front. Everything else is
## added while drawing the part it goes on: horns and eyes while drawing a head, a hand while
## drawing an arm, wings and a tail while drawing the body. Any number goes - no legs (it
## hops), eight legs, three heads.

const ASK := ["head", "arm", "leg"]
const START := {"head": 1, "arm": 0, "leg": 4}

var counts := START.duplicate()
var on_done := Callable()
var on_cancel := Callable()

var _labels := {}


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	add_child(UI.full_rect(UI.margin(col, 24)))

	var top := HBoxContainer.new()
	top.add_child(UI.icon_button("tool_back", "Back", on_cancel, 40, Vector2(100, 84)))
	var heading := UI.title("How many heads, arms and legs?", 40)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(heading)
	col.add_child(top)
	var hint := UI.label("You'll add eyes, horns, wings, hands and more while you draw each part.", 22)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(hint)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	for type in ASK:
		row.add_child(_card(type))
	col.add_child(row)
	col.add_child(UI.big_icon_button("tool_crayon", "Next: draw the body!", press_next))


func _card(type: String) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(320, 0)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 10)
	card.add_child(col)
	var pic := UI.icon(PartTypes.icon(type), 170)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(pic)
	var name := UI.label(PartTypes.info(type)["plural"], 32)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(name)
	var stepper := HBoxContainer.new()
	stepper.alignment = BoxContainer.ALIGNMENT_CENTER
	stepper.add_theme_constant_override("separation", 12)
	stepper.add_child(_step_button("ui_minus", type, -1))
	var count := UI.label(str(counts.get(type, 0)), 48)
	count.custom_minimum_size = Vector2(70, 0)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_labels[type] = count
	stepper.add_child(count)
	stepper.add_child(_step_button("ui_plus", type, 1))
	col.add_child(stepper)
	return card


func _step_button(icon: String, type: String, by: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(76, 76)
	b.pressed.connect(func(): change(type, by))
	var pic := UI.icon(icon, 56)
	pic.position = Vector2(10, 10)
	b.add_child(pic)
	return b


func change(type: String, by: int) -> void:
	var n := clampi(int(counts.get(type, 0)) + by, 0, int(PartTypes.info(type)["max"]))
	counts[type] = n
	_labels[type].text = str(n)


func press_next() -> void:
	on_done.call(counts)
