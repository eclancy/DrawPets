class_name TugGame
extends Node2D
## Tug-of-War Cup - STRENGTH (.ai/competitions.md). Three rounds, one rival each, weakest
## first; lose a round and the cup is over. Both pets pull with their strength; the kid taps
## HEAVE! when the ring is at its biggest for a big pull. Drag the ribbon past your line to win.

signal finished(scores: Array)

const LINE := 150.0

var screen: CompetitionScreen

var _round := 0
var _wins := 0
var _m := 0.0
var _heave := 0.0
var _rival_heave := 0.0
var _t := -2.4
var _over := false
var _player: Creature
var _rival: Creature
var _rope: Sprite2D
var _ring: RingMeter
var _msg: Label
var _round_label: Label
var _rng := RandomNumberGenerator.new()
var _next_rival_heave := 1.0


func _ready() -> void:
	_rng.seed = Events.seed_of(screen.event, screen.tier) + 7
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	_rope = Sprite2D.new()
	_rope.texture = Items.art_texture("prop_rope_long")
	_rope.z_index = 2
	add_child(_rope)
	_player = CompetitionScreen.racer(screen.pet)
	_player.position = Vector2(400, 610)
	_player.z_index = 1
	add_child(_player)
	_build_hud()
	_new_round()


func _new_round() -> void:
	if _rival != null:
		_rival.queue_free()
	var r: Dictionary = screen.rivals[_round]
	_rival = CompetitionScreen.racer(r["pet"])
	_rival.position = Vector2(880, 610)
	_rival.facing = -1.0
	_rival.z_index = 1
	add_child(_rival)
	_m = 0.0
	_t = -1.6
	_over = false
	_round_label.text = "Round %d of 3 - vs %s" % [_round + 1, r["name"]]
	_player.perform("tug", 999.0)
	_rival.perform("tug", 999.0)


func _draw() -> void:
	Crayon.sky(self, Rect2(-100, -100, 1480, 560), Color("#a9d8f2"), Color("#e9f6fa"))
	var hills := PackedVector2Array([Vector2(-100, 470)])
	for i in 18:
		hills.append(Vector2(-100 + i * 90, 430.0 - 40.0 * (0.6 + 0.4 * sin(i * 0.8))))
	hills.append(Vector2(1500, 470))
	Crayon.fill(self, hills, Color("#b5df95"), 9, 14.0, 0.0, 7.0)
	draw_rect(Rect2(-100, 455, 1480, 400), Color("#c6e89d"))
	for x in [640.0 - LINE, 640.0 + LINE]:
		Crayon.line(self, Vector2(x, 520), Vector2(x, 700), Color(1, 1, 1, 0.9), 7.0, int(x), 2.0)
	Crayon.line(self, Vector2(640, 540), Vector2(640, 690), Color(1, 1, 1, 0.5), 4.0, 2, 2.0)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.full_rect(root))
	_round_label = UI.title("", 34)
	_round_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_round_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_round_label.offset_top = 20
	root.add_child(_round_label)
	_msg = UI.title("", 52)
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = 120
	root.add_child(_msg)
	_ring = RingMeter.new()
	_ring.style = "pulse"
	_ring.zone = Vector2(0.82, 1.0)
	_ring.label = "HEAVE!"
	_ring.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_ring.offset_left = -210
	_ring.offset_right = -50
	_ring.offset_top = -230
	_ring.offset_bottom = -70
	root.add_child(_ring)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap()


func tap() -> void:
	if _t < 0.0 or _over:
		return
	if _ring.value >= 0.82:
		_heave = 1.0
		_ring.flash = 1.0
		_say("HEAVE!")
		Sounds.play("heave")
		Voice.speak(screen.pet, "tug", _player)
	else:
		_heave = maxf(_heave, 0.25)
		_say("heave...")
		Sounds.play_varied("tug", 1.0, 0.1, -4.0)


func _say(text: String) -> void:
	_msg.text = text
	_msg.modulate.a = 1.0


func _process(delta: float) -> void:
	_t += delta
	_msg.modulate.a = maxf(0.0, _msg.modulate.a - delta * 1.4)
	_ring.value = (sin(maxf(_t, 0.0) * TAU / 1.1 - PI / 2.0) + 1.0) / 2.0
	_place_rope()
	if _t < 0.0 and int(ceil(-_t)) != int(ceil(-(_t - delta))):
		Sounds.play("count_tick")
	if _t >= 0.0 and _t - delta < 0.0 and not _over:
		Sounds.play("count_go")
	if _t < 0.0 or _over:
		if _t < 0.0:
			_msg.text = "Ready..." if _t < -0.5 else "PULL!"
			_msg.modulate.a = 1.0
		return
	var r: Dictionary = screen.rivals[_round]
	_next_rival_heave -= delta
	if _next_rival_heave <= 0.0:
		_next_rival_heave = 1.1
		if _rng.randf() < 0.3 + Stats.value(r["pet"], "strength") / 200.0:
			_rival_heave = 1.0
	var player_pull := 30.0 + Stats.value(screen.pet, "strength") * 0.8 + _heave * 55.0
	var rival_pull := 30.0 + Stats.value(r["pet"], "strength") * 0.8 + _rival_heave * 50.0 + sin(_t * 1.3) * 5.0
	_heave = maxf(0.0, _heave - delta * 2.5)
	_rival_heave = maxf(0.0, _rival_heave - delta * 2.5)
	_m += (rival_pull - player_pull) * 1.1 * delta
	_player.position.x = 400.0 + _m
	_rival.position.x = 880.0 + _m
	if _m <= -LINE:
		_end_round(true)
	elif _m >= LINE:
		_end_round(false)


func _place_rope() -> void:
	if _player == null or _rival == null:
		return
	var a := _player.mouth_global()
	var b := _rival.mouth_global()
	var tex := _rope.texture
	_rope.position = (a + b) / 2.0
	_rope.rotation = (b - a).angle()
	var k := (b - a).length() / maxf(tex.get_width(), 1.0)
	_rope.scale = Vector2(k, clampf(k, 0.2, 0.6))


func _end_round(won: bool) -> void:
	_over = true
	_player.interrupt()
	_rival.interrupt()
	if won:
		_wins += 1
		_player.perform("celebrate", 1.5)
		_say("You win round %d!" % (_round + 1))
		Sounds.play("cheer")
		_player.say("star")
	else:
		_rival.perform("celebrate", 1.5)
		_say("%s wins!" % screen.rivals[_round]["name"])
		Sounds.play("ui_nope")
		_rival.say("star")
	await get_tree().create_timer(1.8).timeout
	if won and _round < 2:
		_round += 1
		_new_round()
		return
	# Places: beat all three = 1st; the rival who knocked you out finishes above you.
	var scores := [{"who": "player", "score": _wins + 0.5}]
	for i in 3:
		var s := float(i)
		if not won and i == _round:
			s = 3.0
		scores.append({"who": i, "score": s})
	finished.emit(scores)
