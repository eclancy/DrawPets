class_name FeedbackScreen
extends Control
## "Report a bug or send an idea", for grown-ups - reached from Settings by a held button, like
## switching modes, or from the drawing's Stop box by another, so it is not a kid's chat box. The
## same idea as DrawFight's "Report a bug": it goes to ecec.dev's intake
## (EricClancyEngineeringAndCrafts: intake/server.js, POST /api/draw/pets), which saves it and
## emails it to Eric.
##
## Kept small on purpose (.ai/sharing.md): no name field, and a line asking for no names,
## addresses or anything personal. It sends the message, its kind and the game's version and
## platform - and, only if the grown-up ticks "Include a picture of the game" after seeing it, one
## picture of the game's own screen. Never a recording, a photo or a name.
##
## The picture (`picture`, from GameRoot.report_picture) is the screen the player was on before
## Settings, or the drawing in progress from the Stop box - read from the game's own window, kept
## in memory only, never written to disk; never the camera, the photo picker or another app. The
## box starts off every time this screen opens and is never remembered; ticked, it shows the exact
## JPEG that will go, with a line asking to check it for names and faces. No picture worth
## sending, no box. Without a picture the form goes urlencoded, as before; with one, as multipart.

const KINDS := [["bug", "Something went wrong"], ["idea", "An idea"], ["other", "Something else"]]
const MAX_CHARS := 2000
## Points the game at a test copy of the intake instead.
const SITE_OVERRIDE := "DRAWPETS_SITE"
## The picture's longest side, and its JPEG quality.
const PICTURE_PX := 1280
const PICTURE_QUALITY := 0.85

var game: GameRoot
var on_back := Callable()
## The game's screen from before (GameRoot.report_picture), or null: no picture to offer.
var picture: Image = null

var _kind := "bug"
var _kind_buttons := {}
var _text: TextEdit
var _send: Button
var _status: Label
var _http: HTTPRequest
## Off every time the screen opens - never remembered.
var _include := false
var _jpeg := PackedByteArray()
var _picture_button: Button
var _picture_tick: TextureRect
var _picture_label: Label
var _preview_box: Control
var _preview: TextureRect


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	add_child(UI.full_rect(UI.margin(col, 26)))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 14)
	top.add_child(UI.icon_button("tool_back", "Back", _back, 40, Vector2(100, 84)))
	top.add_child(UI.title("Tell us about DrawPets", 40))
	col.add_child(top)
	var intro := UI.label("For grown-ups. Found a bug, or have an idea? This goes to the person who makes DrawPets, by email. Please don't write names, addresses or anything personal.", 22, true)
	intro.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(intro)

	var kinds := HBoxContainer.new()
	kinds.add_theme_constant_override("separation", 12)
	for k in KINDS:
		var b := UI.button(k[1], _pick.bind(k[0]), Vector2(300, 64), 22)
		_kind_buttons[k[0]] = b
		kinds.add_child(b)
	col.add_child(kinds)

	# The message, with the picture beside it once the box is ticked.
	var mid := HBoxContainer.new()
	mid.add_theme_constant_override("separation", 18)
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(mid)
	_text = TextEdit.new()
	_text.placeholder_text = "What were you doing, and what happened? Or: what's your idea?"
	_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_text.add_theme_font_size_override("font_size", 24)
	# The game's paper card and ink, not Godot's dark default.
	for state in ["normal", "focus", "read_only"]:
		_text.add_theme_stylebox_override(state, UI._box(UI.CARD, UI.INK, 3))
	_text.add_theme_color_override("font_color", UI.INK)
	_text.add_theme_color_override("font_placeholder_color", UI.INK_SOFT)
	_text.add_theme_color_override("caret_color", UI.INK)
	_text.add_theme_color_override("selection_color", Color(UI.ACCENT, 0.35))
	_text.text_changed.connect(_on_typed)
	mid.add_child(_text)
	if _has_picture():
		mid.add_child(_build_preview())

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 18)
	_send = UI.big_icon_button("tool_done", "Send", send)
	_send.custom_minimum_size = Vector2(260, 84)
	bottom.add_child(_send)
	if _has_picture():
		bottom.add_child(_build_picture_button())
	_status = UI.label("", 22, true)
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(_status)
	col.add_child(bottom)

	_http = HTTPRequest.new()
	_http.timeout = 20.0
	add_child(_http)
	_http.request_completed.connect(_on_sent)
	_pick(_kind)
	set_include_picture(false)
	_on_typed()
	_text.grab_focus()


func _has_picture() -> bool:
	return picture != null and not picture.is_empty()


## The picture as it will be sent, and the line asking to check it. Hidden until the box is ticked.
func _build_preview() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.custom_minimum_size.x = 400
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UI._box(UI.CARD, UI.INK, 3, 10, 6))
	_preview = TextureRect.new()
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview.custom_minimum_size = Vector2(388, 388.0 * picture.get_height() / picture.get_width())
	frame.add_child(_preview)
	box.add_child(frame)
	var warn := UI.label("Check there's nothing personal in this picture - no names or faces.", 22, true)
	warn.add_theme_color_override("font_color", UI.ACCENT.darkened(0.3))
	box.add_child(warn)
	_preview_box = box
	return box


## "Include a picture of the game": one big button, with a box that shows the game's tick when on.
func _build_picture_button() -> Button:
	_picture_button = UI.button("", _toggle_picture, Vector2(470, 84), 22)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	UI.full_rect(row)
	var box := PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.custom_minimum_size = Vector2(48, 48)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_theme_stylebox_override("panel", UI._box(UI.CARD, UI.INK, 3, 8, 3))
	_picture_tick = UI.icon("tool_done", 40, "none")
	box.add_child(_picture_tick)
	row.add_child(box)
	_picture_label = UI.label("", 22)
	_picture_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_picture_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_picture_label)
	_picture_button.add_child(row)
	# A Button does not measure what is laid over it; keep it wide enough for its words.
	row.minimum_size_changed.connect(UI._fit_width.bind(_picture_button, row))
	return _picture_button


func _toggle_picture() -> void:
	set_include_picture(not _include)


## Ticks or unticks "Include a picture of the game". Ticked, the exact JPEG to be sent is made and
## shown; unticked, it is thrown away.
func set_include_picture(on: bool) -> void:
	if not _has_picture():
		return
	_include = on
	_jpeg = jpeg(picture) if on else PackedByteArray()
	if on:
		var shown := Image.new()
		shown.load_jpg_from_buffer(_jpeg)
		_preview.texture = ImageTexture.create_from_image(shown)
	else:
		_preview.texture = null
	_preview_box.visible = on
	_picture_tick.modulate.a = 1.0 if on else 0.0
	_picture_label.text = "Picture included - tap to take it out" if on else "Include a picture of the game"
	_picture_button.add_theme_stylebox_override("normal", UI._box(UI.GOOD if on else UI.CARD, UI.INK, 3))


func _back() -> void:
	on_back.call()


func _pick(kind: String) -> void:
	_kind = kind
	for k in _kind_buttons:
		var b: Button = _kind_buttons[k]
		b.add_theme_stylebox_override("normal", UI._box(UI.GOOD if k == kind else UI.CARD, UI.INK, 3))


func _on_typed() -> void:
	if _text.text.length() > MAX_CHARS:
		_text.text = _text.text.substr(0, MAX_CHARS)
		_text.set_caret_column(_text.get_line(_text.get_line_count() - 1).length())
		_text.set_caret_line(_text.get_line_count() - 1)
	_send.disabled = _text.text.strip_edges() == ""


## Where the intake is: this page's own site on the web, ecec.dev everywhere else.
static func _site() -> String:
	var site := OS.get_environment(SITE_OVERRIDE)
	if site != "":
		return site
	if OS.has_feature("web"):
		var origin: Variant = JavaScriptBridge.eval("window.location.origin", true)
		if typeof(origin) == TYPE_STRING and str(origin).begins_with("http"):
			return str(origin)
	return "https://ecec.dev"


static func platform() -> String:
	return "web" if OS.has_feature("web") else OS.get_name()


## A window's picture made small enough to send: its longest side at most PICTURE_PX, no alpha.
static func shrink(img: Image) -> Image:
	var out := img.duplicate() as Image
	if out.is_compressed():
		out.decompress()
	out.convert(Image.FORMAT_RGB8)
	var longest := maxi(out.get_width(), out.get_height())
	if longest > PICTURE_PX:
		var k := float(PICTURE_PX) / longest
		out.resize(maxi(1, roundi(out.get_width() * k)), maxi(1, roundi(out.get_height() * k)),
			Image.INTERPOLATE_LANCZOS)
	return out


static func jpeg(img: Image) -> PackedByteArray:
	return img.save_jpg_to_buffer(PICTURE_QUALITY)


## A multipart/form-data body: each field, then the picture as its one file part, `screenshot`.
static func multipart(fields: Dictionary, jpg: PackedByteArray, boundary: String) -> PackedByteArray:
	var body := PackedByteArray()
	for k in fields:
		body.append_array(("--%s\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n" % [boundary, k]).to_utf8_buffer())
		body.append_array(str(fields[k]).to_utf8_buffer())
		body.append_array("\r\n".to_utf8_buffer())
	body.append_array(("--%s\r\nContent-Disposition: form-data; name=\"screenshot\"; filename=\"screenshot.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n" % boundary).to_utf8_buffer())
	body.append_array(jpg)
	body.append_array(("\r\n--%s--\r\n" % boundary).to_utf8_buffer())
	return body


func send() -> void:
	var message := _text.text.strip_edges()
	if message == "":
		return
	var fields := {
		"kind": _kind,
		"message": message,
		"version": UpdateScreen.current_version(),
		"platform": platform(),
	}
	var url := _site() + "/api/draw/pets"
	var err := OK
	if _include and not _jpeg.is_empty():
		# A picture takes longer on a slow phone connection.
		_http.timeout = 60.0
		var boundary := "DrawPets-%08x%08x%08x" % [randi(), randi(), randi()]
		var headers := PackedStringArray(["Content-Type: multipart/form-data; boundary=" + boundary])
		err = _http.request_raw(url, headers, HTTPClient.METHOD_POST, multipart(fields, _jpeg, boundary))
	else:
		_http.timeout = 20.0
		var headers := PackedStringArray(["Content-Type: application/x-www-form-urlencoded"])
		err = _http.request(url, headers, HTTPClient.METHOD_POST, HTTPClient.new().query_string_from_dict(fields))
	if err != OK:
		_sent_badly()
		return
	_send.disabled = true
	if _picture_button != null:
		_picture_button.disabled = true
	_status.text = "Sending..."
	_status.add_theme_color_override("font_color", UI.INK_SOFT)


func _on_sent(result: int, code: int, _h: PackedStringArray, _b: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_sent_badly()
		return
	Sounds.play("good")
	# Sent: the picture is not kept a moment longer than it has to be.
	_jpeg = PackedByteArray()
	picture = null
	if game != null:
		game.report_picture = null
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 24)
	var title := UI.title("Thank you!", 52)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var l := UI.label("It's on its way. Every message gets read.", 26)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(l)
	var done := UI.big_icon_button("tool_back", "Back", _back)
	done.custom_minimum_size = Vector2(300, 90)
	done.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(done)
	var page := Control.new()
	page.add_child(UI.paper_background())
	page.add_child(UI.full_rect(col))
	for c in get_children():
		if c != _http:
			UI.retire(c)
	add_child(UI.full_rect(page))


func _sent_badly() -> void:
	_send.disabled = false
	if _picture_button != null:
		_picture_button.disabled = false
	_status.text = "That didn't send - is this device online? Your message is still here; try again in a moment."
	_status.add_theme_color_override("font_color", UI.ACCENT.darkened(0.3))
