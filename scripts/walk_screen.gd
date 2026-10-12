class_name WalkScreen
extends Node2D
## A walk (.ai/places.md): one pet trots along its home's place - on and on, the place repeating
## - and the camera follows. Tap ahead and it runs there; tap behind and it turns back.
##
## Now and then a glint in the grass: it sniffs, digs (muddy paws), and up comes a present. Tap
## the present and it asks "What's inside? Draw it!" with a hint - "It's a BOUNCY toy" - and that
## word already picked, and the drawing becomes a real toy, snack or thing for the home. Three
## presents a day, a star each when it is drawn (GameRoot.present_drawn).

## What a present can be, and the words it might be.
const ASK := {
	"toy": ["bouncy", "squeaky", "stretchy", "floaty", "soft", "spinny", "rolly", "chewy", "glowy"],
	"food": ["sweet", "crunchy", "juicy", "spicy", "fishy", "weird", "cold", "chewy"],
	"furniture": ["cozy", "bouncy", "climbable", "hidey", "musical", "slidey", "glowy", "splashy"],
}
const KIND := {"toy": "toy", "food": "snack", "furniture": "thing for its home"}
const TILE := 1280.0
const TILES := 6
const PRESENTS_A_DAY := 3
## How many glints one walk hides, at most.
const GLINTS := 2

var game: GameRoot
var home: Dictionary
var pet_id := ""

var pet: Dictionary
var creature: Creature
var _cam: Camera2D
var _zoom := 1.0
var _world: Node2D
var _glints: Array[Glint] = []
var _present: Sprite2D
var _present_t := 0.0
var _hint: Label
var _hint_time := 6.0
var _hud_root: Control
var _ending := false
var _walked := 0.0
var _last_x := 0.0
var _mud_kind := ""


func _ready() -> void:
	pet = PetStore.load_pet(pet_id)
	Stats.ensure(pet)
	var place_id: String = home["place"]
	_mud_kind = Mud.kind_for(place_id)
	for k in TILES:
		var painter := PlacePainter.new()
		painter.place_id = place_id
		painter.tile = k
		painter.position.x = k * TILE
		add_child(painter)
	_world = Node2D.new()
	_world.y_sort_enabled = true
	add_child(_world)

	creature = Creature.new()
	creature.bounds = Rect2(120, 470, TILE * TILES - 240, 150)
	creature.wander = false
	creature.in_water = Places.get_place(place_id).get("water", false)
	creature.position = Vector2(260, 560)
	_world.add_child(creature)
	creature.setup(pet)
	creature.audible = true
	creature.emote.connect(_on_emote)
	_last_x = creature.position.x
	Journal.add_once(pet, "first_walk", "Went for its first walk.")

	_zoom = PlaceScreen.ZOOM.get(pet.get("size", "medium"), 1.0)
	_cam = Camera2D.new()
	_cam.zoom = Vector2(_zoom, _zoom)
	_cam.limit_left = 0
	_cam.limit_top = 0
	_cam.limit_right = int(TILE * TILES)
	_cam.limit_bottom = 720 + int(PlaceScreen.CAM_DROP)
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 3.0
	_cam.position = _cam_target()
	add_child(_cam)
	_cam.make_current()

	_hide_presents()
	_build_hud()
	_show_hint("Off for a walk! Tap ahead to run there, tap behind to turn back.")


## Glints in the grass along the way - as many as there are presents left today, two at most.
func _hide_presents() -> void:
	var found := int(game.profile.today().get("present_found", 0))
	var n := mini(GLINTS, PRESENTS_A_DAY - found)
	for i in n:
		var g := Glint.new()
		g.position = Vector2(TILE * (1.4 + i * 2.1) + randf_range(0, 500), randf_range(500, 600))
		_world.add_child(g)
		_glints.append(g)


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	_hud_root = Control.new()
	_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(UI.fit_safe(_hud_root))
	var back := UI.icon_button("icon_home", "Home", go_home, 40, Vector2(92, 84))
	back.position = Vector2(12, 12)
	_hud_root.add_child(back)
	var title := UI.title("Out for a walk with %s" % pet["name"], 30)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.offset_top = 16
	_hud_root.add_child(title)
	_hint = UI.title("", 22)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_hint.offset_left = -330
	_hint.offset_right = 330
	_hint.offset_top = 60
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_root.add_child(_hint)


func fit_safe_area() -> void:
	if _hud_root != null:
		UI.fit_safe(_hud_root)


func _show_hint(text: String) -> void:
	_hint.text = text
	_hint.modulate.a = 1.0
	_hint_time = 6.0


func _cam_target() -> Vector2:
	var y := 360.0 + PlaceScreen.CAM_DROP
	if _zoom > 1.01:
		y = creature.position.y - creature.height_px * 0.5
	return Vector2(creature.position.x + 160.0 / _zoom, y)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	tap(get_global_mouse_position())


## A tap: on the present it opens; on the ground the pet runs there.
func tap(at: Vector2) -> void:
	if _present != null and at.distance_to(_present.get_parent().global_position + Vector2(0, -45)) < 75.0:
		open_present()
		return
	if _ending or at.y < Places.HORIZON or creature.action() in ["dig", "sniff"]:
		return
	creature.interrupt()
	creature.go_to(at, Callable(), true)


func _process(delta: float) -> void:
	_hint_time -= delta
	if _hint_time < 1.0:
		_hint.modulate.a = maxf(0.0, _hint_time)
	_cam.position = _cam_target()
	_walked += absf(creature.position.x - _last_x)
	_last_x = creature.position.x
	if _walked > 700.0:
		_walked = 0.0
		_train("stamina", 0.5)
	if _present != null:
		_present_t += delta
		_present.position.y = -absf(sin(_present_t * 3.0)) * 10.0 * exp(-_present_t * 0.6)
	if _ending:
		return
	# Sniffed out a glint?
	for g in _glints:
		if absf(g.position.x - creature.position.x) < 110.0 and absf(g.position.y - creature.position.y) < 90.0:
			_find(g)
			return
	if creature.position.x > creature.bounds.end.x - 60.0:
		_the_end()
		return
	# Trots on ahead by itself - unless a present is waiting, when it sits by it.
	if not creature.is_busy():
		if _present != null and creature.position.distance_to(_present.get_parent().position) < 260.0:
			creature.face_toward(_present.get_parent().position.x)
			creature.perform("look", 1.5)
		else:
			# Its nose leads it towards a glint up ahead.
			var y := creature.position.y + randf_range(-50, 50)
			for g in _glints:
				var ahead := g.position.x - creature.position.x
				if ahead > 0.0 and ahead < 700.0:
					y = lerpf(creature.position.y, g.position.y, 0.6)
			creature.go_to(Vector2(creature.position.x + 240.0, y))


# --- Presents --------------------------------------------------------------------------------

func _find(g: Glint) -> void:
	_glints.erase(g)
	creature.interrupt()
	var side := signf(g.position.x - creature.position.x)
	if side == 0.0:
		side = 1.0
	creature.go_to(g.position - Vector2(side * (creature.mouth_reach() + 10.0), -2.0), _sniff_at.bind(g))


func _sniff_at(g: Glint) -> void:
	creature.face_toward(g.position.x)
	Sounds.play_varied("sniff", creature._size_pitch())
	creature.perform("sniff", 0.9, _dig_at.bind(g))
	creature.say("question")


func _dig_at(g: Glint) -> void:
	for i in 4:
		get_tree().create_timer(i * 0.5).timeout.connect(Sounds.play_varied.bind("scratch", 0.8, 0.06, -2.0))
	creature.perform("dig", 2.0, _dug_up.bind(g))


## Up comes a present - and its digger's paws are muddy.
func _dug_up(g: Glint) -> void:
	var at := g.position
	g.queue_free()
	game.profile.count_today("present_found", 99)
	Journal.add(pet, "Dug up a present on a walk!")
	if Mud.splat(pet, 1, "front", _mud_kind) > 0:
		creature.refresh_mud()
	var holder := Node2D.new()
	holder.position = at + Vector2(0, 2)
	_world.add_child(holder)
	_present = Sprite2D.new()
	var tex := Items.art_texture("prop_present")
	_present.texture = tex
	_present.offset = Vector2(0, -tex.get_height() * 0.5)
	_present.scale = Vector2.ONE * (96.0 / maxf(tex.get_width(), tex.get_height()))
	holder.add_child(_present)
	_present_t = 0.0
	Sounds.play("sparkle")
	creature.perform("celebrate", 1.2)
	creature.say("star")
	_show_hint("A present! Tap it to see what's inside.")


## "What's inside? Draw it!" - a kind of thing and one word for it, that word already picked.
## (The demo asks for a particular one.)
func open_present(cat := "", word := "") -> void:
	if _present == null:
		return
	if cat == "":
		cat = ["toy", "toy", "food", "furniture"].pick_random()
	if word == "":
		word = ASK[cat].pick_random()
	Sounds.play("pickup")
	_present = null
	_save()
	game.make_item(cat, game.present_drawn.bind(home["id"], pet_id),
		"What's inside the present? Draw it! It's a %s %s." % [word.to_upper(), KIND[cat]], [word])


# --- The end of the walk ---------------------------------------------------------------------

func _the_end() -> void:
	_ending = true
	creature.stop()
	creature.perform("celebrate", 1.6)
	creature.say("heart")
	_show_hint("What a walk! Home time.")
	get_tree().create_timer(2.6).timeout.connect(go_home)


func go_home() -> void:
	if not is_inside_tree():
		return
	_save()
	game.go_place(home["id"], pet_id)


## Android's back gesture: home, like the Home button.
func go_back() -> void:
	go_home()


func _save() -> void:
	PetStore.change_need(pet, "fun", 0.2)
	PetStore.change_need(pet, "energy", -0.08)
	PetStore.save_pet(pet)


func _exit_tree() -> void:
	PetStore.save_pet(pet)


func _train(stat: String, amount: float) -> void:
	var levels := Stats.train(pet, stat, amount)
	if levels > 0:
		Sounds.play("level_up")
		creature.say("star")
		game.reward(3 * levels, "%s's %s is level %d!" % [pet["name"], Stats.label(stat),
			Stats.level(Stats.value(pet, stat))])


func _on_emote(kind: String, at: Vector2) -> void:
	var e := Emote.new()
	e.kind = kind
	e.position = at
	add_child(e)


## A glint in the grass where a present is buried: three pale pencil twinkles taking turns.
class Glint extends Node2D:
	var _t := 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		for i in 3:
			var at := Vector2((i - 1) * 22.0, -8.0 - (i % 2) * 14.0)
			var a := clampf(0.5 + 0.5 * sin(_t * 4.0 + i * 2.1), 0.0, 1.0)
			var r := 8.0 + 6.0 * a
			var pts := PackedVector2Array()
			for k in 8:
				var rr := r if k % 2 == 0 else r * 0.3
				var ang := -PI / 2.0 + k * PI / 4.0
				pts.append(at + Vector2(cos(ang), sin(ang)) * rr)
			draw_colored_polygon(pts, Color(1.0, 0.97, 0.8, 0.5 + 0.5 * a))
			pts.append(pts[0])
			draw_polyline(pts, Color(0.95, 0.75, 0.3, 0.4 + 0.5 * a), 2.0, true)
