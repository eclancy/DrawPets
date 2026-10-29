class_name PhotoEditor
extends Control
## The camera's second half (.ai/pet-life.md): the moment the kid snapped, big, to finish off -
## pick a frame, put stickers on it and drag them about (drag one off the photo to take it
## away) - then Keep it, into the album and the journal of every pet in it, or Throw it away.
## Frames and stickers are crayon drawings made in code, never shine.
##
## A sticker goes on either way a kid tries it: tapped in the tray it pops onto the middle of the
## photo; dragged out of the tray it rides the finger and lands where it is let go. The first few
## times, until one is on, a drawn hand (HowTo) drags one from the tray onto the photo.

const FRAMES := ["paper", "hearts", "stars", "flowers", "rainbow", "snapshot"]
const STICKERS := ["heart", "star", "flower", "crown", "note", "paw", "sun", "hello"]
## The kept photo's size.
const SIZE := Vector2(960, 540)
## Seconds with no touch before the hand comes back, while no sticker is on yet.
const IDLE_BACK := 6.0
## How many photos the hand shows the stickers on.
const HINT_TIMES := 3
## A finger that moves this far from where it came down on the tray is dragging, not tapping.
const DRAG_START := 24.0

var game: GameRoot
var photo: Image
var home_id := ""
## The pets in the photo: each gets a line in its journal.
var pets: Array = []
## Called with the photo's id, or "" if it was thrown away.
var on_done := Callable()

var _viewport: SubViewport
var _holder: SubViewportContainer
var _frame: FrameArt
var _stickers: Control
var _frame_buttons := {}
var _title: Label
var _left: VBoxContainer
var _tray := {}
## Over the photo's column, the same size, unclipped: the hand lives here, its words centred
## under the photo, its finger free to reach the tray.
var _over: Control
var _hand: HowTo
## The sticker the hand carries while it shows how, so the kid sees what a drag brings along.
var _demo: StickerArt
var _teach := false
var _idle := 0.0
## A sticker is on: the hand's job is done.
var _placed := false
## A finger that came down on a sticker in the tray, and the sticker riding it once it drags.
var _tray_kind := ""
var _tray_from := Vector2.ZERO
var _finger := Vector2.ZERO
var _float: StickerArt
## Set for the rest of the frame a drag ends in, so the tray button it ends on adds no second one.
var _carried := false
var _keeping := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(UI.PAPER, 0.97)
	add_child(UI.full_rect(bg))

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	UI.full_rect(body)
	body.offset_left = 20
	body.offset_top = 16
	body.offset_right = -20
	body.offset_bottom = -16
	add_child(body)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)
	_left = left
	_title = UI.title("Say cheese! Pick a frame, add stickers.", 30)
	left.add_child(_title)
	var holder := SubViewportContainer.new()
	_holder = holder
	holder.stretch = true
	holder.custom_minimum_size = SIZE * 0.86
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left.add_child(holder)
	# The photo is put together in its own viewport, the size of the box on screen (16:9), and
	# kept at SIZE.
	_viewport = SubViewport.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	holder.add_child(_viewport)
	var pic := TextureRect.new()
	pic.texture = ImageTexture.create_from_image(photo)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_viewport.add_child(UI.full_rect(pic))
	_frame = FrameArt.new()
	_viewport.add_child(UI.full_rect(_frame))
	_stickers = Control.new()
	_stickers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_viewport.add_child(UI.full_rect(_stickers))

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(300, 0)
	right.add_theme_constant_override("separation", 8)
	body.add_child(right)
	right.add_child(UI.label("Frame", 22))
	var frames := GridContainer.new()
	frames.columns = 3
	frames.add_theme_constant_override("h_separation", 6)
	frames.add_theme_constant_override("v_separation", 6)
	for kind in FRAMES:
		var b := Button.new()
		b.custom_minimum_size = Vector2(92, 68)
		b.pressed.connect(set_frame.bind(kind))
		var mini := FrameArt.new()
		mini.kind = kind
		mini.thin = true
		mini.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(UI.full_rect(mini))
		mini.offset_left = 6
		mini.offset_top = 6
		mini.offset_right = -6
		mini.offset_bottom = -6
		_frame_buttons[kind] = b
		frames.add_child(b)
	right.add_child(frames)
	right.add_child(UI.label("Stickers", 22))
	var tray := GridContainer.new()
	tray.columns = 4
	tray.add_theme_constant_override("h_separation", 6)
	tray.add_theme_constant_override("v_separation", 6)
	for kind in STICKERS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(68, 68)
		b.button_down.connect(_tray_down.bind(kind))
		b.pressed.connect(_tray_tap.bind(kind))
		var art := StickerArt.new()
		art.kind = kind
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(UI.full_rect(art))
		tray.add_child(b)
		_tray[kind] = b
	right.add_child(tray)
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(gap)
	var keep := UI.big_icon_button("tool_done", "Keep it!", keep_it)
	right.add_child(keep)
	right.add_child(UI.icon_button("ui_let_go", "Throw away", _throw_away, 32, Vector2(0, 70)))
	set_frame("paper")

	_over = Control.new()
	_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_over)
	_demo = StickerArt.new()
	_demo.kind = STICKERS[0]
	_demo.size = Vector2(96, 96)
	_demo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_demo.modulate.a = 0.0
	_over.add_child(_demo)
	_teach = game != null and HowTo.first_times(game.profile, "howto_stickers", HINT_TIMES)
	# The hand comes in a moment after the editor does, once everything has found its place.
	_idle = IDLE_BACK - 0.6


func _process(delta: float) -> void:
	_over.position = _left.get_global_rect().position - get_global_rect().position
	_over.size = _left.size
	# One sentence on screen at a time: the hand's own words while it is up.
	_title.modulate.a = 0.0 if _hand != null else 1.0
	# The hand's sticker rides its fingertip while it presses, then fades where it was let go.
	if _hand != null and is_instance_valid(_hand) and _hand._press > 0.0:
		_demo.position = _hand._finger - _demo.size / 2.0
		_demo.modulate.a = 0.85 * _hand.modulate.a
	else:
		_demo.modulate.a = maxf(0.0, _demo.modulate.a - delta * 3.0)
	if not _teach or _placed or _keeping or _hand != null or _tray_kind != "":
		_idle = 0.0
		return
	_idle += delta
	if _idle > IDLE_BACK:
		_show_hand()


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_finger = (event as InputEventMouse).position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_idle = 0.0
		elif _tray_kind != "":
			_tray_up()
	elif event is InputEventMouseMotion and _tray_kind != "":
		_tray_move()


# --- The hand --------------------------------------------------------------------------------

## The hand drags a sticker out of the tray onto the photo, with a few words under the photo.
func _show_hand() -> void:
	var h := HowTo.new()
	h.gesture = "swipe"
	h.period = 1.8
	h.at = _tray_point
	h.to = _photo_spot
	h.caption = "Drag a sticker onto the photo!"
	h.caption_y = _holder.get_global_rect().end.y - _left.get_global_rect().position.y + 12.0
	h.until_touch = true
	_hand = h
	h.tree_exiting.connect(_hand_gone.bind(h))
	_over.add_child(h)


func _drop_hand() -> void:
	if _hand != null and is_instance_valid(_hand):
		_hand.dismiss()
	_hand = null


func _hand_gone(h: HowTo) -> void:
	if _hand == h:
		_hand = null
	_idle = 0.0


## The first sticker in the tray, in the hand's space.
func _tray_point() -> Vector2:
	var b: Button = _tray[STICKERS[0]]
	return _over.get_global_transform().affine_inverse() * b.get_global_rect().get_center()


## A spot on the photo for the hand to take it to, in the hand's space.
func _photo_spot() -> Vector2:
	var r := _holder.get_global_rect()
	return _over.get_global_transform().affine_inverse() * (r.position + r.size * Vector2(0.62, 0.42))


# --- Stickers from the tray --------------------------------------------------------------------
# A tap on a sticker button pops it onto the photo (pressed). A finger that drags off the button
# instead carries a sticker with it, read here in _input, before the button sees it. Positions
# come from the events themselves (a phone's finger, the demo's), in the viewport's space.

func _tray_down(kind: String) -> void:
	_tray_kind = kind
	_tray_from = _finger


func _tray_tap(kind: String) -> void:
	if _carried:
		return
	add_sticker(kind)


func _tray_move() -> void:
	if _float == null:
		if _finger.distance_to(_tray_from) < DRAG_START:
			return
		_float = StickerArt.new()
		_float.kind = _tray_kind
		_float.size = Vector2(110, 110)
		_float.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_float)
		_drop_hand()
	_float.position = get_global_transform_with_canvas().affine_inverse() * _finger - _float.size / 2.0


## The finger comes up: a carried sticker lands on the photo where it is let go - or, let go
## anywhere else, goes back to the tray.
func _tray_up() -> void:
	var kind := _tray_kind
	_tray_kind = ""
	if _float == null:
		return
	_float.queue_free()
	_float = null
	_carried = true
	_end_carry.call_deferred()
	var at := _holder.get_global_transform_with_canvas().affine_inverse() * _finger
	if Rect2(Vector2.ZERO, _stickers.size).has_point(at):
		add_sticker(kind, at)


func _end_carry() -> void:
	_carried = false


func set_frame(kind: String) -> void:
	_frame.kind = kind
	_frame.queue_redraw()
	for k in _frame_buttons:
		var b: Button = _frame_buttons[k]
		if k == kind:
			b.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.INK, 4))
		else:
			b.remove_theme_stylebox_override("normal")


## Pops a sticker onto the photo, a little way from the middle.
func add_sticker(kind: String, at := Vector2(-1, -1)) -> void:
	var s := Sticker.new()
	s.kind = kind
	s.size = Vector2(110, 110)
	var n := _stickers.get_child_count()
	if at.x < 0.0:
		at = _stickers.size / 2.0 + Vector2(cos(n * 2.4), sin(n * 2.4)) * (60.0 + n * 18.0)
	s.position = at - s.size / 2.0
	s.rotation = Crayon.noise(n + 7, 3) * 0.3
	s.pivot_offset = s.size / 2.0
	_stickers.add_child(s)
	Sounds.play_varied("place", 1.3, 0.1, -4.0)
	_placed = true
	_drop_hand()


## Keeps it: rendered at full size, into the album and every pet's journal.
func keep_it() -> void:
	if _keeping:
		return
	_keeping = true
	_drop_hand()
	# Read back once a frame with the last sticker in it has been drawn. A hidden or minimised
	# window draws no frames, so this never waits on one for long: after a moment it draws one.
	var drawn := [false]
	var mark := func(): drawn[0] = true
	RenderingServer.frame_post_draw.connect(mark, CONNECT_ONE_SHOT)
	var waited := 0
	while not drawn[0] and waited < 60:
		await get_tree().process_frame
		waited += 1
	if not drawn[0]:
		RenderingServer.frame_post_draw.disconnect(mark)
		RenderingServer.force_draw()
	var img := _viewport.get_texture().get_image()
	img.resize(int(SIZE.x), int(SIZE.y), Image.INTERPOLATE_BILINEAR)
	var ids := []
	for p in pets:
		ids.append(p["id"])
	var id := Album.add(game.profile, img, home_id, ids)
	for p in pets:
		Journal.add(p, "Had its photo taken!", id)
	Sounds.play("camera")
	on_done.call(id)


func _throw_away() -> void:
	if _keeping:
		return
	on_done.call("")


## A sticker, drawn in crayon with a white cut-out edge.
class StickerArt extends Control:
	var kind := "heart"

	func _draw() -> void:
		var c := size / 2.0
		var r := minf(size.x, size.y) * 0.4
		var seed := hash(kind) % 997
		match kind:
			"heart":
				_shape(Crayon.heart(c + Vector2(0, r * 0.1), r * 2.0), Color("#f2557a"), seed)
			"star":
				_shape(Crayon.star(c, r, seed), Color("#ffd23f"), seed)
			"flower":
				for i in 5:
					var a := TAU * i / 5.0
					_shape(Crayon.ellipse(c + Vector2(cos(a), sin(a)) * r * 0.55, Vector2(r, r) * 0.42, 16),
						Color("#f7a6c8"), seed + i)
				_shape(Crayon.ellipse(c, Vector2(r, r) * 0.36, 16), Color("#ffcf4a"), seed + 9)
			"crown":
				_shape(PackedVector2Array([c + Vector2(-r, r * 0.6), c + Vector2(-r, -r * 0.5),
					c + Vector2(-r * 0.5, 0), c + Vector2(0, -r * 0.8), c + Vector2(r * 0.5, 0), c + Vector2(r, -r * 0.5),
					c + Vector2(r, r * 0.6)]), Color("#ffd166"), seed)
			"note":
				_shape(Crayon.ellipse(c + Vector2(-r * 0.3, r * 0.5), Vector2(r * 0.45, r * 0.33), 16), Color("#9d8af4"), seed)
				_shape(PackedVector2Array([c + Vector2(r * 0.05, r * 0.5), c + Vector2(r * 0.05, -r * 0.9),
					c + Vector2(r * 0.6, -r * 0.6), c + Vector2(r * 0.6, -r * 0.35), c + Vector2(r * 0.22, -r * 0.55),
					c + Vector2(r * 0.22, r * 0.5)]), Color("#9d8af4"), seed + 1)
			"paw":
				_shape(Crayon.ellipse(c + Vector2(0, r * 0.3), Vector2(r * 0.55, r * 0.45), 18), Color("#b48ad8"), seed)
				for i in 4:
					var a := -PI * 0.85 + i * PI * 0.23
					_shape(Crayon.ellipse(c + Vector2(0, r * 0.3) + Vector2(cos(a), sin(a)) * r * 0.85,
						Vector2(r, r) * 0.2, 12), Color("#b48ad8"), seed + i + 1)
			"sun":
				for i in 8:
					var a := TAU * i / 8.0
					Crayon.line(self, c + Vector2(cos(a), sin(a)) * r * 0.7, c + Vector2(cos(a), sin(a)) * r,
						Color("#ffb347"), 6.0, seed + i, 1.0)
				_shape(Crayon.ellipse(c, Vector2(r, r) * 0.55, 20), Color("#ffd23f"), seed)
			"hello":
				var bubble := Crayon.rounded_rect(Rect2(c - Vector2(r, r * 0.7), Vector2(r * 2.0, r * 1.2)), r * 0.4)
				bubble.append(c + Vector2(-r * 0.2, r * 0.5))
				_shape(bubble, Color("#fffdf6"), seed)
				var font := get_theme_default_font()
				draw_string(font, c + Vector2(-r * 0.62, r * 0.05), "Hi!", HORIZONTAL_ALIGNMENT_LEFT, -1,
					int(r * 0.8), UI.INK)

	## A shape with a white cut-out edge round it, then crayon colour.
	func _shape(poly: PackedVector2Array, col: Color, seed: int) -> void:
		if poly.size() < 3:
			return
		var grown := Geometry2D.offset_polygon(poly, 5.0)
		if not grown.is_empty():
			draw_colored_polygon(grown[0], Color.WHITE)
		Crayon.fill(self, poly, col, seed, 5.0, 1.0, 3.0)
		var edge := poly.duplicate()
		edge.append(poly[0])
		draw_polyline(edge, col.darkened(0.35), 2.5, true)


## A sticker on the photo: drag it about, drag it off the edge to take it away.
class Sticker extends StickerArt:
	var _dragging := false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			if not event.pressed:
				var c := position + size / 2.0
				var room := (get_parent() as Control).size
				if c.x < -10.0 or c.y < -10.0 or c.x > room.x + 10.0 or c.y > room.y + 10.0:
					queue_free()
			accept_event()
		elif event is InputEventMouseMotion and _dragging:
			# The move comes in the sticker's own tilted frame: turned back into the photo's, so
			# the sticker stays under the finger instead of sliding off sideways.
			position += get_transform().basis_xform((event as InputEventMouseMotion).relative)
			accept_event()


## A photo frame, drawn in crayon round the edge.
class FrameArt extends Control:
	var kind := "paper"
	## The little ones on the frame buttons.
	var thin := false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var k := 0.25 if thin else 1.0
		var w := 26.0 * k
		var r := Rect2(Vector2.ZERO, size)
		if thin:
			draw_rect(r, Color("#d9e9f5"))
		var paper := Color("#fffdf6")
		var bottom := w * 3.4 if kind == "snapshot" else w
		_band(r, w, bottom, paper)
		match kind:
			"paper":
				draw_rect(r.grow(-w), Color("#e2d6bd"), false, maxf(2.0, 4.0 * k))
			"hearts":
				_along(r, w, func(at: Vector2, i: int): Crayon.fill(self, Crayon.heart(at, 30.0 * k), Color("#f2557a"), i, 4.0 * k, 1.0, 2.0))
			"stars":
				_along(r, w, func(at: Vector2, i: int): Crayon.fill(self, Crayon.star(at, 14.0 * k, i), Color("#ffd23f"), i, 4.0 * k, 1.0, 2.0))
			"flowers":
				_along(r, w, _flower.bind(k))
			"rainbow":
				var colors := [Color("#f7a1a1"), Color("#f9c98a"), Color("#f7e48a"), Color("#a9dd9a"), Color("#9cc9ef"), Color("#c3a9ec")]
				for i in colors.size():
					draw_rect(r.grow(-(i + 0.5) * w / 6.0), colors[i], false, w / 6.0 + 0.5)
			"snapshot":
				draw_rect(Rect2(w, w, size.x - w * 2.0, size.y - w - bottom), Color("#e2d6bd"), false, maxf(1.5, 3.0 * k))
				if not thin:
					var font := get_theme_default_font()
					draw_string(font, Vector2(w * 1.4, size.y - bottom * 0.32), Journal.date_text(int(Time.get_unix_time_from_system())),
						HORIZONTAL_ALIGNMENT_LEFT, -1, 30, UI.INK_SOFT)

	## The paper border: top, sides, and a bottom that may be deeper (a snapshot's).
	func _band(r: Rect2, w: float, bottom: float, col: Color) -> void:
		draw_rect(Rect2(0, 0, r.size.x, w), col)
		draw_rect(Rect2(0, r.size.y - bottom, r.size.x, bottom), col)
		draw_rect(Rect2(0, 0, w, r.size.y), col)
		draw_rect(Rect2(r.size.x - w, 0, w, r.size.y), col)

	## Calls `fn(point, i)` at even steps round the border's middle.
	func _along(r: Rect2, w: float, fn: Callable) -> void:
		var inner := r.grow(-w * 0.5)
		var step := maxf(w * 3.6, 12.0)
		var i := 0
		var x := inner.position.x
		while x <= inner.end.x:
			fn.call(Vector2(x, inner.position.y), i)
			fn.call(Vector2(x, inner.end.y), i + 1)
			x += step
			i += 2
		var y := inner.position.y + step
		while y < inner.end.y - step * 0.5:
			fn.call(Vector2(inner.position.x, y), i)
			fn.call(Vector2(inner.end.x, y), i + 1)
			y += step
			i += 2

	func _flower(at: Vector2, i: int, k: float) -> void:
		for p in 5:
			var a := TAU * p / 5.0
			draw_circle(at + Vector2(cos(a), sin(a)) * 8.0 * k, 6.0 * k, Color("#f7a6c8"))
		draw_circle(at, 5.0 * k, Color("#ffcf4a"))
