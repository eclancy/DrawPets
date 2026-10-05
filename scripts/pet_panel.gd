class_name PetPanel
extends PanelContainer
## Everything about one pet at a glance: how much it trusts you, how it is feeling, its six
## stats and their levels, and what it is like. Tap a pet in a place to open it.

var on_close := Callable()
var on_take_off := Callable()

var _pet: Dictionary
var _name: Label
var _hearts: Control
var _hearts_holder: HBoxContainer
var _needs := {}
var _stats := {}
var _levels := {}
var _words: Label
var _take_off: Button


func _ready() -> void:
	custom_minimum_size = Vector2(330, 0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	add_child(col)

	var top := HBoxContainer.new()
	_name = UI.label("", 28)
	_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_name)
	top.add_child(UI.button("X", func(): on_close.call(), Vector2(48, 44), 22))
	col.add_child(top)
	_hearts_holder = HBoxContainer.new()
	col.add_child(_hearts_holder)

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
		col.add_child(row)

	var sep := HSeparator.new()
	col.add_child(sep)
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
		col.add_child(row)
	_words = UI.label("", 18, true)
	_words.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(_words)
	_take_off = UI.button("Take off clothes", func(): on_take_off.call(), Vector2(0, 48), 20)
	col.add_child(_take_off)


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
	var bits := []
	for w in _pet.get("personality", []):
		bits.append(w)
	_words.text = "%s. Loves %s." % [", ".join(bits).capitalize() if not bits.is_empty() else "Itself",
		Places.display_name(_pet.get("place", "meadow"))]
	_take_off.visible = not _pet.get("outfit", []).is_empty()
