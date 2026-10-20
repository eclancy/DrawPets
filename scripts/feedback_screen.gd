class_name FeedbackScreen
extends Control
## "Report a bug or send an idea", for grown-ups - reached from Settings by a held button, like
## switching modes, so it is not a kid's chat box. The same idea as DrawFight's "Report a bug": it
## goes to ecec.dev's intake (EricClancyEngineeringAndCrafts: intake/server.js, POST
## /api/draw/pets), which saves it and emails it to Eric.
##
## Kept small on purpose (.ai/sharing.md): no name field, and a line asking for no names,
## addresses or anything personal. It sends the message, its kind and the game's version and
## platform - nothing else, and nothing a kid drew or recorded.

const KINDS := [["bug", "Something went wrong"], ["idea", "An idea"], ["other", "Something else"]]
const MAX_CHARS := 2000
## Points the game at a test copy of the intake instead.
const SITE_OVERRIDE := "DRAWPETS_SITE"

var game: GameRoot
var on_back := Callable()

var _kind := "bug"
var _kind_buttons := {}
var _text: TextEdit
var _send: Button
var _status: Label
var _http: HTTPRequest


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

	_text = TextEdit.new()
	_text.placeholder_text = "What were you doing, and what happened? Or: what's your idea?"
	_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.add_theme_font_size_override("font_size", 24)
	# The game's paper card and ink, not Godot's dark default.
	for state in ["normal", "focus", "read_only"]:
		_text.add_theme_stylebox_override(state, UI._box(UI.CARD, UI.INK, 3))
	_text.add_theme_color_override("font_color", UI.INK)
	_text.add_theme_color_override("font_placeholder_color", UI.INK_SOFT)
	_text.add_theme_color_override("caret_color", UI.INK)
	_text.add_theme_color_override("selection_color", Color(UI.ACCENT, 0.35))
	_text.text_changed.connect(_on_typed)
	col.add_child(_text)

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 18)
	_send = UI.big_icon_button("tool_done", "Send", send)
	_send.custom_minimum_size = Vector2(260, 84)
	bottom.add_child(_send)
	_status = UI.label("", 22, true)
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(_status)
	col.add_child(bottom)

	_http = HTTPRequest.new()
	_http.timeout = 20.0
	add_child(_http)
	_http.request_completed.connect(_on_sent)
	_pick(_kind)
	_on_typed()
	_text.grab_focus()


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


func send() -> void:
	var message := _text.text.strip_edges()
	if message == "":
		return
	var body := HTTPClient.new().query_string_from_dict({
		"kind": _kind,
		"message": message,
		"version": UpdateScreen.current_version(),
		"platform": platform(),
	})
	var headers := PackedStringArray(["Content-Type: application/x-www-form-urlencoded"])
	if _http.request(_site() + "/api/draw/pets", headers, HTTPClient.METHOD_POST, body) != OK:
		_sent_badly()
		return
	_send.disabled = true
	_status.text = "Sending..."
	_status.add_theme_color_override("font_color", UI.INK_SOFT)


func _on_sent(result: int, code: int, _h: PackedStringArray, _b: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_sent_badly()
		return
	Sounds.play("good")
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
	_status.text = "That didn't send - is this device online? Your message is still here; try again in a moment."
	_status.add_theme_color_override("font_color", UI.ACCENT.darkened(0.3))
