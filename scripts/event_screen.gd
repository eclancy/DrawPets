class_name EventScreen
extends Control
## Entering a competition: pick a pet and a cup. A cup opens when the pet's stat for the event
## reaches its level, so the kid can always enter something and can see what to train for.
## On Fun Fair day (Sunday) they pick any event to practise.

var game: GameRoot
var event: Dictionary

var _kind := ""
var _tier := 0
var _pet_id := ""
var _pets: Array = []
var _content: Control


func _ready() -> void:
	for h in game.profile.homes():
		for id in h["pets"]:
			var pet := PetStore.load_pet(id)
			if not pet.is_empty():
				Stats.ensure(pet)
				_pets.append(pet)
	if event["kind"] == "fair":
		_choose_kind()
	else:
		_kind = event["kind"]
		_build()


func _swap(c: Control) -> void:
	if _content != null:
		remove_child(_content)
		_content.queue_free()
	_content = c
	add_child(UI.full_rect(c))


func _choose_kind() -> void:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	root.add_child(UI.full_rect(UI.margin(col, 24)))
	var top := HBoxContainer.new()
	top.add_child(UI.button("Back", func(): game.go_calendar(), Vector2(120, 64), 24))
	var heading := UI.title("Fun Fair! Practise any event", 40)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	col.add_child(top)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for kind in Events.KINDS:
		var b := UI.icon_button(Events.icon(kind), Events.info(kind)["name"], _pick_kind.bind(kind), 72,
			Vector2(0, 160))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(b)
	col.add_child(grid)
	_swap(root)


func _build() -> void:
	var info := Events.info(_kind)
	var stat: String = info["stat"]
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	root.add_child(UI.full_rect(UI.margin(col, 20)))

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.button("Back", func(): game.go_calendar(), Vector2(120, 64), 24))
	top.add_child(UI.icon(Stats.INFO[stat]["icon"], 64))
	var heading := UI.title(info["name"] + (" (practice)" if event["kind"] == "fair" else ""), 42)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	top.add_child(UI.star_counter(game.profile, 44))
	col.add_child(top)
	col.add_child(UI.label("%s  -  uses %s." % [info["how"], Stats.label(stat)], 22, true))

	col.add_child(UI.label("Who's competing?", 24))
	var pets_row := HBoxContainer.new()
	pets_row.add_theme_constant_override("separation", 10)
	var pet_group := ButtonGroup.new()
	for pet in _pets:
		var b := Button.new()
		b.toggle_mode = true
		b.button_group = pet_group
		b.custom_minimum_size = Vector2(170, 190)
		var c := Creature.new()
		c.wander = false
		c.confine = false
		c.depth_scale = false
		c.position = Vector2(85, 140)
		b.add_child(c)
		c.setup(pet, 100.0)
		var l := UI.label("%s\n%s Lv%d" % [pet["name"], Stats.label(stat), Stats.level(Stats.value(pet, stat))], 17)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.position = Vector2(0, 142)
		l.size = Vector2(170, 46)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(l)
		b.pressed.connect(func():
			_pet_id = pet["id"]
			_build())
		b.button_pressed = pet["id"] == _pet_id
		pets_row.add_child(b)
	if _pets.is_empty():
		pets_row.add_child(UI.label("Draw a pet first!", 24))
	col.add_child(pets_row)

	col.add_child(UI.label("Which cup?", 24))
	var tiers := HBoxContainer.new()
	tiers.add_theme_constant_override("separation", 10)
	var chosen := _chosen_pet()
	for t in Events.TIERS.size():
		var tier: Dictionary = Events.TIERS[t]
		var open := chosen.is_empty() or Events.tier_open(chosen, _kind, t)
		var prize: Array = tier["prize"]
		var text := "%s\nneeds %s Lv%d\n1st: %d stars" % [tier["name"], Stats.label(stat), int(tier["level"]), prize[0]]
		var b := UI.button(text, _pick_tier.bind(t), Vector2(0, 110), 19)
		b.toggle_mode = true
		b.button_pressed = t == _tier
		b.disabled = not open
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var done := int(game.profile.data["results"].get(Events.result_key(_event(), t), 0))
		if done > 0 and done <= 3:
			var r := UI.icon("icon_ribbon_%d" % done, 40, "none")
			r.position = Vector2(6, 6)
			b.add_child(r)
		tiers.add_child(b)
	col.add_child(tiers)

	var go := UI.big_button("Go!", func(): game.go_competition(_event(), _tier, _pet_id))
	go.disabled = chosen.is_empty() or not Events.tier_open(chosen, _kind, _tier)
	col.add_child(go)
	_swap(root)


func _pick_kind(kind: String) -> void:
	_kind = kind
	_build()


func _pick_tier(t: int) -> void:
	_tier = t
	_build()


func _chosen_pet() -> Dictionary:
	for pet in _pets:
		if pet["id"] == _pet_id:
			return pet
	if not _pets.is_empty() and _pet_id == "":
		_pet_id = _pets[0]["id"]
		return _pets[0]
	return {}


func _event() -> Dictionary:
	var e := event.duplicate()
	e["practice"] = event["kind"] == "fair"
	e["kind"] = _kind
	return e
