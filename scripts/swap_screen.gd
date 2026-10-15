class_name SwapScreen
extends Control
## Swapping pets with a friend (.ai/sharing.md) - two kids together, phone to phone, no internet:
##   1. both tap the big button, phones close
##   2. "Found the Mango family!" and three pictures - the same on both phones - "Yes, that's them"
##   3. all of each family's pets hop across, and can visit the other family from then on
## The game picks the way: Nearby Connections where there are Google Play services, else the
## same Wi-Fi or a hotspot (SwapLink). If something is off, a picture checklist says what to try.
## A grown-up removes a friend family by holding its button.

## Check digits shown as pictures - things every kid can name.
const PICTURES := [["kit_apple", "apple"], ["kit_fish", "fish"], ["kit_ball", "ball"], ["kit_duck", "duck"],
	["kit_cake", "cake"], ["kit_carrot", "carrot"], ["kit_teddy", "teddy"], ["kit_frisbee", "frisbee"],
	["kit_icecream", "ice cream"], ["kit_bone", "bone"]]
## How long to look before suggesting what to check.
const PATIENCE := 25.0
const HOLD := 1.5

var game: GameRoot

var _link: SwapLink
var _content: Control
var _state := "main"
var _looking := 0.0
var _tips_shown := false
var _sent := false
var _got: Dictionary = {}
var _friend := ""
var _hold_fid := ""
var _held := 0.0
var _hold_bar: ProgressBar
var _searcher: Searcher
var _progress: ProgressBar
var _wifi_way := false


func _ready() -> void:
	Family.get_or_make(game.profile)
	_main()


func _swap(c: Control) -> void:
	if _content != null:
		UI.retire(_content)
	_content = c
	add_child(UI.full_rect(c))


func _page(title: String, back := true) -> VBoxContainer:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	root.add_child(UI.full_rect(UI.margin(col, 22)))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	if back:
		top.add_child(UI.icon_button("tool_back", "Back", go_back, 40, Vector2(100, 84)))
	var t := UI.title(title, 40)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(t)
	col.add_child(top)
	_swap(root)
	return col


# --- The main page: the big button, and your friends --------------------------------------------

func _main() -> void:
	_stop_link()
	_state = "main"
	var col := _page("Swap pets with a friend")
	var me: Dictionary = Family.get_or_make(game.profile)
	col.add_child(UI.label("Stand close together. You both tap the big button at the same time - then your pets can visit each other! You are %s." % Family.called(me["name"]), 24, true))
	var go := UI.big_icon_button("icon_friends", "Swap pets with a friend", start)
	go.custom_minimum_size = Vector2(520, 110)
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(go)
	var fams := Visitors.families(game.profile)
	if fams.is_empty():
		col.add_child(UI.label("No friends yet - swap with someone to make your first!", 22))
		return
	col.add_child(UI.label("Friends whose pets come to visit:", 24))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	for fid in fams:
		list.add_child(_family_row(fid, fams[fid]))


func _family_row(fid: String, info: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var pets: Array = info.get("pets", [])
	for pid in pets.slice(0, 4):
		var pet := Visitors.load_pet(fid, pid)
		if pet.is_empty():
			continue
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(90, 90)
		var c := Creature.new()
		c.wander = false
		c.confine = false
		c.depth_scale = false
		holder.add_child(c)
		c.setup(pet)
		c.fit_in(Vector2(80, 76))
		c.position = Vector2(45, 86)
		row.add_child(holder)
	var l := UI.label("%s - %d %s" % [Friends.sentence(Family.called(str(info.get("name", "?")))),
		pets.size(), "pet" if pets.size() == 1 else "pets"], 22)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	var col := VBoxContainer.new()
	var b := UI.button("Grown-ups: hold to remove", func(): pass, Vector2(260, 52), 18)
	b.button_down.connect(_hold_start.bind(fid))
	b.button_up.connect(_hold_end)
	col.add_child(b)
	var bar := ProgressBar.new()
	bar.max_value = HOLD
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 10)
	bar.set_meta("fid", fid)
	col.add_child(bar)
	row.add_child(col)
	return row


func _hold_start(fid: String) -> void:
	_hold_fid = fid
	_held = 0.0
	for bar in find_children("*", "ProgressBar", true, false):
		if bar.get_meta("fid", "") == fid:
			_hold_bar = bar


func _hold_end() -> void:
	_hold_fid = ""
	_held = 0.0
	if _hold_bar != null:
		_hold_bar.value = 0.0


# --- Swapping ---------------------------------------------------------------------------------

## The big button: permission first on a phone that needs it, then look for the friend.
func start() -> void:
	var n := NearbyLink.plugin()
	if not _wifi_way and NearbyLink.usable() and not n.missing_permissions().is_empty():
		_ask_permission()
		return
	_search()


func _ask_permission() -> void:
	_state = "permission"
	var col := _page("One quick thing")
	col.add_child(UI.label("Your phone will ask if DrawPets can find your friend's phone nearby. Tap ALLOW!\n\n(It only looks for phones right next to you - nothing goes on the internet.)", 26, true))
	var ok := UI.big_icon_button("tool_done", "OK, ask me", _request_permission)
	ok.custom_minimum_size = Vector2(380, 100)
	ok.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(ok)


func _request_permission() -> void:
	var n := NearbyLink.plugin()
	if not n.is_connected("permissions_result", _on_permissions):
		n.connect("permissions_result", _on_permissions)
	n.request_permissions()


func _on_permissions(granted: bool) -> void:
	if granted:
		_search()
	else:
		_trouble("permission")


func _search() -> void:
	_stop_link()
	_state = "searching"
	_looking = 0.0
	_tips_shown = false
	_sent = false
	_got = {}
	var col := _page("Looking for your friend...")
	_searcher = Searcher.new()
	_searcher.custom_minimum_size = Vector2(0, 300)
	_searcher.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_searcher)
	var how := "Keep both phones close, with this screen open on both." if not _wifi_way \
		else "Both phones need the same Wi-Fi - or one joins the other's hotspot."
	col.add_child(UI.label(how, 24, true))
	_link = LanLink.new() if _wifi_way else SwapLink.best()
	_link.check.connect(_on_check)
	_link.linked.connect(_on_linked)
	_link.received.connect(_on_received)
	_link.progress.connect(_on_progress)
	_link.failed.connect(_on_failed)
	add_child(_link)
	_link.begin(Family.get_or_make(game.profile)["name"])


func _on_check(friend_name: String, digits: String) -> void:
	_state = "check"
	_friend = friend_name
	var col := _page("Found %s!" % Family.called(friend_name))
	col.add_child(UI.label("Do you both see these same three pictures?", 28))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 30)
	for p in pictures(digits):
		var box := VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		var pic := UI.item_picture(Items.get_item(p[0]), 130)
		pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(pic)
		var l := UI.label(p[1], 24)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(l)
		row.add_child(box)
	col.add_child(row)
	var answers := HBoxContainer.new()
	answers.alignment = BoxContainer.ALIGNMENT_CENTER
	answers.add_theme_constant_override("separation", 20)
	answers.add_child(UI.icon_button("tool_back", "No - try again", _not_them, 40, Vector2(220, 100)))
	var yes := UI.big_icon_button("tool_done", "Yes, that's them!", _yes)
	yes.custom_minimum_size = Vector2(380, 100)
	answers.add_child(yes)
	col.add_child(answers)
	Sounds.play("good")


## The check digits as pictures: three of them.
static func pictures(digits: String) -> Array:
	var out := []
	for i in 3:
		var d := 0
		if i < digits.length():
			d = int(digits[i]) if digits[i].is_valid_int() else digits.unicode_at(i) % 10
		out.append(PICTURES[d % PICTURES.size()])
	return out


func _yes() -> void:
	_link.confirm(true)
	if _state == "check":
		_state = "waiting"
		var col := _page("Nearly there!", false)
		col.add_child(UI.label("Waiting for your friend to tap Yes too...", 28, true))


func _not_them() -> void:
	_link.confirm(false)
	_search()


func _on_linked() -> void:
	_state = "sending"
	var col := _page("Your pets are hopping over!", false)
	col.add_child(UI.label("Keep the phones close for a moment...", 26))
	_progress = ProgressBar.new()
	_progress.max_value = 1.0
	_progress.show_percentage = false
	_progress.custom_minimum_size = Vector2(500, 26)
	_progress.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(_progress)
	Sounds.play("throw")
	_link.send(PetPack.pack(game.profile))
	_sent = true
	_maybe_done()


func _on_progress(done: int, total: int) -> void:
	if _progress != null and is_instance_valid(_progress) and total > 0:
		_progress.value = clampf(float(done) / total, 0.0, 1.0)


func _on_received(data: PackedByteArray) -> void:
	var pack := PetPack.unpack(data)
	if pack.is_empty():
		_trouble("bad")
		return
	if pack["family"]["id"] == Family.id(game.profile):
		_trouble("self")
		return
	_got = pack
	Visitors.save_family(game.profile, pack)
	_maybe_done()


func _maybe_done() -> void:
	if not _sent or _got.is_empty():
		return
	_state = "done"
	var fam: Dictionary = _got["family"]
	var pets: Array = _got["pets"]
	# A moment for the last bytes to reach the friend before the link closes.
	get_tree().create_timer(2.0).timeout.connect(_stop_link)
	var col := _page("New friends!", true)
	col.add_child(UI.label("%s's %d %s can come and visit you now - and yours can visit them!" % [
		Friends.sentence(Family.called(fam["name"])), pets.size(), "pet" if pets.size() == 1 else "pets"], 28, true))
	var stage := Control.new()
	stage.custom_minimum_size = Vector2(0, 280)
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(stage)
	for i in mini(pets.size(), 5):
		var c := Creature.new()
		c.wander = false
		c.confine = false
		c.depth_scale = false
		stage.add_child(c)
		c.setup(Visitors.load_pet(fam["id"], pets[i]["id"]))
		c.fit_in(Vector2(200, 200))
		c.position = Vector2(180 + i * 220, 250)
		c.perform("celebrate", 3.0)
	var home := UI.big_icon_button("icon_home", "Back home", go_back)
	home.custom_minimum_size = Vector2(320, 90)
	home.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(home)
	Sounds.play("fanfare")
	if game.profile.first_time("friend_family_" + str(fam["id"])):
		game.reward(3, "New friends: %s!" % Family.called(fam["name"]))


func _on_failed(why: String) -> void:
	if _state in ["done", "main"]:
		return
	if why == "no":
		_search()
	else:
		_trouble(why)


## What to try, as a picture checklist - never an error message.
func _trouble(why: String) -> void:
	_stop_link()
	_state = "trouble"
	var col := _page("Hmm, that didn't work")
	var tips := []
	match why:
		"permission":
			tips = [["snd_mic_off", "DrawPets needs to be allowed to find nearby phones. Ask a grown-up to tap Settings, then Apps, then DrawPets, then Permissions - and allow Nearby devices."]]
		"location":
			tips = [["icon_home", "This phone needs Location turned on to find your friend. Swipe down from the top of the screen and tap Location."]]
		"bad":
			tips = [["icon_heart", "Those pets got muddled on the way. Try again!"]]
		"self":
			tips = [["icon_heart", "That's this phone! Find your friend's phone and try again."]]
		_:
			if _wifi_way:
				tips = [["icon_home", "Are both phones on the same Wi-Fi? (Or turn on one phone's hotspot and join it with the other.)"],
					["icon_friends", "Is the swap screen open on both phones?"]]
			else:
				tips = [["icon_friends", "Is the swap screen open on both phones, right next to each other?"],
					["snd_speaker", "Is Bluetooth turned on? (Swipe down from the top of the screen.)"],
					["icon_home", "Is the phone in aeroplane mode? Turn that off."]]
	for t in tips:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		row.add_child(UI.icon(t[0], 56, "none"))
		var l := UI.label(t[1], 24, true)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		col.add_child(row)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	var again := UI.big_icon_button("tool_undo", "Try again", start)
	again.custom_minimum_size = Vector2(300, 96)
	row.add_child(again)
	if NearbyLink.usable():
		row.add_child(UI.button("Try the Wi-Fi way" if not _wifi_way else "Try the Bluetooth way", _switch_way,
			Vector2(300, 96), 24))
	col.add_child(row)


func _switch_way() -> void:
	_wifi_way = not _wifi_way
	start()


func _process(delta: float) -> void:
	if _state == "searching":
		_looking += delta
		if _looking > PATIENCE and not _tips_shown:
			_tips_shown = true
			_trouble("lost")
	if _hold_fid != "":
		_held += delta
		if _hold_bar != null and is_instance_valid(_hold_bar):
			_hold_bar.value = _held
		if _held >= HOLD:
			var fid := _hold_fid
			_hold_end()
			Visitors.forget(game.profile, fid)
			Sounds.play("goodbye")
			_main()


func _stop_link() -> void:
	if _link != null and is_instance_valid(_link):
		_link.finish()
		UI.retire(_link)
	_link = null


func go_back() -> void:
	_stop_link()
	game.go_home()


func _exit_tree() -> void:
	_stop_link()


## Looking for a friend: rings rippling out from a phone, and paw prints hopping round.
class Searcher extends Control:
	var _t := 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0
		for i in 3:
			var k := fmod(_t * 0.6 + i / 3.0, 1.0)
			draw_arc(c, 40.0 + k * 220.0, 0.0, TAU, 64, Color(UI.ACCENT, 0.6 * (1.0 - k)), 6.0, true)
		draw_rect(Rect2(c - Vector2(34, 56), Vector2(68, 112)), Color("#9cc9ef"))
		draw_rect(Rect2(c - Vector2(34, 56), Vector2(68, 112)), UI.INK, false, 4.0)
		for i in 5:
			var a := _t * 1.2 + i * TAU / 5.0
			var at := c + Vector2(cos(a), sin(a) * 0.6) * 170.0
			draw_circle(at, 9.0, Color("#b48ad8"))
			for k in 3:
				draw_circle(at + Vector2(-9 + k * 9, -12), 4.0, Color("#b48ad8"))
