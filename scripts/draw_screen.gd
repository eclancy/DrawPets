class_name DrawScreen
extends Control
## The drawing step: one sheet, a crayon box, and a prompt saying what to draw. Used for the
## body, heads, arms, legs and everything added to them, and for food, toys, furniture and
## clothes. Every button is a picture (.ai/art-direction.md): an eraser button IS an eraser.
##
## Drawing a host (the body, a head, an arm, a leg) it also shows the ADD-ONS - the things
## that go on it: tap "Horns" and the horn sheet opens with this head faint on it; finish the
## horn and you come back here, the horns now showing on the head. Some add-ons are required
## (every creature needs eyes and a mouth) and Done says so until they are there.
##
## Tapping an add-on first asks WHERE: the kid taps their drawing once for each one (two eyes,
## one mouth, an ear each side), and its sheet opens zoomed in on the first tap (`on_placed`
## gets the type and the taps). Making a pet, Back goes back a step and Stop offers to save the
## drawing for later or throw it away (`on_back`, `on_quit`).
##
## Set the fields, then add it to the tree. `on_done` gets {image, pivot, shine, count}, or {}
## when the kid skipped an optional part.

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

## A "How many?" stepper when > 0 (add-on sheets): the starting count, and its limit.
var count := 0
var count_max := 1
## Add-ons for a host: the types the kid can add, what they have added (type -> {count,
## image}), which ones they must add, and what to call when one is tapped or removed.
var host_label := ""
var addons: Array = []
var added := {}
var required: Array = []
var on_addon := Callable()
var on_remove_addon := Callable()
var on_placed := Callable()
## Just "where does it go?" for this type, on `start_image` - no crayons, no Done: adding a part
## to a pet that is already made. Cancel calls `on_done` with {}.
var place_only := ""
var on_back := Callable()
var on_quit := Callable()
## Fixing a part: the drawing to start from, its dot, and {mode, mask} if it had shiny strokes.
var start_image: Image
var start_pivot := Vector2.ZERO
var start_shine := {}

var canvas: DrawCanvas
var _message: Label
var _tool_buttons := {}
var _addon_box: HFlowContainer
var _addon_buttons := {}
var _count_label: Label
var _done := false
var _place_box: VBoxContainer
var _place_label: Label
var _place_go: Button
var _place_type := ""
var _spots: Array = []
## The crayon box - hidden while the kid taps where an add-on goes, so the page fits a phone.
var _crayon_box: Array[Control] = []


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

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	if on_back.is_valid():
		top.add_child(UI.icon_button("tool_back", "Back", func(): on_back.call(), 28, Vector2(78, 64)))
	var step := UI.label(step_text, 18)
	step.add_theme_color_override("font_color", UI.INK_SOFT)
	step.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	step.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top.add_child(step)
	if on_quit.is_valid():
		top.add_child(UI.icon_button("icon_home", "Stop", func(): on_quit.call(), 28, Vector2(78, 64)))
	if step_text != "" or top.get_child_count() > 1:
		side.add_child(top)
	else:
		top.free()
	side.add_child(UI.label(prompt, 22, true))
	_message = UI.label("", 19, true)
	_message.add_theme_color_override("font_color", Color("#d0482a"))
	side.add_child(_message)

	# Where does it go? Shown while the kid taps spots for an add-on.
	_place_box = VBoxContainer.new()
	_place_box.add_theme_constant_override("separation", 6)
	_place_box.visible = false
	_place_label = UI.label("", 22, true)
	_place_box.add_child(_place_label)
	var place_row := HBoxContainer.new()
	place_row.add_theme_constant_override("separation", 8)
	_place_go = UI.icon_button("tool_done", "Draw it!", press_place_done, 34, Vector2(150, 70))
	place_row.add_child(_place_go)
	place_row.add_child(UI.icon_button("tool_back", "Cancel", _cancel_placing, 34, Vector2(110, 70)))
	_place_box.add_child(place_row)
	side.add_child(_place_box)
	canvas.tapped.connect(place_at)

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
	_crayon_box.append(colours)

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
	var tool_list := [["tool_crayon", DrawCanvas.Tool.PEN], ["tool_fill", DrawCanvas.Tool.FILL],
		["tool_eraser", DrawCanvas.Tool.ERASER]]
	if show_dot:
		tool_list.append(["tool_dot", DrawCanvas.Tool.DOT])
	for entry in tool_list:
		var b := _picture_toggle(entry[0], tool_group, func(): canvas.tool = entry[1])
		b.button_pressed = entry[1] == DrawCanvas.Tool.PEN
		_tool_buttons[entry[1]] = b
		tools.add_child(b)
	tools.add_child(VSeparator.new())
	tools.add_child(_picture_button("tool_undo", func(): canvas.undo()))
	tools.add_child(_picture_button("tool_clear", func(): canvas.clear()))
	side.add_child(tools)
	_crayon_box.append(tools)

	if count > 0:
		var stepper := HBoxContainer.new()
		stepper.add_child(UI.label("How many?", 22))
		stepper.add_child(_picture_button("ui_minus", func(): _change_count(-1)))
		_count_label = UI.label(str(count), 30)
		_count_label.custom_minimum_size = Vector2(40, 0)
		_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stepper.add_child(_count_label)
		stepper.add_child(_picture_button("ui_plus", func(): _change_count(1)))
		side.add_child(stepper)

	if not addons.is_empty():
		side.add_child(UI.label("Add to %s:" % host_label, 20))
		_addon_box = HFlowContainer.new()
		_addon_box.add_theme_constant_override("h_separation", 6)
		_addon_box.add_theme_constant_override("v_separation", 6)
		side.add_child(_addon_box)
		refresh_addons()

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

	canvas.set_dot(dot, show_dot)
	if not ghost.is_empty():
		canvas.set_ghost(ghost["image"], ghost["rect"])
	if start_image != null:
		# The old drawing hangs from its dot as before; nudged onto the sheet if the dot moved.
		var room := (Vector2(DrawCanvas.SHEET, DrawCanvas.SHEET) - Vector2(start_image.get_size())).max(Vector2.ZERO)
		var at := (dot - start_pivot).clamp(Vector2.ZERO, room)
		canvas.load_drawing(start_image, at, start_shine.get("mask"), start_shine.get("mode", ""))
		canvas.set_dot(at + start_pivot, show_dot)
	if place_only != "":
		finish.visible = false
		if _addon_box != null:
			_addon_box.visible = false
		begin_placing(place_only)


## The add-on buttons: a part picture (or the kid's own drawing once added, with how many),
## a cross to take it off again, and a red ring on the ones still needed.
func refresh_addons() -> void:
	if _addon_box == null:
		return
	for c in _addon_box.get_children():
		c.queue_free()
	_addon_buttons.clear()
	for type in addons:
		var has: bool = added.has(type)
		var b := Button.new()
		b.custom_minimum_size = Vector2(76, 82)
		b.tooltip_text = PartTypes.info(type)["plural"]
		if required.has(type) and not has:
			b.add_theme_stylebox_override("normal", UI._box(Color("#fff3f0"), Color("#d0482a"), 4))
		elif has:
			b.add_theme_stylebox_override("normal", UI._box(Color("#eef8e6"), UI.GOOD.darkened(0.3), 3))
		var pic: TextureRect
		if has:
			pic = TextureRect.new()
			pic.texture = ImageTexture.create_from_image(added[type]["image"])
			pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			pic.custom_minimum_size = Vector2(46, 46)
			pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			pic = UI.icon(PartTypes.icon(type), 46)
		pic.position = Vector2(15, 4)
		pic.size = Vector2(46, 46)
		b.add_child(pic)
		var l := UI.label(PartTypes.info(type)["plural"], 12)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.position = Vector2(0, 54)
		l.size = Vector2(76, 22)
		b.add_child(l)
		if has:
			var n := UI.title("x%d" % int(added[type]["count"]), 15)
			n.position = Vector2(50, 0)
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE
			b.add_child(n)
			var x := UI.button("x", func(): on_remove_addon.call(type), Vector2(26, 26), 14)
			x.position = Vector2(-6, -6)
			b.add_child(x)
		b.pressed.connect(func(): on_addon.call(type))
		_addon_buttons[type] = b
		_addon_box.add_child(b)


## Shows the add-ons in place on the drawing so far (DrawCanvas.set_previews).
func set_previews(list: Array) -> void:
	canvas.set_previews(list)


func _change_count(by: int) -> void:
	count = clampi(count + by, 1, count_max)
	_count_label.text = str(count)


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
		if canvas.tool == DrawCanvas.Tool.ERASER or canvas.tool == DrawCanvas.Tool.DOT:
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
		if canvas.tool == DrawCanvas.Tool.ERASER or canvas.tool == DrawCanvas.Tool.DOT:
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


# --- Where does it go? ----------------------------------------------------------------------

## Asks the kid to tap where an add-on goes, one tap for each copy; `spots` are taps from last
## time (sheet pixels), to move or add to.
func begin_placing(type: String, spots: Array = []) -> void:
	_place_type = type
	_spots = spots.duplicate()
	canvas.placing = true
	canvas.set_marks(_spots)
	var info := PartTypes.info(type)
	var what: String = info["plural"].to_lower()
	_place_label.text = "Tap your drawing where its %s go - one tap for each! Tap one again to take it away." % what
	_place_box.visible = true
	for c in _crayon_box:
		c.visible = false
	if place_only != "":
		_place_label.text = "Where does it go? Tap the drawing once for each one, then Draw it!"
	_say("")
	_update_place()


## A tap on the drawing while placing: a new spot, or (on a spot) taking it away again.
func place_at(at: Vector2) -> void:
	if _place_type == "":
		return
	for i in _spots.size():
		if (_spots[i] as Vector2).distance_to(at) < 30.0:
			_spots.remove_at(i)
			canvas.set_marks(_spots)
			Sounds.play("undo")
			_update_place()
			return
	if _spots.size() >= int(PartTypes.info(_place_type)["max"]):
		_say("That's as many as it can have!")
		return
	_spots.append(at)
	canvas.set_marks(_spots)
	Sounds.play("dot")
	_update_place()


func _update_place() -> void:
	_place_go.disabled = _spots.is_empty()


func press_place_done() -> void:
	if _spots.is_empty():
		return
	var type := _place_type
	var spots := _spots.duplicate()
	end_placing()
	on_placed.call(type, spots)


func _cancel_placing() -> void:
	end_placing()
	if place_only != "":
		_finish({})


func end_placing() -> void:
	_place_type = ""
	_spots.clear()
	canvas.placing = false
	canvas.set_marks([])
	_place_box.visible = false
	for c in _crayon_box:
		c.visible = place_only == ""


func is_placing() -> bool:
	return _place_type != ""


func press_done() -> void:
	if _done:
		return
	if is_placing():
		end_placing()
	var missing := []
	for type in required:
		if not added.has(type):
			missing.append(PartTypes.info(type)["plural"].to_lower())
	if not missing.is_empty():
		_say("Every creature needs %s! Tap them below to add them." % " and ".join(missing))
		for type in required:
			if _addon_buttons.has(type) and not added.has(type):
				var b: Button = _addon_buttons[type]
				var tween := b.create_tween()
				tween.tween_property(b, "scale", Vector2(1.15, 1.15), 0.12)
				tween.tween_property(b, "scale", Vector2.ONE, 0.12)
		return
	var result := await canvas.finish()
	if result.is_empty():
		_say("Draw something first!" if not can_skip else "Draw something - or tap %s." % skip_text)
		return
	result["count"] = count
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
