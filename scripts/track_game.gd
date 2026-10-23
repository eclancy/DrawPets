class_name TrackGame
extends Node2D
## Running events on a four-lane track (.ai/competitions.md):
##   dash     - SPEED. A ring over your pet sweeps round and lights up GREEN; tap then for a
##              burst. A tap out of the green trips you a little, so mashing gains nothing.
##              Stamina keeps the pace up over the last stretch.
##   hurdles  - AGILITY. A mark before each hurdle in your lane lights up green while a jump
##              would clear it. Where and how long it glows comes from your pet's speed and its
##              leap, which agility makes higher and longer - an agile pet gets a longer glow.
##              A jump off a lit mark always clears; clip a hurdle and it falls over and you slow.
##   marathon - STAMINA. A drum BOOMs every beat and its ring goes green; tap with it to keep your
##              energy (the battery over your pet) up. Stamina decides how fast it drains.
##              Furthest in 25 seconds wins, and a stopwatch shows how long is left.
## Rivals play the same rules with their own stats and a little luck.
##
## Shown, not told (players start at 7): your pet runs in the front lane under an orange YOU
## arrow, and a drawn hand (HowTo) taps in time with the real cue all through the 3-2-1 - the
## very first time a kid runs the event it does two goes first ("Watch!"). It goes at the first
## tap and comes back when the kid rests, or keeps missing, while the race still wants taps.
## Taps during the 3-2-1 are practice: a "Yes!" when right, nothing counts until GO.

signal finished(scores: Array)

const LANES := [500.0, 560.0, 620.0, 680.0]
## The front lane, so no rival ever runs in front of the kid's pet.
const PLAYER_LANE := 3
const HURDLE_HEIGHT := 38.0
const HURDLE_GAP := 290.0
const MARATHON_TIME := 25.0
const BEAT := 0.6
## A drum tap counts this long either side of the BOOM - the ring is green for exactly that.
const ON_BEAT := 0.13
## Dash's ring goes round once in TURN seconds; it is green for this part of the way round.
const TURN := 1.1
const GREEN_ZONE := Vector2(0.72, 0.92)
## The 3-2-1, in seconds.
const COUNT := 3.0
## The camera looks a little low, so the front lane sits up off the bottom edge - out from under
## a thumb, with room under it for the hint's hand to tap the hurdles' marks.
const CAM_Y := 470.0
## Hurdles' practice hop in the 3-2-1, every this many seconds.
const HOP := 1.2
## Out-of-the-green taps in the Dash trip you this long, at this share of your speed.
const TRIP := 0.25
const TRIP_K := 0.75

const GREEN := Color("#5fb85a")

var screen: CompetitionScreen
var mode := "dash"

var length := 2600.0
var racers: Array = []
var hurdles: Array = []
var _time := -COUNT
var _cam: Camera2D
var _ring: RingMeter
var _msg: Label
var _count: Label
var _how: Label
var _hud: Control
var _progress: Progress
var _time_left: TimeLeft
var _you: YouMark
var _marks: Marks
var _puffs: Marks
var _hint: HowTo
## The hint came back because the kid kept missing: it stays until they get one right.
var _sticky := false
var _idle := 0.0
var _misses := 0
var _last_count := -1
## How long the first-time "Watch!" goes on before the 3-2-1 (0 once a kid has seen it).
var _watch := 0.0
## Each lane's hurdle drawings, so a clipped one can fall over.
var _hurdle_sprites: Array = [[], [], [], []]
var _done := false
var _end_wait := 0.0
## The finger Godot is turning into the mouse, or -1 (see _input).
var _mouse_finger := -1
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = Events.seed_of(screen.event, screen.tier)
	if mode == "hurdles":
		length = 2500.0
		var x := 450.0
		while x < length - 150.0:
			hurdles.append(x)
			x += HURDLE_GAP
	elif mode == "marathon":
		length = 99999.0
	_props()
	var entrants := screen.entrants()
	var lane_order := [PLAYER_LANE, 0, 1, 2]
	for i in entrants.size():
		var e: Dictionary = entrants[i]
		var c := CompetitionScreen.racer(e["pet"])
		if not (e["who"] is String):
			c.step_volume_db = -9.0
		var lane: float = LANES[lane_order[i]]
		c.position = Vector2(80, lane)
		c.z_index = int(lane) + 1
		add_child(c)
		racers.append({"who": e["who"], "c": c, "pet": e["pet"], "x": 80.0, "lane": lane,
			"lane_i": lane_order[i], "v": 0.0, "boost": 0.0, "slow": 0.0, "trip": 0.0,
			"energy": 1.0, "finish": -1.0, "next_hurdle": 0, "lit_jump": -1, "beat_seen": -1,
			"scored_beat": -999, "skill": _rng.randf_range(0.0, 1.0)})
	_cam = Camera2D.new()
	_cam.position = Vector2(300, CAM_Y)
	add_child(_cam)
	_cam.make_current()
	# The hurdles' take-off marks lie on the ground under everyone; the stars from a clean jump
	# go over everyone.
	_marks = Marks.new()
	_marks.game = self
	_marks.z_index = 1
	add_child(_marks)
	_puffs = Marks.new()
	_puffs.game = self
	_puffs.on_top = true
	_puffs.z_index = 1000
	add_child(_puffs)
	_build_hud()
	# The very first time a kid runs this event the hand does two goes first, then the 3-2-1.
	# A breath before the first beat, so the drum's first BOOM is heard.
	var profile: Profile = screen.game.profile if screen.game != null else null
	if profile != null and HowTo.first_times(profile, "howto_" + mode, 1):
		_watch = 2.0 * _cycle()
	_time = -COUNT - _watch - 0.3
	_follow()
	_show_hint("Watch!" if _watch > 0.0 else _caption())


func _stat(r: Dictionary, stat: String) -> float:
	return Stats.value(r["pet"], stat)


func _props() -> void:
	var finish_x := length if mode != "marathon" else -9999.0
	for i in range(0, int(minf(length, 6000.0)) + 1400, 520):
		_sprite("prop_bunting", Vector2(i, 395), 480.0, Vector2(0.5, 0.5), -1, true)
	if finish_x > 0.0:
		_sprite("prop_finish", Vector2(finish_x, 700), 300.0, Vector2(0.5, 1.0), 450)
	for x in hurdles:
		for li in LANES.size():
			var lane: float = LANES[li]
			# Each lane's hurdle sits a little further on the nearer it is, so they read as a
			# row across the track rather than a ladder.
			_hurdle_sprites[li].append(_sprite("prop_hurdle", Vector2(x + (lane - LANES[0]) * 0.35, lane + 4),
				44.0, Vector2(0.5, 1.0), int(lane)))
	for i in 6:
		_sprite("prop_cone", Vector2(300 + i * 700, 462), 50.0, Vector2(0.5, 1.0), -1)


## Adds a baked prop drawing at `at`, `size` px tall (or wide), anchored by `anchor` (0..1 of
## its size) - which is also the point it turns about, so a hurdle falls over on its feet.
func _sprite(id: String, at: Vector2, size: float, anchor: Vector2, z: int, by_width := false) -> Sprite2D:
	var s := Sprite2D.new()
	var tex := Items.art_texture(id)
	s.texture = tex
	s.centered = false
	s.offset = -Vector2(tex.get_size()) * anchor
	var k := size / maxf(tex.get_width() if by_width else tex.get_height(), 1.0)
	s.scale = Vector2(k, k)
	s.position = at
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
	draw_rect(Rect2(-800, 455, right + 800, 900), Color("#efd9b4"))
	# The kid's lane, softly in their colour.
	var mine: float = LANES[PLAYER_LANE]
	Crayon.fill(self, PackedVector2Array([Vector2(-800, mine - 30), Vector2(right, mine - 30),
		Vector2(right, mine + 30), Vector2(-800, mine + 30)]), Color(UI.ACCENT, 0.24), 19, 14.0, 0.0, 6.0)
	for i in LANES.size() + 1:
		var y: float = LANES[0] - 30.0 + i * 60.0
		Crayon.line(self, Vector2(-800, y), Vector2(right, y), Color(1, 1, 1, 0.75), 4.0, i * 13, 2.0)
	Crayon.line(self, Vector2(110, 465), Vector2(110, 715), Color(1, 1, 1, 0.9), 8.0, 3, 1.0)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Control.new()
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(UI.full_rect(_hud))
	_progress = Progress.new()
	_progress.game = self
	_progress.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_progress.offset_top = 14
	_progress.offset_bottom = 60
	_progress.offset_left = 140
	_progress.offset_right = -140
	_hud.add_child(_progress)
	if mode == "marathon":
		_time_left = TimeLeft.new()
		_time_left.game = self
		_time_left.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		_time_left.offset_left = -126
		_time_left.offset_right = -14
		_time_left.offset_top = 4
		_time_left.offset_bottom = 116
		_hud.add_child(_time_left)
	_how = UI.title(Events.info(mode)["how"], 24)
	_how.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_how.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_how.offset_top = 70
	_how.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_how)
	if mode != "hurdles":
		_ring = RingMeter.new()
		_ring.style = "sweep" if mode == "dash" else "drum"
		_ring.zone = GREEN_ZONE if mode == "dash" else Vector2(1.0 - ON_BEAT / (BEAT * 0.5), 1.0)
		_hud.add_child(_ring)
		_ring.size = Vector2(220, 220)
	_you = YouMark.new()
	_hud.add_child(_you)
	# What a tap did, by the kid's pet: ZOOM!, Over!, Nice!
	_msg = UI.title("", 44)
	_msg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_msg)
	_count = UI.title("", 120)
	_count.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_count.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_count.grow_vertical = Control.GROW_DIRECTION_BOTH
	_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(_count)


# --- The kid's tap ------------------------------------------------------------------------------

## Godot turns one finger into the mouse: the first one down while no other is. A kid drumming
## the marathon with two thumbs puts the next one down before the last is up, and that one comes
## only as a touch - so it is counted here, keeping track of the mouse finger exactly as Godot
## picks it, so the mouse finger's taps are not counted a second time.
func _input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch == null:
		return
	if touch.pressed and _mouse_finger == -1:
		_mouse_finger = touch.index
	elif not touch.pressed and touch.index == _mouse_finger:
		_mouse_finger = -1


func _notification(what: int) -> void:
	# Paused for Stop's question, it saw no fingers lift: start afresh, so a finger held down across
	# the pause can muddle the count only until it lifts, not for the rest of the race. (A tap
	# counted twice does next to nothing here anyway: one burst, one BOOM, no jump in mid-air.)
	if what == NOTIFICATION_ENABLED:
		_mouse_finger = -1


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap()
	elif event is InputEventScreenTouch and event.pressed and event.index != _mouse_finger:
		tap()


## The kid's tap. Public so the demo can play.
func tap() -> void:
	var r: Dictionary = racers[0]
	if _done or float(r["finish"]) >= 0.0:
		return
	_idle = 0.0
	if _time < -COUNT:
		# Still watching the hand? Straight on to the 3-2-1, in step with the cue.
		_time += ceilf((-COUNT - _time) / _cycle()) * _cycle()
	var practice := _time < 0.0
	var good := false
	match mode:
		"dash":
			good = _lit()
			if good:
				if not practice:
					r["boost"] = 0.85
				_ring.flash = 1.0
				_say("ZOOM!" if not practice else "Yes!", GREEN, 52)
				Sounds.play("good")
			else:
				if not practice:
					r["trip"] = TRIP
				_miss("Wait for green!")
		"hurdles":
			var c: Creature = r["c"]
			if c.is_leaping():
				return
			good = pad_lit()
			# A jump off a lit mark clears its hurdle however the frames fall: the mark never lies.
			r["lit_jump"] = int(r["next_hurdle"]) if good and not practice else -1
			var leap := _leap_of(r)
			Sounds.play_varied("jump", 1.0, 0.05)
			c.leap(leap.x, leap.y)
			if practice and good:
				_say("Yes!", GREEN, 52)
		"marathon":
			good = _lit()
			if good:
				# One BOOM, one burst of energy: tapping twice on it adds nothing.
				var beat := roundi(_time / BEAT)
				if int(r["scored_beat"]) == beat:
					return
				r["scored_beat"] = beat
				if not practice:
					r["energy"] = minf(1.0, float(r["energy"]) + 0.07)
					r["boost"] = 0.3
					_you.glow = 1.0
				_ring.flash = 1.0
				_say("Nice!" if not practice else "Yes!", GREEN, 52)
				Sounds.play("good", 1.0, -4.0)
			else:
				# Tapping between the BOOMs wears it out a little - "not too fast!"
				if not practice:
					r["energy"] = maxf(0.0, float(r["energy"]) - 0.02)
				_miss("Wait for the BOOM!")
	if good:
		_misses = 0
	if _hint != null and (good or not _sticky):
		_hide_hint()


## A tap that was not in time. It says what to wait for (unless the hand is already showing
## it), never that it was wrong; three in a row and the hand comes back to show it again.
func _miss(text: String) -> void:
	_misses += 1
	if _hint != null:
		return
	if _misses >= 3:
		_show_hint(_caption(), true)
	else:
		_say(text, UI.INK_SOFT, 34)


func _say(text: String, color := UI.INK, font := 44) -> void:
	_msg.text = text
	_msg.modulate.a = 1.0
	_msg.add_theme_color_override("font_color", color)
	_msg.add_theme_font_size_override("font_size", font)


## Where the cue is in its cycle, 0..1: Dash's hand going round; the drum ring's swell, which is
## biggest right on the BOOM.
func _cue_value() -> float:
	if mode == "dash":
		return fposmod(_time, TURN) / TURN
	var p := fposmod(_time, BEAT)
	return 1.0 - minf(p, BEAT - p) / (BEAT * 0.5)


## Is the ring green right now? The ring and the scoring share this one rule.
func _lit() -> bool:
	if _ring == null:
		return false
	_ring.value = _cue_value()
	return _ring.lit()


## Is the take-off mark in front of the kid's next hurdle lit - would a jump now clear it? In the
## 3-2-1 it is the practice mark under the pet, blinking in time with the hand.
func pad_lit() -> bool:
	var r: Dictionary = racers[0]
	if _time < 0.0:
		var u := fposmod(_time / HOP, 1.0)
		return u >= 0.3 and u <= 0.62
	var i := int(r["next_hurdle"])
	# Still stumbling from a clipped one, it is too far back to reach the next mark anyway.
	if i >= hurdles.size() or (r["c"] as Creature).is_leaping() or float(r["slow"]) > 0.0:
		return false
	var gap := hurdle_x(r, i) - float(r["x"])
	var w := jump_window(r)
	return gap >= w.x and gap <= w.y


## A leap: how high (px) and how long (s). Agility makes it both.
func _leap_of(r: Dictionary) -> Vector2:
	var agility := _stat(r, "agility")
	return Vector2(52.0 + agility * 0.9, 0.5 + agility / 400.0)


## How far ahead of the pet's middle a hurdle can be, running at its pace, for a jump now to be
## over the bar's height as it passes: (nearest, furthest) in px. The hurdle is cleared when the
## pet is at least HURDLE_HEIGHT up as its middle crosses it - so a faster pet takes off further
## back, and a more agile one (higher, longer leap) has a longer stretch to take off from.
func jump_window(r: Dictionary) -> Vector2:
	var leap := _leap_of(r)
	var k0 := asin(clampf(HURDLE_HEIGHT / leap.x, 0.0, 1.0)) / PI
	var v := _cruise(r)
	return Vector2(v * k0 * leap.y, v * (1.0 - k0) * leap.y)


## The hurdles pace, before anything speeds it up or slows it down.
func _cruise(r: Dictionary) -> float:
	return 170.0 + _stat(r, "speed") * 0.9 + _stat(r, "agility") * 1.3


# --- The hand -------------------------------------------------------------------------------------

## How long one go of the cue takes: the ring going round, two drum BOOMs, a practice hop.
func _cycle() -> float:
	match mode:
		"dash":
			return TURN
		"marathon":
			return 2.0 * BEAT
	return HOP


## The hand's words: the event's tip, the same few words the intro said beside its little picture,
## so a kid who barely reads sees one phrase for it everywhere.
func _caption() -> String:
	var tips: Array = Events.info(mode).get("tips", [])
	if not tips.is_empty():
		return str(tips[0])
	match mode:
		"dash":
			return "TAP when it's GREEN!"
		"marathon":
			return "TAP on every BOOM!"
	return "TAP to JUMP when it glows!"


## The hand taps in time with the real cue (its press lands on the green, the BOOM, the lit mark),
## so only one sentence shows: the instruction line hides while it is up.
func _show_hint(text: String, sticky := false) -> void:
	if _hint != null:
		_hint.dismiss()
	_hint = HowTo.new()
	_hint.gesture = "tap"
	_hint.caption = text
	_hint.caption_y = 64.0
	_hint.phase = _hint_phase
	_hint.at = _hint_spot
	_hint.on_press = _hint_pressed
	_hud.add_child(_hint)
	_sticky = sticky
	_how.visible = false


func _hide_hint() -> void:
	if _hint == null:
		return
	_hint.dismiss()
	_hint = null
	_sticky = false
	# The instruction line comes back once the hand's caption has faded - never both at once.
	_how.visible = true
	_how.modulate.a = 0.0
	var t := _how.create_tween()
	t.tween_property(_how, "modulate:a", 1.0, 0.3).set_delay(0.35)


## The game's cycle for the hand, shifted so its press (at about 0.42) lands on the moment.
func _hint_phase() -> float:
	match mode:
		"dash":
			return fposmod(_cue_value() - GREEN_ZONE.x - 0.03 + 0.42, 1.0)
		"marathon":
			return fposmod(fposmod(_time, BEAT) / BEAT + 0.42, 1.0)
	if _time < 0.0:
		return fposmod(_time / HOP, 1.0)
	var r: Dictionary = racers[0]
	var i := int(r["next_hurdle"])
	if i >= hurdles.size():
		return 0.0
	var w := jump_window(r)
	var gap := hurdle_x(r, i) - float(r["x"])
	# Not wrapped: the finger stays up until the pet is close to its mark, so it never taps a mark
	# that is not glowing yet.
	return clampf(0.43 - (gap - (w.x + w.y) / 2.0) / HURDLE_GAP, 0.0, 0.99)


## Where the hand taps: the ring or the drum; in the hurdles, the mark that is about to light.
func _hint_spot() -> Vector2:
	if _ring != null:
		return _ring.position + _ring.size / 2.0 + Vector2(0, 8)
	return _to_screen(next_mark())


## The middle of the kid's next take-off mark, in the world: in the 3-2-1 the practice one under
## the pet, then the one before the next hurdle.
func next_mark() -> Vector2:
	var r: Dictionary = racers[0]
	var y := float(r["lane"]) + 4.0
	var i := int(r["next_hurdle"])
	if _time < 0.0 or i >= hurdles.size():
		return Vector2(float(r["x"]), y)
	var w := jump_window(r)
	return Vector2(hurdle_x(r, i) - (w.x + w.y) / 2.0, y)


## Before GO the hand's press shows what a press does: the ring flashes, the pet hops. In the
## race it only shows when - the kid's own tap is what counts.
func _hint_pressed() -> void:
	if _time >= 0.0:
		return
	var watching := _time < -COUNT
	match mode:
		"hurdles":
			var r: Dictionary = racers[0]
			var c: Creature = r["c"]
			if not c.is_leaping():
				var leap := _leap_of(r)
				Sounds.play_varied("jump", 1.0, 0.05)
				c.leap(leap.x, leap.y)
		_:
			_ring.flash = 1.0
			if watching:
				_say("ZOOM!" if mode == "dash" else "Nice!", GREEN, 52)
				if mode == "dash":
					Sounds.play("good")


## The hand comes back when the kid rests for two goes while the race still wants taps.
func _coach(delta: float) -> void:
	if not _wants_taps():
		if _hint != null:
			_hide_hint()
		return
	_idle += delta
	if _hint == null and _idle > 2.0 * _cycle():
		_show_hint(_caption())


func _wants_taps() -> bool:
	var r: Dictionary = racers[0]
	if _done or float(r["finish"]) >= 0.0:
		return false
	if mode == "hurdles" and _time >= 0.0:
		return int(r["next_hurdle"]) < hurdles.size()
	if mode == "marathon":
		return _time < MARATHON_TIME
	return true


# --- Each frame ----------------------------------------------------------------------------------

func _process(delta: float) -> void:
	var before := _time
	_time += delta
	_msg.modulate.a = maxf(0.0, _msg.modulate.a - delta * 1.2)
	if _ring != null:
		_ring.value = _cue_value()
	# The drum keeps the beat from the very start, so the hand and the kid can tap along before GO.
	if mode == "marathon" and not _done and floorf(_time / BEAT) != floorf(before / BEAT):
		Sounds.play("drum_beat")
		_ring.beat = 1.0
	if before < -COUNT and _time >= -COUNT and _hint != null and not _sticky:
		_show_hint(_caption())
	if before < 0.0 and _time >= 0.0:
		Sounds.play("count_go")
	if _time < 0.0:
		_countdown()
	else:
		_count.text = "GO!" if _time < 0.7 else ("Time's up!" if _done and mode == "marathon" else "")
		if not _done:
			for r in racers:
				_run(r, delta)
		var player: Dictionary = racers[0]
		_cam.position.x = float(player["x"]) + 220.0
		_progress.queue_redraw()
		_check_end(delta)
	_coach(delta)
	_follow()


## 3, 2, 1 - a tick on each (the drum keeps time instead in the marathon).
func _countdown() -> void:
	if _time < -COUNT:
		_count.text = ""
		return
	var n := int(ceil(-_time))
	_count.text = str(n)
	if n != _last_count:
		_last_count = n
		if mode != "marathon":
			Sounds.play("count_tick")


## Keeps the HUD things that ride the kid's pet - the YOU arrow, what a tap did, the ring - on it.
func _follow() -> void:
	var c: Creature = racers[0]["c"]
	var feet := _to_screen(c.global_position)
	var top := _to_screen(c.top_global())
	# The arrow's tip just touches the top of its head (top_global is a little above it).
	_you.position = top + Vector2(-_you.size.x / 2.0, -_you.size.y + 12.0 + sin(_time * 5.0) * 3.0)
	if mode == "marathon":
		_you.energy = float(racers[0]["energy"])
		_you.queue_redraw()
	_msg.position = Vector2(top.x + 62.0, top.y - 100.0)
	if _ring != null:
		# Up in the sky behind the pet, where the eyes already are and the rivals mostly are not.
		_ring.position = Vector2(feet.x - 170.0 - _ring.size.x / 2.0, 130.0)


func _to_screen(world: Vector2) -> Vector2:
	return world - _cam.position + get_viewport_rect().size / 2.0


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
				var beat := int(_time / TURN)
				if beat != int(r["beat_seen"]):
					r["beat_seen"] = beat
					if _rng.randf() < 0.25 + speed / 160.0:
						r["boost"] = 0.85
					elif _rng.randf() < 0.25:
						r["slow"] = 0.35
		"hurdles":
			v = _cruise(r)
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
	if float(r["trip"]) > 0.0:
		r["trip"] = float(r["trip"]) - delta
		v *= TRIP_K
	r["v"] = v
	r["x"] = float(r["x"]) + v * delta
	c.position.x = r["x"]
	c.drive_velocity = Vector2(v, 0)
	if mode != "marathon" and float(r["x"]) >= length:
		r["finish"] = _time
		c.drive_velocity = Vector2.ZERO
		c.perform("celebrate", 2.0)
		if is_player:
			_say("Finished!", GREEN, 52)
			Sounds.play("cheer")


## Jumping hurdles: the player jumps on a tap; rivals jump by themselves, a bit early or late
## depending on their agility. Clipping a hurdle knocks it over and slows you down.
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
			var leap := _leap_of(r)
			c.leap(leap.x, leap.y)
	if x >= hx:
		r["next_hurdle"] = i + 1
		# High enough as its middle passes the bar - read off one frame, so a hiccup in the frames
		# could clip a jump the mark said was right; a jump off the lit mark always counts.
		if c.z < HURDLE_HEIGHT and int(r["lit_jump"]) != i:
			r["slow"] = 0.6
			_knock_over(int(r["lane_i"]), i)
			if is_player:
				_say("Bonk!", UI.INK_SOFT, 40)
				Sounds.play("thud")
				# Two clipped in a row: the hand comes back to show when.
				_misses += 1
				if _misses >= 2 and _hint == null and i + 1 < hurdles.size():
					_show_hint(_caption(), true)
		elif is_player:
			_say("Over!", GREEN, 52)
			Sounds.play("good", 1.0, -3.0)
			_puffs.puff(Vector2(hx, float(r["lane"]) - 50.0))
			_misses = 0
			if _sticky:
				_hide_hint()


func _knock_over(lane_i: int, i: int) -> void:
	var lane: Array = _hurdle_sprites[lane_i]
	if i >= lane.size():
		return
	var s: Sprite2D = lane[i]
	var t := s.create_tween()
	t.tween_property(s, "rotation", 1.25, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


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
	_hide_hint()
	for r in racers:
		(r["c"] as Creature).drive_velocity = Vector2.ZERO
	if mode == "marathon":
		_count.add_theme_font_size_override("font_size", 96)
		Sounds.play("cheer")
	var scores := []
	for r in racers:
		var score := float(r["x"])
		if mode != "marathon":
			score = -float(r["finish"]) if float(r["finish"]) >= 0.0 else -999.0 + float(r["x"]) / 10000.0
		scores.append({"who": r["who"], "score": score})
	await get_tree().create_timer(1.6 if mode == "marathon" else 1.2).timeout
	finished.emit(scores)


## How far along everyone is: a crayon line with a dot per racer, the kid's pet the big orange
## one, and the finish flag at the end (the marathon has none - it runs on the stopwatch).
class Progress extends Control:
	var game: TrackGame

	func _ready() -> void:
		# Tap anywhere means anywhere - the strip must not swallow taps.
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var y := size.y / 2.0
		Crayon.line(self, Vector2(0, y), Vector2(size.x, y), UI.INK_SOFT, 5.0, 3, 1.5)
		if game.mode != "marathon":
			var f := Vector2(size.x, y)
			Crayon.line(self, f + Vector2(0, 14), f + Vector2(0, -24), Color("#a07b52"), 4.0, 4, 0.5)
			for k in 4:
				var row := floori(k / 2.0)
				var cell := Rect2(f + Vector2(2 + (k % 2) * 13, -24 + row * 10), Vector2(13, 10))
				var col := UI.CARD if (k + row) % 2 == 0 else UI.INK_SOFT
				Crayon.fill(self, PackedVector2Array([cell.position, Vector2(cell.end.x, cell.position.y),
					cell.end, Vector2(cell.position.x, cell.end.y)]), col, 5 + k, 4.0, 0.0, 3.0)
		var far := 1.0
		for r in game.racers:
			far = maxf(far, float(r["x"]))
		var total := game.length if game.mode != "marathon" else maxf(far * 1.1, 800.0)
		for i in range(game.racers.size() - 1, -1, -1):
			var r: Dictionary = game.racers[i]
			var p := Vector2(clampf(float(r["x"]) / total, 0.0, 1.0) * size.x, y)
			var mine: bool = r["who"] is String
			var rad := 15.0 if mine else 10.0
			var col := UI.ACCENT if mine else Color("#9a93c4")
			Crayon.fill_blob(self, p, Vector2(rad, rad), col, 20 + i, 0.05)
			Crayon.marker_line(self, Crayon.ellipse(p, Vector2(rad, rad), 20), col.darkened(0.4), 3.0, 30 + i)
			if mine:
				Crayon.fill(self, Crayon.star(p, 8.0, 7), UI.CARD, 40, 3.0, 0.0, 2.0)


## The kid's pet's marker: an orange arrow pointing down at it, with YOU on it. In the marathon
## its energy rides on top: a battery, like the Stamina sign, that slowly runs down and that a
## tap on the BOOM tops up - it glows as it fills.
class YouMark extends Control:
	## 0..1, or below 0 for no battery.
	var energy := -1.0
	## Set to 1 when a tap fills the battery; it fades.
	var glow := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(110, 122)

	func _process(delta: float) -> void:
		if glow > 0.0:
			glow = maxf(0.0, glow - delta * 2.5)
			queue_redraw()

	func _draw() -> void:
		# A paper tag, so it reads as a label over whatever runs behind, and the arrow under it.
		var tip := Vector2(size.x / 2.0, size.y - 4.0)
		var pts := PackedVector2Array()
		for p in [Vector2(-11, -28), Vector2(11, -28), Vector2(11, -16), Vector2(24, -16), Vector2(0, 0),
				Vector2(-24, -16), Vector2(-11, -16)]:
			pts.append(tip + p)
		Crayon.fill(self, pts, UI.ACCENT, 61, 6.0, 1.0, 4.0)
		Crayon.marker_line(self, pts, UI.ACCENT.darkened(0.35), 4.0, 62)
		var tag := Crayon.rounded_rect(Rect2(size.x / 2.0 - 38.0, tip.y - 66.0, 76.0, 40.0), 14.0)
		Crayon.fill(self, tag, UI.CARD, 63, 6.0, 0.0, 4.0)
		Crayon.marker_line(self, tag, UI.ACCENT, 5.0, 64)
		var font := ThemeDB.fallback_font
		var text := "YOU"
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x
		draw_string(font, Vector2(size.x / 2.0 - w / 2.0, tip.y - 36.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28,
			UI.ACCENT.darkened(0.3))
		if energy < 0.0:
			return
		var body := Rect2(size.x / 2.0 - 47.0, tip.y - 106.0, 84.0, 34.0)
		var nub := Rect2(body.end.x - 2.0, body.position.y + 9.0, 11.0, 16.0)
		Crayon.fill(self, Crayon.rounded_rect(nub, 3.0), UI.INK_SOFT, 104, 4.0, 0.0, 3.0)
		Crayon.fill(self, Crayon.rounded_rect(body, 8.0), UI.CARD, 101, 5.0, 0.0, 4.0)
		var inner := body.grow(-6.0)
		var full := Rect2(inner.position, Vector2(maxf(6.0, inner.size.x * energy), inner.size.y))
		Crayon.fill(self, Crayon.rounded_rect(full, 4.0), RingMeter.GREEN if energy > 0.3 else UI.ACCENT, 102, 4.0, 0.0, 4.0)
		Crayon.marker_line(self, Crayon.rounded_rect(body, 8.0), UI.INK_SOFT, 4.0, 103)
		if glow > 0.0:
			var ring := Crayon.ellipse(body.get_center() + Vector2(4, 0), Vector2(56.0 + 8.0 * (1.0 - glow), 28.0 + 6.0 * (1.0 - glow)), 32)
			Crayon.marker_line(self, ring, Color(1, 0.85, 0.3, glow), 7.0, 105)


## How long the marathon has left: a stopwatch whose coloured slice empties, with the seconds
## in the middle.
class TimeLeft extends Control:
	var game: TrackGame

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0 + Vector2(0, 6)
		var r := minf(size.x, size.y) * 0.36
		var left := clampf(1.0 - maxf(game._time, 0.0) / TrackGame.MARATHON_TIME, 0.0, 1.0)
		Crayon.fill(self, Crayon.rounded_rect(Rect2(c.x - 9, c.y - r - 20, 18, 14), 4.0), UI.INK_SOFT, 70, 4.0, 0.0, 3.0)
		Crayon.fill_blob(self, c, Vector2(r + 6, r + 6), UI.CARD, 71, 0.02)
		if left > 0.01:
			var pie := PackedVector2Array([c])
			var steps := maxi(2, int(left * 40.0))
			for i in steps + 1:
				var a := -PI / 2.0 + TAU * left * i / steps
				pie.append(c + Vector2(cos(a), sin(a)) * r)
			Crayon.fill(self, pie, UI.GOOD if left > 0.2 else UI.ACCENT, 72, 6.0, 0.0, 4.0)
		Crayon.marker_line(self, Crayon.ellipse(c, Vector2(r + 6, r + 6), 40), UI.INK_SOFT, 5.0, 73)
		var font := ThemeDB.fallback_font
		var text := str(int(ceil(left * TrackGame.MARATHON_TIME)))
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 34).x
		var at := c + Vector2(-w / 2.0, 12)
		draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, 10, UI.PAPER)
		draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, UI.INK)


## Drawn in the world. Under everyone: an orange ring round the kid's pet's feet, and the take-off
## marks in its lane, one before each hurdle, exactly as long as the stretch a jump clears it from
## and green while the pet is on it - plus, in the 3-2-1, a practice mark under the pet blinking in
## time with the hand. Over everyone (`on_top`): a puff of stars from a hurdle cleared.
class Marks extends Node2D:
	var game: TrackGame
	var on_top := false
	var _puffs: Array = []

	func puff(at: Vector2) -> void:
		_puffs.append([at, 0.0])

	func _process(delta: float) -> void:
		for p in _puffs:
			p[1] += delta
		_puffs = _puffs.filter(func(p): return p[1] < 0.7)
		queue_redraw()

	func _draw() -> void:
		if on_top:
			for p in _puffs:
				var k: float = p[1] / 0.7
				for j in 5:
					var d := Vector2.from_angle(-PI * (0.1 + 0.2 * j)) * (20.0 + 60.0 * k)
					Crayon.fill(self, Crayon.star(p[0] + d, 11.0, j), Color(1.0, 0.82, 0.25, 1.0 - k), 80 + j, 4.0, 0.0, 3.0)
			return
		if game.racers.is_empty():
			return
		var r: Dictionary = game.racers[0]
		var y := float(r["lane"]) + 4.0
		# The kid's pet stands in an orange ring, in the YOU arrow's colour (green wins while a mark
		# under it is lit).
		var lit := game.mode == "hurdles" and game.pad_lit()
		var c: Creature = r["c"]
		var rx := c.rest.size.x * c.norm * 0.5 + 12.0
		if not lit:
			Crayon.marker_line(self, Crayon.ellipse(Vector2(c.position.x, y), Vector2(rx, rx * 0.22 + 6.0), 36),
				Color(UI.ACCENT, 0.9), 6.0, 140)
		if game.mode != "hurdles":
			return
		var practice := game._time < 0.0
		if practice:
			_pad(Vector2(float(r["x"]) - 40.0, y), Vector2(float(r["x"]) + 40.0, y), lit, 0)
		var w := game.jump_window(r)
		var first := int(r["next_hurdle"])
		for i in range(first, mini(first + 3, game.hurdles.size())):
			var hx := game.hurdle_x(r, i)
			var now := lit and i == first and not practice
			_pad(Vector2(hx - w.y, y), Vector2(hx - w.x, y), now, i + 1)
			if now:
				# The hurdle to jump glows too.
				Crayon.fill_blob(self, Vector2(hx, y - 24.0), Vector2(48, 42), Color(1.0, 0.86, 0.3, 0.6), 90)

	## A take-off mark from `a` to `b` on the ground, as on the event's how-to card: a chalk ring,
	## or, lit, green with a yellow ring and a glow round it.
	func _pad(a: Vector2, b: Vector2, lit: bool, seed: int) -> void:
		var mid := (a + b) / 2.0
		var rx := maxf((b.x - a.x) / 2.0, 14.0) + 6.0
		if lit:
			Crayon.fill_blob(self, mid, Vector2(rx + 50.0, 36.0), Color(RingMeter.GREEN, 0.4), 100 + seed, 0.05)
			Crayon.fill_blob(self, mid, Vector2(rx, 14.0), Color(RingMeter.GREEN, 0.95), 110 + seed, 0.05)
			Crayon.marker_line(self, Crayon.ellipse(mid, Vector2(rx + 8.0, 20.0), 32), Color(1, 0.85, 0.3, 0.95), 6.0, 120 + seed)
		else:
			Crayon.marker_line(self, Crayon.ellipse(mid, Vector2(rx, 12.0), 28), Color(1, 1, 1, 0.95), 5.0, 120 + seed)
