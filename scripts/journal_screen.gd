class_name JournalScreen
extends Control
## A pet's journal (Journal): a book that has been writing itself - the day it was drawn, its
## firsts, the tricks it learned, the cups it won, the presents it dug up - with its photos.

var game: GameRoot
var home_id := ""
var pet_id := ""

var pet: Dictionary


func _ready() -> void:
	pet = PetStore.load_pet(pet_id)
	Stats.ensure(pet)
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	UI.full_rect(col)
	col.offset_left = 16
	col.offset_top = 12
	col.offset_right = -16
	col.offset_bottom = -12
	add_child(col)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", go_back, 40, Vector2(100, 84)))
	var title := UI.title("%s's Journal" % pet["name"], 40)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	col.add_child(top)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)

	# The front page: its picture and the facts about it.
	var front := VBoxContainer.new()
	front.custom_minimum_size = Vector2(360, 0)
	front.add_theme_constant_override("separation", 6)
	body.add_child(front)
	var portrait := Control.new()
	portrait.custom_minimum_size = Vector2(360, 280)
	front.add_child(portrait)
	var c := Creature.new()
	c.wander = false
	c.confine = false
	c.depth_scale = false
	portrait.add_child(c)
	c.setup(pet)
	c.fit_in(Vector2(300, 230))
	c.position = Vector2(180, 272)
	for line in _facts():
		var l := UI.label(line, 20, true)
		l.custom_minimum_size = Vector2(360, 0)
		front.add_child(l)

	# The pages: newest first.
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var pages := VBoxContainer.new()
	pages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pages.add_theme_constant_override("separation", 14)
	scroll.add_child(pages)
	var entries := Journal.entries(pet)
	entries.reverse()
	for e in entries:
		pages.add_child(_entry(e))


func _facts() -> Array:
	var out := []
	var words: Array = pet.get("personality", [])
	if not words.is_empty():
		out.append(", ".join(words.map(func(w): return str(w).capitalize())) + ".")
	out.append("Dreams of %s." % Places.display_name(pet.get("place", "meadow")))
	var food := Items.get_item(str(pet.get("food", {}).get("item", "")))
	var toy := Items.get_item(str(pet.get("toy", {}).get("item", "")))
	if not food.is_empty() or not toy.is_empty():
		var loves := []
		for it in [food, toy]:
			if not it.is_empty():
				loves.append(Items.display_name(it))
		out.append("Loves: %s." % " and ".join(loves))
	var tricks := Tricks.known(pet)
	if not tricks.is_empty():
		out.append("Tricks: %s." % ", ".join(tricks.map(func(t): return Tricks.display_name(t))))
	var hearts := Stats.trust(pet)
	out.append("Trusts you: %d %s." % [hearts, "heart" if hearts == 1 else "hearts"])
	return out


func _entry(e: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var date := UI.label(Journal.date_text(int(e.get("t", 0))), 20)
	date.custom_minimum_size = Vector2(130, 0)
	date.add_theme_color_override("font_color", UI.INK_SOFT)
	row.add_child(date)
	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_col)
	var text := UI.label(str(e.get("text", "")), 24, true)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_child(text)
	var tex := Album.texture(str(e.get("photo", "")))
	if tex != null:
		var pic := TextureRect.new()
		pic.texture = tex
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		pic.custom_minimum_size = Vector2(320, 180)
		pic.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		text_col.add_child(pic)
	return row


func go_back() -> void:
	game.go_place(home_id, pet_id)
