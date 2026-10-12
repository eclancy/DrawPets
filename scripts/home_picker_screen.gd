class_name HomePickerScreen
extends Control
## "Where will it live?" - a home that has a free room, or, if there is a free plot, building a
## new one (BuildHomeScreen). Pets are happiest in their favourite place and like places that
## share its words (hot, snowy...), so each home says how the pet feels about it.

var game: GameRoot
var pet: Dictionary
var on_done := Callable()
var on_cancel := Callable()
## Moving a pet: the home it already lives in is not offered.
var exclude_home := ""

var _content: Control


func _ready() -> void:
	_list()


func _swap(c: Control) -> void:
	if _content != null:
		UI.retire(_content)
	_content = c
	add_child(UI.full_rect(c))


func _list() -> void:
	var root := Control.new()
	root.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	root.add_child(UI.full_rect(UI.margin(col, 24)))
	var top := HBoxContainer.new()
	if on_cancel.is_valid():
		top.add_child(UI.icon_button("tool_back", "Back", on_cancel, 40, Vector2(100, 84)))
	top.add_child(UI.title("Where will %s live?" % pet["name"], 40))
	col.add_child(top)
	var fav: String = pet.get("place", "meadow")
	var p := game.profile

	var homes := HFlowContainer.new()
	homes.add_theme_constant_override("h_separation", 14)
	homes.add_theme_constant_override("v_separation", 14)
	for h in p.homes():
		if not p.has_room(h) or h["id"] == exclude_home:
			continue
		var caption := "%s\n%d of %d rooms - %s" % [Profile.home_name(h), h["pets"].size(), int(h["rooms"]),
			_feeling(fav, h["place"])]
		var b := UI.place_button(h["place"], caption, Vector2(300, 190))
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		b.pressed.connect(func(): on_done.call(h))
		homes.add_child(b)
	if p.free_plots() > 0:
		var build := UI.icon_button("ui_build", "Build a new home\n(%d empty plot%s)" % [p.free_plots(),
			"" if p.free_plots() == 1 else "s"], _build, 72, Vector2(300, 190))
		build.add_theme_stylebox_override("normal", UI._box(Color("#fff0c2"), UI.INK, 4))
		homes.add_child(build)
	col.add_child(homes)
	if Places.is_special(fav) and not p.place_unlocked(fav):
		var dream := UI.label("%s dreams of %s - buy it in the shop and build a home there!" % [pet["name"],
			Places.display_name(fav)], 20)
		dream.add_theme_color_override("font_color", UI.ACCENT)
		col.add_child(dream)
	_swap(root)


func _build() -> void:
	var s := BuildHomeScreen.new()
	s.game = game
	s.for_pet = pet
	s.on_done = func(h: Dictionary):
		if h.is_empty():
			_list()
		else:
			on_done.call(h)
	_swap(s)


static func _feeling(favourite: String, place: String) -> String:
	var like := Places.liking(favourite, place)
	if like >= 1.0:
		return "loves it!"
	if like >= 0.3:
		return "likes it"
	return "it's ok"
