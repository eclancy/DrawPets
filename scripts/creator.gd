class_name Creator
extends Control
## Making a new pet (.ai/creature-pipeline.md):
##   draw the whole creature on one sheet, part by part (CreatureSheet) - tap Wings, draw the
##   wings where they go, "Done with the wings" and watch them flap
##   -> name, size, favourite place -> two personality words -> its coat -> its voice
##   -> favourite food and toy (pick or draw) -> where it will live -> meet it at home.
##
## Stop (on the sheet, and on the steps after it) offers to save it for later or throw it away.
## A pet half made is a DRAFT in user://draft: every layer of the drawing, saved each time a part
## is put down, and with the page as it is when the kid chooses to save. Starting a new pet offers
## to finish it. A shiny marker used anywhere in the pet lasts until the pet is finished, and is
## used up then.

const DRAFT_DIR := "user://draft"
const DRAFT_VERSION := 2

var game: GameRoot
var pet := PetBuilder.new_pet()
var current: Control
var sheet: CreatureSheet

## The drawing, a layer per part type (CreatureSheet), and the part being drawn.
var _layers := {}
var _shines := {}
var _active := "body"
## Shiny markers used in this pet: mode -> true. Used up when it is finished.
var _markers_used := {}
var _after_drawing := false
## The pictures in the draft folder now: file -> the Image written there.
var _saved := {}
var _dialog: Control
## Stop, for the steps after drawing (name, personality, voice, favourites, its home) - they are
## shared screens with no Stop of their own.
var _stop_button: Button


func _ready() -> void:
	_stop_button = UI.icon_button("icon_home", "Stop", _ask_quit, 28, Vector2(78, 64))
	_stop_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_stop_button.offset_left = -92
	_stop_button.offset_right = -14
	_stop_button.offset_top = 12
	_stop_button.offset_bottom = 76
	_stop_button.visible = false
	add_child(_stop_button)
	if has_draft():
		_offer_draft()
	else:
		_open_sheet()


func _show(screen: Control) -> void:
	if current != null and current != screen:
		UI.retire(current)
	current = screen
	if screen.get_parent() == null:
		add_child(UI.full_rect(screen))
	screen.visible = true
	if _stop_button != null:
		move_child(_stop_button, -1)


## Stop shows on the steps after drawing - not while a favourite snack or toy is being drawn,
## where it would sit on the prompt.
func _process(_delta: float) -> void:
	if _stop_button == null:
		return
	var show := _after_drawing
	if current is ItemPickerScreen and (current as ItemPickerScreen)._content is ItemMaker:
		show = false
	_stop_button.visible = show


func _markers() -> Dictionary:
	var out := {}
	for mode in Items.MARKERS:
		var n := game.profile.owned(Items.MARKERS[mode][0])
		if n > 0:
			out[mode] = n
	return out


# --- Drawing it ------------------------------------------------------------------------------

func _open_sheet() -> void:
	_after_drawing = false
	var s := CreatureSheet.new()
	s.layers = _layers
	s.shines = _shines
	s.start = _active
	s.markers = _markers()
	s.markers_used = _markers_used
	s.on_stop = _ask_quit
	s.on_change = _autosave
	s.on_finished = _drawn
	sheet = s
	_show(s)


func _drawn(built: Dictionary) -> void:
	_take_parts(built)
	sheet = null
	_details()


## The parts of a pet built from the drawing, into the pet being made (its name and the rest stay).
func _take_parts(built: Dictionary) -> void:
	pet["parts"] = built["parts"]
	pet["_img"] = built["_img"]
	pet["_tex"] = {}


# --- Stop, and saving for later --------------------------------------------------------------

## Android's back gesture: closes whatever is open, or asks whether to stop.
func go_back() -> void:
	if _dialog != null and is_instance_valid(_dialog):
		_close_dialog()
	elif sheet != null and is_instance_valid(sheet) and sheet.skip_preview():
		return
	else:
		_ask_quit()


## "Stop drawing?" - save it for later, throw it away, or keep going.
func _ask_quit() -> void:
	if _dialog != null and is_instance_valid(_dialog):
		return
	_dialog = Control.new()
	add_child(UI.full_rect(_dialog))
	var dim := ColorRect.new()
	dim.color = Color(0.23, 0.21, 0.4, 0.35)
	_dialog.add_child(UI.full_rect(dim))
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_dialog.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(UI.margin(col, 22))
	var title := UI.title("Stop drawing?", 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	col.add_child(UI.button("Save it for later", _quit_save, Vector2(420, 72), 26))
	col.add_child(UI.button("Throw it away", _quit_discard, Vector2(420, 64), 22))
	col.add_child(UI.button("Keep drawing", _close_dialog, Vector2(420, 64), 22))


## The demo kid taps Stop.
func on_quit_for_demo() -> void:
	_ask_quit()


func _close_dialog() -> void:
	if _dialog != null and is_instance_valid(_dialog):
		UI.retire(_dialog)
	_dialog = null


func _quit_save() -> void:
	_close_dialog()
	await save_draft()
	game.toast("Saved! Draw a new pet to finish it.", "icon_draw")
	game.go_home()


func _quit_discard() -> void:
	_close_dialog()
	delete_draft()
	game.go_home()


## Saves now, page and all - the app is going into the background, or the kid chose to.
func save_now() -> void:
	save_draft()


## Saves the pet as it is now into user://draft, with whatever is on the page.
func save_draft() -> void:
	if not _after_drawing and sheet != null and is_instance_valid(sheet):
		await sheet.state()
	_write_draft()


## Saves when a part is put down - the layers are all up to date then.
func _autosave() -> void:
	_write_draft()


## Each layer is a PNG beside draft.json, written only when it has changed - a part put down
## saves that part, not the whole creature again.
func _write_draft() -> void:
	DirAccess.make_dir_recursive_absolute(DRAFT_DIR)
	if sheet != null and is_instance_valid(sheet):
		_active = sheet.active
	var layers := {}
	var shines := {}
	var keep := ["draft.json"]
	for type in _layers:
		layers[type] = {"_png": _save_png("layer_" + type, _layers[type])}
		keep.append(layers[type]["_png"])
		if _shines.has(type):
			shines[type] = {"mode": _shines[type]["mode"],
				"mask": {"_png": _save_png("shine_" + type, _shines[type]["mask"])}}
			keep.append(shines[type]["mask"]["_png"])
	var data := {"version": DRAFT_VERSION, "layers": layers, "shines": shines, "active": _active,
		"markers": _markers_used.keys(), "after": _after_drawing}
	var f := FileAccess.open(DRAFT_DIR + "/draft.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data))
		f.close()
	var d := DirAccess.open(DRAFT_DIR)
	if d != null:
		for file in d.get_files():
			if not keep.has(file):
				d.remove(file)


## "<stem>.png" in the draft, unless that very picture is already there.
func _save_png(stem: String, img: Image) -> String:
	var file := stem + ".png"
	if _saved.get(file) != img or not FileAccess.file_exists(DRAFT_DIR + "/" + file):
		img.save_png(DRAFT_DIR + "/" + file)
		_saved[file] = img
	return file


static func has_draft() -> bool:
	return FileAccess.file_exists(DRAFT_DIR + "/draft.json")


static func delete_draft() -> void:
	var d := DirAccess.open(DRAFT_DIR)
	if d == null:
		return
	for f in d.get_files():
		d.remove(f)
	DirAccess.remove_absolute(DRAFT_DIR)


## {"_png": file} in draft.json is a picture beside it, {"_v2": [x, y]} a Vector2 - so a draft
## is plain JSON plus pictures, and nothing the kid drew is lost.
static func _unpack(v: Variant) -> Variant:
	if v is Dictionary:
		if v.has("_png"):
			return Image.load_from_file(DRAFT_DIR + "/" + str(v["_png"]))
		if v.has("_v2"):
			return Vector2(float(v["_v2"][0]), float(v["_v2"][1]))
		var out := {}
		for k in v:
			out[k] = _unpack(v[k])
		return out
	if v is Array:
		var out := []
		for x in v:
			out.append(_unpack(x))
		return out
	return v


## A pet half made is waiting: carry on with it, or start a new one.
func _offer_draft() -> void:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 18)
	root.add_child(UI.full_rect(col))
	var title := UI.title("You were drawing a pet!", 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var pic := TextureRect.new()
	var img := _draft_picture()
	if img != null:
		pic.texture = ImageTexture.create_from_image(img)
	pic.custom_minimum_size = Vector2(320, 260)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(pic)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	var keep := UI.big_icon_button("tool_done", "Keep drawing it", resume_draft)
	keep.custom_minimum_size = Vector2(380, 84)
	row.add_child(keep)
	row.add_child(UI.button("Start a new one", _start_fresh, Vector2(300, 84), 24))
	col.add_child(row)
	var note := UI.label("Starting a new one throws that drawing away.", 18)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(note)
	_show(root)


## The draft's drawing so far, for its picture.
func _draft_picture() -> Image:
	var d := _read_draft()
	var layers: Dictionary = d.get("layers", {})
	if layers.is_empty():
		return null
	var all := Image.create(CreatureSheet.SIZE.x, CreatureSheet.SIZE.y, false, Image.FORMAT_RGBA8)
	for type in CreatureSheet.stack_order():
		if layers.has(type):
			var img: Image = layers[type]
			all.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i.ZERO)
	var used := all.get_used_rect()
	return all.get_region(used) if used.size.x > 1 else null


## The draft as saved - and a draft from before the one-sheet creature (version 1), whose body
## is all that carries over: it goes in the middle of the sheet to be drawn on.
static func _read_draft() -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(DRAFT_DIR + "/draft.json"))
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var d: Dictionary = _unpack(data)
	if int(d.get("version", 1)) >= DRAFT_VERSION:
		return d
	var body: Image
	for e in d.get("done", []):
		if e.get("type", "") == "body":
			body = e["image"]
	if body == null and str(d.get("host", "")) == "body":
		body = d.get("current", {}).get("image")
	var out := {"layers": {}, "shines": {}, "active": "body", "markers": d.get("markers", [])}
	if body != null:
		var page := Image.create(CreatureSheet.SIZE.x, CreatureSheet.SIZE.y, false, Image.FORMAT_RGBA8)
		var at := (CreatureSheet.SIZE - body.get_size()) / 2
		body.convert(Image.FORMAT_RGBA8)
		page.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), at.max(Vector2i.ZERO))
		out["layers"]["body"] = page
	return out


func _start_fresh() -> void:
	delete_draft()
	_saved.clear()
	_open_sheet()


## Picks the draft up where it was left: the page it was on, drawing and all.
func resume_draft() -> void:
	var d := _read_draft()
	if d.is_empty():
		_start_fresh()
		return
	_layers = d.get("layers", {})
	_shines = d.get("shines", {})
	_active = str(d.get("active", "body"))
	_markers_used = {}
	for m in d.get("markers", []):
		_markers_used[m] = true
	if bool(d.get("after", false)) and _layers.has("body"):
		_take_parts(PartCutter.build(_layers, _shines))
		_details()
		return
	_open_sheet()


# --- After drawing ---------------------------------------------------------------------------

func _details() -> void:
	_after_drawing = true
	_autosave()
	var s := DetailsScreen.new()
	s.pet = pet
	s.profile = game.profile
	s.on_done = _personality
	_show(s)


func _personality() -> void:
	var s := WordPickerScreen.new()
	s.category = "pet"
	s.question = "What is %s like?" % pet["name"]
	s.max_pick = 2
	s.on_done = func(words: Array):
		pet["personality"] = words
		_coat()
	_show(s)


## Its coat - picked, never read from the drawing - decides how bath day grooms it (BathDay).
func _coat() -> void:
	var s := ChoiceScreen.new()
	s.question = "What's %s's coat like?" % pet["name"]
	s.picture = PetStore.texture(pet, PetBuilder.parts_of(pet, "body")[0]["image"])
	s.options = BathDay.COATS.map(func(c): return [c[0], c[1], c[2]])
	s.on_choose = func(id: String):
		pet["coat"] = id
		_voice()
	_show(s)


## Its voice: a base sound shaped with sliders, or the kid's own recording.
func _voice() -> void:
	if not pet.has("voice"):
		pet["voice"] = Voice.default_for(pet)
	var s := VoiceMakerScreen.new()
	s.game = game
	s.target = pet
	s.on_done = func(): _favourite("food")
	_show(s)


func _favourite(category: String) -> void:
	var s := ItemPickerScreen.new()
	s.game = game
	s.category = category
	s.question = "What's %s's favourite %s?" % [pet["name"], "food" if category == "food" else "toy"]
	s.on_done = func(id: String):
		pet[category] = {"item": id}
		if category == "food":
			_favourite("toy")
		else:
			_home()
	_show(s)


func _home() -> void:
	var s := HomePickerScreen.new()
	s.game = game
	s.pet = pet
	s.on_done = _finish
	_show(s)


func _finish(home: Dictionary) -> void:
	Stats.ensure(pet)
	game.profile.move_in(pet, home)
	PetStore.save_pet(pet, true)
	# Every shiny marker that drew on this pet lasted the whole drawing; now it is used up.
	for mode in _markers_used:
		game.profile.use_up(Items.MARKERS[mode][0])
	delete_draft()
	var first := game.profile.pet_count() == 1
	game.reward(10 if first else 5, "Welcome home, %s!" % pet["name"])
	game.go_place(home["id"], pet["id"], true)
