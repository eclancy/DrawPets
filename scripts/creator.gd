class_name Creator
extends Control
## Making a new pet, in stages (.ai/creature-pipeline.md):
##   how many heads, arms and legs?
##   -> draw the body's shape, adding what grows on it (wings, a tail, fins...)
##   -> draw a head's shape, adding what goes on it (eyes, a mouth, horns, ears...)
##   -> draw an arm, adding a hand or claws -> draw a leg, adding a foot or claws
##   -> put it together -> name, size, favourite place -> two personality words -> its voice
##   -> favourite food and toy (pick or draw) -> where it will live -> meet it at home.
##
## While a host (body, head, arm, leg) is being drawn, tapping an add-on first asks where it
## goes - the kid taps their drawing once for each one - then opens that add-on's sheet zoomed
## in on the first tap, with the host faint on it; finishing it comes back to the host with the
## add-on shown in place. The host's sheet is kept, not redrawn, while the add-on is drawn.
##
## Every drawing step has Back (the step before, drawing and all) and Stop (save it for later,
## or throw it away). A pet half made is a DRAFT in user://draft: saved at every step, and with
## the page as it is when the kid chooses to save. Starting a new pet offers to finish it. A
## shiny marker used anywhere in the pet lasts until the pet is finished, and is used up then.

const HOST_LABELS := {"body": "the body", "head": "the head", "arm": "each arm", "leg": "each leg"}
const DRAFT_DIR := "user://draft"

var game: GameRoot
var pet := PetBuilder.new_pet()
var counts := PartPickerScreen.START.duplicate()
var current: Control

## Hosts still to draw, in order; the ones finished ({type, image, pivot, shine, pending}), in
## order - the pet is rebuilt from these, so going back is just taking one off; and drawings of
## hosts the kid went back past, kept for when they come forward again.
var _hosts: Array = []
var _done_hosts: Array = []
var _carry := {}
var _host_type := ""
var _host_screen: DrawScreen
## The add-ons on the host being drawn: type -> {count, image, pivot, shine, spots (sheet px)}.
var _pending := {}
var _addon_type := ""
var _addon_spots: Array = []
## Shiny markers used in this pet: mode -> true. Used up when it is finished.
var _markers_used := {}
var _after_drawing := false
var _dialog: Control


func _ready() -> void:
	if has_draft():
		_offer_draft()
	else:
		_pick_parts()


## Shows a step. With `keep`, the current step is hidden rather than thrown away - the head's
## sheet waits, drawing and all, while its horns are drawn.
func _show(screen: Control, keep := false) -> void:
	if current != null and current != screen:
		if keep:
			current.visible = false
		else:
			UI.retire(current)
	current = screen
	if screen.get_parent() == null:
		add_child(UI.full_rect(screen))
	screen.visible = true


func _pick_parts() -> void:
	var s := PartPickerScreen.new()
	s.counts = counts
	s.on_done = _on_parts_picked
	s.on_cancel = _cancel_from_picker
	_show(s)


func _markers() -> Dictionary:
	var out := {}
	for mode in Items.MARKERS:
		var n := game.profile.owned(Items.MARKERS[mode][0])
		if n > 0:
			out[mode] = n
	return out


## Notes the shiny marker a drawing was made with: it lasts for the whole pet, and is used up
## when the pet is finished (_finish).
func _spend_marker(r: Dictionary) -> Dictionary:
	var used: String = r.get("used_marker", "")
	if used != "":
		_markers_used[used] = true
	return r.get("shine", {})


func _on_parts_picked(picked: Dictionary) -> void:
	counts = picked
	_hosts = ["body"]
	for t in PartTypes.MAIN:
		if int(counts.get(t, 0)) > 0:
			_hosts.append(t)
	_done_hosts.clear()
	_rebuild_pet()
	_next_host()


## Eyes and a mouth go on the head - or on the body when there is no head.
func _face_host() -> String:
	return "head" if int(counts.get("head", 0)) > 0 else "body"


# --- Drawing a host and its add-ons ----------------------------------------------------------

func _next_host() -> void:
	if _hosts.is_empty():
		_host_screen = null
		_assemble()
		return
	_host_type = _hosts.pop_front()
	var saved: Dictionary = _carry.get(_host_type, {})
	_carry.erase(_host_type)
	_open_host(saved)
	_autosave()


## Opens the sheet for `_host_type` - blank, or `saved` ({image, pivot, shine, pending}) when
## the kid comes back to it.
func _open_host(saved: Dictionary) -> void:
	_after_drawing = false
	_pending = (saved.get("pending", {}) as Dictionary).duplicate(true)
	var info := PartTypes.info(_host_type)
	var n := 1 if _host_type == "body" else int(counts[_host_type])
	var s := DrawScreen.new()
	s.subject = _host_type
	s.prompt = info["prompt"] + (" You'll get %d of them." % n if n > 1 else "")
	s.step_text = "Step %d of %d" % [_done_hosts.size() + 1, _done_hosts.size() + 1 + _hosts.size()]
	if _host_type == "body":
		s.dot = PartTypes.BODY["dot"]
		s.show_dot = false
	else:
		s.ghost = PetBuilder.ghost(pet, _host_type, "body")
		s.dot = info["dot"]
		s.show_dot = true
	s.markers = _markers()
	s.host_label = HOST_LABELS[_host_type]
	s.addons = PartTypes.addons_for(_host_type, int(counts.get("head", 0)) > 0)
	s.required = PartTypes.REQUIRED if _host_type == _face_host() else []
	s.on_addon = _place_addon
	s.on_placed = _start_addon
	s.on_remove_addon = _remove_addon
	s.on_done = _host_done
	s.on_back = _back
	s.on_quit = _ask_quit
	if saved.has("image"):
		s.start_image = saved["image"]
		s.start_pivot = saved["pivot"]
		s.start_shine = saved.get("shine", {})
	var old := current
	_host_screen = s
	if old != null:
		UI.retire(old)
		current = null
	_show(s)
	if not _pending.is_empty():
		_refresh_host.call_deferred()


## Tapping an add-on: first, where does it go? (Its earlier spots, if it is already on.)
func _place_addon(type: String) -> void:
	var spots: Array = _pending[type].get("spots", []) if _pending.has(type) else []
	_host_screen.begin_placing(type, spots)


## Where the parts of a type would go by themselves, in sheet pixels - for the demo kid, who
## taps where a kid most likely would.
func suggest_spots(type: String) -> Array:
	var snap := await _host_screen.canvas.finish()
	if snap.is_empty():
		return []
	var origin: Vector2 = _host_screen.canvas.dot - snap["pivot"]
	var spots := PetBuilder.layout_on_host(type, _host_type, int(PartTypes.info(type).get("count", 1)),
		snap["image"], Transform2D(0.0, Vector2.ONE, 0.0, origin), 1.0, _face_host() == "body")
	var out := []
	for sp in spots:
		out.append(sp["pos"])
	return out


## The spots are tapped: open the add-on's sheet, zoomed in on the first one.
func _start_addon(type: String, spots: Array) -> void:
	var snap := await _host_screen.canvas.finish()
	if snap.is_empty():
		_host_screen._say("Draw %s first, then add things to it!" % HOST_LABELS[_host_type].trim_prefix("each "))
		return
	var origin: Vector2 = _host_screen.canvas.dot - snap["pivot"]
	var info := PartTypes.info(type)
	var s := DrawScreen.new()
	s.subject = type
	s.prompt = info["prompt"] + (" It goes on all %d spots." % spots.size() if spots.size() > 1 else "")
	s.step_text = "Adding to %s" % HOST_LABELS[_host_type]
	s.ghost = PetBuilder.ghost_on(snap["image"], 1.0 / float(PartTypes.info(_host_type)["zoom"]), type,
		_host_type, _face_host() == "body", (spots[0] as Vector2) - origin)
	s.dot = info["dot"]
	s.show_dot = true
	s.can_skip = true
	s.skip_text = "Back"
	s.markers = _markers()
	s.on_quit = _ask_quit
	if _pending.has(type):
		# Moving or changing one already drawn: its drawing comes back to work on.
		s.start_image = _pending[type]["image"]
		s.start_pivot = _pending[type]["pivot"]
		s.start_shine = _pending[type].get("shine", {})
	s.on_done = _addon_done.bind(type, spots)
	_addon_type = type
	_addon_spots = spots
	_show(s, true)


func _addon_done(r: Dictionary, type: String, spots: Array) -> void:
	_addon_type = ""
	if r.is_empty():
		_back_to_host()
		return
	_pending[type] = {"count": spots.size(), "image": r["image"], "pivot": r["pivot"],
		"shine": _spend_marker(r), "spots": spots}
	_autosave()
	_preview_addon(type)


func _back_to_host() -> void:
	_addon_type = ""
	if current != null and current != _host_screen:
		UI.retire(current)
	current = _host_screen
	_host_screen.visible = true
	_refresh_host()


func _remove_addon(type: String) -> void:
	_pending.erase(type)
	_refresh_host()


## Updates the add-on buttons and shows each add-on in place on the drawing so far.
func _refresh_host() -> void:
	if _host_screen == null or not is_instance_valid(_host_screen):
		return
	var added := {}
	for type in _pending:
		added[type] = {"count": _pending[type]["count"], "image": _pending[type]["image"]}
	_host_screen.added = added
	_host_screen.refresh_addons()
	var snap := await _host_screen.canvas.finish()
	if snap.is_empty():
		_host_screen.set_previews([])
		return
	# The cropped drawing's top-left on the sheet: finish() gives the dot in crop pixels.
	var origin: Vector2 = _host_screen.canvas.dot - snap["pivot"]
	var host_zoom := float(PartTypes.info(_host_type)["zoom"])
	var previews := []
	for type in _pending:
		var a: Dictionary = _pending[type]
		var tex := ImageTexture.create_from_image(a["image"])
		var spots := PetBuilder.layout_on_host(type, _host_type, int(a["count"]), snap["image"],
			Transform2D(0.0, Vector2.ONE, 0.0, origin), 1.0, _face_host() == "body", _spots_layout(a, origin))
		for spot in spots:
			previews.append({"texture": tex, "pos": spot["pos"], "pivot": a["pivot"],
				"scale": host_zoom / float(PartTypes.info(type)["zoom"]), "behind": spot["behind"]})
	_host_screen.set_previews(previews)


## An add-on's tapped spots as a layout for PetBuilder, in the host drawing's own pixels.
func _spots_layout(a: Dictionary, origin: Vector2) -> Dictionary:
	var spots: Array = a.get("spots", [])
	if spots.is_empty():
		return {}
	var px := []
	for sp in spots:
		px.append((sp as Vector2) - origin)
	return {"spots": px}


func _host_done(r: Dictionary) -> void:
	var origin: Vector2 = _host_screen.canvas.dot - r["pivot"]
	var pending := _pending.duplicate(true)
	for type in pending:
		pending[type]["layout"] = _spots_layout(pending[type], origin)
	_done_hosts.append({"type": _host_type, "image": r["image"], "pivot": r["pivot"],
		"shine": _spend_marker(r), "pending": pending})
	_rebuild_pet()
	_preview_part(_host_type, pet, _next_host)


## The pet from the finished hosts, in order - the body, then each head, arm and leg with
## everything added to it.
func _rebuild_pet() -> void:
	pet["parts"] = []
	pet["_img"] = {}
	pet["_tex"] = {}
	for e in _done_hosts:
		_add_host(pet, e, int(counts.get(e["type"], 1)))


## Adds one finished host (`n` copies of it - four legs) and everything drawn on it.
static func _add_host(p: Dictionary, e: Dictionary, n: int) -> void:
	var type: String = e["type"]
	if type == "body":
		PetBuilder.set_body(p, e["image"], e["shine"])
	else:
		PetBuilder.add_parts(p, type, n, e["image"], e["pivot"], e["shine"], "body")
	var pending: Dictionary = e["pending"]
	for t in PartTypes.ORDER:
		if pending.has(t):
			var a: Dictionary = pending[t]
			PetBuilder.add_parts(p, t, int(a["count"]), a["image"], a["pivot"], a["shine"], type,
				a.get("layout", {}))


## An add-on is not on the pet until its host is done, so its preview is a copy of the pet with
## the host as drawn so far and every add-on on it - this one included.
func _preview_addon(type: String) -> void:
	var snap := await _host_screen.canvas.finish()
	if snap.is_empty():
		_back_to_host()
		return
	var origin: Vector2 = _host_screen.canvas.dot - snap["pivot"]
	var pending := _pending.duplicate(true)
	for t in pending:
		pending[t]["layout"] = _spots_layout(pending[t], origin)
	var show_pet: Dictionary = pet.duplicate(true)
	_add_host(show_pet, {"type": _host_type, "image": snap["image"], "pivot": snap["pivot"], "shine": {},
		"pending": pending}, 1 if _host_type == "body" else int(counts[_host_type]))
	_preview_part(type, show_pet, _back_to_host)


## The creature so far shows off the part just drawn - legs walk, a tail wags - then carries on.
func _preview_part(type: String, show_pet: Dictionary, then: Callable) -> void:
	var p := PartPreview.new()
	p.pet = show_pet
	p.part_type = type
	p.on_done = then
	add_child(UI.full_rect(p))


# --- Back, stop, and saving for later ---------------------------------------------------------

## Back a step: to the host drawn before this one, with its drawing and add-ons - or, from the
## body, to the parts picker. This host's drawing is kept for when the kid comes forward again.
func _back() -> void:
	if _host_screen == null or not is_instance_valid(_host_screen):
		return
	_carry[_host_type] = await _host_state()
	_hosts.push_front(_host_type)
	if _done_hosts.is_empty():
		_host_screen = null
		_pick_parts()
		_autosave()
		return
	var e: Dictionary = _done_hosts.pop_back()
	_rebuild_pet()
	_host_type = e["type"]
	var pending: Dictionary = e["pending"]
	for t in pending:
		pending[t].erase("layout")
	_open_host({"image": e["image"], "pivot": e["pivot"], "shine": e["shine"], "pending": pending})
	_autosave()


## The host sheet as it is now: {image, pivot, shine, pending} - or just its add-ons when the
## page is empty. An add-on sheet that is open is folded in as it is.
func _host_state() -> Dictionary:
	if _addon_type != "" and current is DrawScreen and current != _host_screen:
		var a := await (current as DrawScreen).canvas.finish()
		if not a.is_empty():
			_pending[_addon_type] = {"count": _addon_spots.size(), "image": a["image"], "pivot": a["pivot"],
				"shine": _spend_marker(a), "spots": _addon_spots}
	var state := {"pending": _pending.duplicate(true)}
	var snap := await _host_screen.canvas.finish()
	if not snap.is_empty():
		state["image"] = snap["image"]
		state["pivot"] = snap["pivot"]
		state["shine"] = _spend_marker(snap)
	return state


## Android's back gesture: the same as the Back button (or closing whatever is open).
func go_back() -> void:
	if _dialog != null and is_instance_valid(_dialog):
		_close_dialog()
	elif current is DrawScreen and current == _host_screen:
		if _host_screen.is_placing():
			_host_screen.end_placing()
		else:
			_back()
	elif current is DrawScreen:
		_back_to_host()
	elif current is PartPickerScreen:
		_cancel_from_picker()
	else:
		_ask_quit()


func _cancel_from_picker() -> void:
	if _done_hosts.is_empty() and _carry.is_empty():
		delete_draft()
		game.go_home()
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
	var current_state := {"pending": _pending.duplicate(true)}
	if not _after_drawing and _host_screen != null and is_instance_valid(_host_screen):
		current_state = await _host_state()
	_write_draft(current_state)


## Saves between steps, without waiting for the page to be read back.
func _autosave() -> void:
	if _host_screen == null or _after_drawing:
		_write_draft({})
	else:
		_write_draft({"pending": _pending.duplicate(true)})


func _write_draft(current_state: Dictionary) -> void:
	delete_draft()
	DirAccess.make_dir_recursive_absolute(DRAFT_DIR)
	var files := {"n": 0}
	var done := []
	for e in _done_hosts:
		done.append(_pack(e, files))
	var carry := {}
	for k in _carry:
		carry[k] = _pack(_carry[k], files)
	var data := {"version": 1, "counts": counts, "host": _host_type, "hosts": _hosts, "done": done,
		"carry": carry, "current": _pack(current_state, files), "markers": _markers_used.keys(),
		"after": _after_drawing}
	var f := FileAccess.open(DRAFT_DIR + "/draft.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data))


static func has_draft() -> bool:
	return FileAccess.file_exists(DRAFT_DIR + "/draft.json")


static func delete_draft() -> void:
	var d := DirAccess.open(DRAFT_DIR)
	if d == null:
		return
	for f in d.get_files():
		d.remove(f)
	DirAccess.remove_absolute(DRAFT_DIR)


## Images become PNG files beside draft.json, Vector2s become {"_v2": [x, y]} - so a draft is
## plain JSON plus pictures, and nothing the kid drew is lost.
static func _pack(v: Variant, files: Dictionary) -> Variant:
	if v is Image:
		files["n"] = int(files["n"]) + 1
		var name := "img_%d.png" % int(files["n"])
		(v as Image).save_png(DRAFT_DIR + "/" + name)
		return {"_png": name}
	if v is Vector2:
		return {"_v2": [v.x, v.y]}
	if v is Dictionary:
		var out := {}
		for k in v:
			out[k] = _pack(v[k], files)
		return out
	if v is Array:
		var out := []
		for x in v:
			out.append(_pack(x, files))
		return out
	return v


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


## The latest thing drawn in the draft, for its picture.
func _draft_picture() -> Image:
	var data = JSON.parse_string(FileAccess.get_file_as_string(DRAFT_DIR + "/draft.json"))
	if typeof(data) != TYPE_DICTIONARY:
		return null
	var d: Dictionary = _unpack(data)
	var cur: Dictionary = d.get("current", {})
	if cur.has("image"):
		return cur["image"]
	var done: Array = d.get("done", [])
	return done[done.size() - 1]["image"] if not done.is_empty() else null


func _start_fresh() -> void:
	delete_draft()
	_pick_parts()


## Picks the draft up where it was left: the page it was on, drawing and all.
func resume_draft() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(DRAFT_DIR + "/draft.json"))
	if typeof(data) != TYPE_DICTIONARY:
		_start_fresh()
		return
	var d: Dictionary = _unpack(data)
	counts = {}
	for k in d.get("counts", {}):
		counts[k] = int(d["counts"][k])
	_hosts = d.get("hosts", [])
	_done_hosts = d.get("done", [])
	_carry = d.get("carry", {})
	_markers_used = {}
	for m in d.get("markers", []):
		_markers_used[m] = true
	_host_type = str(d.get("host", ""))
	_rebuild_pet()
	if bool(d.get("after", false)) or _host_type == "":
		if _hosts.is_empty() and not _done_hosts.is_empty():
			_assemble()
		else:
			_pick_parts()
		return
	_open_host(d.get("current", {}))


# --- After drawing ---------------------------------------------------------------------------

func _assemble() -> void:
	_after_drawing = true
	_autosave()
	var s := AssembleScreen.new()
	s.pet = pet
	s.on_done = _details
	_show(s)


func _details() -> void:
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
