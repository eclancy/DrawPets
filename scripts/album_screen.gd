class_name AlbumScreen
extends Control
## The family photo album: every photo kept with the camera, newest first. Tap one to see it big.
## Photos stay in the game (Album) - this is the only place they are shown.

var game: GameRoot
## Where Back goes (a home, or the home screen).
var on_back := Callable()

var _big: Control
var _big_pic: TextureRect
var _big_label: Label
var _showing := ""


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	UI.full_rect(col)
	col.offset_left = 16
	col.offset_top = 12
	col.offset_right = -16
	col.offset_bottom = -12
	add_child(col)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", _back, 40, Vector2(100, 84)))
	var title := UI.title("Photo Album", 40)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	col.add_child(top)

	var photos := Album.photos(game.profile)
	if photos.is_empty():
		var l := UI.label("No photos yet! In a home, tap Photo, pick a pose and snap.", 26, true)
		l.size_flags_vertical = Control.SIZE_EXPAND_FILL
		col.add_child(l)
	else:
		var scroll := ScrollContainer.new()
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		col.add_child(scroll)
		var grid := GridContainer.new()
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		scroll.add_child(grid)
		for p in photos:
			grid.add_child(_thumb(p))

	_big = Control.new()
	_big.visible = false
	add_child(UI.full_rect(_big))
	var shade := ColorRect.new()
	shade.color = Color(UI.PAPER, 0.96)
	shade.gui_input.connect(_close_big)
	_big.add_child(UI.full_rect(shade))
	_big_pic = TextureRect.new()
	_big_pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_big_pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_big_pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_big.add_child(UI.full_rect(_big_pic))
	_big_pic.offset_left = 40
	_big_pic.offset_top = 30
	_big_pic.offset_right = -40
	_big_pic.offset_bottom = -110
	_big_label = UI.title("", 26)
	_big_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_big_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_big_label.offset_bottom = -40
	_big.add_child(_big_label)
	var close := UI.icon_button("tool_back", "Back", _hide_big, 34, Vector2(100, 80))
	close.position = Vector2(16, 16)
	_big.add_child(close)


func _thumb(p: Dictionary) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(280, 176)
	b.pressed.connect(show_photo.bind(p))
	var pic := TextureRect.new()
	pic.texture = Album.texture(p["id"])
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(UI.full_rect(pic))
	pic.offset_left = 6
	pic.offset_top = 6
	pic.offset_right = -6
	pic.offset_bottom = -6
	return b


func show_photo(p: Dictionary) -> void:
	_showing = p["id"]
	_big_pic.texture = Album.texture(p["id"])
	var names := []
	for id in p.get("pets", []):
		var pet := PetStore.load_pet(id)
		if not pet.is_empty():
			names.append(pet["name"])
	_big_label.text = Journal.date_text(int(p.get("t", 0))) + ("  -  " + ", ".join(names) if not names.is_empty() else "")
	_big.visible = true


func _hide_big() -> void:
	_big.visible = false


func _close_big(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		_hide_big()


func _back() -> void:
	if on_back.is_valid():
		on_back.call()
	else:
		game.go_home()


## Android's back gesture: out of a big photo first.
func go_back() -> void:
	if _big.visible:
		_hide_big()
	else:
		_back()
