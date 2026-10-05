class_name Creator
extends Control
## Making a new pet, in stages (.ai/creature-pipeline.md):
##   how many heads, arms and legs?
##   -> draw the body, adding what grows on it (wings, a tail, fins...)
##   -> draw a head, adding what goes on it (eyes, a mouth, horns, ears...)
##   -> draw an arm, adding a hand or claws -> draw a leg, adding a foot or claws
##   -> put it together -> name, size, favourite place -> two personality words
##   -> favourite food and toy (pick or draw) -> where it will live -> meet it at home.
##
## While a host (body, head, arm, leg) is being drawn, tapping an add-on opens that add-on's
## sheet with the host faint on it; finishing it comes back to the host with the add-on shown
## in place. The host's sheet is kept, not redrawn, while the add-on is drawn.
##
## Owns the pet being made. Nothing about the pet is saved until the end, so backing out half
## way leaves no half-made pet. (Things drawn for the family - food, toys - are kept.)

const HOST_LABELS := {"body": "the body", "head": "the head", "arm": "each arm", "leg": "each leg"}

var game: GameRoot
var pet := PetBuilder.new_pet()
var counts := PartPickerScreen.START.duplicate()
var current: Control

var _hosts: Array = []
var _step := 0
var _steps := 0
var _host_type := ""
var _host_screen: DrawScreen
var _pending := {}


func _ready() -> void:
	_pick_parts()


## Shows a step. With `keep`, the current step is hidden rather than thrown away - the head's
## sheet waits, drawing and all, while its horns are drawn.
func _show(screen: Control, keep := false) -> void:
	if current != null and current != screen:
		if keep:
			current.visible = false
		else:
			remove_child(current)
			current.queue_free()
	current = screen
	if screen.get_parent() == null:
		add_child(UI.full_rect(screen))
	screen.visible = true


func _pick_parts() -> void:
	var s := PartPickerScreen.new()
	s.counts = counts
	s.on_done = _on_parts_picked
	s.on_cancel = func(): game.go_home()
	_show(s)


func _markers() -> Dictionary:
	var out := {}
	for mode in Items.MARKERS:
		var n := game.profile.owned(Items.MARKERS[mode][0])
		if n > 0:
			out[mode] = n
	return out


## Uses up the shiny marker a drawing was made with, if it was.
func _spend_marker(r: Dictionary) -> Dictionary:
	var shine: Dictionary = r.get("shine", {})
	if not shine.is_empty():
		game.profile.use_up(Items.MARKERS[shine["mode"]][0])
	return shine


func _on_parts_picked(picked: Dictionary) -> void:
	counts = picked
	_hosts = ["body"]
	for t in PartTypes.MAIN:
		if int(counts.get(t, 0)) > 0:
			_hosts.append(t)
	_steps = _hosts.size()
	_step = 0
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
	_pending = {}
	_step += 1
	var info := PartTypes.info(_host_type)
	var n := 1 if _host_type == "body" else int(counts[_host_type])
	var s := DrawScreen.new()
	s.subject = _host_type
	s.prompt = info["prompt"] + (" You'll get %d of them." % n if n > 1 else "")
	s.step_text = "Step %d of %d" % [_step, _steps]
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
	s.on_addon = _start_addon
	s.on_remove_addon = _remove_addon
	s.on_done = _host_done
	var old := current
	_host_screen = s
	if old != null:
		remove_child(old)
		old.queue_free()
		current = null
	_show(s)


func _start_addon(type: String) -> void:
	var snap := await _host_screen.canvas.finish()
	if snap.is_empty():
		_host_screen._say("Draw %s first, then add things to it!" % HOST_LABELS[_host_type].trim_prefix("each "))
		return
	var info := PartTypes.info(type)
	var s := DrawScreen.new()
	s.subject = type
	s.prompt = info["prompt"]
	s.step_text = "Adding to %s" % HOST_LABELS[_host_type]
	s.ghost = PetBuilder.ghost_on(snap["image"], 1.0 / float(PartTypes.info(_host_type)["zoom"]), type, _host_type)
	s.dot = info["dot"]
	s.show_dot = true
	s.can_skip = true
	s.skip_text = "Back"
	s.count = int(_pending[type]["count"]) if _pending.has(type) else int(info.get("count", 1))
	s.count_max = int(info["max"])
	s.markers = _markers()
	s.on_done = func(r: Dictionary):
		if not r.is_empty():
			_pending[type] = {"count": int(r["count"]), "image": r["image"], "pivot": r["pivot"],
				"shine": _spend_marker(r)}
		_back_to_host()
	_show(s, true)


func _back_to_host() -> void:
	if current != null and current != _host_screen:
		remove_child(current)
		current.queue_free()
	current = _host_screen
	_host_screen.visible = true
	_refresh_host()


func _remove_addon(type: String) -> void:
	_pending.erase(type)
	_refresh_host()


## Updates the add-on buttons and shows each add-on in place on the drawing so far.
func _refresh_host() -> void:
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
			Transform2D(0.0, Vector2.ONE, 0.0, origin), 1.0)
		for spot in spots:
			previews.append({"texture": tex, "pos": spot["pos"], "pivot": a["pivot"],
				"scale": host_zoom / float(PartTypes.info(type)["zoom"]), "behind": spot["behind"]})
	_host_screen.set_previews(previews)


func _host_done(r: Dictionary) -> void:
	var shine := _spend_marker(r)
	if _host_type == "body":
		PetBuilder.set_body(pet, r["image"], shine)
	else:
		PetBuilder.add_parts(pet, _host_type, int(counts[_host_type]), r["image"], r["pivot"], shine, "body")
	for type in PartTypes.ORDER:
		if _pending.has(type):
			var a: Dictionary = _pending[type]
			PetBuilder.add_parts(pet, type, int(a["count"]), a["image"], a["pivot"], a["shine"], _host_type)
	_next_host()


# --- After drawing ---------------------------------------------------------------------------

func _assemble() -> void:
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
		_favourite("food")
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
	var first := game.profile.pet_count() == 1
	game.reward(10 if first else 5, "Welcome home, %s!" % pet["name"])
	game.go_place(home["id"], pet["id"], true)
