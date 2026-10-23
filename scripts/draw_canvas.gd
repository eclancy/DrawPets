class_name DrawCanvas
extends Control
## One sheet of paper a kid draws one thing on: a whole creature, part by part (CreatureSheet),
## or a favourite food, a toy, a hat (DrawScreen).
##
## The sheet is `sheet_size` pixels (512 square unless set before it enters the tree) whatever
## size it shows at, and it can be looked at closer: pinch or the mouse wheel to zoom, two fingers
## (or the hand tool, or a right-drag) to slide it about. Every stroke and fill is its own node
## inside a SubViewport, back to front, so undo is "delete the last node" and the drawing is
## never flattened until it is finished. Then it is cropped to its ink and becomes the part.
##
## On a creature sheet the rest of the creature shows around the part being drawn
## (set_previews), but it is never part of this drawing - and the bucket never sees it: a wing
## drawn over the body fills right across the body's outline, the way the kid sees it.
##
## Nothing here smooths, straightens or tidies a stroke. Wobbly is the point.

signal message(text: String)
## While `placing`, a tap on the sheet does not draw: it just says where (sheet pixels).
signal tapped(at: Vector2)
## Anything at all changed on the page (a stroke, a fill, an undo, a copy slid along).
signal edited
## A copy being put in place (`moving`) was let go of.
signal copy_dropped
## The copy can no longer slide: the kid drew somewhere else.
signal moving_ended

const SHEET := PartTypes.SHEET

enum Tool { PEN, FILL, ERASER, HAND }

const MIN_ZOOM := 1.0
const MAX_ZOOM := 5.0

## Wipes to transparent: a canvas_item that writes alpha 0 instead of blending.
const ERASE_SHADER := "
shader_type canvas_item;
render_mode blend_disabled;
void fragment() { COLOR = vec4(0.0); }
"

## Paints a flood-fill mask. The mask is grown back out by `grow` pixels (the fill stopped
## that far short of the lines so it could jump small gaps) but never over solid ink, so the
## kid's lines stay on top of their colouring.
const FILL_SHADER := "
shader_type canvas_item;
uniform vec4 fill_color : source_color = vec4(1.0);
uniform sampler2D ink : filter_nearest;
uniform bool protect_ink = true;
uniform int grow = 3;
void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	float m = 0.0;
	for (int y = -grow; y <= grow; y++) {
		for (int x = -grow; x <= grow; x++) {
			if (x * x + y * y <= grow * grow) {
				m = max(m, texture(TEXTURE, UV + vec2(float(x), float(y)) * px).r);
			}
		}
	}
	if (protect_ink) {
		m *= 1.0 - smoothstep(0.55, 0.85, texture(ink, UV).a);
	}
	COLOR = vec4(fill_color.rgb, fill_color.a * m);
}
"

## The same as FILL_SHADER, for the shine mask: where a fill in an ordinary colour lands, it
## takes the shine away underneath (multiplies the mask by 1 - fill).
const UNFILL_SHADER := "
shader_type canvas_item;
render_mode blend_mul;
uniform sampler2D ink : filter_nearest;
uniform bool protect_ink = true;
uniform int grow = 3;
void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	float m = 0.0;
	for (int y = -grow; y <= grow; y++) {
		for (int x = -grow; x <= grow; x++) {
			if (x * x + y * y <= grow * grow) {
				m = max(m, texture(TEXTURE, UV + vec2(float(x), float(y)) * px).r);
			}
		}
	}
	if (protect_ink) {
		m *= 1.0 - smoothstep(0.55, 0.85, texture(ink, UV).a);
	}
	COLOR = vec4(1.0 - m);
}
"

## How wide a gap in an outline the bucket will jump. Thumbs on glass leave gaps.
const FILL_GAP := 4
## How many ways the bucket looks out from a tap for the lines of an open shape (close_around).
const RAYS := 48

var tool := Tool.PEN
## The sheet's size in pixels. Set before it enters the tree.
var sheet_size := Vector2i(SHEET, SHEET)
## How much closer than "the whole sheet fits" it is being looked at.
var zoom := 1.0
var color: Color = UI.PALETTE[0]
var brush := 12.0
## The drawing's middle: finish() gives it back in the cropped drawing's pixels, as its pivot.
var dot := Vector2(256, 256)
## "" for ordinary crayon, or a Shiny mode while a shiny marker is in hand.
var shine := ""

var _viewport: SubViewport
var _ops: Node2D
var _sheet: Control
var placing := false
## A fresh copy of a drawing (a second leg) is on the page by itself: a crayon (or hand) press on
## its ink slides it about instead of drawing, until the kid draws somewhere else or picks a tool
## that is not for sliding. A dashed line goes round it meanwhile.
var moving := false:
	set(on):
		moving = on
		if _frame != null:
			_frame.queue_redraw()
## Asked when the bucket would say "Tap INSIDE something you drew": `on_miss.call(at)` true means
## the caller dealt with it (the tap was inside another of this part's drawings, say).
var on_miss := Callable()
## Asked when the crayon or the eraser goes down: `chooser.call(at)` true means the caller is
## switching to the drawing under it and will call `resume_press(at)` once it has.
var chooser := Callable()
var _dragging := false
var _loaded_size := Vector2.ZERO
var _loaded_image: Image
## Where the copy being slid really is: it only ever sits on whole pixels, so a slide never blurs
## the kid's lines, but the slide itself is followed exactly.
var _slide_at := Vector2.ZERO
var _left_down := false
var _frame: MoveFrame
var _ink: TextureRect
var _previews_behind: PreviewLayer
var _previews_front: PreviewLayer
var _stroke: Line2D
var _busy := false
var _erase_material: ShaderMaterial
var _fill_shader: Shader
var _unfill_shader: Shader
## The shine mask: every op has a twin here, white where it was drawn with a shiny marker and
## wiping the mask where it was not. Only the strokes made with a shiny marker end up shining.
var _mask_viewport: SubViewport
var _mask_ops: Node2D
var _shine_mode := ""
## The crayon (or eraser) scratching while a finger is down, and how fast it is moving.
var _scratch := -1
var _scratch_speed := 0.0
## The shiny marker drawn with on this sheet, if any - the one that gets used up.
var used_marker := ""
## Ops at the bottom that undo never removes: a drawing loaded to be fixed.
var _base_ops := 0
## Looking round the sheet: the scale at zoom 1, and the fingers on it (index -> where).
var _fit_scale := 1.0
var _touches := {}
var _gesture := false
var _pinch_dist := 0.0
var _pinch_mid := Vector2.ZERO
var _panning := false
var _fill_at := Vector2(-1, -1)
## Counts every change, so a caller can tell whether anything was drawn since it last looked.
var _edits := 0
var _seen_edits := 0


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	_viewport = SubViewport.new()
	_viewport.size = sheet_size
	_viewport.transparent_bg = true
	_viewport.disable_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_viewport)
	_ops = Node2D.new()
	_viewport.add_child(_ops)
	_mask_viewport = SubViewport.new()
	_mask_viewport.size = sheet_size
	_mask_viewport.transparent_bg = true
	_mask_viewport.disable_3d = true
	_mask_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_mask_viewport)
	_mask_ops = Node2D.new()
	_mask_viewport.add_child(_mask_ops)

	var sheet := Vector2(sheet_size)
	_sheet = Control.new()
	_sheet.size = sheet
	_sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Smooth when looked at closely, not blocky.
	_sheet.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_sheet)

	_previews_behind = PreviewLayer.new()
	_previews_behind.size = sheet
	_previews_behind.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_previews_behind)

	_ink = TextureRect.new()
	_ink.texture = _viewport.get_texture()
	_ink.size = sheet
	_ink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_ink)

	_previews_front = PreviewLayer.new()
	_previews_front.size = sheet
	_previews_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_previews_front)

	_frame = MoveFrame.new()
	_frame.canvas = self
	_frame.size = sheet
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_frame)

	_erase_material = ShaderMaterial.new()
	var erase := Shader.new()
	erase.code = ERASE_SHADER
	_erase_material.shader = erase
	_fill_shader = Shader.new()
	_fill_shader.code = FILL_SHADER
	_unfill_shader = Shader.new()
	_unfill_shader.code = UNFILL_SHADER

	resized.connect(_fit)
	_fit()


func _fit() -> void:
	var sheet := Vector2(sheet_size)
	_fit_scale = minf(size.x / sheet.x, size.y / sheet.y)
	_apply_view(size / 2.0 - sheet * _fit_scale * zoom / 2.0 if zoom == 1.0 else _sheet.position)


## Puts the sheet at `top_left` (local pixels) at the current zoom - kept so it never slides off:
## centred while it fits, and its edges never inside the view once it is bigger.
func _apply_view(top_left: Vector2) -> void:
	var k := _fit_scale * zoom
	var shown := Vector2(sheet_size) * k
	var p := top_left
	for axis in 2:
		if shown[axis] <= size[axis]:
			p[axis] = (size[axis] - shown[axis]) / 2.0
		else:
			p[axis] = clampf(p[axis], size[axis] - shown[axis], 0.0)
	_sheet.scale = Vector2(k, k)
	_sheet.position = p
	queue_redraw()


## Closer (factor > 1) or further, keeping the spot under `around` (local pixels) where it is.
func zoom_at(factor: float, around: Vector2) -> void:
	var at := _to_sheet(around)
	zoom = clampf(zoom * factor, MIN_ZOOM, MAX_ZOOM)
	_apply_view(around - at * _fit_scale * zoom)


func zoom_in() -> void:
	zoom_at(1.5, size / 2.0)


func zoom_out() -> void:
	zoom_at(1.0 / 1.5, size / 2.0)


## The whole sheet again.
func reset_view() -> void:
	zoom = 1.0
	_fit()


func pan_by(delta: Vector2) -> void:
	_apply_view(_sheet.position + delta)


func _draw() -> void:
	# A little darker round the sheet, so its edges show when it is not filling the view.
	draw_rect(Rect2(Vector2.ZERO, size), UI.PAPER.darkened(0.04))
	var r := Rect2(_sheet.position, Vector2(sheet_size) * _sheet.scale.x)
	draw_rect(Rect2(r.position + Vector2(4, 6), r.size), Color(0.23, 0.21, 0.4, 0.12))
	draw_rect(r, Color("#fffdf6"))
	draw_rect(Rect2(Vector2.ZERO, size), UI.INK, false, 3.0)


## Shows other drawings on the sheet - the rest of the creature, around the part being drawn.
## Each is {texture, pos (sheet px of its pivot), pivot, scale, flip, behind (under this drawing
## rather than over it), alpha}. Not part of the drawing; they just show what it will look like.
func set_previews(list: Array) -> void:
	_previews_behind.items = []
	_previews_front.items = []
	for p in list:
		(_previews_behind if p.get("behind", false) else _previews_front).items.append(p)
	_previews_behind.queue_redraw()
	_previews_front.queue_redraw()


## Starts the sheet empty again - the next part of the creature. Undo starts afresh.
func restart() -> void:
	for n in _ops.get_children():
		_ops.remove_child(n)
		n.queue_free()
	for n in _mask_ops.get_children():
		_mask_ops.remove_child(n)
		n.queue_free()
	_base_ops = 0
	_stroke = null
	_shine_mode = ""
	_ink.material = null
	used_marker = ""
	moving = false
	_dragging = false
	_loaded_size = Vector2.ZERO
	_loaded_image = null
	_changed()


func set_dot(at: Vector2) -> void:
	dot = at


# --- Input -----------------------------------------------------------------------------------
# Mouse events only: on a phone, Godot turns the first finger into the mouse, which is all one
# drawing finger needs. Pinch and two-finger tricks will read InputEventScreenTouch directly.

func _gui_input(event: InputEvent) -> void:
	if _busy:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_at(1.15, event.position)
			accept_event()
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_at(1.0 / 1.15, event.position)
			accept_event()
			return
		if event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			_panning = event.pressed
			accept_event()
			return
	if _gesture:
		# Two fingers are zooming or sliding the page; the mouse a phone makes of the first one
		# must not draw meanwhile.
		accept_event()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var at := _to_sheet(event.position)
		if placing:
			if event.pressed:
				tapped.emit(at.clamp(Vector2.ZERO, Vector2(sheet_size)))
			accept_event()
			return
		_left_down = event.pressed
		if event.pressed:
			if moving and (tool == Tool.PEN or tool == Tool.HAND):
				if _grab(at):
					accept_event()
					return
				if tool == Tool.PEN:
					# Drawing somewhere else: the copy stays where it is.
					moving = false
					moving_ended.emit()
			if tool == Tool.HAND:
				_panning = true
			else:
				_press(at)
			if _stroke != null:
				_scratch = Sounds.loop_start("eraser" if tool == Tool.ERASER else "crayon", -40.0)
		else:
			if _dragging:
				_drop()
			_panning = false
			_stroke = null
			_stop_scratch()
			# The bucket pours when the finger lifts - so a pinch that starts with this finger
			# never colours anything.
			if _fill_at.x >= 0.0:
				var spot := _fill_at
				_fill_at = Vector2(-1, -1)
				fill_at(spot)
		accept_event()
	elif event is InputEventMouseMotion:
		if _dragging:
			_drag_by(event.relative / _sheet.scale.x)
			accept_event()
		elif _panning:
			pan_by(event.relative)
			accept_event()
		elif _stroke != null:
			_extend(_to_sheet(event.position))
			_scratch_speed = maxf(_scratch_speed, event.velocity.length())
			accept_event()


## Two fingers: pinch to zoom, slide to move the page. Read straight from the touches (the mouse
## Godot makes from a finger only knows about one). A stroke the first finger had just begun is
## taken back - it was the start of a pinch, not a line.
func _input(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag) or not is_visible_in_tree():
		return
	var local: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
	if event is InputEventScreenTouch:
		if event.pressed:
			if not Rect2(Vector2.ZERO, size).has_point(local):
				return
			_touches[event.index] = local
			if _touches.size() == 2 and not _gesture:
				_gesture = true
				_dragging = false
				_take_back_stroke()
				_fill_at = Vector2(-1, -1)
				_start_pinch()
		else:
			_touches.erase(event.index)
			if _touches.size() == 1 and _gesture:
				_start_pinch()
			if _touches.is_empty():
				_gesture = false
	elif _touches.has(event.index):
		_touches[event.index] = local
		if _gesture and _touches.size() >= 2:
			var pts: Array = _touches.values()
			var mid: Vector2 = (pts[0] + pts[1]) / 2.0
			var dist: float = (pts[0] as Vector2).distance_to(pts[1])
			if _pinch_dist > 1.0 and dist > 1.0:
				zoom_at(dist / _pinch_dist, mid)
			pan_by(mid - _pinch_mid)
			_pinch_dist = dist
			_pinch_mid = mid


func _start_pinch() -> void:
	var pts: Array = _touches.values()
	if pts.size() >= 2:
		_pinch_mid = (pts[0] + pts[1]) / 2.0
		_pinch_dist = (pts[0] as Vector2).distance_to(pts[1])
	else:
		_pinch_dist = 0.0


## Takes back the stroke in progress, quietly (it was a pinch starting).
func _take_back_stroke() -> void:
	if _stroke == null:
		return
	var twin: Node = _stroke.get_meta("twin")
	_ops.remove_child(_stroke)
	_stroke.queue_free()
	_mask_ops.remove_child(twin)
	twin.queue_free()
	_stroke = null
	_stop_scratch()
	_changed()


## The scratching follows the stroke: loud while the crayon moves fast, quiet while it rests.
func _process(delta: float) -> void:
	if _scratch < 0:
		return
	var v := clampf(_scratch_speed / 900.0, 0.0, 1.0)
	Sounds.loop_set(_scratch, lerpf(-34.0, 0.0, sqrt(v)), 0.85 + 0.35 * v)
	_scratch_speed = move_toward(_scratch_speed, 0.0, delta * 4000.0)


func _stop_scratch() -> void:
	if _scratch >= 0:
		Sounds.loop_stop(_scratch)
		_scratch = -1


func _exit_tree() -> void:
	_stop_scratch()


func _to_sheet(local: Vector2) -> Vector2:
	return (local - _sheet.position) / _sheet.scale.x


func _press(at: Vector2) -> void:
	match tool:
		Tool.PEN, Tool.ERASER:
			if chooser.is_valid() and chooser.call(at):
				return
			begin_stroke(at)
		Tool.FILL:
			_fill_at = at


# --- Drawing operations ----------------------------------------------------------------------
# Public so the scripted demo (DemoKid) draws through exactly the same code a finger does.

func begin_stroke(at: Vector2) -> void:
	var line := Line2D.new()
	var erasing := tool == Tool.ERASER
	line.width = brush * (2.0 if erasing else 1.0)
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.antialiased = not erasing
	if erasing:
		line.material = _erase_material
	# A second point a hair away, so a single tap still leaves a round dot.
	line.add_point(at)
	line.add_point(at + Vector2(0.5, 0.0))
	var twin := line.duplicate() as Line2D
	if shine != "" and not erasing:
		twin.default_color = Color.WHITE
		twin.antialiased = true
		_use_shine()
		used_marker = shine
	else:
		twin.material = _erase_material
		twin.antialiased = false
	_add_op(line, twin)
	_stroke = line
	_changed()


func _add_op(node: Node2D, twin: Node2D) -> void:
	node.set_meta("twin", twin)
	_ops.add_child(node)
	_mask_ops.add_child(twin)


## Turns on the live shine the first time a shiny marker touches the page.
func _use_shine() -> void:
	if _shine_mode == shine:
		return
	_shine_mode = shine
	_ink.material = Shiny.material(shine, _mask_viewport.get_texture())


func _extend(at: Vector2) -> void:
	var last := _stroke.get_point_position(_stroke.get_point_count() - 1)
	if at.distance_to(last) < 1.5:
		return
	var twin: Line2D = _stroke.get_meta("twin")
	if _stroke.get_point_count() == 2 and _stroke.get_point_position(0).distance_to(last) < 1.0:
		_stroke.set_point_position(1, at)
		twin.set_point_position(1, at)
	else:
		_stroke.add_point(at)
		twin.add_point(at)
	_changed()


## Draws a whole stroke at once (the demo, and anything else that is not a finger).
func add_stroke(points: PackedVector2Array) -> void:
	if points.is_empty():
		return
	begin_stroke(points[0])
	for i in range(1, points.size()):
		_extend(points[i])
	_stroke = null


func fill_at(at: Vector2) -> void:
	var start := Vector2i(at.floor())
	if start.x < 0 or start.y < 0 or start.x >= sheet_size.x or start.y >= sheet_size.y:
		return
	_busy = true
	var sheet_image := await snapshot()
	var t0 := Time.get_ticks_usec()
	var blockers: Image = null
	var walls := _walls(sheet_image, FILL_GAP)
	var result := flood(sheet_image, start, FILL_GAP, walls)
	if result.get("leaked", false):
		# An open shape - a C, a leg drawn as a U - would let the colour out over the whole page.
		# Close it off where the kid would have, and fill inside that.
		blockers = close_around(sheet_image, start, walls)
		if blockers != null:
			result = flood(sheet_image, start, FILL_GAP, _walls(blockers, FILL_GAP))
	# Read off a phone with `adb logcat -s godot` - the bucket is GDScript, the slow case on a
	# cheap tablet (.ai/android.md).
	print("[timing] fill %d ms" % ((Time.get_ticks_usec() - t0) / 1000))
	_busy = false
	if result.get("leaked", false):
		if on_miss.is_valid() and on_miss.call(at):
			return
		message.emit("Tap INSIDE something you drew to colour it in!")
		Sounds.play("ui_nope")
		return
	if not result.has("mask"):
		return
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = ImageTexture.create_from_image(result["mask"])
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var mat := ShaderMaterial.new()
	mat.shader = _fill_shader
	mat.set_shader_parameter("fill_color", color)
	# Paper fills keep off the closing edge as well as the ink, so the colour stops there.
	mat.set_shader_parameter("ink", ImageTexture.create_from_image(
		blockers if blockers != null and result["empty"] else sheet_image))
	mat.set_shader_parameter("protect_ink", result["empty"])
	mat.set_shader_parameter("grow", result["grow"])
	sprite.material = mat
	var twin := sprite.duplicate() as Sprite2D
	var twin_mat := mat.duplicate() as ShaderMaterial
	if shine != "":
		twin_mat.set_shader_parameter("fill_color", Color.WHITE)
		_use_shine()
		used_marker = shine
	else:
		twin_mat.shader = _unfill_shader
	twin.material = twin_mat
	Sounds.play_varied("fill", 1.0, 0.08)
	_add_op(sprite, twin)
	_changed()


## Starts from an existing drawing - fixing a part - with its top-left at `at` on the sheet.
## It can be drawn on, filled and rubbed out like anything drawn here, but undo stops at it.
func load_drawing(img: Image, at: Vector2, shine_mask: Image = null, shine_mode := "") -> void:
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.position = at
	sprite.texture = ImageTexture.create_from_image(img)
	var twin := Sprite2D.new()
	twin.centered = false
	twin.position = at
	if shine_mask != null and shine_mode != "":
		twin.texture = ImageTexture.create_from_image(shine_mask)
		shine = shine_mode
		_use_shine()
		shine = ""
	_add_op(sprite, twin)
	_base_ops = _ops.get_child_count()
	_loaded_size = Vector2(img.get_size())
	_loaded_image = img
	_changed()


# --- Sliding a copy into place -----------------------------------------------------------------

## Starts sliding the copy, if `at` is on its ink - or a fingertip from it, the same on screen at
## any zoom (the page is just the copy, untouched).
func _grab(at: Vector2) -> bool:
	if _base_ops != 1 or _ops.get_child_count() != 1 or _loaded_image == null:
		return false
	var op: Node2D = _ops.get_child(0)
	var local := at - op.position
	var r := 20.0 / _sheet.scale.x
	var hit := false
	for k in 9:
		var q := Vector2i(local + (Vector2.ZERO if k == 0 else Vector2.from_angle(TAU * k / 8.0) * r))
		if Rect2i(Vector2i.ZERO, _loaded_image.get_size()).has_point(q) and _loaded_image.get_pixelv(q).a > 0.1:
			hit = true
			break
	if not hit:
		return false
	_dragging = true
	_slide_at = op.position
	Sounds.play("pickup")
	return true


## Slides the copy by `by` (sheet px), kept on the page. Relative, so it never jumps under the
## finger, at any zoom.
func _drag_by(by: Vector2) -> void:
	if _ops.get_child_count() == 0:
		return
	var op: Node2D = _ops.get_child(0)
	var twin: Node2D = op.get_meta("twin")
	_slide_at = (_slide_at + by).clamp(Vector2.ZERO, (Vector2(sheet_size) - _loaded_size).max(Vector2.ZERO))
	op.position = _slide_at.round()
	twin.position = op.position
	_frame.queue_redraw()
	_changed()


func _drop() -> void:
	_dragging = false
	Sounds.play("place")
	copy_dropped.emit()


## The demo slides a copy as a finger would: pressed at `from`, let go at `to` (sheet px).
func drag_copy(from: Vector2, to: Vector2) -> void:
	if _grab(from):
		_drag_by(to - from)
		_drop()


## Where the loaded drawing (a copy being slid) is now, in sheet px.
func loaded_rect() -> Rect2:
	if _base_ops < 1 or _ops.get_child_count() == 0:
		return Rect2()
	return Rect2((_ops.get_child(0) as Node2D).position, _loaded_size)


## A point on the sheet, in global (screen) space - for a hint's hand to point at. Kept inside the
## view, so a hand never points off the page.
func sheet_to_global(p: Vector2) -> Vector2:
	var local := (_sheet.position + p * _sheet.scale.x).clamp(Vector2(24, 24), size - Vector2(24, 24))
	return get_global_transform() * local


## Slides the page so that `p` (sheet px) is in view - in the middle, if it was not.
func bring_into_view(p: Vector2) -> void:
	var on_screen := _sheet.position + p * _sheet.scale.x
	if Rect2(Vector2.ZERO, size).grow(-60.0).has_point(on_screen):
		return
	_apply_view(size / 2.0 - p * _sheet.scale.x)


## Something drawn on top of what was loaded, to take back.
func can_undo() -> bool:
	return _ops.get_child_count() > _base_ops


## How many strokes, fills and wipes are on the page (a loaded drawing counts as one).
func op_count() -> int:
	return _ops.get_child_count()


## After the caller switched drawings for an eraser press (`chooser`): carries the press on, if
## the finger is still down.
func resume_press(at: Vector2) -> void:
	if not _left_down or _gesture:
		return
	begin_stroke(at)
	if _stroke != null:
		_scratch = Sounds.loop_start("eraser" if tool == Tool.ERASER else "crayon", -40.0)


func undo() -> void:
	if _ops.get_child_count() <= _base_ops:
		return
	Sounds.play("undo")
	var last := _ops.get_child(_ops.get_child_count() - 1)
	var twin: Node = last.get_meta("twin")
	_ops.remove_child(last)
	last.queue_free()
	_mask_ops.remove_child(twin)
	twin.queue_free()
	_stroke = null
	_changed()


## Wipes the sheet - as one more undoable step, so a mis-tap on Clear is never a disaster.
func clear() -> void:
	Sounds.play("clear")
	var wipe := Polygon2D.new()
	var s := Vector2(sheet_size)
	wipe.polygon = PackedVector2Array([Vector2.ZERO, Vector2(s.x, 0), s, Vector2(0, s.y)])
	wipe.material = _erase_material
	_add_op(wipe, wipe.duplicate())
	_changed()


func _changed() -> void:
	_edits += 1
	edited.emit()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_mask_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


## Whether anything was drawn, filled, rubbed out or undone since mark_loaded.
func changed_since_load() -> bool:
	return _edits != _seen_edits


## What is on the page now is what the caller has kept.
func mark_loaded() -> void:
	_seen_edits = _edits


## The drawing as it stands, full sheet, transparent where nothing is drawn.
func snapshot() -> Image:
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_mask_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	return _viewport.get_texture().get_image()


## The whole sheet as drawn, not cropped - {image, shine: {mode, mask} or {}, used_marker} - for
## a creature, whose parts keep their place on the one sheet. Empty when nothing is drawn.
func snapshot_full() -> Dictionary:
	var img := await snapshot()
	if img.get_used_rect().size.x < 2:
		return {}
	var out := img.duplicate() as Image
	Crayon.unpremultiply(out)
	var result := {"image": out, "shine": {}, "used_marker": used_marker}
	if _shine_mode != "":
		var mask := _mask_viewport.get_texture().get_image()
		if mask.get_used_rect().size.x > 0:
			result["shine"] = {"mode": _shine_mode, "mask": mask}
	return result


## The finished drawing cropped to its ink, and the dot in the cropped image's pixels - plus
## {mode, mask} under "shine" when some of it was drawn with a shiny marker. Empty when
## nothing was drawn.
func finish() -> Dictionary:
	var img := await snapshot()
	var used := img.get_used_rect()
	if used.size.x < 2 or used.size.y < 2:
		return {}
	var cropped := img.get_region(used)
	Crayon.unpremultiply(cropped)
	var result := {"image": cropped, "pivot": dot - Vector2(used.position), "shine": {},
		"used_marker": used_marker}
	if _shine_mode != "":
		var mask := _mask_viewport.get_texture().get_image().get_region(used)
		if mask.get_used_rect().size.x > 0:
			result["shine"] = {"mode": _shine_mode, "mask": mask}
	return result


# --- Flood fill ------------------------------------------------------------------------------

## For a tap in an open shape that would colour the whole page - a C, a leg drawn as a U, two
## lines side by side: the drawing with that shape closed off by a straight edge across its
## opening (the convex hull of its lines), so the colour stops there as if the kid had drawn the
## edge. The shape is the open lines first met looking out from the tap - the nearest ones and
## any about as near - and they must go at least about halfway round it. Things that are closed
## already (an eye, a wheel) are things, not the walls of a shape: a tap between two eyes does not
## colour the space between them. Null when the tap is not inside an open shape at all - beside a
## line, between two things, or on empty paper.
static func close_around(img: Image, start: Vector2i, walls := PackedByteArray()) -> Image:
	var w := img.get_width()
	var h := img.get_height()
	var ink := walls if not walls.is_empty() else _walls(img, FILL_GAP)
	if ink[start.y * w + start.x] != 0:
		ink = _walls(img, 0)
		if ink[start.y * w + start.x] != 0:
			return null
	# Look out from the tap every way for the first line each way.
	var hits := []
	var nearest := INF
	for k in RAYS:
		var dir := Vector2.from_angle(TAU * k / RAYS)
		var p := Vector2(start) + Vector2(0.5, 0.5)
		var d := 0.0
		while true:
			p += dir
			d += 1.0
			var x := int(p.x)
			var y := int(p.y)
			if x < 0 or y < 0 or x >= w or y >= h:
				break
			if ink[y * w + x] != 0:
				hits.append([y * w + x, d])
				nearest = minf(nearest, d)
				break
	var reach := maxf(nearest * 2.5, nearest + 40.0)
	# Each line met, followed all the way round and numbered; the closed ones put aside.
	var label := PackedByteArray()
	label.resize(w * h)
	var boxes := {}
	var open := {}
	for hit in hits:
		var at: int = hit[0]
		if float(hit[1]) > reach or label[at] != 0 or boxes.size() >= 250:
			continue
		var id := boxes.size() + 1
		boxes[id] = _follow_line(ink, label, at, id, w, h)
		open[id] = not _is_closed(label, boxes[id], id, w)
	# The open lines must go at least about halfway round the tap.
	var round_it := 0
	for hit in hits:
		if float(hit[1]) <= reach and open.get(int(label[int(hit[0])]), false):
			round_it += 1
	if round_it < int(RAYS * 0.45):
		return null
	# Their outermost points, row by row, make the shape's hull.
	var points := PackedVector2Array()
	for id in boxes:
		if not open[id]:
			continue
		var box: Rect2i = boxes[id]
		for y in range(box.position.y, box.end.y):
			var row := y * w
			var lo := -1
			var hi := -1
			for x in range(box.position.x, box.end.x):
				if label[row + x] == id:
					if lo < 0:
						lo = x
					hi = x
			if lo >= 0:
				points.append(Vector2(lo, y))
				points.append(Vector2(hi, y))
	var hull := Geometry2D.convex_hull(points)
	if hull.size() < 4 or not Geometry2D.is_point_in_polygon(Vector2(start), hull):
		return null
	# The edge, drawn into a copy of the drawing for the bucket to stop at.
	var out := img.duplicate() as Image
	out.convert(Image.FORMAT_RGBA8)
	for i in hull.size() - 1:
		var a := hull[i]
		var b := hull[i + 1]
		var steps := maxi(1, int(a.distance_to(b)))
		for k in steps + 1:
			var q := a.lerp(b, k / float(steps))
			out.fill_rect(Rect2i(int(q.x) - 1, int(q.y) - 1, 3, 3).intersection(Rect2i(0, 0, w, h)), Color(0, 0, 0, 1))
	return out


## Numbers every ink pixel joined to `at` with `id`; its box. (The ink is grown, so lines are
## thick enough that joining side to side is enough. Written out longhand: this is a hot loop.)
static func _follow_line(ink: PackedByteArray, label: PackedByteArray, at: int, id: int, w: int,
		h: int) -> Rect2i:
	var x0 := at % w
	var y0 := at / w
	var x1 := x0
	var y1 := y0
	label[at] = id
	var stack := PackedInt32Array([at])
	while not stack.is_empty():
		var i := stack[stack.size() - 1]
		stack.remove_at(stack.size() - 1)
		var x := i % w
		var y := i / w
		x0 = mini(x0, x)
		x1 = maxi(x1, x)
		y0 = mini(y0, y)
		y1 = maxi(y1, y)
		if x > 0 and ink[i - 1] != 0 and label[i - 1] == 0:
			label[i - 1] = id
			stack.append(i - 1)
		if x < w - 1 and ink[i + 1] != 0 and label[i + 1] == 0:
			label[i + 1] = id
			stack.append(i + 1)
		if y > 0 and ink[i - w] != 0 and label[i - w] == 0:
			label[i - w] = id
			stack.append(i - w)
		if y < h - 1 and ink[i + w] != 0 and label[i + w] == 0:
			label[i + w] = id
			stack.append(i + w)
	return Rect2i(x0, y0, x1 - x0 + 1, y1 - y0 + 1)


## Whether a line closes round some paper of its own (an eye, a wheel) - more than a scribble's
## crossing. Floods its box from the edges: any paper the flood cannot reach is inside it.
static func _is_closed(label: PackedByteArray, box: Rect2i, id: int, w: int) -> bool:
	# A copy of the box, one pixel bigger all round: 1 where the line is.
	var bw := box.size.x + 2
	var bh := box.size.y + 2
	var wall := PackedByteArray()
	wall.resize(bw * bh)
	var ink_count := 0
	for y in range(box.position.y, box.end.y):
		var row := y * w
		var brow := (y - box.position.y + 1) * bw + 1 - box.position.x
		for x in range(box.position.x, box.end.x):
			if label[row + x] == id:
				wall[brow + x] = 1
				ink_count += 1
	# Paper the flood reaches from the box's edge is outside; marked 2.
	wall[0] = 2
	var stack := PackedInt32Array([0])
	var count := 1
	while not stack.is_empty():
		var i := stack[stack.size() - 1]
		stack.remove_at(stack.size() - 1)
		var x := i % bw
		if x > 0 and wall[i - 1] == 0:
			wall[i - 1] = 2
			count += 1
			stack.append(i - 1)
		if x < bw - 1 and wall[i + 1] == 0:
			wall[i + 1] = 2
			count += 1
			stack.append(i + 1)
		if i >= bw and wall[i - bw] == 0:
			wall[i - bw] = 2
			count += 1
			stack.append(i - bw)
		if i + bw < bw * bh and wall[i + bw] == 0:
			wall[i + bw] = 2
			count += 1
			stack.append(i + bw)
	var enclosed := bw * bh - count - ink_count
	return enclosed > 0.15 * box.size.x * box.size.y


## Fills from `start`. Tapping paper fills the paper region the tap is in, treating anything
## within `gap` pixels of ink as a wall so it can jump small gaps in an outline; tapping
## colour recolours that colour. `blockers`, when given, is the drawing with the walls laid in
## and is what paper fills stop at. Returns {mask (R8 Image), empty, grow}, or {leaked = true}
## when a paper fill reached the edge of the sheet - the kid tapped outside their drawing,
## and colouring the whole page is never what they meant.
static func flood(img: Image, start: Vector2i, gap: int, walls := PackedByteArray()) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	var si := (start.y * w + start.x) * 4
	var empty := data[si + 3] < 200
	var wall := PackedByteArray()
	var grow := 1

	if empty:
		wall = walls if not walls.is_empty() else _walls(img, gap)
		grow = gap
		if wall[start.y * w + start.x] != 0:
			# Tapped in a gap narrower than the wall padding; fill it exactly instead.
			wall = _walls(img, 0)
			grow = 1
			if wall[start.y * w + start.x] != 0:
				return {}
	else:
		var sr := data[si]
		var sg := data[si + 1]
		var sb := data[si + 2]
		wall.resize(w * h)
		for i in w * h:
			var j := i * 4
			var same := data[j + 3] >= 200 and absi(data[j] - sr) + absi(data[j + 1] - sg) \
				+ absi(data[j + 2] - sb) < 48
			wall[i] = 0 if same else 255

	var mask := PackedByteArray()
	mask.resize(w * h)
	var stack := PackedInt32Array([start.y * w + start.x])
	while not stack.is_empty():
		var idx := stack[stack.size() - 1]
		stack.remove_at(stack.size() - 1)
		if mask[idx] != 0 or wall[idx] != 0:
			continue
		var y := idx / w
		var row := y * w
		var xl := idx - row
		var xr := xl
		while xl > 0 and wall[row + xl - 1] == 0 and mask[row + xl - 1] == 0:
			xl -= 1
		while xr < w - 1 and wall[row + xr + 1] == 0 and mask[row + xr + 1] == 0:
			xr += 1
		if empty and (xl == 0 or xr == w - 1 or y == 0 or y == h - 1):
			return {"leaked": true}
		for x in range(xl, xr + 1):
			mask[row + x] = 255
		for ny in [y - 1, y + 1]:
			if ny < 0 or ny >= h:
				continue
			var nrow: int = ny * w
			var in_span := false
			for x in range(xl, xr + 1):
				var j := nrow + x
				if wall[j] == 0 and mask[j] == 0:
					if not in_span:
						stack.append(j)
						in_span = true
				else:
					in_span = false

	return {"mask": Image.create_from_data(w, h, false, Image.FORMAT_R8, mask),
		"empty": empty, "grow": grow}


## 255 wherever there is ink, padded out by `gap` pixels; 0 where a fill may go.
##
## Grown only around the drawing (the rest of a big sheet is empty paper), and in two half steps,
## which make the same round-ish blob with far fewer looks: growing is the bucket's slow part.
static func _walls(img: Image, gap: int) -> PackedByteArray:
	var ink := BitMap.new()
	ink.create_from_image_alpha(img, 0.5)
	var used := img.get_used_rect()
	if gap > 0 and used.size.x > 0:
		var around := used.grow(gap + 1).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		var half := gap / 2
		ink.grow_mask(half, around)
		ink.grow_mask(gap - half, around)
	var walls := ink.convert_to_image()
	walls.convert(Image.FORMAT_L8)
	return walls.get_data()


## A dashed line round a copy that can still slide, so it is clear which thing will move.
class MoveFrame extends Control:
	var canvas: DrawCanvas

	func _draw() -> void:
		if not canvas.moving:
			return
		var r := canvas.loaded_rect()
		if r.size.x <= 0.0:
			return
		# Dashes of marker, walked round a rounded box a little bigger than the copy.
		var k := canvas._sheet.scale.x
		var box := Crayon.rounded_rect(r.grow(10.0 / k), 16.0 / k)
		box.append(box[0])
		var dash := 16.0 / k
		var gap := 10.0 / k
		var left := dash
		var on := true
		var seed := 0
		var piece := PackedVector2Array([box[0]])
		for i in box.size() - 1:
			var a := box[i]
			var b := box[i + 1]
			var d := a.distance_to(b)
			var t := 0.0
			while d - t > left:
				t += left
				var q := a.lerp(b, t / d)
				if on:
					piece.append(q)
					Crayon.marker_line(self, piece, Color(UI.ACCENT, 0.9), maxf(3.0, 4.0 / k), seed, false)
					seed += 1
				piece = PackedVector2Array([q])
				on = not on
				left = dash if on else gap
			left -= d - t
			if on:
				piece.append(b)


## Other drawings shown on the sheet (set_previews).
class PreviewLayer extends Control:
	var items := []

	func _draw() -> void:
		for p in items:
			var tex: Texture2D = p["texture"]
			var k: float = p["scale"]
			draw_set_transform(p["pos"], 0.0, Vector2(-k if p.get("flip", false) else k, k))
			draw_texture(tex, -Vector2(p["pivot"]), Color(1, 1, 1, float(p.get("alpha", 0.92))))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
