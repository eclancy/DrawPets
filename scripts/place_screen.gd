class_name PlaceScreen
extends Node2D
## A home: a favourite place, the pets who live there, and whatever the kid has put in it.
## The looking-after part of the game (.ai/pet-life.md).
##
##   Rub a pet         -> hearts, trust, charm. Its head: eyes shut, it leans into your finger.
##                        Its body: a happy wiggle - keep going and it rolls over for a belly rub.
##   Tap a pet         -> it looks up and says hello, and its card opens.
##   Tap the ground    -> it comes over.
##   Food drawer       -> tap a snack into the bowl, or drag it out; the hungriest pet trots
##                        over and munches it.
##   Toys drawer       -> each toy plays the way its words say (Words.toy_play): fling a ball and
##                        it is fetched and held out - tap it and it is thrown again; hold out a
##                        rope and a pet grabs the other end for tug of war - pull, let go, pull,
##                        in time with a drum, till it lets go happily (see "Tug of war"); a teddy
##                        gets a cuddle, a bone a long chew; tap a squeaky duck and they pounce;
##                        a treat ball is nosed (and tapped) about till the treat rolls out; a
##                        heavy thing gets shoved along. Toys lying about can be picked up again,
##                        and tapped.
##   Decorate drawer   -> drag furniture in (or tap it in), drag it about, drag it back to put it
##                        away.
##   Wardrobe drawer   -> drag clothes onto a pet (or tap them, for the pet you are looking at).
##   Listen (optional) -> with the mic on, a clap or a shout - only how loud, never what is said,
##                        nothing kept - makes the pets look up and come running, and wakes a
##                        sleeper gently. Tapping the ground does the same without the mic.
##   Photo             -> everyone strikes the pose you pick; Snap! freezes the moment, then
##                        a frame and stickers (PhotoEditor) and it goes in the album and the
##                        journal of every pet in it.
##   Bath drawer       -> scrub a muddy pet with the sponge till it shakes itself dry, squeaky
##                        clean; brush it fluffy. Pets get muddy (Mud) splashing about a muddy
##                        place, digging, and running about in a passing shower of rain.
## Pets in a home make friends (Friends): they say hello, nuzzle, play chase and fetch together,
## and best friends sleep side by side - sooner when their personalities and favourites click.
## Left alone, pets use the furniture by its words: nap on cozy things, bounce on bouncy ones.
## Every kind of play trains a stat (Stats), and milestones pay gold stars (GameRoot.reward).
## At night (Clock) the place goes lavender, glowy things light up, and the pets curl up asleep
## somewhere cozy. A tap wakes one gently - it stays up while it is played with - and in the
## morning they stretch and say good morning.
## Kids start at 7 and many barely read, so the first few times a kid comes to each of these a
## drawn hand (HowTo) does the move where it happens, and comes back if they rest with it still
## to do (see "Showing how").

const ZOOM := {"tiny": 1.5, "small": 1.2, "medium": 1.0, "big": 0.9, "huge": 0.78, "giant": 0.66}
const TABS := [["food", "icon_pantry", "Food"], ["toy", "icon_toys", "Toys"],
	["furniture", "icon_decorate", "Decorate"], ["clothing", "icon_wardrobe", "Wardrobe"], ["bath", "icon_bath", "Bath"]]
## Where pets walk. It stops short of the screen's bottom edge, which the drawer bar covers -
## the camera sits CAM_DROP lower so the whole band shows above the bar - and starts clear of
## the column of buttons down the left, so nothing a kid wants to touch hides under Listen.
const GROUND := Rect2(130, 458, 1080, 172)
const CAM_DROP := 56.0

var game: GameRoot
var home: Dictionary
var focus_id := ""
var first_visit := false
## A Beginner fun day held here (FunDays): "party" (friends come to play) or "photo" (Photo Day).
var fun_day := ""
## Guests: party guests (friendly pets) and friends' pets visiting from a swap (Visitors) -
## they wander about, dance, say hello and make friends, and go home when you leave.
var guests: Array[Creature] = []

var pets: Array = []
var creatures: Array[Creature] = []
var furniture: Array[Furniture] = []
var world: Node2D
var food: PlaceItem
var toy: PlaceItem
var tab := ""
## What is happening with the toy (see "Toys"): "" lying about or not out, "chase" flung and
## being chased, "return" being brought back, "offer" held out for the kid to take, "busy" a pet
## is cuddling, chewing, pouncing on, nosing or pushing it (or on its way to).
var toy_state := ""

var _place: Dictionary
var _cam: Camera2D
var _follow: Creature
var _held: Node2D
var _held_kind := ""
var _held_item := {}
var _samples: Array = []
var _petting: Creature
var _pet_last := Vector2.ZERO
var _pet_last_time := 0.0
var _pet_dist := 0.0
var _pet_moved := 0.0
var _pet_press_time := 0.0
var _pet_hearts := 0
var _toy_pet: Creature
var _toy_fresh := false
var _toy_dropped_on: Creature
var _toy_press := false
var _toy_press_at := Vector2.ZERO
var _toy_press_time := 0.0
var _thrown_from := Vector2(640, 600)
var _offer_left := 0.0
var _nudges := 0
## Who is nosing the treat ball - picked up and put back, the same pet carries on where it was.
var _nudger: Creature
## A toy a pet held out, just taken by a touch: lifted again at once (a tap), it is thrown for
## you, away from the pet (`_tap_dir`), so "tap it" is all a little one has to do.
var _tap_take := false
var _tap_take_time := 0.0
var _tap_dir := 1.0
var _pushing := false
var _push_thud_in := 0.0
var _tug_caller: Creature
var _tug_call_in := 0.0
var _hinted := {}
var _chasers: Array = []
var _leapt: Array = []
var _caught_in_air := false
## When the toy was last flung: nobody catches it for a moment, so one tapped out of a pet's mouth
## really flies before it is chased down.
var _chase_from := 0.0
var _eater: Creature
## The snack `_eater` is going for or eating. `food` is the newest one out, which may be another
## the kid is already holding out for whoever is next.
var _eating: PlaceItem
var _told_full := false
var _munch_in := 0.0
## Tug of war (see "Tug of war"): the pet on the other end, the rhythm's clock (negative while
## it gets a grip), the kid's knot (0 let out, 1 pulled) and how it is moving, whether a finger
## is on it and where it came down, how hard this pull is going, where the pet backs off from
## and to (the front, where no furniture hides it), where the guide ring was, the heaves so far
## and the pulls since the last good one, how long no finger has been on the rope, whether the
## hand is teaching this one, the camera's pet (held still meanwhile), and the HUD bits - the
## rope's handle, the PULL!/let go word and the hearts to fill.
var _tug: Creature
var _tug_t := 0.0
var _tug_h := 0.0
var _tug_prev_h := 0.0
var _tug_vel := 0.0
var _tug_down := false
var _tug_down_x := 0.0
var _tug_down_h := 0.0
var _tug_heave := 0.0
var _tug_lead := 0.0
var _tug_from := Vector2.ZERO
var _tug_to := Vector2.ZERO
var _tug_guide := Vector2(640, 360)
var _tug_heaves := 0
var _tug_dry := 0
var _tug_half := 0
var _tug_travel := 0.0
var _tug_near_sum := 0.0
var _tug_near_time := 0.0
var _tug_idle := 0.0
var _tug_teach := false
var _tug_follow: Creature
var _tug_bar: TugGame.PullBar
var _tug_word: Label
var _tug_hearts: HBoxContainer
## Showing how (HowTo): the hand up now, what it teaches ("rub", "food", "toys", "tug"...), how
## to show it again, and how long the kid has rested since.
var _how: HowTo
var _how_key := ""
var _how_spec := {}
var _how_idle := 0.0
## The drawer's item buttons by id, in drawer order, so the hand can point at one.
var _item_buttons := {}
## Quick taps on pets with no rub in between - after three, the hand shows how to rub.
var _pats := 0
var _pat_last := 0.0
## Where the finger that took something from a drawer came down (screen), and whether it has
## been far from there since: let go on the drawer without going anywhere, it was a tap.
var _grab_screen := Vector2.ZERO
var _grab_far := false
## Where the finger holding something is, in world space - set by every drag event, so tug of
## war follows the finger rather than wherever a mouse cursor happens to be.
var _finger := Vector2.ZERO
var _selected: Furniture
var _drawer: HBoxContainer
var _tab_buttons := {}
var _panel: PetPanel
var _panel_pet: Creature
var _hint: Label
var _hud_root: Control
var _hint_time := 8.0
var _save_in := 10.0
var _ai_in := 1.5
var _squeak_in := 0.0
## Night: when each pet woken up, or played with, goes back to bed (Creature -> _now() seconds).
var _up_till := {}
var _was_night := false
## Bath: who the sponge or brush is on, how far it has rubbed, whether this wash is done.
var _washing: Creature
var _wash_dist := 0.0
var _wash_total := 0.0
var _wash_last := Vector2.INF
var _wash_sound_in := 0.0
var _bathed := false
## What this place gets on a pet (Mud.kind_for): mud, sand, dust, or "" for nowhere dirty.
var _mud_kind := ""
var _painter: PlacePainter
var _rain_in := -1.0
var _rain_left := 0.0
var _rain_loop := -1
var _editor: PhotoEditor
## The food bowl: snacks dropped in it (or tapped in from the drawer) are eaten there, nose down.
var _bowl: Sprite2D
## Listening for a call: the button, how loud the room usually is, and a rest after each call.
var _listen_btn: Button
var _listening := false
var _quiet := 0.05
var _call_rest := 0.0
var _ask: Control


func _ready() -> void:
	var t0 := Time.get_ticks_usec()
	_place = Places.get_place(home["place"])
	var painter := PlacePainter.new()
	painter.place_id = home["place"]
	add_child(painter)
	_painter = painter
	_mud_kind = Mud.kind_for(home["place"])
	# Now and then a shower passes over an outdoor place, a little while after you arrive.
	var tags := Places.tags(home["place"])
	if _mud_kind != "" and tags.has("outside") and not tags.has("dry") and randf() < 0.12:
		_rain_in = randf_range(8.0, 30.0)
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
		c.audible = true
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

	_make_bowl()
	_build_hud()
	_drop_daily_snacks()
	_was_night = Clock.is_night()
	if _was_night:
		for c in creatures:
			if c.pet["id"] == focus_id:
				_up_till[c] = _now() + 90.0  # just made, fixed or visited: it stays up to see you
			else:
				_go_to_bed(c, true)
	_greet()
	_start_fun_day()
	_maybe_visitor()
	print("[timing] home %d ms (%d pets)" % [(Time.get_ticks_usec() - t0) / 1000, creatures.size()])


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
	if _was_night and not first_visit:
		_show_hint("It's night time - shh! Tap a pet to wake it up gently.")
		return
	if Clock.is_morning() and not first_visit and game.profile.count_today("morning_" + home["id"], 1):
		_good_morning()
		return
	for c in creatures:
		if Care.is_bath_day(c.pet) and not first_visit:
			_show_hint("It's bath day for %s! Open the Bath drawer." % c.pet["name"])
			return
	if first_visit:
		_show_hint("Welcome home, %s! Rub it to pet it." % focus.pet["name"])
		_teach_rub(focus)
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
	_show_hint("They missed you!" if missed else "Rub a pet - or tap it to see how it's doing!")
	_teach_rub(focus)


# --- HUD -------------------------------------------------------------------------------------

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(UI.fit_safe(root))
	_hud_root = root

	var home_btn := UI.icon_button("icon_home", "Home", func(): game.go_home(), 40, Vector2(92, 84))
	home_btn.position = Vector2(12, 12)
	root.add_child(home_btn)
	if not creatures.is_empty():
		var walk_btn := UI.icon_button("icon_walk", "Walk", go_walk, 40, Vector2(92, 84))
		walk_btn.position = Vector2(12, 104)
		root.add_child(walk_btn)
		var trick_btn := UI.icon_button("icon_tricks", "Tricks", go_tricks, 40, Vector2(92, 84))
		trick_btn.position = Vector2(12, 196)
		root.add_child(trick_btn)
		var photo_btn := UI.icon_button("icon_camera", "Photo", open_tab.bind("camera"), 40, Vector2(92, 84))
		photo_btn.position = Vector2(12, 288)
		root.add_child(photo_btn)
		_listen_btn = UI.icon_button("snd_mic_off", "Listen", toggle_listening, 40, Vector2(92, 84))
		_listen_btn.position = Vector2(12, 380)
		root.add_child(_listen_btn)

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
	right.add_child(UI.icon_button("icon_shop", "Shop", func(): game.go_shop(game.go_place.bind(home["id"])),
		40, Vector2(84, 84)))
	right.add_child(UI.icon_button("icon_calendar", "Events" if game.profile.advanced() else "Fun days",
		func(): game.go_calendar(), 40, Vector2(84, 84)))
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
	_panel.advanced = game.profile.advanced()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.offset_right = -12
	_panel.offset_top = 104
	_panel.visible = false
	_panel.on_close = func(): _panel.visible = false
	_panel.on_take_off = _take_off_clothes
	_panel.on_voice = func(p: Dictionary): _leave_with(p, func(): game.go_voice(p["id"], home["id"]))
	_panel.on_move = func(p: Dictionary): _leave_with(p, func(): game.go_move(p["id"], home["id"]))
	_panel.on_let_go = func(p: Dictionary): _leave_with(p, func(): game.go_let_go(p["id"], home["id"]))
	_panel.on_journal = func(p: Dictionary): _leave_with(p, func(): game.go_journal(p["id"], home["id"]))

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
	root.add_child(_panel)  # after the bar, so the card is always on top of it
	_fill_drawer()


func open_tab(which: String) -> void:
	tab = "" if tab == which else which
	if tab == "bath" and not _hinted.has("bath"):
		_hinted["bath"] = true
		_show_hint("Tap Bath day! for a bath - or sponge off some mud.")
	for t in _tab_buttons:
		_tab_buttons[t].set_pressed_no_signal(t == tab)
	_select_furniture(null)
	_fill_drawer()
	_teach_drawer()


func _fill_drawer() -> void:
	for c in _drawer.get_children():
		c.queue_free()
	_item_buttons.clear()
	if tab == "":
		var l := UI.label("Open a drawer: Food, Toys, Decorate, Wardrobe or Bath.", 22)
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_drawer.add_child(l)
		return
	if tab == "camera":
		_fill_camera()
		return
	if tab == "furniture" and _selected != null:
		for entry in [["edit_bigger", "Bigger", _resize_selected.bind(1.15)],
				["edit_smaller", "Smaller", _resize_selected.bind(1.0 / 1.15)], ["edit_flip", "Flip", _flip_selected],
				["edit_remove", "Put away", _remove_selected], ["tool_done", "Done", _select_furniture.bind(null)]]:
			_drawer.add_child(UI.icon_button(entry[0], entry[1], entry[2], 52, Vector2(104, 96)))
		return
	var draw_new := func(): game.make_item(tab, game.back_to_place.bind(home["id"], focus_id))
	if tab == "bath":
		var bath := UI.icon_button("icon_bath", "Bath day!", go_bath, 52, Vector2(120, 96))
		bath.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.INK, 3))
		_drawer.add_child(bath)
	else:
		var draw := UI.icon_button("icon_draw", "Draw", draw_new, 52, Vector2(96, 96))
		draw.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.INK, 3))
		_drawer.add_child(draw)
	var ids := Items.available(game.profile, tab)
	if tab == "clothing" and ids.is_empty():
		_drawer.add_child(UI.button("Get clothes in the shop!", func(): game.go_shop(game.go_place.bind(home["id"])),
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
		_item_buttons[id] = b


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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_touched()
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
		if event.pressed:
			_press(at)
		else:
			_release()
	elif event is InputEventMouseMotion:
		_drag(at)


## A finger comes down: on furniture (decorating), a toy, a pet, or the ground. In tug of war,
## anywhere: it takes hold of the knot again.
func _press(at: Vector2) -> void:
	if _tug != null:
		_tug_press(_screen_of(at).x)
		return
	if tab == "furniture":
		var f := _furniture_at(at)
		if f != null:
			_select_furniture(f)
			_held = f
			_held_kind = "move"
			Sounds.play("pickup")
			return
		_select_furniture(null)
	if _toy_at(at):
		if toy_state == "offer":
			# Held out to you: a touch takes it. A rope's end, and it is tug of war straight away;
			# anything else is in your hand - flick it, or just lift: a tap throws it for you.
			var tug := toy.play() == "tug"
			take_toy(at)
			if not tug:
				_tap_take = true
				_tap_take_time = _now()
			return
		# A tap squeaks or bounces it; a drag (or a hold) picks it up.
		_toy_press = true
		_toy_press_at = at
		_toy_press_time = _now()
		return
	var c := _creature_at(at)
	if c != null:
		_petting = c
		_pet_last = at
		_pet_last_time = _now()
		_pet_press_time = _now()
		_pet_dist = 0.0
		_pet_moved = 0.0
		_pet_hearts = 0
	elif _tap_guest(at):
		pass
	elif at.y > Places.HORIZON and toy_state not in ["chase", "return"]:
		var who := _focus_creature()
		if who != null and who.action() == "sleep":
			_show_hint("Shh - %s is asleep. Tap it to wake it up gently." % who.pet["name"])
		elif who != null and who != _eater and who != _tug and who != _toy_pet:
			who.go_to(at, func(): who.say("note"))


func _drag(at: Vector2) -> void:
	if _tug_down:
		_tug_drag(_screen_of(at).x)
		return
	if _toy_press:
		if at.distance_to(_toy_press_at) > 12.0:
			_toy_press = false
			take_toy(at)
		return
	if _petting == null:
		return
	var d := at.distance_to(_pet_last)
	var dt := maxf(_now() - _pet_last_time, 0.008)
	_pet_moved += d
	if _pet_moved > 14.0:
		stroke_pet(_petting, d, at, d / dt)
	_pet_last = at
	_pet_last_time = _now()


func _release() -> void:
	_tug_down = false
	if _toy_press:
		_toy_press = false
		tap_toy()
		return
	if _petting == null:
		return
	var c := _petting
	_petting = null
	c.touch_at = Vector2.INF
	if _pet_moved < 14.0 and _now() - _pet_press_time < 0.45:
		boop(c)
		# Little ones pat. Three pats and no rub: the hand shows them how to rub.
		_pats = _pats + 1 if _now() - _pat_last < 6.0 else 1
		_pat_last = _now()
		if _pats >= 3 and c.action() != "sleep":
			_pats = 0
			_show_rub(c)
	elif c.action() == "belly":
		c.extend_action(0.8)  # a moment more on its back, then it rolls the right way up


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


## Out for a walk - the pet whose card is open, or the one this home is looking at.
func go_walk() -> void:
	var c := _panel_pet if _panel.visible and _panel_pet != null else _focus_creature()
	if c == null:
		return
	if c.action() == "sleep":
		_wake(c)
	_leave_with(c.pet, game.go_walk.bind(home["id"], c.pet["id"]))


## Teaching tricks - the pet whose card is open, or the one this home is looking at.
func go_tricks() -> void:
	var c := _panel_pet if _panel.visible and _panel_pet != null else _focus_creature()
	if c != null:
		_leave_with(c.pet, game.go_tricks.bind(home["id"], c.pet["id"]))


## Saves everyone (the pet is about to be loaded fresh by another screen), then goes.
func _leave_with(_pet: Dictionary, go: Callable) -> void:
	_save_all()
	go.call()


func _creature_at(at: Vector2) -> Creature:
	for i in range(creatures.size() - 1, -1, -1):
		if creatures[i].hit(at):
			return creatures[i]
	return null


## The pet nearest `at`, if `at` is within `reach` px of its body.
func _creature_near(at: Vector2, reach: float) -> Creature:
	var best: Creature = null
	var best_d := INF
	for c in creatures:
		var mid := c.global_position.lerp(c.top_global(), 0.5)
		var d := mid.distance_to(at) - (c.top_global() - c.global_position).length() * 0.5
		if d < reach and d < best_d:
			best = c
			best_d = d
	return best


func _furniture_at(at: Vector2) -> Furniture:
	for i in range(furniture.size() - 1, -1, -1):
		if furniture[i].hit(at):
			return furniture[i]
	return null


## Is the finger on the toy? One in a pet's mouth needs a closer touch - near it, you are petting.
func _toy_at(at: Vector2) -> bool:
	if toy == null or not is_instance_valid(toy) or toy.held or _tug != null:
		return false
	var in_mouth := toy.carrier != null and toy_state != "offer"
	return toy.hit(at, in_mouth)


# --- Petting ---------------------------------------------------------------------------------

## A tap on a pet: it looks up and says hello, and its card opens. Asleep, it just wakes up.
func boop(c: Creature) -> void:
	if c.action() == "sleep":
		_wake(c)
		return
	_show_panel(c)
	if c == _eater or c == _tug or (c == _toy_pet and toy_state != ""):
		return
	c.interrupt()
	c.perform("look", 0.9)
	c.leap(c.height_px * 0.12, 0.3)
	c.say("hello")


## A rub of `distance` pixels across a pet, the finger at `at` moving at `speed` px/s. Where you
## rub matters: its head and it shuts its eyes and leans into your finger; its body and it
## wiggles - keep going and it rolls over for a belly rub. Every so far of rubbing is a heart.
func stroke_pet(c: Creature, distance: float, at := Vector2.INF, speed := 0.0) -> void:
	# Busy eating, tugging or playing with a toy, it still loves it - it just carries on. Asleep,
	# it sleeps on, and dreams of you.
	var asleep := c.action() == "sleep"
	var busy := c == _eater or c == _tug or (c == _toy_pet and toy_state != "") or asleep
	var zone := c.touch_zone(at) if at != Vector2.INF else "body"
	if not busy:
		if c.action() != "belly":
			var want := "petted" if zone == "head" else "wiggle"
			if c.action() != want:
				c.perform(want, 0.6)
		c.extend_action(0.5)
		c.touch_at = at
	_pet_dist += distance
	if _pet_dist <= 140.0:
		return
	_pet_dist = 0.0
	_pet_hearts += 1
	_pats = 0
	_taught("rub")
	var belly := c.action() == "belly"
	# Every heart shows; every other one it says so, so a long rub is not a wall of noise.
	if _pet_hearts % 2 == 1 and not asleep:
		c.say("heart")
	else:
		_on_emote("heart", c.top_global())
	if speed > 1100.0 and randf() < 0.5 and not asleep:
		c.say("note")  # a tickle: it giggles
	_love(c, 1)
	_train(c, "charm", 0.5 if belly else 0.35)
	PetStore.change_need(c.pet, "fun", 0.015)
	if _pet_hearts == 4 and zone == "body" and not belly and not busy:
		c.perform("belly", 1.5)
		if not _hinted.has("belly"):
			_hinted["belly"] = true
			_show_hint("A belly rub! Keep rubbing!")


# --- Dragging things out of the drawers ------------------------------------------------------

func _grab(id: String) -> void:
	var item := Items.get_item(id)
	if item.is_empty():
		return
	# Something new out of a drawer: the pet lets go of the rope, if you were tugging.
	_end_tug()
	_held_item = item
	_samples.clear()
	_grab_screen = get_viewport().get_mouse_position()
	_grab_far = false
	_tap_take = false
	match item["category"]:
		"food":
			# A snack lying uneaten makes way for the new one - but not one a pet is going for.
			if food != null and is_instance_valid(food) and food != _eating:
				food.queue_free()
			food = _new_item(item)
			_held = food
			_held_kind = "food"
		"toy":
			if toy != null and is_instance_valid(toy):
				_reset_toy_play()
				toy.queue_free()
			toy = _new_item(item)
			_nudges = 0
			_nudger = null
			_held = toy
			_held_kind = "toy"
			_taught("toys")
			var play := toy.play()
			if not _hinted.has(play):
				_hinted[play] = true
				_show_hint(Words.PLAY_HINT.get(play, ""))
		"furniture":
			var f := _spawn_furniture({"item": id, "pos": [640, 600], "scale": 1.0, "flip": false})
			_held = f
			_held_kind = "furniture"
		"clothing", "bath":
			var ghost := Sprite2D.new()
			var tex: Texture2D = item["_tex"]
			ghost.texture = tex
			ghost.scale = Vector2.ONE * (110.0 / maxf(tex.get_width(), tex.get_height()))
			ghost.z_index = 100
			add_child(ghost)
			_held = ghost
			_held_kind = item["category"]
			_washing = null
			_wash_last = Vector2.INF
			_bathed = false
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
	it.bounds = Rect2(GROUND.position, GROUND.size + Vector2(30, 0))
	it.bounced.connect(_on_bounce.bind(it))
	world.add_child(it)
	return it


func _move_held(at: Vector2) -> void:
	_finger = at
	if _screen_of(at).distance_to(_grab_screen) > 24.0:
		_grab_far = true
	match _held_kind:
		"food", "toy":
			var it := _held as PlaceItem
			if _tug != null:
				_tug_drag(_screen_of(at).x)
				return
			it.position = Vector2(at.x, clampf(at.y + 60.0, it.bounds.position.y, it.bounds.end.y))
			it.z = maxf(0.0, it.position.y - at.y - it.radius * 0.9 * it.scale.y)
			it.vel = Vector2.ZERO
			it.vz = 0.0
			_samples.append([Time.get_ticks_msec() / 1000.0, at])
			if _samples.size() > 6:
				_samples.pop_front()
			if _held_kind == "toy" and it.play() == "tug":
				_try_start_tug(it, at)
				if _tug == null and _tug_call_in <= 0.0:
					_tug_call_in = 0.4
					_call_for_tug(at)
		"furniture", "move":
			_held.position = Vector2(at.x, clampf(at.y + 20.0, GROUND.position.y - 30.0, GROUND.end.y))
		"clothing":
			_held.position = at
		"bath":
			_held.position = at
			_scrub(at)


func _drop_held(at: Vector2, screen_at: Vector2) -> void:
	var held := _held
	var kind := _held_kind
	_held = null
	_held_kind = ""
	var over_bar := screen_at.y > get_viewport().get_visible_rect().size.y - 118.0
	# Let go on the drawer without going anywhere: a tap on its button. Dragged about and back
	# onto the drawer (or a swipe along it, scrolling): put back, nothing happens.
	var tapped := over_bar and not _grab_far
	var put_back := over_bar and _grab_far
	match kind:
		"food":
			(held as PlaceItem).held = false
			_told_full = false
			if put_back and at.distance_to(_bowl.position) >= 110.0:
				if food == held:
					food = null
				held.queue_free()
				return
			# A tap, or let go near the bowl: it goes in the bowl.
			if tapped or at.distance_to(_bowl.position) < 110.0:
				_into_bowl(held as PlaceItem)
			_taught("food")
			if int(_held_item.get("uses", 0)) > 0:
				game.profile.use_up(_held_item["id"])
				_fill_drawer()
		"toy":
			(held as PlaceItem).held = false
			var tap_take := _tap_take
			_tap_take = false
			if _tug_caller != null:
				_tug_caller.stop()
				_tug_caller = null
			if _tug != null:
				# Tug of war goes on: the knot pays out, and a touch anywhere takes it up again.
				_tug_down = false
				return
			if put_back and not tap_take:
				_reset_toy_play()
				if toy == held:
					toy = null
				held.queue_free()
				return
			# The flick: how fast the finger was going as it let go. A finger that stopped
			# before letting go puts the toy down.
			var v := Vector2.ZERO
			if _samples.size() >= 2:
				var a: Array = _samples[0]
				var b: Array = _samples[_samples.size() - 1]
				var dt: float = maxf(b[0] - a[0], 0.016)
				if _now() - float(b[0]) < 0.12:
					v = (b[1] - a[1]) / dt
			# Taken from a pet with a tap: thrown for you, up and away from it - fetch!
			if tap_take and not _grab_far and _now() - _tap_take_time < 0.5:
				v = Vector2(_tap_dir * 650.0, -750.0)
			_toy_dropped_on = _creature_at(at)
			throw_toy(v)
		"furniture":
			var f := held as Furniture
			if put_back:
				furniture.erase(f)
				f.queue_free()
				return
			if tapped:
				f.position = _free_floor_spot(f)
			f.entry["pos"] = PetBuilder.arr(f.position)
			home["items"].append(f.entry)
			game.profile.save()
			Sounds.play_varied("place", 1.0, 0.05)
			_select_furniture(f)
			_taught("decorate")
			if game.profile.count_today("decorate", 3):
				game.reward(1, "Nice decorating!")
		"move":
			var f := held as Furniture
			if over_bar:
				_remove_furniture(f)
				return
			f.entry["pos"] = PetBuilder.arr(f.position)
			game.profile.save()
			Sounds.play_varied("place", 1.1, 0.05, -3.0)
		"clothing":
			held.queue_free()
			var c := _creature_at(at)
			if c == null and not over_bar:
				c = _creature_near(at, 70.0)  # a near miss on a pet that moved still counts
			if tapped:
				# A tap on the clothes: on the pet whose card is open, or the one this home is
				# looking at.
				c = _panel_pet if _panel.visible and _panel_pet != null else _focus_creature()
			if c != null:
				dress(c, _held_item)
		"bath":
			held.queue_free()
			if _washing != null:
				_washing.touch_at = Vector2.INF
			_washing = null


## Puts a piece of clothing on a pet.
func dress(c: Creature, item: Dictionary) -> void:
	Journal.add_once(c.pet, "first_outfit", "Dressed up for the first time!")
	Wardrobe.put_on(c.pet, item)
	Sounds.play("dress")
	c.rebuild()
	c.perform("celebrate", 1.2)
	c.say("star")
	_train(c, "charm", 0.8)
	PetStore.save_pet(c.pet)
	_taught("wardrobe")
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
	Sounds.play("pickup", 0.85)
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
			Sounds.play("pickup", 1.3, -4.0)
			food = snack
			game.profile.save()
			return


# --- Toys ------------------------------------------------------------------------------------
# A toy is played with the way its words say (Words.toy_play). Every toy flies by its words
# (PlaceItem); what happens when it lands, or is held out, is its play:
#   fetch   flung: everyone chases, the catcher brings it back to where it was thrown from and
#           holds it out - take it and throw again. Put down: a pet brings it to you.
#   tug     held out: the nearest pet comes for the other end. Flung: fetched, and held out
#           with the end towards you - grab it to pull.
#   cuddle  a pet hugs it, then naps with it on something cozy.
#   chew    a pet lies down with it for a long chew.
#   squeak  tap it - squeak! - and a pet pounces on it and bats it about. Flung: chased, then
#           squeaked to bits in the catcher's mouth.
#   puzzle  a pet noses it about until the treat falls out.
#   push    a pet leans into it and shoves it along.

## Sends the toy off with a flick velocity in screen pixels/second. A slow one is a put-down.
func throw_toy(v: Vector2) -> void:
	_reset_toy_play()
	v = v.limit_length(1600.0) * toy.throw_scale()
	toy.vel = Vector2(v.x, v.y * 0.25)
	toy.vz = clampf(-v.y * 0.55, 0.0, 1000.0) + 120.0
	_thrown_from = _finger
	_toy_fresh = true
	if v.length() < 220.0:
		return  # put down: when it lands, _toy_landed decides who comes for it
	if toy.has_word("floaty"):
		toy.vz = maxf(toy.vz, 320.0)  # a disc sails, even flung flat
	Sounds.play_varied("throw", 0.8 + clampf(v.length() / 1600.0, 0.0, 1.0) * 0.5, 0.05)
	if toy.play() in ["fetch", "tug", "squeak"]:
		_start_chase()


func _start_chase() -> void:
	toy_state = "chase"
	_toy_fresh = false
	_chase_from = _now()
	for c in creatures:
		if not _free_for_toy(c):
			continue
		c.interrupt()
		c.rest_z = 0.0
		_chasers.append(c)
		c.say("note")
	if _chasers.is_empty():
		if not _asleep_hint():
			_show_hint("Everyone's too sleepy to play. Let them rest on something cozy!")
		toy_state = ""


## Whatever was going on with the toy stops: the kid has picked it up, or thrown it again.
func _reset_toy_play() -> void:
	if _toy_pet != null and toy_state != "":
		_toy_pet.straining = false
		_toy_pet.interrupt()
		if _pushing:
			_toy_pet.set_display_height(_toy_pet.fixed_height)  # back to its own walking speed
	for c: Creature in _chasers:
		c.stop()
	if toy != null and is_instance_valid(toy) and toy.carrier != null:
		toy.carrier = null
	toy_state = ""
	_toy_pet = null
	_chasers.clear()
	_leapt.clear()
	_caught_in_air = false
	_pushing = false


func _free_for_toy(c: Creature) -> bool:
	return c != _eater and c != _tug and c.action() != "sleep" and float(c.pet["needs"]["energy"]) >= 0.3


func _nearest_free(at: Vector2) -> Creature:
	var best: Creature = null
	for c in creatures:
		if _free_for_toy(c) and (best == null or c.position.distance_to(at) < best.position.distance_to(at)):
			best = c
	return best


## The spot a pet stands on to get its mouth to the toy, coming from the side it is on.
func _beside_toy(c: Creature, gap := 0.0) -> Vector2:
	var side := signf(toy.position.x - c.position.x)
	if side == 0.0:
		side = c.facing
	return toy.position - Vector2(side * (c.mouth_reach() + gap), -2.0)


## Still this pet's turn with the toy? (The kid may have picked it up, or thrown another.)
func _still_mine(c: Creature) -> bool:
	return toy != null and is_instance_valid(toy) and not toy.held and _toy_pet == c and toy_state == "busy"


func _carry(c: Creature) -> void:
	toy.hold_in_mouth(c)


func _update_toy(delta: float) -> void:
	_tug_call_in -= delta
	# A rope held out keeps calling, finger moving or not - resting it on the drawer still wants
	# a game, and a pet that ended up out of reach comes round again.
	if _tug == null and _held_kind == "toy" and _held == toy and toy.play() == "tug" and _tug_call_in <= 0.0:
		_tug_call_in = 0.5
		_try_start_tug(toy, _finger)
		if _tug == null:
			_call_for_tug(_finger)
	if _toy_press and _now() - _toy_press_time > 0.3:
		_toy_press = false
		take_toy(_toy_press_at)  # held still on it: picked up
		return
	if toy == null or not is_instance_valid(toy) or toy.held or _tug != null:
		return
	match toy_state:
		"chase":
			_update_chase()
		"return":
			_carry(_toy_pet)
		"offer":
			_carry(_toy_pet)
			_offer_left -= delta
			if _offer_left <= 0.0:
				_offer_done()
		"busy":
			if _pushing:
				var c := _toy_pet
				toy.slide_to(c.position + Vector2(c.facing * (c.mouth_reach() * 0.6 + toy.radius * toy.scale.x), 2.0))
				_push_thud_in -= delta
				if _push_thud_in <= 0.0:
					_push_thud_in = 0.7
					Sounds.play_varied("thud", 0.8, 0.08, -8.0)
			elif toy.carrier == _toy_pet:
				_carry(_toy_pet)
		"":
			if _toy_fresh and toy.landed():
				_toy_landed()


func _update_chase() -> void:
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
		var in_reach := mouth.distance_to(toy.global_position + Vector2(0, -toy.z)) < reach \
			and toy.z < c.height_px * 0.9 + c.z
		# Lying still on the grass, it just stoops for it - no drawn neck is long enough to reach.
		var at_it := toy.z < 8.0 and c.position.distance_to(aim.clamp(c.bounds.position, c.bounds.end)) < 14.0
		if (in_reach or at_it) and _now() - _chase_from > 0.35:
			_catch(c)
			return


func _catch(c: Creature) -> void:
	_caught_in_air = toy.z > 20.0
	_toy_pet = c
	toy.pick_up(c)
	Sounds.play_varied("catch", c._size_pitch(), 0.06)
	if not Voice.play_thing(toy.item) and toy.has_word("squeaky"):
		Sounds.play_varied("squeak", 1.0, 0.08)
	for other: Creature in _chasers:
		if other != c:
			other.stop()
			_train(other, "speed", 0.3)
			_friend_time(c, other, 2.0)  # they chased it together
	_chasers.clear()
	if toy.play() == "squeak":
		toy_state = "busy"
		_squeak_chew(c)
		return
	toy_state = "return"
	c.go_to(_hand_spot(c), _on_fetched, true)


## Where a pet brings a toy back to: the front of the place, where the finger let it go.
func _hand_spot(c: Creature) -> Vector2:
	var x := clampf(_thrown_from.x, 200.0, 1080.0)
	if absf(x - c.position.x) < 40.0:
		x = c.position.x
	return Vector2(x, GROUND.end.y - 4.0)


func _on_fetched() -> void:
	var c := _toy_pet
	if c == null or toy == null or not is_instance_valid(toy) or toy_state != "return":
		return
	var shiny := _shiny()
	_train(c, "speed", 0.8 * shiny)
	if _caught_in_air:
		_train(c, "agility", 1.0 * shiny)
		_on_emote("star", c.top_global())
	_train_words(c, 1.0 * shiny)
	PetStore.change_need(c.pet, "fun", 0.12)
	PetStore.change_need(c.pet, "energy", -0.04)
	_love(c, 1)
	Journal.add_once(c.pet, "first_fetch", "Played fetch for the first time!")
	var n := int(game.profile.today().get("fetch", 0)) + 1
	game.profile.today()["fetch"] = n
	if n % 5 == 0 and n <= 25:
		game.reward(2, "%d fetches today!" % n)
	_offer(c)


## Back with it, it holds the toy out: tap it and it is thrown again - or, a rope, tap the end
## and it is tug of war. It waits a good while: a kid who is slow to see it has not done wrong.
func _offer(c: Creature) -> void:
	toy_state = "offer"
	_offer_left = 8.0
	c.face_toward(640.0)
	c.perform("look", _offer_left)
	c.say("note")
	var tug := toy.play() == "tug"
	var shown := _teach("offer", {"gesture": "tap", "at": _toy_point,
		"caption": "Tap the rope to pull!" if tug else "Tap it to throw again!"})
	var key := "offer_" + toy.play()
	if not shown and not _hinted.has(key):
		_hinted[key] = true
		_show_hint("Tap the rope - tug of war!" if tug else "Tap it to throw it again!")


## Nobody took it: it drops it - and a chewy one gets chewed.
func _offer_done() -> void:
	var c := _toy_pet
	if toy.has_word("chewy"):
		toy_state = "busy"
		_chew(c)
	else:
		_let_go_of_toy(c)


func _let_go_of_toy(c: Creature) -> void:
	if toy != null and is_instance_valid(toy) and toy.carrier == c:
		toy.drop_at(c.position + Vector2(c.facing * c.mouth_reach(), 6.0), 20.0)
	c.rest_z = 0.0
	c.straining = false
	if c == _toy_pet:
		toy_state = ""
		_toy_pet = null
	_panel.refresh()


## The finger picks the toy up - off the ground, out of a pet's mouth, or (a rope it is holding
## out) by the other end, which starts tug of war.
func take_toy(at: Vector2) -> void:
	if toy == null or not is_instance_valid(toy):
		return
	var had: Creature = _toy_pet if toy_state != "" else null
	var offered := toy_state == "offer"
	_grab_screen = _screen_of(at)
	_grab_far = false
	if offered:
		_taught("offer")
	if offered and toy.play() == "tug":
		toy_state = ""
		_toy_pet = null
		_held = toy
		_held_kind = "toy"
		_held_item = toy.item
		_samples.clear()
		_start_tug(had, at)
		return
	# Thrown for you on a tap: away from the pet, the way it was holding it out.
	_tap_dir = signf(toy.position.x - had.position.x) if had != null else 1.0
	if _tap_dir == 0.0:
		_tap_dir = 1.0
	_reset_toy_play()
	toy.end_stretch()
	_held = toy
	_held_kind = "toy"
	_held_item = toy.item
	_samples.clear()
	toy.held = true
	Sounds.play("pickup")
	_move_held(at)
	if had != null:
		had.say("heart" if offered else "question")


## A tap on a toy lying about: it hops - and a squeaky one squeaks, and a pet pounces on it. A
## treat ball rolls, which helps whoever is nosing it: the treat comes out sooner.
func tap_toy() -> void:
	if toy == null or not is_instance_valid(toy) or toy.held or toy.carrier != null:
		return
	_look_at_toy()
	if toy.has_word("squeaky"):
		_taught("squeak")
		_squeak_toy()
		toy.hop(130.0)
		if not (toy_state == "busy" and _toy_pet != null):
			_send_pouncer()
	elif toy.play() == "puzzle":
		toy.hop(120.0, Vector2(randf_range(-1.0, 1.0) * 170.0, 0.0))
		Sounds.play_varied("bounce", 1.25, 0.08, -6.0)
		if toy_state == "busy" and _toy_pet != null:
			_nudges = mini(_nudges + 1, 2)  # the pet still gets the last nudge - and the treat
	else:
		toy.hop(220.0)


func _look_at_toy() -> void:
	for c in creatures:
		if c.is_busy() or c == _toy_pet:
			continue
		c.face_toward(toy.position.x)
		c.perform("look", 0.8)


func _squeak_toy() -> void:
	if toy == null or not is_instance_valid(toy):
		return
	_on_emote("note", toy.global_position + Vector2(0, -toy.z - toy.radius * 2.0))
	if not Voice.play_thing(toy.item):
		Sounds.play_varied("squeak", 1.0, 0.1)


## A toy put down (or flung) lands, and someone comes for it - by its play.
func _toy_landed() -> void:
	_toy_fresh = false
	var play := toy.play()
	if play == "squeak":
		_look_at_toy()
		# The hand taps it - squeak! - so a kid sees what a tap does.
		_teach("squeak", {"gesture": "tap", "at": _toy_point, "caption": "Tap it to squeak!",
			"on_press": _squeak_shown})
		return
	var c := _toy_dropped_on if _toy_dropped_on != null and _free_for_toy(_toy_dropped_on) \
		else _nearest_free(toy.position)
	_toy_dropped_on = null
	if c == null:
		_show_hint("Everyone's too sleepy to play - let them rest!")
		return
	if play == "puzzle" and c != _nudger:
		_nudges = 0  # a new pet on the treat ball starts from the beginning
		_nudger = c
	toy_state = "busy"
	_toy_pet = c
	c.interrupt()
	c.rest_z = 0.0
	match play:
		"fetch", "tug":
			c.go_to(_beside_toy(c), _bring_it.bind(c))
		"cuddle":
			c.go_to(_beside_toy(c), _cuddle.bind(c))
		"chew":
			c.go_to(_beside_toy(c), _start_chew.bind(c), true)
		"puzzle":
			_nudge(c)
		"push":
			_start_push(c)


## A fetch toy or a rope put down: a pet picks it up and brings it to you.
func _bring_it(c: Creature) -> void:
	if not _still_mine(c):
		return
	toy.pick_up(c)
	Sounds.play_varied("catch", c._size_pitch(), 0.06, -4.0)
	toy_state = "return"
	_thrown_from = Vector2(640.0, 0.0)
	c.go_to(_hand_spot(c), _offer.bind(c))


func _cuddle(c: Creature) -> void:
	if not _still_mine(c):
		return
	c.face_toward(toy.position.x)
	toy.pick_up(c)
	c.say("heart")
	for i in 3:
		get_tree().create_timer(1.1 + i * 1.1).timeout.connect(_heart_on.bind(c))
	c.perform("cuddle", 4.0, _cuddled.bind(c))


func _heart_on(c: Creature) -> void:
	if c.action() == "cuddle":
		_on_emote("heart", c.top_global())


func _cuddled(c: Creature) -> void:
	if not _still_mine(c):
		return
	_train_words(c, 1.0 * _shiny())
	_love(c, 1)
	PetStore.change_need(c.pet, "fun", 0.08)
	game.reward_daily("toy_play", 5, 1, "%s loves a cuddle!" % c.pet["name"])
	var cozy := _furniture_with("cozy")
	if cozy == null:
		_let_go_of_toy(c)
		c.say("heart")
		return
	# Off to bed with it.
	c.go_to(cozy.nap_spot(), _nap_with_toy.bind(c, cozy))


func _nap_with_toy(c: Creature, cozy: Furniture) -> void:
	if not _still_mine(c) or not is_instance_valid(cozy):
		return
	c.rest_z = cozy.nap_height()
	c.perform("sleep", 5.0, _napped.bind(c))


func _napped(c: Creature) -> void:
	_train(c, "stamina", 0.6)
	PetStore.change_need(c.pet, "energy", 0.2)
	if _still_mine(c):
		_let_go_of_toy(c)
	c.rest_z = 0.0


func _start_chew(c: Creature) -> void:
	if not _still_mine(c):
		return
	c.face_toward(toy.position.x)
	toy.pick_up(c)
	_chew(c)


func _chew(c: Creature) -> void:
	_sfx_times("chew", 6, 0.75, c._size_pitch())
	c.perform("chew", 4.5, _chewed.bind(c))


func _chewed(c: Creature) -> void:
	if not _still_mine(c):
		return
	_train_words(c, 1.2 * _shiny())
	_love(c, 1)
	PetStore.change_need(c.pet, "fun", 0.08)
	game.reward_daily("toy_play", 5, 1, "%s had a good chew!" % c.pet["name"])
	_let_go_of_toy(c)


## Caught a flung squeaky toy: it squeaks it and squeaks it.
func _squeak_chew(c: Creature) -> void:
	for i in 4:
		get_tree().create_timer(0.3 + i * 0.55).timeout.connect(_squeak_toy)
	c.perform("chew", 2.4, _squeaked.bind(c))


func _squeaked(c: Creature) -> void:
	if not _still_mine(c):
		return
	var shiny := _shiny()
	_train_words(c, 1.0 * shiny)
	if _caught_in_air:
		_train(c, "agility", 1.0 * shiny)
		_on_emote("star", c.top_global())
	_love(c, 1)
	PetStore.change_need(c.pet, "fun", 0.1)
	_let_go_of_toy(c)
	c.perform("celebrate", 1.0)


## Squeak! The nearest pet that wants to play runs over to pounce on it.
func _send_pouncer() -> void:
	var c := _nearest_free(toy.position)
	if c == null:
		return
	toy_state = "busy"
	_toy_pet = c
	c.interrupt()
	c.rest_z = 0.0
	c.say("note")
	c.go_to(_beside_toy(c, toy.radius * 0.6), _pounce.bind(c), true)


func _pounce(c: Creature) -> void:
	if not _still_mine(c):
		return
	c.face_toward(toy.position.x)
	c.leap(c.height_px * 0.35, 0.45)
	get_tree().create_timer(0.4).timeout.connect(_pounced.bind(c))


func _pounced(c: Creature) -> void:
	if not _still_mine(c):
		return
	_squeak_toy()
	toy.hop(160.0, Vector2(c.facing * randf_range(160.0, 260.0), randf_range(-50.0, 50.0)))  # batted away
	var shiny := _shiny()
	_train(c, "agility", 0.8 * shiny)
	_train_words(c, 0.6 * shiny)
	_love(c, 1)
	PetStore.change_need(c.pet, "fun", 0.06)
	game.reward_daily("toy_play", 5, 1, "%s pounced!" % c.pet["name"])
	c.perform("hop", 0.6)
	toy_state = ""
	_toy_pet = null


## A treat ball: nose it, it rolls; nose it again... the third time the treat falls out.
func _nudge(c: Creature) -> void:
	if not _still_mine(c):
		return
	c.go_to(_beside_toy(c, toy.radius * 0.5), _nudge_it.bind(c))


func _nudge_it(c: Creature) -> void:
	if not _still_mine(c):
		return
	c.face_toward(toy.position.x)
	c.perform("sniff", 0.7, _nudged.bind(c))


func _nudged(c: Creature) -> void:
	if not _still_mine(c):
		return
	_nudges += 1
	toy.hop(90.0, Vector2(c.facing * randf_range(170.0, 240.0), randf_range(-50.0, 50.0)))
	Sounds.play_varied("bounce", 1.25, 0.08, -6.0)
	if _nudges < 3:
		if randf() < 0.5:
			c.say("question")
		get_tree().create_timer(1.0).timeout.connect(_nudge.bind(c))
		return
	# Out it pops!
	_nudges = 0
	_nudger = null
	var shiny := _shiny()
	for i in 2:
		_on_emote("crumb", toy.global_position + Vector2(randf_range(-20, 20), -toy.z - 20.0))
	_on_emote("star", c.top_global())
	_sfx_times("munch", 3, 0.35, c._size_pitch())
	c.perform("eat", 1.4)
	PetStore.change_need(c.pet, "food", 0.1)
	_train(c, "smarts", 0.5 * shiny)
	_train_words(c, 1.0 * shiny)
	_love(c, 1)
	PetStore.change_need(c.pet, "fun", 0.1)
	game.reward_daily("toy_play", 5, 1, "%s got the treat out!" % c.pet["name"])
	toy_state = ""
	_toy_pet = null


## Something heavy: it goes round behind it and leans in, shoving it towards the middle.
func _start_push(c: Creature) -> void:
	var dir := signf(640.0 - toy.position.x)
	if dir == 0.0:
		dir = 1.0
	var behind := toy.position - Vector2(dir * (c.mouth_reach() * 0.6 + toy.radius * toy.scale.x + 6.0), -2.0)
	c.go_to(behind, _push_it.bind(c, dir))


func _push_it(c: Creature, dir: float) -> void:
	if not _still_mine(c):
		return
	c.facing = dir
	c.straining = true
	c.walk_speed *= 0.4
	_pushing = true
	_push_thud_in = 0.0
	var to := clampf(toy.position.x + dir * 260.0, GROUND.position.x + 60.0, GROUND.end.x - 60.0)
	c.go_to(Vector2(to - dir * (c.mouth_reach() * 0.6 + toy.radius * toy.scale.x), c.position.y), _pushed.bind(c))
	c.say("note")


func _pushed(c: Creature) -> void:
	_pushing = false
	c.straining = false
	c.set_display_height(c.fixed_height)  # back to its own walking speed
	if not _still_mine(c):
		return
	var shiny := _shiny()
	_train(c, "strength", 1.0 * shiny)
	_train_words(c, 1.0 * shiny)
	_love(c, 1)
	PetStore.change_need(c.pet, "fun", 0.08)
	PetStore.change_need(c.pet, "energy", -0.03)
	game.reward_daily("toy_play", 5, 1, "%s is so strong!" % c.pet["name"])
	c.perform("celebrate", 1.0)
	c.say("star")
	toy_state = ""
	_toy_pet = null


func _shiny() -> float:
	return 2.0 if toy != null and is_instance_valid(toy) and toy.item.get("shine", "") != "" else 1.0


## Playing with a toy trains whatever its words train (a chewy toy stamina, a bouncy one agility).
func _train_words(c: Creature, amount: float) -> void:
	for w in toy.item.get("words", []):
		_train(c, Words.stat_of("toy", w), amount)


## A thing hitting the ground: its own sound if the kid gave it one, else what its words say.
func _on_bounce(speed: float, item: PlaceItem) -> void:
	var loud := clampf(speed / 900.0, 0.2, 1.0)
	var vol := linear_to_db(loud)
	if item.is_food:
		Sounds.play_varied("thud", 1.5, 0.08, vol - 6.0)
		return
	if item.has_word("squeaky"):
		_on_emote("note", item.global_position + Vector2(0, -item.z - 30.0))
	if Voice.play_thing(item.item):
		return
	if item.has_word("squeaky"):
		Sounds.play_varied("squeak", 1.0, 0.08, vol)
	elif item.has_word("heavy"):
		Sounds.play_varied("thud", 1.0, 0.06, vol)
	elif item.has_word("soft"):
		Sounds.play_varied("thud", 1.6, 0.06, vol - 8.0)  # a soft flump
	else:
		Sounds.play_varied("bounce", 0.8 + 0.5 * loud, 0.05, vol)


## The same effect a few times, `gap` seconds apart - chewing, bouncing on a trampoline.
func _sfx_times(id: String, count: int, gap: float, pitch := 1.0, vol := 0.0) -> void:
	for i in count:
		get_tree().create_timer(i * gap).timeout.connect(Sounds.play_varied.bind(id, pitch, 0.06, vol))


# --- Tug of war ------------------------------------------------------------------------------
# The same pull as the Tug-of-War Cup (TugGame), so playing at home is practice for it: the pet
# takes the rope's other end and backs off to the right, facing you, and your end - the orange
# knot on a strip of paper beside it (TugGame.PullBar) - slides LEFT to pull and back RIGHT to let
# go, in time with a guide ring and a drum. A finger anywhere moves the knot one to one; lifting
# it lets the rope pay out, which is letting go too. Each pull in time is a HEAVE: the knot
# flashes, the pet leans back and growls, a heart fills - and strength grows (`_train`). Fill all
# TUG_GOAL hearts and the pet lets go happily: you win, it celebrates. Out of time costs nothing,
# and nothing a finger does ends it badly. A kid who wanders off leaves the pet holding its end
# for a while, then it drops it - no winner, no fuss.

## Hearts to fill - good heaves - to win.
const TUG_GOAL := 5
## How good a pull has to be to fill a heart (TugGame grades it 0..1: how far, how near the ring).
## Kinder than the cup's 0.7: this is play.
const TUG_GOOD := 0.55
## The knot's slide in screen px (one to one under the finger), and the gap from the pet's mouth
## to the knot let right out.
const TUG_STROKE := 240.0
const TUG_GAP := 190.0
## The pet's mouth must be this far from the left edge to leave room for the strip and its arrows
## clear of the buttons down the left; if it is not, the pet backs off to the right to get a grip.
const TUG_MOUTH_MIN := 120.0 + 130.0 + TUG_STROKE + TUG_GAP
## No finger on the rope this long (seconds) and the pet drops its end.
const TUG_REST := 8.0 * TugGame.BEAT


## Holding a stretchy toy right by a pet's mouth: it grabs the other end.
func _try_start_tug(it: PlaceItem, at: Vector2) -> void:
	for c in creatures:
		if c == _eater or c.action() == "sleep":
			continue
		if c.mouth_global().distance_to(at) < maxf(60.0, c.height_px * 0.3):
			_start_tug(c, at)
			return


## Holding out a stretchy toy: the nearest pet that wants to play comes for the other end -
## the kid does not have to find its mouth. It comes round to the right of the finger, so it
## faces your end of the rope the way it will pull.
func _call_for_tug(at: Vector2) -> void:
	var c := _tug_caller if _tug_caller != null else _nearest_free(at)
	if c == null:
		return
	_tug_caller = c
	var side := 1.0 if at.x + c.mouth_reach() < GROUND.end.x - 20.0 else -1.0
	# Stand so its mouth comes to the finger: its mouth is this far above and in front of its feet.
	var up := c.global_position.y - c.mouth_global().y
	c.go_to(Vector2(at.x + side * c.mouth_reach(), at.y + up), _tug_arrived.bind(c), true)


## There: it takes the end. Near enough is near enough - the finger may be resting on the
## drawer, below where a pet can stand - unless the finger has gone off somewhere else since.
func _tug_arrived(c: Creature) -> void:
	if _tug != null or _held_kind != "toy" or _held != toy or c != _tug_caller:
		return
	c.face_toward(_finger.x)
	if absf(c.mouth_global().x - _finger.x) < maxf(c.height_px * 1.5, 220.0):
		_start_tug(c, _finger)


## It has the other end. The finger that brought the rope is already on it: it holds the knot.
func _start_tug(c: Creature, at: Vector2) -> void:
	_tug = c
	_tug_caller = null
	_finger = at
	Sounds.play("tug")
	c.interrupt()
	c.rest_z = 0.0
	c.perform("tug", 999.0)
	toy.held = false
	toy.pick_up(c)
	_panel.visible = false
	# The camera holds still while you tug, so your end stays under the knot on the screen.
	_tug_follow = _follow
	_follow = null
	# Facing your end, on its left - backing off to the right first if it needs the room, and
	# to the front, where no bed or tree hides it.
	c.facing = -1.0
	var reach := c.mouth_reach()
	var up := c.position.y - c.mouth_global().y
	_tug_from = c.position
	_tug_to = Vector2(c.position.x, maxf(c.position.y, GROUND.end.y - 20.0))
	var m := _hud_of(_tug_to + Vector2(-reach, -up))
	if m.x < TUG_MOUTH_MIN:
		_tug_to.x = minf(_world_of_hud(Vector2(TUG_MOUTH_MIN + 24.0, m.y)).x + reach, GROUND.end.x)
		m = _hud_of(_tug_to + Vector2(-reach, -up))
	# A beat to get a grip ("Ready..."), two if it has a way to back off.
	_tug_lead = TugGame.BEAT * (2.0 if _tug_from.distance_to(_tug_to) > 220.0 else 1.0)
	_tug_t = -_tug_lead
	_tug_half = -999
	_tug_h = 0.0
	_tug_prev_h = 0.0
	_tug_vel = 0.0
	_tug_heave = 0.0
	_tug_travel = 0.0
	_tug_near_sum = 0.0
	_tug_near_time = 0.0
	_tug_heaves = 0
	_tug_dry = 0
	_tug_idle = 0.0
	_tug_down = true
	_tug_down_x = _screen_of(at).x
	_tug_down_h = 0.0
	_build_tug_hud(m)
	# The first few times, the hand rides the guide ring: pull left with it, let go, again.
	_tug_teach = HowTo.first_times(game.profile, "howto_home_tug", HOW_TIMES)
	_tug_guide_point()
	if _tug_teach:
		_how_key = "tug"
		var y := _tug_bar.y
		_how_spec = {"gesture": "follow", "follow": _tug_guide_point, "until_touch": true,
			"caption": "Pull left, let go, again!",
			"caption_y": y - 170.0 if y - 170.0 >= 96.0 else y + 100.0}
		_show_how()
	else:
		_show_hint("Tug of war! Pull left with the ring, let go, again!")


## The rope's handle, the PULL!/let go word over it and the hearts to fill under it - beside the
## pet's mouth (`m`, on the screen), so the rope runs from its mouth to your knot.
func _build_tug_hud(m: Vector2) -> void:
	_drop_tug_hud([_tug_bar, _tug_word, _tug_hearts])
	var y := clampf(m.y, 240.0, 470.0)
	_tug_bar = TugGame.PullBar.new()
	_tug_bar.y = y
	_tug_bar.loose_x = m.x - TUG_GAP
	_tug_bar.pulled_x = m.x - TUG_GAP - TUG_STROKE
	_hud_root.add_child(UI.full_rect(_tug_bar))
	var mid := m.x - TUG_GAP - TUG_STROKE / 2.0
	_tug_word = UI.title("Ready...", 40)
	_tug_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tug_word.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tug_word.position = Vector2(mid - 200.0, y - 100.0)
	_tug_word.size = Vector2(400, 54)
	_hud_root.add_child(_tug_word)
	_tug_hearts = UI.hearts(0, 40)
	_tug_hearts.position = Vector2(mid - 100.0, y + 46.0)
	_hud_root.add_child(_tug_hearts)


## Frees what is left of a tug's HUD (some of it may be gone already).
func _drop_tug_hud(nodes: Array) -> void:
	for n in nodes:
		if is_instance_valid(n):
			n.queue_free()


## Where the guide ring is on the screen, for the hand to ride (where it last was, as the hand
## fades after the rope is let go).
func _tug_guide_point() -> Vector2:
	if _tug_bar != null and is_instance_valid(_tug_bar):
		_tug_guide = Vector2(_tug_bar.x_of(TugGame.guide_at(_tug_t)), _tug_bar.y)
	return _tug_guide


## A finger comes down anywhere while tugging: it takes hold of the knot where it is.
func _tug_press(x: float) -> void:
	_tug_down = true
	_tug_down_x = x
	_tug_down_h = _tug_h
	_tug_idle = 0.0


## The finger slides: left pulls the knot, right lets it out - one to one.
func _tug_drag(x: float) -> void:
	if not _tug_down:
		return
	_tug_h = clampf(_tug_down_h + (_tug_down_x - x) / TUG_STROKE, 0.0, 1.0)
	# Pinned at an end: the next move the other way answers at once.
	if _tug_h <= 0.0 or _tug_h >= 1.0:
		_tug_down_x = x
		_tug_down_h = _tug_h
	_tug_idle = 0.0


func _update_tug(delta: float) -> void:
	if _tug == null:
		return
	if toy == null or not is_instance_valid(toy) or not is_instance_valid(_tug):
		_end_tug()
		return
	var c := _tug
	_tug_t += delta
	var live := _tug_t >= 0.0
	# The knot: under the finger, or paying out on its own.
	if not _tug_down:
		_tug_h = move_toward(_tug_h, 0.0, delta * 2.5)
		_tug_idle += delta
	var dh := _tug_h - _tug_prev_h
	_tug_prev_h = _tug_h
	_tug_vel = lerpf(_tug_vel, dh / maxf(delta, 0.001), minf(1.0, delta * 12.0))
	# A new half-beat: the drum on a pull, and the pull just finished graded.
	var half := int(floor(_tug_t / (TugGame.BEAT * 0.5)))
	if half != _tug_half:
		_tug_half = half
		_tug_new_half()
		if _tug == null:
			return  # that was the winning heave
	var near := TugGame.nearness(_tug_h, _tug_t)
	var pulling := TugGame.is_pull(_tug_t)
	var want := 0.0
	if pulling and live:
		if dh > 0.0:
			_tug_travel += dh
		_tug_near_sum += near * delta
		_tug_near_time += delta
		# Going left with the ring, at its pace (wiggling back and forth counts no more).
		var v := maxf(0.0, _tug_vel) if _tug_travel <= 1.05 else 0.0
		want = near * clampf(v / (0.7 / (0.5 * TugGame.BEAT)), 0.0, 1.0)
	_tug_heave = move_toward(_tug_heave, want, delta * 6.0)
	# The pet: backs off to get a grip, then leans back and growls harder the better you pull -
	# and a good heave draws it your way a little.
	var grip := 1.0 if _tug_lead <= 0.0 else clampf(1.0 + _tug_t / _tug_lead, 0.0, 1.0)
	grip = grip * grip * (3.0 - 2.0 * grip)
	c.position = _tug_from.lerp(_tug_to, grip) - Vector2(34.0 * _tug_heave, 0.0)
	c.facing = -1.0
	c.effort = clampf(0.2 + 0.8 * _tug_heave, 0.0, 1.0)
	toy.global_position = c.mouth_global() + Vector2(0, toy.radius * 0.3)
	toy.z = 0.0
	toy.stretch_to = _world_of_hud(Vector2(_tug_bar.x_of(_tug_h), _tug_bar.y))
	_tug_bar.t = _tug_t
	_tug_bar.h = _tug_h
	_tug_bar.near = near if live else 0.0
	if not live:
		_tug_word.text = "Ready..."
		_tug_word.add_theme_color_override("font_color", UI.INK)
		_tug_word.add_theme_font_size_override("font_size", 36)
	else:
		_tug_word.text = "PULL!" if pulling else "let go..."
		var col := TugGame.PULL_GREEN if pulling else TugGame.LET_GO
		_tug_word.add_theme_color_override("font_color", col)
		_tug_word.add_theme_font_size_override("font_size", 46 if pulling else 32)
	# Resting, or not quite getting it: the hand comes back to show it again.
	var resting := _tug_idle > 2.0 * TugGame.BEAT or _tug_dry >= 3
	if _tug_teach and _how_key == "tug" and _how == null and resting:
		_tug_dry = 0
		_show_how()
	if _tug_idle > TUG_REST:
		_show_hint("%s dropped the rope - tug again any time!" % c.pet["name"])
		_end_tug()


func _tug_new_half() -> void:
	if not TugGame.is_pull(_tug_t):
		# A pull just ended: how was it? (Not while it is still getting a grip.)
		if _tug_t > 0.0:
			var grade := minf(_tug_travel, 1.0) * (_tug_near_sum / maxf(_tug_near_time, 0.001))
			if grade >= TUG_GOOD:
				_tug_heaved()
			else:
				_tug_dry += 1
				if grade >= 0.25:
					Sounds.play_varied("tug", 1.0, 0.1)
					_train(_tug, "strength", 0.15 * _shiny())
		_tug_travel = 0.0
		_tug_near_sum = 0.0
		_tug_near_time = 0.0
		return
	# A pull starts: the drum - or, getting a grip, a tick.
	Sounds.play("drum_beat" if _tug_t >= -0.05 else "count_tick")


## A pull in time: HEAVE! The knot flashes, the pet growls and leans back, a heart fills.
func _tug_heaved() -> void:
	var c := _tug
	_tug_heaves += 1
	_tug_dry = 0
	_tug_bar.flash = 1.0
	Sounds.play("heave")
	Voice.speak(c.pet, "tug", c)
	_on_emote("heart", c.top_global())
	_train(c, "strength", 0.5 * _shiny())
	_fill_tug_heart(_tug_heaves - 1)
	# They have got it: the hand can go.
	if _how_key == "tug":
		_drop_how()
	if _tug_heaves >= TUG_GOAL:
		_tug_won()


func _fill_tug_heart(i: int) -> void:
	if _tug_hearts == null or i < 0 or i >= _tug_hearts.get_child_count():
		return
	var r := _tug_hearts.get_child(i) as TextureRect
	r.texture = Items.art_texture("icon_heart")
	r.pivot_offset = r.size / 2.0
	r.scale = Vector2(1.7, 1.7)
	var pop := create_tween().tween_property(r, "scale", Vector2.ONE, 0.3)
	pop.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Every heart filled: it lets go of its end, happily, and the rope flies to your side - you win,
## and it is so pleased it played.
func _tug_won() -> void:
	var knot := _world_of_hud(Vector2(_tug_bar.x_of(_tug_h), _tug_bar.y))
	var c := _tug_stop()
	if toy != null and is_instance_valid(toy):
		toy.drop_at(Vector2(knot.x, c.position.y + 4.0), maxf(0.0, c.position.y - knot.y))
		toy.vz = 260.0
	c.perform("celebrate", 1.8)
	c.say("heart")
	for i in 3:
		_on_emote("heart", c.top_global() + Vector2(randf_range(-40, 40), randf_range(-20, 10)))
	Sounds.play("cheer")
	_love(c, 1)
	PetStore.change_need(c.pet, "fun", 0.12)
	PetStore.change_need(c.pet, "energy", -0.03)
	if toy != null and is_instance_valid(toy):
		_train_words(c, 1.0 * _shiny())
	Journal.add_once(c.pet, "first_tug", "Played tug of war!")
	game.reward_daily("tug", 5, 1, "You won tug of war with %s!" % c.pet["name"])
	_tug_word.text = "You win!"
	_tug_word.add_theme_color_override("font_color", TugGame.PULL_GREEN)
	_tug_word.add_theme_font_size_override("font_size", 50)
	_tug_bar.flash = 1.0
	# The win stays up a moment, then the rope's handle goes.
	get_tree().create_timer(1.8).timeout.connect(_drop_tug_hud.bind([_tug_bar, _tug_word, _tug_hearts]))
	_tug_bar = null
	_tug_word = null
	_tug_hearts = null


## Tug of war stops with no winner - another toy came out, or the kid went off to do something
## else. The pet just drops its end.
func _end_tug() -> void:
	if _tug == null:
		return
	var c := _tug_stop()
	if toy != null and is_instance_valid(toy) and is_instance_valid(c):
		toy.drop_at(c.position + Vector2(c.facing * c.mouth_reach(), 6.0), 10.0)
	_drop_tug_hud([_tug_bar, _tug_word, _tug_hearts])
	_tug_bar = null
	_tug_word = null
	_tug_hearts = null


## Lets go of the other end: the pet stops pulling, the finger lets go, the camera follows again.
## Returns the pet that was tugging.
func _tug_stop() -> Creature:
	var c := _tug
	_tug = null
	_tug_down = false
	if is_instance_valid(c):
		c.effort = 0.0
		c.interrupt()
	if toy != null and is_instance_valid(toy):
		toy.end_stretch()
		toy.held = false
		if _held == toy:
			_held = null
			_held_kind = ""
	_follow = _tug_follow
	_tug_follow = null
	if _how_key == "tug":
		_how_key = ""
		_drop_how()
	return c


# --- Feeding ---------------------------------------------------------------------------------

func _update_food(delta: float) -> void:
	if _eater != null:
		# Busy with its snack - another the kid holds out waits for whoever is next.
		if _eating == null or not is_instance_valid(_eating):
			return
		if _eating.has_meta("in_bowl") and _eater.action() == "eat_bowl":
			_eating.sprite.scale *= 1.0 - delta * 0.35
			if randf() < delta * 2.5:
				_on_emote("crumb", _bowl.position + Vector2(randf_range(-20, 20), -40))
			_munch_in -= delta
			if _munch_in <= 0.0:
				_munch_in = randf_range(0.3, 0.42)
				Sounds.play_varied("munch", _eater._size_pitch(), 0.1)
		elif _eating.carrier == _eater:
			_eating.hold_in_mouth(_eater)
			_eating.sprite.scale *= 1.0 - delta * 0.3
			if randf() < delta * 2.5:
				_on_emote("crumb", _eater.mouth_global())
			_munch_in -= delta
			if _munch_in <= 0.0:
				_munch_in = randf_range(0.3, 0.42)
				Sounds.play_varied("munch", _eater._size_pitch(), 0.1)
		return
	if food == null or not is_instance_valid(food):
		return
	if not food.landed() or toy_state in ["chase", "return"]:
		return
	var hungriest: Creature = null
	for c in creatures:
		if c == _tug or c.action() == "sleep" or (c == _toy_pet and toy_state != ""):
			continue
		if float(c.pet["needs"]["food"]) > 0.95:
			continue
		if hungriest == null or float(c.pet["needs"]["food"]) < float(hungriest.pet["needs"]["food"]):
			hungriest = c
	if hungriest == null:
		if not _told_full and not creatures.is_empty():
			_told_full = true
			if not _asleep_hint():
				_show_hint("Everyone's full! Maybe later.")
		return
	_eater = hungriest
	_eating = food
	hungriest.interrupt()
	hungriest.rest_z = 0.0
	var side := signf(food.position.x - hungriest.position.x)
	if side == 0.0:
		side = 1.0
	hungriest.go_to(food.position - Vector2(side * hungriest.mouth_reach(), -2.0), _arrive_at_food, true)


func _arrive_at_food() -> void:
	if _eating == null or not is_instance_valid(_eating) or _eater == null or _eating.held:
		_eater = null
		_eating = null
		return
	_eater.face_toward(_eating.position.x)
	if _eating.has_meta("in_bowl"):
		# Eaten from the bowl, nose down.
		_munch_in = 0.0
		_eater.perform("eat_bowl", 2.6, _ate)
		return
	# It picks the food up to munch it - no drawn neck is long enough to reach the ground.
	_eating.pick_up(_eater)
	_munch_in = 0.0
	_eater.perform("eat", 2.4, _ate)


func _ate() -> void:
	var c := _eater
	var snack := _eating
	_eater = null
	_eating = null
	if c == null:
		return
	Care.fed(c.pet)
	var item: Dictionary = snack.item if snack != null and is_instance_valid(snack) else {}
	if snack != null and is_instance_valid(snack):
		snack.queue_free()
	if food == snack:
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
	if word == "cozy":
		spot = f.nap_spot()
	elif word == "hidey":
		spot = f.position + Vector2(randf_range(-20, 20), -10)  # just behind it
	elif word in ["shady", "warm", "musical", "scratchy", "fancy"]:
		spot = f.position + Vector2(signf(c.position.x - f.position.x + 0.1) * f.height_px * 0.45, 8)
	c.go_to(spot, func(): _use_furniture(c, f, word))


func _use_furniture(c: Creature, f: Furniture, word: String) -> void:
	if not is_instance_valid(f):
		return
	match word:
		"cozy":
			c.rest_z = f.nap_height()
			c.perform("sleep", randf_range(6.0, 10.0), func():
				PetStore.change_need(c.pet, "energy", 0.35)
				_train(c, "stamina", 0.4)
				c.rest_z = 0.0)
		"shady", "warm":
			c.perform("sleep", 4.0, func(): PetStore.change_need(c.pet, "energy", 0.2))
		"bouncy":
			c.rest_z = f.perch_height()
			_sfx_times("trampoline", 6, 0.63, c._size_pitch())
			c.perform("bounce", 3.5, func():
				_train(c, "agility", 1.4)
				PetStore.change_need(c.pet, "fun", 0.06)
				c.rest_z = 0.0)
		"climbable":
			Sounds.play_varied("hop", c._size_pitch())
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
			var whee := func():
				Sounds.play_varied("slide", 1.0, 0.05)
				c.go_to(f.position + Vector2(f.height_px * 0.7, 12), landed, true)
			c.perform("look", 1.0, whee)
		"musical":
			if str(f.item.get("id", "")).contains("piano"):
				_sfx_times("piano", 3, 1.2)
			else:
				_sfx_times("drum", 7, 0.5)
			c.perform("dance", 3.5, func():
				_train(c, "charm", 1.3)
				PetStore.change_need(c.pet, "fun", 0.05))
		"splashy":
			_sfx_times("splash", 3, 0.9, 1.0, -3.0)
			c.perform("splash", 3.0, func():
				_train(c, "stamina", 1.1)
				PetStore.change_need(c.pet, "clean", 0.3)
				PetStore.change_need(c.pet, "fun", 0.08))
		"scratchy":
			_sfx_times("scratch", 3, 0.8)
			c.perform("scratch", 2.5, func(): _train(c, "strength", 1.1))
		"hidey":
			c.perform("hide", 5.0, func():
				_train(c, "smarts", 1.0)
				c.say("question"))
		"fancy":
			c.perform("look", 2.5, func(): _train(c, "charm", 0.6))


# --- Calling by voice (optional) ------------------------------------------------------------

## The Listen button: on, the game listens for a clap or a shout; off, the mic is off. The mic
## needs a yes first (the Settings switch, or this asking) - and "No thanks" always works.
func toggle_listening() -> void:
	if _listening:
		_set_listening(false)
		return
	if not bool(game.profile.settings().get("mic", false)):
		_ask_mic()
		return
	_set_listening(true)


func _set_listening(on: bool) -> void:
	_listening = on
	if on:
		if OS.get_name() == "Android":
			OS.request_permission("android.permission.RECORD_AUDIO")
		Sounds.listen_start()
		_quiet = 0.05
		_call_rest = 1.0
		_show_hint("Listening! Clap or call - your pets will come running.")
	else:
		Sounds.listen_stop()
	var b := _listen_btn
	b.get_child(0).get_child(0).texture = Items.art_texture("snd_record" if on else "snd_mic_off")
	if on:
		b.add_theme_stylebox_override("normal", UI._box(UI.GOOD, UI.INK, 3))
	else:
		b.remove_theme_stylebox_override("normal")


func _ask_mic() -> void:
	if _ask != null:
		return
	_ask = PanelContainer.new()
	_ask.add_theme_stylebox_override("panel", UI._box(UI.PAPER, UI.INK, 3, 20, 24))
	_ask.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_ask.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_ask.grow_vertical = Control.GROW_DIRECTION_BOTH
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 12)
	_ask.add_child(col)
	col.add_child(UI.title("Call your pets?", 34))
	var l := UI.label("The game listens for a clap or a shout - just how loud, never the words. Nothing is recorded or kept.", 22, true)
	l.custom_minimum_size = Vector2(520, 0)
	col.add_child(l)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.add_child(UI.icon_button("snd_mic_off", "No thanks", _close_ask, 44, Vector2(180, 96)))
	var yes := UI.big_icon_button("snd_record", "Yes, listen!", _mic_yes)
	yes.custom_minimum_size = Vector2(300, 96)
	row.add_child(yes)
	col.add_child(row)
	_hud_root.add_child(_ask)


func _close_ask() -> void:
	if _ask != null:
		UI.retire(_ask)
		_ask = null


func _mic_yes() -> void:
	game.profile.settings()["mic"] = true
	game.profile.save()
	_close_ask()
	_set_listening(true)


## Every frame while listening: a sound much louder than the room - a clap, a shout - is a call.
func _listen(delta: float) -> void:
	var level := Sounds.loudness()
	_call_rest -= delta
	if level > maxf(0.3, _quiet * 5.0) and _call_rest <= 0.0:
		_call_rest = 2.0
		heard_call()
		return
	_quiet = lerpf(_quiet, level, minf(1.0, delta * 0.5))


## A call! Everyone looks up and comes running to the front - a sleeper wakes up gently first.
func heard_call() -> void:
	var i := 0
	for c in creatures:
		if c == _eater or c == _tug:
			continue
		if c.action() == "sleep":
			_wake(c)
		else:
			c.interrupt()
			c.rest_z = 0.0
			c.say("question")
			var spot := Vector2(640.0 + (i - (creatures.size() - 1) / 2.0) * 150.0, GROUND.end.y - 20.0)
			c.go_to(spot, _came.bind(c), true)
		i += 1
	if not _hinted.has("called"):
		_hinted["called"] = true
		_show_hint("They heard you!")


func _came(c: Creature) -> void:
	c.face_toward(640.0 if absf(c.position.x - 640.0) > 40.0 else c.position.x + 1.0)
	c.perform("greet", 1.2)
	c.say("hello")
	_love(c, 1)


# --- Friends ----------------------------------------------------------------------------------

func _free_to_socialise(c: Creature) -> bool:
	return c.action() == "" and c != _toy_pet and c != _eater and c != _tug and c != _tug_caller \
		and not _chasers.has(c)


## Now and then an idle pet (or a party guest) goes to spend time with another - more often one it
## gets on with, or knows well. A first hello; after that a nuzzle, or for lively friends a game
## of chase. True if it went.
func _social(c: Creature) -> bool:
	var choices := []
	var total := 0.0
	for o in creatures + guests:
		if o == c or not _free_to_socialise(o):
			continue
		var w := Friends.fit(c.pet, o.pet) * (1.0 + Friends.points(c.pet, o.pet["id"]) / 30.0)
		choices.append([o, w])
		total += w
	if choices.is_empty():
		return false
	var roll := randf() * total
	var o: Creature = choices[0][0]
	for ch in choices:
		roll -= float(ch[1])
		if roll <= 0.0:
			o = ch[0]
			break
	if not Friends.has_met(c.pet, o.pet["id"]):
		meet(c, o)
		return true
	var lively := false
	for w in c.pet.get("personality", []) + o.pet.get("personality", []):
		if w in ["playful", "sporty", "silly"]:
			lively = true
	if Friends.level(Friends.points(c.pet, o.pet["id"])) >= 2 and lively and randf() < 0.5:
		chase(c, o)
	else:
		c.go_to(_beside(o, c), _nuzzle.bind(c, o))
	return true


## The spot beside `o` where `c` stands to say hello, on the side `c` is coming from.
func _beside(o: Creature, c: Creature) -> Vector2:
	var side := signf(c.position.x - o.position.x + 0.1)
	return (o.position + Vector2(side * (o.height_px * 0.45 + c.height_px * 0.4), 4)).clamp(GROUND.position, GROUND.end)


## Two pets meet for the first time: a sniff - and how it goes says how they will get on.
func meet(c: Creature, o: Creature) -> void:
	Friends.meet(c.pet, o.pet)
	c.go_to(_beside(o, c), _met.bind(c, o))


func _met(c: Creature, o: Creature) -> void:
	c.face_toward(o.position.x)
	o.face_toward(c.position.x)
	c.perform("sniff", 1.0)
	if _free_to_socialise(o):
		o.perform("sniff", 1.0)
	var fit := Friends.fit(c.pet, o.pet)
	var slow: bool = Friends.liking(c.pet, o.pet)["slow"] or Friends.liking(o.pet, c.pet)["slow"]
	var why := Friends.why(c.pet, o.pet, 1, slow)
	var reason := ("%s." % Friends.sentence(str(why[0]))) if not why.is_empty() else ""
	if slow:
		c.say("question")
		_show_hint("%s met %s! %s" % [c.pet["name"], o.pet["name"], reason])
	elif fit >= 1.25:
		c.say("heart")
		o.say("heart")
		_show_hint("%s met %s! %s - they'll get on!" % [c.pet["name"], o.pet["name"], reason.trim_suffix(".")])
	else:
		c.say("hello")
		_show_hint("%s met %s!" % [c.pet["name"], o.pet["name"]])
	_friend_time(c, o, 2.0)


func _nuzzle(c: Creature, o: Creature) -> void:
	c.face_toward(o.position.x)
	c.perform("nuzzle", 1.4)
	if _free_to_socialise(o):
		o.face_toward(c.position.x)
		o.perform("nuzzle", 1.4)
	var lv := Friends.level(Friends.points(c.pet, o.pet["id"]))
	for i in maxi(1, lv):
		_on_emote("heart", c.top_global().lerp(o.top_global(), 0.5) + Vector2((i - lv / 2.0) * 26.0, -i * 8.0))
	_friend_time(c, o, 3.0)


## Friends who like a run: one dashes off, the other gives chase, then they both bounce about.
func chase(c: Creature, o: Creature) -> void:
	var spot := Vector2(randf_range(GROUND.position.x + 80, GROUND.end.x - 80), randf_range(GROUND.position.y + 20, GROUND.end.y - 10))
	c.go_to(spot, _caught_up.bind(c, o), true)
	c.say("note")
	get_tree().create_timer(0.5).timeout.connect(_give_chase.bind(o, c))


func _give_chase(o: Creature, c: Creature) -> void:
	if is_instance_valid(o) and _free_to_socialise(o):
		o.go_to(_beside(c, o) if c.is_busy() else c.position, Callable(), true)


func _caught_up(c: Creature, o: Creature) -> void:
	c.perform("celebrate", 1.2)
	if is_instance_valid(o) and o.action() == "":
		o.perform("celebrate", 1.2)
	_friend_time(c, o, 5.0)


## Time spent together: friendship grows (Friends.grow), and a new level is celebrated.
func _friend_time(a: Creature, b: Creature, amount: float) -> void:
	var lv := Friends.grow(a.pet, b.pet, amount)
	if lv > 0:
		_became(a, b, lv)


## Friends now - or best friends: hearts all round, a hint, both journals, and stars once.
func _became(a: Creature, b: Creature, lv: int) -> void:
	for i in 5:
		_on_emote("heart", a.top_global().lerp(b.top_global(), 0.5) + Vector2(randf_range(-60, 60), randf_range(-30, 10)))
	a.say("heart")
	Sounds.play("trust_up")
	var what := "best friends" if lv >= 3 else "friends"
	_show_hint("%s and %s are %s now!" % [a.pet["name"], b.pet["name"], what])
	for pair in [[a, b], [b, a]]:
		if not str(pair[0].pet["id"]).begins_with("rival_"):
			Journal.add(pair[0].pet, "%s with %s!" % ["Best friends" if lv >= 3 else "Became friends", pair[1].pet["name"]])
	var ids := [str(a.pet["id"]), str(b.pet["id"])]
	ids.sort()
	if game.profile.first_time("friends_%s_%s_%d" % [ids[0], ids[1], lv]):
		game.reward(5 if lv >= 3 else 3, "%s and %s are %s!" % [a.pet["name"], b.pet["name"], what])


# --- Fun days (Beginner) --------------------------------------------------------------------

func _start_fun_day() -> void:
	match fun_day:
		"party":
			var friends := FunDays.friends(2)
			for i in friends.size():
				var c := _add_guest(friends[i], Vector2(GROUND.end.x - 120.0 - i * 160.0, GROUND.position.y + 60.0 + i * 50.0))
				c.perform("greet", 2.0)
			var confetti := PlacePainter.Drift.new()
			confetti.kind = "sprinkles"
			add_child(confetti)
			_show_hint("Party time! %s and %s came to play!" % [friends[0]["name"], friends[1]["name"]])
			for c in creatures:
				c.perform("celebrate", 1.6)
			FunDays.join(game, "party")
		"photo":
			open_tab("camera")
			_show_hint("It's Photo Day! Pick a pose, then Snap! your pets.")


func _add_guest(pet: Dictionary, at: Vector2) -> Creature:
	Stats.ensure(pet)
	var c := Creature.new()
	c.bounds = GROUND
	c.in_water = _place.get("water", false)
	c.position = at
	world.add_child(c)
	c.setup(pet)
	c.audible = true
	c.emote.connect(_on_emote)
	guests.append(c)
	return c


## A friend family's pet drops in (Visitors): the first time a home is opened each day, and now
## and then after that. Not at night (it would be asleep at home), and not in the middle of a party.
func _maybe_visitor() -> void:
	if fun_day == "party" or Clock.is_night() or Visitors.families(game.profile).is_empty():
		return
	if not game.profile.count_today("visitor_" + home["id"], 1) and randf() > 0.3:
		return
	var pet := Visitors.pick(game.profile)
	if pet.is_empty():
		return
	var c := _add_guest(pet, Vector2(GROUND.end.x, randf_range(GROUND.position.y + 30.0, GROUND.end.y - 20.0)))
	c.go_to(Vector2(GROUND.end.x - 260.0, c.position.y), c.say.bind("hello"))
	var fam: Dictionary = Visitors.families(game.profile).get(pet["_family"], {})
	_show_hint("%s from %s came to visit!" % [pet["name"], Family.called(str(fam.get("name", "a friend's")))])


## A tap on a guest: it looks up and says hello.
func _tap_guest(at: Vector2) -> bool:
	for g in guests:
		if g.hit(at):
			if g.action() == "":
				g.perform("look", 0.9)
				g.leap(g.height_px * 0.12, 0.3)
			g.say("hello")
			return true
	return false


## Party guests now and then dance, or come and say hello to one of yours.
func _guest_tick() -> void:
	for g in guests:
		if g.is_busy() or randf() > 0.35:
			continue
		if randf() < 0.6 and _social(g):
			continue
		g.perform("dance", 2.0)


# --- The camera ------------------------------------------------------------------------------

const POSES := [["icon_heart", "Happy", "happy"], ["trick_jump", "Jump", "jump"], ["trick_wave", "Wave", "wave"],
	["trick_dance", "Dance", "dance"], ["trick_sit", "Sit", "sit"], ["icon_energy", "Sleepy", "sleepy"]]


func _fill_camera() -> void:
	var snap_btn := UI.icon_button("icon_camera", "Snap!", snap, 52, Vector2(110, 96))
	snap_btn.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.INK, 3))
	_drawer.add_child(snap_btn)
	for p in POSES:
		_drawer.add_child(UI.icon_button(p[0], p[1], pose.bind(p[2]), 48, Vector2(92, 96)))
	_drawer.add_child(UI.icon_button("icon_album", "Album", _open_album, 48, Vector2(92, 96)))
	if not _hinted.has("camera"):
		_hinted["camera"] = true
		_show_hint("Pick a pose, then Snap!")


## Everyone strikes a pose for the camera.
func pose(kind: String) -> void:
	for c in creatures:
		if c == _eater or c == _tug:
			continue
		c.interrupt()
		c.rest_z = 0.0
		match kind:
			"happy":
				c.perform("greet", 3.0)
				c.say("heart")
			"jump":
				c.do_trick("jump")
			"sleepy":
				c.perform("sleep", 8.0, Callable(), 2.0)
			_:
				c.perform(kind, 3.5)


## Snap! The place and the pets just as they are - not the buttons - for the photo editor.
func snap() -> void:
	if _editor != null:
		return
	var layer := _hud_root.get_parent() as CanvasLayer
	layer.visible = false
	await _frame_drawn()
	if not is_inside_tree():
		return
	var img := get_viewport().get_texture().get_image()
	layer.visible = true
	Sounds.play("camera")
	# A 16:9 picture from the middle of a wide phone screen.
	var w := img.get_width()
	var h := img.get_height()
	if float(w) / h > 16.0 / 9.0:
		var cw := int(h * 16.0 / 9.0)
		img = img.get_region(Rect2i((w - cw) / 2, 0, cw, h))
	img.resize(int(PhotoEditor.SIZE.x), int(PhotoEditor.SIZE.y), Image.INTERPOLATE_BILINEAR)
	_editor = PhotoEditor.new()
	_editor.game = game
	_editor.photo = img
	_editor.home_id = home["id"]
	_editor.pets = pets
	_editor.on_done = _photo_done
	_hud_root.add_child(UI.full_rect(_editor))


## Waits for the next frame to be drawn - with the buttons hidden, for the photo. A window that is
## hidden (or a phone with its screen off) may never draw one, so after two seconds of frames it
## draws one itself, as GameRoot.capture does, rather than leave the camera stuck.
func _frame_drawn() -> void:
	var drawn := [false]
	var mark := func(): drawn[0] = true
	RenderingServer.frame_post_draw.connect(mark, CONNECT_ONE_SHOT)
	var waited := 0
	while not drawn[0] and waited < 120 and is_inside_tree():
		await get_tree().process_frame
		waited += 1
	if not drawn[0]:
		if RenderingServer.frame_post_draw.is_connected(mark):
			RenderingServer.frame_post_draw.disconnect(mark)
		RenderingServer.force_draw()


func _photo_done(id: String) -> void:
	UI.retire(_editor)
	_editor = null
	if id != "":
		_save_all()
		_show_hint("In the album - and in their journals!")
		if fun_day == "photo":
			FunDays.join(game, "photo")


func _open_album() -> void:
	_save_all()
	game.go_album(game.go_place.bind(home["id"], focus_id))


## Android's back gesture: out of the photo editor first, then home.
func go_back() -> void:
	if _editor != null:
		_photo_done("")
	else:
		game.go_home()


# --- Mud and the bath ------------------------------------------------------------------------

## Every so often: running about a muddy place, or out in the rain, gets feet muddy.
func _mud_tick() -> void:
	if _mud_kind == "" or (_rain_left <= 0.0 and not Places.tags(home["place"]).has("muddy")):
		return
	for c in creatures:
		if c.velocity.length() < 40.0 or c.z > 8.0 or c.flying:
			continue
		if randf() < (0.18 if _rain_left > 0.0 else 0.1):
			get_muddy(c, 1, "feet")


## Splats `n` spots of this place's mud on a pet (Mud) - fun, never a telling-off.
func get_muddy(c: Creature, n: int, where: String) -> void:
	if Mud.splat(c.pet, n, where, _mud_kind) <= 0:
		return
	c.refresh_mud()
	Sounds.play_varied("splat", c._size_pitch(), 0.1)
	_on_emote("dirt", c.global_position + Vector2(0, -12))
	if not _hinted.has("mud"):
		_hinted["mud"] = true
		_show_hint("%s is all muddy! Open the Bath drawer and scrub it clean." % c.pet["name"])


## Left alone, a pet sometimes digs - and comes up with muddy paws and a muddy nose.
func _dig(c: Creature) -> void:
	_sfx_times("scratch", 4, 0.5, 0.8, -2.0)
	c.perform("dig", 2.4, _dug.bind(c))


func _dug(c: Creature) -> void:
	get_muddy(c, 1 + randi() % 2, "front")
	_train(c, "strength", 0.3)


## A passing shower: rain streaks, a patter, and muddy feet for anyone who runs about in it.
func start_rain(seconds: float) -> void:
	_rain_in = -1.0
	_rain_left = seconds
	_painter.start_rain()
	if _rain_loop < 0:
		_rain_loop = Sounds.loop_start("rain")
	_show_hint("It's raining! Splish splash - somebody might get muddy.")


func _stop_rain() -> void:
	_rain_left = 0.0
	_painter.stop_rain()
	if _rain_loop >= 0:
		Sounds.loop_stop(_rain_loop)
		_rain_loop = -1


## The sponge or the brush rubbing over a pet. Soapy things scrub off the mud where they rub, in
## a froth of bubbles, and once it is all off (or after a good long wash) the pet shakes itself
## dry, squeaky clean. Fluffy things brush it: hearts and charm, like petting. It shuts its eyes
## and enjoys it either way.
func _scrub(at: Vector2) -> void:
	var c := _creature_at(at)
	if c == null:
		_wash_last = Vector2.INF
		return
	var soapy: bool = _held_item.get("words", []).has("soapy")
	if c != _washing:
		_washing = c
		_wash_total = 0.0
		_bathed = false
	if _wash_last == Vector2.INF:
		_wash_last = at
		return
	var d := at.distance_to(_wash_last)
	_wash_last = at
	if d < 2.0:
		return
	var asleep := c.action() == "sleep"
	if asleep and soapy:
		_wake(c)  # a wet sponge wakes anybody
	elif not asleep and c != _eater and c != _tug and not (c == _toy_pet and toy_state != "") \
			and c.action() not in ["shake", "stretch"]:
		if c.action() != "petted":
			c.perform("petted", 0.6)
		c.extend_action(0.5)
		c.touch_at = at
	_wash_dist += d
	_wash_total += d
	_wash_sound_in -= d
	if _wash_sound_in <= 0.0:
		_wash_sound_in = 90.0
		Sounds.play_varied("scrub" if soapy else "brush", 1.0, 0.1)
	if _wash_dist < 45.0:
		return
	_wash_dist = 0.0
	if not soapy:
		_on_emote("twinkle", at + Vector2(randf_range(-24, 24), randf_range(-24, 8)))
		if int(_wash_total / 45.0) % 3 == 0:
			_on_emote("heart", c.top_global())
			_love(c, 1)
			_train(c, "charm", 0.3)
		return
	_on_emote("bubble", at + Vector2(randf_range(-22, 22), randf_range(-16, 6)))
	if Mud.scrub_near(c, at, maxf(80.0, c.height_px * 0.3)):
		_taught("sponge")
		c.refresh_mud()
		_on_emote("bubble", at)
		Sounds.play_varied("bubble", 1.3, 0.2, -2.0)
	if not _bathed and c.action() != "shake" and (Mud.count(c.pet) == 0 and _wash_total > 260.0):
		_bath_done(c)


## Squeaky clean: it shakes itself dry, glints, and loves you for it.
func _bath_done(c: Creature) -> void:
	_bathed = true
	Mud.clear(c.pet)
	c.refresh_mud()
	PetStore.change_need(c.pet, "clean", 0.15)  # a quick wash; bath day is the real thing
	c.interrupt()
	Sounds.play("shake")
	c.perform("shake", 1.3, _shaken.bind(c))


func _shaken(c: Creature) -> void:
	Sounds.play("clean")
	for i in 5:
		_on_emote("twinkle", c.global_position + Vector2(randf_range(-0.5, 0.5) * c.height_px,
			-randf_range(0.2, 1.0) * c.height_px))
	c.say("heart")
	_love(c, 1)
	_train(c, "charm", 0.5)
	_panel.refresh()


# --- Bath day and the food bowl ------------------------------------------------------------

## Bath day: the pet whose card is open (or the one this home is looking at) trots off - into the
## house if there is one, the bathroom's in there, else off to the watering hole - and the bath
## routine begins (BathScreen).
func go_bath() -> void:
	var c := _panel_pet if _panel.visible and _panel_pet != null else _focus_creature()
	if c == null:
		return
	if c.action() == "sleep":
		_wake(c)
	var spot := BathDay.spot(home)
	var to := Vector2(GROUND.end.x, c.position.y)
	if spot == "tub":
		for f in furniture:
			if f.item.get("house", false):
				to = f.position + Vector2(0, 6)
	_panel.visible = false
	c.interrupt()
	c.say("note")
	_show_hint("Bath day! Off to %s, %s!" % [BathDay.SPOT_NAMES.get(spot, "the pond"), c.pet["name"]])
	c.go_to(to, _leave_with.bind(c.pet, game.go_bath.bind(home["id"], c.pet["id"])), true)


func _make_bowl() -> void:
	_bowl = Sprite2D.new()
	var tex := Items.art_texture("prop_bowl")
	_bowl.texture = tex
	_bowl.centered = false
	_bowl.offset = -Items.art_pivot("prop_bowl", tex.get_image())
	_bowl.scale = Vector2.ONE * (58.0 / maxf(tex.get_height(), 1.0))
	_bowl.position = Vector2(GROUND.position.x + 110.0, GROUND.end.y - 24.0)
	world.add_child(_bowl)


func _into_bowl(it: PlaceItem) -> void:
	it.position = _bowl.position + Vector2(0, -3)
	it.vel = Vector2.ZERO
	it.vz = 0.0
	it.z = 0.0
	it.set_meta("in_bowl", true)
	Sounds.play_varied("place", 1.2, 0.05, -4.0)


# --- Night ----------------------------------------------------------------------------------

## Bedtime: off to something cozy (or warm), a big yawn, and curled up asleep till morning - or
## till a tap. `now`: already asleep there, as when the home is opened at night.
func _go_to_bed(c: Creature, now := false) -> void:
	# Best friends sleep side by side.
	for o in creatures:
		if o != c and o.is_asleep() and Friends.level(Friends.points(c.pet, o.pet["id"])) >= 3:
			var side := signf(c.position.x - o.position.x + 0.1)
			var by := (o.position + Vector2(side * (o.height_px * 0.45 + c.height_px * 0.35), 3)).clamp(GROUND.position, GROUND.end)
			if now:
				c.position = by
				c.z = o.rest_z
				_lie_down(c, o.rest_z, 2.0)
			else:
				c.go_to(by, _lie_down.bind(c, o.rest_z, 0.0))
			return
	# A real bed if there is one, then a house's doorstep, then by something warm.
	var beds := []
	for f in furniture:
		if f.has_word("cozy") and not f.has_word("hidey"):
			beds.append(f)
	var bed: Furniture = beds.pick_random() if not beds.is_empty() else _furniture_with("cozy")
	if bed == null:
		bed = _furniture_with("warm")
	var spot := c.position
	var perch := 0.0
	if bed != null and bed.has_word("cozy"):
		spot = bed.nap_spot()
		perch = bed.nap_height()
	elif bed != null:
		var side := signf(c.position.x - bed.position.x + 0.1)
		spot = bed.position + Vector2(side * bed.height_px * randf_range(0.5, 0.8), randf_range(4, 24))
	spot = spot.clamp(GROUND.position, GROUND.end)
	if now:
		c.position = spot
		c.z = perch
		_lie_down(c, perch, 2.0)
	else:
		c.go_to(spot, _lie_down.bind(c, perch, 0.0))


func _lie_down(c: Creature, perch: float, asleep_for: float) -> void:
	c.rest_z = perch
	c.perform("sleep", 900.0, _slept.bind(c), asleep_for)


func _slept(c: Creature) -> void:
	c.rest_z = 0.0


## A tap on a sleeping pet: it wakes gently - a long stretch and a yawn - says hello, and stays
## up a while to play.
func _wake(c: Creature) -> void:
	c.interrupt()
	_up_till[c] = _now() + 60.0
	c.perform("stretch", 1.6, _woken.bind(c))


func _woken(c: Creature) -> void:
	c.rest_z = 0.0
	c.perform("look", 0.8)
	c.say("hello")


## Morning: everyone stretches, then says good morning.
func _good_morning() -> void:
	for c in creatures:
		c.interrupt()
		c.rest_z = 0.0
		c.perform("stretch", 1.6 + randf() * 0.6, _morning_hello.bind(c))
	_show_hint("Good morning! Everyone slept well.")


func _morning_hello(c: Creature) -> void:
	c.perform("greet", 1.6)
	c.say("heart")


## Every so often: sleepers get their energy back, pets being played with stay up, and night
## falling or morning coming while the home is open is noticed.
func _night_tick() -> void:
	var night := Clock.is_night()
	for c in creatures:
		if c.is_asleep():
			PetStore.change_need(c.pet, "energy", 0.01)
		elif c == _eater or c == _tug or c == _toy_pet or _chasers.has(c) \
				or c.action() in ["petted", "wiggle", "belly", "cuddle", "greet", "stretch", "celebrate"]:
			_up_till[c] = maxf(float(_up_till.get(c, 0.0)), _now() + 40.0)
	if night == _was_night:
		return
	_was_night = night
	if night:
		_show_hint("Bedtime! The pets are getting sleepy.")
		return
	for c in creatures:
		if c.action() == "sleep":
			c.interrupt()
			c.rest_z = 0.0
			c.perform("stretch", 1.6 + randf() * 0.6, _morning_hello.bind(c))
	_show_hint("Good morning!")


## Shows "they're asleep" if anyone is - true when it did.
func _asleep_hint() -> bool:
	for c in creatures:
		if c.action() == "sleep":
			_show_hint("Shh - they're asleep! Tap a pet to wake it up gently.")
			return true
	return false


# --- Showing how -----------------------------------------------------------------------------
# The first few times a kid comes to each thing here - rubbing a pet, the food, the toys, a toy
# held out, a squeaky toy, decorating, dressing up, the sponge, tug of war - a drawn hand (HowTo)
# does the move where it happens, with a few words. It goes at their first touch; if they rest
# with the move still to do, it comes back after HOW_IDLE seconds; once they have done it
# (`_taught`), it stays away. One at a time: a new one takes over, and the hint line hides while
# it is up. The hand only ever shows a move that works: a tap on a snack does fill the bowl.

## Visits to each thing that get the hand, per kid.
const HOW_TIMES := 3
const HOW_IDLE := 6.0
## Below two reward toasts (GameRoot stacks them from y 96), so they never cover it.
const HOW_CAPTION_Y := 232.0


## Shows the hand for `key` (see `_show_how` for `spec`), the first HOW_TIMES times for this kid -
## `after` seconds from now, if the kid has not touched anything by then. True if it will show.
func _teach(key: String, spec: Dictionary, after := 0.0) -> bool:
	if not HowTo.first_times(game.profile, "howto_home_" + key, HOW_TIMES):
		return false
	_how_key = key
	_how_spec = spec
	if after > 0.0:
		_drop_how()
		_how_idle = HOW_IDLE - after
	else:
		_show_how()
	return true


## The hand, from `_how_spec`: gesture, at, to, follow, period, caption, caption_y, on_press and
## until_touch, as HowTo has them. Points are in the HUD's space; Callables let it ride a thing.
func _show_how() -> void:
	_drop_how()
	var h := HowTo.new()
	h.gesture = _how_spec.get("gesture", "tap")
	h.caption = _how_spec.get("caption", "")
	h.at = _how_spec.get("at", Vector2(640, 420))
	h.to = _how_spec.get("to", Vector2(840, 420))
	h.follow = _how_spec.get("follow", Callable())
	h.period = _how_spec.get("period", 1.3)
	h.on_press = _how_spec.get("on_press", Callable())
	h.until_touch = _how_spec.get("until_touch", true)
	h.caption_y = _how_spec.get("caption_y", HOW_CAPTION_Y)
	_how = h
	_how_idle = 0.0
	_hint_time = 0.0  # its words say it now; an old hint line coming back after would be stale
	_hud_root.add_child(h)


func _drop_how() -> void:
	if _how != null and is_instance_valid(_how):
		_how.dismiss()
	_how = null


## The kid has done it: no more hand for it now.
func _taught(key: String) -> void:
	if _how_key == key:
		_how_key = ""
		_drop_how()


## Any finger down: the rest is over, and a hand that goes at a touch has gone.
func _touched() -> void:
	_how_idle = 0.0
	if _how != null and is_instance_valid(_how) and _how.until_touch:
		_how = null


## Is the move the hand teaches still the thing to do? (Its drawer shut, the toy taken... no.)
func _how_wanted(key: String) -> bool:
	if _editor != null or _ask != null or _held != null:
		return false
	match key:
		"rub":
			var c = _how_spec.get("pet")
			return tab == "" and _tug == null and toy_state == "" and _petting == null \
				and is_instance_valid(c) and (c as Creature).action() != "sleep"
		"food":
			return tab == "food"
		"toys":
			return tab == "toy" and _tug == null and toy_state == ""
		"offer":
			return toy_state == "offer"
		"squeak":
			return toy_state == "" and toy != null and is_instance_valid(toy) and toy.has_word("squeaky") \
				and not toy.held and toy.carrier == null
		"decorate":
			return tab == "furniture" and _selected == null
		"wardrobe":
			return tab == "clothing"
		"sponge":
			return tab == "bath" and _muddiest() != null
	return false


## Every frame: a hand whose move is no longer wanted goes, and one the kid rested on comes back.
## (Tug of war brings its own back, by the beat.)
func _update_how(delta: float) -> void:
	if _how != null and not is_instance_valid(_how):
		_how = null
	if _how_key == "" or _how_key == "tug":
		return
	if not _how_wanted(_how_key):
		_drop_how()
		_how_idle = 0.0
		return
	if _how != null:
		return
	_how_idle += delta
	if _how_idle >= HOW_IDLE:
		_show_how()


## Rub your pet: the hand strokes back and forth across its body.
func _rub_spec(c: Creature) -> Dictionary:
	return {"gesture": "drag", "at": _pet_point.bind(c, -44.0), "to": _pet_point.bind(c, 44.0),
		"period": 0.9, "caption": "Rub your pet!", "pet": c}


## On arrival: the hand rubs the pet you came to see - stood at the front first, before anything
## is drawn, so no bed or tree hides it and the hand is plainly on the pet, not the furniture. It
## comes once the welcome (its hello, the reward toasts) is over, unless the kid is in first.
func _teach_rub(c: Creature) -> void:
	if c != null and c.action() != "sleep" and _teach("rub", _rub_spec(c), 3.2):
		c.position = Vector2(clampf(c.position.x, 360.0, 920.0), GROUND.end.y - 24.0)


## Little ones pat: after three pats with no rub, the hand shows them how to rub - the card the
## pats opened goes, so the pet is in plain view.
func _show_rub(c: Creature) -> void:
	if not HowTo.first_times(game.profile, "howto_home_pats", HOW_TIMES):
		return
	_panel.visible = false
	_how_key = "rub"
	_how_spec = _rub_spec(c)
	_show_how()


## A drawer just opened: the hand does what its things are for - drags a snack to the bowl (a
## tap puts it there too), flicks a ball (or drags a toy onto the grass), drags furniture into
## the room (or a tap), clothes onto the pet (or a tap), the sponge onto the mud.
func _teach_drawer() -> void:
	var id := _first_item()
	if id == "":
		return
	match tab:
		"food":
			_teach("food", {"gesture": "swipe", "at": _button_point.bind(id, Vector2.ZERO), "to": _bowl_point,
				"period": 1.8, "caption": "Drag a snack to the bowl!"})
		"toy":
			var fetch := Words.toy_play(Items.get_item(id).get("words", [])) == "fetch"
			_teach("toys", {"gesture": "swipe", "at": _button_point.bind(id, Vector2.ZERO),
				"to": _button_point.bind(id, Vector2(-60, -280) if fetch else Vector2(0, -210)),
				"period": 0.9 if fetch else 1.8,
				"caption": "Flick it to throw!" if fetch else "Drag it onto the grass!"})
		"furniture":
			if _selected == null:
				_teach("decorate", {"gesture": "swipe", "at": _button_point.bind(id, Vector2.ZERO),
					"to": _hud_of(_free_floor_spot()), "period": 1.8, "caption": "Drag it into the room!"})
		"clothing":
			var c := _panel_pet if _panel.visible and _panel_pet != null else _focus_creature()
			if c != null:
				_teach("wardrobe", {"gesture": "swipe", "at": _button_point.bind(id, Vector2.ZERO),
					"to": _pet_point.bind(c, 0.0), "period": 1.8, "caption": "Drag it onto your pet!"})
		"bath":
			var c := _muddiest()
			var sponge := ""
			for i in _item_buttons:
				if Items.get_item(i).get("words", []).has("soapy"):
					sponge = i
					break
			if c != null and sponge != "":
				_teach("sponge", {"gesture": "swipe", "at": _button_point.bind(sponge, Vector2.ZERO),
					"to": _mud_point.bind(c), "period": 1.8, "caption": "Drag the sponge onto the mud!"})


## The first thing in the open drawer, or "".
func _first_item() -> String:
	for id in _item_buttons:
		return id
	return ""


## The first muddy pet, or null.
func _muddiest() -> Creature:
	for c in creatures:
		if Mud.count(c.pet) > 0:
			return c
	return null


# Where things are, in the HUD's space (where the hand and the tug handle are drawn) - Callables
# that keep up with a thing as it moves.

## A point in the world, on the screen.
func _screen_of(world_at: Vector2) -> Vector2:
	return get_canvas_transform() * world_at


## A point in the world, in the HUD's space.
func _hud_of(world_at: Vector2) -> Vector2:
	return _hud_root.get_global_transform_with_canvas().affine_inverse() * (get_canvas_transform() * world_at)


## A point in the HUD's space, in the world.
func _world_of_hud(p: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * (_hud_root.get_global_transform_with_canvas() * p)


## The middle of a drawer button (and `off` from it).
func _button_point(id: String, off: Vector2) -> Vector2:
	var b = _item_buttons.get(id)
	if not is_instance_valid(b):
		return Vector2(640, 660) + off
	var r := (b as Control).get_global_rect()
	return r.get_center() - _hud_root.get_global_rect().position + off


## A pet's body (and `dx` across it).
func _pet_point(c: Creature, dx: float) -> Vector2:
	if not is_instance_valid(c):
		return Vector2(640, 400)
	return _hud_of(c.global_position.lerp(c.top_global(), 0.42)) + Vector2(dx, 0)


func _bowl_point() -> Vector2:
	return _hud_of(_bowl.position + Vector2(0, -16))


func _toy_point() -> Vector2:
	if toy == null or not is_instance_valid(toy):
		return Vector2(640, 500)
	return _hud_of(toy.sprite.global_position)


## A spot of mud on a pet, else its body.
func _mud_point(c: Creature) -> Vector2:
	if not is_instance_valid(c):
		return Vector2(640, 400)
	var spots: Array = c.pet.get("mud", [])
	if not spots.is_empty():
		var at := Mud.where_is(c, spots[0])
		if at.x != INF:
			return _hud_of(at)
	return _pet_point(c, 0.0)


## The hand taps the squeaky toy: it squeaks and hops, and everyone looks - what a tap does.
func _squeak_shown() -> void:
	if toy == null or not is_instance_valid(toy) or toy.held or toy.carrier != null:
		return
	_squeak_toy()
	toy.hop(90.0)
	_look_at_toy()


## An open bit of floor for a piece of furniture tapped in from the drawer: along the middle of
## the ground, as far as it can be from what is already there.
func _free_floor_spot(skip: Node2D = null) -> Vector2:
	var best := Vector2(640, GROUND.position.y + 90.0)
	var best_d := -1.0
	for i in 9:
		var p := Vector2(lerpf(GROUND.position.x + 110.0, GROUND.end.x - 110.0, i / 8.0),
			GROUND.position.y + 70.0 + (i % 3) * 30.0)
		var d := p.distance_to(_bowl.position)
		for f in furniture:
			if f != skip:
				d = minf(d, f.position.distance_to(p))
		for c in creatures:
			d = minf(d, c.position.distance_to(p) * 1.5)
		if d > best_d:
			best_d = d
			best = p
	return best


# --- Training, trust and rewards -------------------------------------------------------------

func _train(c: Creature, stat: String, amount: float) -> void:
	if stat == "" or amount <= 0.0:
		return
	var levels := Stats.train(c.pet, stat, amount)
	if levels > 0 and game.profile.advanced():
		Sounds.play("level_up")
		var lvl := Stats.level(Stats.value(c.pet, stat))
		c.say("star")
		game.reward(3 * levels, "%s's %s is level %d!" % [c.pet["name"], Stats.label(stat), lvl])
		Journal.add(c.pet, "%s went up to level %d!" % [Stats.label(stat), lvl])
		if stat == "speed":
			c.set_display_height(c.fixed_height)  # walk speed follows the speed stat


func _love(c: Creature, n: int) -> void:
	Care.played(c.pet)
	var before := Stats.trust(c.pet)
	c.pet["love"] = int(c.pet.get("love", 0)) + n
	var after := Stats.trust(c.pet)
	if after > before:
		Sounds.play("trust_up")
		for i in after:
			_on_emote("heart", c.top_global() + Vector2((i - after / 2.0) * 30.0, -10))
		game.reward(5 * after, "%s trusts you more! (%d hearts)" % [c.pet["name"], after])
		Journal.add(c.pet, "Trusts you with %d %s now!" % [after, "heart" if after == 1 else "hearts"])


# --- Every frame -----------------------------------------------------------------------------

func _process(delta: float) -> void:
	if _listening:
		_listen(delta)
	if _rain_in > 0.0:
		_rain_in -= delta
		if _rain_in <= 0.0:
			start_rain(randf_range(45.0, 80.0))
	if _rain_left > 0.0:
		_rain_left -= delta
		if _rain_left <= 0.0:
			_stop_rain()
	_update_toy(delta)
	_update_tug(delta)
	_update_food(delta)
	if toy_state == "return" and toy != null and is_instance_valid(toy) and toy.has_word("squeaky"):
		_squeak_in -= delta
		if _squeak_in <= 0.0:
			_squeak_in = 0.7
			_on_emote("note", toy.global_position + Vector2(0, -30))
			if not Voice.play_thing(toy.item):
				Sounds.play_varied("squeak", 1.0, 0.1, -4.0)
	_ai_in -= delta
	if _ai_in <= 0.0:
		_ai_in = 1.2
		_guest_tick()
		_night_tick()
		_mud_tick()
		var night := Clock.is_night()
		for c in creatures:
			if c.is_busy() or c == _toy_pet or c == _eater or c == _tug or c == _tug_caller or _chasers.has(c):
				continue
			if _how_key == "rub" and _how_spec.get("pet") == c:
				continue  # waiting to be rubbed, out in front, not off behind the furniture
			if night and _now() > float(_up_till.get(c, 0.0)):
				if randf() < 0.3:
					_go_to_bed(c)
				continue
			if _mud_kind != "" and randf() < 0.03:
				_dig(c)
				continue
			if randf() < 0.14 and _social(c):
				continue
			if randf() < 0.22:
				_play_with_furniture(c)
	if _follow != null:
		_cam.position = _follow.position + Vector2(0, -_follow.height_px * 0.5 + CAM_DROP)
	_update_how(delta)
	# One sentence at a time: while the hand is showing how, its words stand in for the hint.
	_hint_time -= delta
	_hint.modulate.a = 0.0 if _how != null else clampf(_hint_time, 0.0, 1.0)
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


## The buttons and drawers keep clear of a phone's camera hole; the place itself runs edge to edge.
func fit_safe_area() -> void:
	if _hud_root != null:
		UI.fit_safe(_hud_root)


func save_now() -> void:
	_save_all()


func _save_all() -> void:
	for pet in pets:
		PetStore.save_pet(pet)
	game.profile.save()


func _exit_tree() -> void:
	_save_all()
	for g in guests:
		Visitors.save_friends(g.pet)  # a visitor remembers its new friends next time (others: no-op)
	Sounds.listen_stop()
	if _rain_loop >= 0:
		Sounds.loop_stop(_rain_loop)


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


## Puts a toy down gently at `at` - on a pet, if one is there.
func put_toy(id: String, at: Vector2) -> void:
	_grab(id)
	_samples.clear()
	_move_held(at)
	_samples.clear()
	_drop_held(at, Vector2(640, 300))


func place_furniture(id: String, at: Vector2) -> void:
	_grab(id)
	_move_held(at)
	_drop_held(at, Vector2(640, 300))
