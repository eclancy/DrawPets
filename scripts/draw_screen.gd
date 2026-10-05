class_name DrawScreen
extends Control
## The drawing step: one sheet, a crayon box, and a prompt saying what to draw. Used for the
## body, every part, the favourite food and the favourite toy.
##
## Set the fields, then add it to the tree. `on_done` gets {image, pivot}, or {} when the kid
## skipped an optional part.

var subject := "body"
var prompt := ""
var step_text := ""
var ghost := {}
var dot := Vector2(256, 256)
var show_dot := false
var can_skip := false
var skip_text := "Skip"
## Shiny markers the family owns: mode -> how many. Each one draws one shiny drawing.
var markers := {}
var on_done := Callable()

var canvas: DrawCanvas
var _message: Label
var _tool_buttons := {}
var _done := false


func _ready() -> void:
	add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	add_child(UI.full_rect(UI.margin(row, 20)))

	var holder := AspectRatioContainer.new()
	holder.ratio = 1.0
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_stretch_ratio = 1.4
	row.add_child(holder)
	canvas = DrawCanvas.new()
	holder.add_child(canvas)
	canvas.message.connect(_say)

	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 12)
	row.add_child(side)

	if step_text != "":
		var step := UI.label(step_text, 20)
		step.add_theme_color_override("font_color", UI.INK_SOFT)
		side.add_child(step)
	side.add_child(UI.label(prompt, 26, true))
	_message = UI.label("", 22, true)
	_message.add_theme_color_override("font_color", Color("#d0482a"))
	side.add_child(_message)

	var colours := GridContainer.new()
	colours.columns = 7
	colours.add_theme_constant_override("h_separation", 8)
	colours.add_theme_constant_override("v_separation", 8)
	var colour_group := ButtonGroup.new()
	for c in UI.PALETTE:
		colours.add_child(_swatch(c, colour_group))
	for mode in markers:
		colours.add_child(_marker_swatch(mode, int(markers[mode]), colour_group))
	side.add_child(colours)

	var sizes := HBoxContainer.new()
	var size_group := ButtonGroup.new()
	for entry in [["Thin", 6.0], ["Medium", 12.0], ["Thick", 24.0]]:
		var b := _toggle(entry[0], size_group, func(): canvas.brush = entry[1])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.button_pressed = entry[1] == 12.0
		sizes.add_child(b)
	side.add_child(sizes)

	var tools := HBoxContainer.new()
	var tool_group := ButtonGroup.new()
	var tool_list := [["Crayon", DrawCanvas.Tool.PEN], ["Fill", DrawCanvas.Tool.FILL],
		["Eraser", DrawCanvas.Tool.ERASER]]
	if show_dot:
		tool_list.append(["Move dot", DrawCanvas.Tool.DOT])
	for entry in tool_list:
		var b := _toggle(entry[0], tool_group, func(): canvas.tool = entry[1])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.button_pressed = entry[1] == DrawCanvas.Tool.PEN
		_tool_buttons[entry[1]] = b
		tools.add_child(b)
	side.add_child(tools)

	var edits := HBoxContainer.new()
	for entry in [["Undo", func(): canvas.undo()], ["Clear", func(): canvas.clear()]]:
		var b := UI.button(entry[0], entry[1], Vector2(0, 64), 24)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		edits.add_child(b)
	side.add_child(edits)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)

	var finish := HBoxContainer.new()
	if can_skip:
		var skip := UI.button(skip_text, func(): _finish({}), Vector2(140, 84))
		finish.add_child(skip)
	var done := UI.big_button("Done!", press_done)
	done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	finish.add_child(done)
	side.add_child(finish)

	canvas.set_dot(dot, show_dot)
	if not ghost.is_empty():
		canvas.set_ghost(ghost["image"], ghost["rect"])


func _swatch(c: Color, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = Vector2(52, 52)
	var light := c.get_luminance() > 0.8
	for state in ["normal", "hover"]:
		b.add_theme_stylebox_override(state, UI._box(c, UI.INK_SOFT if light else c.darkened(0.25), 3, 26))
	for state in ["pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(state, UI._box(c, UI.ACCENT, 7, 26))
	b.button_pressed = c == UI.PALETTE[0]
	b.pressed.connect(func():
		canvas.color = c
		canvas.shine = ""
		if canvas.tool == DrawCanvas.Tool.ERASER or canvas.tool == DrawCanvas.Tool.DOT:
			_select_tool(DrawCanvas.Tool.PEN))
	return b


## A shiny marker: draws in gold, rainbow or glitter. Used up when the drawing is finished.
func _marker_swatch(mode: String, count: int, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = Vector2(52, 52)
	b.tooltip_text = "%s marker (%d left)" % [mode.capitalize(), count]
	var pic := UI.icon(Items.MARKERS[mode][0], 44)
	pic.position = Vector2(4, 4)
	b.add_child(pic)
	b.pressed.connect(func():
		canvas.color = Items.MARKERS[mode][1]
		canvas.shine = mode
		_say("Shiny %s marker! It gets used up when you finish this drawing." % mode)
		if canvas.tool == DrawCanvas.Tool.ERASER or canvas.tool == DrawCanvas.Tool.DOT:
			_select_tool(DrawCanvas.Tool.PEN))
	return b


func _toggle(text: String, group: ButtonGroup, on_press: Callable) -> Button:
	var b := UI.button(text, on_press, Vector2(0, 60), 22)
	b.toggle_mode = true
	b.button_group = group
	return b


func _select_tool(t: DrawCanvas.Tool) -> void:
	canvas.tool = t
	_tool_buttons[t].button_pressed = true


func _say(text: String) -> void:
	_message.text = text


func press_done() -> void:
	if _done:
		return
	var result := await canvas.finish()
	if result.is_empty():
		_say("Draw something first!" if not can_skip else "Draw something - or tap Skip.")
		return
	_finish(result)


func _finish(result: Dictionary) -> void:
	if _done:
		return
	_done = true
	on_done.call(result)
