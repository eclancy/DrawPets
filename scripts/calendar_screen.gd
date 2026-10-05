class_name CalendarScreen
extends Control
## The competition calendar: this month, a competition most days, today's circled, and a
## ribbon on every day a pet placed. Worked out on this device from the date (Events), so it
## needs no internet and is the same for everyone in the family.

var game: GameRoot
var _month_offset := 0
var _content: Control


func _ready() -> void:
	_build()


func _build() -> void:
	if _content != null:
		remove_child(_content)
		_content.queue_free()
	_content = Control.new()
	add_child(UI.full_rect(_content))
	_content.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	_content.add_child(UI.full_rect(UI.margin(col, 18)))

	var now := Time.get_datetime_dict_from_system()
	var year: int = now["year"]
	var month: int = now["month"] + _month_offset
	while month > 12:
		month -= 12
		year += 1
	var first := Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": 1,
		"hour": 12, "minute": 0, "second": 0})

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UI.button("Back", func(): game.go_home(), Vector2(120, 64), 24))
	top.add_child(UI.icon("icon_calendar", 60))
	var heading := UI.title("%s %d" % [Events.MONTHS[month - 1], year], 42)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	if _month_offset > 0:
		top.add_child(UI.button("<", _change_month.bind(-1), Vector2(64, 64), 28))
	if _month_offset < 2:
		top.add_child(UI.button(">", _change_month.bind(1), Vector2(64, 64), 28))
	top.add_child(UI.star_counter(game.profile, 44))
	col.add_child(top)

	var grid := GridContainer.new()
	grid.columns = 7
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	for name in ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]:
		var l := UI.label(name, 20)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(l)
	var first_day := Events.for_unix(first)
	for i in int(first_day["weekday"]):
		grid.add_child(Control.new())
	var today := Events.today()
	var day := first
	while true:
		var ev := Events.for_unix(day)
		if int(ev["month"]) != month:
			break
		grid.add_child(_day_cell(ev, today))
		day += 86400
	col.add_child(grid)

	var info := Events.info(today["kind"])
	var go := UI.big_button("Today: %s - let's go!" % info["name"], func(): game.go_event(today))
	col.add_child(go)


func _day_cell(ev: Dictionary, today: Dictionary) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(150, 78)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var is_today: bool = ev["key"] == today["key"]
	var past: bool = ev["key"] < today["key"]
	if is_today:
		b.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.ACCENT, 5))
	elif past:
		b.modulate = Color(1, 1, 1, 0.6)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full_rect(row)
	row.offset_left = 8
	row.add_child(UI.label(str(ev["day"]), 22))
	row.add_child(UI.icon(Events.icon(ev["kind"]), 34, "none"))
	var name := UI.label(Events.info(ev["kind"])["name"], 14, true)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name)
	var best := _best_place(ev)
	if best > 0:
		row.add_child(UI.icon("icon_ribbon_%d" % best, 34, "none"))
	b.add_child(row)
	b.pressed.connect(func():
		if is_today:
			game.go_event(ev)
		elif past:
			game.toast("That one's over! %s" % ("You won a ribbon." if best > 0 else "There's always next week."), "icon_calendar")
		else:
			game.toast("%s is on the %s. Train up till then!" % [Events.info(ev["kind"])["name"], _nth(int(ev["day"]))], "icon_calendar"))
	return b


func _change_month(by: int) -> void:
	_month_offset = clampi(_month_offset + by, 0, 2)
	_build()


func _best_place(ev: Dictionary) -> int:
	var best := 0
	var results: Dictionary = game.profile.data["results"]
	for tier in Events.TIERS.size():
		var key := Events.result_key(ev, tier)
		if results.has(key):
			var place := int(results[key])
			if place <= 3 and (best == 0 or place < best):
				best = place
	return best


static func _nth(n: int) -> String:
	var suffix := "th"
	if n % 100 < 11 or n % 100 > 13:
		suffix = {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
	return "%d%s" % [n, suffix]
