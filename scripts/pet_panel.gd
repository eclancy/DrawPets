class_name PetPanel
extends PanelContainer
## Everything about one pet at a glance: how much it trusts you, how it is feeling, its six
## stats and their levels, and what it is like. Tap a pet in a place to open it.
##
## Laid out in two columns - feelings on the left, stats on the right, its buttons along the
## bottom - so the whole card fits between the top buttons and the drawer bar on a phone. One
## tall column put its buttons under the bar.

var on_close := Callable()
var on_take_off := Callable()
var on_voice := Callable()
var on_move := Callable()
var on_let_go := Callable()
var on_journal := Callable()
## Advanced shows the six stats; Beginner shows how today's care is going instead.
var advanced := true

var _pet: Dictionary
var _name: Label
var _hearts: Control
var _hearts_holder: HBoxContainer
var _needs := {}
var _stats := {}
var _levels := {}
var _words: Label
var _take_off: Button
var _today: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	add_child(col)

	# Its name and hearts across the top.
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	_name = UI.label("", 28)
	top.add_child(_name)
	_hearts_holder = HBoxContainer.new()
	_hearts_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hearts_holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_hearts_holder)
	top.add_child(UI.button("X", func(): on_close.call(), Vector2(48, 44), 22))
	col.add_child(top)

	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 18)
	col.add_child(cols)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(210, 0)
	left.add_theme_constant_override("separation", 6)
	cols.add_child(left)
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(300, 0)
	right.add_theme_constant_override("separation", 6)
	cols.add_child(right)

	for n in [["food", "icon_food"], ["fun", "icon_fun"], ["clean", "icon_clean"], ["energy", "icon_energy"]]:
		var row := HBoxContainer.new()
		row.add_child(UI.icon(n[1], 30))
		var bar := ProgressBar.new()
		bar.max_value = 1.0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 16)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(bar)
		_needs[n[0]] = bar
		left.add_child(row)

	for stat in Stats.LIST:
		var row := HBoxContainer.new()
		row.add_child(UI.icon(Stats.INFO[stat]["icon"], 30))
		var name := UI.label(Stats.label(stat), 18)
		name.custom_minimum_size = Vector2(84, 0)
		row.add_child(name)
		var lvl := UI.label("1", 18)
		lvl.custom_minimum_size = Vector2(34, 0)
		row.add_child(lvl)
		var bar := ProgressBar.new()
		bar.max_value = Stats.MAX
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 14)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.add_theme_stylebox_override("fill", UI._box(Color("#8fb4ef"), UI.INK, 0, 8, 0))
		row.add_child(bar)
		_stats[stat] = bar
		_levels[stat] = lvl
		row.visible = advanced
		right.add_child(row)
	_today = UI.label("", 22, true)
	_today.visible = not advanced
	right.add_child(_today)
	_words = UI.label("", 18, true)
	_words.custom_minimum_size = Vector2(210, 0)
	_words.add_theme_color_override("font_color", UI.INK_SOFT)
	left.add_child(_words)
	_take_off = UI.button("Take off clothes", func(): on_take_off.call(), Vector2(0, 44), 18)
	left.add_child(_take_off)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	for entry in [["icon_journal", "Journal", "journal"], ["snd_voice", "Voice", "voice"],
			["ui_move_home", "Move", "move"], ["ui_let_go", "Let go", "let_go"]]:
		var b := UI.icon_button(entry[0], entry[1], _action.bind(entry[2]), 36, Vector2(78, 76))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(b)
	col.add_child(actions)


func _action(what: String) -> void:
	var cb: Callable = {"voice": on_voice, "move": on_move, "let_go": on_let_go,
		"journal": on_journal}[what]
	if cb.is_valid():
		cb.call(_pet)


func show_pet(pet: Dictionary) -> void:
	_pet = pet
	refresh()


func refresh() -> void:
	if _pet.is_empty():
		return
	_name.text = _pet["name"]
	var trust := Stats.trust(_pet)
	if _hearts == null or _hearts.get_meta("level", -1) != trust:
		if _hearts != null:
			_hearts.queue_free()
		_hearts = UI.hearts(trust, 28)
		_hearts.set_meta("level", trust)
		_hearts_holder.add_child(_hearts)
	for n in _needs:
		_needs[n].value = float(_pet["needs"].get(n, 1.0))
	for stat in Stats.LIST:
		var v := Stats.value(_pet, stat)
		_stats[stat].value = v
		_levels[stat].text = "Lv%d" % Stats.level(v)
	_today.text = "\n".join(Care.today_lines(_pet))
	var bits := []
	for w in _pet.get("personality", []):
		bits.append(w)
	_words.text = "%s. Loves %s." % [", ".join(bits).capitalize() if not bits.is_empty() else "Itself",
		Places.display_name(_pet.get("place", "meadow"))]
	var friends := Friends.summary(_pet, 2)
	if friends != "":
		_words.text += "\n" + friends
	_take_off.visible = not _pet.get("outfit", []).is_empty()
