class_name PlaceScreen
extends Node2D
## A home: a favourite place, the pets who live there, and whatever the kid has put in it.
## The Nintendogs part of the game (.ai/pet-life.md).
##
##   Rub a pet         -> hearts, trust, charm. Tap it to see how it is doing.
##   Tap the ground    -> it comes over.
##   Food drawer       -> drag a snack out; the hungriest pet trots over and munches it.
##   Toys drawer       -> fling a toy; everyone chases, the fastest brings it back. Hold a
##                        stretchy toy by a pet's mouth for tug of war.
##   Decorate drawer   -> drag furniture in, drag it about, drag it back to put it away.
##   Wardrobe drawer   -> drag clothes onto a pet.
## Left alone, pets use the furniture by its words: nap on cozy things, bounce on bouncy ones.
## Every kind of play trains a stat (Stats), and milestones pay gold stars (GameRoot.reward).

const ZOOM := {"tiny": 1.5, "small": 1.2, "medium": 1.0, "big": 0.9, "huge": 0.78, "giant": 0.66}
const TABS := [["food", "icon_pantry", "Food"], ["toy", "icon_toys", "Toys"],
	["furniture", "icon_decorate", "Decorate"], ["clothing", "icon_wardrobe", "Wardrobe"]]
## Where pets walk. It stops short of the screen's bottom edge, which the drawer bar covers -
## the camera sits CAM_DROP lower so the whole band shows above the bar.
const GROUND := Rect2(70, 458, 1140, 172)
const CAM_DROP := 56.0

var game: GameRoot
var home: Dictionary
var focus_id := ""
var first_visit := false

var pets: Array = []
var creatures: Array[Creature] = []
var furniture: Array[Furniture] = []
var world: Node2D
var food: PlaceItem
var toy: PlaceItem
var tab := ""

var _place: Dictionary
var _cam: Camera2D
var _follow: Creature
var _held: Node2D
var _held_kind := ""
var _held_item := {}
var _samples: Array = []
var _petting: Creature
var _pet_last := Vector2.ZERO
var _pet_dist := 0.0
var _fetch := ""
var _fetcher: Creature
var _chasers: Array = []
var _leapt: Array = []
var _caught_in_air := false
var _eater: Creature
var _told_full := false
var _tug: Creature
var _tug_time := 0.0
## Where the finger holding something is, in world space - set by every drag event, so tug of
## war follows the finger rather than wherever a mouse cursor happens to be.
var _finger := Vector2.ZERO
var _selected: Furniture
var _drawer: HBoxContainer
var _tab_buttons := {}
var _panel: PetPanel
var _panel_pet: Creature
var _hint: Label
var _hint_time := 8.0
var _save_in := 10.0
var _ai_in := 1.5
var _squeak_in := 0.0


func _ready() -> void:
	_place = Places.get_place(home["place"])
	var painter := PlacePainter.new()
	painter.place_id = home["place"]
	add_child(painter)
	world = Node2D.new()
	world.y_sort_enabled = true
	add_child(world)

	for entry in home.get("items", []):
		_spawn_furniture(entry)
	var biggest := 1.5
	for id in home["pets"]:
		var pet := PetStore.load_pet(id)
		if pet.is_empty() or pet["parts"].is_empty():
			continue
		var hours := PetStore.catch_up(pet)
		Stats.ensure(pet)
		pet["_hours"] = hours
		pets.append(pet)
		var c := Creature.new()
		c.bounds = GROUND
		c.in_water = _place.get("water", false)
		c.position = Vector2(randf_range(300, 980), randf_range(500, 610))
		world.add_child(c)
		c.setup(pet)
		c.emote.connect(_on_emote)
		creatures.append(c)
		biggest = minf(biggest, ZOOM.get(pet.get("size", "medium"), 1.0))

	_cam = Camera2D.new()
	var zoom := biggest if not pets.is_empty() else 1.0
	_cam.zoom = Vector2(zoom, zoom)
	_cam.position = Vector2(640, 360 + CAM_DROP)
	if zoom > 1.01:
		_follow = _focus_creature()
		_cam.limit_left = 0
		_cam.limit_top = 0
		_cam.limit_right = 1280
		_cam.limit_bottom = 720 + int(CAM_DROP)
		_cam.position_smoothing_enabled = true
		_cam.position_smoothing_speed = 4.0
	add_child(_cam)
	_cam.make_current()

	_build_hud()
	_drop_daily_snacks()
	_greet()


func _focus_creature() -> Creature:
	for c in creatures:
		if c.pet["id"] == focus_id:
			return c
	return creatures[0] if not creatures.is_empty() else null


func _greet() -> void:
	game.reward_daily("visit_" + home["id"], 1, 3, "Daily visit!")
	var focus := _focus_creature()
	if focus == null:
		_show_hint("Nobody lives here yet - draw a pet and move it in!")
		return
	if first_visit:
		_show_hint("Welcome home, %s! Rub it to pet it. Open a drawer to feed it, play, decorate or dress up." % focus.pet["name"])
		focus.perform("celebrate", 1.8)
		for i in 3:
			_on_emote("heart", focus.top_global() + Vector2(randf_range(-30, 30), 0))
		return
	var missed := false
	for c in creatures:
		if float(c.pet.get("_hours", 0.0)) > 6.0:
			c.perform("greet", 2.0)
			c.say("heart")
			missed = true
		if Places.liking(c.pet["place"], home["place"]) >= 1.0 and randf() < 0.5:
			c.say("star")
	_show_hint("They missed you!" if missed else "Rub a pet to pet it. Tap a pet to see how it's doing.")


# --- HUD -------------------------------------------------------------------------------------

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(UI.full_rect(root))

	var home_btn := UI.icon_button("icon_home", "Home", func(): game.go_home(), 40, Vector2(92, 84))
	home_btn.position = Vector2(12, 12)
	root.add_child(home_btn)

	var title := UI.title("%s  -  %d of %d rooms" % [Places.display_name(home["place"]), home["pets"].size(),
		int(home["rooms"])], 30)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.offset_top = 16
	root.add_child(title)

	var right := HBoxContainer.new()
	right.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	right.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	right.offset_right = -12
	right.offset_top = 12
	right.add_theme_constant_override("separation", 10)
	right.add_child(UI.star_counter(game.profile, 40))
	right.add_child(UI.icon_button("icon_shop", "Shop", func(): game.go_shop(func(): game.go_place(home["id"])),
		40, Vector2(84, 84)))
	right.add_child(UI.icon_button("icon_calendar", "Events", func(): game.go_calendar(), 40, Vector2(84, 84)))
	root.add_child(right)

	_hint = UI.title("", 22)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_hint.offset_left = -330
	_hint.offset_right = 330
	_hint.offset_top = 60
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_hint)

	_panel = PetPanel.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.offset_right = -12
	_panel.offset_top = 104
	_panel.visible = false
	_panel.on_close = func(): _panel.visible = false
	_panel.on_take_off = _take_off_clothes
	root.add_child(_panel)

	var bar := PanelContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bar.offset_top = -118
	bar.add_theme_stylebox_override("panel", UI._box(Color(1, 0.99, 0.96, 0.92), UI.INK, 3, 18, 8))
	root.add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bar.add_child(row)
	for t in TABS:
		var b := UI.icon_button(t[1], t[2], open_tab.bind(t[0]), 52, Vector2(100, 104))
		b.toggle_mode = true
		_tab_buttons[t[0]] = b
		row.add_child(b)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	row.add_child(scroll)
	_drawer = HBoxContainer.new()
	_drawer.add_theme_constant_override("separation", 8)
	scroll.add_child(_drawer)
	_fill_drawer()


func open_tab(which: String) -> void:
	tab = "" if tab == which else which
	for t in _tab_buttons:
		_tab_buttons[t].set_pressed_no_signal(t == tab)
	_select_furniture(null)
	_fill_drawer()


func _fill_drawer() -> void:
	for c in _drawer.get_children():
		c.queue_free()
	if tab == "":
		var l := UI.label("Open a drawer: Food, Toys, Decorate or Wardrobe.", 22)
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_drawer.add_child(l)
		return
	if tab == "furniture" and _selected != null:
		for entry in [["Bigger", func(): _resize_selected(1.15)], ["Smaller", func(): _resize_selected(1.0 / 1.15)],
				["Flip", _flip_selected], ["Put away", _remove_selected], ["Done", func(): _select_furniture(null)]]:
			_drawer.add_child(UI.button(entry[0], entry[1], Vector2(110, 96), 22))
		return
	var back_here := func(_item: Dictionary): game.go_place(home["id"], focus_id)
	var draw_new := func(): game.make_item(tab, back_here)
	var draw := UI.icon_button("icon_draw", "Draw", draw_new, 52, Vector2(96, 96))
	draw.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.INK, 3))
	_drawer.add_child(draw)
	var ids := Items.available(game.profile, tab)
	if tab == "clothing" and ids.is_empty():
		_drawer.add_child(UI.button("Get clothes in the shop!", func(): game.go_shop(func(): game.go_place(home["id"])),
			Vector2(0, 96), 22))
	for id in ids:
		var item := Items.get_item(id)
		if int(item.get("uses", 0)) > 0 and game.profile.owned(id) <= 0:
			continue
		var b := Button.new()
		b.custom_minimum_size = Vector2(96, 96)
		b.tooltip_text = Items.display_name(item)
		var pic := UI.item_picture(item, 80)
		pic.position = Vector2(8, 8)
		b.add_child(pic)
		if int(item.get("uses", 0)) > 0:
			var n := UI.title("x%d" % game.profile.owned(id), 18)
			n.position = Vector2(56, 64)
			b.add_child(n)
		b.button_down.connect(_grab.bind(id))
		_drawer.add_child(b)


func _show_hint(text: String) -> void:
	_hint.text = text
	_hint.modulate.a = 1.0
	_hint_time = 7.0


func _show_panel(c: Creature) -> void:
	_panel_pet = c
	_panel.show_pet(c.pet)
	_panel.visible = true
	focus_id = c.pet["id"]


# --- Input -----------------------------------------------------------------------------------

## Drags that start on a drawer button arrive at the button, not the world - read them here,
## before the GUI does.
func _input(event: InputEvent) -> void:
	if _held == null:
		return
	if event is InputEventMouseMotion:
		_move_held(get_global_mouse_position())
	elif event is InputEventMouseButton and not event.pressed:
		_drop_held(get_global_mouse_position(), get_viewport().get_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if _held != null:
		return
	var at := get_global_mouse_position()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			_petting = null
			return
		if tab == "furniture":
			var f := _furniture_at(at)
			if f != null:
				_select_furniture(f)
				_held = f
				_held_kind = "move"
				return
			_select_furniture(null)
		var c := _creature_at(at)
		if c != null:
			_petting = c
			_pet_last = at
			_pet_dist = 0.0
			_show_panel(c)
		elif at.y > Places.HORIZON and _fetch == "":
			var who := _focus_creature()
			if who != null and who != _eater and who != _tug:
				who.go_to(at, func(): who.say("note"))
	elif event is InputEventMouseMotion and _petting != null:
		stroke_pet(_petting, at.distance_to(_pet_last))
		_pet_last = at


func _creature_at(at: Vector2) -> Creature:
	for i in range(creatures.size() - 1, -1, -1):
		if creatures[i].hit(at):
			return creatures[i]
	return null


func _furniture_at(at: Vector2) -> Furniture:
	for i in range(furniture.size() - 1, -1, -1):
		if furniture[i].hit(at):
			return furniture[i]
	return null


## A rub of `distance` pixels across a pet. Every so far of rubbing is a heart.
func stroke_pet(c: Creature, distance: float) -> void:
	if c == _fetcher or c == _eater or c == _tug:
		return
	_pet_dist += distance
	if c.action() != "petted":
		c.perform("petted", 0.6)
	c.extend_action(0.5)
	if _pet_dist > 140.0:
		_pet_dist = 0.0
		c.say("heart")
		_love(c, 1)
		_train(c, "charm", 0.35)
		PetStore.change_need(c.pet, "fun", 0.015)


# --- Dragging things out of the drawers ------------------------------------------------------

func _grab(id: String) -> void:
	var item := Items.get_item(id)
	if item.is_empty():
		return
	_held_item = item
	_samples.clear()
	match item["category"]:
		"food":
			if food != null and is_instance_valid(food) and _eater == null:
				food.queue_free()
			food = _new_item(item)
			_held = food
			_held_kind = "food"
		"toy":
			if toy != null and is_instance_valid(toy):
				_end_tug(false)
				if _fetcher != null:
					_fetcher.interrupt()
				toy.queue_free()
			_fetch = ""
			_fetcher = null
			toy = _new_item(item)
			_held = toy
			_held_kind = "toy"
		"furniture":
			var f := _spawn_furniture({"item": id, "pos": [640, 600], "scale": 1.0, "flip": false})
			_held = f
			_held_kind = "furniture"
		"clothing":
			var ghost := Sprite2D.new()
			var tex: Texture2D = item["_tex"]
			ghost.texture = tex
			ghost.scale = Vector2.ONE * (110.0 / maxf(tex.get_width(), tex.get_height()))
			ghost.z_index = 100
			add_child(ghost)
			_held = ghost
			_held_kind = "clothing"
	if _held is PlaceItem:
		(_held as PlaceItem).held = true
	if _held != null:
		_move_held(get_global_mouse_position())


func _new_item(item: Dictionary) -> PlaceItem:
	var it := PlaceItem.new()
	var h := 120.0
	for c in creatures:
		h = maxf(h, c.height_px)
	it.setup(item, clampf(h * 0.42, 50.0, 170.0))
	it.bounds = Rect2(GROUND.position - Vector2(30, 0), GROUND.size + Vector2(60, 0))
	it.bounced.connect(_on_bounce.bind(it))
	world.add_child(it)
	return it


func _move_held(at: Vector2) -> void:
	_finger = at
	match _held_kind:
		"food", "toy":
			var it := _held as PlaceItem
			if _tug != null:
				it.stretch_to = at
				return
			it.position = Vector2(at.x, clampf(at.y + 60.0, it.bounds.position.y, it.bounds.end.y))
			it.z = maxf(0.0, it.position.y - at.y - it.radius * 0.9 * it.scale.y)
			it.vel = Vector2.ZERO
			it.vz = 0.0
			_samples.append([Time.get_ticks_msec() / 1000.0, at])
			if _samples.size() > 6:
				_samples.pop_front()
			if _held_kind == "toy" and it.has_word("stretchy"):
				_try_start_tug(it, at)
		"furniture", "move":
			_held.position = Vector2(at.x, clampf(at.y + 20.0, GROUND.position.y - 30.0, GROUND.end.y))
		"clothing":
			_held.position = at


func _drop_held(at: Vector2, screen_at: Vector2) -> void:
	var held := _held
	var kind := _held_kind
	_held = null
	_held_kind = ""
	var over_bar := screen_at.y > get_viewport().get_visible_rect().size.y - 118.0
	match kind:
		"food":
			(held as PlaceItem).held = false
			_told_full = false
			if int(_held_item.get("uses", 0)) > 0:
				game.profile.use_up(_held_item["id"])
				_fill_drawer()
		"toy":
			(held as PlaceItem).held = false
			if _tug != null:
				_end_tug(true)
				return
			var v := Vector2.ZERO
			if _samples.size() >= 2:
				var a: Array = _samples[0]
				var b: Array = _samples[_samples.size() - 1]
				var dt: float = maxf(b[0] - a[0], 0.016)
				v = (b[1] - a[1]) / dt
			throw_toy(v)
		"furniture":
			var f := held as Furniture
			if over_bar:
				furniture.erase(f)
				f.queue_free()
				return
			f.entry["pos"] = PetBuilder.arr(f.position)
			home["items"].append(f.entry)
			game.profile.save()
			_select_furniture(f)
			if game.profile.count_today("decorate", 3):
				game.reward(1, "Nice decorating!")
		"move":
			var f := held as Furniture
			if over_bar:
				_remove_furniture(f)
				return
			f.entry["pos"] = PetBuilder.arr(f.position)
			game.profile.save()
		"clothing":
			held.queue_free()
			var c := _creature_at(at)
			if c != null:
				dress(c, _held_item)


## Puts a piece of clothing on a pet.
func dress(c: Creature, item: Dictionary) -> void:
	Wardrobe.put_on(c.pet, item)
	c.rebuild()
	c.perform("celebrate", 1.2)
	c.say("star")
	_train(c, "charm", 0.8)
	PetStore.save_pet(c.pet)
	if c == _panel_pet:
		_panel.refresh()


func _take_off_clothes() -> void:
	if _panel_pet == null:
		return
	Wardrobe.take_off_all(_panel_pet.pet)
	_panel_pet.rebuild()
	PetStore.save_pet(_panel_pet.pet)
	_panel.refresh()


# --- Decorating ------------------------------------------------------------------------------

func _spawn_furniture(entry: Dictionary) -> Furniture:
	var item := Items.get_item(entry.get("item", ""))
	if item.is_empty():
		return null
	var f := Furniture.new()
	f.bounds = GROUND
	world.add_child(f)
	f.setup(item, entry)
	furniture.append(f)
	return f


func _select_furniture(f: Furniture) -> void:
	if _selected != null and is_instance_valid(_selected):
		_selected.selected = false
		_selected.queue_redraw()
	_selected = f
	if f != null:
		f.selected = true
		f.queue_redraw()
	if tab == "furniture":
		_fill_drawer()


func _resize_selected(k: float) -> void:
	if _selected == null:
		return
	_selected.entry["scale"] = clampf(float(_selected.entry.get("scale", 1.0)) * k, 0.4, 2.5)
	_selected.apply_size()
	game.profile.save()


func _flip_selected() -> void:
	if _selected == null:
		return
	_selected.entry["flip"] = not _selected.entry.get("flip", false)
	_selected.apply_size()
	game.profile.save()


func _remove_selected() -> void:
	if _selected != null:
		_remove_furniture(_selected)


func _remove_furniture(f: Furniture) -> void:
	home["items"].erase(f.entry)
	furniture.erase(f)
	if _selected == f:
		_selected = null
	f.queue_free()
	game.profile.save()
	_fill_drawer()


## "Tasty" things (an apple tree) drop a snack once a day.
func _drop_daily_snacks() -> void:
	var today := Time.get_date_string_from_system()
	for f in furniture:
		if f.has_word("tasty") and f.entry.get("snack_day", "") != today:
			f.entry["snack_day"] = today
			var snack := _new_item(Items.get_item("kit_apple"))
			snack.position = f.position + Vector2(randf_range(-60, 60), 30)
			snack.z = f.height_px * 0.6
			food = snack
			game.profile.save()
			return


# --- Fetch -----------------------------------------------------------------------------------

## Sends the toy off with a flick velocity in screen pixels/second. Everyone with the energy
## for it gives chase.
func throw_toy(v: Vector2) -> void:
	v = v.limit_length(1600.0) * toy.throw_scale()
	toy.vel = Vector2(v.x, v.y * 0.25)
	toy.vz = clampf(-v.y * 0.55, 0.0, 1000.0) + 120.0
	_fetch = "chase"
	_fetcher = null
	_caught_in_air = false
	_chasers.clear()
	_leapt.clear()
	for c in creatures:
		if c == _eater or c.action() == "sleep" or float(c.pet["needs"]["energy"]) < 0.3:
			continue
		c.interrupt()
		c.rest_z = 0.0
		_chasers.append(c)
		c.say("note")
	if _chasers.is_empty():
		_show_hint("Everyone's too sleepy to play. Let them rest on something cozy!")
		_fetch = ""


func _update_fetch() -> void:
	if toy == null or not is_instance_valid(toy) or toy.held:
		return
	match _fetch:
		"chase":
			for c: Creature in _chasers:
				var side := signf(toy.position.x - c.position.x)
				if side == 0.0:
					side = c.facing
				var aim := toy.position - Vector2(side * c.mouth_reach(), -2.0)
				c.go_to(aim, Callable(), true, toy.z > c.height_px * 0.6)
				# A bouncing or floating toy gets jumped for - that is what trains agility.
				var near := absf(toy.position.x - c.position.x) < c.height_px * 0.8
				if near and not _leapt.has(c) and toy.z > c.height_px * 0.25 and toy.z < c.height_px * 1.6:
					_leapt.append(c)
					c.leap(minf(toy.z * 0.9, c.height_px * 0.9), 0.55)
				var reach := maxf(toy.radius, 26.0) + c.height_px * 0.25
				var mouth := c.mouth_global()
				if mouth.distance_to(toy.global_position + Vector2(0, -toy.z)) < reach \
						and toy.z < c.height_px * 0.9 + c.z:
					_caught_in_air = toy.z > 20.0
					_fetcher = c
					toy.pick_up(c)
					_fetch = "return"
					var back := Vector2(clampf(c.position.x, 200.0, 1080.0), GROUND.end.y - 4.0)
					c.go_to(back, _on_fetched, true)
					for other in _chasers:
						if other != c:
							other.stop()
							_train(other, "speed", 0.3)
					break
		"return":
			if _fetcher != null:
				toy.global_position = _fetcher.mouth_global() + Vector2(0, toy.radius * 0.9 * toy.scale.y)
				toy.z = 0.0


func _on_fetched() -> void:
	var c := _fetcher
	if c == null or toy == null or not is_instance_valid(toy):
		_fetch = ""
		return
	_fetch = "after"
	var shiny := 2.0 if toy.item.get("shine", "") != "" else 1.0
	_train(c, "speed", 0.8 * shiny)
	if _caught_in_air:
		_train(c, "agility", 1.0 * shiny)
		_on_emote("star", c.top_global())
	for w in toy.item.get("words", []):
		_train(c, Words.stat_of("toy", w), 1.0 * shiny)
	PetStore.change_need(c.pet, "fun", 0.12)
	PetStore.change_need(c.pet, "energy", -0.04)
	_love(c, 1)
	var n := int(game.profile.today().get("fetch", 0)) + 1
	game.profile.today()["fetch"] = n
	if n % 5 == 0 and n <= 25:
		game.reward(2, "%d fetches today!" % n)

	# What happens next depends on the toy's words.
	var cozy := _furniture_with("cozy")
	if toy.has_word("soft") and cozy != null:
		c.go_to(cozy.position + Vector2(0, 3), func():
			c.rest_z = cozy.perch_height()
			c.perform("sleep", 5.0, func():
				_train(c, "charm", 1.0)
				PetStore.change_need(c.pet, "energy", 0.2)
				_let_go_of_toy(c)))
	elif toy.has_word("chewy"):
		c.perform("chew", 4.0, func():
			_train(c, "stamina", 1.2 * shiny)
			_let_go_of_toy(c))
	elif toy.has_word("puzzly"):
		c.perform("sniff", 2.5, func():
			_on_emote("crumb", c.mouth_global())
			_on_emote("star", c.top_global())
			PetStore.change_need(c.pet, "food", 0.1)
			_train(c, "smarts", 1.5 * shiny)
			_let_go_of_toy(c))
	else:
		_let_go_of_toy(c)
		c.perform("celebrate", 1.3)
		c.say("star")


func _let_go_of_toy(c: Creature) -> void:
	if toy != null and is_instance_valid(toy) and toy.carrier == c:
		toy.drop_at(c.position + Vector2(c.facing * c.mouth_reach(), 6.0), 20.0)
	c.rest_z = 0.0
	_fetch = ""
	_fetcher = null
	_panel.refresh()


func _on_bounce(item: PlaceItem) -> void:
	if item.has_word("squeaky"):
		_on_emote("note", item.global_position + Vector2(0, -item.z - 30.0))


# --- Tug of war ------------------------------------------------------------------------------

## Holding a stretchy toy right by a pet's mouth: it grabs the other end.
func _try_start_tug(it: PlaceItem, at: Vector2) -> void:
	for c in creatures:
		if c == _eater or c.action() == "sleep":
			continue
		if c.mouth_global().distance_to(at) < maxf(60.0, c.height_px * 0.3):
			_tug = c
			_tug_time = 0.0
			c.interrupt()
			c.perform("tug", 999.0)
			it.held = false
			it.pick_up(c)
			it.stretch_to = at
			_show_hint("Tug of war! Pull, pull!")
			return


func _update_tug(delta: float) -> void:
	if _tug == null or toy == null or not is_instance_valid(toy):
		return
	var c := _tug
	_tug_time += delta
	toy.global_position = c.mouth_global() + Vector2(0, toy.radius * 0.3)
	toy.z = 0.0
	var span := _finger - c.mouth_global()
	var slack := c.height_px * 0.35
	var tension := maxf(0.0, span.length() - slack)
	# It pulls back with its strength; a strong pet barely gets dragged.
	var give := tension * 2.2 / (1.0 + Stats.value(c.pet, "strength") / 25.0)
	c.position += span.normalized() * give * delta
	c.position = c.position.clamp(GROUND.position, GROUND.end)
	if absf(span.x) > 4.0:
		c.facing = -signf(span.x)
	var shiny := 2.0 if toy.item.get("shine", "") != "" else 1.0
	_train(c, "strength", 0.6 * delta * clampf(tension / 80.0, 0.0, 1.5) * shiny)
	if span.length() > 520.0:
		_end_tug(true)


## Ends tug of war. When the kid lets go, the pet wins - it always does.
func _end_tug(pet_wins: bool) -> void:
	if _tug == null:
		return
	var c := _tug
	_tug = null
	if toy != null and is_instance_valid(toy):
		toy.end_stretch()
		toy.drop_at(c.position + Vector2(c.facing * c.mouth_reach(), 6.0), 10.0)
	c.interrupt()
	if pet_wins and _tug_time > 0.6:
		c.perform("celebrate", 1.4)
		c.say("star")
		_love(c, 1)
		PetStore.change_need(c.pet, "fun", 0.1)
		game.reward_daily("tug", 5, 1, "%s won tug of war!" % c.pet["name"])


# --- Feeding ---------------------------------------------------------------------------------

func _update_food(delta: float) -> void:
	if food == null or not is_instance_valid(food):
		return
	if _eater != null:
		if food.carrier == _eater:
			food.global_position = _eater.mouth_global() + Vector2(0, food.radius * 0.6 * food.scale.y)
			food.z = 0.0
			food.sprite.scale *= 1.0 - delta * 0.3
			if randf() < delta * 2.5:
				_on_emote("crumb", _eater.mouth_global())
		return
	if not food.landed() or _fetch != "":
		return
	var hungriest: Creature = null
	for c in creatures:
		if c == _tug or c.action() == "sleep":
			continue
		if float(c.pet["needs"]["food"]) > 0.95:
			continue
		if hungriest == null or float(c.pet["needs"]["food"]) < float(hungriest.pet["needs"]["food"]):
			hungriest = c
	if hungriest == null:
		if not _told_full and not creatures.is_empty():
			_told_full = true
			_show_hint("Everyone's full! Maybe later.")
		return
	_eater = hungriest
	hungriest.interrupt()
	hungriest.rest_z = 0.0
	var side := signf(food.position.x - hungriest.position.x)
	if side == 0.0:
		side = 1.0
	hungriest.go_to(food.position - Vector2(side * hungriest.mouth_reach(), -2.0), _arrive_at_food, true)


func _arrive_at_food() -> void:
	if food == null or not is_instance_valid(food) or _eater == null:
		_eater = null
		return
	_eater.face_toward(food.position.x)
	# It picks the food up to munch it - no drawn neck is long enough to reach the ground.
	food.pick_up(_eater)
	_eater.perform("eat", 2.4, _ate)


func _ate() -> void:
	var c := _eater
	_eater = null
	if c == null:
		return
	var item: Dictionary = food.item if food != null and is_instance_valid(food) else {}
	if food != null and is_instance_valid(food):
		food.queue_free()
	food = null
	PetStore.change_need(c.pet, "food", 0.4)
	_love(c, 2)
	var favourite := Items.get_item(c.pet.get("food", {}).get("item", ""))
	var shared := false
	for w in item.get("words", []):
		if favourite.get("words", []).has(w):
			shared = true
	if item.get("id", "") == favourite.get("id", "-"):
		c.perform("celebrate", 1.4)
		c.say("star")
		c.say("heart")
		game.reward_daily("favourite_food", 1, 2, "%s's favourite!" % c.pet["name"])
	elif shared:
		c.say("heart")
	# A snack gives a training boost to its word's stat for ten minutes.
	var stat := "all" if item.get("id", "") == "star_snack" else Words.first_stat("food", item.get("words", []))
	if stat != "":
		c.pet["boost"] = {"stat": stat, "until": Time.get_unix_time_from_system() + 600}
	game.reward_daily("feed", 3, 1, "Fed %s!" % c.pet["name"])
	_panel.refresh()


# --- Furniture play --------------------------------------------------------------------------

func _furniture_with(word: String) -> Furniture:
	var options := []
	for f in furniture:
		if f.has_word(word):
			options.append(f)
	return options.pick_random() if not options.is_empty() else null


## Left alone, a pet finds something to do with the furniture - by its words.
func _play_with_furniture(c: Creature) -> void:
	if furniture.is_empty():
		return
	var pet := c.pet
	var word := ""
	var tags := Places.tags(home["place"])
	if float(pet["needs"]["energy"]) < 0.45 and _furniture_with("cozy") != null:
		word = "cozy"
	elif tags.has("hot") and _furniture_with("shady") != null and randf() < 0.4:
		word = "shady"
	elif tags.has("cold") and _furniture_with("warm") != null and randf() < 0.4:
		word = "warm"
	else:
		var playable := []
		for w in ["bouncy", "climbable", "musical", "splashy", "scratchy", "slidey", "hidey", "fancy"]:
			if _furniture_with(w) != null:
				playable.append(w)
		if playable.is_empty():
			return
		word = playable.pick_random()
	var f := _furniture_with(word)
	if f == null:
		return
	var spot := f.position + Vector2(0, 3)
	if word == "hidey":
		spot = f.position + Vector2(randf_range(-20, 20), -10)  # just behind it
	elif word in ["shady", "warm", "musical", "scratchy", "fancy"]:
		spot = f.position + Vector2(signf(c.position.x - f.position.x + 0.1) * f.height_px * 0.45, 8)
	c.go_to(spot, func(): _use_furniture(c, f, word))


func _use_furniture(c: Creature, f: Furniture, word: String) -> void:
	if not is_instance_valid(f):
		return
	match word:
		"cozy":
			c.rest_z = f.perch_height()
			c.perform("sleep", randf_range(6.0, 10.0), func():
				PetStore.change_need(c.pet, "energy", 0.35)
				_train(c, "stamina", 0.4)
				c.rest_z = 0.0)
		"shady", "warm":
			c.perform("sleep", 4.0, func(): PetStore.change_need(c.pet, "energy", 0.2))
		"bouncy":
			c.rest_z = f.perch_height()
			c.perform("bounce", 3.5, func():
				_train(c, "agility", 1.4)
				PetStore.change_need(c.pet, "fun", 0.06)
				c.rest_z = 0.0)
		"climbable":
			c.rest_z = f.perch_height()
			c.perform("look", 4.0, func():
				_train(c, "strength", 0.9)
				_train(c, "agility", 0.5)
				c.rest_z = 0.0)
		"slidey":
			c.rest_z = f.perch_height()
			var landed := func():
				_train(c, "speed", 0.9)
				PetStore.change_need(c.pet, "fun", 0.08)
				c.say("note")
			c.perform("look", 1.0, func(): c.go_to(f.position + Vector2(f.height_px * 0.7, 12), landed, true))
		"musical":
			c.perform("dance", 3.5, func():
				_train(c, "charm", 1.3)
				PetStore.change_need(c.pet, "fun", 0.05))
		"splashy":
			c.perform("splash", 3.0, func():
				_train(c, "stamina", 1.1)
				PetStore.change_need(c.pet, "clean", 0.3)
				PetStore.change_need(c.pet, "fun", 0.08))
		"scratchy":
			c.perform("scratch", 2.5, func(): _train(c, "strength", 1.1))
		"hidey":
			c.perform("hide", 5.0, func():
				_train(c, "smarts", 1.0)
				c.say("question"))
		"fancy":
			c.perform("look", 2.5, func(): _train(c, "charm", 0.6))


# --- Training, trust and rewards -------------------------------------------------------------

func _train(c: Creature, stat: String, amount: float) -> void:
	if stat == "" or amount <= 0.0:
		return
	var levels := Stats.train(c.pet, stat, amount)
	if levels > 0:
		var lvl := Stats.level(Stats.value(c.pet, stat))
		c.say("star")
		game.reward(3 * levels, "%s's %s is level %d!" % [c.pet["name"], Stats.label(stat), lvl])
		if stat == "speed":
			c.set_display_height(c.fixed_height)  # walk speed follows the speed stat


func _love(c: Creature, n: int) -> void:
	var before := Stats.trust(c.pet)
	c.pet["love"] = int(c.pet.get("love", 0)) + n
	var after := Stats.trust(c.pet)
	if after > before:
		for i in after:
			_on_emote("heart", c.top_global() + Vector2((i - after / 2.0) * 30.0, -10))
		game.reward(5 * after, "%s trusts you more! (%d hearts)" % [c.pet["name"], after])


# --- Every frame -----------------------------------------------------------------------------

func _process(delta: float) -> void:
	_update_fetch()
	_update_tug(delta)
	_update_food(delta)
	if _fetch == "return" and toy != null and is_instance_valid(toy) and toy.has_word("squeaky"):
		_squeak_in -= delta
		if _squeak_in <= 0.0:
			_squeak_in = 0.7
			_on_emote("note", toy.global_position + Vector2(0, -30))
	_ai_in -= delta
	if _ai_in <= 0.0:
		_ai_in = 1.2
		for c in creatures:
			if c.is_busy() or c == _fetcher or c == _eater or c == _tug or (_chasers.has(c) and _fetch == "chase"):
				continue
			if randf() < 0.22:
				_play_with_furniture(c)
	if _follow != null:
		_cam.position = _follow.position + Vector2(0, -_follow.height_px * 0.5 + CAM_DROP)
	_hint_time -= delta
	if _hint_time < 1.0:
		_hint.modulate.a = maxf(0.0, _hint_time)
	_save_in -= delta
	if _save_in <= 0.0:
		_save_in = 10.0
		_save_all()
		if _panel.visible:
			_panel.refresh()


func _on_emote(kind: String, at: Vector2) -> void:
	var e := Emote.new()
	e.kind = kind
	e.position = at
	add_child(e)


func _save_all() -> void:
	for pet in pets:
		PetStore.save_pet(pet)
	game.profile.save()


func _exit_tree() -> void:
	_save_all()


# --- Script entry points (DemoKid), down the same paths a finger takes -----------------------

func drop_food(id: String, at: Vector2) -> void:
	_grab(id)
	_move_held(at)
	_drop_held(at, Vector2(640, 300))


func fling_toy(id: String, from: Vector2, velocity: Vector2) -> void:
	_grab(id)
	_move_held(from)
	_held = null
	_held_kind = ""
	toy.held = false
	throw_toy(velocity)


func place_furniture(id: String, at: Vector2) -> void:
	_grab(id)
	_move_held(at)
	_drop_held(at, Vector2(640, 300))
