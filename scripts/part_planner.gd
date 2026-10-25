class_name PartPlanner
extends Control
## Which parts a new pet will have, and how many (.ai/creature-pipeline.md). Two ways:
##   "start" - a screen of its own before the drawing: "What will your pet have?" - heads, eyes,
##             ears, arms, legs and tails, each a picture with - and +, set to a cat or a dog to
##             start (PartTypes.PLAN_ASK). The body and a mouth come with every pet.
##   "more"  - over the drawing once everything planned is drawn (or from the sheet's Add more):
##             "Anything else?" - every part not in the plan yet. Tap one to add it (a pair of
##             wings, a hand for each arm), - and + to change how many. Spikes, hair and claws
##             are drawn as a bunch: yes or no.
## The kid then draws them one at a time on the sheet (CreatureSheet), so how many never has to
## be worked out while drawing.
##
## Fields, set before it enters the tree: `mode`, `plan` (more: the plan so far), `on_done`
## (gets type -> how many, only the ones wanted), `on_back` (start: home; more: back to the
## drawing), `on_finished` (more: "No - it's finished!").

var mode := "start"
var plan: Array = []
var on_done := Callable()
var on_back := Callable()
var on_finished := Callable()

## type -> how many, for every card.
var counts := {}
var _labels := {}
var _cards := {}
var _ticks := {}
var _pics := {}
var _hint: Label
var _go: Button


func _ready() -> void:
	if mode == "start":
		_build_start()
	else:
		_build_more()


func _build_start() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	add_child(UI.fit_safe(UI.margin(col, 24)))

	var top := HBoxContainer.new()
	top.add_child(UI.icon_button("tool_back", "Back", _back, 40, Vector2(100, 84)))
	var heading := UI.title("What will your pet have?", 44)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(heading)
	var balance := Control.new()
	balance.custom_minimum_size = Vector2(100, 0)
	top.add_child(balance)
	col.add_child(top)
	_hint = UI.label("Tap - and + to choose. Wings, horns, tentacles and more come at the end!", 22, true)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(_hint)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	for type in PartTypes.PLAN_ORDER:
		counts[type] = int(PartTypes.PLAN_ASK[type][2])
		var card := _card(type, 176.0, 104.0)
		card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(card)
	col.add_child(row)
	var go_row := HBoxContainer.new()
	go_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_go = UI.big_icon_button("tool_crayon", "Let's draw it!", press_go)
	_go.custom_minimum_size.x = 460
	go_row.add_child(_go)
	col.add_child(go_row)
	for type in counts:
		_show_count(type)


func _build_more() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.23, 0.21, 0.4, 0.35)
	add_child(UI.full_rect(dim))
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(UI.margin(col, 18))
	var heading := UI.title("Anything else?", 40)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(heading)
	_hint = UI.label("Tap the parts you want to add.", 22, true)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(_hint)

	var types := offered(plan)
	var grid := GridContainer.new()
	grid.columns = maxi(1, ceili(types.size() / 2.0))
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	var w := 136.0 if grid.columns > 7 else 150.0
	for type in types:
		counts[type] = 0
		grid.add_child(_card(type, w, 70.0))
	var centre := CenterContainer.new()
	centre.add_child(grid)
	col.add_child(centre)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 14)
	buttons.add_child(UI.icon_button("tool_back", "Back to drawing", _back, 36, Vector2(170, 76)))
	_go = UI.big_icon_button("tool_crayon", "Draw them!", press_go)
	buttons.add_child(_go)
	var finished := UI.button("No - it's finished!", press_finished, Vector2(300, 84), 26)
	finished.add_theme_stylebox_override("normal", UI._box(UI.GOOD, UI.INK, 3))
	buttons.add_child(finished)
	col.add_child(buttons)
	for type in counts:
		_show_count(type)


## The parts "Anything else?" offers: every one not in the plan yet (not the body or a mouth).
static func offered(p: Array) -> Array:
	var out := []
	for type in PartTypes.GUIDE_ORDER:
		if type != "body" and type != "mouth" and PartTypes.planned(p, type) == 0:
			out.append(type)
	return out


## A part's card: its picture (tap it, on "Anything else?", to add it or leave it out), its name,
## and - n + (no count for the parts drawn as a bunch).
func _card(type: String, w: float, px: float) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(w, 0)
	_cards[type] = card
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)
	var pic := Button.new()
	pic.flat = true
	pic.custom_minimum_size = Vector2(px + 8.0, px + 8.0)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pic.pressed.connect(toggle.bind(type))
	var art := UI.icon(PartTypes.icon(type), px, "none")
	art.position = Vector2(4, 4)
	pic.add_child(art)
	_pics[type] = art
	var tick := UI.icon("tool_done", px * 0.4, "none")
	tick.position = Vector2(px * 0.68, -2)
	tick.visible = false
	pic.add_child(tick)
	_ticks[type] = tick
	col.add_child(pic)
	var called := UI.label(PartTypes.info(type)["plural"], 26 if mode == "start" else 21)
	called.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(called)
	var stepper := HBoxContainer.new()
	stepper.alignment = BoxContainer.ALIGNMENT_CENTER
	stepper.add_theme_constant_override("separation", 4)
	var big := mode == "start"
	var bunch := PartTypes.BUNCH.has(type)
	stepper.add_child(_step_button("ui_minus", type, -1, 54.0 if big else 46.0, bunch))
	var count := UI.label("", 44 if big else 30)
	count.custom_minimum_size = Vector2(46 if big else 36, 0)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count.modulate.a = 0.0 if bunch else 1.0
	_labels[type] = count
	stepper.add_child(count)
	stepper.add_child(_step_button("ui_plus", type, 1, 54.0 if big else 46.0, bunch))
	col.add_child(stepper)
	return card


func _step_button(icon: String, type: String, by: int, px: float, hidden: bool) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(px, px)
	b.pressed.connect(change.bind(type, by))
	var pic := UI.icon(icon, px * 0.7)
	pic.position = Vector2(px * 0.15, px * 0.15)
	b.add_child(pic)
	if hidden:
		b.modulate.a = 0.0
		b.disabled = true
	return b


## - or +: one fewer or one more, within what that part allows.
func change(type: String, by: int) -> void:
	var lo := 0
	var hi := PartTypes.most(type)
	if mode == "start":
		lo = int(PartTypes.PLAN_ASK[type][0])
		hi = int(PartTypes.PLAN_ASK[type][1])
	var n := clampi(int(counts.get(type, 0)) + by, lo, hi)
	if n == int(counts.get(type, 0)):
		Sounds.play("ui_nope")
		return
	counts[type] = n
	Sounds.play("ui_tap")
	_show_count(type)


## Tapping a part's picture on "Anything else?": in, at its usual number, or back out.
func toggle(type: String) -> void:
	if mode == "start":
		return
	if int(counts.get(type, 0)) > 0:
		counts[type] = 0
	else:
		counts[type] = start_count(type, plan)
	Sounds.play("ui_toggle")
	_show_count(type)


## How many a part starts at when it is added: a hand for each arm, a foot for each leg, a pair
## of wings.
static func start_count(type: String, p: Array) -> int:
	var n := int(PartTypes.MORE_START.get(type, 1))
	if type == "hand" and PartTypes.planned(p, "arm") > 0:
		n = PartTypes.planned(p, "arm")
	if type == "foot" and PartTypes.planned(p, "leg") > 0:
		n = PartTypes.planned(p, "leg")
	return mini(n, PartTypes.most(type))


func _show_count(type: String) -> void:
	var n := int(counts.get(type, 0))
	(_labels[type] as Label).text = str(n)
	var card: PanelContainer = _cards[type]
	if mode == "more" and n > 0:
		card.add_theme_stylebox_override("panel", UI._box(UI.HILITE, UI.ACCENT, 4, 16, 8))
	else:
		card.remove_theme_stylebox_override("panel")
	(_ticks[type] as Control).visible = mode == "more" and n > 0
	# None of them: the picture fades.
	(_pics[type] as Control).modulate.a = 1.0 if n > 0 or mode == "more" else 0.4
	if mode == "more":
		_go.modulate.a = 1.0 if _wanted().size() > 0 else 0.5


func _wanted() -> Dictionary:
	var out := {}
	for type in counts:
		if int(counts[type]) > 0:
			out[type] = int(counts[type])
	return out


## "Let's draw it!" / "Draw them!"
func press_go() -> void:
	if mode == "more" and _wanted().is_empty():
		Sounds.play("ui_nope")
		_hint.text = "Tap a part to add it - or tap It's finished!"
		_hint.add_theme_color_override("font_color", Color("#d0482a"))
		return
	Sounds.play("ui_tap")
	on_done.call(counts.duplicate() if mode == "start" else _wanted())


func press_finished() -> void:
	on_finished.call()


func _back() -> void:
	on_back.call()
