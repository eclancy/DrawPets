class_name ShopScreen
extends Control
## Spending gold stars (.ai/shop.md). What is here is what a kid CANNOT just draw for
## themselves: shiny toys that train twice as fast, clothes, shiny markers, special furniture,
## special places, and room for more pets. Room to grow also needs trust - a kid earns a bigger
## family by looking after the one they have.

const TABS := [["toy", "Shiny Toys"], ["clothing", "Clothes"], ["supply", "Markers & Treats"],
	["furniture", "Furniture"], ["places", "Places"], ["room", "Room to Grow"]]

var game: GameRoot
var on_back := Callable()
var tab := "toy"

var _grid: HFlowContainer
var _tab_buttons := {}
var _note: Label


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	add_child(UI.full_rect(UI.margin(col, 18)))

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.button("Back", func(): on_back.call(), Vector2(120, 64), 24))
	top.add_child(UI.icon("icon_shop", 60))
	var heading := UI.title("The Shop", 44)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	top.add_child(UI.star_counter(game.profile, 48))
	col.add_child(top)

	var tabs := HBoxContainer.new()
	var group := ButtonGroup.new()
	for t in TABS:
		var b := UI.button(t[1], show_tab.bind(t[0]), Vector2(0, 56), 20)
		b.toggle_mode = true
		b.button_group = group
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_tab_buttons[t[0]] = b
		tabs.add_child(b)
	col.add_child(tabs)
	_note = UI.label("", 20)
	_note.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(_note)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_grid = HFlowContainer.new()
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(_grid)
	show_tab(tab)


func show_tab(which: String) -> void:
	tab = which
	_tab_buttons[which].button_pressed = true
	for c in _grid.get_children():
		c.queue_free()
	match which:
		"places":
			_note.text = "Special places your pets can dream of - buy one and build a home there."
			for id in Places.ORDER:
				if Places.is_special(id):
					_grid.add_child(_place_card(id))
		"room":
			_note.text = "More room for more pets. Your pets need to trust you first!"
			_room_cards()
		_:
			_note.text = {"toy": "Shiny toys sparkle - and train their stat TWICE as fast!",
				"clothing": "Dress your pets up. Clothes win points at the Style Show.",
				"supply": "A shiny marker draws one thing that shines forever. Treats boost training.",
				"furniture": "Fancy things for a home - pets play with them by their words."}[which]
			for id in Items.SHOP:
				var item: Dictionary = Items.SHOP[id]
				if item["category"] == which or (which == "supply" and item["category"] == "food"):
					if not item.get("prize", false):
						_grid.add_child(_item_card(id))


func _card_base() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 4)
	return col


func _item_card(id: String) -> PanelContainer:
	var item := Items.get_item(id)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(196, 0)
	var col := _card_base()
	panel.add_child(col)
	var pic := UI.item_picture(item, 120)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(pic)
	var name := UI.label(item["name"], 21)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(name)
	var words := UI.label(item.get("note", ", ".join(item.get("words", []))), 15, true)
	words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words.add_theme_color_override("font_color", UI.INK_SOFT)
	words.custom_minimum_size = Vector2(176, 0)
	col.add_child(words)
	var price := int(item["price"])
	var consumable := int(item.get("uses", 0)) > 0
	var have := game.profile.owned(id)
	if have > 0 and not consumable:
		col.add_child(_tag("Yours!"))
	else:
		if consumable and have > 0:
			col.add_child(_tag("You have %d" % have))
		col.add_child(_buy_button(price, func(): _buy_item(id, price), ""))
	return panel


func _place_card(id: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var col := _card_base()
	panel.add_child(col)
	var b := UI.place_button(id, Places.display_name(id), Vector2(260, 160), not game.profile.place_unlocked(id))
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(b)
	var words := UI.label(", ".join(Places.tags(id)), 16)
	words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(words)
	var price := int(Places.get_place(id).get("price", 100))
	if game.profile.place_unlocked(id):
		col.add_child(_tag("Yours!"))
	else:
		var buy := func():
			if game.profile.spend(price):
				game.profile.unlock_place(id)
				game.toast("%s is yours! Build a home there for your next pet." % Places.display_name(id), "icon_home")
				show_tab(tab)
		col.add_child(_buy_button(price, buy, ""))
	return panel


func _room_cards() -> void:
	var p := game.profile
	var all_pets := []
	for h in p.homes():
		for pid in h["pets"]:
			var pet := PetStore.load_pet(pid)
			if not pet.is_empty():
				all_pets.append(pet)
	# A new home plot.
	var plot := PanelContainer.new()
	plot.custom_minimum_size = Vector2(300, 0)
	var col := _card_base()
	plot.add_child(col)
	col.add_child(UI.icon("icon_home", 90))
	col.add_child(UI.label("New home plot", 22))
	col.add_child(UI.label("You have %d of %d" % [p.home_slots(), Profile.MAX_HOMES], 16))
	var price := p.next_home_price()
	if price < 0:
		col.add_child(_tag("All the land is yours!"))
	else:
		var gate := Profile.trust_gate(all_pets, p.next_home_trust())
		var buy := func():
			if game.profile.spend(price):
				game.profile.data["home_slots"] = game.profile.home_slots() + 1
				game.profile.save()
				game.toast("A new plot! Your next pet can build a home there.", "icon_home")
				show_tab(tab)
		col.add_child(_buy_button(price, buy, gate))
	_grid.add_child(plot)
	# An extra room in each home.
	for h in p.homes():
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(300, 0)
		var c := _card_base()
		panel.add_child(c)
		var b := UI.place_button(h["place"], Places.display_name(h["place"]), Vector2(260, 120))
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(b)
		c.add_child(UI.label("Rooms: %d of %d" % [int(h["rooms"]), Profile.MAX_ROOMS], 18))
		var rp := p.next_room_price(h)
		if rp < 0:
			c.add_child(_tag("Full size!"))
		else:
			var home_pets := []
			for pet in all_pets:
				if h["pets"].has(pet["id"]):
					home_pets.append(pet)
			var gate := Profile.trust_gate(home_pets, p.next_room_trust(h))
			var buy := func():
				if game.profile.spend(rp):
					h["rooms"] = int(h["rooms"]) + 1
					game.profile.save()
					game.toast("%s has room for one more!" % Places.display_name(h["place"]), "icon_home")
					show_tab(tab)
			c.add_child(_buy_button(rp, buy, gate))
		_grid.add_child(panel)


## A price button. Disabled, with the reason under it, when it cannot be bought yet.
func _buy_button(price: int, on_buy: Callable, gate: String) -> Control:
	var col := VBoxContainer.new()
	var b := Button.new()
	b.custom_minimum_size = Vector2(150, 56)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full_rect(row)
	var star := UI.icon("icon_star", 32, "none")
	row.add_child(star)
	var l := UI.label(str(price), 24)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
	b.add_child(row)
	col.add_child(b)
	if gate != "":
		b.disabled = true
		var why := UI.label(gate, 15, true)
		why.custom_minimum_size = Vector2(176, 0)
		why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		why.add_theme_color_override("font_color", UI.ACCENT)
		col.add_child(why)
	elif game.profile.stars() < price:
		b.disabled = true
		var need := UI.label("Need %d more" % (price - game.profile.stars()), 15)
		need.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		need.add_theme_color_override("font_color", UI.INK_SOFT)
		col.add_child(need)
	else:
		b.pressed.connect(on_buy)
	return col


func _tag(text: String) -> Label:
	var l := UI.label(text, 20)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_color", UI.GOOD.darkened(0.3))
	return l


func _buy_item(id: String, price: int) -> void:
	if not game.profile.spend(price):
		return
	game.profile.give(id)
	game.toast("Bought the %s!" % Items.SHOP[id]["name"], "icon_shop")
	show_tab(tab)
