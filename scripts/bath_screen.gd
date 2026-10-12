class_name BathScreen
extends Node2D
## Bath day (BathDay, .ai/pet-life.md): the pet at its bath spot - a tub in the bathroom if its
## home has a house, else its place's watering hole - for the whole routine, one step at a time:
## clip its nails (if it has any), wash it, brush its teeth, groom its coat.
##
## Each step's tool works its way over the pet by itself, slowly. Rub with a finger and the tool
## goes where you rub - and faster. Washing takes the mud off; then it is rinsed and shakes itself
## dry. At the end it glints, the clean need is full for the week (Care.bathed), and home it goes.

## Slow enough to watch it work its way round; a finger is quicker.
const AUTO_SPEED := 120.0
const REACH_AUTO := 34.0
const REACH_FINGER := 54.0
## Where the pet stands in the water, on the 1280 x 720 design screen.
const STAND := Vector2(640, 612)

var game: GameRoot
var home: Dictionary
var pet_id := ""

var pet: Dictionary
var creature: Creature
var _spot := "pond"
var _steps: Array = []
var _step := -1
var _points: Array[Vector2] = []
var _done_pts: Array[bool] = []
var _in_order := false
var _tool: Sprite2D
var _finger_down := false
var _finger := Vector2.ZERO
var _wait := 0.0
var _then := Callable()
var _finished := false
var _time := 0.0
var _hint: Label
var _title: Label
var _bar: ProgressBar
var _chips: Array[Control] = []
var _home_btn: Button
var _hud_root: Control


func _ready() -> void:
	pet = PetStore.load_pet(pet_id)
	Stats.ensure(pet)
	_spot = BathDay.spot(home)
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	if _spot != "tub":
		var painter := PlacePainter.new()
		painter.place_id = home["place"]
		add_child(painter)
	var back := BathPainter.new()
	back.kind = _spot
	add_child(back)
	creature = Creature.new()
	creature.wander = false
	creature.confine = false
	creature.depth_scale = false
	creature.position = STAND
	add_child(creature)
	creature.setup(pet)
	creature.audible = true
	creature.fit_in(Vector2(400, 330))
	creature.emote.connect(_on_emote)
	var front := BathPainter.new()
	front.kind = _spot
	front.front = true
	add_child(front)
	_tool = Sprite2D.new()
	_tool.z_index = 20
	_tool.visible = false
	add_child(_tool)
	_steps = BathDay.steps(pet)
	_build_hud()
	creature.say("hello")
	Sounds.play_varied("splash", 1.0, 0.05, -4.0)
	_pause(1.0, _next_step)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud_root = Control.new()
	_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.fit_safe(_hud_root))
	var back := UI.icon_button("tool_back", "Not now", go_home, 36, Vector2(100, 84))
	back.position = Vector2(12, 12)
	_hud_root.add_child(back)
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.offset_top = 12
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 6)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(col)
	_title = UI.title("Bath day for %s %s!" % [pet["name"], BathDay.where(_spot)], 30)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for s in _steps:
		var chip := PanelContainer.new()
		chip.add_theme_stylebox_override("panel", UI._box(UI.PAPER, UI.INK, 2, 14, 6))
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(UI.icon(s[2], 50, "none"))
		chip.modulate = Color(1, 1, 1, 0.45)
		_chips.append(chip)
		row.add_child(chip)
	col.add_child(row)
	_bar = ProgressBar.new()
	_bar.max_value = 1.0
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(360, 16)
	_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(_bar)
	_hint = UI.title("", 26)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_hint.offset_bottom = -20
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(_hint)
	_home_btn = UI.big_icon_button("icon_home", "Back home", go_home)
	_home_btn.custom_minimum_size = Vector2(320, 90)
	_home_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_home_btn.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_home_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_home_btn.offset_bottom = -90
	_home_btn.visible = false
	_hud_root.add_child(_home_btn)


func fit_safe_area() -> void:
	UI.fit_safe(_hud_root)


# --- The steps -------------------------------------------------------------------------------

func _next_step() -> void:
	_step += 1
	if _step > 0:
		_chips[_step - 1].modulate = Color.WHITE
		_chips[_step - 1].add_theme_stylebox_override("panel", UI._box(UI.GOOD, UI.INK, 2, 14, 6))
	if _step >= _steps.size():
		_all_done()
		return
	var s: Array = _steps[_step]
	_chips[_step].modulate = Color.WHITE
	_chips[_step].add_theme_stylebox_override("panel", UI._box(Color("#fff0c2"), UI.ACCENT, 3, 14, 6))
	var tex := Items.art_texture(s[2])
	_tool.texture = tex
	_tool.scale = Vector2.ONE * (120.0 / maxf(tex.get_width(), tex.get_height()))
	_tool.position = STAND + Vector2(330, -160)
	_tool.visible = true
	_hint.text = "%s  -  rub to help, or just watch!" % s[1]
	if s[0] == "teeth":
		creature.perform("open_wide", 999.0)
	else:
		creature.perform("petted", 999.0)
	# Wait a moment for the pose to settle before working out where the tool goes.
	_pause(0.35, _plan.bind(s[0]))


## Where the tool has to get to for this step, on the pet as it is now.
func _plan(kind: String) -> void:
	_points.clear()
	_in_order = kind == "teeth"
	match kind:
		"nails":
			for part in creature.parts:
				if part.type in BathDay.NAILS:
					_points.append(_tip(part))
		"teeth":
			var m := creature.mouth_global()
			var w := maxf(creature.height_px * 0.08, 16.0)
			for i in 6:
				_points.append(m + Vector2(-w if i % 2 == 0 else w, (i / 2 - 1) * 4.0))
		_:
			# Over everything it is drawn on, in rows, back and forth.
			var box := creature._box().grow(-6.0)
			var gap := clampf(minf(box.size.x, box.size.y) / 6.0, 26.0, 46.0)
			var rows := int(box.size.y / gap) + 1
			var cols := int(box.size.x / gap) + 1
			for r in rows:
				for k in cols:
					var c := k if r % 2 == 0 else cols - 1 - k
					var p := box.position + Vector2(c * gap + gap * 0.5, r * gap + gap * 0.5)
					if creature.on_drawing(p):
						_points.append(p)
	if _points.is_empty():
		_points.append(creature.global_position + Vector2(0, -creature.height_px * 0.5))
	_done_pts.clear()
	for p in _points:
		_done_pts.append(false)


## The end of a foot, hand or claw furthest from its joint - where the nails are.
func _tip(part: CreaturePart) -> Vector2:
	var g := part.sprite.get_global_transform()
	var r := part.sprite.get_rect()
	var best := part.global_position
	for corner in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		var p: Vector2 = g * corner
		if p.distance_to(part.global_position) > best.distance_to(part.global_position):
			best = p
	return best.lerp(part.global_position, 0.15)


func _process(delta: float) -> void:
	_time += delta
	if _wait > 0.0:
		_wait -= delta
		if _wait <= 0.0:
			var then := _then
			_then = Callable()
			if then.is_valid():
				then.call()
		return
	if _finished or _step < 0 or _step >= _steps.size() or _done_pts.is_empty():
		return
	var kind: String = _steps[_step][0]
	var reach := REACH_AUTO
	if _finger_down:
		_tool.position = _tool.position.lerp(_finger, minf(1.0, delta * 18.0))
		reach = REACH_FINGER
	else:
		var next := _done_pts.find(false)
		if next >= 0:
			_tool.position = _tool.position.move_toward(_points[next], AUTO_SPEED * delta)
	if kind in ["wash", "groom", "teeth"]:
		_tool.rotation = sin(_time * 14.0) * 0.18
	var done := 0
	for i in _points.size():
		if _done_pts[i]:
			done += 1
			continue
		if _in_order and i != _done_pts.find(false):
			continue
		if _tool.position.distance_to(_points[i]) < reach:
			_done_pts[i] = true
			done += 1
			_did(kind, _points[i])
	_bar.value = float(done) / _points.size()
	if done >= _points.size():
		_step_done(kind)


## One spot done: a snip, a froth of bubbles, a sparkle.
func _did(kind: String, at: Vector2) -> void:
	match kind:
		"nails":
			Sounds.play_varied("snip", 1.0, 0.08)
			_on_emote("twinkle", at + Vector2(0, -10))
		"wash":
			_on_emote("bubble", at + Vector2(randf_range(-14, 14), randf_range(-14, 6)))
			if randf() < 0.4:
				Sounds.play_varied("scrub", 1.0, 0.1)
			if Mud.scrub_near(creature, at, 70.0):
				creature.refresh_mud()
		"teeth":
			Sounds.play_varied("brush", 1.5, 0.08)
			_on_emote("bubble", at + Vector2(0, -8))
		"groom":
			if randf() < 0.5:
				_on_emote("twinkle", at)
			if randf() < 0.35:
				Sounds.play_varied("brush", 1.0, 0.1)


func _step_done(kind: String) -> void:
	_tool.visible = false
	_bar.value = 1.0
	creature.interrupt()
	match kind:
		"wash":
			# A rinse, then it shakes itself dry.
			Mud.clear(pet)
			creature.refresh_mud()
			Sounds.play_varied("splash", 1.1, 0.05)
			for i in 8:
				_on_emote("drop", creature.global_position + Vector2(randf_range(-0.4, 0.4) * creature.height_px,
					-randf_range(0.3, 1.0) * creature.height_px))
			_hint.text = "Rinse... and shake!"
			_pause(0.9, _shake)
		"teeth":
			Sounds.play("good")
			_on_emote("twinkle", creature.mouth_global())
			creature.say("heart")
			_pause(1.0, _next_step)
		_:
			creature.say("heart")
			_pause(0.9, _next_step)


func _shake() -> void:
	Sounds.play("shake")
	creature.perform("shake", 1.3)
	_pause(1.7, _next_step)


func _all_done() -> void:
	_finished = true
	_tool.visible = false
	_bar.value = 1.0
	Sounds.play("clean")
	creature.perform("celebrate", 2.0)
	creature.say("heart")
	for i in 6:
		_on_emote("twinkle", creature.global_position + Vector2(randf_range(-0.5, 0.5) * creature.height_px,
			-randf_range(0.2, 1.0) * creature.height_px))
	Care.bathed(pet)
	Mud.clear(pet)
	var before := Stats.trust(pet)
	pet["love"] = int(pet.get("love", 0)) + 2
	if Stats.trust(pet) > before:
		game.reward(5 * Stats.trust(pet), "%s trusts you more! (%d hearts)" % [pet["name"], Stats.trust(pet)])
	Journal.add_once(pet, "first_bath_day", "Had its first bath day - squeaky clean!")
	game.reward_daily("bath_day", 1, 3, "Bath day done - %s is squeaky clean!" % pet["name"])
	PetStore.save_pet(pet)
	_hint.text = "All done - squeaky clean! See you next bath day."
	_home_btn.visible = true


func _pause(seconds: float, then: Callable) -> void:
	_wait = seconds
	_then = then


# --- Fingers ---------------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_finger_down = event.pressed
		_finger = get_global_mouse_position()
	elif event is InputEventMouseMotion:
		_finger = get_global_mouse_position()


## The demo kid's finger (and a test's): rub at `at` for a moment.
func rub_at(at: Vector2, down := true) -> void:
	_finger_down = down
	_finger = at


func go_home() -> void:
	if not is_inside_tree():
		return
	PetStore.save_pet(pet)
	game.go_place(home["id"], pet_id)


func go_back() -> void:
	go_home()


func _exit_tree() -> void:
	PetStore.save_pet(pet)


func _on_emote(kind: String, at: Vector2) -> void:
	var e := Emote.new()
	e.kind = kind
	e.position = at
	add_child(e)


## The bath spot, in two layers: the back (behind the pet: a bathroom and the tub's far side, or
## the pool's far bank and water) and the front (in front of it: the tub's side, or the water
## its legs stand in and the near bank). Crayon, light, no outlines darker than ~30% value.
class BathPainter extends Node2D:
	var kind := "pond"
	var front := false

	const C := Vector2(640, 612)
	## How far above its feet the tub's water comes: up to its tummy, bubbles and all.
	const TUB_TOP := 95.0
	const R := Vector2(340, 84)
	const WATER := {"pond": Color("#9fd3e6"), "rockpool": Color("#a6dcef"), "spring": Color("#aee2ef"),
		"oasis": Color("#8fd3e6"), "crystal": Color("#c9c1f2"), "cloud": Color("#d8ecfb"),
		"shell": Color("#bfe6f2"), "tub": Color("#d6ecfb")}
	const BANK := {"pond": Color("#b8d98f"), "rockpool": Color("#c9c4d6"), "spring": Color("#cfd3e2"),
		"oasis": Color("#f2d7a0"), "crystal": Color("#d3c6ee"), "cloud": Color("#fbfdff"),
		"shell": Color("#f7c6d4"), "tub": Color("#fffdf6")}

	func _ready() -> void:
		z_index = 10 if front else 0

	func _draw() -> void:
		if kind == "tub":
			_tub()
			return
		var water: Color = WATER.get(kind, WATER["pond"])
		var bank: Color = BANK.get(kind, BANK["pond"])
		if not front:
			if kind == "shell":
				var fan := PackedVector2Array([C + Vector2(-R.x * 1.05, 10)])
				for i in 13:
					var a := PI + PI * i / 12.0
					fan.append(C + Vector2(cos(a) * R.x * 1.05, sin(a) * 300.0 - 10.0))
				fan.append(C + Vector2(R.x * 1.05, 10))
				Crayon.fill(self, fan, bank, 31, 12.0, 3.0, 6.0)
				for i in 7:
					var a := PI + PI * (i + 1) / 8.0
					Crayon.line(self, C, C + Vector2(cos(a) * R.x, sin(a) * 280.0), bank.darkened(0.12), 6.0, 40 + i, 3.0)
			Crayon.fill_blob(self, C, R * 1.12, bank, 11, 0.06)
			Crayon.fill_blob(self, C, R, water, 12, 0.04)
			_decor_back()
		else:
			# The near half of the water, see-through over its feet, and the near bank.
			var near := PackedVector2Array()
			for i in 25:
				var a := PI * i / 24.0
				near.append(C + Vector2(cos(a) * R.x * 0.98, sin(a) * R.y * 0.98 - 22.0 * sin(a)))
			draw_colored_polygon(near, Color(water, 0.62))
			var rim := PackedVector2Array()
			for i in 25:
				var a := PI * i / 24.0
				rim.append(C + Vector2(cos(a) * R.x * 1.06, sin(a) * R.y * 1.06))
			Crayon.marker_line(self, rim, bank.darkened(0.06), 16.0, 13, false)
			for i in 5:
				var x := C.x - R.x * 0.6 + i * R.x * 0.3
				Crayon.line(self, Vector2(x - 26, C.y + 26), Vector2(x + 26, C.y + 26), Color(1, 1, 1, 0.7), 4.0, 50 + i, 2.0)
			_decor_front()

	func _decor_back() -> void:
		match kind:
			"pond":
				for i in 4:
					var base := C + Vector2(-R.x * 1.0 + i * 22.0, -R.y * 0.6)
					Crayon.line(self, base, base + Vector2(i * 6.0 - 10.0, -110.0 - i * 18.0), Color("#9bbf7a"), 6.0, 60 + i, 2.0)
			"rockpool", "spring":
				for i in 6:
					var at := C + Vector2(cos(PI + PI * i / 5.0) * R.x * 1.08, sin(PI + PI * i / 5.0) * R.y * 1.1)
					Crayon.fill_blob(self, at, Vector2(56, 34), Color("#c4bfcf"), 70 + i, 0.2)
			"oasis":
				var top := C + Vector2(R.x * 0.95, -320)
				Crayon.line(self, C + Vector2(R.x * 1.05, -R.y * 0.4), top, Color("#d8b48a"), 22.0, 80, 8.0)
				for i in 5:
					var a := -PI * 0.95 + PI * 0.95 * i / 4.0
					var tip := top + Vector2(cos(a) * 140.0, sin(a) * 60.0 + 50.0)
					Crayon.fill(self, PackedVector2Array([top, top.lerp(tip, 0.5) + Vector2(0, -22), tip,
						top.lerp(tip, 0.5) + Vector2(0, 14)]), Color("#8fcf7f"), 81 + i, 6.0, 2.0, 4.0)
			"crystal":
				for i in 4:
					var x := C.x - R.x + i * R.x * 0.66
					var h := 120.0 + (i % 2) * 70.0
					Crayon.fill(self, PackedVector2Array([Vector2(x - 24, C.y - R.y * 0.7), Vector2(x, C.y - R.y * 0.7 - h),
						Vector2(x + 24, C.y - R.y * 0.7)]), [Color("#b7a6f0"), Color("#9fdcf0"), Color("#f2b6e4")][i % 3], 90 + i, 6.0, 2.0, 4.0)

	func _decor_front() -> void:
		match kind:
			"spring":
				for i in 4:
					var at := C + Vector2(-R.x * 0.6 + i * R.x * 0.4, -R.y * 1.6)
					Crayon.scribble(self, at, Vector2(80, 120), Color(1, 1, 1, 0.45), 100 + i, 6.0)
			"cloud":
				for i in 5:
					var at := C + Vector2(-R.x + i * R.x * 0.5, R.y * 0.7)
					Crayon.fill_blob(self, at, Vector2(70, 40), Color(1, 1, 1, 0.92), 110 + i, 0.12)

	## A bathroom: tiled wall, wooden floor, a window, a towel - and a tub on little feet.
	func _tub() -> void:
		if not front:
			draw_rect(Rect2(-500, -200, 2280, 760), Color("#efe8f6"))
			for i in 40:
				var x := -500.0 + i * 64.0
				draw_line(Vector2(x, -200), Vector2(x, 560), Color("#e2d8ee"), 3.0)
			for j in 13:
				var y := -200.0 + j * 64.0
				draw_line(Vector2(-500, y), Vector2(1780, y), Color("#e2d8ee"), 3.0)
			draw_rect(Rect2(-500, 560, 2280, 400), Color("#ead6b8"))
			for i in 9:
				Crayon.line(self, Vector2(-500, 590 + i * 28), Vector2(1780, 590 + i * 28), Color("#dcc4a0"), 4.0, 120 + i, 3.0)
			Crayon.fill(self, Crayon.rounded_rect(Rect2(130, 90, 240, 200), 16), Color("#fffdf6"), 130, 8.0, 1.0, 4.0)
			Crayon.fill(self, Crayon.rounded_rect(Rect2(150, 110, 200, 160), 10), Color("#bfe3f5"), 131, 8.0, 1.0, 4.0)
			Crayon.line(self, Vector2(250, 110), Vector2(250, 270), Color("#fffdf6"), 8.0, 132, 1.0)
			Crayon.line(self, Vector2(1000, 230), Vector2(1180, 230), Color("#c9c6d8"), 8.0, 133, 1.0)
			Crayon.fill(self, PackedVector2Array([Vector2(1030, 230), Vector2(1150, 230), Vector2(1140, 400),
				Vector2(1040, 400)]), Color("#f7b6cc"), 134, 8.0, 2.0, 4.0)
			# The tub's far side and its water.
			Crayon.fill_blob(self, C + Vector2(0, -TUB_TOP), Vector2(370, 70), Color("#fffdf6"), 135, 0.02)
			Crayon.fill_blob(self, C + Vector2(0, -TUB_TOP), Vector2(330, 52), WATER["tub"], 136, 0.03)
		else:
			var side := PackedVector2Array()
			for i in 25:
				var a := PI * i / 24.0
				side.append(C + Vector2(cos(a) * 370.0, -TUB_TOP + sin(a) * (TUB_TOP + 100.0)))
			draw_colored_polygon(side, Color("#fbfdff"))
			Crayon.fill(self, side, Color("#eef4fa"), 140, 10.0, 0.0, 6.0)
			Crayon.marker_line(self, side, Color("#c9d6e4"), 8.0, 141, false)
			for x in [C.x - 250.0, C.x + 250.0]:
				Crayon.fill_blob(self, Vector2(x, C.y + 112), Vector2(30, 24), Color("#f2c46a"), 142 + int(x), 0.1)
			for i in 14:
				var at := C + Vector2(-340.0 + i * 52.0, -TUB_TOP - 2.0 + Crayon.noise(150, i) * 8.0)
				var r := 18.0 + absf(Crayon.noise(151, i)) * 16.0
				draw_circle(at, r, Color(1, 1, 1, 0.95))
				draw_arc(at, r, 0.0, TAU, 20, Color("#a9cfee"), 3.0, true)
