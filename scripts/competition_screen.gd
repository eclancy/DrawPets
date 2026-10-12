class_name CompetitionScreen
extends Node2D
## A competition, start to finish: meet the rivals, play the event's mini-game, then the
## podium, ribbons and prizes (.ai/competitions.md).
##
## Every event mixes the pet's stat with the kid's timing, so a well-trained pet does well even
## with clumsy tapping, and great tapping can carry a pet a cup above its training. Every
## mini-game emits `finished` with [{who: "player" or a rival index, score}] - higher is better.

var game: GameRoot
var event: Dictionary
var tier := 0
var pet: Dictionary
var rivals: Array = []

var _layer: CanvasLayer
var _overlay: Control
var _mini: Node2D


func _ready() -> void:
	Stats.ensure(pet)
	rivals = Rivals.field(event["kind"], tier, 3, Events.seed_of(event, tier))
	_layer = CanvasLayer.new()
	_layer.layer = 10
	add_child(_layer)
	_intro()


func _clear_overlay() -> void:
	if _overlay != null:
		_overlay.queue_free()
	_overlay = Control.new()
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(UI.full_rect(_overlay))


## Everyone who is taking part, the kid's pet first.
func entrants() -> Array:
	var out := [{"who": "player", "name": pet["name"], "pet": pet}]
	for i in rivals.size():
		out.append({"who": i, "name": rivals[i]["name"], "pet": rivals[i]["pet"]})
	return out


func _intro() -> void:
	_clear_overlay()
	_overlay.add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	_overlay.add_child(UI.full_rect(UI.margin(col, 24)))
	var info := Events.info(event["kind"])
	var stat: String = info["stat"]
	var top := HBoxContainer.new()
	top.add_child(UI.icon(Stats.INFO[stat]["icon"], 72))
	top.add_child(UI.title("%s - %s" % [info["name"], Events.TIERS[tier]["name"]], 42))
	col.add_child(top)
	col.add_child(UI.label(info["how"], 26, true))
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	for e in entrants():
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(250, 300)
		if e["who"] is String:
			card.add_theme_stylebox_override("panel", UI._box(Color("#fff0c2"), UI.ACCENT, 5))
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(230, 280)
		card.add_child(holder)
		var c := Creature.new()
		c.wander = false
		c.confine = false
		c.depth_scale = false
		c.position = Vector2(115, 210)
		holder.add_child(c)
		c.setup(e["pet"], 150.0)
		if not (e["who"] is String):
			c.facing = -1.0
		var l := UI.label("%s\n%s Lv%d" % [e["name"], Stats.label(stat), Stats.level(Stats.value(e["pet"], stat))], 20)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.position = Vector2(0, 220)
		l.size = Vector2(230, 56)
		holder.add_child(l)
		row.add_child(card)
	col.add_child(row)
	col.add_child(UI.big_button("Ready!", _start))


func _start() -> void:
	_clear_overlay()
	var kind: String = event["kind"]
	match Events.info(kind)["game"]:
		"track":
			var t := TrackGame.new()
			t.mode = kind
			_mini = t
		"tug":
			_mini = TugGame.new()
		"tricks":
			_mini = TrickGame.new()
		"style":
			_mini = StyleGame.new()
	_mini.set("screen", self)
	_mini.connect("finished", _results)
	add_child(_mini)


## Places, prizes, ribbons, training - then the podium.
func _results(scores: Array) -> void:
	scores.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	var place := 1
	for i in scores.size():
		if scores[i]["who"] is String:
			place = i + 1
	var p := game.profile
	var key := Events.result_key(event, tier)
	var first_try: bool = not p.data["results"].has(key)
	var practice: bool = event.get("practice", false)
	if not practice:
		var prev := int(p.data["results"].get(key, 99))
		p.data["results"][key] = mini(prev, place)
		p.save()
	var stat: String = Events.info(event["kind"])["stat"]
	var gained := Stats.train(pet, stat, 3.0 if place == 1 else 2.0)
	pet["love"] = int(pet.get("love", 0)) + 1
	PetStore.change_need(pet, "energy", -0.15)
	PetStore.save_pet(pet)

	var prize: Array = Events.TIERS[tier]["prize"]
	if practice:
		game.reward_daily("fair", 3, 1, "Practice makes perfect!")
	elif first_try:
		game.reward(prize[place - 1], "%s place in the %s!" % [_ordinal(place), Events.TIERS[tier]["name"]])
	else:
		game.reward_daily("rematch", 3, 1, "Good try!")
	if gained > 0:
		game.reward(3 * gained, "%s's %s went up!" % [pet["name"], Stats.label(stat)])
	if place == 1 and tier >= 2 and p.owned("neck_medal") == 0:
		p.give("neck_medal")
		game.toast("You won a GOLD MEDAL for %s to wear!" % pet["name"], "icon_trophy")
	_podium(scores, place)


func _podium(scores: Array, place: int) -> void:
	Sounds.play("fanfare" if place == 1 else "ribbon")
	if _mini != null:
		_mini.queue_free()
		_mini = null
	get_viewport().canvas_transform = Transform2D.IDENTITY
	_clear_overlay()
	_overlay.add_child(UI.paper_background())
	var stage := Control.new()
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(UI.full_rect(stage))

	var title := UI.title("You came %s!" % _ordinal(place) if place <= 3 else "What a race - well done!", 48)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.offset_top = 20
	stage.add_child(title)

	var podium := Sprite2D.new()
	podium.texture = Items.art_texture("prop_podium")
	podium.centered = false
	var pimg := podium.texture.get_image()
	var k := 460.0 / maxf(pimg.get_width(), 1.0)
	podium.scale = Vector2(k, k)
	podium.position = Vector2(640.0 - pimg.get_width() * k / 2.0, 640.0 - pimg.get_height() * k)
	stage.add_child(podium)
	var tops := [Vector2(640, 640 - pimg.get_height() * k * 0.92), Vector2(640 - 155, 640 - pimg.get_height() * k * 0.62),
		Vector2(640 + 155, 640 - pimg.get_height() * k * 0.45)]
	var all := entrants()
	for i in mini(3, scores.size()):
		var e: Dictionary = all[0] if scores[i]["who"] is String else all[int(scores[i]["who"]) + 1]
		var c := Creature.new()
		c.wander = false
		c.confine = false
		c.depth_scale = false
		c.position = tops[i]
		stage.add_child(c)
		c.setup(e["pet"], 130.0 - i * 10.0)
		if i == 0:
			c.perform("celebrate", 99.0)
			c.say("star")
		else:
			c.perform("greet", 99.0)
		var ribbon := UI.icon("icon_ribbon_%d" % (i + 1), 56, "none")
		ribbon.position = tops[i] + Vector2(-28, 10)
		stage.add_child(ribbon)
		var name := UI.title(e["name"], 22)
		name.position = tops[i] + Vector2(-60, 66)
		stage.add_child(name)

	var list := VBoxContainer.new()
	list.position = Vector2(40, 140)
	for i in scores.size():
		var e: Dictionary = all[0] if scores[i]["who"] is String else all[int(scores[i]["who"]) + 1]
		var l := UI.label("%d. %s" % [i + 1, e["name"]], 24)
		if scores[i]["who"] is String:
			l.add_theme_color_override("font_color", UI.ACCENT)
		list.add_child(l)
	stage.add_child(list)

	var buttons := HBoxContainer.new()
	buttons.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	buttons.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	buttons.grow_vertical = Control.GROW_DIRECTION_BEGIN
	buttons.offset_right = -24
	buttons.offset_bottom = -24
	buttons.add_theme_constant_override("separation", 12)
	buttons.add_child(UI.icon_button("tool_undo", "Try again", func(): game.go_competition(event, tier, pet["id"]), 44, Vector2(130, 96)))
	buttons.add_child(UI.big_icon_button("icon_calendar", "Calendar", func(): game.go_calendar()))
	stage.add_child(buttons)


static func _ordinal(n: int) -> String:
	return ["1st", "2nd", "3rd", "4th", "5th"][clampi(n - 1, 0, 4)]


## A creature for a mini-game: driven by the game, not wandering, sized fairly so every racer
## can be seen - tiny ones a bit bigger than life, giant ones a bit smaller.
static func racer(p: Dictionary) -> Creature:
	var c := Creature.new()
	c.wander = false
	c.confine = false
	c.depth_scale = false
	c.driven = true
	c.audible = true
	var f: float = Creature.SIZES.get(p.get("size", "medium"), 1.0)
	c.setup(p, clampf(Creature.STANDARD_HEIGHT * f, 90.0, 170.0))
	return c
