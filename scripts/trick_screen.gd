class_name TrickScreen
extends Control
## Teaching tricks (.ai/pet-life.md): a stage with the pet on it - the swipe pad - and its trick
## cards beside it. Tap a blank card to draw a symbol on it (anything at all: it is only a
## picture), tap a card to hold it up, then do its swipe on the stage. The right swipe teaches
## the trick - a little more each time, faster for a clever pet - and a trick it knows it just
## does. Only the swipe's shape is read (Tricks.read_swipe), never the drawing (rule 4).
##
## Shown more than told, for kids who barely read. Every card wears its swipe as a little drawn
## arrow (Glyph) in its corner, where the kid's own drawing never hides it, and the swipe to do
## runs over the stage as a line with an arrowhead. For a kid's first few visits a drawn hand
## (HowTo) taps a card, then swipes along that line, and comes back if they rest. A right swipe
## glows green, sounds good and fills a pip under the card (four pips and it knows it); a wrong
## one gets a puzzled look, never a telling-off, and the hand shows the swipe again.

## Seconds with no touch before the hand comes back to show it again (the first few visits).
const IDLE_BACK := 6.0
## How many visits the hand teaches on its own; after that it only answers a wrong swipe.
const HINT_TIMES := 3
const SWIPE_CAPTION := "Swipe like the finger!"

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
var _glyph: Glyph
var _pips: Pips
var _hint: Label
var _grid: GridContainer
var _trick := ""
## trick -> its card's Button, so the hand can point at one.
var _cards := {}
## Over the stage, the same size, but not clipped by it: the hand lives here, so its caption sits
## over the stage and its finger can still reach the cards.
var _over: Control
var _hand: HowTo
var _coach := false
var _idle := 0.0


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

	# The top row: Back, the title, and the line saying what to do. It sits above the reward
	# toasts, which come down from just under it, so they never cover it.
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", go_home, 40, Vector2(100, 84)))
	top.add_child(UI.title("Tricks with %s" % pet["name"], 36))
	_hint = UI.label("", 24, true)
	_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint.max_lines_visible = 2
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(_hint)
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

	# The card held up beside it: paper with a border, the kid's drawing on it, its swipe on a
	# badge at the corner and its pips underneath.
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
	_glyph = Glyph.new()
	_glyph.size = Vector2(78, 78)
	_glyph.visible = false
	_stage.add_child(_glyph)
	_pips = Pips.new()
	_pips.size = Vector2(176, 40)
	_pips.r = 13.0
	_pips.visible = false
	_stage.add_child(_pips)

	_trail = Trail.new()
	_stage.add_child(UI.full_rect(_trail))

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_grid)

	_over = Control.new()
	_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main.add_child(_over)

	_refresh_cards()
	_show_hint("Tap a card!")
	_coach = HowTo.first_times(game.profile, "howto_teach_tricks", HINT_TIMES)
	# The hand comes in a moment after the screen does, once the cards have found their places.
	_idle = IDLE_BACK - 0.5


func _place_pet() -> void:
	if creature == null or _pips == null:
		return
	creature.position = Vector2(_stage.size.x * 0.42, _stage.size.y - 60.0)
	_held.position = Vector2(_stage.size.x - 190.0, _stage.size.y * 0.24)
	_held_card.position = _held.position - Vector2(13, 12)
	_held_name.position = _held.position + Vector2(-10, 152)
	_glyph.position = _held_card.position - Vector2(30, 30)
	_pips.position = _held_card.position + Vector2(0, 206)


func _show_hint(text: String) -> void:
	_hint.text = text


func _process(delta: float) -> void:
	# The hand's layer lies exactly over the stage.
	_over.position = _stage.get_global_rect().position - _main.get_global_rect().position
	_over.size = _stage.size
	_trail.keep = _hand != null and _hand.gesture == "follow"
	if _trail.keep:
		# Only the hand and its ring lift between goes; its words stay put.
		_hand.self_modulate.a = _trail.ghost_lift()
	# One sentence on screen at a time: the hand's own words while it is up.
	_hint.visible = _hand == null
	if _drawing != null or _trail.drawing or _hand != null:
		_idle = 0.0
		return
	_idle += delta
	if _coach and _idle > IDLE_BACK:
		if _trick == "":
			_show_card_hand()
		else:
			_show_swipe_hand()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_idle = 0.0


# --- The hand --------------------------------------------------------------------------------

## The hand taps a card: the one to go on with.
func _show_card_hand(seconds := 0.0) -> void:
	var h := HowTo.new()
	h.gesture = "tap"
	h.at = _card_point.bind(_card_to_try())
	h.caption = "Tap a card!"
	h.caption_y = 18.0
	h.until_touch = true
	h.seconds = seconds
	_set_hand(h)


## The hand draws the held card's swipe, riding the moving dot along its line.
func _show_swipe_hand(seconds := 0.0) -> void:
	if _trick == "":
		return
	_trail.show_swipe(Tricks.INFO[_trick]["swipe"])
	var h := HowTo.new()
	h.gesture = "follow"
	h.follow = _ghost_point
	h.caption = SWIPE_CAPTION
	h.caption_y = 18.0
	h.until_touch = true
	h.seconds = seconds
	_set_hand(h)


func _set_hand(h: HowTo) -> void:
	_drop_hand()
	_hand = h
	h.tree_exiting.connect(_hand_gone.bind(h))
	_over.add_child(h)


func _drop_hand() -> void:
	if _hand != null and is_instance_valid(_hand):
		_hand.dismiss()
	_hand = null


func _hand_gone(h: HowTo) -> void:
	if _hand == h:
		_hand = null
	_idle = 0.0


## The card to start with: one it is learning, else one with no picture yet.
func _card_to_try() -> String:
	for t in Tricks.ALL:
		if Tricks.cards(pet).has(t) and not Tricks.knows(pet, t):
			return t
	for t in Tricks.ALL:
		if not Tricks.cards(pet).has(t):
			return t
	return Tricks.ALL[0]


## A card's picture, in the hand's space.
func _card_point(t: String) -> Vector2:
	var b: Button = _cards.get(t, null)
	if b == null or not is_instance_valid(b):
		return _over.size / 2.0
	return _over.get_global_transform().affine_inverse() * (b.get_global_rect().get_center() + Vector2(0, -26))


## The swipe line's moving dot, in the hand's space.
func _ghost_point() -> Vector2:
	return _over.get_global_transform().affine_inverse() * (_trail.get_global_transform() * _trail.ghost_head())


# --- The cards -------------------------------------------------------------------------------

func _refresh_cards() -> void:
	for c in _grid.get_children():
		UI.retire(c)
	_cards.clear()
	for t in Tricks.ALL:
		var b := _card_button(t)
		_cards[t] = b
		_grid.add_child(b)


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
	# Underneath: a crayon to draw it with, or its pips - green while learning, gold and a star
	# once it knows it.
	var status := HBoxContainer.new()
	status.alignment = BoxContainer.ALIGNMENT_CENTER
	status.add_theme_constant_override("separation", 4)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if has_card:
		var pips := Pips.new()
		pips.custom_minimum_size = Vector2(96, 24)
		pips.r = 8.0
		pips.show_learned(Tricks.learned(pet, t))
		status.add_child(pips)
		if Tricks.knows(pet, t):
			status.add_child(UI.icon("icon_star", 24))
	else:
		status.add_child(UI.icon("tool_crayon", 24))
		var s := UI.label("Draw a card", 20)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		status.add_child(s)
	col.add_child(status)
	b.add_child(col)
	# The swipe, on a badge in the corner, over any drawing - tucked inside the card, where the
	# scrolling list never clips it.
	var glyph := Glyph.new()
	glyph.swipe = Tricks.INFO[t]["swipe"]
	glyph.position = Vector2(100, 6)
	glyph.size = Vector2(54, 54)
	b.add_child(glyph)
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
	_glyph.swipe = Tricks.INFO[t]["swipe"]
	_glyph.visible = true
	_glyph.queue_redraw()
	_pips.show_learned(Tricks.learned(pet, t))
	_pips.visible = true
	Sounds.play_varied("card_flip", 1.0, 0.05)
	creature.face_toward(creature.position.x + 100.0)
	creature.perform("look", 0.8)
	var how: String = Tricks.INFO[t]["how"]
	if Tricks.knows(pet, t):
		_show_hint("%s knows %s - %s!" % [pet["name"], Tricks.display_name(t).to_upper(), how])
	else:
		_show_hint("Now %s!" % how)
	if _coach:
		_show_swipe_hand()
	else:
		_drop_hand()
		_trail.show_swipe(Tricks.INFO[t]["swipe"])
	_refresh_cards()


func _draw_card(t: String) -> void:
	_drop_hand()
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
		elif _trail.drawing:
			swipe(_trail.end())
	elif event is InputEventMouseMotion and _trail.drawing:
		_trail.add(event.position)


## A finished swipe on the stage (also the demo kid's way in). A tap or a scribble counts too:
## whatever it was, the kid is shown what to do next.
func swipe(points: PackedVector2Array) -> void:
	_drop_hand()
	var got := Tricks.read_swipe(points)
	if _trick == "":
		_trail.settle(points, false)
		_show_hint("First tap a card to hold it up!")
		_show_card_hand(3.0)
		return
	var want: String = Tricks.INFO[_trick]["swipe"]
	if got != want:
		# Not that one: a puzzled look (for a real swipe), and the hand shows the right one again.
		_trail.settle(points, false)
		if got != "":
			creature.perform("look", 0.9)
			creature.say("question")
		_show_hint("For %s, %s!" % [Tricks.display_name(_trick).to_upper(), Tricks.INFO[_trick]["how"]])
		_show_swipe_hand(Trail.LOOP * 2.0 + 0.2)
		return
	_trail.settle(points, true)
	teach(_trick)


## The right swipe: a trick it knows, it does; one it is learning, it learns a bit more of. Either
## way it looks right: a good sound, a sparkle, and a pip fills under the card.
func teach(t: String) -> void:
	var name := Tricks.display_name(t).to_upper()
	var before := Tricks.learned(pet, t)
	if before >= 1.0:
		creature.do_trick(t)
		Sounds.play("good")
		_sparkle(_held_card.position + Vector2(88, 40))
		_train("smarts", 0.15)
		PetStore.change_need(pet, "fun", 0.03)
		_show_hint("%s! Good %s!" % [name, pet["name"]])
		return
	Care.played(pet)
	var after := minf(1.0, before + Tricks.lesson(pet, game.profile.advanced()))
	pet["tricks"][t]["learned"] = after
	_train("smarts", 0.8)
	PetStore.change_need(pet, "fun", 0.04)
	_pips.show_learned(after, true)
	if after >= 1.0:
		creature.do_trick(t)
		Sounds.play("correct")
		creature.say("star")
		_sparkle(_held_card.position + Vector2(88, 60), "confetti")
		for i in Pips.COUNT:
			_sparkle(_pips.position + _pips.pip_center(i))
		if game.profile.first_time("trick_%s_%s" % [pet["id"], t]):
			game.reward(3, "%s learned %s!" % [pet["name"], name])
			Journal.add(pet, "Learned a trick: %s!" % Tricks.display_name(t))
		var stage_show := "Trick Show" if game.profile.advanced() else "Talent Show"
		_show_hint("%s learned %s! Ready for the %s!" % [pet["name"], name, stage_show])
	else:
		Sounds.play("good")
		_sparkle(_pips.position + _pips.pip_center(_pips.filled - 1))
		if randf() < after:
			creature.do_trick(t)
			_show_hint("Nearly! %s is getting it - again!" % pet["name"])
		else:
			_try_trick(t)
			_show_hint("Yes! %s is learning - again!" % pet["name"])
	PetStore.save_pet(pet)
	_refresh_cards()


## A right swipe for a trick it has not quite got: a happy little go at it, a bit of the move -
## never the puzzled look a wrong swipe gets.
func _try_trick(t: String) -> void:
	match t:
		"jump":
			creature.perform("hop", 0.4)
		"spin":
			creature.perform("spin", 0.4)
		"sit":
			creature.perform("sit", 0.6)
		"roll":
			creature.perform("wiggle", 0.7)
		"wave":
			creature.perform("wave", 0.6)
		"bow":
			creature.perform("bow", 0.6)
		_:
			creature.perform("dance", 0.6)
	creature.say("heart")


## A little drawn glint (or confetti) on the stage at `at`.
func _sparkle(at: Vector2, kind := "twinkle") -> void:
	var e := Emote.new()
	e.kind = kind
	e.position = at
	_stage.add_child(e)


func _train(stat: String, amount: float) -> void:
	var levels := Stats.train(pet, stat, amount)
	if levels > 0 and game.profile.advanced():
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


## A swipe drawn as a way to go: the line, a solid arrowhead where it ends, and (big, on the
## stage) a dot where the finger starts. On the cards' badges and as the line to follow.
static func draw_swipe(canvas: CanvasItem, pts: PackedVector2Array, col: Color, width: float,
		seed: int, start_dot := true) -> void:
	if pts.size() < 2:
		return
	Crayon.marker_line(canvas, pts, col, width, seed, false)
	var tip := pts[pts.size() - 1]
	var back := (pts[pts.size() - 2] - tip).normalized()
	var barb := width * 2.6
	var head := PackedVector2Array([tip + back.rotated(0.55) * barb, tip - back * width * 0.7,
		tip + back.rotated(-0.55) * barb])
	Crayon.fill(canvas, head, col, seed + 3, 4.0, 1.0, 3.0)
	Crayon.marker_line(canvas, head, col, width * 0.6, seed + 1)
	if start_dot:
		Crayon.fill_blob(canvas, pts[0], Vector2(width, width) * 1.2, col, seed + 2)


## A swipe's path as the kid is shown it. A loop (the circle) stops a little short of where it
## began, so its arrowhead shows which way round it goes instead of landing on its own start -
## and the hand rides this same path, which still reads as a circle (Tricks.read_swipe).
static func shown_path(pts: PackedVector2Array) -> PackedVector2Array:
	if pts.size() > 8 and pts[0].distance_to(pts[pts.size() - 1]) < 2.0:
		return pts.slice(0, pts.size() - maxi(2, pts.size() / 9))
	return pts


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


## The finger's swipe on the stage, and the swipe to do shown as a line with a dot running along
## it. A finished swipe stays a moment: green if it was the right one, fading softly if not.
class Trail extends Control:
	## One go of the swipe to do: the dot runs along it for MOVE seconds, rests, and goes again.
	const LOOP := 1.6
	const MOVE := 1.2

	var drawing := false
	## Keeps the swipe to do going round (the hand is riding its dot); otherwise it shows 3 times.
	var keep := false
	var _points := PackedVector2Array()
	var _kind := ""
	var _ghost_t := -1.0
	var _last := PackedVector2Array()
	var _last_good := false
	var _last_t := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func begin(at: Vector2) -> void:
		drawing = true
		_points = PackedVector2Array([at])
		_ghost_t = -1.0
		_last_t = 0.0

	func add(at: Vector2) -> void:
		if _points.is_empty() or at.distance_to(_points[_points.size() - 1]) > 4.0:
			_points.append(at)

	func end() -> PackedVector2Array:
		drawing = false
		var out := _points
		_points = PackedVector2Array()
		return out

	## Leaves a finished swipe showing for a moment, green if it was right.
	func settle(points: PackedVector2Array, good: bool) -> void:
		_last = points
		_last_good = good
		_last_t = 1.0

	func show_swipe(kind: String) -> void:
		_kind = kind
		_ghost_t = 0.0

	## The swipe to do, laid over the middle of the stage (worked out afresh, so it follows a resize).
	func ghost_path() -> PackedVector2Array:
		return TrickScreen.shown_path(Tricks.swipe_path(_kind, Vector2(size.x * 0.42, size.y * 0.45),
			minf(size.y * 0.45, 260.0)))

	## How much of the hand riding the dot shows: it comes down as each go starts and lifts away
	## while the dot rests at the end, so it never seems to slide back across the stage pressed.
	## Once the kid's own finger is down (the dot has stopped) it is simply out of the way.
	func ghost_lift() -> float:
		if _ghost_t < 0.0:
			return 0.0
		var u := fmod(_ghost_t, LOOP)
		if u < MOVE:
			return clampf(u / 0.12, 0.0, 1.0)
		return clampf(1.0 - (u - MOVE - 0.06) / 0.2, 0.0, 1.0)

	## Where the running dot is now: the hand's fingertip rides it.
	func ghost_head() -> Vector2:
		var path := ghost_path()
		if path.size() < 2:
			return size / 2.0
		return _along(path, _progress())

	func _progress() -> float:
		return clampf(fmod(maxf(_ghost_t, 0.0), LOOP) / MOVE, 0.0, 1.0)

	static func _along(path: PackedVector2Array, k: float) -> Vector2:
		var f := k * (path.size() - 1)
		var i := mini(int(f), path.size() - 2)
		return path[i].lerp(path[i + 1], f - i)

	func _process(delta: float) -> void:
		if _ghost_t >= 0.0:
			_ghost_t += delta
			if not keep and _ghost_t > LOOP * 3.0:
				_ghost_t = -1.0
		_last_t = maxf(0.0, _last_t - delta)
		queue_redraw()

	func _draw() -> void:
		if _last_t > 0.0 and _last.size() >= 2:
			if _last_good:
				Crayon.marker_line(self, _last, Color(UI.GOOD, _last_t), 16.0, 5, false)
			else:
				Crayon.marker_line(self, _last, Color(UI.INK_SOFT, 0.4 * _last_t), 9.0, 5, false)
		if _points.size() >= 2:
			Crayon.marker_line(self, _points, Color(UI.ACCENT, 0.8), 9.0, 3, false)
		if _ghost_t >= 0.0 and _kind != "":
			var path := ghost_path()
			if path.size() < 2:
				return
			TrickScreen.draw_swipe(self, path, Color(UI.INK_SOFT, 0.35), 7.0, 11)
			# The part the dot has run along so far, brighter, and the dot itself.
			var k := _progress()
			var head := _along(path, k)
			var done := PackedVector2Array()
			for i in int(k * (path.size() - 1)) + 1:
				done.append(path[i])
			done.append(head)
			if done.size() >= 2:
				Crayon.marker_line(self, done, Color(UI.ACCENT, 0.55), 11.0, 12, false)
			Crayon.fill_blob(self, head, Vector2(15, 15), Color(UI.ACCENT, 0.85), 13)


## A trick's swipe, small, on a paper badge: in every card's corner, and on the card held up.
## Bolder than the line on the stage and with no start dot (this small, a dot reads as a second
## arrowhead); the zigzag, flat on the stage, stands up taller here so it still reads as one.
class Glyph extends Control:
	var swipe := "up"

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size / 2.0
		var r := minf(size.x, size.y) * 0.5 - 3.0
		var seed := 60 + swipe.length() * 7 + swipe.unicode_at(0)
		# Solid paper, so the kid's drawing under the corner never shows through it.
		var disc := Crayon.blob(c, Vector2(r, r), seed, 20, 0.04)
		Crayon.fill(self, disc, UI.CARD, seed + 2, 6.0, 0.0, 5.0)
		Crayon.marker_line(self, disc, UI.ACCENT.darkened(0.1), maxf(2.5, r * 0.08), seed + 1)
		var path := TrickScreen.shown_path(Tricks.swipe_path(swipe, c, r * 1.4))
		if swipe == "zigzag":
			path = PackedVector2Array()
			for i in 4:
				path.append(c + Vector2(-0.62 if i % 2 == 0 else 0.62, -0.5 + i * 0.3) * r)
		TrickScreen.draw_swipe(self, path, UI.ACCENT.darkened(0.35), maxf(3.5, r * 0.15), seed + 2, false)


## The four pips under a card: how much of its trick the pet has learned. A right swipe fills one
## (it pops); all four, in gold, and it knows it.
class Pips extends Control:
	const COUNT := 4
	const GOLD := Color("#ffd23f")

	var r := 8.0
	var filled := 0
	var known := false
	var _pop := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	## How many pips `learned` (0..1) fills. Every lesson is at least a quarter, so each right
	## swipe fills at least one more - and only knowing it fills the last.
	static func count_for(learned: float) -> int:
		if learned >= 1.0:
			return COUNT
		return mini(COUNT - 1, int(floor(learned * COUNT + 0.001)))

	func show_learned(learned: float, pop := false) -> void:
		var n := count_for(learned)
		if pop and n > filled:
			_pop = 1.0
		filled = n
		known = learned >= 1.0
		queue_redraw()

	func pip_center(i: int) -> Vector2:
		var gap := r * 2.9
		return Vector2(size.x / 2.0 + gap * (i - (COUNT - 1) / 2.0), size.y / 2.0)

	func _process(delta: float) -> void:
		if _pop > 0.0:
			_pop = maxf(0.0, _pop - delta * 2.5)
			queue_redraw()

	func _draw() -> void:
		var on := GOLD if known else UI.GOOD
		for i in COUNT:
			var c := pip_center(i)
			var rr := r
			if i == filled - 1 and _pop > 0.0:
				rr *= 1.0 + 0.6 * sin(_pop * PI)
			var ring := Crayon.ellipse(c, Vector2(rr, rr), 18)
			if i < filled:
				Crayon.fill_blob(self, c, Vector2(rr, rr), on, 31 + i, 0.06)
				Crayon.marker_line(self, ring, on.darkened(0.35), maxf(2.0, r * 0.22), 41 + i)
			else:
				Crayon.fill_blob(self, c, Vector2(rr, rr), UI.CARD, 31 + i, 0.06)
				Crayon.marker_line(self, ring, Color(UI.INK_SOFT, 0.55), maxf(1.5, r * 0.18), 41 + i)
