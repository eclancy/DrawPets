class_name ShopScreen
extends Control
## Spending gold stars (.ai/shop.md). What is here is what a kid CANNOT just draw for
## themselves: shiny toys that train twice as fast, clothes, shiny markers, special furniture,
## special places, and room for more pets. Room to grow also needs trust - a kid earns a bigger
## family by looking after the one they have.

const TABS := [["adopt", "Adopt"], ["toy", "Shiny Toys"], ["clothing", "Clothes"],
	["supply", "Markers & Treats"], ["furniture", "Furniture"], ["places", "Places"],
	["room", "Room to Grow"]]

var game: GameRoot
var on_back := Callable()
var tab := "adopt"
var adopt_group: String = Adoptables.GROUPS[0]

var _grid: HFlowContainer
var _tab_buttons := {}
var _note: Label
var _meet: Control


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	add_child(UI.full_rect(UI.margin(col, 18)))

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", func(): on_back.call(), 40, Vector2(100, 84)))
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
		"adopt":
			_note.text = "Meet pets that need a home! Tap one to say hello."
			_adopt_cards()
		"places":
			_note.text = "Special places your pets can dream of - buy one and build a home there."
			for id in Places.ORDER:
				if Places.is_special(id):
					_grid.add_child(_place_card(id))
		"room":
			_note.text = "More room for more pets. Your pets need to trust you first!"
			_room_cards()
		_:
			var adv := game.profile.advanced()
			_note.text = {"toy": "Shiny toys sparkle - and train their stat TWICE as fast!" if adv
					else "Shiny toys sparkle and shine!",
				"clothing": "Dress your pets up. Clothes win points at the Style Show." if adv
					else "Dress your pets up - for the Costume Parade, or just for fun.",
				"supply": "A shiny marker draws one thing that shines forever. Treats boost training." if adv
					else "A shiny marker draws one thing that shines forever.",
				"furniture": "Fancy things for a home - pets play with them by their words."}[which]
			for id in Items.SHOP:
				var item: Dictionary = Items.SHOP[id]
				if item["category"] == which or (which == "supply" and item["category"] == "food"):
					# A Star Snack is a training boost - there is no training in Beginner.
					if not item.get("prize", false) and (adv or id != "star_snack"):
						_grid.add_child(_item_card(id))


# --- Adopt -----------------------------------------------------------------------------------

## Which of the family's pets it would get on with (Friends) - or that it would take its time.
func _would_get_on(pet: Dictionary) -> String:
	var best := []
	var slow := true
	for h in game.profile.homes():
		for id in h["pets"]:
			var mine := PetStore.load_pet(id)
			if mine.is_empty():
				continue
			var fit := Friends.fit(pet, mine)
			if fit >= 0.85:
				slow = false
			if fit >= 1.2:
				var why := Friends.why(pet, mine, 1)
				best.append("%s%s" % [mine["name"], (" (" + str(why[0]) + ")") if not why.is_empty() else ""])
	if not best.is_empty():
		return "Would get on with " + ", ".join(best.slice(0, 2)) + "."
	if slow and game.profile.pet_count() > 0:
		return "Would take its time making friends with your pets."
	return ""

func _adopt_cards() -> void:
	var tabs := HBoxContainer.new()
	tabs.custom_minimum_size = Vector2(1200, 0)
	tabs.add_theme_constant_override("separation", 8)
	var group := ButtonGroup.new()
	for g in Adoptables.GROUPS:
		var b := UI.button(Adoptables.GROUP_NAMES[g], _pick_group.bind(g), Vector2(0, 50), 19)
		b.toggle_mode = true
		b.button_group = group
		b.button_pressed = g == adopt_group
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(b)
	_grid.add_child(tabs)
	for id in Adoptables.ids_in(adopt_group):
		_grid.add_child(_adopt_card(id))


func _pick_group(g: String) -> void:
	adopt_group = g
	show_tab("adopt")


func _adopt_card(id: String) -> Button:
	var pet := Adoptables.build(id)
	var b := Button.new()
	b.custom_minimum_size = Vector2(228, 250)
	b.pressed.connect(meet.bind(id))
	var c := Creature.new()
	c.wander = false
	c.confine = false
	c.depth_scale = false
	c.position = Vector2(114, 168)
	b.add_child(c)
	c.setup(pet, 124.0)
	c.fit_in(Vector2(204, 130))
	var name := UI.label(pet["name"], 22)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.position = Vector2(0, 176)
	name.size = Vector2(228, 30)
	b.add_child(name)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.position = Vector2(0, 206)
	row.size = Vector2(228, 36)
	if game.profile.adopted().has(id):
		row.add_child(_tag("Lives with you!"))
	else:
		row.add_child(UI.icon("icon_star", 28, "none"))
		var l := UI.label(str(Adoptables.price(id)), 22)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(l)
	b.add_child(row)
	return b


## Meeting a pet: it bounces up to say hello, and you can see what it is like before adopting.
func meet(id: String) -> void:
	if _meet != null:
		_meet.queue_free()
	var pet := Adoptables.build(id)
	_meet = Control.new()
	add_child(UI.full_rect(_meet))
	var dim := ColorRect.new()
	dim.color = Color(0.23, 0.21, 0.4, 0.35)
	_meet.add_child(UI.full_rect(dim))
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(1060, 600)
	_meet.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	panel.add_child(row)

	var stage := Control.new()
	stage.custom_minimum_size = Vector2(420, 560)
	stage.clip_contents = true
	row.add_child(stage)
	var bg := UI.place_button(pet["place"], "", Vector2(420, 560))
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.size = Vector2(420, 560)
	stage.add_child(bg)
	var c := Creature.new()
	c.wander = false
	c.confine = false
	c.depth_scale = false
	c.position = Vector2(210, 470)
	stage.add_child(c)
	c.setup(pet, 260.0)
	c.fit_in(Vector2(370, 300))  # room to hop and greet without leaving the frame
	c.perform("greet", 2.0)
	c.say("hello")

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	row.add_child(col)
	var top := HBoxContainer.new()
	var title := UI.title(pet["name"], 46)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	top.add_child(UI.button("X", func(): _close_meet(), Vector2(56, 56), 24))
	col.add_child(top)
	var size_row := HBoxContainer.new()
	size_row.add_child(UI.icon("size_" + pet["size"], 54))
	var words: Array = Creature.SIZE_LABELS[pet["size"]]
	size_row.add_child(UI.label("%s - about as big as a %s" % [words[0], words[1]], 20))
	col.add_child(size_row)
	var traits := []
	for w in pet["personality"]:
		traits.append("%s (%s)" % [w, Words.hint("pet", w)])
	col.add_child(UI.label("Personality: " + ", ".join(traits), 20, true))
	col.add_child(UI.label("Loves %s." % Places.display_name(pet["place"]), 20))
	var likes := HBoxContainer.new()
	likes.add_child(UI.label("Favourites:", 20))
	for key in ["food", "toy"]:
		likes.add_child(UI.item_picture(Items.get_item(pet[key]["item"]), 56))
	col.add_child(likes)
	var getting_on := _would_get_on(pet)
	if getting_on != "":
		col.add_child(UI.label(getting_on, 20, true))
	for stat in (Stats.LIST if game.profile.advanced() else []):
		var srow := HBoxContainer.new()
		srow.add_child(UI.icon(Stats.INFO[stat]["icon"], 30))
		var sl := UI.label(Stats.label(stat), 17)
		sl.custom_minimum_size = Vector2(90, 0)
		srow.add_child(sl)
		var bar := ProgressBar.new()
		bar.max_value = Stats.MAX
		bar.value = Stats.value(pet, stat)
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 14)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.add_theme_stylebox_override("fill", UI._box(Color("#8fb4ef"), UI.INK, 0, 8, 0))
		srow.add_child(bar)
		col.add_child(srow)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)
	var price := Adoptables.price(id)
	if game.profile.adopted().has(id):
		col.add_child(_tag("%s already lives with you!" % pet["name"]))
	else:
		var gate := ""
		if not game.profile.can_add_pet():
			gate = "Every home is full - get more room first"
		var adopt := UI.big_icon_button("ui_adopt", "Adopt for %d stars" % price, func(): game.adopt(id))
		if gate != "" or game.profile.stars() < price:
			adopt.disabled = true
			var why := UI.label(gate if gate != "" else "You need %d more stars" % (price - game.profile.stars()), 18)
			why.add_theme_color_override("font_color", UI.ACCENT)
			col.add_child(why)
		col.add_child(adopt)


func _close_meet() -> void:
	if _meet != null:
		_meet.queue_free()
		_meet = null


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
				Sounds.play("buy")
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
				Sounds.play("buy")
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
					Sounds.play("buy")
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
	Sounds.play("shiny" if Items.SHOP[id].get("shine", "") != "" else "buy")
	game.toast("Bought the %s!" % Items.SHOP[id]["name"], "icon_shop")
	show_tab(tab)
