class_name CreatureSheet
extends Control
## The whole creature, drawn on one big sheet (.ai/creature-pipeline.md). The kid taps a part -
## Wings - and draws the wings right where they go, on the creature itself; "Done with the wings"
## shows them flapping, and the sheet is straight back, the next part glowing. Nothing else on the
## screen moves about: the same crayons, the same buttons, the same drawing, every time.
##
## Each part type is its own LAYER, so a part can be picked again and fixed - its lines come back
## to draw on and rub out - and so PartCutter can cut the creature into parts when it is done:
## two eyes drawn are two eyes that blink, and a wing knows where it meets the body.
##
## The sheet zooms (pinch, the wheel, or the buttons) for small things like eyes, and slides about
## with two fingers or the hand.
##
## Set the fields, then add it to the tree. `layers` and `shines` are shared with the caller
## (Creator), which saves them in its draft; `on_change` is called whenever a part is put down,
## and `on_finished` gets the pet when the kid says it is finished.

## The sheet, in pixels: about the shape of the space it is shown in, so none of it is wasted.
const SIZE := Vector2i(1024, 896)
const BRUSHES := [[8.0, 4.0], [16.0, 8.0], [32.0, 14.0]]
## The rest of the creature is a little faint while a part is drawn, so it is clear which lines
## are this part's - the ones the eraser rubs out.
const OTHERS_ALPHA := 0.6

## type -> sheet-sized drawing, and type -> {mode, mask} for a shiny one.
var layers := {}
var shines := {}
## Shiny markers the family owns (mode -> how many), and the ones drawn with (mode -> true).
var markers := {}
var markers_used := {}
## The part to start on.
var start := "body"
var on_stop := Callable()
var on_change := Callable()
var on_finished := Callable()

var canvas: DrawCanvas
## The part being drawn now, or "" between parts.
var active := ""

var _cache := {}
var _prompt: Label
var _message: Label
var _part_buttons := {}
var _ticks := {}
var _tool_buttons := {}
var _done_button: Button
var _done_label: Label
var _finish_button: Button
var _pulse: Tween
var _pulsing: Control
var _pen_shine := ""
var _busy := false


func _ready() -> void:
	add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	add_child(UI.full_rect(UI.margin(row, 12)))

	# Tools down the left, the sheet as big as it can be, the parts and crayons on the right.
	var tools := VBoxContainer.new()
	tools.add_theme_constant_override("separation", 4)
	row.add_child(tools)
	var tool_group := ButtonGroup.new()
	for entry in [["tool_crayon", DrawCanvas.Tool.PEN], ["tool_fill", DrawCanvas.Tool.FILL],
			["tool_eraser", DrawCanvas.Tool.ERASER], ["tool_hand", DrawCanvas.Tool.HAND]]:
		var b := _picture_button(entry[0], _set_tool.bind(entry[1]), tool_group)
		b.button_pressed = entry[1] == DrawCanvas.Tool.PEN
		_tool_buttons[entry[1]] = b
		tools.add_child(b)
	tools.add_child(HSeparator.new())
	tools.add_child(_picture_button("tool_undo", _undo))
	tools.add_child(_picture_button("tool_clear", _clear))
	tools.add_child(HSeparator.new())
	tools.add_child(_picture_button("tool_zoom_in", _zoom.bind(1)))
	tools.add_child(_picture_button("tool_zoom_out", _zoom.bind(-1)))
	tools.add_child(_picture_button("tool_fit", _zoom.bind(0)))
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tools.add_child(gap)
	tools.add_child(UI.icon_button("icon_home", "Stop", _stop, 28, Vector2(64, 64)))

	canvas = DrawCanvas.new()
	canvas.sheet_size = SIZE
	canvas.brush = 16.0
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(canvas)
	canvas.message.connect(_say)
	canvas.tapped.connect(_tapped_between_parts)

	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(350, 0)
	side.add_theme_constant_override("separation", 7)
	row.add_child(side)
	_prompt = UI.label("", 20, true)
	_prompt.custom_minimum_size = Vector2(350, 0)
	side.add_child(_prompt)
	_message = UI.label("", 18, true)
	_message.add_theme_color_override("font_color", Color("#d0482a"))
	_message.visible = false
	side.add_child(_message)

	var parts := GridContainer.new()
	parts.columns = 5
	parts.add_theme_constant_override("h_separation", 5)
	parts.add_theme_constant_override("v_separation", 5)
	for type in PartTypes.SHEET_PARTS:
		parts.add_child(_part_button(type))
	side.add_child(parts)

	var colours := GridContainer.new()
	colours.columns = 9
	colours.add_theme_constant_override("h_separation", 4)
	colours.add_theme_constant_override("v_separation", 4)
	var colour_group := ButtonGroup.new()
	for c in UI.PALETTE:
		colours.add_child(_swatch(c, colour_group))
	for mode in markers:
		colours.add_child(_marker_swatch(mode, int(markers[mode]), colour_group))
	side.add_child(colours)

	var sizes := HBoxContainer.new()
	sizes.add_theme_constant_override("separation", 6)
	var size_group := ButtonGroup.new()
	for entry in BRUSHES:
		var b := _picture_button("", _set_brush.bind(entry[0]), size_group, Vector2(56, 50))
		var d := DrawScreen.SizeDot.new()
		d.radius = entry[1]
		b.add_child(UI.full_rect(d))
		b.button_pressed = entry[0] == canvas.brush
		sizes.add_child(b)
	side.add_child(sizes)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)
	_finish_button = UI.button("It's finished!", press_finished, Vector2(0, 58), 24)
	_finish_button.add_theme_stylebox_override("normal", UI._box(UI.GOOD, UI.INK, 3))
	side.add_child(_finish_button)
	_done_button = UI.big_button("", press_done)
	_done_button.custom_minimum_size = Vector2(0, 76)
	var done_row := HBoxContainer.new()
	done_row.alignment = BoxContainer.ALIGNMENT_CENTER
	done_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	done_row.add_theme_constant_override("separation", 8)
	done_row.add_child(UI.icon("tool_done", 42, "none"))
	_done_label = UI.label("", 24)
	_done_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	done_row.add_child(_done_label)
	_done_button.add_child(UI.full_rect(done_row))
	side.add_child(_done_button)

	if not layers.has("body"):
		_open("body")
	elif start == "":
		_next()
	else:
		_open(start)


# --- The parts -------------------------------------------------------------------------------

## A part's button: its picture and name, a tick once it is drawn.
func _part_button(type: String) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(66, 62)
	b.pressed.connect(pick.bind(type))
	var pic := UI.icon(PartTypes.icon(type), 38)
	pic.position = Vector2(14, 2)
	pic.size = Vector2(38, 38)
	b.add_child(pic)
	var l := UI.label(name_of(type).capitalize(), 11)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_child(l)
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	l.grow_horizontal = Control.GROW_DIRECTION_BOTH
	l.offset_top = -22
	l.offset_bottom = -4
	var tick := UI.icon("tool_done", 22, "none")
	tick.position = Vector2(46, -4)
	tick.size = Vector2(22, 22)
	b.add_child(tick)
	_ticks[type] = tick
	_part_buttons[type] = b
	return b


## Tapping a part: put down the one being drawn, and draw this one.
func pick(type: String) -> void:
	if _busy or type == active:
		return
	_busy = true
	await _fold()
	_busy = false
	if type != "body" and not layers.has("body"):
		_open("body")
		_say("Draw its BODY first - then the rest goes on it!")
		Sounds.play("ui_nope")
		return
	Sounds.play("ui_tap")
	_open(type)
	on_change.call()


## "Done with the wings": they come alive for a moment, then on to the next part.
func press_done() -> void:
	if _busy or active == "":
		return
	_busy = true
	var type := active
	await _fold()
	_busy = false
	if not layers.has(type):
		if type == "body" or not layers.has("body"):
			_say("Draw its BODY first - big!")
			return
		_next()
		return
	if not layers.has("body"):
		_open("body")
		_say("Draw its BODY first - then the rest goes on it!")
		return
	Sounds.play("done")
	on_change.call()
	var p := PartPreview.new()
	p.pet = build()
	p.part_type = type
	p.on_done = _next
	add_child(UI.full_rect(p))


## "It's finished!" - if it has everything a creature needs.
func press_finished() -> void:
	if _busy:
		return
	_busy = true
	await _fold()
	_busy = false
	var missing := []
	for type in PartTypes.NEEDED:
		if not layers.has(type):
			missing.append(type)
	if not missing.is_empty():
		var words := []
		for type in missing:
			words.append(PartTypes.info(type)["plural"].to_upper() if type != "body" else "a BODY")
		_say("Every creature needs %s! Tap %s to draw %s." % [" and ".join(words),
			"them" if missing.size() > 1 else "it", "them" if missing.size() > 1 else "it"])
		Sounds.play("ui_nope")
		for type in missing:
			_bounce(_part_buttons[type])
		return
	Sounds.play("done")
	on_finished.call(build())


## The creature as drawn so far, cut into parts (PartCutter).
func build() -> Dictionary:
	return PartCutter.build(layers, shines, _cache)


## Puts the part being drawn into its layer (or takes the layer away if it was all rubbed out).
## The page stays as it is.
func _fold() -> void:
	if active == "" or not canvas.changed_since_load():
		return
	var type := active
	var snap := await canvas.snapshot_full()
	if snap.is_empty():
		layers.erase(type)
		shines.erase(type)
	else:
		layers[type] = snap["image"]
		if (snap["shine"] as Dictionary).is_empty():
			shines.erase(type)
		else:
			shines[type] = snap["shine"]
		if snap["used_marker"] != "":
			markers_used[snap["used_marker"]] = true
	_cache.erase(type)
	canvas.mark_loaded()


## The sheet with `type` to draw on - its lines from before, if it has any - and everything else
## on the creature shown around it, in front or behind as it will be.
func _open(type: String) -> void:
	active = type
	canvas.restart()
	canvas.placing = false
	if layers.has(type):
		var sh: Dictionary = shines.get(type, {})
		canvas.load_drawing(layers[type], Vector2.ZERO, sh.get("mask"), sh.get("mode", ""))
	canvas.mark_loaded()
	canvas.shine = _pen_shine
	_show_others()
	_say("")
	_refresh()


## Between parts - nothing left that a creature usually has. The page can't be drawn on until a
## part is picked (what would the lines be?).
func _next() -> void:
	for type in PartTypes.SUGGESTED:
		if not layers.has(type):
			_open(type)
			return
	active = ""
	canvas.restart()
	canvas.placing = true
	_show_others()
	_refresh()


func _tapped_between_parts(_at: Vector2) -> void:
	_say("Tap a part to draw more - or tap It's finished!")
	_bounce(_finish_button)


## Every other layer around the one being drawn, stacked the way the creature will be (the tail
## and spikes behind the body, the head and legs on it, the face on the head) and a little faint.
func _show_others() -> void:
	var order := stack_order()
	var at := order.find(active)
	# Flattened into what goes behind the part and what goes in front, so the faint creature is
	# faint all over - a tail does not show through the body it is tucked behind.
	var behind: Image
	var front: Image
	for type in order:
		if type == active or not layers.has(type):
			continue
		if at >= 0 and order.find(type) > at:
			front = _stack_on(front, layers[type])
		else:
			behind = _stack_on(behind, layers[type])
	var list := []
	for img in [behind, front]:
		if img != null:
			list.append({"texture": ImageTexture.create_from_image(img), "pos": Vector2.ZERO,
				"pivot": Vector2.ZERO, "scale": 1.0, "alpha": OTHERS_ALPHA if active != "" else 1.0,
				"behind": img == behind})
	canvas.set_previews(list)


static func _stack_on(under: Image, img: Image) -> Image:
	if img == null:
		return under
	if under == null:
		under = Image.create(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	under.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i.ZERO)
	return under


## What a part is called on its button: "eyes" and "legs", but "head" and "tail" - the ones a
## creature usually has one of.
static func name_of(type: String) -> String:
	if type in ["body", "head", "mouth", "nose", "tail", "hair", "other"]:
		return type
	return PartTypes.info(type)["plural"].to_lower()


## Back to front, the way the creature stacks.
static func stack_order() -> Array:
	var out: Array = PartCutter.BEHIND.duplicate()
	out.append("body")
	for type in PartTypes.ORDER:
		if not out.has(type):
			out.append(type)
	return out


## The prompt, the Done button, and the part buttons: the one being drawn lit up, ticks on the
## ones drawn, the rest faded until there is a body, and the next good one gently glowing.
func _refresh() -> void:
	if active != "":
		_prompt.text = PartTypes.DRAW[active]
		_done_label.text = "Done with this" if active == "other" else "Done with the %s" % name_of(active)
	else:
		_prompt.text = "Tap a part to draw more - or tap It's finished!"
	_done_button.visible = active != ""
	var ready := true
	for type in PartTypes.NEEDED:
		if not layers.has(type) and type != active:
			ready = false
	_finish_button.visible = ready
	var next := ""
	for type in PartTypes.SUGGESTED:
		if not layers.has(type) and type != active:
			next = type
			break
	for type in _part_buttons:
		var b: Button = _part_buttons[type]
		var drawn := layers.has(type)
		if type == active:
			b.add_theme_stylebox_override("normal", UI._box(UI.HILITE, UI.ACCENT, 5))
		elif drawn:
			b.add_theme_stylebox_override("normal", UI._box(Color("#eef8e6"), UI.GOOD.darkened(0.3), 3))
		else:
			b.remove_theme_stylebox_override("normal")
		(_ticks[type] as Control).visible = drawn and type != active
		b.modulate.a = 1.0 if type == "body" or type == next or layers.has("body") else 0.45
	_glow(_part_buttons.get(next))


func _glow(b: Control) -> void:
	if _pulsing == b:
		return
	if _pulse != null:
		_pulse.kill()
	if _pulsing != null and is_instance_valid(_pulsing):
		_pulsing.scale = Vector2.ONE
	_pulsing = b
	if b == null:
		return
	b.pivot_offset = b.custom_minimum_size / 2.0
	_pulse = b.create_tween().set_loops()
	_pulse.tween_property(b, "scale", Vector2(1.12, 1.12), 0.45).set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(b, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_SINE)


func _bounce(b: Control) -> void:
	b.pivot_offset = b.size / 2.0
	var t := b.create_tween()
	t.tween_property(b, "scale", Vector2(1.15, 1.15), 0.12)
	t.tween_property(b, "scale", Vector2.ONE, 0.12)


func _say(text: String) -> void:
	_message.text = text
	_message.visible = text != ""


## For the caller's draft: the part being drawn, put into its layer.
func state() -> void:
	await _fold()


## Android's back gesture, while a part is showing off: carry on.
func skip_preview() -> bool:
	for c in get_children():
		if c is PartPreview and not c.is_queued_for_deletion():
			(c as PartPreview).skip()
			return true
	return false


# --- Tools -----------------------------------------------------------------------------------

func _stop() -> void:
	on_stop.call()


func _set_tool(t: DrawCanvas.Tool) -> void:
	canvas.tool = t


func _set_brush(px: float) -> void:
	canvas.brush = px


func _undo() -> void:
	canvas.undo()


func _clear() -> void:
	canvas.clear()


## 1 closer, -1 further, 0 the whole sheet.
func _zoom(way: int) -> void:
	match way:
		1:
			canvas.zoom_in()
		-1:
			canvas.zoom_out()
		_:
			canvas.reset_view()
	Sounds.play("ui_tap")


func _picture_button(icon: String, on_press: Callable, group: ButtonGroup = null,
		min_size := Vector2(64, 56)) -> Button:
	var b := Button.new()
	b.custom_minimum_size = min_size
	if group != null:
		b.toggle_mode = true
		b.button_group = group
	b.pressed.connect(on_press)
	if icon != "":
		var pic := UI.icon(icon, 42)
		pic.position = (min_size - Vector2(42, 42)) / 2.0
		b.add_child(pic)
	return b


func _swatch(c: Color, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = Vector2(35, 35)
	var light := c.get_luminance() > 0.8
	for state_name in ["normal", "hover"]:
		b.add_theme_stylebox_override(state_name, UI._box(c, UI.INK_SOFT if light else c.darkened(0.25), 3, 18, 4))
	for state_name in ["pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(state_name, UI._box(c, UI.ACCENT, 6, 18, 4))
	b.button_pressed = c == UI.PALETTE[0]
	b.pressed.connect(_pick_colour.bind(c, ""))
	return b


## A shiny marker: draws in gold, rainbow or glitter. Used up when the pet is finished.
func _marker_swatch(mode: String, n: int, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = Vector2(35, 35)
	b.tooltip_text = "%s marker (%d left)" % [mode.capitalize(), n]
	var pic := UI.icon(Items.MARKERS[mode][0], 31)
	pic.position = Vector2(2, 2)
	b.add_child(pic)
	b.pressed.connect(_pick_colour.bind(Items.MARKERS[mode][1], mode))
	return b


func _pick_colour(c: Color, mode: String) -> void:
	canvas.color = c
	canvas.shine = mode
	_pen_shine = mode
	if mode != "":
		_say("Shiny %s marker! It gets used up when your pet is finished." % mode)
	if canvas.tool == DrawCanvas.Tool.ERASER or canvas.tool == DrawCanvas.Tool.HAND:
		canvas.tool = DrawCanvas.Tool.PEN
		_tool_buttons[DrawCanvas.Tool.PEN].button_pressed = true
