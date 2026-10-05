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
##   --screen=place|create|shop|calendar   boot straight into a screen
##   --shot=N        screenshot frame N to .shots/shot.png. F12 grabs a frame any time.

var screen: Node
var profile: Profile
var dev := {}
var _frame := 0
var _shot_at := -1
var _toasts: VBoxContainer


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
	profile = Profile.load_or_new()
	if dev.has("stars"):
		profile.add_stars(int(dev["stars"]))
	_build_toasts()

	match dev.get("screen", ""):
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
			else:
				go_home()


# --- Screens ---------------------------------------------------------------------------------

func go_home() -> void:
	var s := HomeScreen.new()
	s.game = self
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
func go_place(home_id: String, focus := "", first_visit := false) -> void:
	var h := profile.home(home_id)
	if h.is_empty():
		go_home()
		return
	var s := PlaceScreen.new()
	s.game = self
	s.home = h
	s.focus_id = focus
	s.first_visit = first_visit
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
func make_item(category: String, on_done: Callable, prompt := "") -> void:
	var s := ItemMaker.new()
	s.game = self
	s.category = category
	s.prompt = prompt
	s.on_done = on_done
	show_screen(s)


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
		UI.full_rect(node)
	add_child(node)
	move_child(node, 0)


func _notification(what: int) -> void:
	# Android's back gesture goes home instead of closing the game.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not (screen is HomeScreen):
		go_home()


# --- Rewards and toasts ----------------------------------------------------------------------

## Pays out gold stars and says why.
func reward(stars: int, why: String) -> void:
	if stars <= 0:
		return
	profile.add_stars(stars)
	toast("+%d  %s" % [stars, why], "icon_star")


## Pays out once per day per key (with a daily cap for repeatable things).
func reward_daily(key: String, cap: int, stars: int, why: String) -> void:
	if profile.count_today(key, cap):
		reward(stars, why)


func toast(text: String, icon := "") -> void:
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
	_toasts.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_toasts.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toasts.offset_top = 96
	_toasts.alignment = BoxContainer.ALIGNMENT_BEGIN
	layer.add_child(_toasts)


# --- Screenshots -----------------------------------------------------------------------------

func _process(_delta: float) -> void:
	_frame += 1
	if _frame == _shot_at:
		capture("shot")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		capture("f12_%d" % _frame)


func capture(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var dir := ProjectSettings.globalize_path("res://.shots")
	DirAccess.make_dir_recursive_absolute(dir)
	img.save_png(dir + "/" + shot_name + ".png")
	print("Screenshot: .shots/%s.png" % shot_name)
