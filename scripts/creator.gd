class_name Creator
extends Control
## Making a new pet, start to finish:
##   pick parts -> draw the body -> draw one of each part (eyes and a mouth always)
##   -> put it together -> name, size, favourite place -> two personality words
##   -> its favourite food (pick or draw) -> its favourite toy (pick or draw)
##   -> where it will live -> meet it at home.
##
## Owns the pet being made and swaps its own steps as children. Nothing about the pet is saved
## until the end, so backing out half way leaves no half-made pet behind. (Food and toys drawn
## along the way are kept - they are the family's, not the pet's.)

var game: GameRoot
var pet := PetBuilder.new_pet()
var counts := {"eye": 2, "mouth": 1}
var current: Control

var _queue: Array = []
var _step := 0
var _steps := 0


func _ready() -> void:
	_pick_parts()


func _show(screen: Control) -> void:
	if current != null:
		remove_child(current)
		current.queue_free()
	current = screen
	add_child(UI.full_rect(screen))


func _step_text() -> String:
	_step += 1
	return "Step %d of %d" % [_step, _steps]


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
	_queue.clear()
	for type in PartTypes.ORDER:
		if int(counts.get(type, 0)) > 0:
			_queue.append(type)
	_step = 0
	_steps = 1 + _queue.size()
	var s := _draw_screen("body", PartTypes.BODY["prompt"], {}, PartTypes.BODY["dot"], false, false)
	s.on_done = func(r: Dictionary):
		PetBuilder.set_body(pet, r["image"], _spend_marker(r))
		_next_part()
	_show(s)


func _draw_screen(subject: String, prompt: String, ghost: Dictionary, dot: Vector2,
		show_dot: bool, can_skip: bool) -> DrawScreen:
	var s := DrawScreen.new()
	s.subject = subject
	s.prompt = prompt
	s.step_text = _step_text()
	s.ghost = ghost
	s.dot = dot
	s.show_dot = show_dot
	s.can_skip = can_skip
	s.markers = _markers()
	return s


func _next_part() -> void:
	if _queue.is_empty():
		_assemble()
		return
	var type: String = _queue.pop_front()
	var info := PartTypes.info(type)
	var n := int(counts[type])
	var prompt: String = info["prompt"]
	if n > 1:
		prompt += " You'll get %d of them." % n
	var required := int(info.get("min", 0)) > 0
	var s := _draw_screen(type, prompt, PetBuilder.ghost(pet, type), info["dot"], true, not required)
	s.on_done = func(r: Dictionary):
		if not r.is_empty():
			PetBuilder.add_parts(pet, type, n, r["image"], r["pivot"], _spend_marker(r))
		_next_part()
	_show(s)


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
