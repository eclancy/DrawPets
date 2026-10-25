class_name CreatureSheet
extends Control
## The whole creature, drawn on one big sheet (.ai/creature-pipeline.md), one part at a time and
## each right where it goes, GUIDED by the plan the kid made first (PartPlanner: one head, two
## eyes, four legs...). The sheet asks for each in turn - "Draw a LEG", then "LEG 2 of 4! Draw it
## - or copy the last one" - with "Copy" sliding a copy of the last one where it goes. When a
## kind of part is all drawn it shows off (legs walk), and the next is asked for; when the plan is
## all drawn, "Anything else?" offers wings, horns, tentacles and the rest. The parts in the plan
## sit on the right with a dot for each one, filled as they are drawn - tap one to go back to it.
## Nothing else on the screen moves about: the same crayons, the same buttons, the same drawing.
##
## Every part the kid draws is its own DRAWING, so nothing is ever copied or joined behind their
## back: four legs are four drawings (or four legs drawn in one go - they count), a copy is a
## button they pressed. Each drawing goes IN FRONT of what it grows from or BEHIND it - the kid's
## choice, one button - and the sheet shows the creature stacked exactly as it will be.
##
## The bold drawing is the one being drawn; the rest of the creature is faint around it, so it is
## clear which lines the crayon, eraser and undo touch. The bucket in a faint drawing of the same
## part, or the eraser on one, makes that one the bold one.
##
## The sheet zooms (pinch, the wheel, or the buttons) for small things like eyes, and slides about
## with two fingers or the hand.
##
## Set the fields, then add it to the tree. `layers` is shared with the caller (Creator), which
## saves it in its draft; `on_change` is called whenever a drawing is put down, and `on_finished`
## gets the pet when the kid says it is finished.

## The sheet, in pixels: about the shape of the space it is shown in, so none of it is wasted.
const SIZE := Vector2i(1024, 896)
const BRUSHES := [[8.0, 4.0], [16.0, 8.0], [32.0, 14.0]]
## The rest of the creature is a little faint while a part is drawn, so it is clear which lines
## are this part's - the ones the eraser rubs out.
const OTHERS_ALPHA := 0.6
## Parts a creature usually has one of: their Done button says "the head", not "the heads".
const ONE_OF := ["body", "head", "mouth", "nose", "tail", "hair", "other"]
## The first few copies get the hand showing the slide.
const HOW_COPIES := 3
## A tool on the left, two to a row, with its word under its picture - big enough for a small
## finger on a phone, where the whole screen is about 7 cm tall.
const TOOL_SIZE := Vector2(84, 76)
## The parts, the crayons and Done, on the right.
const SIDE_W := 420.0
## The plan's parts: three rows of them, as wide as fits.
const TILE_H := 76.0
const STRIP_HEIGHT := 240.0
## What to draw now, across the top of the drawing: where the kid is looking.
const BANNER_H := 76.0

## type -> [drawing, ...], in the order drawn. A drawing is {image (cropped to its ink), at (sheet
## px of its top-left), shine ({} or {mode, mask} the same size), behind (bool), z (its place in the
## stack)} - what PartCutter.build takes.
var layers := {}
## Shiny markers the family owns (mode -> how many), and the ones drawn with (mode -> true).
var markers := {}
var markers_used := {}
## For the hint's "first few times" (HowTo.first_times). Optional.
var profile: Profile
## The part to start on; "" for none (between parts).
var start := "body"
## What the kid said the pet will have, in drawing order: [[type, how many], ...]
## (PartTypes.plan_from). Shared with the caller, which saves it in the draft; changed in place -
## "No more legs" takes legs down to the ones drawn, "Anything else?" adds to it.
var plan: Array = []
var on_stop := Callable()
var on_change := Callable()
var on_finished := Callable()

var canvas: DrawCanvas
## The part being drawn now, or "" between parts.
var active := ""

## The bold drawing's settings (behind, z) - and, once something is drawn, the drawing itself:
## while `_in_list` it is the last of its part's drawings.
var _bold := {}
var _in_list := false
## The bold drawing began as Draw another or Copy on this visit (undo can take it back whole);
## it is a copy not yet drawn on (it can still slide).
var _fresh := false
var _copying := false
var _row_bounced := false
var _switching := false
var _cache := {}
## The banner over the drawing: the part's picture, what to draw ("Draw a LEG", "LEG 2 of 4") and
## a line under it - how, or anything the game has to say ("That's its BODY!").
var _banner_box: Control
var _banner_icon: TextureRect
var _head: Label
var _tip: Label
var _tip_text := ""
var _said := ""
## The plan's parts on the right: type -> its button, its dots, its tick.
var _tiles := {}
var _dots := {}
var _ticks := {}
var _strip: GridContainer
var _strip_types: Array = []
var _more: PartPlanner
var _tool_buttons := {}
var _row: HBoxContainer
var _copy: Button
var _stack_box: HBoxContainer
var _front: Button
var _behind: Button
var _done_button: Button
var _done_label: Label
var _finish_button: Button
var _how: HowTo
var _pen_shine := ""
var _busy := false
## Opening a page: the canvas's own restart is not the kid editing.
var _opening := false
## The rest of the creature, in front of the bold drawing, is nearly solid while that drawing is
## behind something - what is hidden on the creature is hidden here too.
const FRONT_ALPHA_BEHIND := 0.9
## Parts that only ever sit on the face: no In front / Behind for them (behind, they would vanish).
const ALWAYS_FRONT := ["eye", "mouth", "nose"]


func _ready() -> void:
	add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	add_child(UI.full_rect(UI.margin(row, 8)))

	# Tools down the left, two to a row; what to draw over the sheet, which is as big as it can be;
	# the parts and crayons on the right.
	var tools := VBoxContainer.new()
	tools.add_theme_constant_override("separation", 8)
	row.add_child(tools)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	tools.add_child(grid)
	var tool_group := ButtonGroup.new()
	# Each with its word under it: a crumpled page is "Clear", the hand is "Move".
	for entry in [["tool_crayon", DrawCanvas.Tool.PEN, "Crayon"], ["tool_fill", DrawCanvas.Tool.FILL, "Paint"],
			["tool_eraser", DrawCanvas.Tool.ERASER, "Eraser"], ["tool_hand", DrawCanvas.Tool.HAND, "Move"]]:
		var b := _picture_button(entry[0], _set_tool.bind(entry[1]), tool_group, TOOL_SIZE, entry[2])
		b.button_pressed = entry[1] == DrawCanvas.Tool.PEN
		_tool_buttons[entry[1]] = b
		grid.add_child(b)
	grid.add_child(_picture_button("tool_undo", _undo, null, TOOL_SIZE, "Undo"))
	grid.add_child(_picture_button("tool_clear", _clear, null, TOOL_SIZE, "Clear"))
	grid.add_child(_picture_button("tool_zoom_in", _zoom.bind(1), null, TOOL_SIZE, "Zoom in"))
	grid.add_child(_picture_button("tool_zoom_out", _zoom.bind(-1), null, TOOL_SIZE, "Zoom out"))
	grid.add_child(_picture_button("tool_fit", _zoom.bind(0), null, TOOL_SIZE, "See all"))
	var sizes := HBoxContainer.new()
	sizes.add_theme_constant_override("separation", 6)
	var size_group := ButtonGroup.new()
	for entry in BRUSHES:
		var b := _picture_button("", _set_brush.bind(entry[0]), size_group, Vector2(54, 54))
		var d := DrawScreen.SizeDot.new()
		d.radius = entry[1]
		b.add_child(UI.full_rect(d))
		b.button_pressed = entry[0] == 16.0
		sizes.add_child(b)
	tools.add_child(sizes)
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tools.add_child(gap)
	tools.add_child(UI.icon_button("icon_home", "Stop", _stop, 36, Vector2(TOOL_SIZE.x * 2.0 + 6.0, 76)))

	var middle := VBoxContainer.new()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.add_theme_constant_override("separation", 8)
	row.add_child(middle)
	middle.add_child(_banner())
	canvas = DrawCanvas.new()
	canvas.sheet_size = SIZE
	canvas.brush = 16.0
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_child(canvas)
	canvas.message.connect(_say)
	canvas.tapped.connect(_tapped_between_parts)
	canvas.edited.connect(_on_edited)
	canvas.copy_dropped.connect(_on_copy_dropped)
	canvas.moving_ended.connect(_on_moving_ended)
	canvas.on_miss = _bucket_missed
	canvas.chooser = _press_picks

	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(SIDE_W, 0)
	side.add_theme_constant_override("separation", 8)
	row.add_child(side)

	# The plan's parts, a dot for each one; tap one to go back to it. Its room is kept whatever
	# the plan, so nothing below it moves.
	var strip_room := Control.new()
	strip_room.custom_minimum_size = Vector2(SIDE_W, STRIP_HEIGHT)
	_strip = GridContainer.new()
	_strip.add_theme_constant_override("h_separation", 6)
	_strip.add_theme_constant_override("v_separation", 6)
	strip_room.add_child(_strip)
	side.add_child(strip_room)

	# A copy, in front or behind - for the part being drawn. The row keeps its room even when it
	# has nothing to offer (the body), so the screen never changes shape.
	_row = HBoxContainer.new()
	_row.custom_minimum_size = Vector2(SIDE_W, 76)
	_row.add_theme_constant_override("separation", 8)
	_copy = _row_button(press_copy, 240)
	_row.add_child(_copy)
	# In front | Behind: two halves, the one it is now lit - tap the one you want.
	_stack_box = HBoxContainer.new()
	_stack_box.add_theme_constant_override("separation", 4)
	_front = _row_button(set_front.bind(true), 84)
	_behind = _row_button(set_front.bind(false), 84)
	_stack_box.add_child(_front)
	_stack_box.add_child(_behind)
	_row.add_child(_stack_box)
	side.add_child(_row)

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

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)
	_finish_button = UI.button("It's finished!", press_finished, Vector2(0, 64), 28)
	_finish_button.add_theme_stylebox_override("normal", UI._box(UI.GOOD, UI.INK, 3))
	side.add_child(_finish_button)
	_done_button = UI.big_button("", press_done)
	_done_button.custom_minimum_size = Vector2(0, 84)
	var done_row := HBoxContainer.new()
	done_row.alignment = BoxContainer.ALIGNMENT_CENTER
	done_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	done_row.add_theme_constant_override("separation", 10)
	done_row.add_child(UI.icon("tool_done", 48, "none"))
	_done_label = UI.label("", 30)
	_done_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	done_row.add_child(_done_label)
	_done_button.add_child(UI.full_rect(done_row))
	side.add_child(_done_button)

	if PartTypes.planned(plan, "body") == 0:
		PartTypes.add_to_plan(plan, {"body": 1})
	if not layers.has("body"):
		_open("body")
	elif start == "":
		_between_parts()
	else:
		_open(start)


## What to draw now, over the sheet, lit like the part's tile: its picture, "Draw a LEG" big, and
## the line under it.
func _banner() -> Control:
	var banner := PanelContainer.new()
	_banner_box = banner
	banner.custom_minimum_size = Vector2(0, BANNER_H)
	banner.add_theme_stylebox_override("panel", UI._box(UI.HILITE, UI.ACCENT, 4, 18, 12))
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 14)
	banner.add_child(line)
	_banner_icon = UI.icon("part_body", 60, "none")
	_banner_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(_banner_icon)
	_head = UI.label("", 32)
	_head.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(_head)
	_tip = UI.label("", 20, true)
	_tip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_tip.max_lines_visible = 2
	_tip.add_theme_constant_override("line_spacing", -2)
	line.add_child(_tip)
	return banner


## The banner: this part's picture, what to draw, and how. A new part makes it bounce, so the
## change is seen.
func _direct(icon: String, head: String, tip: String) -> void:
	_banner_icon.texture = Items.art_texture(icon)
	if _head.text != head and _head.text != "":
		_bounce(_banner_box, 1.06)
	_head.text = head
	_tip_text = tip
	_show_tip()


func _show_tip() -> void:
	_tip.text = _said if _said != "" else _tip_text
	_tip.add_theme_color_override("font_color", Color("#c8401f") if _said != "" else UI.INK_SOFT)


func _refresh_direction() -> void:
	if active == "":
		_direct("tool_done", "All drawn!", "Tap a part to fix it, or Add more - or It's finished!")
		return
	var d := _direction_for(active)
	_direct(PartTypes.icon(active), d[0], d[1])


# --- The parts -------------------------------------------------------------------------------

## The plan's parts on the right, again if the plan has changed: a tile for each kind of part in
## it, in drawing order, and Add more at the end.
func _build_strip() -> void:
	var types := []
	for e in plan:
		types.append(str(e[0]))
	if types == _strip_types:
		return
	_strip_types = types
	for c in _strip.get_children():
		UI.retire(c)
	_tiles.clear()
	_dots.clear()
	_ticks.clear()
	var n := types.size() + 1
	var cols := 5 if n <= 15 else (6 if n <= 18 else 7)
	_strip.columns = cols
	var w := floorf((SIDE_W - 6.0 * (cols - 1)) / cols)
	for type in types:
		_strip.add_child(_tile(type, w))
	var more := _tile_button(w, ask_more)
	var px := _tile_icon(w)
	var pic := UI.icon("ui_plus", px * 0.85)
	pic.position = Vector2((w - px * 0.85) / 2.0, 6)
	more.add_child(pic)
	more.add_child(_words("Add more", _tile_font(w)))
	_strip.add_child(more)


## A part in the plan: its picture, a dot for each one (filled when drawn), its name, and a tick
## once they are all drawn.
func _tile(type: String, w: float) -> Button:
	var b := _tile_button(w, pick.bind(type))
	var px := _tile_icon(w)
	var pic := UI.icon(PartTypes.icon(type), px)
	pic.position = Vector2((w - px) / 2.0, 3)
	b.add_child(pic)
	var dots := Dots.new()
	dots.position = Vector2(2, 4.0 + px)
	dots.size = Vector2(w - 4.0, 10)
	b.add_child(dots)
	_dots[type] = dots
	b.add_child(_words(name_of(type).capitalize(), _tile_font(w)))
	var tick := UI.icon("tool_done", 26, "none")
	tick.position = Vector2(w - 22.0, -5)
	tick.size = Vector2(26, 26)
	b.add_child(tick)
	_ticks[type] = tick
	_tiles[type] = b
	return b


func _tile_button(w: float, on_press: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(w, TILE_H)
	b.pressed.connect(on_press)
	return b


static func _tile_icon(w: float) -> float:
	return 40.0 if w >= 70.0 else 34.0


static func _tile_font(w: float) -> int:
	return 15 if w >= 70.0 else 13


## Words along the bottom of a button.
func _words(text: String, font_size := 15) -> Label:
	var l := UI.label(text, font_size)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	l.grow_horizontal = Control.GROW_DIRECTION_BOTH
	l.offset_top = -(font_size + 8)
	l.offset_bottom = -2
	return l


func _bounce_tile(type: String) -> void:
	if _tiles.has(type):
		_bounce(_tiles[type])


## A dot for each of a part the plan has: filled once drawn. One-of parts and bunches show none
## (their tick says it).
class Dots extends Control:
	var n := 0
	var have := 0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if n <= 1:
			return
		var gap := minf(9.0, (size.x - 8.0) / float(n - 1))
		var r := minf(3.6, gap * 0.42)
		var x0 := size.x / 2.0 - gap * (n - 1) / 2.0
		for i in n:
			var c := Vector2(x0 + gap * i, size.y / 2.0)
			if i < have:
				draw_circle(c, r, UI.GOOD.darkened(0.25))
			else:
				draw_arc(c, r, 0.0, TAU, 12, UI.INK_SOFT, 1.5, true)


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


## "Copy this leg": the same leg again, just beside it, to slide where it goes - the next one. On
## a fresh page ("LEG 2 of 4!") it copies the last one drawn into it.
func press_copy() -> void:
	if _busy or active == "" or active == "body":
		return
	_busy = true
	await _fold()
	_busy = false
	var list: Array = layers.get(active, [])
	if list.is_empty():
		_nope("Draw one first!")
		return
	var src: Dictionary = _bold if _in_list else list.back()
	canvas.restart()
	var sh: Dictionary = src.get("shine", {})
	var at := _copy_at(src)
	canvas.load_drawing(src["image"], at, sh.get("mask"), sh.get("mode", ""))
	canvas.shine = _pen_shine
	# Not marked as kept: the copy is new, so it is put down even if it never moves.
	_start_fresh(bool(src.get("behind", false)))
	_copying = true
	if canvas.tool != DrawCanvas.Tool.HAND:
		_select_tool(DrawCanvas.Tool.PEN)
	canvas.moving = true
	canvas.bring_into_view(at + Vector2((src["image"] as Image).get_size()) / 2.0)
	Sounds.play("pickup")
	_show_others()
	_say("")
	_tip_text = PartTypes.DRAG_COPY
	_show_tip()
	_refresh_row()
	_show_how_drag()
	on_change.call()


## In front of what it grows from, or behind it: the bold drawing goes to the very front of the
## stack or the very back. Tapping the side it is already on does nothing but bounce.
func set_front(front: bool) -> void:
	if _busy or active == "" or active == "body" or ALWAYS_FRONT.has(active):
		return
	var b := _front if front else _behind
	if bool(_bold.get("behind", false)) != front:
		_bounce(b)
		return
	_bold["behind"] = not front
	_bold["z"] = _top_z() + 1 if front else _bottom_z() - 1
	Sounds.play("ui_toggle")
	_show_others()
	_refresh_row()
	_bounce(b)
	on_change.call()


## The demo's old name for it: swaps sides.
func press_stack() -> void:
	set_front(bool(_bold.get("behind", false)))


## A new bold drawing of the active part, not drawn yet: on top of the stack.
func _start_fresh(behind: bool) -> void:
	_in_list = false
	_fresh = true
	_copying = false
	_bold = {"behind": behind, "z": _top_z() + 1}


## Where a copy first goes: just to the right of the one copied (or the left, if the sheet ends).
func _copy_at(d: Dictionary) -> Vector2:
	var img: Image = d["image"]
	var w := float(img.get_width())
	var at: Vector2 = d["at"] + Vector2(w + 24.0, 0.0)
	if at.x + w > SIZE.x:
		at = d["at"] - Vector2(w + 24.0, 0.0)
	if at.x < 0.0:
		at = d["at"] + Vector2(24.0, 24.0)
	return at.clamp(Vector2.ZERO, (Vector2(SIZE) - Vector2(img.get_size())).max(Vector2.ZERO))


## Done: on to the next one of these ("Next leg"), or - when they are all drawn - they come alive
## for a moment ("Done with the legs") and the next part in the plan is asked for. Done on an empty
## page means no more of these ("No more legs", "Skip the tail"): the plan comes down to the ones
## drawn. When the plan is all drawn, "Anything else?".
func press_done() -> void:
	if _busy or active == "":
		return
	_busy = true
	var type := active
	var blank := not _bold_has_ink()
	var was_open := _first_unfinished() != ""
	await _fold()
	_busy = false
	if not layers.has("body"):
		if type != "body":
			_open("body")
		_nope("Draw its BODY first - big!")
		return
	var have := count_of(type)
	if blank:
		if have == 0 and PartTypes.NEEDED.has(type):
			_nope("Every creature needs %s! Draw %s." % [_needs_words(type), "it" if ONE_OF.has(type) else "one"])
			return
		_set_planned(type, have)
		Sounds.play("ui_tap")
		on_change.call()
		if have == 0:
			_after_part(was_open)
		else:
			_show_off(type, was_open)
		return
	if have < _planned(type):
		Sounds.play("ui_tap")
		_open_new(type)
		on_change.call()
		return
	_set_planned(type, maxi(have, _planned(type)))
	Sounds.play("done")
	on_change.call()
	_show_off(type, was_open)


## The part comes alive for a moment (PartPreview), then on.
func _show_off(type: String, was_open: bool) -> void:
	var p := PartPreview.new()
	p.pet = build()
	p.part_type = type
	p.on_done = _after_part.bind(was_open)
	add_child(UI.full_rect(p))


## On to the next part the plan wants - or, if that was the last of it, "Anything else?".
func _after_part(was_open: bool) -> void:
	_next()
	if active == "" and was_open:
		ask_more()


## "a MOUTH", "EYES".
func _needs_words(type: String) -> String:
	return "a " + type.to_upper() if ONE_OF.has(type) else PartTypes.info(type)["plural"].to_upper()


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
			words.append(_needs_words(type))
		# Straight to the first one missing.
		for type in missing:
			if _planned(type) == 0:
				_set_planned(type, 1)
		if active != missing[0]:
			_open(missing[0])
		_say("Every creature needs %s! Draw %s here." % [" and ".join(words),
			"them" if missing.size() > 1 else "it"])
		Sounds.play("ui_nope")
		for type in missing:
			_bounce_tile(type)
		return
	Sounds.play("done")
	on_finished.call(build())


## The creature as drawn so far, cut into parts (PartCutter).
func build() -> Dictionary:
	return PartCutter.build(layers, _cache)


## A drawing from a sheet-sized picture (and its sheet-sized shine mask): cropped to its ink.
## {} when there is no ink.
static func drawing_from_sheet(img: Image, shine: Dictionary, behind := false, z := 0) -> Dictionary:
	var used := img.get_used_rect()
	if used.size.x < 2 or used.size.y < 2:
		return {}
	var d := {"image": img.get_region(used), "at": Vector2(used.position), "shine": {},
		"behind": behind, "z": z}
	var mask: Image = shine.get("mask")
	if mask != null:
		var cut := mask.get_region(used)
		if cut.get_used_rect().size.x > 0:
			d["shine"] = {"mode": shine["mode"], "mask": cut}
	return d


## Puts the bold drawing down as it is on the page (or takes it away if it was all rubbed out).
## The page stays as it is.
func _fold() -> void:
	if active == "" or not canvas.changed_since_load():
		return
	var type := active
	var snap := await canvas.snapshot_full()
	if active != type:
		return  # another page opened meanwhile; this snapshot is not this part's any more
	var list: Array = layers.get(type, [])
	if _in_list and not list.is_empty():
		list.pop_back()
	var d := {} if snap.is_empty() else drawing_from_sheet(snap["image"], snap["shine"],
		bool(_bold.get("behind", false)), int(_bold.get("z", 0)))
	_in_list = not d.is_empty()
	if _in_list:
		list.append(d)
		_bold = d
		if snap["used_marker"] != "":
			markers_used[snap["used_marker"]] = true
	if list.is_empty():
		layers.erase(type)
	else:
		layers[type] = list
	canvas.mark_loaded()


## The sheet with `type` to draw on - its last drawing from before, if it has any - and the rest
## of the creature faint around it, in front or behind as it will be.
func _open(type: String) -> void:
	_opening = true
	active = type
	var list: Array = layers.get(type, [])
	_in_list = not list.is_empty()
	_fresh = false
	_copying = false
	_row_bounced = false
	canvas.restart()
	canvas.placing = false
	if _in_list:
		_bold = list.back()
		var sh: Dictionary = _bold.get("shine", {})
		canvas.load_drawing(_bold["image"], _bold["at"], sh.get("mask"), sh.get("mode", ""))
	else:
		_bold = {"behind": PartCutter.BEHIND.has(type), "z": _top_z() + 1}
	canvas.mark_loaded()
	canvas.shine = _pen_shine
	_opening = false
	_dismiss_how()
	_show_others()
	_say("")
	_refresh()


## A fresh page for one more of `type` (the next leg), the rest of the creature faint around it.
func _open_new(type: String) -> void:
	_opening = true
	active = type
	canvas.restart()
	canvas.placing = false
	canvas.mark_loaded()
	canvas.shine = _pen_shine
	_start_fresh(PartCutter.BEHIND.has(type))
	_row_bounced = false
	_opening = false
	_dismiss_how()
	_show_others()
	_say("")
	_refresh()
	# There is one to copy now.
	if layers.has(type) and not ONE_OF.has(type):
		_row_bounced = true
		_bounce(_copy)


## On to the first part in the plan not all drawn yet - a fresh page for the next one. When the
## plan is all drawn, between parts: the page can't be drawn on until a part is picked (what would
## the lines be?).
func _next() -> void:
	var type := _first_unfinished()
	if type == "":
		_between_parts()
		return
	if layers.has(type):
		_open_new(type)
	else:
		_open(type)
	_bounce_tile(type)


## The first part in the plan with fewer drawn than planned, or "".
func _first_unfinished() -> String:
	for e in plan:
		if count_of(str(e[0])) < int(e[1]):
			return str(e[0])
	return ""


## How many of `type` are drawn: every separate piece of its drawings (four legs drawn in one go
## are four), as PartCutter will cut them. A bunch (spikes) is one, however many.
func count_of(type: String) -> int:
	var n := 0
	for d in layers.get(type, []):
		n += _pieces_in(d)
	if PartTypes.BUNCH.has(type):
		return mini(n, 1)
	return n


func _pieces_in(d: Dictionary) -> int:
	var img: Image = d["image"]
	if not _cache.has(img):
		_cache[img] = PartCutter.pieces(img, Vector2i(d["at"]))
	return (_cache[img] as Array).size()


func _planned(type: String) -> int:
	return PartTypes.planned(plan, type)


func _set_planned(type: String, n: int) -> void:
	PartTypes.add_to_plan(plan, {type: n})


## Which of its kind the bold drawing is: 1 for the first leg, 2 for the next...
func _step_no() -> int:
	var n := 0
	for d in layers.get(active, []):
		if not (_in_list and d == _bold):
			n += _pieces_in(d)
	return n + 1


## Is there anything on the bold drawing?
func _bold_has_ink() -> bool:
	return canvas.op_count() > 0 or _in_list


# --- Anything else? ------------------------------------------------------------------------------

## "Anything else?" (PartPlanner) over the drawing: wings, horns, tentacles... added to the plan
## and drawn next. From Add more any time, and by itself when the plan is all drawn.
func ask_more() -> void:
	if _busy or (_more != null and is_instance_valid(_more)):
		return
	_busy = true
	await _fold()
	_busy = false
	var m := PartPlanner.new()
	m.mode = "more"
	m.plan = plan
	m.on_done = _add_more
	m.on_back = close_more
	m.on_finished = _finish_from_more
	_more = m
	add_child(UI.full_rect(m))
	_refresh()


func close_more() -> void:
	if _more != null and is_instance_valid(_more):
		UI.retire(_more)
	_more = null


func _add_more(counts: Dictionary) -> void:
	close_more()
	PartTypes.add_to_plan(plan, counts)
	on_change.call()
	if active == "":
		_next()
	else:
		_refresh()


func _finish_from_more() -> void:
	close_more()
	press_finished()


func _between_parts() -> void:
	active = ""
	canvas.restart()
	canvas.placing = true
	_dismiss_how()
	_show_others()
	_refresh()


func _tapped_between_parts(_at: Vector2) -> void:
	_say("Tap a part to fix it, or Add more - or tap It's finished!")
	_bounce(_finish_button)


# --- The stack: what is in front of what ----------------------------------------------------------

## Every drawing, back to front, as the creature will stack them: on what it grows from (as
## PartCutter.attach will find it), in front of it or behind it as the kid chose, and the
## later-stacked in front among those on the same part. [[type, drawing]] - with the bold drawing
## in it even before anything is drawn (no image yet).
func _stacked() -> Array:
	var extra := []
	if active != "" and not _in_list:
		extra = [active, _bold]
	return stack_of(layers, extra)


## The same for any drawings (the draft's picture uses it too); `extra` is one more [type, drawing].
static func stack_of(drawings: Dictionary, extra: Array = []) -> Array:
	var all := []
	for type in drawings:
		for d in drawings[type]:
			all.append([type, d])
	if not extra.is_empty():
		all.append(extra)
	var body: Array = []
	for e in all:
		if e[0] == "body":
			body = e
	if body.is_empty():
		return all
	var hosts := {}
	for e in all:
		if e != body:
			hosts[e] = _host_of(e, all, body)
	var out := []
	_emit(body, all, hosts, out)
	# Anything that could not be hung (should not happen), on top.
	for e in all:
		if not out.has(e):
			out.append(e)
	return out


## Behind ones, the part, front ones - each in the stack's order.
static func _emit(node: Array, all: Array, hosts: Dictionary, out: Array) -> void:
	var kids := []
	for e in all:
		if hosts.get(e) == node:
			kids.append(e)
	kids.sort_custom(_lower)
	for e in kids:
		if bool(e[1].get("behind", false)):
			_emit(e, all, hosts, out)
	out.append(node)
	for e in kids:
		if not bool(e[1].get("behind", false)):
			_emit(e, all, hosts, out)


static func _lower(a: Array, b: Array) -> bool:
	return int(a[1].get("z", 0)) < int(b[1].get("z", 0))


## What a drawing will grow from, as PartCutter.attach finds it: of the parts that can carry it
## (the body always; a head for a face, a spike or anything else; an arm for a hand; a leg or an
## arm for a foot or claw), the one its ink overlaps most - a head over the body when it is on
## both - or, touching none, the nearest. Not drawn yet: where that part usually goes.
static func _host_of(e: Array, all: Array, body: Array) -> Array:
	var type: String = e[0]
	var d: Dictionary = e[1]
	var can := []
	for h in all:
		if h != e and h != body and PartCutter._can_carry(h[0], type):
			can.append(h)
	if not d.has("image"):
		var usual: String = PartTypes.info(type).get("host", "body")
		for h in can:
			if h[0] == usual:
				return h
		return body
	var best: Array = body
	var best_n := _ink_overlap(d, body[1])
	for h in can:
		var n := _ink_overlap(d, h[1])
		if n > best_n or (n == best_n and n > 0 and best == body):
			best = h
			best_n = n
	if best_n > 0:
		return best
	# Touching nothing: it hangs from the nearest one (an ear just off the top of the head).
	var gap := _gap(d, body[1])
	for h in can:
		var g := _gap(d, h[1])
		if g < gap:
			best = h
			gap = g
	return best


## How far apart two drawings' boxes are (0 when they overlap).
static func _gap(a: Dictionary, b: Dictionary) -> float:
	var ra := _rect_of(a)
	var rb := _rect_of(b)
	var dx := maxi(0, maxi(ra.position.x - rb.end.x, rb.position.x - ra.end.x))
	var dy := maxi(0, maxi(ra.position.y - rb.end.y, rb.position.y - ra.end.y))
	return Vector2(dx, dy).length()


## How much ink of `a` lies on ink of `b` - sampled, which is plenty to tell a head from a body.
static func _ink_overlap(a: Dictionary, b: Dictionary) -> int:
	if not a.has("image") or not b.has("image"):
		return 0
	var ra := _rect_of(a)
	var rb := _rect_of(b)
	var both := ra.intersection(rb)
	if both.size.x <= 0 or both.size.y <= 0:
		return 0
	var ia: Image = a["image"]
	var ib: Image = b["image"]
	var step := maxi(2, int(sqrt(float(both.get_area()) / 2500.0)))
	var n := 0
	for y in range(both.position.y, both.end.y, step):
		for x in range(both.position.x, both.end.x, step):
			if ia.get_pixel(x - ra.position.x, y - ra.position.y).a > 0.4 \
					and ib.get_pixel(x - rb.position.x, y - rb.position.y).a > 0.4:
				n += 1
	return n


static func _rect_of(d: Dictionary) -> Rect2i:
	if not d.has("image"):
		return Rect2i()
	return Rect2i(Vector2i(d["at"]), (d["image"] as Image).get_size())


func _top_z() -> int:
	var z := 0
	for type in layers:
		for d in layers[type]:
			z = maxi(z, int(d.get("z", 0)))
	return z


func _bottom_z() -> int:
	var z := 0
	for type in layers:
		for d in layers[type]:
			z = mini(z, int(d.get("z", 0)))
	return z


## Every other drawing around the bold one, faint, flattened into what is behind it and what is in
## front - so a tail does not show through the body it is tucked behind.
func _show_others() -> void:
	var order := _stacked()
	var mine := -1
	for i in order.size():
		if order[i][1] == _bold and order[i][0] == active:
			mine = i
	var behind: Image
	var front: Image
	for i in order.size():
		var d: Dictionary = order[i][1]
		if i == mine or not d.has("image"):
			continue
		if mine >= 0 and i > mine:
			front = _stack_on(front, d)
		else:
			behind = _stack_on(behind, d)
	var list := []
	var faint := OTHERS_ALPHA if active != "" else 1.0
	for img in [behind, front]:
		if img != null:
			var alpha := faint
			if img == front and bool(_bold.get("behind", false)):
				alpha = maxf(faint, FRONT_ALPHA_BEHIND)
			list.append({"texture": ImageTexture.create_from_image(img), "pos": Vector2.ZERO,
				"pivot": Vector2.ZERO, "scale": 1.0, "alpha": alpha, "behind": img == behind})
	canvas.set_previews(list)


static func _stack_on(under: Image, d: Dictionary) -> Image:
	if under == null:
		under = Image.create(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	var img: Image = d["image"]
	under.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(d["at"]))
	return under


## What a part is called on its button: "eyes" and "legs", but "head" and "tail" - the ones a
## creature usually has one of.
static func name_of(type: String) -> String:
	if type in ONE_OF:
		return type
	return PartTypes.info(type)["plural"].to_lower()


## Back to front, the way the creature stacks its kinds of part by default (drafts' pictures).
static func stack_order() -> Array:
	var out: Array = PartCutter.BEHIND.duplicate()
	out.append("body")
	for type in PartTypes.ORDER:
		if not out.has(type):
			out.append(type)
	return out


# --- Switching to a faint drawing of the same part ------------------------------------------------

## The bucket said "Tap INSIDE something": was it inside one of this part's other drawings (it
## becomes the bold one and fills), or another part's (say which)?
func _bucket_missed(at: Vector2) -> bool:
	if _switching or active == "":
		return false
	for d in _siblings():
		if _fills(d, at):
			_switch_to(d, at, true)
			return true
	return _whose(at, "colour")


## On another part's ink? Say whose, and how to get to it: "That's its BODY! Tap Body first, then
## colour it." True if it was.
func _whose(at: Vector2, verb: String) -> bool:
	var order := _stacked()
	for i in range(order.size() - 1, -1, -1):
		var type: String = order[i][0]
		var d: Dictionary = order[i][1]
		if type == active or not d.has("image"):
			continue
		if _has_ink(d, at, 0.0):
			var n := name_of(type)
			_say("That's its %s! Tap %s first, then %s it." % [n.to_upper(), n.capitalize(), verb])
			Sounds.play("ui_nope")
			_bounce_tile(type)
			return true
	return false


## The crayon or the eraser went down on one of this part's other drawings (and not on the bold
## one)? Then that one becomes the bold one, and the stroke carries on there - stripes on the first
## leg go on the first leg, not into a new loose "leg". (The crayon only does this once the bold
## drawing has something on it: on a fresh page it is drawing a new one.) The eraser on another
## part says whose it is.
func _press_picks(at: Vector2) -> bool:
	if _switching or active == "" or active == "body":
		return false
	var pen := canvas.tool == DrawCanvas.Tool.PEN
	if pen and canvas.op_count() == 0 and not _in_list:
		return false
	for d in _siblings():
		if _has_ink(d, at, canvas.brush) or (pen and _rect_of(d).has_point(Vector2i(at)) and _fills(d, at)):
			_switch_for_press(at)
			return true
	if not pen and _whose(at, "rub out"):
		return true
	return false


## The active part's drawings other than the bold one, top of the stack first.
func _siblings() -> Array:
	var out := []
	for d in layers.get(active, []):
		if not (_in_list and d == _bold):
			out.append(d)
	out.sort_custom(_higher)
	return out


func _higher(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("z", 0)) > int(b.get("z", 0))


## Would a bucket tap at `at` colour something inside drawing `d` (by its own lines)?
static func _fills(d: Dictionary, at: Vector2) -> bool:
	var img: Image = d["image"]
	var p := Vector2i(at - Vector2(d["at"])) + Vector2i(8, 8)
	var padded := Image.create(img.get_width() + 16, img.get_height() + 16, false, Image.FORMAT_RGBA8)
	if not Rect2i(Vector2i.ZERO, padded.get_size()).has_point(p):
		return false
	var src := img.duplicate() as Image
	src.convert(Image.FORMAT_RGBA8)
	padded.blit_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i(8, 8))
	var walls := DrawCanvas._walls(padded, DrawCanvas.FILL_GAP)
	var r := DrawCanvas.flood(padded, p, DrawCanvas.FILL_GAP, walls)
	if r.get("leaked", false):
		var closed := DrawCanvas.close_around(padded, p, walls)
		if closed == null:
			return false
		r = DrawCanvas.flood(padded, p, DrawCanvas.FILL_GAP, DrawCanvas._walls(closed, DrawCanvas.FILL_GAP))
	return r.has("mask")


## Ink of drawing `d` at `at` or round it (`r` sheet px)?
static func _has_ink(d: Dictionary, at: Vector2, r: float) -> bool:
	var img: Image = d["image"]
	var local := at - Vector2(d["at"])
	for k in 9:
		var p := local if k == 0 else local + Vector2.from_angle(TAU * k / 8.0) * r * 0.5
		var q := Vector2i(p)
		if Rect2i(Vector2i.ZERO, img.get_size()).has_point(q) and img.get_pixelv(q).a > 0.1:
			return true
	return false


## Makes `target` (one of the active part's drawings) the bold one - to the top of the stack - and
## carries on with the bucket.
func _switch_to(target: Dictionary, at: Vector2, fill: bool) -> void:
	_busy = true
	_switching = true
	await _fold()
	_raise(target)
	_open(active)
	if fill:
		await canvas.fill_at(at)
	else:
		canvas.resume_press(at)
	_busy = false
	_switching = false
	on_change.call()


func _switch_for_press(at: Vector2) -> void:
	_busy = true
	_switching = true
	await _fold()
	# Put down, the bold one may have had ink there after all - then it carries on there.
	if not (_in_list and _has_ink(_bold, at, canvas.brush)):
		for d in _siblings():
			if _has_ink(d, at, canvas.brush) or (_rect_of(d).has_point(Vector2i(at)) and _fills(d, at)):
				_raise(d)
				_open(active)
				break
	canvas.resume_press(at)
	_busy = false
	_switching = false
	on_change.call()


## Moves `d` to the end of its part's drawings (the bold one is the last), keeping its place in
## the stack.
func _raise(d: Dictionary) -> void:
	var list: Array = layers.get(active, [])
	for i in list.size():
		if is_same(list[i], d):
			list.remove_at(i)
			list.append(d)
			return


# --- Showing it ----------------------------------------------------------------------------------

## The prompt, the Done button, the row, and the plan's parts: the one being drawn lit up, its
## dots filled as they are drawn, ticks on the ones all drawn, the rest faded until there is a
## body.
func _refresh() -> void:
	_build_strip()
	_refresh_direction()
	_done_button.visible = active != ""
	_update_done()
	var ready := true
	for type in PartTypes.NEEDED:
		if not layers.has(type) and type != active:
			ready = false
	_finish_button.visible = ready
	for type in _tiles:
		var b: Button = _tiles[type]
		var n := _planned(type)
		var have := count_of(type)
		if type == active:
			b.add_theme_stylebox_override("normal", UI._box(UI.HILITE, UI.ACCENT, 5))
		elif have >= n:
			b.add_theme_stylebox_override("normal", UI._box(Color("#eef8e6"), UI.GOOD.darkened(0.3), 3))
		else:
			b.remove_theme_stylebox_override("normal")
		var dots: Dots = _dots[type]
		dots.n = 0 if PartTypes.BUNCH.has(type) else maxi(n, have)
		dots.have = have
		dots.queue_redraw()
		(_ticks[type] as Control).visible = have >= n and type != active
		b.modulate.a = 1.0 if type == "body" or layers.has("body") else 0.45
	_refresh_row()


## What to draw now, [what, how]: the part's own words ("Draw a LEG", "Coming down from the
## body"), or "LEG 2 of 4" - "Draw it - or copy the last one." With no head, the face goes on the
## body.
func _direction_for(type: String) -> Array:
	var n := _planned(type)
	var k := _step_no()
	if n > 1 and k > 1 and k <= n and not _in_list and not PartTypes.BUNCH.has(type):
		return [PartTypes.DRAW_NEXT[0] % [PartTypes.one_name(type).to_upper(), k, n], PartTypes.DRAW_NEXT[1]]
	var d: Array = PartTypes.DRAW[type]
	var tip: String = d[1]
	if _planned("head") == 0 and not layers.has("head"):
		tip = tip.replace("its head", "its body")
	return [d[0], tip]


## Done says what it will do: "Next leg" while there are more to draw, "Done with the legs" on the
## last, and on an empty page "No more legs" (or "Skip the tail" before there is one).
func _update_done() -> void:
	if active == "":
		return
	var blank := not _bold_has_ink() and active != "body"
	if blank and layers.has(active):
		_done_label.text = "No more %s" % PartTypes.info(active)["plural"].to_lower()
	elif blank and not PartTypes.NEEDED.has(active):
		_done_label.text = "Skip this" if active == "other" else "Skip the %s" % name_of(active)
	elif active == "other":
		_done_label.text = "Done with this"
	elif _step_no() < _planned(active) and not _in_list:
		_done_label.text = "Next %s" % PartTypes.one_name(active)
	elif _planned(active) == 1 and not PartTypes.BUNCH.has(active):
		_done_label.text = "Done with the %s" % PartTypes.one_name(active)
	else:
		_done_label.text = "Done with the %s" % name_of(active)


## The row: Copy / In front | Behind, for any part but the body.
func _refresh_row() -> void:
	var show := active != "" and active != "body"
	_copy.visible = show
	_stack_box.visible = show and not ALWAYS_FRONT.has(active)
	if not show:
		return
	var icon := PartTypes.icon(active)
	# What it grows from: a face part's head, a hand's arm, a foot's leg - or the body.
	var host_icon := "part_body"
	var usual: String = PartTypes.info(active).get("host", "body")
	if usual != "body" and layers.has(usual):
		host_icon = PartTypes.icon(usual)
	_dress(_front, "In front", [[host_icon, Vector2(0, 4), 36, 1.0], [icon, Vector2(20, 0), 36, 1.0]])
	_dress(_behind, "Behind", [[icon, Vector2(20, 0), 36, 1.0], [host_icon, Vector2(0, 4), 36, 1.0]])
	var behind := bool(_bold.get("behind", false))
	_lit(_front, not behind)
	_lit(_behind, behind)
	_update_row()


## The half of In front | Behind that the drawing is on now, lit like a picked part.
func _lit(b: Button, on: bool) -> void:
	if on:
		b.add_theme_stylebox_override("normal", UI._box(UI.HILITE, UI.ACCENT, 4))
		b.add_theme_stylebox_override("hover", UI._box(UI.HILITE, UI.ACCENT, 4))
	else:
		b.remove_theme_stylebox_override("normal")
		b.remove_theme_stylebox_override("hover")


## Copy: "Copy this leg" once it has ink, "Copy the last leg" on a fresh page after one - lit when
## there is something to copy; a faded one still answers a tap ("Draw one first!").
func _update_row() -> void:
	_update_done()
	if active == "" or active == "body":
		return
	var one := PartTypes.one_name(active)
	var icon := PartTypes.icon(active)
	var mine := _bold_has_ink()
	var text := "Copy this %s" % one if mine or not layers.has(active) else "Copy the last %s" % one
	if _copy.get_meta("text", "") != text:
		_copy.set_meta("text", text)
		_dress(_copy, text, [[icon, Vector2(0, 0), 36, 0.55], [icon, Vector2(22, 4), 36, 1.0]])
	_copy.modulate.a = 1.0 if mine or layers.has(active) else 0.45
	if mine and not _row_bounced and not ONE_OF.has(active) and _step_no() < _planned(active):
		_row_bounced = true
		_bounce(_copy)


func _row_button(on_press: Callable, width: float) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(width, 76)
	b.pressed.connect(on_press)
	return b


## A row button's picture (some part pictures laid over each other: [icon, at, px, alpha]) and
## its words underneath.
func _dress(b: Button, text: String, pics: Array) -> void:
	for c in b.get_children():
		c.queue_free()
	var w := b.custom_minimum_size.x
	var art := Control.new()
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.position = Vector2((w - 58.0) / 2.0, 2)
	art.size = Vector2(58, 40)
	b.add_child(art)
	for p in pics:
		var pic := UI.icon(p[0], float(p[2]), "none")
		pic.position = p[1]
		pic.size = Vector2(p[2], p[2])
		pic.modulate.a = float(p[3])
		art.add_child(pic)
	var l := UI.label(text, 16, true)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_constant_override("line_spacing", -4)
	l.max_lines_visible = 2
	l.clip_text = true
	l.position = Vector2(2, 42)
	l.size = Vector2(w - 4.0, 32)
	b.add_child(l)


func _on_edited() -> void:
	if _opening:
		return
	if _said != "" and not _switching:
		_say("")
	_update_row()


## Let go of the copy: the hand has done its job; "Drag it where it goes!" stays while it can
## still slide.
func _on_copy_dropped() -> void:
	_dismiss_how()


## The copy can't slide any more (the kid drew somewhere else): back to what this part is for.
func _on_moving_ended() -> void:
	_dismiss_how()
	if active != "":
		_refresh_direction()


func _nope(text: String) -> void:
	Sounds.play("ui_nope")
	_say(text)


func _bounce(b: Control, by := 1.15) -> void:
	b.pivot_offset = b.size / 2.0
	var t := b.create_tween()
	t.tween_property(b, "scale", Vector2(by, by), 0.12)
	t.tween_property(b, "scale", Vector2.ONE, 0.12)


## The game's own words take the prompt's place for a while: one sentence at a time.
func _say(text: String) -> void:
	_said = text
	_show_tip()


## The first few copies: the hand slides the copy along, to show it can be.
func _show_how_drag() -> void:
	_dismiss_how()
	if profile == null or not HowTo.first_times(profile, "howto_copy_drag", HOW_COPIES):
		return
	_how = HowTo.new()
	_how.gesture = "drag"
	_how.at = _copy_point.bind(Vector2.ZERO)
	_how.to = _copy_point.bind(Vector2(110, 0))
	_how.period = 1.4
	_how.until_touch = true
	add_child(_how)


## The middle of the copy being slid (and `off` from it), in this screen's space.
func _copy_point(off: Vector2) -> Vector2:
	var r := canvas.loaded_rect()
	var g := canvas.sheet_to_global(r.get_center()) + off
	return get_global_transform().affine_inverse() * g


func _dismiss_how() -> void:
	if _how != null and is_instance_valid(_how):
		_how.dismiss()
	_how = null


## For the caller's draft: the drawing being drawn, put down - after anything already putting
## it down (the app going to the background mid-tap).
func state() -> void:
	while _busy:
		await get_tree().process_frame
	_busy = true
	await _fold()
	_busy = false


## Android's back gesture, while a part is showing off: carry on; over "Anything else?": back to
## the drawing.
func skip_preview() -> bool:
	if _more != null and is_instance_valid(_more):
		close_more()
		return true
	for c in get_children():
		if c is PartPreview and not c.is_queued_for_deletion():
			(c as PartPreview).skip()
			return true
	return false


# --- Tools -----------------------------------------------------------------------------------

func _stop() -> void:
	on_stop.call()


## Picking the crayon or the hand keeps a copy slidable (both slide it); any other tool ends that.
func _set_tool(t: DrawCanvas.Tool) -> void:
	canvas.tool = t
	if canvas.moving and t != DrawCanvas.Tool.PEN and t != DrawCanvas.Tool.HAND:
		canvas.moving = false
		_on_moving_ended()


func _select_tool(t: DrawCanvas.Tool) -> void:
	canvas.tool = t
	_tool_buttons[t].button_pressed = true


func _set_brush(px: float) -> void:
	canvas.brush = px


## Undo takes back the last stroke - and, once a new drawing or copy has nothing left to take
## back, the new drawing itself, back to the one before.
func _undo() -> void:
	if _busy:
		return
	if canvas.can_undo():
		canvas.undo()
		canvas.moving = _copying and not canvas.can_undo()
		return
	if _fresh and active != "" and active != "body":
		if _in_list:
			var list: Array = layers.get(active, [])
			list.pop_back()
			if list.is_empty():
				layers.erase(active)
		Sounds.play("undo")
		_open(active)
		on_change.call()


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


## A tool: its picture, and its word under it if it has one.
func _picture_button(icon: String, on_press: Callable, group: ButtonGroup = null,
		min_size := Vector2(64, 56), words := "") -> Button:
	var b := Button.new()
	b.custom_minimum_size = min_size
	if group != null:
		b.toggle_mode = true
		b.button_group = group
	b.pressed.connect(on_press)
	if icon != "":
		var px := 42.0 if words == "" else 44.0
		var pic := UI.icon(icon, px)
		pic.position = Vector2((min_size.x - px) / 2.0, (min_size.y - px) / 2.0 if words == "" else 3.0)
		b.add_child(pic)
	if words != "":
		b.add_child(_words(words, 16))
	return b


func _swatch(c: Color, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = Vector2(42, 42)
	var light := c.get_luminance() > 0.8
	for state_name in ["normal", "hover"]:
		b.add_theme_stylebox_override(state_name, UI._box(c, UI.INK_SOFT if light else c.darkened(0.25), 3, 21, 4))
	for state_name in ["pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(state_name, UI._box(c, UI.ACCENT, 7, 21, 4))
	b.button_pressed = c == UI.PALETTE[0]
	b.pressed.connect(_pick_colour.bind(c, ""))
	return b


## A shiny marker: draws in gold, rainbow or glitter. Used up when the pet is finished.
func _marker_swatch(mode: String, n: int, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = Vector2(42, 42)
	b.tooltip_text = "%s marker (%d left)" % [mode.capitalize(), n]
	var pic := UI.icon(Items.MARKERS[mode][0], 38)
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
		_select_tool(DrawCanvas.Tool.PEN)
