class_name HomeScreen
extends Control
## The front door: every home the family has built - painted with its house, its things and its
## pets alive inside it - the gold stars, and the way to the shop, the competition calendar and
## a new pet. An empty plot builds a ready-made home (BuildHomeScreen); a locked plot goes to the
## shop.

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
	top.add_child(UI.icon_button("ui_settings", "Settings", func(): game.go_settings(), 48, Vector2(96, 96)))
	col.add_child(top)

	var p := game.profile
	if p.homes().is_empty():
		var sub := UI.label("Build a home on a plot, then draw a pet - or adopt one in the shop!", 24)
		sub.add_theme_color_override("font_color", UI.INK_SOFT)
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
	for i in p.free_plots():
		flow.add_child(_plot_card("Empty plot\nTap to build a home!", false))
	if p.home_slots() < Profile.MAX_HOMES:
		flow.add_child(_plot_card("More land\nin the shop", true))

	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 16)
	var new_pet := UI.big_icon_button("tool_crayon", "Draw a new pet", func(): game.start_creator())
	new_pet.custom_minimum_size = Vector2(420, 90)
	new_pet.disabled = not p.can_add_pet()
	bottom.add_child(new_pet)
	if not p.can_add_pet():
		var why := UI.label("Every home is full - earn stars and trust,\nthen get more room in the shop!", 20)
		why.add_theme_color_override("font_color", UI.INK_SOFT)
		bottom.add_child(why)
	col.add_child(bottom)


func _home_card(h: Dictionary) -> Button:
	var caption := "%s   %d/%d" % [Profile.home_name(h), h["pets"].size(), int(h["rooms"])]
	var card := UI.place_button(h["place"], caption, Vector2(400, 250), false, h.get("items", []))
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
		creature.position = Vector2(400.0 * (i + 1) / (n + 1), 215)
		card.add_child(creature)
		creature.setup(pet, 110.0 if n <= 2 else 84.0)
		if i % 2 == 1:
			creature.facing = -1.0
	return card


func _plot_card(text: String, locked: bool) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(250, 250)
	b.add_theme_stylebox_override("normal", UI._box(Color(1, 1, 1, 0.35), UI.INK_SOFT, 3))
	b.text = "\n\n" + text
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", UI.INK_SOFT)
	var pic := UI.icon("icon_lock" if locked else "ui_build", 64)
	pic.position = Vector2(93, 34)
	b.add_child(pic)
	if locked:
		b.pressed.connect(func(): game.go_shop())
	else:
		b.pressed.connect(func(): game.go_build_home())
	return b
