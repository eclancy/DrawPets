class_name StyleGame
extends Node2D
## Style Show - CHARM (.ai/competitions.md). Today's theme is a clothing word ("cozy",
## "spooky"...). First the kid dresses the pet: clothes whose words include the theme carry a
## star, and each one worn fills one of the two outfit stars by the pet. Then the pet walks the
## runway while the spotlight goes on ahead and waits for it at three spots; the kid taps to POSE
## while the pet is in the light. Charm, the outfit and the poses make the score. The judges
## never look at the drawing: only what the kid chose and how they played.
##
## Shown, not told (HowTo). While dressing, a hand taps the first starred clothes, then Walk.
## Before the walk the light is parked on the pet for a 3-2-1 while the hand taps in time and the
## pet poses with each tap, so a tap is seen to mean a pose; the first time ever, two "Watch!"
## taps come first. The hand goes at the kid's first pose (a tap too soon leaves it showing when)
## and comes back if a light goes by with no pose, or after a few taps too soon. On the runway
## its press only rings the light - "now!" - and never poses for the kid. Three cameras at the
## top are the three poses - each fills with stars as it is used - and the light glows brighter
## the nearer the pet is to its middle.

signal finished(scores: Array)

const POSES := 3
## Where the spotlight waits for the pet, one spot per pose, and where the walk starts and ends.
const SPOTS := [400.0, 700.0, 1000.0]
const START_X := 140.0
const END_X := 1200.0
const FLOOR_Y := 610.0
const WALK_SPEED := 130.0
## How near the middle of the light the pet's middle must be: full marks inside PERFECT, some
## inside NICE - which a long pet stretches (_reach), since its head is in the light before its
## middle is. At walking pace that is about 0.6 s for a perfect pose and 1.7 s or more for any
## pose at all. If the pet looks lit, it is.
const PERFECT := 40.0
const NICE := 110.0
## A perfect pose, a nice one, and a light walked through without one - still a nice walk.
const PERFECT_POINTS := 10.0
const NICE_POINTS := 6.0
const PASS_POINTS := 2.0
## How long a pose holds the pet (and the light) still.
const POSE_TIME := 0.7
## Taps closer together than this that do not pose are mashing: the pet waits for one calm tap,
## so a pose is the kid's choice. One tap too soon and then a wait is never held up by it.
const CALM := 0.35
## Taps too soon in a row before the hand comes back to show when.
const EARLY_HINT := 3
const TOO_SOON := "Wait for the light!"
## A practice pose in the countdown (the hand's, or the kid's). A pose twirls the pet round and
## back every quarter second, so both lengths end facing down the runway, the way it will walk.
const PRACTICE_POSE := 0.6
## The 3-2-1 before the walk, a beat at a time; the hand taps once a beat.
const BEAT := 1.0
const COUNT := 3
## How far before a light the hand starts coming down, riding the pet.
const APPROACH := 240.0
## Seconds without a touch, while dressing, before the hand shows the next step again.
const DRESS_IDLE := 4.0
## While dressing, the camera comes in close, so the pet stands this tall on screen (up to twice
## its runway size) with its feet this far above the bottom, clear of the clothes bar - the kid
## can see the outfit. (From the bottom, since a 4:3 tablet's screen is taller than 720.)
const DRESS_PET_H := 230.0
const DRESS_FEET_UP := 215.0
const DRESS_CAPTION_Y := 142.0
## The hand, a little smaller than usual over the clothes bar so more of it shows above the edge.
const BAR_HAND := 118.0
const WALK_CAPTION_Y := 102.0
const POSE_CAPTION := "TAP when the light's on you!"
## The audience: lumps along the back of the runway, where the camera flashes go off.
const CROWD := 17
## The same green as the tug's PULL!, for every "that worked".
const YES := Color("#5fb85a")

var screen: CompetitionScreen

var _theme := ""
var _pet: Creature
var _state := "dress"
var _t := 0.0
var _beat := -999
var _first := false
var _idle := 0.0
## Lights used so far, posed in or walked through.
var _poses := 0
var _pose_points := 0.0
## The spotlight: where it is, whether it is parked and waiting for a pose, how bright.
var _spot_x := START_X
var _light_on := false
var _light_vis := 0.0
var _glow := 0.0
var _hold := 0.0
var _pulse := 0.0
var _calm := 0.0
## Taps too soon since the last pose, and how long the line still says to wait.
var _early := 0
var _nudge := 0.0
var _crowd_flash := 0.0
var _flashes := 0
var _cam: Camera2D
var _light_node: Node2D
var _hud: Control
var _msg: Label
var _big: Label
var _pop: Label
var _pop_tween: Tween
var _big_tween: Tween
var _flash: ColorRect
var _hint: HowTo
var _hint_spot := Vector2(640, 600)
var _dress_ui: Control
var _scroll: ScrollContainer
var _walk_button: Button
## Clothing id -> its button; the starred ones (theme word) come first in the bar.
var _buttons := {}
var _starred: Array = []
var _slots: Array = []
## The two outfit stars' card by the pet, where the theme word pops while dressing.
var _star_card: Control
var _cards: HBoxContainer
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = Events.seed_of(screen.event, screen.tier) + 11
	_theme = Events.theme(screen.event)
	_cam = Camera2D.new()
	add_child(_cam)
	_cam.make_current()
	# The light and the crowd's flashes, over the stage but behind the pet.
	_light_node = Node2D.new()
	_light_node.draw.connect(_draw_light)
	add_child(_light_node)
	_pet = CompetitionScreen.racer(screen.pet)
	_pet.driven = true
	_pet.position = Vector2(640, FLOOR_Y)
	add_child(_pet)
	var zoom := clampf(DRESS_PET_H / maxf(_pet.height_px, 1.0), 1.0, 2.0)
	_cam.zoom = Vector2(zoom, zoom)
	_cam.position = Vector2(640, FLOOR_Y - (_dress_feet().y - _screen().y * 0.5) / zoom)
	_build_hud()
	_build_dress()
	_refresh_dress()
	# The hand comes in a moment after the screen, once the clothes bar is laid out.
	_idle = DRESS_IDLE - 0.6


func _draw() -> void:
	# Drawn once: wide enough for a 20:9 phone and for the camera looking lower while dressing.
	draw_rect(Rect2(-600, -300, 2480, 1400), Color("#ece4f6"))
	var runway := PackedVector2Array([Vector2(-600, 560), Vector2(1880, 560), Vector2(1880, 680), Vector2(-600, 680)])
	Crayon.pencil_fill(self, runway, Color("#f2a7c3"), 41)
	for i in CROWD:
		Crayon.fill_blob(self, _crowd_at(i), Vector2(36, 26), Color("#d6cbe9"), 50 + i, 0.2)


## The screen: 1280 x 720, but wider on a 20:9 phone and taller on a 4:3 tablet.
func _screen() -> Vector2:
	return get_viewport_rect().size


## Where the pet's feet are on the screen while dressing: in the middle, above the clothes.
func _dress_feet() -> Vector2:
	var s := _screen()
	return Vector2(s.x * 0.5, s.y - DRESS_FEET_UP)


static func _crowd_at(i: int) -> Vector2:
	return Vector2(-540 + i * 150, 500)


## The spotlight, sliding or parked, brighter the nearer the pet is to its middle - and camera
## flashes in the crowd when the pet poses.
func _draw_light() -> void:
	var c := _light_node
	if _crowd_flash > 0.0:
		for k in 4:
			var i := 4 + int(absf(Crayon.noise(_flashes, k)) * 9.0)
			var p := _crowd_at(i) + Vector2(Crayon.noise(_flashes + 3, k) * 20.0, -8.0)
			Crayon.fill(c, Crayon.star(p, 10.0 + 18.0 * _crowd_flash, k), Color(1, 1, 0.86, _crowd_flash), 70 + k, 5.0, 1.0, 2.5)
	if _state == "dress" or _light_vis <= 0.01:
		return
	var v := _light_vis
	var x := _spot_x
	# From above the top of even a 4:3 tablet's screen.
	var cone := PackedVector2Array([Vector2(x - 24, -200), Vector2(x + 24, -200), Vector2(x + 122, FLOOR_Y + 16),
		Vector2(x - 122, FLOOR_Y + 16)])
	Crayon.fill(c, cone, Color(1.0, 0.96, 0.72, (0.22 + 0.2 * _glow) * v), 61, 16.0, 2.0, 8.0)
	var pool := Vector2(x, FLOOR_Y + 14)
	Crayon.fill_blob(c, pool, Vector2(124, 27), Color(1.0, 0.92, 0.55, (0.45 + 0.4 * _glow) * v), 62, 0.04)
	if _glow > 0.05:
		Crayon.marker_line(c, Crayon.ellipse(pool, Vector2(134, 32), 36), Color(1.0, 0.76, 0.24, _glow * v), 5.0, 63)
	# Right in the middle: sparkles twirl round the pet.
	if _glow > 0.7:
		var a := (_glow - 0.7) / 0.3 * v
		for k in 5:
			var turn := _t * 1.6 + k * TAU / 5.0
			var p := Vector2(x, FLOOR_Y - 90) + Vector2(cos(turn) * 150.0, sin(turn) * 70.0)
			Crayon.fill(c, Crayon.star(p, 13.0, k), Color(1, 0.84, 0.3, a), 64 + k, 4.0, 1.0, 2.0)
	# A tap that did not pose, or the hand's press: a ring spreads from the light - "this is where".
	if _pulse > 0.0:
		var r := Vector2(134, 32) * (1.0 + (1.0 - _pulse) * 0.6)
		Crayon.marker_line(c, Crayon.ellipse(pool, r, 36), Color(1, 0.76, 0.24, _pulse * v), 6.0, 69)


# --- The HUD -------------------------------------------------------------------------------------

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Control.new()
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.full_rect(_hud))
	# The one instruction, where the hand's caption goes - shown only while the hand is not.
	_msg = UI.title("", 46)
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = DRESS_CAPTION_Y
	_hud.add_child(_msg)
	# 3, 2, 1, GO!
	_big = UI.title("", 120)
	_big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_big.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_big.offset_left = -200
	_big.offset_right = 200
	_big.offset_top = 200
	_big.offset_bottom = 360
	_big.pivot_offset = Vector2(200, 80)
	_big.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_big)
	# PERFECT! / Nice! / WARM!, popping over the pet.
	_pop = UI.title("", 54)
	_pop.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pop.size = Vector2(520, 74)
	_pop.pivot_offset = Vector2(260, 37)
	_pop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_pop)
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 0.94)
	_flash.modulate.a = 0.0
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(UI.full_rect(_flash))


## The dressing room: the theme and what a star means at the top, the two outfit stars by the
## pet, and the clothes along the bottom with Walk in its own corner - however many clothes
## there are, they scroll and Walk stays put.
func _build_dress() -> void:
	_dress_ui = Control.new()
	_dress_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(UI.full_rect(_dress_ui))

	var head := VBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_theme_constant_override("separation", -8)
	head.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	head.grow_horizontal = Control.GROW_DIRECTION_BOTH
	head.offset_top = 6
	var today := UI.title("Today's theme", 28)
	today.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_child(today)
	var theme_row := HBoxContainer.new()
	theme_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme_row.alignment = BoxContainer.ALIGNMENT_CENTER
	theme_row.add_theme_constant_override("separation", 10)
	theme_row.add_child(UI.icon("icon_star", 70, "none"))
	theme_row.add_child(UI.title("= %s!" % _theme.to_upper(), 64))
	head.add_child(theme_row)
	_dress_ui.add_child(head)

	# Two outfit stars - the most the outfit can score - filling as starred clothes go on.
	var card := PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", UI._box(Color(1, 0.99, 0.95, 0.9), UI.INK, 3, 18, 10))
	var slots := HBoxContainer.new()
	slots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slots.add_theme_constant_override("separation", 4)
	for i in 2:
		var s := UI.icon("icon_star", 62, "none")
		s.pivot_offset = Vector2(31, 31)
		_slots.append(s)
		slots.add_child(s)
	card.add_child(slots)
	# Just beside the pet, at its shoulder.
	var k := _cam.zoom.x * _pet.norm
	var feet := _dress_feet()
	card.position = Vector2(minf(feet.x + maxf(_pet.rest.size.x * k * 0.5, 60.0) + 24.0, _screen().x - 170.0),
		feet.y - _pet.height_px * _cam.zoom.y * 0.75 - 41.0)
	_dress_ui.add_child(card)
	_star_card = card

	var bar := PanelContainer.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bar.offset_top = -170
	bar.offset_left = 10
	bar.offset_right = -10
	bar.offset_bottom = -40
	bar.add_theme_stylebox_override("panel", UI._box(Color(1, 0.99, 0.96, 0.92), UI.INK, 3, 18, 10))
	_dress_ui.add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	bar.add_child(row)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	row.add_child(_scroll)
	var clothes := HBoxContainer.new()
	clothes.add_theme_constant_override("separation", 10)
	_scroll.add_child(clothes)
	_walk_button = UI.big_icon_button("icon_walk", "Walk the runway!", start_walk)
	_walk_button.custom_minimum_size = Vector2(350, 104)
	_walk_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_walk_button)

	var plain := []
	for id in Items.available(screen.game.profile, "clothing"):
		if _matches(id):
			_starred.append(id)
		else:
			plain.append(id)
	if _starred.is_empty():
		_add_shop_window(clothes)
	for id in _starred + plain:
		var item := Items.get_item(id)
		var b := Button.new()
		b.custom_minimum_size = Vector2(104, 104)
		# Lets a finger dragging across the clothes scroll them.
		b.mouse_filter = Control.MOUSE_FILTER_PASS
		var pic := UI.item_picture(item, 84)
		pic.position = Vector2(10, 10)
		b.add_child(pic)
		if _matches(id):
			var star := UI.icon("icon_star", 42, "none")
			star.position = Vector2(60, 2)
			b.add_child(star)
		b.pressed.connect(_pick.bind(id))
		clothes.add_child(b)
		_buttons[id] = b


## No starred clothes: a faded picture of the shop and its clothes that would be - just so the
## kid knows what to look for next time. No box round it: it must not look like a button.
func _add_shop_window(row: HBoxContainer) -> void:
	var ids := []
	for id in Items.SHOP:
		var it: Dictionary = Items.SHOP[id]
		if it["category"] == "clothing" and it.get("words", []).has(_theme) and not it.get("prize", false) \
				and screen.game.profile.owned(id) == 0:
			ids.append(id)
	if ids.is_empty():
		return
	var inner := HBoxContainer.new()
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	inner.add_theme_constant_override("separation", 8)
	inner.modulate.a = 0.7
	inner.add_child(UI.icon("icon_shop", 56, "none"))
	for id in ids.slice(0, 3):
		var holder := Control.new()
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.custom_minimum_size = Vector2(76, 76)
		var pic := UI.item_picture(Items.get_item(id), 70)
		pic.position = Vector2(0, 6)
		holder.add_child(pic)
		var star := UI.icon("icon_star", 30, "none")
		star.position = Vector2(46, 0)
		holder.add_child(star)
		inner.add_child(holder)
	row.add_child(inner)


func _matches(id: String) -> bool:
	return Items.get_item(id).get("words", []).has(_theme)


func _worn(id: String) -> bool:
	for entry in screen.pet.get("outfit", []):
		if entry.get("item", "") == id:
			return true
	return false


## Starred things being worn - one per place on the body - up to the two that score.
func _match_count() -> int:
	var n := 0
	for entry in screen.pet.get("outfit", []):
		if _matches(entry.get("item", "")):
			n += 1
	return mini(n, 2)


## What the kid should tap next: a starred thing for a place on the body that has no star yet,
## or Walk once the outfit is as starry as it can get.
func _next_step() -> Control:
	if _match_count() < 2:
		var starred_at := {}
		for entry in screen.pet.get("outfit", []):
			var it := Items.get_item(entry.get("item", ""))
			if it.get("words", []).has(_theme):
				starred_at[it.get("wear", "head")] = true
		for id in _starred:
			if not starred_at.has(Items.get_item(id).get("wear", "head")):
				return _buttons[id]
	return _walk_button


func _dress_text() -> String:
	if _next_step() != _walk_button:
		return "Tap clothes with a star!"
	return "Now walk the runway!" if _match_count() > 0 else "Tap to walk the runway!"


## Worn clothes light up in their buttons; the outfit stars show what they are worth.
func _refresh_dress() -> void:
	for id in _buttons:
		var b: Button = _buttons[id]
		if _worn(id):
			b.add_theme_stylebox_override("normal", UI._box(UI.HILITE, UI.ACCENT, 5))
			b.add_theme_stylebox_override("hover", UI._box(UI.HILITE, UI.ACCENT, 5))
		else:
			b.remove_theme_stylebox_override("normal")
			b.remove_theme_stylebox_override("hover")
	var n := _match_count()
	for i in _slots.size():
		var s: Control = _slots[i]
		s.modulate = Color.WHITE if i < n else Color(1, 1, 1, 0.22)


func _pick(id: String) -> void:
	if _state != "dress":
		return
	if _worn(id):
		_take_off(id)
	else:
		wear(Items.get_item(id))


func wear(item: Dictionary) -> void:
	var before := _match_count()
	Wardrobe.put_on(screen.pet, item)
	_pet.rebuild()
	Sounds.play("dress")
	PetStore.save_pet(screen.pet)
	var after := _match_count()
	if after > before:
		_pop_word("%s!" % _theme.to_upper(), YES)
		Sounds.play("sparkle")
		_pet.say("star")
		_fly_star(after - 1)
	else:
		_pet.say("heart")
	_refresh_dress()
	if _state != "dress":
		return
	if _hint != null:
		_show_dress_hint()
	elif _next_step() == _walk_button:
		# The outfit is done: the hand shows the walk a moment later.
		_idle = maxf(_idle, DRESS_IDLE - 1.5)


func _take_off(id: String) -> void:
	var outfit: Array = screen.pet.get("outfit", [])
	for entry in outfit.duplicate():
		if entry.get("item", "") == id:
			outfit.erase(entry)
	screen.pet["outfit"] = outfit
	_pet.rebuild()
	Sounds.play("dress", 0.85)
	PetStore.save_pet(screen.pet)
	_refresh_dress()


## A star flies from the pet's new clothes into its outfit slot.
func _fly_star(slot: int) -> void:
	if slot < 0 or slot >= _slots.size():
		return
	var target: Control = _slots[slot]
	var s := UI.icon("icon_star", 62, "none")
	_hud.add_child(s)
	s.position = _pet_top() - Vector2(31, 31)
	var t := s.create_tween()
	t.tween_property(s, "global_position", target.global_position, 0.45).set_trans(Tween.TRANS_SINE)
	t.tween_callback(s.queue_free)
	target.scale = Vector2(0.4, 0.4)
	var grow := target.create_tween()
	grow.tween_interval(0.4)
	grow.tween_property(target, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# --- The hand ------------------------------------------------------------------------------------

func _show_hint(text: String, at: Variant, phase: Callable, y: float) -> void:
	_drop_hint()
	_hint = HowTo.new()
	_hint.gesture = "tap"
	_hint.caption = text
	_hint.caption_y = y
	_hint.at = at
	_hint.phase = phase
	_hint.on_press = _hint_pressed
	_hud.add_child(_hint)
	_idle = 0.0


## Gone at once, not faded: its caption sits where our own line comes back, and the two
## together (one fading over the other) look smudged - the kid's finger is down anyway.
func _drop_hint() -> void:
	if _hint != null:
		_hint.queue_free()
		_hint = null


func _show_dress_hint() -> void:
	var target := _next_step()
	if target != _walk_button:
		_scroll.ensure_control_visible(target)
	_show_hint(_dress_text(), _center_of.bind(target), Callable(), DRESS_CAPTION_Y)
	_hint.hand_height = BAR_HAND


## The hand rides the pet, tapping it as it reaches the middle of the light.
func _show_walk_hint(text: String) -> void:
	_show_hint(text, _pet_point, _hint_phase, WALK_CAPTION_Y)


## Where the hand is in its tap (0..1, pressing at 0.5): on the beat while counting down, and
## by how near the pet is to the light's middle while it walks.
func _hint_phase() -> float:
	if _state == "ready":
		return fposmod(_t / BEAT, 1.0)
	if _state == "walk" and _light_on and _poses < POSES:
		return clampf(0.5 + (_pet.position.x - _spot_x) / (2.0 * APPROACH), 0.0, 0.97)
	return 0.0


## While counting down, the hand's taps make the pet pose - that is what a tap does. On the
## runway its press, right in the middle of the light, rings the light and ticks: "now!" (it never
## poses for the kid - the pose is theirs to take).
func _hint_pressed() -> void:
	if _state == "ready" and _pet.action() == "":
		_pet.perform("celebrate", PRACTICE_POSE)
		Sounds.play("camera")
		_camera_flash(0.0)
	elif _state == "walk" and _light_on and _poses < POSES:
		_pulse = 1.0
		Sounds.play("count_tick")


## Where the hand pokes a button: near its top, so the hand (which comes up from below) shows
## above the bottom of the screen - or where it last was, should the button be gone first.
func _center_of(c: Variant) -> Vector2:
	if is_instance_valid(c):
		var r := (c as Control).get_global_rect()
		_hint_spot = Vector2(r.get_center().x, r.position.y + 30.0)
	return _hint_spot


## The middle of the pet, and just over its head, on the screen (through the camera's zoom).
func _pet_point() -> Vector2:
	return _pet.get_global_transform_with_canvas() * Vector2(0, -_pet.height_px * 0.5)


func _pet_top() -> Vector2:
	return _pet.get_global_transform_with_canvas() * Vector2(0, -_pet.height_px - 20.0)


# --- Playing -------------------------------------------------------------------------------------

func start_walk() -> void:
	if _state != "dress":
		return
	_state = "ready"
	_drop_hint()
	UI.retire(_dress_ui)
	_buttons = {}
	_slots = []
	_first = HowTo.first_times(screen.game.profile, "howto_style", 1)
	_t = -float(COUNT + (2 if _first else 0)) * BEAT
	_beat = -999
	_pet.interrupt()
	_pet.position = Vector2(START_X, FLOOR_Y)
	_pet.facing = 1.0
	_spot_x = START_X
	_light_on = true
	_light_vis = 1.0
	# The camera steps back from the dressing room to the whole runway.
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	t.tween_property(_cam, "position", Vector2(640, 360), 0.6)
	t.tween_property(_cam, "zoom", Vector2.ONE, 0.6)
	_msg.offset_top = WALK_CAPTION_Y
	_build_pose_cards()
	_show_walk_hint("Watch!" if _first else POSE_CAPTION)


## The three poses, as cameras at the top: the next one bobs, a used one gets its stars.
func _build_pose_cards() -> void:
	_cards = HBoxContainer.new()
	_cards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cards.add_theme_constant_override("separation", 18)
	_cards.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_cards.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_cards.offset_top = 12
	for i in POSES:
		var slot := Control.new()
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.custom_minimum_size = Vector2(86, 78)
		var cam := UI.icon("icon_camera", 78, "none")
		cam.position = Vector2(4, 0)
		cam.pivot_offset = Vector2(39, 39)
		slot.add_child(cam)
		_cards.add_child(slot)
	_hud.add_child(_cards)


func _mark_card(i: int, points: float) -> void:
	var slot: Control = _cards.get_child(i)
	var cam: Control = slot.get_child(0)
	cam.scale = Vector2.ONE
	cam.modulate = Color(1, 1, 1, 0.4)
	var n := 2 if points >= PERFECT_POINTS else (1 if points >= NICE_POINTS else 0)
	for k in n:
		var s := UI.icon("icon_star", 48, "none")
		s.pivot_offset = Vector2(24, 24)
		s.position = Vector2(19.0 + (k - (n - 1) * 0.5) * 32.0, 14.0)
		slot.add_child(s)
		s.scale = Vector2(1.8, 1.8)
		s.create_tween().tween_property(s, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_idle = 0.0
		if _state == "dress":
			_drop_hint()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap()


func tap() -> void:
	if _state == "ready":
		_drop_hint()
		# Still watching the hand? Straight on to the 3-2-1, and this tap is a practice pose.
		if _t < -COUNT * BEAT:
			_t = -COUNT * BEAT
		_pet.perform("celebrate", PRACTICE_POSE)
		Sounds.play("camera")
		_camera_flash(0.0)
		_pop_word("Yes!", YES)
		return
	if _state != "walk" or _poses >= POSES or _hold > 0.0:
		return
	var miss := absf(_pet.position.x - _spot_x)
	var near := miss < _reach()
	if _light_on and near and _calm <= 0.0:
		_pose(miss)
		return
	# No pose: the ring spreads from the light, to say "this is where", and the next tap must
	# come calmly. The hand (if it is up) stays, still showing when.
	_pulse = 1.0
	_calm = CALM
	if near:
		# The pet does look lit - mashing in the light, or the light just leaving it at GO or
		# after a pose - so no words, which would say otherwise.
		return
	# Too soon: the instruction line itself says wait (still one sentence on screen), and a few
	# in a row bring the hand back to ride the pet into the light.
	Sounds.play("ui_tap")
	_nudge = 1.1
	_early += 1
	if _early >= EARLY_HINT and _hint == null:
		_show_walk_hint(POSE_CAPTION)


## How far the pet's middle may be from the light's middle and still pose: NICE, plus a quarter
## of the pet's length, so a long pet with its head and front legs in the light is in it.
func _reach() -> float:
	return NICE + _pet.rest.size.x * _pet.norm * 0.25


func _pose(miss: float) -> void:
	_drop_hint()
	_early = 0
	_nudge = 0.0
	var perfect := miss < PERFECT
	_pet.perform("celebrate", POSE_TIME)
	_hold = POSE_TIME
	Sounds.play("camera")
	_camera_flash(0.4 if perfect else 0.25)
	_pop_word("PERFECT!" if perfect else "Nice!", YES)
	_pet.say("star" if perfect else "heart")
	_use_light(PERFECT_POINTS if perfect else NICE_POINTS)


## One light used up - posed in, or walked through - and the light goes on to the next spot.
func _use_light(points: float) -> void:
	var i := _poses
	_poses += 1
	_pose_points += points
	_early = 0
	_mark_card(i, points)
	_light_on = false
	if _poses >= POSES:
		return
	var t := create_tween()
	if points > PASS_POINTS:
		t.tween_interval(POSE_TIME)
	var next: float = SPOTS[_poses]
	t.tween_property(self, "_spot_x", next, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(_park)


func _park() -> void:
	_light_on = true


func _camera_flash(screen_flash: float) -> void:
	_flashes += 1
	_crowd_flash = 1.0
	_flash.modulate.a = maxf(_flash.modulate.a, screen_flash)


func _pop_word(text: String, color: Color, font_size := 54) -> void:
	_pop.text = text
	_pop.add_theme_color_override("font_color", color)
	_pop.add_theme_font_size_override("font_size", font_size)
	var at := _pop_spot()
	_pop.position = Vector2(clampf(at.x - 260.0, 0.0, _screen().x - 520.0), at.y - 37.0)
	_pop.modulate.a = 1.0
	_pop.scale = Vector2(1.3, 1.3)
	if _pop_tween != null:
		_pop_tween.kill()
	_pop_tween = create_tween()
	_pop_tween.tween_property(_pop, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pop_tween.tween_interval(0.7)
	_pop_tween.tween_property(_pop, "modulate:a", 0.0, 0.35)


## Where a word pops (its middle): over the pet's head on the runway. While dressing the camera
## has the pet so big that over its head is the instruction line, so the theme word pops just
## over the outfit stars instead - where its star has just flown.
func _pop_spot() -> Vector2:
	if _state == "dress" and is_instance_valid(_star_card):
		var r := _star_card.get_global_rect()
		return Vector2(r.get_center().x, r.position.y - 40.0)
	return _pet_top() - Vector2(0, 47)


func _say_big(text: String, color := UI.INK) -> void:
	_big.text = text
	_big.add_theme_color_override("font_color", color)
	_big.modulate.a = 1.0
	_big.scale = Vector2(1.4, 1.4)
	if _big_tween != null:
		_big_tween.kill()
	_big_tween = create_tween()
	_big_tween.tween_property(_big, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_big_tween.tween_interval(0.45)
	_big_tween.tween_property(_big, "modulate:a", 0.0, 0.25)


func _process(delta: float) -> void:
	_flash.modulate.a = maxf(0.0, _flash.modulate.a - delta * 2.2)
	_crowd_flash = maxf(0.0, _crowd_flash - delta * 1.8)
	_nudge = maxf(0.0, _nudge - delta)
	_msg.text = _instruction()
	_msg.visible = _hint == null
	# "Wait" in the softer ink, so it reads as a word from the side, not the instruction.
	var soft := _nudge > 0.0 and _msg.text == TOO_SOON
	if soft != _msg.has_theme_color_override("font_color"):
		if soft:
			_msg.add_theme_color_override("font_color", UI.INK_SOFT)
		else:
			_msg.remove_theme_color_override("font_color")
	if _state == "dress":
		_pet.drive_velocity = Vector2.ZERO
		_idle += delta
		if _hint == null and _idle > DRESS_IDLE:
			_show_dress_hint()
		_light_node.queue_redraw()
		return
	_t += delta
	_hold = maxf(0.0, _hold - delta)
	_calm = maxf(0.0, _calm - delta)
	_pulse = maxf(0.0, _pulse - delta * 1.5)
	var glow: float = 1.0 if _hold > 0.0 else [0.0, 0.55, 1.0][_now()]
	_glow = move_toward(_glow, glow, delta * 5.0)
	_light_vis = move_toward(_light_vis, 1.0 if _poses < POSES or _hold > 0.0 else 0.0, delta * 1.5)
	_light_node.queue_redraw()
	_bob_next_card()

	if _state == "ready":
		_pet.drive_velocity = Vector2.ZERO
		var beat := int(floor(_t / BEAT))
		if beat != _beat:
			_beat = beat
			_on_beat(beat)
		if _t >= 0.0:
			_go()
		return
	if _state != "walk":
		_pet.drive_velocity = Vector2.ZERO
		return
	_pet.drive_velocity = Vector2(WALK_SPEED, 0.0) if _pet.action() == "" else Vector2.ZERO
	# Walked right through a light with no pose: on it goes, and the hand comes back to show how.
	if _light_on and _poses < POSES and _pet.position.x - _spot_x > _reach():
		_use_light(PASS_POINTS)
		if _hint == null and _poses < POSES:
			_show_walk_hint(POSE_CAPTION)
	if _pet.position.x > END_X:
		_state = "done"
		_pet.drive_velocity = Vector2.ZERO
		_score()


## 0: not now. 1: in the light. 2: right in the middle (and all through the countdown, which is
## exactly what "now" looks like).
func _now() -> int:
	if _state == "ready":
		return 2
	if _state != "walk" or not _light_on or _poses >= POSES:
		return 0
	var miss := absf(_pet.position.x - _spot_x)
	return 2 if miss < PERFECT else (1 if miss < _reach() else 0)


func _instruction() -> String:
	match _state:
		"dress":
			return _dress_text()
		"ready", "walk":
			if _poses >= POSES:
				return ""
			return TOO_SOON if _nudge > 0.0 else POSE_CAPTION
	return ""


func _bob_next_card() -> void:
	if _cards == null or _poses >= POSES:
		return
	var cam: Control = _cards.get_child(_poses).get_child(0)
	cam.scale = Vector2.ONE * (1.0 + 0.07 * sin(_t * 6.0))


## The countdown, a beat at a time: watch (first time ever), then 3, 2, 1.
func _on_beat(beat: int) -> void:
	if beat < -COUNT:
		return
	if beat == -COUNT and _hint != null and _hint.caption != POSE_CAPTION:
		_show_walk_hint(POSE_CAPTION)
	if beat < 0:
		_say_big(str(-beat))
		Sounds.play("count_tick")


func _go() -> void:
	_state = "walk"
	_say_big("GO!", YES)
	Sounds.play("count_go")
	# The light leaves the pet and goes on ahead to wait at the first spot.
	_light_on = false
	var t := create_tween()
	var first: float = SPOTS[0]
	t.tween_property(self, "_spot_x", first, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(_park)


func _score() -> void:
	_drop_hint()
	var match_points := 0.0
	for entry in screen.pet.get("outfit", []):
		if Items.get_item(entry.get("item", "")).get("words", []).has(_theme):
			match_points += 10.0
	match_points = minf(match_points, 20.0)
	var charm := Stats.value(screen.pet, "charm") * 0.45
	var total := charm + match_points + _pose_points
	_show_judges(int(charm), int(match_points), int(_pose_points))
	Sounds.play("cheer")
	var scores := [{"who": "player", "score": total}]
	for i in screen.rivals.size():
		var rival_charm := Stats.value(screen.rivals[i]["pet"], "charm")
		scores.append({"who": i, "score": rival_charm * 0.45 + _rng.randf_range(4.0, 16.0) + _rng.randf_range(8.0, 26.0)})
	await get_tree().create_timer(3.2).timeout
	finished.emit(scores)


## The judges' card: what charm, the outfit and the poses each scored, as pictures and numbers.
func _show_judges(charm: int, outfit: int, poses: int) -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 4)
	var said := UI.title("The judges say...", 38)
	said.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(said)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	var parts := [[Stats.INFO["charm"]["icon"], charm], ["icon_star", outfit], ["icon_camera", poses]]
	for i in parts.size():
		if i > 0:
			row.add_child(UI.title("+", 48))
		row.add_child(UI.icon(parts[i][0], 64, "none"))
		row.add_child(UI.title(str(parts[i][1]), 52))
	row.add_child(UI.title("=", 48))
	var sum := UI.title(str(charm + outfit + poses), 64)
	sum.add_theme_color_override("font_color", UI.ACCENT.darkened(0.2))
	row.add_child(sum)
	col.add_child(row)
	panel.add_child(UI.margin(col, 12))
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.offset_top = -40
	panel.offset_bottom = -40
	_hud.add_child(panel)
