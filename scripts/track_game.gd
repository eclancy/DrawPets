class_name TrackGame
extends Node2D
## Running events on a four-lane track (.ai/competitions.md):
##   dash     - SPEED. Tap while the ring's hand is in the green for a burst; mistime it and
##              stumble. Stamina keeps the pace up over the last stretch.
##   hurdles  - AGILITY. Tap to jump each hurdle; agility decides how high and how long.
##              Clip one and you slow down.
##   marathon - STAMINA. Tap along with the drum. On the beat keeps your energy up; stamina
##              decides how fast it drains. Furthest in 25 seconds wins.
## Rivals play the same rules with their own stats and a little luck.

signal finished(scores: Array)

const LANES := [500.0, 560.0, 620.0, 680.0]
const PLAYER_LANE := 2
const HURDLE_HEIGHT := 38.0
const MARATHON_TIME := 25.0
const BEAT := 0.6

var screen: CompetitionScreen
var mode := "dash"

var length := 2600.0
var racers: Array = []
var hurdles: Array = []
var _time := -2.9
var _cam: Camera2D
var _ring: RingMeter
var _msg: Label
var _count: Label
var _progress: Progress
var _done := false
var _end_wait := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = Events.seed_of(screen.event, screen.tier)
	if mode == "hurdles":
		length = 2500.0
		var x := 450.0
		while x < length - 150.0:
			hurdles.append(x)
			x += 290.0
	elif mode == "marathon":
		length = 99999.0
	_props()
	var entrants := screen.entrants()
	var lane_order := [PLAYER_LANE, 0, 1, 3]
	for i in entrants.size():
		var e: Dictionary = entrants[i]
		var c := CompetitionScreen.racer(e["pet"])
		var lane: float = LANES[lane_order[i]]
		c.position = Vector2(80, lane)
		c.z_index = int(lane) + 1
		add_child(c)
		racers.append({"who": e["who"], "c": c, "pet": e["pet"], "x": 80.0, "lane": lane, "boost": 0.0, "slow": 0.0,
			"energy": 1.0, "finish": -1.0, "next_hurdle": 0, "beat_seen": -1,
			"skill": _rng.randf_range(0.0, 1.0)})
	_cam = Camera2D.new()
	_cam.position = Vector2(640, 360)
	add_child(_cam)
	_cam.make_current()
	_build_hud()


func _stat(r: Dictionary, stat: String) -> float:
	return Stats.value(r["pet"], stat)


func _props() -> void:
	var finish_x := length if mode != "marathon" else -9999.0
	for i in range(0, int(minf(length, 6000.0)) + 1400, 520):
		_sprite("prop_bunting", Vector2(i, 395), 480.0, Vector2(0.5, 0.5), -1, true)
	if finish_x > 0.0:
		_sprite("prop_finish", Vector2(finish_x, 700), 300.0, Vector2(0.5, 1.0), 450)
	for x in hurdles:
		for lane in LANES:
			# Each lane's hurdle sits a little further on the nearer it is, so they read as a
			# row across the track rather than a ladder.
			_sprite("prop_hurdle", Vector2(x + (lane - LANES[0]) * 0.35, lane + 4), 44.0, Vector2(0.5, 1.0), int(lane))
	for i in 6:
		_sprite("prop_cone", Vector2(300 + i * 700, 462), 50.0, Vector2(0.5, 1.0), -1)


## Adds a baked prop drawing at `at`, `size` px tall (or wide), anchored by `anchor` (0..1 of
## its size).
func _sprite(id: String, at: Vector2, size: float, anchor: Vector2, z: int, by_width := false) -> Sprite2D:
	var s := Sprite2D.new()
	var tex := Items.art_texture(id)
	s.texture = tex
	s.centered = false
	var k := size / maxf(tex.get_width() if by_width else tex.get_height(), 1.0)
	s.scale = Vector2(k, k)
	s.position = at - Vector2(tex.get_size()) * anchor * k
	s.z_index = z
	add_child(s)
	return s


func _draw() -> void:
	var right := (length if mode != "marathon" else 8000.0) + 1500.0
	Crayon.sky(self, Rect2(-800, -300, right + 800, 760), Color("#a9d8f2"), Color("#e9f6fa"))
	var hills := PackedVector2Array([Vector2(-800, 470)])
	var x := -800.0
	while x <= right:
		hills.append(Vector2(x, 430.0 - 50.0 * (0.6 + 0.4 * sin(x * 0.004 + 1.0))))
		x += 80.0
	hills.append(Vector2(right, 470))
	Crayon.fill(self, hills, Color("#b5df95"), 5, 14.0, 0.0, 7.0)
	draw_rect(Rect2(-800, 455, right + 800, 300), Color("#efd9b4"))
	for i in LANES.size() + 1:
		var y: float = LANES[0] - 30.0 + i * 60.0
		Crayon.line(self, Vector2(-800, y), Vector2(right, y), Color(1, 1, 1, 0.75), 4.0, i * 13, 2.0)
	Crayon.line(self, Vector2(110, 465), Vector2(110, 715), Color(1, 1, 1, 0.9), 8.0, 3, 1.0)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.full_rect(root))
	_count = UI.title("3", 120)
	_count.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_count.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_count.grow_vertical = Control.GROW_DIRECTION_BOTH
	root.add_child(_count)
	_msg = UI.title("", 44)
	_msg.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_msg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_msg.offset_top = 120
	root.add_child(_msg)
	var how := UI.title(Events.info(mode)["how"], 24)
	how.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	how.grow_horizontal = Control.GROW_DIRECTION_BOTH
	how.offset_top = 70
	root.add_child(how)
	if mode != "hurdles":
		_ring = RingMeter.new()
		_ring.style = "sweep" if mode == "dash" else "pulse"
		_ring.label = "TAP!"
		_ring.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		_ring.offset_left = -200
		_ring.offset_top = -230
		_ring.offset_right = -40
		_ring.offset_bottom = -70
		root.add_child(_ring)
	_progress = Progress.new()
	_progress.game = self
	_progress.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_progress.offset_top = 14
	_progress.offset_bottom = 60
	_progress.offset_left = 140
	_progress.offset_right = -140
	root.add_child(_progress)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap()


## The kid's tap. Public so the demo can play.
func tap() -> void:
	if _time < 0.0 or _done:
		return
	var r: Dictionary = racers[0]
	match mode:
		"dash":
			var v := fmod(_time, 1.1) / 1.1
			if v >= 0.72 and v <= 0.92:
				r["boost"] = 0.85
				_say("ZOOM!")
				_ring.flash = 1.0
			else:
				r["slow"] = 0.35
				_say("Oops!")
		"hurdles":
			var c: Creature = r["c"]
			if not c.is_leaping():
				var agility := _stat(r, "agility")
				c.leap(52.0 + agility * 0.9, 0.5 + agility / 400.0)
		"marathon":
			var phase := fmod(_time, BEAT)
			if phase < 0.13 or phase > BEAT - 0.13:
				r["energy"] = minf(1.0, float(r["energy"]) + 0.07)
				r["boost"] = 0.3
				_ring.flash = 1.0
				_say("Nice!")
			else:
				r["energy"] = maxf(0.0, float(r["energy"]) - 0.05)
				_say("Steady...")


func _say(text: String) -> void:
	_msg.text = text
	_msg.modulate.a = 1.0


func _process(delta: float) -> void:
	_time += delta
	_msg.modulate.a = maxf(0.0, _msg.modulate.a - delta * 1.5)
	if _time < 0.0:
		_count.text = str(int(ceil(-_time))) if _time < -0.2 else "GO!"
		return
	_count.text = "GO!" if _time < 0.7 else ""
	if _ring != null:
		_ring.value = fmod(_time, 1.1) / 1.1 if mode == "dash" else 1.0 - fmod(_time, BEAT) / BEAT
	for r in racers:
		_run(r, delta)
	var player: Dictionary = racers[0]
	_cam.position.x = maxf(640.0, float(player["x"]) + 220.0)
	_progress.queue_redraw()
	_check_end(delta)


func _run(r: Dictionary, delta: float) -> void:
	var c: Creature = r["c"]
	if float(r["finish"]) >= 0.0:
		c.drive_velocity = Vector2.ZERO
		return
	var is_player: bool = r["who"] is String
	var speed := _stat(r, "speed")
	var v := 0.0
	match mode:
		"dash":
			v = 150.0 + speed * 2.3
			if float(r["x"]) > length * 0.6:
				v *= 0.8 + _stat(r, "stamina") / 100.0 * 0.2
			if not is_player:
				# Rivals time their bursts too - better ones more often.
				var beat := int(_time / 1.1)
				if beat != int(r["beat_seen"]):
					r["beat_seen"] = beat
					if _rng.randf() < 0.25 + speed / 160.0:
						r["boost"] = 0.85
					elif _rng.randf() < 0.25:
						r["slow"] = 0.35
		"hurdles":
			v = 170.0 + speed * 0.9 + _stat(r, "agility") * 1.3
			_hurdle(r, is_player)
		"marathon":
			var drain := 0.035 * (1.45 - _stat(r, "stamina") / 100.0)
			r["energy"] = maxf(0.0, float(r["energy"]) - drain * delta)
			v = (110.0 + speed * 0.5) * (0.5 + 0.5 * float(r["energy"]))
			if not is_player:
				var beat := int(_time / BEAT)
				if beat != int(r["beat_seen"]):
					r["beat_seen"] = beat
					if _rng.randf() < 0.4 + _stat(r, "stamina") / 200.0:
						r["energy"] = minf(1.0, float(r["energy"]) + 0.07)
	if float(r["boost"]) > 0.0:
		r["boost"] = float(r["boost"]) - delta
		v *= 1.5 if mode == "dash" else 1.15
	if float(r["slow"]) > 0.0:
		r["slow"] = float(r["slow"]) - delta
		v *= 0.45
	r["x"] = float(r["x"]) + v * delta
	c.position.x = r["x"]
	c.drive_velocity = Vector2(v, 0)
	c.position.x = r["x"]
	if mode != "marathon" and float(r["x"]) >= length:
		r["finish"] = _time
		c.drive_velocity = Vector2.ZERO
		c.perform("celebrate", 2.0)
		if is_player:
			_say("Finished!")


## Jumping hurdles: the player jumps on a tap; rivals jump by themselves, a bit early or late
## depending on their agility. Clipping a hurdle slows you down.
func _hurdle(r: Dictionary, is_player: bool) -> void:
	var i := int(r["next_hurdle"])
	if i >= hurdles.size():
		return
	var c: Creature = r["c"]
	var hx := hurdle_x(r, i)
	var x := float(r["x"])
	if not is_player and not c.is_leaping():
		var agility := _stat(r, "agility")
		var early := 70.0 + _rng.randf_range(-1.0, 1.0) * (1.0 - agility / 100.0) * 70.0
		if hx - x < early:
			c.leap(52.0 + agility * 0.9, 0.5 + agility / 400.0)
	if x >= hx:
		r["next_hurdle"] = i + 1
		if c.z < HURDLE_HEIGHT:
			r["slow"] = 0.6
			if is_player:
				_say("Bonk!")
		elif is_player:
			_say("Over!")


## Where hurdle `i` is in this racer's lane (each lane's sits a little further on).
func hurdle_x(r: Dictionary, i: int) -> float:
	return float(hurdles[i]) + (float(r["lane"]) - LANES[0]) * 0.35


func _check_end(delta: float) -> void:
	if _done:
		return
	var all_done := true
	if mode == "marathon":
		all_done = _time >= MARATHON_TIME
	else:
		for r in racers:
			if float(r["finish"]) < 0.0:
				all_done = false
		var player: Dictionary = racers[0]
		if float(player["finish"]) >= 0.0:
			_end_wait += delta
			if _end_wait > 4.0:
				all_done = true
	if not all_done:
		return
	_done = true
	var scores := []
	for r in racers:
		var score := float(r["x"])
		if mode != "marathon":
			score = -float(r["finish"]) if float(r["finish"]) >= 0.0 else -999.0 + float(r["x"]) / 10000.0
		scores.append({"who": r["who"], "score": score})
	await get_tree().create_timer(1.2).timeout
	finished.emit(scores)


## How far along everyone is: a crayon line with a dot per racer, the kid's pet in orange.
class Progress extends Control:
	var game: TrackGame

	func _draw() -> void:
		var y := size.y / 2.0
		draw_line(Vector2(0, y), Vector2(size.x, y), UI.INK_SOFT, 4.0, true)
		var far := 1.0
		for r in game.racers:
			far = maxf(far, float(r["x"]))
		var total := game.length if game.mode != "marathon" else maxf(far * 1.1, 800.0)
		for i in range(game.racers.size() - 1, -1, -1):
			var r: Dictionary = game.racers[i]
			var x := clampf(float(r["x"]) / total, 0.0, 1.0) * size.x
			var col := UI.ACCENT if r["who"] is String else Color("#9a93c4")
			draw_circle(Vector2(x, y), 14.0 if i == 0 else 10.0, col)
			draw_arc(Vector2(x, y), 14.0 if i == 0 else 10.0, 0, TAU, 20, UI.INK, 2.0, true)
