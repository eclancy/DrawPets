class_name HomeScreen
extends Control
## The front door: every home the family has, each painted with its pets alive inside it, the
## gold stars, and the way to the shop, the competition calendar and a new pet. Empty plots
## show where a new home can go; locked plots show there is more to earn.

var game: GameRoot


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	add_child(UI.full_rect(UI.margin(col, 20)))

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	var heading := UI.title("DrawPets", 58)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	top.add_child(UI.star_counter(game.profile, 48))
	top.add_child(UI.icon_button("icon_shop", "Shop", func(): game.go_shop(), 48, Vector2(96, 96)))
	top.add_child(UI.icon_button("icon_calendar", "Events", func(): game.go_calendar(), 48, Vector2(96, 96)))
	col.add_child(top)

	var p := game.profile
	if p.pet_count() == 0:
		var sub := UI.label("Draw a creature. Bring it to life. Look after it.", 26)
		col.add_child(sub)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.add_theme_constant_override("h_separation", 14)
	flow.add_theme_constant_override("v_separation", 14)
	scroll.add_child(flow)
	for h in p.homes():
		flow.add_child(_home_card(h))
	for i in p.home_slots() - p.homes().size():
		flow.add_child(_plot_card("Empty plot\nA new pet can build a home here", false))
	if p.home_slots() < Profile.MAX_HOMES:
		flow.add_child(_plot_card("More land\nin the shop", true))

	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 16)
	var new_pet := UI.big_button("+ Draw a new pet", func(): game.start_creator())
	new_pet.custom_minimum_size = Vector2(420, 90)
	new_pet.disabled = not p.can_add_pet()
	bottom.add_child(new_pet)
	if not p.can_add_pet():
		var why := UI.label("Every home is full - earn stars and trust,\nthen get more room in the shop!", 20)
		why.add_theme_color_override("font_color", UI.INK_SOFT)
		bottom.add_child(why)
	col.add_child(bottom)


func _home_card(h: Dictionary) -> Button:
	var caption := "%s   %d/%d" % [Places.display_name(h["place"]), h["pets"].size(), int(h["rooms"])]
	var card := UI.place_button(h["place"], caption, Vector2(400, 250))
	card.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	card.pressed.connect(func(): game.go_place(h["id"]))
	var n: int = h["pets"].size()
	for i in n:
		var pet := PetStore.load_pet(h["pets"][i])
		if pet.is_empty() or pet["parts"].is_empty():
			continue
		var creature := Creature.new()
		creature.wander = false
		creature.confine = false
		creature.depth_scale = false
		creature.position = Vector2(400.0 * (i + 1) / (n + 1), 205)
		card.add_child(creature)
		creature.setup(pet, 120.0 if n <= 2 else 90.0)
		if i % 2 == 1:
			creature.facing = -1.0
	return card


func _plot_card(text: String, locked: bool) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(250, 250)
	b.add_theme_stylebox_override("normal", UI._box(Color(1, 1, 1, 0.35), UI.INK_SOFT, 3))
	b.text = text
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", UI.INK_SOFT)
	if locked:
		b.pressed.connect(func(): game.go_shop())
		var lock := UI.icon("icon_lock", 48)
		lock.position = Vector2(101, 20)
		b.add_child(lock)
	else:
		b.pressed.connect(func(): game.start_creator())
	return b
