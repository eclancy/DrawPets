class_name UI
extends RefCounted
## The look of every menu, built in code. Text is dark indigo, never black: kids' drawings own
## black (see .ai/art-direction.md), and a black button label competes with their linework.
##
## Everything is sized for a thumb on a phone held sideways - nothing tappable is smaller
## than about 64 px at the 1280x720 design size.

const INK := Color("#3b3566")
const INK_SOFT := Color("#6b6593")
const PAPER := Color("#f6f1e4")
const CARD := Color("#fffdf7")
const HILITE := Color("#ffe27a")
const ACCENT := Color("#ff8a5c")
const GOOD := Color("#7cc96b")

## The crayon box. Black is here on purpose - it is the kids' colour, not ours.
const PALETTE := [
	Color("#1f1d24"), Color("#ffffff"), Color("#e23b3b"), Color("#f28c28"),
	Color("#f7d038"), Color("#8fd14f"), Color("#2e9e4f"), Color("#5bc0eb"),
	Color("#2f5bd3"), Color("#8a4fd1"), Color("#f27fb2"), Color("#8b5a2b"),
	Color("#9a9a9a"), Color("#f6c59a"),
]


static func make_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 26

	theme.set_stylebox("normal", "Button", _box(CARD, INK, 3))
	theme.set_stylebox("hover", "Button", _box(Color("#fff6d6"), INK, 3))
	theme.set_stylebox("pressed", "Button", _box(HILITE, INK, 4))
	theme.set_stylebox("hover_pressed", "Button", _box(HILITE, INK, 4))
	theme.set_stylebox("disabled", "Button", _box(Color("#ece7da"), INK_SOFT, 2))
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
			"font_hover_pressed_color"]:
		theme.set_color(state, "Button", INK)
	theme.set_color("font_disabled_color", "Button", INK_SOFT)

	theme.set_color("font_color", "Label", INK)

	theme.set_stylebox("normal", "LineEdit", _box(CARD, INK, 3))
	theme.set_stylebox("focus", "LineEdit", _box(Color.WHITE, ACCENT, 4))
	theme.set_color("font_color", "LineEdit", INK)
	theme.set_color("font_placeholder_color", "LineEdit", INK_SOFT)
	theme.set_font_size("font_size", "LineEdit", 34)

	theme.set_stylebox("panel", "PanelContainer", _box(CARD, INK, 3))
	theme.set_stylebox("panel", "Panel", _box(CARD, INK, 3))

	theme.set_stylebox("background", "ProgressBar", _box(Color("#ece7da"), INK, 2, 8, 0))
	theme.set_stylebox("fill", "ProgressBar", _box(GOOD, INK, 0, 8, 0))
	return theme


static func _box(bg: Color, border: Color, width: int, radius := 16, margin := 14) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = margin
	box.content_margin_right = margin
	box.content_margin_top = margin * 0.6
	box.content_margin_bottom = margin * 0.6
	box.anti_aliasing = true
	return box


static func button(text: String, on_press: Callable, min_size := Vector2(0, 72),
		font_size := 28) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size", font_size)
	b.pressed.connect(on_press)
	return b


## A big friendly call to action, in the accent colour.
static func big_button(text: String, on_press: Callable) -> Button:
	var b := button(text, on_press, Vector2(0, 84), 32)
	b.add_theme_stylebox_override("normal", _box(ACCENT, INK, 4))
	b.add_theme_stylebox_override("hover", _box(Color("#ff9f78"), INK, 4))
	b.add_theme_stylebox_override("pressed", _box(Color("#f07040"), INK, 5))
	return b


static func label(text: String, font_size := 28, wrap := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## A heading with a thick paper-coloured outline, so it reads on any background.
static func title(text: String, font_size := 44) -> Label:
	var l := label(text, font_size)
	l.add_theme_color_override("font_outline_color", PAPER)
	l.add_theme_constant_override("outline_size", 10)
	return l


static func margin(child: Control, all := 24) -> MarginContainer:
	var m := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, all)
	m.add_child(child)
	return m


static func full_rect(c: Control) -> Control:
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return c


## The game's own drawing of an icon (art/wear/icon_*.png), `px` square. Shiny ones sparkle.
static func icon(id: String, px := 48.0, shine := "") -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = Items.art_texture(id)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.custom_minimum_size = Vector2(px, px)
	rect.size = Vector2(px, px)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if shine == "" and id in ["icon_star", "icon_trophy"]:
		shine = "gold"
	if shine != "" and shine != "none":
		shine_rect(rect, rect.texture.get_image(), shine)
	return rect


## Makes a TextureRect showing `image` (keep-aspect, centred) shine and sparkle.
static func shine_rect(rect: TextureRect, image: Image, mode: String, mask: Image = null) -> void:
	var box := rect.custom_minimum_size
	var k := minf(box.x / image.get_width(), box.y / image.get_height())
	var origin := (box - Vector2(image.get_size()) * k) / 2.0
	Shiny.apply(rect, image, mode, mask, origin, k)


## A picture of an item, `px` square, shiny if the item is.
static func item_picture(item: Dictionary, px := 96.0) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = item.get("_tex")
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.custom_minimum_size = Vector2(px, px)
	rect.size = Vector2(px, px)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if item.get("shine", "") != "" and item.get("_img") != null:
		shine_rect(rect, item["_img"], item["shine"], item.get("_shine"))
	return rect


## The gold star count, kept up to date.
static func star_counter(profile: Profile, px := 44.0) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 6)
	row.add_child(icon("icon_star", px))
	var count := StarCount.new()
	count.text = str(profile.stars())
	count.add_theme_font_size_override("font_size", int(px * 0.75))
	count.add_theme_color_override("font_outline_color", PAPER)
	count.add_theme_constant_override("outline_size", 10)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(count)
	# Connected to the label's own method, so the connection goes when the screen does.
	profile.stars_changed.connect(count.show_stars)
	return row


## A row of trust hearts, filled up to `level` of 5.
static func hearts(level: int, px := 26.0) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 0)
	for i in 5:
		row.add_child(icon("icon_heart" if i < level else "icon_heart_empty", px))
	return row


## A big call-to-action button with a picture beside its words.
static func big_icon_button(icon_id: String, text: String, on_press: Callable) -> Button:
	var b := big_button("", on_press)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	full_rect(row)
	row.add_child(icon(icon_id, 52, "none"))
	var l := label(text, 32)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
	b.add_child(row)
	return b


## A button with a drawn icon above its label.
static func icon_button(id: String, text: String, on_press: Callable, px := 52.0,
		min_size := Vector2(104, 96)) -> Button:
	var b := Button.new()
	b.custom_minimum_size = min_size
	b.pressed.connect(on_press)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	full_rect(col)
	var pic := icon(id, px)
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(pic)
	if text != "":
		var l := label(text, 18)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(l)
	b.add_child(col)
	return b


## A button showing a little painting of a place, with a caption, and a padlock if it is
## still to be bought.
static func place_button(id: String, caption: String, min_size := Vector2(150, 92),
		locked := false, items := []) -> Button:
	var b := Button.new()
	b.custom_minimum_size = min_size
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.clip_contents = true
	var thumb := Control.new()
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thumb.clip_contents = true
	full_rect(thumb)
	thumb.offset_left = 5
	thumb.offset_top = 5
	thumb.offset_right = -5
	thumb.offset_bottom = -5
	b.add_child(thumb)
	var painter := PlacePainter.new()
	painter.place_id = id
	painter.animate = false
	thumb.add_child(painter)
	# A home's house and things, standing where they stand in the place.
	for entry in items:
		var item := Items.get_item(entry.get("item", ""))
		if item.is_empty():
			continue
		var s := Sprite2D.new()
		s.texture = item["_tex"]
		s.centered = false
		s.offset = -Items.pivot_of(item)
		var k := float(item.get("height", 150)) * float(entry.get("scale", 1.0)) / maxf(item["_img"].get_height(), 1.0)
		s.scale = Vector2(-k if entry.get("flip", false) else k, k)
		s.position = PetBuilder.v2(entry["pos"])
		painter.add_child(s)
	# Fill the picture whatever its shape: wide ones by width, tall ones by height, the ground
	# along the bottom either way.
	thumb.resized.connect(func():
		var k := maxf(thumb.size.x / 1280.0, thumb.size.y / 760.0)
		painter.scale = Vector2(k, k)
		painter.position = Vector2((thumb.size.x - 1280.0 * k) / 2.0, thumb.size.y - 640.0 * k))
	if locked:
		thumb.modulate = Color(0.85, 0.83, 0.9)
		var lock := icon("icon_lock", 34)
		lock.position = Vector2(8, 8)
		b.add_child(lock)
	var name := title(caption, 17)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.add_theme_constant_override("outline_size", 7)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	name.grow_horizontal = Control.GROW_DIRECTION_BOTH
	name.grow_vertical = Control.GROW_DIRECTION_BEGIN
	name.offset_bottom = -4
	b.add_child(name)
	return b


## A plain paper background for menu screens.
static func paper_background() -> ColorRect:
	var bg := ColorRect.new()
	bg.color = PAPER
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return full_rect(bg) as ColorRect


class StarCount extends Label:
	func show_stars(n: int) -> void:
		text = str(n)
