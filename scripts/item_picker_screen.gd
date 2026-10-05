class_name ItemPickerScreen
extends Control
## "What's its favourite food?" - pick one from everything the family has (their drawings
## first, then the starter kit, then shop things), or draw a new one. Drawing is always the
## first button, but never the only way through.

var game: GameRoot
var category := "food"
var question := ""
var on_done := Callable()

var _content: Control


func _ready() -> void:
	_list()


func _list() -> void:
	if _content != null:
		remove_child(_content)
		_content.queue_free()
	_content = Control.new()
	add_child(UI.full_rect(_content))
	_content.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	_content.add_child(UI.full_rect(UI.margin(col, 24)))
	col.add_child(UI.title(question, 38))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.add_theme_constant_override("h_separation", 12)
	flow.add_theme_constant_override("v_separation", 12)
	scroll.add_child(flow)

	var draw := UI.icon_button("icon_draw", "Draw a new one!", _draw_new, 72, Vector2(170, 170))
	draw.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.INK, 4))
	flow.add_child(draw)
	for id in Items.available(game.profile, category):
		flow.add_child(_card(Items.get_item(id)))


func _card(item: Dictionary) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(170, 170)
	b.pressed.connect(func(): on_done.call(item["id"]))
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	UI.full_rect(col)
	var pic := UI.item_picture(item, 100)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(pic)
	var name := UI.label(Items.display_name(item), 18)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(name)
	var words := UI.label(", ".join(item.get("words", [])), 15)
	words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words.add_theme_color_override("font_color", UI.INK_SOFT)
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(words)
	b.add_child(col)
	return b


func _draw_new() -> void:
	var maker := ItemMaker.new()
	maker.game = game
	maker.category = category
	maker.on_done = func(item: Dictionary):
		if item.is_empty():
			_list()
		else:
			on_done.call(item["id"])
	if _content != null:
		remove_child(_content)
		_content.queue_free()
	_content = maker
	add_child(UI.full_rect(maker))
