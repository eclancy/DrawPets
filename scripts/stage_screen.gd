class_name StageScreen
extends Node2D
## A Beginner fun day on the stage (FunDays) - nobody is scored, and the audience of friendly
## pets cheers for everything:
##   talent  tap trick cards and the pet does them (the ones it knows, and a wave and a dance
##           anyone can do). Each one lights a star; three, and "Take a bow!" - and it bows.
##   dance   everyone from its home dances on stage; tap a move and they all do it. Each move
##           lights a note along the top; when they are all lit, the party's done.
##   parade  dress it up from the wardrobe, then "Parade!" and it walks the catwalk.
## Then confetti, a rosette for joining in (FunDays.join), and a line in its journal.
##
## Many players barely read yet, so it shows rather than tells: for a kid's first three of each
## show a drawn hand (HowTo) taps what to tap, and comes back whenever they rest a while with
## something still to tap; the first three times "Take a bow!" turns up, the hand moves over to
## it. The button that ends the show stands apart at the end of the row and swells, so a long
## row of cards or clothes can never scroll it out of reach.

const ACTS_FOR_A_BOW := 3
## How many moves make a dance party - one lit note each.
const DANCE_MOVES := 6
## Seconds of nothing tapped before the hand comes back.
const IDLE_HINT := 6.0
## How many of each show (and how many bows) a kid is shown the way.
const HINT_TIMES := 3

var game: GameRoot
var kind := "talent"
var home: Dictionary
var pet_id := ""

var pet: Dictionary
var stars: Array[Creature] = []
var crowd: Array[Creature] = []
var _acts := 0
var _done := false
var _buttons: HBoxContainer
var _msg: Label
var _hud_root: Control
var _parading := false
var _bowing := false
var _worn := 0
## The fun day the show began on, so a show still going at midnight counts for it.
var _day: Dictionary
var _layer: CanvasLayer
var _bar: HBoxContainer
## The button that ends the show (Take a bow! / Parade!), outside the scrolling row.
var _finish: Button
## Stars to light (talent) or notes (dance), one per act.
var _pips: HBoxContainer
var _hint: HowTo
var _hint_up := false
## Whether the hand shows now: a kid's first few of this show, or of the bow once it is up.
var _teach := false
var _hint_ids: Array = []
var _hint_presses := 0
var _idle := 0.0
var _last_spot := Vector2(640, 640)


func _ready() -> void:
	pet = PetStore.load_pet(pet_id)
	_day = FunDays.today()
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	var pets := [pet]
	if kind == "dance":
		for id in home["pets"]:
			if id != pet_id and pets.size() < 4:
				var p := PetStore.load_pet(id)
				if not p.is_empty():
					pets.append(p)
	for i in pets.size():
		var c := _creature(pets[i], 200.0 if pets.size() == 1 else 150.0)
		c.position = Vector2(640.0 + (i - (pets.size() - 1) / 2.0) * 220.0, 560)
		stars.append(c)
	if kind == "parade":
		stars[0].position = Vector2(260, 560)
	# The audience sits along the front, clear of the buttons in the middle.
	var friends := FunDays.friends(3)
	for i in friends.size():
		var f := _creature(friends[i], 90.0)
		f.position = Vector2([140.0, 1210.0, 1110.0][i], 690.0)
		f.facing = 1.0 if i == 0 else -1.0
		f.z_index = 5
		crowd.append(f)
	_build_hud()


func _creature(p: Dictionary, h: float) -> Creature:
	var c := Creature.new()
	c.wander = false
	c.confine = false
	c.depth_scale = false
	c.audible = true
	add_child(c)
	c.setup(p, h)
	c.emote.connect(_on_emote)
	return c


func _draw() -> void:
	draw_rect(Rect2(-400, -100, 2080, 920), Color("#e9e0f4"))
	draw_rect(Rect2(-400, 520, 2080, 300), Color("#e8cfa9"))
	for i in 16:
		Crayon.line(self, Vector2(-400, 540 + i * 18), Vector2(1680, 540 + i * 18), Color("#d9bc94"), 3.0, i, 2.0)
	if kind == "parade":
		# The catwalk: a long runner across the stage, gold-edged, that the pet walks down.
		var runner := PackedVector2Array([Vector2(170, 530), Vector2(1110, 530), Vector2(1150, 596),
			Vector2(130, 596)])
		Crayon.pencil_fill(self, runner, Color("#d9739b"), 41)
		for edge: float in [530.0, 596.0]:
			var dx := 40.0 * (edge - 530.0) / 66.0
			Crayon.line(self, Vector2(170 - dx, edge), Vector2(1110 + dx, edge), Color("#e8b84a"), 5.0, int(edge), 1.5)
	else:
		var spot := Crayon.ellipse(Vector2(640, 580), Vector2(420, 60))
		draw_colored_polygon(spot, Color(1, 0.97, 0.75, 0.6))
	for side: float in [-1.0, 1.0]:
		var x0 := 640.0 + side * 1040.0
		var x1 := 640.0 + side * 500.0
		var curtain := PackedVector2Array([Vector2(x0, -100), Vector2(x1, -100), Vector2(x1 + side * 30.0, 300),
			Vector2(x1 - side * 20.0, 560), Vector2(x0, 560)])
		Crayon.pencil_fill(self, curtain, Color("#ef9aa8"), 31 + int(side))
	Crayon.pencil_fill(self, PackedVector2Array([Vector2(-400, -100), Vector2(1680, -100), Vector2(1680, 30),
		Vector2(-400, 30)]), Color("#ef9aa8"), 33)
	# Bunting across the top: it is a celebration, not a contest.
	var colors := [Color("#f7a6c8"), Color("#9cc9ef"), Color("#ffd166"), Color("#a9dd9a")]
	for i in 14:
		var x := 180.0 + i * 66.0
		Crayon.fill(self, PackedVector2Array([Vector2(x, 44), Vector2(x + 52, 44), Vector2(x + 26, 92)]),
			colors[i % 4], 60 + i, 5.0, 1.0, 3.0)


func _build_hud() -> void:
	_layer = CanvasLayer.new()
	add_child(_layer)
	_hud_root = Control.new()
	_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(UI.fit_safe(_hud_root))
	var back := UI.icon_button("tool_back", "Back", go_back, 36, Vector2(100, 84))
	back.position = Vector2(12, 12)
	_hud_root.add_child(back)
	_msg = UI.title("", 46)
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = 104
	_msg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(_msg)
	_pips = HBoxContainer.new()
	_pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pips.add_theme_constant_override("separation", 8)
	_pips.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_pips.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_pips.offset_top = 172
	_hud_root.add_child(_pips)
	# The bottom row: the cards or clothes (scrolling, if there are lots), then the button that
	# ends the show, always in reach. It sits a little up from the edge, so the hand that pokes
	# it (from below, the way a finger comes) stays on the screen.
	_bar = HBoxContainer.new()
	_bar.add_theme_constant_override("separation", 14)
	_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_bar.offset_top = -148
	_bar.offset_bottom = -24
	_bar.offset_left = 220
	_bar.offset_right = -230
	_hud_root.add_child(_bar)
	var scroll := ScrollContainer.new()
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bar.add_child(scroll)
	_buttons = HBoxContainer.new()
	_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buttons.add_theme_constant_override("separation", 10)
	scroll.add_child(_buttons)
	match kind:
		"talent":
			_msg.text = "Tap a trick card!"
			var tricks := Tricks.known(pet)
			for t in ["wave", "dance"]:
				if not tricks.has(t):
					tricks.append(t)
			for t in tricks:
				_buttons.add_child(_card_button(t, tricks.size()))
			_add_pips("icon_star", ACTS_FOR_A_BOW)
		"dance":
			_msg.text = "Tap a dance move!"
			for t in ["dance", "spin", "jump", "wave"]:
				_buttons.add_child(_card_button(t, 4))
			_add_pips("trick_dance", DANCE_MOVES)
		"parade":
			var clothes := Items.available(game.profile, "clothing")
			for id in clothes:
				var item := Items.get_item(id)
				var b := Button.new()
				b.custom_minimum_size = Vector2(96, 100)
				var pic := UI.item_picture(item, 80)
				pic.position = Vector2(8, 10)
				b.add_child(pic)
				b.pressed.connect(wear.bind(item))
				_buttons.add_child(b)
			_finish = _finish_button("icon_wardrobe", "Parade!", parade)
			if clothes.is_empty():
				# Nothing to put on yet: the Parade! button on its own, in the middle.
				_msg.text = "No clothes yet - tap Parade!"
				_buttons.add_child(_finish)
			else:
				_msg.text = "Tap clothes, then Parade!"
				_bar.add_child(_finish)
	if HowTo.first_times(game.profile, "howto_stage_" + kind, HINT_TIMES):
		_teach = true
		# The hand comes in a moment, once the buttons have found their places.
		_idle = IDLE_HINT - 0.6


## A trick card. With lots of them they slim down, so most still fit along the row.
func _card_button(t: String, count := 4) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(116 if count <= 5 else 100, 106)
	b.pressed.connect(act.bind(t))
	b.set_meta("move", t)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	UI.full_rect(col)
	var pic := TextureRect.new()
	pic.texture = Tricks.card_texture(pet, t)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = Vector2(60, 60)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(pic)
	var l := UI.label(Tricks.display_name(t), 18)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(l)
	b.add_child(col)
	return b


## A big orange button, wide enough for its picture and words.
func _finish_button(icon_id: String, text: String, on_press: Callable) -> Button:
	var b := UI.big_icon_button(icon_id, text, on_press)
	b.custom_minimum_size = Vector2((b.get_child(0) as Control).get_combined_minimum_size().x + 48.0, 106)
	b.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return b


## A row of dim pictures along the top, one to light per act: how far the show has got, and how
## much is left, without a number.
func _add_pips(icon_id: String, n: int) -> void:
	for i in n:
		var p := UI.icon(icon_id, 46, "none")
		p.modulate = Color(0.7, 0.68, 0.8, 0.35)
		_pips.add_child(p)


func _light_pip(i: int) -> void:
	if i < 0 or i >= _pips.get_child_count():
		return
	var p := _pips.get_child(i) as Control
	p.modulate = Color.WHITE
	p.pivot_offset = p.size / 2.0
	p.scale = Vector2(1.6, 1.6)
	p.create_tween().tween_property(p, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK)


## Swells and settles, over and over: tap me next.
func _pulse(b: Control) -> void:
	b.pivot_offset = b.custom_minimum_size / 2.0
	var t := b.create_tween().set_loops()
	t.tween_property(b, "scale", Vector2(1.08, 1.08), 0.45).set_trans(Tween.TRANS_SINE)
	t.tween_property(b, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_SINE)


## A trick, a move: done on stage, and the crowd goes wild.
func act(t: String) -> void:
	if _done or _bowing:
		return
	_tapped()
	for c in stars:
		c.do_trick(t)
	_cheer()
	_acts += 1
	_light_pip(_acts - 1)
	if kind == "talent" and _acts == ACTS_FOR_A_BOW:
		_msg.text = "Bravo! Now take a bow!"
		_finish = _finish_button("trick_bow", "Take a bow!", take_bow)
		_bar.add_child(_finish)
		_pulse(_finish)
		if HowTo.first_times(game.profile, "howto_stage_bow", HINT_TIMES):
			_teach = true
			# Once the cheering settles, the hand moves over to the new button.
			_idle = IDLE_HINT - 1.4
	elif kind == "dance" and _acts >= DANCE_MOVES:
		finale()


## The end of the Talent Show: everyone on stage bows to the crowd, then the finale.
func take_bow() -> void:
	if _done or _bowing:
		return
	_bowing = true
	_tapped()
	_clear_buttons()
	_msg.text = "Take a bow, %s!" % pet["name"]
	for c in stars:
		c.do_trick("bow")
	_cheer()
	get_tree().create_timer(1.4).timeout.connect(finale)


func wear(item: Dictionary) -> void:
	if _parading or _done:
		return
	_tapped()
	Wardrobe.put_on(stars[0].pet, item)
	stars[0].rebuild()
	stars[0].perform("celebrate", 0.8)
	Sounds.play("dress")
	_cheer(false)
	_worn += 1
	if _worn == 1 and _finish != null:
		_msg.text = "Looking good! Tap Parade!"
		_pulse(_finish)


## Down the catwalk, left to right, cameras flashing.
func parade() -> void:
	if _parading or _done:
		return
	_parading = true
	_tapped()
	_clear_buttons()
	_msg.text = "Here comes %s!" % pet["name"]
	var c := stars[0]
	c.go_to(Vector2(1000, 560), finale)
	for i in 4:
		get_tree().create_timer(0.6 + i * 0.8).timeout.connect(_flash)


func _flash() -> void:
	Sounds.play_varied("camera", 1.0, 0.1, -4.0)
	_on_emote("twinkle", stars[0].top_global() + Vector2(randf_range(-60, 60), randf_range(0, 60)))
	_cheer(false)


func _cheer(loud := true) -> void:
	Sounds.play_varied("cheer" if loud else "good", 1.0, 0.08, -2.0 if loud else -6.0)
	for f in crowd:
		f.perform("celebrate", 1.2)
		if randf() < 0.6:
			f.say("heart" if randf() < 0.5 else "star")
	if loud:
		for i in 4:
			_on_emote("confetti", Vector2(randf_range(300, 980), randf_range(160, 320)))


## The end: confetti, a rosette for joining in, a line in its journal.
func finale() -> void:
	if _done:
		return
	_done = true
	_drop_hint()
	for c in stars:
		c.perform("celebrate", 2.0)
		c.say("star")
	_cheer()
	for i in 8:
		_on_emote("confetti", Vector2(randf_range(200, 1080), randf_range(140, 360)))
	var words := {"talent": "Star of the show, %s!", "dance": "What a dance party, %s!",
		"parade": "Looking fabulous, %s!"}
	_msg.text = words.get(kind, "Hooray, %s!") % pet["name"]
	# Bigger, and down under the stars - clear of the rosette's toast at the top.
	_msg.add_theme_font_size_override("font_size", 52)
	_msg.offset_top = 236.0
	_msg.offset_bottom = 236.0
	FunDays.join(game, kind, _day)
	for c in stars:
		Journal.add(c.pet, "Joined the %s!" % FunDays.info(kind)["name"])
		Care.played(c.pet)
		PetStore.save_pet(c.pet)
	_clear_buttons()
	var rosette := UI.icon("icon_rosette", 96, "none")
	_buttons.add_child(rosette)
	# Back home comes a moment later: the last move's own tap must not land on it, and the kid
	# should see the confetti and the line first.
	var home_btn := _finish_button("icon_home", "Back home", go_back)
	home_btn.disabled = true
	home_btn.modulate.a = 0.0
	_buttons.add_child(home_btn)
	var t := home_btn.create_tween()
	t.tween_interval(1.6)
	t.tween_callback(home_btn.set.bind("disabled", false))
	t.tween_property(home_btn, "modulate:a", 1.0, 0.3)


## Takes the row away - from inside a press of one of its own buttons, so through UI.retire.
func _clear_buttons() -> void:
	for b in _buttons.get_children():
		if not b.is_queued_for_deletion():
			UI.retire(b)
	if _finish != null and is_instance_valid(_finish) and not _finish.is_queued_for_deletion():
		UI.retire(_finish)
	_finish = null


func _on_emote(k: String, at: Vector2) -> void:
	var e := Emote.new()
	e.kind = k
	e.position = at
	add_child(e)


func go_back() -> void:
	for c in stars:
		PetStore.save_pet(c.pet)
	game.go_place(home["id"], pet_id)


# --- The hand ----------------------------------------------------------------------------------
# One sentence on screen at a time: while the hand is up its caption stands where the message
# does, and the message hides. The resting clock stands still while the hand is up, so after a
# stray touch sends it away it comes back IDLE_HINT later.

func _process(delta: float) -> void:
	if _hint_up:
		if is_instance_valid(_hint):
			return
		_hint_up = false
		_hint = null
		_msg.visible = true
	if not _teach or _done or _parading or _bowing:
		return
	_idle += delta
	if _idle >= IDLE_HINT:
		_show_hint()


## The kid tapped something that counts: the hand can go, and the resting clock starts again.
func _tapped() -> void:
	_idle = 0.0
	_drop_hint()


func _drop_hint() -> void:
	if _hint_up and is_instance_valid(_hint):
		_hint.dismiss()


## What to tap now: the first card (talent, dance); the bow once it is up; clothes then Parade!,
## or just Parade! once something is on.
func _show_hint() -> void:
	_idle = 0.0
	var first: Control = null
	for b in _buttons.get_children():
		if b is Button and not b.is_queued_for_deletion():
			first = b as Control
			break
	var caption := ""
	_hint_ids.clear()
	match kind:
		"talent":
			if _finish != null:
				_hint_ids = [_finish.get_instance_id()]
				caption = "Tap to take a bow!"
			elif first != null:
				_hint_ids = [first.get_instance_id()]
				caption = "Tap a trick card!"
		"dance":
			if first != null:
				_hint_ids = [first.get_instance_id()]
				caption = "Tap a dance move!"
		"parade":
			if _finish == null:
				return
			if _worn == 0 and first != null and first != _finish:
				_hint_ids = [first.get_instance_id(), _finish.get_instance_id()]
				caption = "Tap clothes, then Parade!"
			else:
				_hint_ids = [_finish.get_instance_id()]
				caption = "Tap Parade!"
	if _hint_ids.is_empty():
		return
	_hint = HowTo.new()
	if _hint_ids.size() > 1:
		_hint.gesture = "taps"
		for id in _hint_ids:
			_hint.targets.append(_spot.bind(id))
	else:
		_hint.gesture = "tap"
		_hint.at = _spot.bind(_hint_ids[0])
	_hint.caption = caption
	_hint.caption_y = _msg.offset_top - 4.0
	_hint.hand_height = 120.0
	_hint.period = 1.6
	_hint.until_touch = true
	_hint.on_press = _hint_press
	_hint_presses = 0
	# Straight on the layer, so its points are the buttons' own screen points.
	_layer.add_child(_hint)
	_hint_up = true
	_msg.visible = false


## Where the hand pokes a button: across the middle, at the top, so the hand under it stays on
## screen. By id, so a button that has gone just leaves the hand where it was.
func _spot(id: int) -> Vector2:
	var c := instance_from_id(id) as Control
	if c == null or not c.is_inside_tree():
		return _last_spot
	var r := c.get_global_rect()
	_last_spot = Vector2(r.get_center().x, r.position.y + 12.0)
	return _last_spot


## The hand's poke does what a finger's would, so the kid sees what a tap does: the button gives,
## and the first time round the pets do that move (it does not count towards the show).
func _hint_press() -> void:
	if _hint_ids.is_empty() or _done:
		return
	var b := instance_from_id(_hint_ids[_hint_presses % _hint_ids.size()]) as Control
	_hint_presses += 1
	if b == null or b == _finish:
		return
	b.pivot_offset = b.size / 2.0
	var t := b.create_tween()
	t.tween_property(b, "scale", Vector2(0.9, 0.9), 0.08)
	t.tween_property(b, "scale", Vector2.ONE, 0.16)
	if _hint_presses == 1 and b.has_meta("move"):
		for c in stars:
			c.do_trick(b.get_meta("move"))
