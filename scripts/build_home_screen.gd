class_name BuildHomeScreen
extends Control
## Building a home on an empty plot: pick one of the ready-built homes (Homes.PREMADE - a house
## and a few things already set out, one for each place), then give it a name. Homes in special
## places stay locked until the place is bought in the shop.
##
## `on_done` gets the new home, or {} if the kid backed out.

var game: GameRoot
var on_done := Callable()
## Optional: a pet who will live there, so each home can say how it would feel about it.
var for_pet := {}

var _content: Control
var _name: LineEdit
var _chosen := ""


func _ready() -> void:
	_list()


func _swap(c: Control) -> void:
	if _content != null:
		UI.retire(_content)
	_content = c
	add_child(UI.full_rect(c))


func _list() -> void:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	root.add_child(UI.full_rect(UI.margin(col, 20)))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", func(): on_done.call({}), 40, Vector2(100, 84)))
	top.add_child(UI.icon("ui_build", 64))
	var heading := UI.title("Pick a home to build", 42)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	col.add_child(top)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)
	for id in Homes.ids():
		grid.add_child(_card(id))
	_swap(root)


func _card(id: String) -> Button:
	var info := Homes.info(id)
	var place: String = info["place"]
	var locked := not game.profile.place_unlocked(place)
	var caption: String = info["name"]
	if not for_pet.is_empty() and Places.liking(for_pet.get("place", ""), place) >= 1.0:
		caption += " - %s loves it!" % for_pet["name"]
	var b := UI.place_button(place, caption, Vector2(290, 190), locked)
	var house := UI.item_picture(Items.get_item(info["house"]), 120)
	house.position = Vector2(85, 26)
	b.add_child(house)
	b.move_child(house, 1)
	b.pressed.connect(func():
		if locked:
			game.toast("Buy %s in the shop to build there!" % Places.display_name(place), "icon_lock")
		else:
			_name_it(id))
	return b


func _name_it(id: String) -> void:
	_chosen = id
	var info := Homes.info(id)
	var root := Control.new()
	root.add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 30)
	root.add_child(UI.full_rect(UI.margin(row, 30)))
	var preview := UI.place_button(info["place"], Places.display_name(info["place"]), Vector2(560, 400))
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var house := UI.item_picture(Items.get_item(info["house"]), 300)
	house.position = Vector2(130, 60)
	preview.add_child(house)
	preview.move_child(house, 1)
	row.add_child(preview)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 16)
	row.add_child(col)
	var top := HBoxContainer.new()
	top.add_child(UI.icon("ui_sign", 72))
	top.add_child(UI.title("Name your home!", 40))
	col.add_child(top)
	_name = LineEdit.new()
	_name.text = info["name"]
	_name.placeholder_text = "Name it!"
	_name.max_length = 22
	_name.custom_minimum_size = Vector2(0, 72)
	_name.select_all_on_focus = true
	col.add_child(_name)
	col.add_child(UI.big_icon_button("ui_build", "Build it!", press_build))
	col.add_child(UI.icon_button("tool_back", "Pick another", _list, 40, Vector2(0, 84)))
	_swap(root)


func set_home_name(text: String) -> void:
	if _name != null:
		_name.text = text


func press_build() -> void:
	var n := _name.text.strip_edges()
	if n == "":
		n = Homes.info(_chosen)["name"]
	var h := game.profile.build_home(_chosen, n)
	Sounds.play("build")
	game.reward(5, "You built %s!" % n)
	on_done.call(h)
