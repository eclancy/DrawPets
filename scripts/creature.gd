class_name Creature
extends Node2D
## A kid's drawing, alive: the parts hung on a joint tree, walking, hopping or flying about,
## and reacting to being fed, petted and played with.
##
## The creature stands on a ground plane. `position` is where its feet are; `z` is how far
## above the ground it is (hopping, flying, swimming, perched on furniture), drawn as a lift
## with a shadow left on the ground. Further down the screen is nearer, so it is drawn bigger.
##
## Its parts decide what it can do (.ai/creature-pipeline.md): legs walk, no legs hop, wings
## let it fly, fins let it swim. Its stats decide how well: speed sets how fast it runs. The
## motion channels below (stride, wag, blink, mouth_open, ...) are what each part reads.

signal emote(kind: String, at: Vector2)

const SIZES := {"tiny": 0.35, "small": 0.6, "medium": 1.0, "big": 1.45, "huge": 2.0, "giant": 2.7}
const SIZE_ORDER := ["tiny", "small", "medium", "big", "huge", "giant"]
const SIZE_LABELS := {"tiny": ["Tiny", "mouse"], "small": ["Small", "cat"],
	"medium": ["Medium", "dog"], "big": ["Big", "horse"], "huge": ["Huge", "elephant"],
	"giant": ["Giant", "dinosaur"]}
## On-screen height of a medium creature at the 1280x720 design size.
const STANDARD_HEIGHT := 180.0

var pet: Dictionary
var rig: Node2D
var body: CreaturePart
var parts: Array[CreaturePart] = []
var rest := Rect2()
var norm := 1.0
var height_px := 100.0
var fixed_height := -1.0

# --- Motion channels, read by CreaturePart.animate --------------------------------------------
var time := 0.0
var phase := 0.0
var stride := 0.0
var bob := 0.0
var bob_vel := 0.0
var squash := 0.0
var breath := 0.02
var breath_speed := 2.2
var blink := 0.0
var head_tilt := 0.0
var nod := 0.0
var mouth_open := 0.0
var sniff := 0.0
var wave := 0.0
var flap := 0.0
var swim := 0.0
var tuck := 0.0
var wag := 0.2
var wag_speed := 6.0
var ear_droop := 0.0
var lean := 0.0
## Lying over on its back for a belly rub, 0-1. The whole rig tips over backwards about its feet.
var roll := 0.0
## Leaning into something heavy it is pushing along.
var straining := false
## Where a finger is petting it (global), or Vector2.INF. It leans into the finger.
var touch_at := Vector2.INF
var accel := Vector2.ZERO

# --- Movement -------------------------------------------------------------------------------
var facing := 1.0
var z := 0.0
## The height of whatever it is standing on - a rock, a bed. Walking off sets it back to 0.
var rest_z := 0.0
var velocity := Vector2.ZERO
var walk_speed := 150.0
var has_legs := false
var can_fly := false
var can_swim := false
var in_water := false
var flying := false
var happiness := 0.7
var bounds := Rect2(60, 460, 1160, 240)
var wander := true
var confine := true
var depth_scale := true
## Driven creatures (competitions) do not think or wander: something else sets drive_velocity
## every frame and they just move and animate.
var driven := false
## Makes footsteps, hops, flaps and snores - on for the pets in a home or a competition, off for
## the little ones in cards and menus. Its voice is separate: a pet talks wherever it is.
var audible := false
## How loud its footsteps are, under the rest (rivals' are quieter than the kid's own pet).
var step_volume_db := 0.0

## Footsteps and flaps are pitched by size: a mouse patters, a dinosaur thumps.
const SIZE_PITCH := {"tiny": 1.7, "small": 1.3, "medium": 1.0, "big": 0.85, "huge": 0.72, "giant": 0.6}
var _flap_in := 0.0
var _bubble_in := 0.0
var drive_velocity := Vector2.ZERO

var _goal := Vector2.ZERO
var _has_goal := false
var _on_arrive := Callable()
var _run := false
var _idle := 1.5
var _action := ""
var _action_len := 0.0
var _action_left := 0.0
var _on_action_done := Callable()
var _next_blink := 2.0
var _blink_t := -1.0
var _prev_velocity := Vector2.ZERO
var _prev_bob := 0.0
var _hop := 0.0
var _zzz := 0.0
var _leap_t := -1.0
var _leap_len := 0.6
var _leap_h := 60.0
var _bark := 0.0
var _mouth := Vector2.ZERO
var _shadow_w := 50.0


func setup(p: Dictionary, display_height := -1.0) -> void:
	pet = p
	fixed_height = display_height
	_build()


## Builds the joint tree again - after a change of clothes.
func rebuild() -> void:
	_build()


func _build() -> void:
	if rig != null:
		rig.queue_free()
	parts.clear()
	rig = Node2D.new()
	add_child(rig)
	rest = PetBuilder.rest_bounds(pet)

	# Parents before children, so an eye can be hung on the head it rides on. Clothes go last,
	# hung on whatever part they were put on, so a hat nods with the head.
	var all: Array = pet["parts"].duplicate()
	for entry in pet.get("outfit", []):
		var item := Items.get_item(entry.get("item", ""))
		if item.is_empty():
			continue
		var wear: Dictionary = entry.duplicate()
		wear["id"] = "wear_%s" % entry["item"]
		wear["type"] = "clothing"
		wear["pivot"] = PetBuilder.arr(Items.pivot_of(item))
		wear["draw_scale"] = 1.0
		wear["_item"] = item
		all.append(wear)

	var made := {}
	var pending := all
	var guard := 0
	while not pending.is_empty() and guard < 64:
		guard += 1
		for p in pending.duplicate():
			var parent_id: String = p["parent"]
			if parent_id != "" and not made.has(parent_id):
				if PetBuilder.find(pet, parent_id).is_empty():
					p["parent"] = "body"  # its part was removed; it falls back to the body
				continue
			var part := CreaturePart.new()
			if p.has("_item"):
				var item: Dictionary = p["_item"]
				p["shine"] = item.get("shine", "")
				part.setup(p, item["_tex"], item["_img"], item.get("_shine"))
			else:
				part.setup(p, PetStore.texture(pet, p["image"]), pet["_img"].get(p["image"]),
					pet["_img"].get(p.get("shine_image", ""), null))
			if parent_id == "":
				# The body's middle is body-space (0, 0); shift it so the lowest ink of the
				# whole creature stands on the ground and it is centred over its position.
				part.base = Transform2D(0.0, Vector2.ONE, 0.0,
					Vector2(-rest.get_center().x, -rest.end.y))
				rig.add_child(part)
				body = part
			else:
				var parent: CreaturePart = made[parent_id]
				var pp := PetBuilder.find(pet, parent_id)
				var parent_x := Transform2D.IDENTITY if pp["type"] == "body" \
					else PetBuilder.joint_xform(pp)
				part.base = parent_x.affine_inverse() * PetBuilder.joint_xform(p)
				parent.add_child(part)
				if p["behind"]:
					parent.move_child(part, parent.sprite.get_index())
			made[p["id"]] = part
			parts.append(part)
			pending.erase(p)

	has_legs = PetBuilder.has_type(pet, "leg") or PetBuilder.has_type(pet, "tentacle")
	can_fly = PetBuilder.has_type(pet, "wing")
	can_swim = PetBuilder.has_type(pet, "fin")
	_mouth = _find_mouth()
	_apply_size()


## Where it carries things, in body space: its mouth if it has one, else the front of its head,
## else the front of its body.
func _find_mouth() -> Vector2:
	for p in pet["parts"]:
		if p["type"] == "mouth":
			return PetBuilder.v2(p["pos"])
	var h := PetBuilder.head(pet)
	var box := rest
	if not h.is_empty():
		var img: Image = pet["_img"].get(h["image"])
		if img != null:
			var x := PetBuilder.sprite_xform(h)
			box = Rect2(x * Vector2.ZERO, Vector2.ZERO).expand(x * Vector2(img.get_size()))
	return Vector2(box.end.x - box.size.x * 0.12, box.position.y + box.size.y * 0.6)


func _apply_size() -> void:
	var f: float = SIZES.get(pet.get("size", "medium"), 1.0)
	var target := fixed_height if fixed_height > 0.0 else STANDARD_HEIGHT * f
	# Long, low creatures are sized by length too, so a snake does not become a motorway.
	norm = target / maxf(maxf(rest.size.y, rest.size.x * 0.6), 1.0)
	height_px = rest.size.y * norm
	rig.scale = Vector2(norm * facing, norm)
	walk_speed = (70.0 + 90.0 * sqrt(f)) * (0.75 + Stats.value(pet, "speed") / 100.0 * 0.7)
	_shadow_w = rest.size.x * norm * 0.42


## Sizes it to fit inside `box` (on-screen pixels) whatever its shape - a long pig in a tall
## portrait frame as well as a tall fawn in a wide one. set_display_height sizes by height
## (and lets a long creature run up to 1.7x as wide), which spills out of a narrow frame.
func fit_in(box: Vector2) -> void:
	var n := minf(box.y / maxf(rest.size.y, 1.0), box.x / maxf(rest.size.x, 1.0))
	set_display_height(n * maxf(rest.size.y, rest.size.x * 0.6))


func set_display_height(h: float) -> void:
	fixed_height = h
	_apply_size()


# --- Commands -------------------------------------------------------------------------------

func go_to(where: Vector2, on_arrive := Callable(), run := false, fly := false) -> void:
	_goal = where
	if confine:
		_goal = _goal.clamp(bounds.position, bounds.end)
	_has_goal = true
	_on_arrive = on_arrive
	_run = run
	flying = fly and can_fly
	rest_z = 0.0


func stop() -> void:
	_has_goal = false
	_on_arrive = Callable()


## Plays an action for `duration` seconds: eat, petted, wiggle, belly, cuddle, celebrate, greet,
## hop, look, sniff, sleep, bounce, dance, splash, scratch, chew, tug, hide.
func perform(action_name: String, duration: float, on_done := Callable()) -> void:
	_end_action()
	_action = action_name
	_action_len = duration
	_action_left = duration
	_on_action_done = on_done
	_has_goal = false


## Keeps a running action going a while longer - stroking keeps "petted" alive.
func extend_action(at_least: float) -> void:
	_action_left = maxf(_action_left, at_least)


## Stops whatever it is doing, without the action's on_done.
func interrupt() -> void:
	_end_action()
	stop()


func action() -> String:
	return _action


func is_busy() -> bool:
	return _action != "" or _has_goal


func face_toward(x: float) -> void:
	if absf(x - position.x) > 2.0:
		facing = signf(x - position.x)


## A jump of `height` px lasting `duration` s, whatever it is doing - hurdles, catching.
func leap(height: float, duration: float) -> void:
	_leap_t = 0.0
	_leap_len = duration
	_leap_h = height


func is_leaping() -> bool:
	return _leap_t >= 0.0


func say(kind: String) -> void:
	if kind in ["heart", "star", "note", "question", "greet", "hello"]:
		Voice.speak(pet, kind, self)
	elif kind == "zzz" and audible:
		Sounds.play_varied("snore", _size_pitch(), 0.05, -3.0)
	_bark = maxf(_bark, 0.35)
	emote.emit(kind, top_global())


## Blinks right now, rather than when it next would - to show a kid the eyes they drew blink.
func blink_now() -> void:
	_blink_t = 0.0


## Opens its mouth for `seconds` - while its voice is playing.
func open_mouth(seconds: float) -> void:
	_bark = maxf(_bark, seconds)


func _size_pitch() -> float:
	return float(SIZE_PITCH.get(pet.get("size", "medium"), 1.0))


# --- Where things are -----------------------------------------------------------------------

func mouth_global() -> Vector2:
	return body.to_global(_mouth)


## How far in front of its feet its mouth is, horizontally, on screen.
func mouth_reach() -> float:
	return absf(_mouth.x - rest.get_center().x) * norm * scale.x


func top_global() -> Vector2:
	return global_position + Vector2(0, (-height_px - z - 10.0) * scale.y)


## True when a global point is on (or very near) the creature.
func hit(point: Vector2) -> bool:
	return _box().grow(12.0).has_point(point)


## Where a finger is on it: "head" (its head, or its face if it has no head) or "body".
func touch_zone(point: Vector2) -> String:
	var face_parts := false
	for part in parts:
		if part.type != "head" and not PartTypes.FACE.has(part.type):
			continue
		face_parts = true
		var g := part.sprite.get_global_transform()
		var r := part.sprite.get_rect()
		var box := Rect2(g * r.position, Vector2.ZERO).expand(g * r.end).abs()
		if box.grow(10.0).has_point(point):
			return "head"
	if face_parts:
		return "body"
	var whole := _box()
	return "head" if point.y < whole.position.y + whole.size.y * 0.4 else "body"


## Its drawing's bounds on screen.
func _box() -> Rect2:
	var g := body.get_global_transform()
	return Rect2(g * rest.position, Vector2.ZERO).expand(g * rest.end).abs()


# --- Every frame ----------------------------------------------------------------------------

func _process(delta: float) -> void:
	time += delta
	if not driven:
		_think(delta)
	elif _action != "":
		_action_left -= delta
		_run_action(delta)
		if _action_left <= 0.0:
			_end_action()
	_move(delta)
	_mood(delta)
	for part in parts:
		part.animate(self, delta)
	if _action != "belly":
		roll = move_toward(roll, 0.0, delta * 3.0)
	# Rolled over, it lies on its back where it stood: tipped backwards about its feet, then
	# slid forwards so its middle stays over its shadow.
	rig.position = Vector2(facing * roll * height_px * 0.3 / maxf(scale.x, 0.01), -z)
	rig.rotation = (lean + (0.16 if straining else 0.0) - roll * 1.35) * facing
	rig.scale = Vector2(move_toward(rig.scale.x, norm * facing, norm * delta * 10.0), norm)
	if depth_scale:
		var d := clampf(inverse_lerp(bounds.position.y, bounds.end.y, position.y), 0.0, 1.0)
		scale = Vector2.ONE * lerpf(0.82, 1.12, d)
	queue_redraw()


func _draw() -> void:
	var shrink := clampf(1.0 - (z - rest_z) / maxf(height_px * 2.5, 1.0), 0.35, 1.0)
	draw_set_transform(Vector2(0, -rest_z), 0.0, Vector2(1.0, 0.26))
	draw_circle(Vector2.ZERO, _shadow_w * shrink, Color(0.32, 0.27, 0.5, 0.16))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _think(delta: float) -> void:
	if _action != "":
		_action_left -= delta
		_run_action(delta)
		if _action_left <= 0.0:
			var done := _on_action_done
			_end_action()
			if done.is_valid():
				done.call()
		return
	if _has_goal or not wander:
		return
	_idle -= delta
	if _idle > 0.0:
		return
	_idle = randf_range(1.5, 4.5) * (1.7 - happiness)
	var roll := randf()
	var spot := Vector2(randf_range(bounds.position.x, bounds.end.x),
		randf_range(bounds.position.y, bounds.end.y))
	if roll < 0.55:
		go_to(spot)
	elif roll < 0.7 and can_fly:
		go_to(spot, Callable(), false, true)
	elif roll < 0.85:
		perform("look", 1.6)
	else:
		perform("hop", 0.7)


func _move(delta: float) -> void:
	var target_v := Vector2.ZERO
	if driven:
		target_v = drive_velocity
	elif _has_goal and _action == "":
		var to := _goal - position
		var dist := to.length()
		var speed := walk_speed * (1.9 if _run else 1.0) * (0.65 + 0.5 * happiness)
		if dist < 5.0:
			_has_goal = false
			var arrive := _on_arrive
			_on_arrive = Callable()
			if arrive.is_valid():
				arrive.call()
		else:
			target_v = to / dist * minf(speed, dist / maxf(delta, 0.001))
	velocity = target_v if driven else velocity.move_toward(target_v, walk_speed * 9.0 * delta)
	position += velocity * delta
	if confine:
		position = position.clamp(bounds.position, bounds.end)
	accel = (velocity - _prev_velocity) / maxf(delta, 0.001)
	_prev_velocity = velocity

	var spd := velocity.length()
	var moving := spd > 8.0
	if absf(velocity.x) > 8.0 and _action not in ["celebrate", "dance"]:
		facing = signf(velocity.x)

	var swimming := in_water and can_swim
	var aloft := flying or swimming
	var walking := moving and has_legs and not aloft
	var hopping := moving and not has_legs and not aloft

	stride = move_toward(stride, 1.0 if walking else 0.0, delta * 6.0)
	var old_step := int(phase / PI)
	phase += delta * spd * PI / maxf(height_px * 0.35, 8.0)
	if audible and walking and stride > 0.5 and int(phase / PI) != old_step:
		Sounds.play_varied("step", _size_pitch(), 0.08, step_volume_db)
	bob = absf(sin(phase)) * rest.size.y * 0.035 * stride

	# Height above the ground: a leap, flying, swimming, hopping, or standing on something.
	var lift := 0.0
	if swimming:
		lift = height_px * 0.35 + sin(time * 1.6) * 6.0
	elif flying:
		lift = height_px * 0.75 + sin(time * 3.0) * 5.0
	if _leap_t >= 0.0:
		_leap_t += delta
		var k := clampf(_leap_t / _leap_len, 0.0, 1.0)
		z = rest_z + sin(k * PI) * _leap_h
		if k >= 1.0:
			_leap_t = -1.0
			if audible:
				Sounds.play_varied("land", _size_pitch(), 0.06, step_volume_db)
	elif aloft:
		z = move_toward(z, lift, delta * maxf(height_px, 60.0) * 1.5)
	elif hopping:
		var old_hop := int(_hop / PI)
		_hop += delta * spd * PI / maxf(height_px * 0.6, 10.0)
		if audible and int(_hop / PI) != old_hop:
			Sounds.play_varied("hop", _size_pitch(), 0.07, step_volume_db - 4.0)
		z = rest_z + absf(sin(_hop)) * height_px * 0.22
	elif _action not in ["hop", "celebrate", "greet", "bounce", "dance", "wiggle"]:
		z = move_toward(z, rest_z, delta * maxf(height_px, 60.0) * 3.0)
		_hop = 0.0
	if flying and not _has_goal and _action == "" and z >= lift - 2.0:
		flying = false  # landed from the flight: drift back down next frame

	flap = move_toward(flap, 1.0 if flying and z > 4.0 else 0.0, delta * 5.0)
	if audible and flap > 0.5:
		_flap_in -= delta
		if _flap_in <= 0.0:
			_flap_in = 0.32
			Sounds.play_varied("flap", _size_pitch(), 0.08, step_volume_db)
	if audible and swimming:
		_bubble_in -= delta
		if _bubble_in <= 0.0:
			_bubble_in = randf_range(0.6, 1.6)
			Sounds.play_varied("bubble", _size_pitch(), 0.15, step_volume_db - 2.0)
	swim = move_toward(swim, 1.0 if swimming and moving else 0.0, delta * 3.0)
	tuck = move_toward(tuck, 1.0 if (z - rest_z > 6.0 and not walking) else 0.0, delta * 4.0)
	var target_squash := 0.0
	if hopping:
		target_squash = -0.1 if z - rest_z < height_px * 0.04 else 0.06
	squash = move_toward(squash, target_squash, delta * 2.0)
	bob_vel = (bob - _prev_bob) / maxf(delta, 0.001)
	_prev_bob = bob


func _mood(delta: float) -> void:
	happiness = PetStore.happiness(pet) if pet.has("needs") else 0.7
	var excited := 1.0 if _action in ["celebrate", "petted", "greet", "dance", "bounce", "wiggle", "belly"] else 0.0
	wag = 0.08 + 0.3 * happiness + 0.2 * excited
	wag_speed = 3.0 + 11.0 * happiness + 8.0 * excited
	ear_droop = (1.0 - happiness) * 0.35
	breath_speed = 1.2 if _action == "sleep" else 2.2 + stride * 2.0

	# The mouth: shut unless something opens it. It pants when running, grins when excited,
	# opens for a bark, and chomps when eating (set in _run_action).
	var target_mouth := 0.0
	if _run and velocity.length() > walk_speed:
		target_mouth = 0.45 + 0.2 * sin(time * 14.0)
	if excited > 0.0 and _action != "petted":
		target_mouth = 0.65
	if _action == "cuddle":
		target_mouth = 0.2
	if _bark > 0.0:
		_bark -= delta
		target_mouth = 1.0
	if _action not in ["eat", "chew", "sleep", "tug"]:
		mouth_open = move_toward(mouth_open, target_mouth, delta * 6.0)

	if _action in ["petted", "sleep", "belly", "cuddle"]:
		blink = move_toward(blink, 0.85, delta * 6.0)
		return
	_next_blink -= delta
	if _next_blink <= 0.0:
		_next_blink = randf_range(1.5, 5.0)
		_blink_t = 0.0
	if _blink_t >= 0.0:
		_blink_t += delta
		blink = sin(clampf(_blink_t / 0.16, 0.0, 1.0) * PI)
		if _blink_t > 0.16:
			_blink_t = -1.0
			blink = 0.0
	else:
		blink = move_toward(blink, 0.0, delta * 6.0)


func _run_action(delta: float) -> void:
	var t := _action_len - _action_left
	var k := clampf(t / maxf(_action_len, 0.01), 0.0, 1.0)
	match _action:
		"eat":
			mouth_open = absf(sin(t * 10.0))
			nod = 0.12
		"chew":
			mouth_open = absf(sin(t * 6.0)) * 0.6
			nod = 0.06
			lean = 0.1
		"petted":
			# Eyes shut, head tipped into the hand, leaning towards the finger.
			head_tilt = 0.14
			if touch_at != Vector2.INF:
				var toward := clampf((touch_at.x - global_position.x) / maxf(height_px, 1.0), -1.0, 1.0)
				lean = move_toward(lean, toward * 0.12 * facing, delta * 1.5)
		"wiggle":
			# A back rub: the happy whole-body wiggle.
			lean = sin(t * 13.0) * 0.07
			head_tilt = sin(t * 13.0 + 1.2) * 0.1
			z = rest_z + absf(sin(t * 6.5)) * height_px * 0.03
		"belly":
			# Rolled over for a belly rub, legs kicking in the air.
			roll = move_toward(roll, 1.0, delta * 4.0)
			stride = 1.0
			phase += delta * 14.0
			head_tilt = sin(t * 5.0) * 0.08
		"cuddle":
			# Hugging a soft toy, swaying a little.
			head_tilt = 0.16 + sin(t * 2.0) * 0.05
			lean = sin(t * 1.8) * 0.05
		"sniff":
			sniff = 1.0
			nod = 0.05
		"look":
			head_tilt = sin(t * 3.0) * 0.18
		"hop":
			z = rest_z + sin(k * PI) * height_px * 0.25
		"celebrate", "greet":
			z = rest_z + absf(sin(t * 8.0)) * height_px * 0.28
			wave = 1.0
			if _action == "celebrate" and int(t * 4.0) % 2 == 1:
				facing = -absf(facing)
			else:
				facing = absf(facing)
		"bounce":
			z = rest_z + absf(sin(t * 5.0)) * height_px * 0.7
			wave = 1.0
			tuck = 1.0
		"dance":
			z = rest_z + absf(sin(t * 8.0)) * height_px * 0.1
			facing = 1.0 if int(t * 2.0) % 2 == 0 else -1.0
			wave = 1.0
			head_tilt = sin(t * 8.0) * 0.15
			if int(t * 1.5) != int((t - delta) * 1.5):
				say("note")
		"splash":
			z = rest_z + absf(sin(t * 7.0)) * height_px * 0.12
			if int(t * 2.0) != int((t - delta) * 2.0):
				emote.emit("drop", global_position + Vector2(randf_range(-30, 30), -10))
		"scratch":
			stride = 1.0
			phase += delta * 22.0
			head_tilt = 0.1
		"tug":
			lean = -0.18
			mouth_open = 0.5
			stride = 0.6
			phase += delta * 9.0
			head_tilt = sin(t * 15.0) * 0.1  # the growly shake
		"hide":
			head_tilt = sin(t * 1.5) * 0.1
		"sleep":
			if t <= delta:
				Voice.yawn(pet, self)
			mouth_open = sin(clampf(t / 1.4, 0.0, 1.0) * PI) * 0.9  # one big yawn first
			_zzz -= delta
			if _zzz <= 0.0 and t > 1.4:
				_zzz = 1.6
				say("zzz")


func _end_action() -> void:
	_action = ""
	nod = 0.0
	sniff = 0.0
	wave = 0.0
	head_tilt = 0.0
	lean = 0.0
	_on_action_done = Callable()
