class_name HomePickerScreen
extends Control
## "Where will it live?" - a home that has a free room, or a new home on a free plot. Pets are
## happiest in their favourite place and like places that share its words (hot, snowy...), so
## each choice says how the pet feels about it.

var game: GameRoot
var pet: Dictionary
var on_done := Callable()


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	add_child(UI.full_rect(UI.margin(col, 24)))
	col.add_child(UI.title("Where will %s live?" % pet["name"], 38))
	var fav: String = pet["place"]
	var p := game.profile

	var homes := HFlowContainer.new()
	homes.add_theme_constant_override("h_separation", 12)
	homes.add_theme_constant_override("v_separation", 12)
	var any := false
	for h in p.homes():
		if p.has_room(h):
			any = true
			var caption := "%s\n%d of %d rooms used - %s" % [Places.display_name(h["place"]), h["pets"].size(),
				int(h["rooms"]), _feeling(fav, h["place"])]
			var b := UI.place_button(h["place"], caption, Vector2(250, 150))
			b.pressed.connect(func(): on_done.call(h))
			homes.add_child(b)
	if any:
		col.add_child(UI.label("Move in with friends:", 24))
		col.add_child(homes)

	if p.homes().size() < p.home_slots():
		col.add_child(UI.label("...or build a new home (%d free plot%s):" % [p.home_slots() - p.homes().size(),
			"" if p.home_slots() - p.homes().size() == 1 else "s"], 24))
		var grid := GridContainer.new()
		grid.columns = 7
		grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		for id in Places.ORDER:
			var locked := not p.place_unlocked(id)
			var caption := Places.display_name(id) + ("\nloves it!" if id == fav else "")
			var b := UI.place_button(id, caption, Vector2(150, 100), locked)
			b.disabled = locked
			b.pressed.connect(func(): on_done.call(p.add_home(id)))
			grid.add_child(b)
		col.add_child(grid)
	if Places.is_special(fav) and not p.place_unlocked(fav):
		var dream := UI.label("%s dreams of %s - buy it in the shop and it can move there!" % [pet["name"],
			Places.display_name(fav)], 20)
		dream.add_theme_color_override("font_color", UI.ACCENT)
		col.add_child(dream)


static func _feeling(favourite: String, place: String) -> String:
	var like := Places.liking(favourite, place)
	if like >= 1.0:
		return "loves it!"
	if like >= 0.3:
		return "likes it"
	return "it's ok"
