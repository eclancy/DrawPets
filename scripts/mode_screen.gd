class_name ModeScreen
extends Control
## The first thing a new game asks (.ai/project-overview.md): how do you want to play?
##   Beginner - looking after your pets: feeding, playing, bath day, walks, tricks, photos, and
##              gentle celebrations on the calendar. No stats, no scores, no contests.
##   Advanced - all of that, plus training stats and the competition calendar.
## Some kids are not ready for a busier game, or for competing at all, and the game should never
## make them feel that. A grown-up can switch any time in Settings (Profile.mode).

var game: GameRoot
## Called once a mode is picked.
var on_done := Callable()


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 22)
	add_child(UI.full_rect(UI.margin(col, 30)))
	var title := UI.title("How do you want to play?", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 30)
	col.add_child(row)
	row.add_child(_card("icon_heart", "Beginner",
		"Look after your pets: feed them, play, bath day, walks, tricks and photos - and fun days on the calendar.\n\nNo scores. No contests.",
		pick.bind("beginner")))
	row.add_child(_card("icon_trophy", "Advanced",
		"Everything in Beginner, plus training your pets' stats and entering competitions on the calendar.",
		pick.bind("advanced")))
	var note := UI.label("A grown-up can change this any time in Settings.", 22)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(note)


func _card(icon: String, name: String, text: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(440, 470)
	b.pressed.connect(on_press)
	var c := VBoxContainer.new()
	c.alignment = BoxContainer.ALIGNMENT_CENTER
	c.add_theme_constant_override("separation", 14)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(UI.full_rect(UI.margin(c, 22)))
	var pic := UI.icon(icon, 110, "none")
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	c.add_child(pic)
	var t := UI.title(name, 40)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c.add_child(t)
	var l := UI.label(text, 21, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(l)
	return b


func pick(mode: String) -> void:
	game.profile.set_mode(mode)
	Sounds.play("star")
	on_done.call()
