class_name DrawCanvas
extends Control
## One sheet of paper a kid draws one thing on: a body, a leg, a favourite food.
##
## The sheet is 512 px square whatever size it shows at. Every stroke and fill is its own node
## inside a SubViewport, back to front, so undo is "delete the last node" and the drawing is
## never flattened until it is finished. Then it is cropped to its ink and becomes the part.
##
## Two things on the sheet are not the kid's drawing and never end up in it:
##   the ghost - the body (or head) drawn so far, faint, so a leg is drawn at the right size;
##   the dot   - red, where the part joins on. The kid starts drawing there, and it becomes
##               the joint the part swings about. Its position also fixes the part's rest
##               direction: a leg drawn down from a dot at the top hangs down.
##
## Nothing here smooths, straightens or tidies a stroke. Wobbly is the point.

signal message(text: String)

const SHEET := PartTypes.SHEET

enum Tool { PEN, FILL, ERASER, DOT }

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

var tool := Tool.PEN
var color: Color = UI.PALETTE[0]
var brush := 12.0
var dot := Vector2(256, 256)
var show_dot := true
## "" for ordinary crayon, or a Shiny mode while a shiny marker is in hand.
var shine := ""

var _viewport: SubViewport
var _ops: Node2D
var _sheet: Control
var _ghost: TextureRect
var _ink: TextureRect
var _dot_layer: DotLayer
var _stroke: Line2D
var _ghost_image: Image
var _ghost_rect := Rect2()
var _busy := false
var _erase_material: ShaderMaterial
var _fill_shader: Shader
var _unfill_shader: Shader
## The shine mask: every op has a twin here, white where it was drawn with a shiny marker and
## wiping the mask where it was not. Only the strokes made with a shiny marker end up shining.
var _mask_viewport: SubViewport
var _mask_ops: Node2D
var _shine_mode := ""


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	_viewport = SubViewport.new()
	_viewport.size = Vector2i(SHEET, SHEET)
	_viewport.transparent_bg = true
	_viewport.disable_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_viewport)
	_ops = Node2D.new()
	_viewport.add_child(_ops)
	_mask_viewport = SubViewport.new()
	_mask_viewport.size = Vector2i(SHEET, SHEET)
	_mask_viewport.transparent_bg = true
	_mask_viewport.disable_3d = true
	_mask_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_mask_viewport)
	_mask_ops = Node2D.new()
	_mask_viewport.add_child(_mask_ops)

	_sheet = Control.new()
	_sheet.size = Vector2(SHEET, SHEET)
	_sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sheet)

	_ghost = TextureRect.new()
	_ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ghost.stretch_mode = TextureRect.STRETCH_SCALE
	_ghost.modulate = Color(0.55, 0.6, 0.9, 0.22)
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.visible = false
	_sheet.add_child(_ghost)

	_ink = TextureRect.new()
	_ink.texture = _viewport.get_texture()
	_ink.size = Vector2(SHEET, SHEET)
	_ink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_ink)

	_dot_layer = DotLayer.new()
	_dot_layer.canvas = self
	_dot_layer.size = Vector2(SHEET, SHEET)
	_dot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_dot_layer)

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
	_sheet.scale = Vector2.ONE * (size.x / SHEET)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2(4, 6), size), Color(0.23, 0.21, 0.4, 0.12))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#fffdf6"))
	draw_rect(Rect2(Vector2.ZERO, size), UI.INK, false, 3.0)


## Shows a drawing faintly under the sheet, at `rect` in sheet pixels. The bucket treats it as
## a wall too: a leg is drawn as an outline left open where it meets the body, and the fill
## should stop at the body rather than leak out of the top.
func set_ghost(image: Image, rect: Rect2) -> void:
	_ghost_image = image
	_ghost_rect = rect
	_ghost.texture = ImageTexture.create_from_image(image)
	_ghost.position = rect.position
	_ghost.size = rect.size
	_ghost.visible = true


func set_dot(at: Vector2, visible_dot := true) -> void:
	dot = at
	show_dot = visible_dot
	_dot_layer.queue_redraw()


# --- Input -----------------------------------------------------------------------------------
# Mouse events only: on a phone, Godot turns the first finger into the mouse, which is all one
# drawing finger needs. Pinch and two-finger tricks will read InputEventScreenTouch directly.

func _gui_input(event: InputEvent) -> void:
	if _busy:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var at := _to_sheet(event.position)
		if event.pressed:
			_press(at)
		else:
			_stroke = null
		accept_event()
	elif event is InputEventMouseMotion and _stroke != null:
		_extend(_to_sheet(event.position))
		accept_event()


func _to_sheet(local: Vector2) -> Vector2:
	return local / (size.x / SHEET)


func _press(at: Vector2) -> void:
	match tool:
		Tool.PEN, Tool.ERASER:
			begin_stroke(at)
		Tool.FILL:
			fill_at(at)
		Tool.DOT:
			if show_dot:
				set_dot(at.clamp(Vector2.ZERO, Vector2(SHEET, SHEET)))


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
	if start.x < 0 or start.y < 0 or start.x >= SHEET or start.y >= SHEET:
		return
	_busy = true
	var sheet_image := await snapshot()
	var blockers := _ghost_walls(sheet_image)
	var result := flood(sheet_image, start, FILL_GAP, blockers)
	_busy = false
	if result.get("leaked", false):
		message.emit("That would colour the whole page! Fill INSIDE a closed shape.")
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
	# Paper fills keep off the ghost as well as the ink, so a leg's colour stops at the body.
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
	else:
		twin_mat.shader = _unfill_shader
	twin.material = twin_mat
	_add_op(sprite, twin)
	_changed()


func undo() -> void:
	if _ops.get_child_count() == 0:
		return
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
	var wipe := Polygon2D.new()
	wipe.polygon = PackedVector2Array([Vector2.ZERO, Vector2(SHEET, 0), Vector2(SHEET, SHEET),
		Vector2(0, SHEET)])
	wipe.material = _erase_material
	_add_op(wipe, wipe.duplicate())
	_changed()


func _changed() -> void:
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_mask_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


## The drawing as it stands, full sheet, transparent where nothing is drawn.
func snapshot() -> Image:
	_changed()
	await RenderingServer.frame_post_draw
	return _viewport.get_texture().get_image()


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
	var result := {"image": cropped, "pivot": dot - Vector2(used.position), "shine": {}}
	if _shine_mode != "":
		var mask := _mask_viewport.get_texture().get_image().get_region(used)
		if mask.get_used_rect().size.x > 0:
			result["shine"] = {"mode": _shine_mode, "mask": mask}
	return result


# --- Flood fill ------------------------------------------------------------------------------

## The drawing with the ghost laid into it, for the bucket to treat as walls. Null with no ghost.
func _ghost_walls(sheet_image: Image) -> Image:
	if _ghost_image == null or not _ghost.visible:
		return null
	var composite := sheet_image.duplicate() as Image
	var g := _ghost_image.duplicate() as Image
	g.resize(maxi(1, int(_ghost_rect.size.x)), maxi(1, int(_ghost_rect.size.y)))
	composite.blend_rect(g, Rect2i(Vector2i.ZERO, g.get_size()), Vector2i(_ghost_rect.position))
	return composite


## Fills from `start`. Tapping paper fills the paper region the tap is in, treating anything
## within `gap` pixels of ink as a wall so it can jump small gaps in an outline; tapping
## colour recolours that colour. `blockers`, when given, is the drawing with the ghost laid in
## and is what paper fills stop at. Returns {mask (R8 Image), empty, grow}, or {leaked = true}
## when a paper fill reached the edge of the sheet - the kid tapped outside their drawing,
## and colouring the whole page is never what they meant.
static func flood(img: Image, start: Vector2i, gap: int, blockers: Image = null) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	var si := (start.y * w + start.x) * 4
	var empty := data[si + 3] < 200
	var wall := PackedByteArray()
	var grow := 1
	var wall_src := blockers if blockers != null else img

	if empty:
		wall = _walls(wall_src, gap)
		grow = gap
		if wall[start.y * w + start.x] != 0:
			# Tapped in a gap narrower than the wall padding; fill it exactly instead.
			wall = _walls(wall_src, 0)
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
static func _walls(img: Image, gap: int) -> PackedByteArray:
	var ink := BitMap.new()
	ink.create_from_image_alpha(img, 0.5)
	if gap > 0:
		ink.grow_mask(gap, Rect2i(Vector2i.ZERO, img.get_size()))
	var walls := ink.convert_to_image()
	walls.convert(Image.FORMAT_L8)
	return walls.get_data()


## The red "attach here" dot, drawn over the sheet. Not part of the drawing.
class DotLayer extends Control:
	var canvas: DrawCanvas

	func _draw() -> void:
		if not canvas.show_dot:
			return
		draw_circle(canvas.dot, 15.0, Color(1, 1, 1, 0.9))
		draw_circle(canvas.dot, 11.0, Color("#e8344e"))
		draw_arc(canvas.dot, 21.0, 0.0, TAU, 32, Color("#e8344e"), 3.0, true)
