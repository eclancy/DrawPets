class_name DrawScreen
extends Control
## Drawing one thing on its own sheet: a favourite food, a toy, a hat, a trick card - a sheet, a
## crayon box, and a prompt saying what to draw. (A creature is drawn on CreatureSheet.) Every
## button is a picture (.ai/art-direction.md): an eraser button IS an eraser.
##
## Set the fields, then add it to the tree. `on_done` gets {image, pivot, shine}, or {} when the
## kid skipped it.

var subject := "item"
var prompt := ""
var step_text := ""
var dot := Vector2(256, 256)
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
	row.add_theme_constant_override("separation", 22)
	add_child(UI.full_rect(UI.margin(row, 18)))

	var holder := AspectRatioContainer.new()
	holder.ratio = 1.0
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_stretch_ratio = 1.35
	row.add_child(holder)
	canvas = DrawCanvas.new()
	holder.add_child(canvas)
	canvas.message.connect(_say)

	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 8)
	row.add_child(side)

	if step_text != "":
		var step := UI.label(step_text, 18)
		step.add_theme_color_override("font_color", UI.INK_SOFT)
		side.add_child(step)
	side.add_child(UI.label(prompt, 22, true))
	_message = UI.label("", 19, true)
	_message.add_theme_color_override("font_color", Color("#d0482a"))
	side.add_child(_message)

	var colours := GridContainer.new()
	colours.columns = 8
	colours.add_theme_constant_override("h_separation", 6)
	colours.add_theme_constant_override("v_separation", 6)
	var colour_group := ButtonGroup.new()
	for c in UI.PALETTE:
		colours.add_child(_swatch(c, colour_group))
	for mode in markers:
		colours.add_child(_marker_swatch(mode, int(markers[mode]), colour_group))
	side.add_child(colours)

	# Brush sizes, then the tools, then undo and clear - all pictures.
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 6)
	var size_group := ButtonGroup.new()
	for entry in [[6.0, 5.0], [12.0, 9.0], [24.0, 15.0]]:
		var b := _picture_toggle("", size_group, func(): canvas.brush = entry[0])
		var d := SizeDot.new()
		d.radius = entry[1]
		b.add_child(UI.full_rect(d))
		b.button_pressed = entry[0] == 12.0
		tools.add_child(b)
	tools.add_child(VSeparator.new())
	var tool_group := ButtonGroup.new()
	for entry in [["tool_crayon", DrawCanvas.Tool.PEN], ["tool_fill", DrawCanvas.Tool.FILL],
			["tool_eraser", DrawCanvas.Tool.ERASER]]:
		var b := _picture_toggle(entry[0], tool_group, func(): canvas.tool = entry[1])
		b.button_pressed = entry[1] == DrawCanvas.Tool.PEN
		_tool_buttons[entry[1]] = b
		tools.add_child(b)
	tools.add_child(VSeparator.new())
	tools.add_child(_picture_button("tool_undo", func(): canvas.undo()))
	tools.add_child(_picture_button("tool_clear", func(): canvas.clear()))
	side.add_child(tools)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)

	var finish := HBoxContainer.new()
	finish.add_theme_constant_override("separation", 8)
	if can_skip:
		finish.add_child(UI.icon_button("tool_skip" if skip_text == "Skip" else "tool_back", skip_text,
			func(): _finish({}), 40, Vector2(110, 84)))
	var done := UI.big_icon_button("tool_done", "Done!", press_done)
	done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	finish.add_child(done)
	side.add_child(finish)

	canvas.set_dot(dot)


func _swatch(c: Color, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = Vector2(48, 48)
	var light := c.get_luminance() > 0.8
	for state in ["normal", "hover"]:
		b.add_theme_stylebox_override(state, UI._box(c, UI.INK_SOFT if light else c.darkened(0.25), 3, 24))
	for state in ["pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(state, UI._box(c, UI.ACCENT, 7, 24))
	b.button_pressed = c == UI.PALETTE[0]
	b.pressed.connect(func():
		canvas.color = c
		canvas.shine = ""
		if canvas.tool == DrawCanvas.Tool.ERASER:
			_select_tool(DrawCanvas.Tool.PEN))
	return b


## A shiny marker: draws in gold, rainbow or glitter. Used up when the drawing is finished.
func _marker_swatch(mode: String, n: int, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = Vector2(48, 48)
	b.tooltip_text = "%s marker (%d left)" % [mode.capitalize(), n]
	var pic := UI.icon(Items.MARKERS[mode][0], 40)
	pic.position = Vector2(4, 4)
	b.add_child(pic)
	b.pressed.connect(func():
		canvas.color = Items.MARKERS[mode][1]
		canvas.shine = mode
		_say("Shiny %s marker! It gets used up when you finish this drawing." % mode)
		if canvas.tool == DrawCanvas.Tool.ERASER:
			_select_tool(DrawCanvas.Tool.PEN))
	return b


func _picture_button(icon: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(56, 56)
	b.tooltip_text = icon.trim_prefix("tool_").trim_prefix("ui_").capitalize()
	b.pressed.connect(on_press)
	var pic := UI.icon(icon, 42)
	pic.position = Vector2(7, 7)
	b.add_child(pic)
	return b


func _picture_toggle(icon: String, group: ButtonGroup, on_press: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(56, 56)
	b.toggle_mode = true
	b.button_group = group
	b.pressed.connect(on_press)
	if icon != "":
		b.tooltip_text = icon.trim_prefix("tool_").capitalize()
		var pic := UI.icon(icon, 42)
		pic.position = Vector2(7, 7)
		b.add_child(pic)
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
		_say("Draw something first!" if not can_skip else "Draw something - or tap %s." % skip_text)
		return
	Sounds.play("done")
	_finish(result)


func _finish(result: Dictionary) -> void:
	if _done:
		return
	_done = true
	on_done.call(result)


## A brush size, drawn as a dot of that size.
class SizeDot extends Control:
	var radius := 8.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_circle(size / 2.0, radius, UI.INK)
