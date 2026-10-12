class_name StageScreen
extends Node2D
## A Beginner fun day on the stage (FunDays) - nobody is scored, and the audience of friendly
## pets cheers for everything:
##   talent  the pet shows off its tricks (the cards it knows, and a wave and a dance anyone can
##           do), then takes a bow.
##   dance   everyone from its home dances on stage; tap a move and they all do it.
##   parade  dress it up from the wardrobe, then it parades down the catwalk.
## Then confetti, a rosette for joining in (FunDays.join), and a line in its journal.

const ACTS_FOR_A_BOW := 3

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


func _ready() -> void:
	pet = PetStore.load_pet(pet_id)
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
	var friends := FunDays.friends(3)
	for i in friends.size():
		var f := _creature(friends[i], 90.0)
		f.position = Vector2([150.0, 1130.0, 1010.0][i], 690.0)
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
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud_root = Control.new()
	_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.fit_safe(_hud_root))
	var back := UI.icon_button("tool_back", "Back", go_back, 36, Vector2(100, 84))
	back.position = Vector2(12, 12)
	_hud_root.add_child(back)
	_msg = UI.title("", 34)
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = 104
	_msg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(_msg)
	var scroll := ScrollContainer.new()
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	scroll.offset_top = -124
	scroll.offset_left = 230
	scroll.offset_right = -230
	_hud_root.add_child(scroll)
	_buttons = HBoxContainer.new()
	_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buttons.add_theme_constant_override("separation", 10)
	scroll.add_child(_buttons)
	match kind:
		"talent":
			_msg.text = "The Talent Show! Show everyone what %s can do." % pet["name"]
			for t in Tricks.known(pet):
				_buttons.add_child(_card_button(t))
			for t in ["wave", "dance"]:
				if not Tricks.knows(pet, t):
					_buttons.add_child(_card_button(t))
		"dance":
			_msg.text = "Dance Party! Tap a move - everybody does it!"
			for t in ["dance", "spin", "jump", "wave"]:
				_buttons.add_child(_card_button(t))
		"parade":
			_msg.text = "Costume Parade! Dress %s up, then off down the catwalk." % pet["name"]
			for id in Items.available(game.profile, "clothing"):
				var item := Items.get_item(id)
				var b := Button.new()
				b.custom_minimum_size = Vector2(96, 100)
				var pic := UI.item_picture(item, 80)
				pic.position = Vector2(8, 10)
				b.add_child(pic)
				b.pressed.connect(wear.bind(item))
				_buttons.add_child(b)
			if Items.available(game.profile, "clothing").is_empty():
				_buttons.add_child(UI.label("No clothes yet - a parade in its own coat!", 22))
			var go := UI.big_icon_button("icon_wardrobe", "Parade!", parade)
			go.custom_minimum_size = Vector2(220, 96)
			_buttons.add_child(go)


func _card_button(t: String) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(116, 106)
	b.pressed.connect(act.bind(t))
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


## A trick, a move: done on stage, and the crowd goes wild.
func act(t: String) -> void:
	if _done:
		return
	for c in stars:
		c.do_trick(t)
	_cheer()
	_acts += 1
	if kind == "talent" and _acts == ACTS_FOR_A_BOW:
		_msg.text = "Bravo! One more, or take a bow?"
		var bow := UI.big_icon_button("trick_bow", "Take a bow!", finale)
		bow.custom_minimum_size = Vector2(240, 96)
		_buttons.add_child(bow)
		_buttons.move_child(bow, 0)
	elif kind == "dance" and _acts >= 6:
		finale()


func wear(item: Dictionary) -> void:
	if _parading or _done:
		return
	Wardrobe.put_on(stars[0].pet, item)
	stars[0].rebuild()
	stars[0].perform("celebrate", 0.8)
	Sounds.play("dress")
	_cheer(false)


## Down the catwalk, left to right, cameras flashing.
func parade() -> void:
	if _parading or _done:
		return
	_parading = true
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
	for c in stars:
		c.perform("celebrate", 2.0)
		c.say("star")
	_cheer()
	for i in 8:
		_on_emote("confetti", Vector2(randf_range(200, 1080), randf_range(140, 360)))
	var words := {"talent": "Star of the show, %s!", "dance": "What a dance party, %s!",
		"parade": "Looking fabulous, %s!"}
	_msg.text = words.get(kind, "Hooray, %s!") % pet["name"]
	FunDays.join(game, kind)
	for c in stars:
		Journal.add(c.pet, "Joined the %s!" % FunDays.info(kind)["name"])
		Care.played(c.pet)
		PetStore.save_pet(c.pet)
	for b in _buttons.get_children():
		b.queue_free()
	var rosette := UI.icon("icon_rosette", 96, "none")
	_buttons.add_child(rosette)
	var home_btn := UI.big_icon_button("icon_home", "Back home", go_back)
	home_btn.custom_minimum_size = Vector2(280, 96)
	_buttons.add_child(home_btn)


func _on_emote(k: String, at: Vector2) -> void:
	var e := Emote.new()
	e.kind = k
	e.position = at
	add_child(e)


func go_back() -> void:
	for c in stars:
		PetStore.save_pet(c.pet)
	game.go_place(home["id"], pet_id)
