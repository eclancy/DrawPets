class_name UIAudit
extends RefCounted
## Every word and every button on the screen, measured the way a phone shows them - the game's
## 720 units tall are about 6.5 cm on a phone held sideways, so a word in 16 px type is about a
## millimetre and a half high, and a 48 px button is smaller than a fingertip. The demo kid calls
## `scan` at each of its screenshots when run with --audit:
##
##   "$GODOT_BIN" --path . --resolution 1616x720 -- --demo --quit --audit
##
## and every word smaller than SMALL_TEXT and every button smaller than SMALL_TARGET either way is
## listed in .shots/ui_audit.txt, by the screen it is on, with the first screenshot it was seen in.
## Words and buttons that are see-through, hidden, off the screen or not for tapping are skipped.

## Smaller than this, words are hard for a kid to read on a phone (about 14 dp).
const SMALL_TEXT := 20.0
## Smaller than this either way, a button is hard to hit with a small finger (about 40 dp).
const SMALL_TARGET := 64.0
const REPORT := "res://.shots/ui_audit.txt"

## key -> {kind, screen, what, size, first, count}
static var _found := {}


## Looks over everything showing now, for the screenshot called `shot`.
static func scan(root: Node, shot: String) -> void:
	var view := Rect2(Vector2.ZERO, root.get_viewport().get_visible_rect().size)
	_scan(root, shot, view)
	_write()


static func _scan(node: Node, shot: String, view: Rect2) -> void:
	if node is CanvasItem and not (node as CanvasItem).visible:
		return
	if node is Control:
		_check(node as Control, shot, view)
	for c in node.get_children():
		_scan(c, shot, view)


static func _check(c: Control, shot: String, view: Rect2) -> void:
	if _alpha(c) < 0.2:
		return
	var xf := c.get_global_transform_with_canvas()
	var k := absf(xf.get_scale().y)
	var box := Rect2(xf.origin, c.size * k)
	if not view.intersects(box) or box.size.x < 1.0 or box.size.y < 1.0:
		return
	if c is Label and (c as Label).text.strip_edges() != "":
		_text(c, (c as Label).text, c.get_theme_font_size("font_size") * k, shot)
		_spill(c as Label, k, shot)
	elif c is RichTextLabel and (c as RichTextLabel).get_parsed_text().strip_edges() != "":
		_text(c, (c as RichTextLabel).get_parsed_text(), c.get_theme_font_size("normal_font_size") * k, shot)
	elif c is Button:
		var b := c as Button
		if b.text.strip_edges() != "":
			_text(c, b.text, b.get_theme_font_size("font_size") * k, shot)
		if not b.disabled and b.mouse_filter != Control.MOUSE_FILTER_IGNORE \
				and minf(box.size.x, box.size.y) < SMALL_TARGET:
			_note("button", c, _name_of(b), minf(box.size.x, box.size.y), shot)


## Words wider than the button they are on (bigger words in a button that stayed the same size).
static func _spill(l: Label, k: float, shot: String) -> void:
	if l.autowrap_mode != TextServer.AUTOWRAP_OFF or l.clip_text:
		return
	var b: Node = l.get_parent()
	for i in 3:
		if b == null or b is Button:
			break
		b = b.get_parent()
	if not (b is Button):
		return
	var over := l.get_minimum_size().x * k - (b as Control).size.x * absf((b as Control).get_global_transform_with_canvas().get_scale().x)
	if over > 2.0:
		_note("spills", l, l.text.strip_edges().replace("\n", " ").left(48), over, shot)


static func _text(c: Control, text: String, px: float, shot: String) -> void:
	if px < SMALL_TEXT:
		_note("text", c, text.strip_edges().replace("\n", " ").left(48), px, shot)


static func _note(kind: String, c: Control, what: String, px: float, shot: String) -> void:
	var screen := _screen_of(c)
	var key := "%s|%s|%s|%d" % [kind, screen, what, roundi(px)]
	if _found.has(key):
		_found[key]["count"] += 1
		return
	_found[key] = {"kind": kind, "screen": screen, "what": what, "size": px, "first": shot, "count": 1}


## The nearest named screen or panel it is part of: "PetPanel < PlaceScreen".
static func _screen_of(n: Node) -> String:
	var names := []
	var p := n
	while p != null and names.size() < 2:
		var s: Script = p.get_script()
		if s != null and s.get_global_name() != "":
			var gn := String(s.get_global_name())
			if not names.has(gn):
				names.append(gn)
		p = p.get_parent()
	return " < ".join(names) if not names.is_empty() else "?"


## A button's words, or the picture on it.
static func _name_of(b: Button) -> String:
	if b.text.strip_edges() != "":
		return b.text.strip_edges().left(40)
	for c in b.find_children("*", "Label", true, false):
		if (c as Label).text.strip_edges() != "":
			return "[%s]" % (c as Label).text.strip_edges().left(40)
	for c in b.find_children("*", "TextureRect", true, false):
		var t: Texture2D = (c as TextureRect).texture
		if t != null and t.resource_path != "":
			return "<%s>" % t.resource_path.get_file().get_basename()
	return "(%s)" % b.name


## How see-through it is, counting everything it sits in.
static func _alpha(c: CanvasItem) -> float:
	var a := c.self_modulate.a
	var p: Node = c
	while p is CanvasItem:
		a *= (p as CanvasItem).modulate.a
		p = p.get_parent()
	return a


## By screen, then words before buttons, then smallest first.
static func _before(a: Dictionary, b: Dictionary) -> bool:
	if a["screen"] != b["screen"]:
		return str(a["screen"]) < str(b["screen"])
	if a["kind"] != b["kind"]:
		return str(a["kind"]) > str(b["kind"])
	return float(a["size"]) < float(b["size"])


static func _write() -> void:
	var rows: Array = _found.values()
	rows.sort_custom(_before)
	var out := PackedStringArray()
	out.append("Too small on a phone: words under %d px, buttons under %d px either way; words spilling out of their button (by how many px)." % [SMALL_TEXT, SMALL_TARGET])
	out.append("screen | kind | size | what | first seen in (times seen)")
	for r in rows:
		out.append("%s | %s | %d | %s | %s (%d)" % [r["screen"], r["kind"], roundi(r["size"]), r["what"],
			r["first"], r["count"]])
	var f := FileAccess.open(REPORT, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(out) + "\n")
		f.close()
