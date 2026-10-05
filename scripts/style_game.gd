class_name StyleGame
extends Node2D
## Style Show - CHARM (.ai/competitions.md). Today's theme is a clothing word ("cozy",
## "spooky"...). Dress the pet - clothes with the theme word score - then it walks the runway,
## and the kid taps to POSE when it is in the spotlight. Charm, the outfit and the poses make
## the score. The judges never look at the drawing: only what the kid chose and how they played.

signal finished(scores: Array)

const POSES := 3

var screen: CompetitionScreen

var _theme := ""
var _pet: Creature
var _state := "dress"
var _t := 0.0
var _poses := 0
var _pose_points := 0.0
var _spot_x := 640.0
var _msg: Label
var _dress_ui: Control
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = Events.seed_of(screen.event, screen.tier) + 11
	_theme = Events.theme(screen.event)
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	_pet = CompetitionScreen.racer(screen.pet)
	_pet.driven = true
	_pet.position = Vector2(640, 610)
	add_child(_pet)
	_build_hud()


func _draw() -> void:
	draw_rect(Rect2(-100, -100, 1480, 920), Color("#ece4f6"))
	var runway := PackedVector2Array([Vector2(-100, 560), Vector2(1380, 560), Vector2(1380, 680), Vector2(-100, 680)])
	Crayon.pencil_fill(self, runway, Color("#f2a7c3"), 41)
	for i in 9:
		Crayon.fill_blob(self, Vector2(60 + i * 150, 500), Vector2(36, 26), Color("#d6cbe9"), 50 + i, 0.2)
	if _state == "walk":
		var cone := PackedVector2Array([Vector2(_spot_x - 30, -20), Vector2(_spot_x + 30, -20),
			Vector2(_spot_x + 120, 640), Vector2(_spot_x - 120, 640)])
		draw_colored_polygon(cone, Color(1, 0.96, 0.7, 0.45))
		draw_colored_polygon(Crayon.ellipse(Vector2(_spot_x, 625), Vector2(120, 26)), Color(1, 0.95, 0.6, 0.6))


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.full_rect(root))
	_msg = UI.title("Today's theme: %s!" % _theme.to_upper(), 44)
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = 24
	root.add_child(_msg)

	_dress_ui = VBoxContainer.new()
	_dress_ui.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_dress_ui.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_dress_ui.offset_top = -200
	_dress_ui.offset_left = 20
	_dress_ui.offset_right = -20
	root.add_child(_dress_ui)
	var hint := UI.title("Dress up! Clothes that are %s score points. Then walk the runway." % _theme, 22)
	_dress_ui.add_child(hint)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var game := screen.game
	for id in Items.available(game.profile, "clothing"):
		var item := Items.get_item(id)
		var b := Button.new()
		b.custom_minimum_size = Vector2(96, 96)
		var pic := UI.item_picture(item, 80)
		pic.position = Vector2(8, 8)
		b.add_child(pic)
		if item.get("words", []).has(_theme):
			var star := UI.icon("icon_star", 28, "none")
			star.position = Vector2(64, 4)
			b.add_child(star)
		b.pressed.connect(func(): wear(item))
		row.add_child(b)
	if row.get_child_count() == 0:
		row.add_child(UI.label("No clothes yet - the shop has lots! You can still walk.", 22))
	var walk := UI.big_button("Walk the runway!", start_walk)
	walk.custom_minimum_size = Vector2(320, 84)
	row.add_child(walk)
	_dress_ui.add_child(row)


func wear(item: Dictionary) -> void:
	Wardrobe.put_on(screen.pet, item)
	_pet.rebuild()
	_pet.say("star")
	PetStore.save_pet(screen.pet)


func start_walk() -> void:
	_dress_ui.visible = false
	_state = "walk"
	_t = 0.0
	_pet.position = Vector2(80, 610)
	_msg.text = "Tap to POSE in the spotlight!"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap()


func tap() -> void:
	if _state != "walk" or _poses >= POSES:
		return
	_poses += 1
	var miss := absf(_pet.position.x - _spot_x)
	var points := 10.0 if miss < 60.0 else (6.0 if miss < 130.0 else 2.0)
	_pose_points += points
	_msg.text = "Perfect pose!" if points >= 10.0 else ("Nice!" if points >= 6.0 else "Oops - out of the light!")
	_pet.perform("celebrate", 0.6)
	_pet.say("star" if points >= 6.0 else "question")


func _process(delta: float) -> void:
	_t += delta
	if _state != "walk":
		_pet.drive_velocity = Vector2.ZERO
		return
	_spot_x = 640.0 + sin(_t * 1.6) * 430.0
	queue_redraw()
	_pet.drive_velocity = Vector2(130.0, 0.0) if _pet.action() == "" else Vector2.ZERO
	if _pet.position.x > 1200.0:
		_state = "done"
		_pet.drive_velocity = Vector2.ZERO
		_score()


func _score() -> void:
	var match_points := 0.0
	for entry in screen.pet.get("outfit", []):
		if Items.get_item(entry.get("item", "")).get("words", []).has(_theme):
			match_points += 10.0
	match_points = minf(match_points, 20.0)
	var total := Stats.value(screen.pet, "charm") * 0.45 + match_points + _pose_points
	_msg.text = "The judges say... %d points!" % int(total)
	var scores := [{"who": "player", "score": total}]
	for i in screen.rivals.size():
		var charm := Stats.value(screen.rivals[i]["pet"], "charm")
		scores.append({"who": i, "score": charm * 0.45 + _rng.randf_range(4.0, 16.0) + _rng.randf_range(8.0, 26.0)})
	await get_tree().create_timer(2.0).timeout
	finished.emit(scores)
