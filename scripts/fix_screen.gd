class_name FixScreen
extends Control
## Fixing up a pet after it is made (.ai/creature-pipeline.md): redraw a part (starting from
## the old drawing - draw on it, rub bits out, or clear it and start again), add a part, take
## a part off, move the parts about, and change its name, size, place, personality, favourites
## and voice.
##
## Everything changes the pet in memory; Done saves it, "Forget changes" leaves without saving,
## so the pet on disk is untouched until the kid is happy. A creature always keeps its body,
## eyes and a mouth (PetBuilder.remove_drawing).

var game: GameRoot
var pet: Dictionary
var on_done := Callable()

var current: Control
var _hint := ""
## Shiny markers used while fixing: mode -> true. Used up on Done.
var _markers_used := {}


func _ready() -> void:
	_hub()


func _show(screen: Control) -> void:
	if current != null:
		UI.retire(current)
	current = screen
	add_child(UI.full_rect(screen))


func _markers() -> Dictionary:
	var out := {}
	for mode in Items.MARKERS:
		var n := game.profile.owned(Items.MARKERS[mode][0])
		if n > 0:
			out[mode] = n
	return out


## Notes the shiny marker a drawing used: it lasts for all the fixing, and is used up on Done
## (never if the kid forgets their changes).
func _spend_marker(r: Dictionary) -> Dictionary:
	var used: String = r.get("used_marker", "")
	if used != "":
		_markers_used[used] = true
	return r.get("shine", {})


# --- The hub ---------------------------------------------------------------------------------

func _hub() -> void:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	root.add_child(UI.full_rect(UI.margin(row, 20)))

	var stage := UI.place_button(pet.get("place", "meadow"), "", Vector2(440, 640))
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.pressed.connect(func(): _creature.say("note"))
	row.add_child(stage)
	_creature = Creature.new()
	_creature.wander = false
	_creature.confine = false
	_creature.depth_scale = false
	stage.add_child(_creature)
	_creature.setup(pet, 300.0)
	var place := func(): _creature.position = Vector2(stage.size.x / 2.0, stage.size.y - 70.0)
	stage.resized.connect(place)
	place.call_deferred()

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 12)
	row.add_child(col)
	var top := HBoxContainer.new()
	top.add_child(UI.icon("ui_fix", 60))
	top.add_child(UI.title("Fix up %s" % pet["name"], 40))
	col.add_child(top)
	var hint := UI.label(_hint if _hint != "" else "Change anything you like. Tap Done to keep it.", 20, true)
	hint.add_theme_color_override("font_color", UI.ACCENT if _hint != "" else UI.INK_SOFT)
	col.add_child(hint)
	_hint = ""

	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	for entry in [["tool_crayon", "Redraw a part", redraw_list], ["ui_plus", "Add a part", add_host],
			["edit_remove", "Take a part off", remove_list], ["edit_layer", "Move parts", assemble],
			["ui_sign", "Name, size\n& place", details], ["icon_charm", "Personality", personality],
			["icon_food", "Favourites", favourites], ["snd_voice", "Its voice", voice]]:
		var b := UI.icon_button(entry[0], entry[1], entry[2], 64, Vector2(0, 150))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(b)
	col.add_child(grid)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	bottom.add_child(UI.icon_button("tool_undo", "Forget changes", func(): on_done.call(false), 40,
		Vector2(170, 90)))
	var done := UI.big_icon_button("tool_done", "Done!", press_done)
	done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(done)
	col.add_child(bottom)
	_show(root)


var _creature: Creature


func press_done() -> void:
	for mode in _markers_used:
		game.profile.use_up(Items.MARKERS[mode][0])
	PetStore.save_pet(pet, true)
	on_done.call(true)


# --- Picking a drawing -----------------------------------------------------------------------

## A grid of the pet's drawings, each a button calling `on_pick` with its entry.
func _drawing_grid(title_text: String, icon: String, on_pick: Callable, skip_body := false) -> void:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	root.add_child(UI.full_rect(UI.margin(col, 22)))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", _hub, 40, Vector2(100, 84)))
	top.add_child(UI.icon(icon, 60))
	top.add_child(UI.title(title_text, 38))
	col.add_child(top)
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 12)
	flow.add_theme_constant_override("v_separation", 12)
	for entry in PetBuilder.drawings(pet):
		if skip_body and entry["type"] == "body":
			continue
		var b := Button.new()
		b.custom_minimum_size = Vector2(180, 190)
		b.pressed.connect(on_pick.bind(entry))
		var pic := TextureRect.new()
		pic.texture = PetStore.texture(pet, entry["file"])
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pic.position = Vector2(20, 12)
		pic.size = Vector2(140, 124)
		b.add_child(pic)
		var label := PartTypes.label_for(entry["type"], int(entry["count"]))
		if int(entry["count"]) > 1:
			label = "%d %s" % [entry["count"], label]
		if entry["host"] != "" and entry["host"] != "body":
			label += "\non the %s" % PartTypes.info(entry["host"])["label"].to_lower()
		var l := UI.label(label, 17)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.position = Vector2(0, 138)
		l.size = Vector2(180, 48)
		b.add_child(l)
		flow.add_child(b)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(flow)
	col.add_child(scroll)
	_show(root)


# --- Redraw ----------------------------------------------------------------------------------

func redraw_list() -> void:
	_drawing_grid("Which part do you want to redraw?", "tool_crayon", redraw)


func redraw(entry: Dictionary) -> void:
	var type: String = entry["type"]
	var file: String = entry["file"]
	var part := {}
	for p in pet["parts"]:
		if p["image"] == file:
			part = p
			break
	var info := PartTypes.info(type)
	var s := DrawScreen.new()
	s.subject = type
	s.prompt = "Fix the %s! Draw on it, rub bits out with the eraser, or clear it and start again." % \
		PartTypes.label_for(type, int(entry["count"])).to_lower()
	s.step_text = "Fixing %s" % pet["name"]
	if type != "body" and entry["host"] != "":
		s.ghost = PetBuilder.ghost(pet, type, entry["host"])
	s.dot = info["dot"]
	s.show_dot = type != "body"
	s.can_skip = true
	s.skip_text = "Back"
	s.markers = _markers()
	s.start_image = pet["_img"][file]
	s.start_pivot = PetBuilder.v2(part["pivot"])
	var shine_file: String = part.get("shine_image", "")
	if shine_file != "" and pet["_img"].has(shine_file):
		s.start_shine = {"mode": part.get("shine", ""), "mask": pet["_img"][shine_file]}
	s.on_done = func(r: Dictionary):
		if r.is_empty():
			_hub()
			return
		PetBuilder.replace_drawing(pet, file, r["image"], r["pivot"], _spend_marker(r))
		_hint = "Looking good! Tap Move parts if anything needs nudging."
		_preview(type)
	_show(s)


# --- Add -------------------------------------------------------------------------------------

func add_host() -> void:
	var hosts := ["body"]
	for t in PartTypes.MAIN:
		if PetBuilder.has_type(pet, t):
			hosts.append(t)
	if hosts.size() == 1:
		add_type("body")
		return
	var root := _picker_root("Add a part to which bit?", "ui_plus")
	var flow: HFlowContainer = root.get_meta("flow")
	for host in hosts:
		var first: Dictionary = PetBuilder.parts_of(pet, host)[0]
		var b := Button.new()
		b.custom_minimum_size = Vector2(200, 200)
		b.pressed.connect(add_type.bind(host))
		var pic := TextureRect.new()
		pic.texture = PetStore.texture(pet, first["image"])
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pic.position = Vector2(20, 14)
		pic.size = Vector2(160, 140)
		b.add_child(pic)
		var l := UI.label("The " + PartTypes.info(host)["label"].to_lower(), 20)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.position = Vector2(0, 160)
		l.size = Vector2(200, 34)
		b.add_child(l)
		flow.add_child(b)
	_show(root)


func add_type(host: String) -> void:
	var types: Array = PartTypes.addons_for(host, PetBuilder.has_type(pet, "head"))
	if host == "body":
		types = PartTypes.MAIN + types
	var root := _picker_root("What are you adding to the %s?" % PartTypes.info(host)["label"].to_lower(), "ui_plus")
	var flow: HFlowContainer = root.get_meta("flow")
	for type in types:
		flow.add_child(UI.icon_button(PartTypes.icon(type), PartTypes.info(type)["plural"],
			add_draw.bind(host, type), 64, Vector2(140, 130)))
	_show(root)


func add_draw(host: String, type: String) -> void:
	var info := PartTypes.info(type)
	var s := DrawScreen.new()
	s.subject = type
	s.prompt = info["prompt"]
	s.step_text = "Adding to %s" % pet["name"]
	s.ghost = PetBuilder.ghost(pet, type, host)
	s.dot = info["dot"]
	s.show_dot = true
	s.can_skip = true
	s.skip_text = "Back"
	s.count = int(info.get("count", 1))
	s.count_max = int(info["max"])
	s.markers = _markers()
	s.on_done = func(r: Dictionary):
		if r.is_empty():
			_hub()
			return
		PetBuilder.add_parts(pet, type, int(r["count"]), r["image"], r["pivot"], _spend_marker(r), host)
		_hint = "Added! Tap Move parts to put it just where you want it."
		_preview(type)
	_show(s)


## The pet shows off the part just drawn (PartPreview), then it is back to the list.
func _preview(type: String) -> void:
	var p := PartPreview.new()
	p.pet = pet
	p.part_type = type
	p.on_done = _hub
	add_child(UI.full_rect(p))


func _picker_root(title_text: String, icon: String) -> Control:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	root.add_child(UI.full_rect(UI.margin(col, 22)))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", _hub, 40, Vector2(100, 84)))
	top.add_child(UI.icon(icon, 60))
	top.add_child(UI.title(title_text, 36))
	col.add_child(top)
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 12)
	flow.add_theme_constant_override("v_separation", 12)
	col.add_child(flow)
	root.set_meta("flow", flow)
	return root


# --- Take off --------------------------------------------------------------------------------

func remove_list() -> void:
	_drawing_grid("Which part do you want to take off?", "edit_remove", remove_ask, true)


func remove_ask(entry: Dictionary) -> void:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 18)
	root.add_child(UI.full_rect(UI.margin(col, 60)))
	var pic := TextureRect.new()
	pic.texture = PetStore.texture(pet, entry["file"])
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = Vector2(0, 260)
	col.add_child(pic)
	var what := PartTypes.label_for(entry["type"], int(entry["count"])).to_lower()
	var q := UI.title("Take off the %s?" % what, 40)
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(q)
	if PartTypes.MAIN.has(entry["type"]):
		var also := UI.label("Anything on them comes off too.", 22)
		also.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		also.add_theme_color_override("font_color", UI.INK_SOFT)
		col.add_child(also)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	row.add_child(UI.icon_button("tool_back", "Keep them", remove_list, 44, Vector2(200, 100)))
	var yes := UI.big_icon_button("edit_remove", "Take off", func(): remove_do(entry))
	yes.custom_minimum_size = Vector2(320, 100)
	row.add_child(yes)
	col.add_child(row)
	_show(root)


func remove_do(entry: Dictionary) -> void:
	var why := PetBuilder.remove_drawing(pet, entry["file"])
	_hint = why if why != "" else "Gone! You can always add something new."
	_hub()


# --- Everything else -------------------------------------------------------------------------

func assemble() -> void:
	var s := AssembleScreen.new()
	s.pet = pet
	s.on_done = _hub
	_show(s)


func details() -> void:
	var s := DetailsScreen.new()
	s.pet = pet
	s.profile = game.profile
	s.on_done = _hub
	_show(s)


func personality() -> void:
	var s := WordPickerScreen.new()
	s.category = "pet"
	s.question = "What is %s like?" % pet["name"]
	s.picked = pet.get("personality", []).duplicate()
	s.on_done = func(words: Array):
		pet["personality"] = words
		_hub()
	_show(s)


func favourites() -> void:
	var s := ItemPickerScreen.new()
	s.game = game
	s.category = "food"
	s.question = "What's %s's favourite food?" % pet["name"]
	s.on_done = func(id: String):
		pet["food"] = {"item": id}
		var t := ItemPickerScreen.new()
		t.game = game
		t.category = "toy"
		t.question = "And its favourite toy?"
		t.on_done = func(toy_id: String):
			pet["toy"] = {"item": toy_id}
			_hub()
		_show(t)
	_show(s)


func voice() -> void:
	var s := VoiceMakerScreen.new()
	s.game = game
	s.target = pet
	s.on_done = _hub
	_show(s)
