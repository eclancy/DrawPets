class_name TrickScreen
extends Control
## Teaching tricks (.ai/pet-life.md): a stage with the pet on it - the swipe pad - and its trick
## cards beside it. Tap a blank card to draw a symbol on it (anything at all: it is only a
## picture), tap a card to hold it up, then do its swipe on the stage. The right swipe teaches
## the trick - a little more each time, faster for a clever pet - and a trick it knows it just
## does. Only the swipe's shape is read (Tricks.read_swipe), never the drawing (rule 4).

var game: GameRoot
var home: Dictionary
var pet_id := ""

var pet: Dictionary
var creature: Creature
var _main: Control
var _drawing: Control
var _stage: Control
var _trail: Trail
var _held: TextureRect
var _held_card: Panel
var _held_name: Label
var _hint: Label
var _grid: GridContainer
var _trick := ""


func _ready() -> void:
	pet = PetStore.load_pet(pet_id)
	Stats.ensure(pet)
	add_child(UI.paper_background())
	_main = Control.new()
	add_child(UI.full_rect(_main))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	UI.full_rect(col)
	col.offset_left = 16
	col.offset_top = 12
	col.offset_right = -16
	col.offset_bottom = -12
	_main.add_child(col)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", go_home, 40, Vector2(100, 84)))
	var title := UI.title("Tricks with %s" % pet["name"], 36)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	col.add_child(top)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)

	_stage = Stage.new()
	_stage.custom_minimum_size = Vector2(620, 0)
	_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stage.size_flags_stretch_ratio = 1.2
	_stage.gui_input.connect(_on_stage_input)
	_stage.resized.connect(_place_pet)
	body.add_child(_stage)

	creature = Creature.new()
	creature.wander = false
	creature.confine = false
	creature.depth_scale = false
	_stage.add_child(creature)
	creature.setup(pet)
	creature.audible = true
	creature.fit_in(Vector2(340, 300))
	creature.emote.connect(_on_emote)

	# The card held up beside it: paper with a border, the kid's drawing on it.
	_held_card = Panel.new()
	_held_card.size = Vector2(176, 200)
	_held_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_card.add_theme_stylebox_override("panel", UI._box(UI.PAPER, UI.INK, 3, 16))
	_held_card.visible = false
	_stage.add_child(_held_card)
	_held = TextureRect.new()
	_held.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_held.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_held.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held.size = Vector2(150, 150)
	_stage.add_child(_held)
	_held_name = UI.title("", 22)
	_held_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_held_name.size = Vector2(170, 30)
	_stage.add_child(_held_name)

	_trail = Trail.new()
	_stage.add_child(UI.full_rect(_trail))

	_hint = UI.title("", 22)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_hint.offset_left = 16
	_hint.offset_right = -16
	_hint.offset_top = 12
	_stage.add_child(_hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_grid)
	_refresh_cards()
	_show_hint("Tap a card to hold it up - or a blank one to draw a card for a new trick!")


func _place_pet() -> void:
	if creature == null or _held_name == null:
		return
	creature.position = Vector2(_stage.size.x * 0.42, _stage.size.y - 60.0)
	_held.position = Vector2(_stage.size.x - 190.0, _stage.size.y * 0.24)
	_held_card.position = _held.position - Vector2(13, 12)
	_held_name.position = _held.position + Vector2(-10, 152)


func _show_hint(text: String) -> void:
	_hint.text = text


# --- The cards -------------------------------------------------------------------------------

func _refresh_cards() -> void:
	for c in _grid.get_children():
		c.queue_free()
	for t in Tricks.ALL:
		_grid.add_child(_card_button(t))


func _card_button(t: String) -> Button:
	var has_card := Tricks.cards(pet).has(t)
	var b := Button.new()
	b.custom_minimum_size = Vector2(160, 190)
	b.pressed.connect(pick.bind(t))
	if t == _trick:
		b.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.INK, 4))
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	UI.full_rect(col)
	var pic := TextureRect.new()
	pic.texture = Tricks.card_texture(pet, t)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = Vector2(120, 104)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not has_card:
		pic.modulate = Color(1, 1, 1, 0.3)
	col.add_child(pic)
	var name := UI.label(Tricks.display_name(t), 20)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(name)
	var status := "Draw a card"
	if Tricks.knows(pet, t):
		status = "Knows it!"
	elif has_card:
		status = "Learning %s" % "*".repeat(1 + int(Tricks.learned(pet, t) * 4.0))
	var s := UI.label(status, 16)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(s)
	b.add_child(col)
	return b


## A card is tapped: a blank one is drawn on first; one with a picture is held up.
func pick(t: String) -> void:
	if not Tricks.cards(pet).has(t):
		_draw_card(t)
		return
	_trick = t
	_held.texture = Tricks.card_texture(pet, t)
	_held_card.visible = true
	_held_name.text = Tricks.display_name(t)
	Sounds.play_varied("card_flip", 1.0, 0.05)
	creature.face_toward(creature.position.x + 100.0)
	creature.perform("look", 0.8)
	var how: String = Tricks.INFO[t]["how"]
	if Tricks.knows(pet, t):
		_show_hint("%s knows %s! Now %s on the stage." % [pet["name"], Tricks.display_name(t).to_upper(), how])
	else:
		_show_hint("Show %s the card... now %s on the stage!" % [pet["name"], how])
	_trail.show_swipe(Tricks.INFO[t]["swipe"])
	_refresh_cards()


func _draw_card(t: String) -> void:
	var s := DrawScreen.new()
	s.subject = "card"
	s.prompt = "Draw a symbol for %s on its card - a swirl, a star, a squiggle, anything you like!" \
		% Tricks.display_name(t).to_upper()
	s.step_text = "A trick card for %s" % pet["name"]
	s.can_skip = true
	s.skip_text = "Back"
	s.on_done = _card_drawn.bind(t)
	_main.visible = false
	_drawing = s
	add_child(UI.full_rect(s))


func _card_drawn(r: Dictionary, t: String) -> void:
	UI.retire(_drawing)
	_drawing = null
	_main.visible = true
	if r.is_empty():
		return
	var file := "card_%s.png" % t
	pet["_img"][file] = r["image"]
	pet["_tex"].erase(file)
	var tricks: Dictionary = pet.get("tricks", {})
	tricks[t] = {"image": file, "learned": Tricks.learned(pet, t)}
	pet["tricks"] = tricks
	PetStore.save_pet(pet, true)
	pick(t)


# --- Swiping on the stage --------------------------------------------------------------------

func _on_stage_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_trail.begin(event.position)
		else:
			swipe(_trail.end())
	elif event is InputEventMouseMotion and _trail.drawing:
		_trail.add(event.position)


## A finished swipe on the stage (also the demo kid's way in).
func swipe(points: PackedVector2Array) -> void:
	var got := Tricks.read_swipe(points)
	if got == "":
		return
	if _trick == "":
		_show_hint("First tap a card to hold it up!")
		return
	var want: String = Tricks.INFO[_trick]["swipe"]
	if got != want:
		creature.perform("look", 0.9)
		creature.say("question")
		_show_hint("Hmm? For %s, %s." % [Tricks.display_name(_trick).to_upper(), Tricks.INFO[_trick]["how"]])
		_trail.show_swipe(want)
		return
	teach(_trick)


## The right swipe: a trick it knows, it does; one it is learning, it learns a bit more of.
func teach(t: String) -> void:
	var name := Tricks.display_name(t).to_upper()
	var before := Tricks.learned(pet, t)
	if before >= 1.0:
		creature.do_trick(t)
		Sounds.play("good")
		_train("smarts", 0.15)
		PetStore.change_need(pet, "fun", 0.03)
		_show_hint("%s! Good %s!" % [name, pet["name"]])
		return
	var after := minf(1.0, before + Tricks.lesson(pet))
	pet["tricks"][t]["learned"] = after
	_train("smarts", 0.8)
	PetStore.change_need(pet, "fun", 0.04)
	if after >= 1.0:
		creature.do_trick(t)
		Sounds.play("correct")
		creature.say("star")
		if game.profile.first_time("trick_%s_%s" % [pet["id"], t]):
			game.reward(3, "%s learned %s!" % [pet["name"], name])
		_show_hint("%s learned %s! Its card is ready for the Trick Show." % [pet["name"], name])
	elif randf() < after:
		creature.do_trick(t)
		Sounds.play("good")
		_show_hint("Nearly! %s is getting it - again!" % pet["name"])
	else:
		creature.perform("look", 0.9)
		creature.say("question")
		_show_hint("%s is thinking about it... do it again!" % pet["name"])
	PetStore.save_pet(pet)
	_refresh_cards()


func _train(stat: String, amount: float) -> void:
	var levels := Stats.train(pet, stat, amount)
	if levels > 0:
		Sounds.play("level_up")
		creature.say("star")
		game.reward(3 * levels, "%s's %s is level %d!" % [pet["name"], Stats.label(stat),
			Stats.level(Stats.value(pet, stat))])


func _on_emote(kind: String, at: Vector2) -> void:
	var e := Emote.new()
	e.kind = kind
	e.position = _stage.get_global_transform().affine_inverse() * at
	_stage.add_child(e)


func go_home() -> void:
	PetStore.save_pet(pet)
	game.go_place(home["id"], pet_id)


## Android's back gesture: out of drawing a card first, then back to the home.
func go_back() -> void:
	if _drawing != null:
		_card_drawn({}, "")
	else:
		go_home()


func _exit_tree() -> void:
	PetStore.save_pet(pet)


## The stage: a pale spotlight on a wooden floor, drawn in pencil.
class Stage extends Control:
	func _ready() -> void:
		clip_contents = true
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color("#efe6f7"))
		var floor_y := size.y - 120.0
		draw_rect(Rect2(0, floor_y, size.x, 120), Color("#ecd5b2"))
		for i in 6:
			Crayon.line(self, Vector2(0, floor_y + 12 + i * 18), Vector2(size.x, floor_y + 12 + i * 18),
				Color("#dcc09a"), 3.0, i, 2.0)
		var spot := Crayon.ellipse(Vector2(size.x * 0.42, size.y - 60.0), Vector2(200, 36))
		draw_colored_polygon(spot, Color(1, 0.97, 0.75, 0.7))
		draw_rect(r, UI.INK, false, 3.0)


## The finger's swipe on the stage, and the swipe to do shown as a moving dotted line.
class Trail extends Control:
	var drawing := false
	var _points := PackedVector2Array()
	var _ghost := PackedVector2Array()
	var _ghost_t := -1.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func begin(at: Vector2) -> void:
		drawing = true
		_points = PackedVector2Array([at])
		_ghost_t = -1.0

	func add(at: Vector2) -> void:
		if _points.is_empty() or at.distance_to(_points[_points.size() - 1]) > 4.0:
			_points.append(at)

	func end() -> PackedVector2Array:
		drawing = false
		var out := _points
		_points = PackedVector2Array()
		return out

	func show_swipe(kind: String) -> void:
		_ghost = Tricks.swipe_path(kind, Vector2(size.x * 0.42, size.y * 0.45), minf(size.y * 0.45, 260.0))
		_ghost_t = 0.0

	func _process(delta: float) -> void:
		if _ghost_t >= 0.0:
			_ghost_t += delta
			if _ghost_t > 4.2:
				_ghost_t = -1.0
		queue_redraw()

	func _draw() -> void:
		if _points.size() >= 2:
			draw_polyline(_points, Color(UI.ACCENT, 0.8), 9.0, true)
		if _ghost_t >= 0.0 and _ghost.size() >= 2:
			var k := fmod(_ghost_t, 1.4) / 1.2
			var upto := int(clampf(k, 0.0, 1.0) * (_ghost.size() - 1))
			for i in upto + 1:
				draw_circle(_ghost[i], 5.0, Color(UI.INK, 0.35))
			draw_circle(_ghost[upto], 14.0, Color(UI.ACCENT, 0.55))
