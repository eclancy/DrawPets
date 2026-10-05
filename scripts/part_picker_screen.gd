class_name PartPickerScreen
extends Control
## "What does your creature have?" - the kid picks how many of each part. Every creature has
## a body; everything else is optional, and anything goes (eight eyes, no legs, four wings).
## The kid draws each kind of part once, and gets that many copies of it.

var counts := {"eye": 2, "mouth": 1}
var on_done := Callable()
var on_cancel := Callable()

var _labels := {}


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	add_child(UI.full_rect(UI.margin(col, 22)))

	var top := HBoxContainer.new()
	top.add_child(UI.button("Back", on_cancel, Vector2(120, 64), 24))
	var heading := UI.title("What does your creature have?", 38)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(heading)
	col.add_child(top)
	var hint := UI.label("Every creature has a body, eyes and a mouth. Tap + for everything else - six legs? Three eyes? Sure!", 22)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)

	var grid := GridContainer.new()
	grid.columns = 6
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for type in PartTypes.ORDER:
		grid.add_child(_card(type))
	col.add_child(grid)

	var next := UI.big_button("Next: draw the body!", press_next)
	col.add_child(next)


func _card(type: String) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(col)
	var name := UI.label(PartTypes.info(type)["plural"], 24)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(name)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(UI.button("-", func(): change(type, -1), Vector2(54, 54), 30))
	var count := UI.label(str(counts.get(type, 0)), 32)
	if int(counts.get(type, 0)) > 0:
		count.add_theme_color_override("font_color", UI.ACCENT)
	count.custom_minimum_size = Vector2(44, 0)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_labels[type] = count
	row.add_child(count)
	row.add_child(UI.button("+", func(): change(type, 1), Vector2(54, 54), 30))
	col.add_child(row)
	return card


func change(type: String, by: int) -> void:
	var info := PartTypes.info(type)
	var n := clampi(int(counts.get(type, 0)) + by, int(info.get("min", 0)), int(info["max"]))
	counts[type] = n
	_labels[type].text = str(n)
	_labels[type].add_theme_color_override("font_color", UI.ACCENT if n > 0 else UI.INK)


func press_next() -> void:
	on_done.call(counts)
