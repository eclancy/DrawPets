class_name FunDayScreen
extends Control
## Joining in a Beginner fun day (FunDays): what today is, who's coming - then off to the stage,
## the walk, the bath or the home it happens in. No cups, no scores.

var game: GameRoot
var event: Dictionary


func _ready() -> void:
	var info := FunDays.info(event["kind"])
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	add_child(UI.full_rect(UI.margin(col, 24)))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", func(): game.go_calendar(), 40, Vector2(100, 84)))
	top.add_child(UI.icon(info["icon"], 64, "none"))
	var heading := UI.title(info["name"], 44)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	col.add_child(top)
	col.add_child(UI.label(info["how"] + "  Everyone who joins in gets a rosette!", 26, true))
	col.add_child(UI.label("Who's coming?", 26))
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 12)
	row.add_theme_constant_override("v_separation", 12)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(row)
	var any := false
	for h in game.profile.homes():
		for id in h["pets"]:
			var pet := PetStore.load_pet(id)
			if pet.is_empty():
				continue
			any = true
			row.add_child(_pet_button(pet))
	if not any:
		row.add_child(UI.label("Draw a pet first - or adopt one in the shop!", 26))


func _pet_button(pet: Dictionary) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(200, 220)
	b.pressed.connect(go.bind(pet["id"]))
	var c := Creature.new()
	c.wander = false
	c.confine = false
	c.depth_scale = false
	b.add_child(c)
	c.setup(pet)
	c.fit_in(Vector2(160, 150))
	c.position = Vector2(100, 172)
	var l := UI.label(pet["name"], 22)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, 182)
	l.size = Vector2(200, 34)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(l)
	return b


## Off it goes, to wherever today's fun happens.
func go(pet_id: String) -> void:
	var home := FunDays.home_of(game.profile, pet_id)
	if home.is_empty():
		return
	match event["kind"]:
		"party", "photo":
			game.go_place(home["id"], pet_id, false, event["kind"])
		"treasure":
			game.go_walk(home["id"], pet_id, true)
		"spa":
			game.go_bath(home["id"], pet_id, true)
		_:
			game.go_stage(event["kind"], home["id"], pet_id)


func go_back() -> void:
	game.go_calendar()
