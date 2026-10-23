class_name FunDayScreen
extends Control
## Joining in a Beginner fun day (FunDays): what today is - one plain line, and the same thing in
## pictures ending in the rosette everyone gets - then tap your pet, and off to the stage, the
## walk, the bath or the home it happens in. No cups, no scores.
##
## Many players barely read yet, so for a kid's first three fun days a drawn hand (HowTo) taps a
## pet card, and comes back whenever they rest a while without picking one.

## Seconds of nothing before the hand comes back to show which way to go.
const IDLE_HINT := 6.0
## How many fun days a kid is shown the way in.
const HINT_TIMES := 3

var game: GameRoot
var event: Dictionary

var _first_card: Control
var _how: Label
var _tap_label: Label
## Whether this visit shows the hand at all (a kid's first few).
var _teach := false
var _hint: HowTo
var _hint_up := false
var _idle := 0.0


func _ready() -> void:
	var info := FunDays.info(event["kind"])
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	add_child(UI.full_rect(UI.margin(col, 24)))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.icon_button("tool_back", "Back", func(): game.go_calendar(), 40, Vector2(100, 84)))
	top.add_child(UI.icon(info["icon"], 64, "none"))
	var heading := UI.title(info["name"], 44)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	col.add_child(top)
	_how = UI.label(info["how"], 28, true)
	_how.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_how)
	col.add_child(_steps(info))
	# The size of the hand's caption, which stands in its place.
	_tap_label = UI.title("Tap your pet to join!", 46)
	_tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_tap_label)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(scroll)
	var row := HFlowContainer.new()
	row.alignment = FlowContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("h_separation", 12)
	row.add_theme_constant_override("v_separation", 12)
	scroll.add_child(row)
	for h in game.profile.homes():
		for id in h["pets"]:
			var pet := PetStore.load_pet(id)
			if pet.is_empty():
				continue
			var card := _pet_button(pet)
			row.add_child(card)
			if _first_card == null:
				_first_card = card
	if _first_card == null:
		# Nobody to bring yet: the two ways to get a pet, right here rather than only in words.
		_tap_label.text = "Draw a pet first - or adopt one!"
		row.add_child(_big("icon_draw", "Draw a pet", game.start_creator))
		row.add_child(_big("icon_shop", "Adopt one", game.go_shop.bind(game.go_fun_day.bind(event))))
	elif HowTo.first_times(game.profile, "howto_funday_pick", HINT_TIMES):
		_teach = true
		# In a moment, once the cards have found their places.
		_idle = IDLE_HINT - 0.4


## What happens today, in pictures: what you do, then what happens, then the rosette.
func _steps(info: Dictionary) -> Control:
	var strip := HBoxContainer.new()
	strip.alignment = BoxContainer.ALIGNMENT_CENTER
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_theme_constant_override("separation", 4)
	var pics: Array = info.get("steps", [])
	pics = pics + ["icon_rosette"]
	for i in pics.size():
		if i > 0:
			strip.add_child(Arrow.new())
		if pics[i] == "glint":
			strip.add_child(_glint())
		elif pics[i] == "guests":
			strip.add_child(_guests())
		else:
			strip.add_child(UI.icon(pics[i], 80, "none"))
	return strip


## The two friendly pets coming to the party - the very ones who will turn up (FunDays.friends).
func _guests() -> Control:
	var box := Control.new()
	box.custom_minimum_size = Vector2(184, 84)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var friends := FunDays.friends(2)
	for i in friends.size():
		var c := Creature.new()
		c.wander = false
		c.confine = false
		c.depth_scale = false
		box.add_child(c)
		c.setup(friends[i])
		c.fit_in(Vector2(88, 80))
		c.position = Vector2(46.0 + i * 92.0, 80.0)
		c.facing = 1.0 if i == 0 else -1.0
	return box


## The very sparkle the walk hides in the grass (WalkScreen.Glint), twinkling: look for this.
func _glint() -> Control:
	var box := Control.new()
	box.custom_minimum_size = Vector2(80, 80)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var g := WalkScreen.Glint.new()
	g.position = Vector2(40, 62)
	box.add_child(g)
	return box


func _big(icon_id: String, text: String, on_press: Callable) -> Button:
	var b := UI.big_icon_button(icon_id, text, on_press)
	# Wide enough for its picture and words.
	b.custom_minimum_size = Vector2((b.get_child(0) as Control).get_combined_minimum_size().x + 48.0, 96)
	return b


func _pet_button(pet: Dictionary) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(200, 220)
	b.pressed.connect(go.bind(pet["id"]))
	var c := Creature.new()
	c.wander = false
	c.confine = false
	c.depth_scale = false
	b.add_child(c)
	c.setup(pet)
	c.fit_in(Vector2(160, 150))
	c.position = Vector2(100, 172)
	var l := UI.label(pet["name"], 22)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, 182)
	l.size = Vector2(200, 34)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(l)
	return b


# --- The hand ----------------------------------------------------------------------------------

func _process(delta: float) -> void:
	if not _teach:
		return
	if _hint_up:
		if is_instance_valid(_hint):
			return
		_hint_up = false
		_hint = null
		_how.modulate.a = 1.0
		_tap_label.modulate.a = 1.0
	_idle += delta
	if _idle >= IDLE_HINT:
		_show_hint()


## The hand taps the first pet card, with the instruction as its caption in the instruction's
## own place. The words above hide meanwhile (keeping their room), so there is one sentence on
## screen - the one about what to do now.
func _show_hint() -> void:
	_idle = 0.0
	_hint = HowTo.new()
	_hint.gesture = "tap"
	_hint.at = _card_spot
	_hint.caption = _tap_label.text
	_hint.caption_y = _tap_label.global_position.y - global_position.y - 4.0
	_hint.until_touch = true
	_hint.period = 1.5
	_hint.on_press = _squish_card
	add_child(_hint)
	_hint_up = true
	_how.modulate.a = 0.0
	_tap_label.modulate.a = 0.0


## Where the hand pokes: the pet in the first card.
func _card_spot() -> Vector2:
	var r := _first_card.get_global_rect()
	return r.get_center() - global_position + Vector2(10, 0)


## The card gives under the hand's poke, the way it will under a finger.
func _squish_card() -> void:
	_first_card.pivot_offset = _first_card.size / 2.0
	var t := _first_card.create_tween()
	t.tween_property(_first_card, "scale", Vector2(0.94, 0.94), 0.08)
	t.tween_property(_first_card, "scale", Vector2.ONE, 0.18)


## Off it goes, to wherever today's fun happens.
func go(pet_id: String) -> void:
	var home := FunDays.home_of(game.profile, pet_id)
	if home.is_empty():
		return
	match event["kind"]:
		"party", "photo":
			game.go_place(home["id"], pet_id, false, event["kind"])
		"treasure":
			game.go_walk(home["id"], pet_id, true)
		"spa":
			game.go_bath(home["id"], pet_id, true)
		_:
			game.go_stage(event["kind"], home["id"], pet_id)


func go_back() -> void:
	game.go_calendar()


## A crayon arrow between the pictures: this, then this.
class Arrow extends Control:
	func _init() -> void:
		custom_minimum_size = Vector2(56, 80)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var y := size.y / 2.0
		Crayon.marker_line(self, PackedVector2Array([Vector2(8, y), Vector2(46, y)]), UI.ACCENT, 6.0, 3, false)
		Crayon.marker_line(self, PackedVector2Array([Vector2(32, y - 13), Vector2(47, y), Vector2(32, y + 13)]),
			UI.ACCENT, 6.0, 5, false)
