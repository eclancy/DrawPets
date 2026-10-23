class_name BathScreen
extends Node2D
## Bath day (BathDay, .ai/pet-life.md): the pet at its bath spot - a tub in the bathroom if its
## home has a house, else its place's watering hole - for the whole routine, one step at a time:
## clip its nails (if it has any), wash it, brush its teeth, groom its coat.
##
## Each step's tool comes in beside the pet and works its way over it by itself, slowly. Rub on
## the pet (or pick the tool up) with a finger and the tool goes where you rub - and faster. Washing takes the mud off; then it is rinsed and shakes itself
## dry. At the end it glints, the clean need is full for the week (Care.bathed), and home it goes.
##
## What to do is shown, not told - players start at 7 and many barely read. Soft rings on the pet
## mark where the tool still has to go (its paws, all over, side to side at its mouth) and pop as
## it gets there; a finger's help gets more bubbles and a heart now and then; each step ends with
## its chip popping green and a word saying so. For a kid's first three baths a drawn hand
## (HowTo) rubs the tool over the next ring itself - the tool really follows it, so it is the
## real move - until the kid touches, and it comes back if they rest.

## Slow enough to watch it work its way round; a finger is quicker.
const AUTO_SPEED := 120.0
const REACH_AUTO := 34.0
const REACH_FINGER := 54.0
## Where the pet stands in the water, on the 1280 x 720 design screen.
const STAND := Vector2(640, 612)
## In the tub its paws are under the water and the bubbles: for its nails it stands up, this
## much higher, where the kid can see them. (A small pet also sits up a little for the rest, so
## what is being washed is not all under the bubbles - see _lift_for.)
const LIFT := 140.0
## In the tub, spots lower than this are under its front and the bubbles: no rings there.
const WATERLINE := STAND.y - BathPainter.TUB_TOP - 20.0
## How far from the pet a finger still steers the tool. Further off (a hand resting on the tub)
## the tool carries on by itself rather than stopping dead.
const NEAR_PET := 80.0
## A press this near the tool picks it up: it then goes wherever that finger drags it, as a
## sponge in a hand would, until the finger lifts.
const GRAB := 90.0
## Where each step's tool comes in, from its first ring: just off it, so nothing is done yet.
const TOOL_START := Vector2(64, -48)
## How fast the hand moves on to the next ring: a pace a kid can watch and join in with. It is
## there to show the move, not to do the bath for them.
const HAND_SPEED := 170.0
## The hand comes back after this long with no finger down, while a step is going.
const IDLE_BACK := 6.0
## Every this many spots a finger (or the hand) does, a heart: it likes being helped.
const HEART_EVERY := 5
## The word that says a step is done: a green that reads on the light bathroom and the water.
const DONE_GREEN := Color("#4f9e47")

var game: GameRoot
var home: Dictionary
var pet_id := ""
## A Beginner Spa Day (FunDays): the same routine, bubblier, whatever day its bath is.
var spa := false

var pet: Dictionary
var creature: Creature
var _spot := "pond"
var _steps: Array = []
var _step := -1
var _points: Array[Vector2] = []
var _done_pts: Array[bool] = []
var _in_order := false
var _tool: Sprite2D
var _tool_scale := 1.0
var _finger_down := false
var _finger := Vector2.ZERO
## The finger now down picked the tool up (pressed on it), so it steers it anywhere.
var _holding := false
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
var _marks: Marks
## The hand showing how (HowTo), while it is up; and whether this bath shows it at all.
var _how: HowTo
var _teach := false
var _idle := 0.0
## Where the hand's fingertip is (world), and the spot it rubs round on its way to the next ring.
var _hand_at := Vector2.ZERO
var _hand_anchor := Vector2.ZERO
var _helped := 0
var _lifted := 0.0
## While the hand's caption fades out, the line at the bottom waits, so the two never overlap.
var _hand_fade := 0.0


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
	# Over the tub's front and bubbles, under the tool.
	_marks = Marks.new()
	_marks.z_index = 15
	add_child(_marks)
	_tool = Sprite2D.new()
	_tool.z_index = 20
	_tool.visible = false
	add_child(_tool)
	_steps = BathDay.steps(pet)
	_teach = HowTo.first_times(game.profile, "howto_bath", 3)
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
	_title = UI.title(("Spa Day for %s %s!" if spa else "Bath day for %s %s!") % [pet["name"], BathDay.where(_spot)], 30)
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
	_hint = UI.title("", 28)
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
	if _step >= _steps.size():
		_all_done()
		return
	var s: Array = _steps[_step]
	_chips[_step].modulate = Color.WHITE
	_chips[_step].add_theme_stylebox_override("panel", UI._box(Color("#fff0c2"), UI.ACCENT, 3, 14, 6))
	var tex := Items.art_texture(s[2])
	_tool.texture = tex
	_tool_scale = 120.0 / maxf(tex.get_width(), tex.get_height())
	# It comes in beside the pet once the pose has settled (_plan), not off across the room.
	_tool.visible = false
	# "Rub its paws!": where a finger helps. The chip (the tool) says which step it is.
	_say(s[3])
	if s[0] == "teeth":
		creature.perform("open_wide", 999.0)
	else:
		creature.perform("petted", 999.0)
	# In the tub: up out of the bubbles for its nails, back in after.
	var moved := _lift(_lift_for(s[0]))
	# Wait a moment for the pose (and the hop) to settle before working out where the tool goes.
	_pause(0.75 if moved else 0.35, _plan.bind(s[0]))


## How high it stands in the tub for a step: right up out of the bubbles for its nails; for the
## rest, just high enough that two thirds of its drawing is above the water - a low, small pet
## would otherwise be washed and brushed under the bubbles, where nobody can see it happen.
## (Where its drawing is comes from the parts' shapes, never what they look like: rule 4.)
func _lift_for(kind: String) -> float:
	if _spot != "tub":
		return 0.0
	if kind == "nails":
		return LIFT
	# Its drawing, top to bottom, on a coarse grid - each spot as a height above its feet.
	var box := creature._box()
	var ys: Array[float] = []
	for r in 12:
		for c in 12:
			var p := box.position + box.size * Vector2((c + 0.5) / 12.0, (r + 0.5) / 12.0)
			if creature.on_drawing(p):
				ys.append(p.y - creature.position.y)
	if ys.is_empty():
		return 0.0
	var two_thirds := ys[int(ys.size() * 0.66)]
	return clampf(STAND.y + two_thirds - WATERLINE, 0.0, LIFT)


## Up out of the water, or back down into it. True if it moved.
func _lift(height: float) -> bool:
	if absf(height - _lifted) < 2.0:
		return false
	var up := height > _lifted
	_lifted = height
	var t := create_tween()
	t.tween_property(creature, "position:y", STAND.y - height, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if up:
		Sounds.play_varied("hop", creature._size_pitch(), 0.05)
	else:
		Sounds.play_varied("splash", 1.0, 0.05)
	return true


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
			# Side to side across its mouth, further apart than the brush reaches: a finger has to
			# really brush back and forth, not just touch once.
			var m := creature.mouth_global()
			var w := maxf(creature.height_px * 0.1, 40.0)
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
					# Not under the tub's side: a ring there would float on the tub.
					if creature.on_drawing(p) and not (_spot == "tub" and p.y > WATERLINE):
						_points.append(p)
	if _points.is_empty():
		_points.append(creature.global_position + Vector2(0, -creature.height_px * 0.5))
	_done_pts.clear()
	for p in _points:
		_done_pts.append(false)
	_marks.points = _points
	_marks.done = _done_pts
	_marks.in_order = _in_order
	_marks.radius = 9.0 if kind in ["wash", "groom"] else 16.0
	_helped = 0
	_idle = 0.0
	# The tool pops in just beside the first ring - near enough the pet that a finger pressing
	# where the hand presses steers it straight away, far enough that the ring is not done yet.
	var zone := creature._box().grow(NEAR_PET * 0.5)
	var start := _points[0] + TOOL_START
	_tool.position = start.clamp(zone.position, zone.end)
	_tool.scale = Vector2.ONE * _tool_scale * 0.3
	_tool.visible = true
	create_tween().tween_property(_tool, "scale", Vector2.ONE * _tool_scale, 0.22) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Sounds.play_varied("pickup", 1.1, 0.05)
	if _teach and not _finger_down:
		_show_hand()


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
	if _how != null and not is_instance_valid(_how):
		_how = null
	# One sentence on screen at a time: the hand's caption stands in for the line at the bottom.
	_hand_fade -= delta
	_hint.visible = _how == null and _hand_fade <= 0.0
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
	var next := _done_pts.find(false)
	var reach := REACH_AUTO
	# A finger on (or near) the pet steers the tool, and so does one that picked the tool up;
	# one resting further off leaves it be, so the step never stops dead under a hand on the tub.
	var helping := _finger_down and (_holding or creature._box().grow(NEAR_PET).has_point(_finger))
	if helping:
		_tool.position = _tool.position.lerp(_finger, minf(1.0, delta * 18.0))
		reach = REACH_FINGER
	elif _how != null and next >= 0:
		# The hand rubs round the next ring the way a kid would, and the tool goes with it.
		_hand_anchor = _hand_anchor.move_toward(_points[next], HAND_SPEED * delta)
		var amp := 8.0 if _in_order else 30.0
		_hand_at = _hand_anchor + Vector2(sin(_time * TAU / 0.7) * amp, sin(_time * TAU / 0.35) * amp * 0.2)
		_tool.position = _tool.position.lerp(_hand_at, minf(1.0, delta * 18.0))
		helping = true
	elif next >= 0:
		_tool.position = _tool.position.move_toward(_points[next], AUTO_SPEED * delta)
	# Teeth count only when the brush gets right to each side.
	if _in_order:
		reach = REACH_AUTO
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
			_did(kind, _points[i], helping)
	_bar.value = float(done) / _points.size()
	if done >= _points.size():
		_step_done(kind)
		return
	# Resting while the step goes on: the hand comes back to show it again.
	_idle = 0.0 if _finger_down else _idle + delta
	if _teach and _how == null and _idle > IDLE_BACK:
		_show_hand()


## One spot done: a snip, a froth of bubbles, a sparkle - more of them when a finger helped,
## and every few spots a heart, so a kid can tell their rubbing is doing something.
func _did(kind: String, at: Vector2, helped := false) -> void:
	_marks.pop(at)
	if helped:
		_helped += 1
		_on_emote("bubble" if kind in ["wash", "teeth"] else "twinkle",
			at + Vector2(randf_range(-20, 20), randf_range(-24, 0)))
		if _helped % HEART_EVERY == 0:
			_on_emote("heart", creature.top_global())
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
	_drop_hand()
	_tool.visible = false
	# The next tool is not in that hand: it comes in by the pet, and a finger picks it up anew.
	_holding = false
	_bar.value = 1.0
	creature.interrupt()
	# Done, and clear about it: its chip pops green and the line says so, in green.
	var chip := _chips[_step]
	chip.add_theme_stylebox_override("panel", UI._box(UI.GOOD, UI.INK, 2, 14, 6))
	chip.pivot_offset = chip.size / 2.0
	var pop := chip.create_tween()
	pop.tween_property(chip, "scale", Vector2(1.35, 1.35), 0.12)
	pop.tween_property(chip, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
	_say(_steps[_step][4], DONE_GREEN, 40)
	Sounds.play("good")
	match kind:
		"wash":
			# A rinse, then it shakes itself dry.
			Mud.clear(pet)
			creature.refresh_mud()
			Sounds.play_varied("splash", 1.1, 0.05)
			for i in 8:
				_on_emote("drop", creature.global_position + Vector2(randf_range(-0.4, 0.4) * creature.height_px,
					-randf_range(0.3, 1.0) * creature.height_px))
			_pause(0.9, _shake)
		"teeth":
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
	_drop_hand()
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
	if spa:
		FunDays.join(game, "spa")
		for i in 10:
			_on_emote("bubble", creature.global_position + Vector2(randf_range(-0.6, 0.6) * creature.height_px,
				-randf_range(0.0, 1.2) * creature.height_px))
	PetStore.save_pet(pet)
	# One short line: the Back home button under it says what comes next.
	_say("All squeaky clean!", DONE_GREEN, 40)
	_home_btn.visible = true


func _pause(seconds: float, then: Callable) -> void:
	_wait = seconds
	_then = then


## The line at the bottom: what to do, or (bigger, in green) that a step is done.
func _say(text: String, color := UI.INK, font_size := 28) -> void:
	_hint.text = text
	_hint.add_theme_color_override("font_color", color)
	_hint.add_theme_font_size_override("font_size", font_size)


# --- The hand --------------------------------------------------------------------------------

## The hand rubs the tool over the next ring, with the step's few words ("Rub its paws!"),
## until the kid's first touch.
func _show_hand() -> void:
	_drop_hand()
	# It picks the tool up where it is, and takes it on to the next ring.
	_hand_anchor = _tool.position
	_hand_at = _tool.position
	_how = HowTo.new()
	_how.gesture = "follow"
	_how.follow = _hand_point
	_how.caption = _steps[_step][3]
	# Just under the progress bar, clear of the hand, which comes up from below to the paws and
	# the tummy - unless the pet stands so tall it reaches up there: then where the line at the
	# bottom is, which it stands in for.
	var top := (get_canvas_transform() * creature._box().position).y
	_how.caption_y = 150.0 if top > 230.0 else 630.0
	_how.until_touch = true
	_hud_root.add_child(_how)
	_hint.visible = false
	_idle = 0.0


func _drop_hand() -> void:
	if _how != null and is_instance_valid(_how):
		_how.dismiss()
		_hand_fade = 0.35
	_how = null


## The hand's fingertip in the HUD's space (the HUD sits inside the phone's safe area).
func _hand_point() -> Vector2:
	return _hud_root.get_global_transform_with_canvas().affine_inverse() * (get_canvas_transform() * _hand_at)


# --- Fingers ---------------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_press(get_global_mouse_position(), event.pressed)
	elif event is InputEventMouseMotion:
		_finger = get_global_mouse_position()


## The demo kid's finger (and a test's): rub at `at` for a moment. A finger down sends the hand
## away, as a real touch does.
func rub_at(at: Vector2, down := true) -> void:
	if down and _finger_down:
		_finger = at
		return
	_press(at, down)


## A finger going down (or up) at `at`. Down on the tool, it picks the tool up.
func _press(at: Vector2, down: bool) -> void:
	_finger_down = down
	_finger = at
	_holding = down and _tool.visible and at.distance_to(_tool.position) < GRAB
	if down:
		_drop_hand()


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


## Where this step's tool still has to go: a soft ring on each spot left (only the next one for
## teeth, which go side to side in turn), each popping when the tool gets there - so a kid can
## see where to rub, and that it worked. The orange of the hand's press ring (UI.ACCENT: "touch
## here"), on a white halo so it shows on any colour of pet, and so it is not taken for one of
## the bubbles. Laid over the pet, never in its drawing, never black. `points` and `done` are
## the screen's own arrays.
class Marks extends Node2D:
	var points: Array[Vector2] = []
	var done: Array[bool] = []
	var in_order := false
	var radius := 9.0
	var _t := 0.0
	var _pops: Array = []

	func pop(at: Vector2) -> void:
		_pops.append([at, 0.0])

	func _process(delta: float) -> void:
		_t += delta
		for p in _pops:
			p[1] += delta
		_pops = _pops.filter(func(p): return p[1] < 0.4)
		queue_redraw()

	func _draw() -> void:
		var next := done.find(false)
		for i in mini(points.size(), done.size()):
			if done[i] or (in_order and i != next):
				continue
			var r := radius * (1.0 + 0.15 * sin(_t * 5.0 + i * 0.9))
			var ring := Crayon.ellipse(points[i], Vector2(r, r), 16)
			Crayon.marker_line(self, ring, Color(1, 1, 1, 0.9), 7.0, i)
			Crayon.marker_line(self, ring, UI.ACCENT, 3.0, i + 40)
		for p in _pops:
			var k: float = p[1] / 0.4
			var r := radius * (1.0 + 1.8 * k)
			Crayon.marker_line(self, Crayon.ellipse(p[0], Vector2(r, r), 18), Color(1, 1, 1, 0.85 * (1.0 - k)), 3.0, 99)


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
