class_name GameRoot
extends Node
## Owns the screen flow and the family's save. Screens are swapped as children of this node
## rather than by changing Godot scenes, so there is no global for a screen to forget to write
## (the same shape as DrawFight's GameRoot):
##   home -> creator -> place -> home,  home -> shop / calendar -> event -> competition.
##
## Gold stars are paid out through reward(), which also shows the toast that says why - a kid
## should always know what they did to earn one.
##
## Dev flags, after `--` on the command line:
##   --demo          a scripted kid draws a whole creature, then plays with it, decorates,
##                   shops and competes, screenshotting every step into .shots/demo_*.png
##   --quit          with --demo, quit when it is done
##   --stars=N       start with N gold stars (for trying the shop)
##   --screen=place|create|shop|calendar|swap   boot straight into a screen
##   --shot=N        screenshot frame N to .shots/shot.png. F12 grabs a frame any time.
##   --hour=H        pretend it is H o'clock (0-24, e.g. 21.5) - to see dusk, night and morning
##   --no-update     an exported Windows build skips its update check (UpdateScreen)

var screen: Node
var profile: Profile
var dev := {}
var _frame := 0
var _shot_at := -1
var _toasts: VBoxContainer
## Whether a screen wants the toasts aside (toasts_aside), and whether they are there now.
var _toasts_aside := false
var _toasts_right := false


func _ready() -> void:
	# Merged into the engine's default theme rather than set on the window: screens hang off
	# this plain Node (and the place's HUD off a CanvasLayer), and a theme does not inherit
	# through either.
	var theme := UI.make_theme()
	ThemeDB.get_default_theme().merge_with(theme)
	ThemeDB.get_default_theme().default_font_size = theme.default_font_size
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var kv := arg.substr(2).split("=", true, 1)
			dev[kv[0]] = kv[1] if kv.size() > 1 else "true"
	_shot_at = int(dev.get("shot", "-1"))
	if dev.has("hour"):
		Clock.forced_hour = float(dev["hour"])
	profile = Profile.load_or_new()
	var sounds := Sounds.new()
	sounds.name = "Sounds"
	add_child(sounds)
	sounds.apply_settings(profile.settings())
	if dev.has("stars"):
		profile.add_stars(int(dev["stars"]))
	_build_toasts()

	# A downloaded Windows copy updates itself before anything else (.ai/releasing.md); an
	# Android one only finds out, in the background, for the home screen to mention.
	if UpdateScreen.should_check() and not dev.has("demo"):
		var u := UpdateScreen.new()
		u.on_done = open_first_screen
		show_screen(u)
		return
	UpdateScreen.check_quietly(self)
	open_first_screen()


func open_first_screen() -> void:
	match dev.get("screen", ""):
		"swap":
			go_swap()
		"place":
			if not profile.homes().is_empty():
				go_place(profile.homes()[0]["id"])
			else:
				go_home()
		"create":
			start_creator()
		"shop":
			go_shop()
		"calendar":
			go_calendar()
		_:
			if dev.has("demo"):
				var kid := DemoKid.new()
				kid.game = self
				add_child(kid)
				kid.run()
			elif profile.mode() == "":
				go_mode()
			else:
				go_home()


# --- Screens ---------------------------------------------------------------------------------

func go_home() -> void:
	var s := HomeScreen.new()
	s.game = self
	show_screen(s)


## Beginner or Advanced? Asked on first start.
func go_mode() -> void:
	var s := ModeScreen.new()
	s.game = self
	s.on_done = go_home
	show_screen(s)


## Starts a new pet - if there is somewhere for it to live.
func start_creator() -> Creator:
	if not profile.can_add_pet():
		toast("Every home is full! Earn stars and trust in the shop to make room.", "icon_home")
		go_home()
		return null
	var c := Creator.new()
	c.game = self
	show_screen(c)
	return c


## Visits a home. `focus` is the pet the visit is about (selected, greeted first).
func go_place(home_id: String, focus := "", first_visit := false, fun_day := "") -> void:
	var h := profile.home(home_id)
	if h.is_empty():
		go_home()
		return
	var s := PlaceScreen.new()
	s.game = self
	s.home = h
	s.focus_id = focus
	s.first_visit = first_visit
	s.fun_day = fun_day
	show_screen(s)


func go_voice(pet_id: String, home_id: String) -> void:
	var pet := PetStore.load_pet(pet_id)
	if pet.is_empty():
		go_home()
		return
	var s := VoiceMakerScreen.new()
	s.game = self
	s.target = pet
	s.on_done = func():
		PetStore.save_pet(pet, true)
		go_place(home_id, pet_id)
	show_screen(s)


## Moving a pet to another home (or a new one on a free plot).
func go_move(pet_id: String, home_id: String) -> void:
	var pet := PetStore.load_pet(pet_id)
	if pet.is_empty():
		go_home()
		return
	var s := HomePickerScreen.new()
	s.game = self
	s.pet = pet
	s.exclude_home = home_id
	s.on_cancel = func(): go_place(home_id, pet_id)
	s.on_done = func(h: Dictionary):
		profile.move_in(pet, h)
		PetStore.save_pet(pet)
		toast("%s moved to %s!" % [pet["name"], Profile.home_name(h)], "ui_move_home")
		go_place(h["id"], pet_id)
	show_screen(s)


func go_let_go(pet_id: String, home_id: String) -> void:
	var pet := PetStore.load_pet(pet_id)
	var h := profile.home(home_id)
	if pet.is_empty():
		go_home()
		return
	var s := LetGoScreen.new()
	s.game = self
	s.pet = pet
	s.home = h
	s.on_cancel = func(): go_place(home_id, pet_id)
	show_screen(s)


## Building a home on an empty plot, then back home to see it.
func go_build_home() -> void:
	if game_free_plots() <= 0:
		go_shop()
		return
	var s := BuildHomeScreen.new()
	s.game = self
	s.on_done = func(_h: Dictionary): go_home()
	show_screen(s)


func game_free_plots() -> int:
	return profile.free_plots()


## Adopting a pet from the shop: it chooses a home (building one if needed), the stars are paid
## once it has moved in, and then you meet it at home.
func adopt(id: String) -> void:
	var price := Adoptables.price(id)
	if profile.stars() < price:
		toast("You need %d more stars." % (price - profile.stars()), "icon_star")
		return
	if not profile.can_add_pet():
		toast("Every home is full! Get more room in the shop first.", "icon_home")
		return
	var pet := Adoptables.adopt(id)
	var s := HomePickerScreen.new()
	s.game = self
	s.pet = pet
	s.on_cancel = func(): go_shop()
	s.on_done = func(h: Dictionary):
		if not profile.spend(price):
			go_shop()
			return
		profile.move_in(pet, h)
		profile.adopted().append(id)
		profile.save()
		PetStore.save_pet(pet, true)
		toast("%s is part of the family!" % pet["name"], "ui_adopt")
		Sounds.play("adopt")
		go_place(h["id"], pet["id"], true)
	show_screen(s)


func go_shop(back := Callable()) -> void:
	var s := ShopScreen.new()
	s.game = self
	s.on_back = back if back.is_valid() else go_home
	show_screen(s)


func go_calendar() -> void:
	var s := CalendarScreen.new()
	s.game = self
	show_screen(s)


func go_event(event: Dictionary) -> void:
	var s := EventScreen.new()
	s.game = self
	s.event = event
	show_screen(s)


func go_competition(event: Dictionary, tier: int, pet_id: String) -> void:
	var s := CompetitionScreen.new()
	s.game = self
	s.event = event
	s.tier = tier
	s.pet = PetStore.load_pet(pet_id)
	show_screen(s)


## Draws a new item (a toy, a snack, furniture, clothes) and calls on_done with it - or with
## {} if the kid backed out.
func make_item(category: String, on_done: Callable, prompt := "", words := []) -> void:
	var s := ItemMaker.new()
	s.game = self
	s.category = category
	s.prompt = prompt
	s.words = words
	s.on_done = on_done
	show_screen(s)


## After drawing something from a home's drawer: back to that home. Screens that come back to a
## home are given a method of the game, bound - never a lambda of the home screen, which has
## been freed by the time they finish.
func back_to_place(_item: Dictionary, home_id: String, focus := "") -> void:
	go_place(home_id, focus)


## Out for a walk with one pet (WalkScreen) - a Treasure Hunt on that fun day.
func go_walk(home_id: String, pet_id: String, treasure := false) -> void:
	var h := profile.home(home_id)
	if h.is_empty():
		go_home()
		return
	var s := WalkScreen.new()
	s.game = self
	s.home = h
	s.pet_id = pet_id
	s.treasure = treasure
	show_screen(s)


## The photo album. `back` is where Back goes - a home, or (by default) the home screen.
func go_album(back := Callable()) -> void:
	var s := AlbumScreen.new()
	s.game = self
	s.on_back = back
	show_screen(s)


## A pet's journal (JournalScreen), then back to its home.
func go_journal(pet_id: String, home_id: String) -> void:
	var s := JournalScreen.new()
	s.game = self
	s.pet_id = pet_id
	s.home_id = home_id
	show_screen(s)


## Bath day for one pet (BathScreen) - a Spa Day on that fun day.
func go_bath(home_id: String, pet_id: String, spa := false) -> void:
	var h := profile.home(home_id)
	if h.is_empty():
		go_home()
		return
	var s := BathScreen.new()
	s.game = self
	s.home = h
	s.pet_id = pet_id
	s.spa = spa
	show_screen(s)


## Swapping pets with a friend, phone to phone (SwapScreen).
func go_swap() -> void:
	var s := SwapScreen.new()
	s.game = self
	show_screen(s)


## A Beginner fun day (FunDays): pick who's coming.
func go_fun_day(event: Dictionary) -> void:
	var s := FunDayScreen.new()
	s.game = self
	s.event = event
	show_screen(s)


## A fun day on the stage: the Talent Show, the Dance Party or the Costume Parade (StageScreen).
func go_stage(kind: String, home_id: String, pet_id: String) -> void:
	var s := StageScreen.new()
	s.game = self
	s.kind = kind
	s.home = profile.home(home_id)
	s.pet_id = pet_id
	show_screen(s)


## Teaching one pet tricks (TrickScreen).
func go_tricks(home_id: String, pet_id: String) -> void:
	var h := profile.home(home_id)
	if h.is_empty():
		go_home()
		return
	var s := TrickScreen.new()
	s.game = self
	s.home = h
	s.pet_id = pet_id
	show_screen(s)


## A present from a walk has been drawn: a star (three a day), and home with the new thing.
## A present from a walk is drawn: home - or, on a Treasure Hunt with sparkles still in the
## grass, back out to find the next.
func present_drawn(item: Dictionary, home_id: String, pet_id: String, treasure := false) -> void:
	if not item.is_empty():
		reward_daily("present", 3, 1, "A present from your walk!")
	if treasure and int(profile.today().get("treasure_opened", 0)) < WalkScreen.TREASURE_GLINTS:
		go_walk(home_id, pet_id, true)
	else:
		go_place(home_id, pet_id)


## Swaps screens at the end of the frame - never mid-way through the button press that asked
## for it, while the old screen is still handling that input.
func show_screen(node: Node) -> void:
	_swap.call_deferred(node)


func _swap(node: Node) -> void:
	if screen != null and is_instance_valid(screen):
		remove_child(screen)
		screen.queue_free()
	# A place's camera leaves its transform on the viewport; menus expect none.
	get_viewport().canvas_transform = Transform2D.IDENTITY
	screen = node
	if node is Control:
		UI.fit_safe(node)
	add_child(node)
	move_child(node, 0)
	_music_for(node)


# --- A phone's camera hole ---------------------------------------------------------------------

var _safe_check := 0.0


## Where the screen is safe to put buttons, as insets in game units - from the phone (zero on a
## computer, where the "safe area" is just the desktop without its taskbar).
func _read_safe_insets() -> Vector4:
	if not OS.has_feature("mobile"):
		return Vector4.ZERO
	var screen_px := Vector2(DisplayServer.screen_get_size())
	var safe := DisplayServer.get_display_safe_area()
	if screen_px.x <= 0.0 or safe.size.x <= 0:
		return Vector4.ZERO
	var k := get_viewport().get_visible_rect().size.x / screen_px.x
	return Vector4(safe.position.x, safe.position.y, screen_px.x - safe.end.x, screen_px.y - safe.end.y) * k


## Turning the phone round moves the camera hole to the other edge - keep everything clear of it.
func _check_safe_area(delta: float) -> void:
	_safe_check -= delta
	if _safe_check > 0.0:
		return
	_safe_check = 0.5
	var insets := _read_safe_insets()
	if insets.is_equal_approx(UI.safe_insets):
		return
	UI.safe_insets = insets
	if screen is Control:
		UI.fit_safe(screen)
	elif screen != null and screen.has_method("fit_safe_area"):
		screen.fit_safe_area()
	_place_toasts()


## Each kind of screen has its music: calm for drawing, bouncy for competitions, the home tune
## everywhere else - and a home's place has its ambience under it.
func _music_for(node: Node) -> void:
	var track := "home"
	var place := ""
	if node is Creator or node is ItemMaker or node is VoiceMakerScreen:
		track = "create"
	elif node is CompetitionScreen:
		track = "contest"
	elif node is PlaceScreen:
		place = (node as PlaceScreen).home.get("place", "")
	elif node is WalkScreen:
		place = (node as WalkScreen).home.get("place", "")
	elif node is BathScreen:
		place = (node as BathScreen).home.get("place", "")
	elif node is LetGoScreen:
		place = (node as LetGoScreen).home.get("place", "")
	Sounds.music(track)
	Sounds.ambience(place)


## The settings screen, then back where the kid was.
## Feedback for a grown-up (FeedbackScreen), from Settings.
func go_feedback(back: Callable) -> void:
	var s := FeedbackScreen.new()
	s.game = self
	s.on_back = back
	show_screen(s)


func go_settings(back := Callable()) -> void:
	var s := SettingsScreen.new()
	s.game = self
	s.on_back = back if back.is_valid() else go_home
	show_screen(s)


func _notification(what: int) -> void:
	# Android's back gesture goes home instead of closing the game.
	# A screen with its own way back (making a pet: a step back, or "save it for later?") gets
	# it, so a half-drawn pet is never lost to a stray swipe.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not (screen is HomeScreen):
		if screen != null and is_instance_valid(screen) and screen.has_method("go_back"):
			screen.go_back()
		else:
			go_home()
	# A phone can stop the game at any time once it is in the background - save now, not later.
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if screen != null and is_instance_valid(screen) and screen.has_method("save_now"):
			screen.save_now()
		if profile != null:
			profile.save()


# --- Rewards and toasts ----------------------------------------------------------------------

## Pays out gold stars and says why.
func reward(stars: int, why: String) -> void:
	if stars <= 0:
		return
	profile.add_stars(stars)
	Sounds.play("star")
	toast("+%d  %s" % [stars, why], "icon_star")


## Pays out once per day per key (with a daily cap for repeatable things).
func reward_daily(key: String, cap: int, stars: int, why: String) -> void:
	if profile.count_today(key, cap):
		reward(stars, why)


func toast(text: String, icon := "") -> void:
	if icon != "icon_star":
		Sounds.play("toast")
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	if icon != "":
		row.add_child(UI.icon(icon, 40))
	var l := UI.label(text, 24)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
	panel.add_child(row)
	_toasts.add_child(panel)
	var tween := panel.create_tween()
	tween.tween_interval(2.6)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(panel.queue_free)


func _build_toasts() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	_toasts = VBoxContainer.new()
	_toasts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toasts.alignment = BoxContainer.ALIGNMENT_BEGIN
	layer.add_child(_toasts)
	_toasts.child_exiting_tree.connect(_on_toast_gone)
	_place_toasts()


## Toasts stack down from the top, in the middle. A screen with something to see there - the
## podium, its winner standing at the top - puts them `aside`, down the right-hand side, while it
## is up, and back when it goes.
func toasts_aside(aside: bool) -> void:
	_toasts_aside = aside
	_place_toasts()


## A toast faded: if that was the last one still aside, the stack can go back to the middle.
func _on_toast_gone(_toast: Node) -> void:
	if _toasts_right and not _toasts_aside:
		_place_toasts.call_deferred()


## Puts the stack where it belongs now, clear of the phone's camera hole. Toasts still showing
## aside when their screen goes stay where they are until they fade, rather than jumping into
## the middle over the next screen; once the last has gone, the stack is back in the middle.
func _place_toasts() -> void:
	if _toasts == null or not is_instance_valid(_toasts):
		return
	var showing := 0
	for t in _toasts.get_children():
		if not t.is_queued_for_deletion():
			showing += 1
	var aside := _toasts_aside or (_toasts_right and showing > 0)
	_toasts_right = aside
	if aside:
		_toasts.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_toasts.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		_toasts.offset_left = 0.0
		_toasts.offset_right = -24.0 - UI.safe_insets.z
		_toasts.offset_top = 124.0
	else:
		_toasts.set_anchors_preset(Control.PRESET_CENTER_TOP)
		_toasts.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_toasts.offset_left = UI.safe_insets.x
		_toasts.offset_right = -UI.safe_insets.z
		_toasts.offset_top = 96.0
	_toasts.offset_bottom = _toasts.offset_top


# --- Screenshots -----------------------------------------------------------------------------

func _process(delta: float) -> void:
	_check_safe_area(delta)
	_frame += 1
	if _frame == _shot_at:
		capture("shot")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		capture("f12_%d" % _frame)


## A minimised window draws no frames, so this never waits on one for long: after a moment it
## draws one itself (or the demo would sit silent forever).
func capture(shot_name: String) -> void:
	var drawn := [false]
	var mark := func(): drawn[0] = true
	RenderingServer.frame_post_draw.connect(mark, CONNECT_ONE_SHOT)
	var waited := 0
	while not drawn[0] and waited < 120:
		await get_tree().process_frame
		waited += 1
	if not drawn[0]:
		RenderingServer.frame_post_draw.disconnect(mark)
		print("capture: no frame drawn (window hidden?) - drawing one for %s" % shot_name)
		RenderingServer.force_draw()
	var img := get_viewport().get_texture().get_image()
	# res:// is read-only in an exported game (a phone): there, shots go to user://shots, and come
	# off the device with adb (.ai/android.md).
	var dir := ProjectSettings.globalize_path("res://.shots" if OS.has_feature("editor") else "user://shots")
	DirAccess.make_dir_recursive_absolute(dir)
	img.save_png(dir + "/" + shot_name + ".png")
	print("Screenshot: .shots/%s.png" % shot_name)
