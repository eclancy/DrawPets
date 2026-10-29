class_name Creator
extends Control
## Making a new pet (.ai/creature-pipeline.md):
##   what will it have - how many heads, eyes, ears, arms, legs and tails (PartPlanner)
##   -> draw the whole creature on one sheet, guided one part at a time (CreatureSheet) - "Draw a
##   LEG", "LEG 2 of 4!", "Done with the legs" and watch them walk - then "Anything else?" for
##   wings, horns, tentacles and the rest
##   -> name, size, favourite place -> two personality words -> its coat -> its voice
##   -> favourite food and toy (pick or draw) -> where it will live -> meet it at home.
##
## Stop (on the sheet, and on the steps after it) offers to save it for later or throw it away.
## A pet half made is a DRAFT in user://draft: the plan and every layer of the drawing, saved each
## time a part is put down, and with the page as it is when the kid chooses to save. Starting a new pet offers
## to finish it. A shiny marker used anywhere in the pet lasts until the pet is finished, and is
## used up then.

const DRAFT_DIR := "user://draft"
const DRAFT_VERSION := 3

var game: GameRoot
## Straight back to the saved pet, without asking (back from a bug report).
var resume := false
var pet := PetBuilder.new_pet()
var current: Control
var sheet: CreatureSheet

## The drawing, a layer per part type (CreatureSheet), and the part being drawn.
var _layers := {}
var _active := "body"
## What the pet will have, in drawing order ([[type, how many], ...] - PartTypes.plan_from).
## The sheet changes it in place: a part skipped stays skipped, "Anything else?" adds to it.
var _plan: Array = []
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
	if has_draft() and resume:
		resume_draft()
	elif has_draft():
		_offer_draft()
	else:
		_ask_plan()


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

## "What will your pet have?" - how many heads, eyes, ears, arms, legs and tails.
func _ask_plan() -> void:
	var s := PartPlanner.new()
	s.mode = "start"
	s.on_done = _planned
	s.on_back = game.go_home
	_show(s)


func _planned(counts: Dictionary) -> void:
	_plan = PartTypes.plan_from(counts)
	_active = "body"
	_open_sheet()


func _open_sheet() -> void:
	_after_drawing = false
	var s := CreatureSheet.new()
	s.layers = _layers
	s.start = _active
	s.plan = _plan
	s.profile = game.profile
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

## Android's back gesture: closes whatever is open, back to the drawing from its name, or asks
## whether to stop.
func go_back() -> void:
	if _dialog != null and is_instance_valid(_dialog):
		_close_dialog()
	elif sheet != null and is_instance_valid(sheet) and sheet.skip_preview():
		return
	elif current is DetailsScreen:
		(current as DetailsScreen)._back()
	elif current is PartPlanner:
		game.go_home()
	else:
		_ask_quit()


## "Back to drawing" from its name: the sheet again, with nothing picked, to add or fix a part.
func _back_to_drawing() -> void:
	_after_drawing = false
	_active = ""
	_open_sheet()
	_autosave()


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
	# For a grown-up: something went wrong while drawing? Tell the person who makes it. Held, like
	# the one in Settings, and the pet is saved first so nothing is lost on the way.
	col.add_child(UI.HeldButton.new("Grown-ups, hold: report a bug", _report_bug, Vector2(420, 52), 18))


## The demo kid taps Stop.
func on_quit_for_demo() -> void:
	_ask_quit()


func _close_dialog() -> void:
	if _dialog != null and is_instance_valid(_dialog):
		UI.retire(_dialog)
	_dialog = null


## The pet is saved, then the bug report; its Back comes straight back to the pet as it was.
func _report_bug() -> void:
	_close_dialog()
	await save_draft()
	game.go_feedback(game.resume_creator)


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


## Each drawing is a PNG beside draft.json (with where it goes, and its place in the stack),
## written only when it has changed - a part put down saves that part, not the whole creature.
func _write_draft() -> void:
	DirAccess.make_dir_recursive_absolute(DRAFT_DIR)
	if sheet != null and is_instance_valid(sheet):
		_active = sheet.active
	var layers := {}
	var keep := ["draft.json"]
	for type in _layers:
		var list := []
		var drawings: Array = _layers[type]
		for i in drawings.size():
			var d: Dictionary = drawings[i]
			var e := {"image": {"_png": _save_png("layer_%s_%d" % [type, i], d["image"])},
				"at": {"_v2": [d["at"].x, d["at"].y]}, "behind": bool(d.get("behind", false)),
				"z": int(d.get("z", 0)), "shine": {}}
			keep.append(e["image"]["_png"])
			var sh: Dictionary = d.get("shine", {})
			if not sh.is_empty():
				e["shine"] = {"mode": sh["mode"], "mask": {"_png": _save_png("shine_%s_%d" % [type, i], sh["mask"])}}
				keep.append(e["shine"]["mask"]["_png"])
			list.append(e)
		layers[type] = list
	var data := {"version": DRAFT_VERSION, "layers": layers, "active": _active,
		"markers": _markers_used.keys(), "after": _after_drawing, "plan": _plan,
		"pet": {"name": pet.get("name", ""), "size": pet.get("size", "medium"),
			"place": pet.get("place", "meadow")}}
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
	var note := UI.label("Starting a new one throws that drawing away.", 22)
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
	for e in CreatureSheet.stack_of(layers):
		var img: Image = e[1]["image"]
		all.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(e[1]["at"]))
	var used := all.get_used_rect()
	return all.get_region(used) if used.size.x > 1 else null


## The draft as saved: type -> its drawings ({image, at, shine, behind, z}). Older drafts are
## read too - version 2 kept one sheet-sized picture per part (it becomes that part's one drawing,
## still cut into its pieces), and version 1 (the staged creator) only carries its body over, in
## the middle of the sheet.
static func _read_draft() -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(DRAFT_DIR + "/draft.json"))
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var d: Dictionary = _unpack(data)
	var version := int(d.get("version", 1))
	if version >= 3:
		# A picture that did not load is left out, not carried on as nothing.
		var layers := {}
		for type in d.get("layers", {}):
			var list := []
			for dr in d["layers"][type]:
				if not (dr.get("image") is Image):
					continue
				dr["at"] = Vector2(dr.get("at", Vector2.ZERO))
				dr["behind"] = bool(dr.get("behind", false))
				dr["z"] = int(dr.get("z", 0))
				var sh = dr.get("shine")
				if typeof(sh) != TYPE_DICTIONARY or not (sh.get("mask") is Image):
					dr["shine"] = {}
				list.append(dr)
			if not list.is_empty():
				layers[type] = list
		d["layers"] = layers
		return d
	if version == 2:
		var layers := {}
		var z := 0
		for type in d.get("layers", {}):
			if not (d["layers"][type] is Image):
				continue
			var img: Image = d["layers"][type]
			var shine: Dictionary = d.get("shines", {}).get(type, {})
			var dr := CreatureSheet.drawing_from_sheet(img, shine, PartCutter.BEHIND.has(type), z)
			z += 1
			if not dr.is_empty():
				layers[type] = [dr]
		d["layers"] = layers
		return d
	var body: Image
	for e in d.get("done", []):
		if e.get("type", "") == "body":
			body = e["image"]
	if body == null and str(d.get("host", "")) == "body":
		body = d.get("current", {}).get("image")
	var out := {"layers": {}, "active": "body", "markers": d.get("markers", [])}
	if body != null:
		body.convert(Image.FORMAT_RGBA8)
		var at := ((Vector2(CreatureSheet.SIZE) - Vector2(body.get_size())) / 2.0).floor()
		out["layers"]["body"] = [{"image": body, "at": at.max(Vector2.ZERO), "shine": {},
			"behind": false, "z": 0}]
	return out


func _start_fresh() -> void:
	delete_draft()
	_saved.clear()
	_layers = {}
	_ask_plan()


## Picks the draft up where it was left: the page it was on, drawing and all.
func resume_draft() -> void:
	var d := _read_draft()
	if d.is_empty():
		_start_fresh()
		return
	_layers = d.get("layers", {})
	_active = str(d.get("active", "body"))
	_plan = _plan_of(d)
	var saved: Dictionary = d.get("pet", {})
	for key in ["name", "size", "place"]:
		if saved.has(key):
			pet[key] = str(saved[key])
	_markers_used = {}
	for m in d.get("markers", []):
		_markers_used[m] = true
	if bool(d.get("after", false)) and _layers.has("body"):
		_take_parts(PartCutter.build(_layers))
		_details()
		return
	_open_sheet()


## The draft's plan - or, for a draft from before there were plans, a cat-or-dog plan with every
## part already drawn in it.
static func _plan_of(d: Dictionary) -> Array:
	var out := []
	for e in d.get("plan", []):
		if e is Array and e.size() == 2 and PartTypes.GUIDE_ORDER.has(str(e[0])) and int(e[1]) > 0:
			out.append([str(e[0]), int(e[1])])
	if not out.is_empty():
		return out
	var counts := {}
	for type in PartTypes.PLAN_ASK:
		counts[type] = int(PartTypes.PLAN_ASK[type][2])
	for type in d.get("layers", {}):
		counts[type] = maxi(int(counts.get(type, 0)), 1)
	return PartTypes.plan_from(counts)


# --- After drawing ---------------------------------------------------------------------------

func _details() -> void:
	_after_drawing = true
	_autosave()
	var s := DetailsScreen.new()
	s.pet = pet
	s.profile = game.profile
	s.on_done = _personality
	s.on_back = _back_to_drawing
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
