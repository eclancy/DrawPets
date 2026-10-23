class_name WalkScreen
extends Node2D
## A walk (.ai/places.md): one pet trots along its home's place - on and on, the place repeating
## - and the camera follows. Tap ahead and it runs there; tap behind and it turns back.
##
## Now and then a glint in the grass: it sniffs, digs (muddy paws), and up comes a present. Tap
## the present and it asks "Draw what's inside - a BOUNCY toy!", that word already picked, and
## the drawing becomes a real toy, snack or thing for the home. Three presents a day, a star each
## when it is drawn (GameRoot.present_drawn).
##
## What to do is shown, not told - players start at 7 and many barely read. The line at the bottom
## says what the walk is for, with a sparkle beside it; a tap on a sparkle sends the pet straight
## there to dig; a present hops until it is tapped, with the pet waiting by it, so it can never be
## walked away from. For a kid's first three walks with presents a drawn hand (HowTo) taps the
## sparkle and then the present, and comes back if one is still waiting a while later.

## What a present can be, and the words it might be.
const ASK := {
	"toy": ["bouncy", "squeaky", "stretchy", "floaty", "soft", "spinny", "rolly", "chewy", "glowy"],
	"food": ["sweet", "crunchy", "juicy", "spicy", "fishy", "weird", "cold", "chewy"],
	"furniture": ["cozy", "bouncy", "climbable", "hidey", "musical", "slidey", "glowy", "splashy"],
}
const KIND := {"toy": "toy", "food": "snack", "furniture": "thing for its home"}
const TILE := 1280.0
const TILES := 6
## Nothing left to dig up today: a shorter stroll.
const TILES_NO_PRESENTS := 3
const PRESENTS_A_DAY := 3
## How many glints one walk hides, at most.
const GLINTS := 2
## A Treasure Hunt hides three, whatever was found on walks today. Opening one goes off to draw
## it and comes back to the hunt (GameRoot.present_drawn) with the rest still in the grass.
const TREASURE_GLINTS := 3
## How near a tap must be to a sparkle or a present (world px) to count as on it - generous, for
## small fingers on a hopping box.
const TAP_NEAR := 90.0
## The hand comes back after this long while a sparkle or a present still waits for a tap.
const IDLE_BACK := 6.0

var game: GameRoot
var home: Dictionary
var pet_id := ""
## A Beginner Treasure Hunt (FunDays): three glints, whatever was found today.
var treasure := false

var pet: Dictionary
var creature: Creature
var _cam: Camera2D
var _zoom := 1.0
var _world: Node2D
## The glints still buried. One stays here until it is dug up, even while the pet is on its way
## to it, so nothing that stops the pet on the way can lose it.
var _glints: Array[Glint] = []
## The glint the pet is on its way to dig up (or sniffing, or digging).
var _seeking: Glint
var _present: Sprite2D
var _present_t := 0.0
var _tiles := TILES
var _hint: Label
var _hint_row: HBoxContainer
var _hint_glint: Control
var _hint_time := 6.0
var _hud_root: Control
var _ending := false
var _walked := 0.0
var _last_x := 0.0
var _mud_kind := ""
## The hand showing how (HowTo), while it is up, and what it is tapping ("glint" or "present").
var _how: HowTo
var _how_on := ""
var _how_glint: Glint
var _how_pt := Vector2.ZERO
## Whether this walk shows the hand: -1 not asked yet (asked when there is first something to tap,
## so a walk with nothing to find does not use up one of a kid's three).
var _teach := -1
## What is waiting for a tap now, and for how long without the hand.
var _waiting := 0
var _idle := 0.0
## While the hand's caption fades out, the line at the bottom waits, so the two never overlap.
var _hand_fade := 0.0


func _ready() -> void:
	pet = PetStore.load_pet(pet_id)
	Stats.ensure(pet)
	var place_id: String = home["place"]
	_mud_kind = Mud.kind_for(place_id)
	var n := _presents_left()
	if n <= 0:
		_tiles = TILES_NO_PRESENTS
	for k in _tiles:
		var painter := PlacePainter.new()
		painter.place_id = place_id
		painter.tile = k
		painter.position.x = k * TILE
		add_child(painter)
	_world = Node2D.new()
	_world.y_sort_enabled = true
	add_child(_world)

	creature = Creature.new()
	creature.bounds = Rect2(120, 470, TILE * _tiles - 240, 150)
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
	_cam.limit_right = int(TILE * _tiles)
	_cam.limit_bottom = 720 + int(PlaceScreen.CAM_DROP)
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 3.0
	_cam.position = _cam_target()
	add_child(_cam)
	_cam.make_current()

	_hide_presents(n)
	_build_hud()
	# What the walk is for, with a sparkle beside the words. Steering is optional (it trots on by
	# itself), so it is not what the first line spends itself on.
	if n > 0:
		_show_hint("Look out for sparkles!", true, 9.0)
	else:
		_show_hint("A stroll today - presents tomorrow!")


## How many glints this walk hides: as many as there are presents left today, two at most - and
## on a Treasure Hunt, the hunt's three less the ones opened so far.
func _presents_left() -> int:
	if treasure:
		return maxi(0, TREASURE_GLINTS - int(game.profile.today().get("treasure_opened", 0)))
	var found := int(game.profile.today().get("present_found", 0))
	return mini(GLINTS, PRESENTS_A_DAY - found)


## Glints in the grass along the way.
func _hide_presents(n: int) -> void:
	for i in n:
		var g := Glint.new()
		g.position = Vector2(TILE * (1.4 + i * (1.3 if treasure else 2.1)) + randf_range(0, 500), randf_range(500, 600))
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
	var title := UI.title(("Treasure Hunt with %s!" if treasure else "Out for a walk with %s") % pet["name"], 30)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.offset_top = 16
	_hud_root.add_child(title)
	# The line saying what to do sits at the bottom, clear of the star toasts at the top, and is
	# where the hand's caption goes too.
	_hint_row = HBoxContainer.new()
	_hint_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_hint_row.add_theme_constant_override("separation", 6)
	_hint_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint_row.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_hint_row.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hint_row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_hint_row.offset_bottom = -22
	_hud_root.add_child(_hint_row)
	_hint_glint = Control.new()
	_hint_glint.custom_minimum_size = Vector2(70, 56)
	_hint_glint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var g := Glint.new()
	g.position = Vector2(35, 46)
	_hint_glint.add_child(g)
	_hint_row.add_child(_hint_glint)
	_hint = UI.title("", 30)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint_row.add_child(_hint)


func fit_safe_area() -> void:
	if _hud_root != null:
		UI.fit_safe(_hud_root)


## The line at the bottom, with a sparkle beside it when it is about sparkles. It fades after
## `seconds` - except while a present waits, when it stays.
func _show_hint(text: String, glint := false, seconds := 6.0) -> void:
	_hint.text = text
	_hint_glint.visible = glint
	_hint_row.modulate.a = 1.0
	_hint_time = seconds


func _cam_target() -> Vector2:
	var y := 360.0 + PlaceScreen.CAM_DROP
	if _zoom > 1.01:
		y = creature.position.y - creature.height_px * 0.5
	# A present waiting: between it and the pet, so both stay in sight.
	if _present != null:
		return Vector2(lerpf(creature.position.x, _present.get_parent().position.x, 0.5), y)
	return Vector2(creature.position.x + 160.0 / _zoom, y)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	tap(get_global_mouse_position())


## A tap: on the present it opens; on a sparkle the pet runs to dig it up; on the ground the pet
## runs there. While it has its nose to a sparkle, the ground can wait.
func tap(at: Vector2) -> void:
	_drop_hand()
	if _on_present(at):
		open_present()
		return
	if _ending or _seeking != null or creature.action() in ["dig", "sniff"]:
		return
	if _present == null:
		for g in _glints:
			if at.distance_to(g.position + Vector2(0, -14)) < TAP_NEAR:
				_find(g, true)
				return
	if at.y < Places.HORIZON:
		return
	creature.interrupt()
	creature.go_to(at, Callable(), true)


func _on_present(at: Vector2) -> bool:
	return _present != null and at.distance_to(_present.to_global(_present.offset)) < TAP_NEAR


## Where the pet waits for a present to be opened: a step to the side of it (whichever side it
## is on) and a little behind, so the present stands clear in front, easy to see and to tap.
func _beside_present() -> Vector2:
	var at: Vector2 = _present.get_parent().position
	var side := signf(creature.position.x - at.x)
	if side == 0.0:
		side = -1.0
	return at + Vector2(side * (creature.mouth_reach() + 70.0), -24.0)


func _process(delta: float) -> void:
	if _how != null and not is_instance_valid(_how):
		_how = null
	# One sentence on screen at a time: the hand's caption stands in for the line.
	_hand_fade -= delta
	_hint_row.visible = _how == null and _hand_fade <= 0.0
	if _present == null:
		_hint_time -= delta
		if _hint_time < 1.0:
			_hint_row.modulate.a = maxf(0.0, _hint_time)
	_cam.position = _cam_target()
	_walked += absf(creature.position.x - _last_x)
	_last_x = creature.position.x
	if _walked > 700.0:
		_walked = 0.0
		_train("stamina", 0.5)
	if _present != null:
		# It keeps hopping until it is tapped: a present that sits still gets forgotten.
		_present_t += delta
		_present.position.y = -absf(sin(_present_t * 3.0)) * 12.0
	_coach(delta)
	if _ending:
		return
	if _seeking != null:
		# On its way to dig: if anything stopped it on the way, it carries on.
		if not creature.is_busy():
			_find(_seeking)
		return
	# Sniffed out a glint? (Not while a present waits: one at a time.)
	if _present == null:
		for g in _glints:
			if absf(g.position.x - creature.position.x) < 110.0 and absf(g.position.y - creature.position.y) < 90.0:
				_find(g)
				return
		if creature.position.x > creature.bounds.end.x - 60.0:
			_the_end()
			return
	# Trots on ahead by itself - unless a present is waiting, when it waits beside it (and comes
	# back to it if a tap sends it off).
	if not creature.is_busy():
		if _present != null:
			var spot := _beside_present()
			if creature.position.distance_to(spot) > 40.0:
				creature.go_to(spot, Callable(), creature.position.distance_to(spot) > 260.0)
			else:
				creature.face_toward(_present.get_parent().position.x)
				creature.perform("hop" if randf() < 0.25 else "look", 1.5)
		else:
			# Its nose leads it towards a glint up ahead.
			var y := creature.position.y + randf_range(-50, 50)
			for g in _glints:
				var ahead := g.position.x - creature.position.x
				if ahead > 0.0 and ahead < 700.0:
					y = lerpf(creature.position.y, g.position.y, 0.6)
			creature.go_to(Vector2(creature.position.x + 240.0, y))


# --- Presents --------------------------------------------------------------------------------

func _find(g: Glint, run := false) -> void:
	_seeking = g
	creature.interrupt()
	var side := signf(g.position.x - creature.position.x)
	if side == 0.0:
		side = 1.0
	creature.go_to(g.position - Vector2(side * (creature.mouth_reach() + 10.0), -2.0), _sniff_at.bind(g), run)


func _sniff_at(g: Glint) -> void:
	creature.face_toward(g.position.x)
	Sounds.play_varied("sniff", creature._size_pitch())
	creature.perform("sniff", 0.9, _dig_at.bind(g))
	creature.say("question")
	_show_hint("Sniff, sniff... dig, dig!")


func _dig_at(g: Glint) -> void:
	for i in 4:
		get_tree().create_timer(i * 0.5).timeout.connect(Sounds.play_varied.bind("scratch", 0.8, 0.06, -2.0))
	creature.perform("dig", 2.0, _dug_up.bind(g))


## Up comes a present - and its digger's paws are muddy.
func _dug_up(g: Glint) -> void:
	var at := g.position
	_glints.erase(g)
	_seeking = null
	g.queue_free()
	if treasure:
		FunDays.join(game, "treasure")
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
	# The same words the hand says when it taps it.
	_show_hint("Tap the present!")


## "Draw what's inside - a BOUNCY toy!" - a kind of thing and one word for it, that word already
## picked. (The demo asks for a particular one.) It counts towards today's three when it is
## opened, not when it is dug up, so a present left behind (Home) is not one used up - and the
## journal line goes with it, so walking out and back again and again cannot fill a pet's journal.
func open_present(cat := "", word := "") -> void:
	if _present == null:
		return
	if cat == "":
		cat = ["toy", "toy", "food", "furniture"].pick_random()
	if word == "":
		word = ASK[cat].pick_random()
	Sounds.play("pickup")
	_drop_hand()
	_present = null
	if treasure:
		game.profile.count_today("treasure_opened", TREASURE_GLINTS)
	elif game.profile.count_today("present_found", PRESENTS_A_DAY):
		Journal.add(pet, "Dug up a present on a walk!")
	_save()
	game.make_item(cat, game.present_drawn.bind(home["id"], pet_id, treasure),
		"Draw what's inside - a %s %s!" % [word.to_upper(), KIND[cat]], [word])


# --- The hand --------------------------------------------------------------------------------

## For a kid's first three walks with presents: the hand taps a sparkle in sight, then the
## present when it is dug up - straight away for each new one, then again whenever one has been
## waiting IDLE_BACK seconds since the hand last went. Taps elsewhere send it away (until_touch)
## but do not stop it coming back: only a tap on the right thing is what is wanted.
func _coach(delta: float) -> void:
	var want := ""
	var thing: Object = null
	if not _ending and _present != null:
		want = "present"
		thing = _present
	elif not _ending and _seeking == null and creature.action() not in ["dig", "sniff"]:
		thing = _glint_in_view()
		if thing != null:
			want = "glint"
	# What it points at is gone, or found: away it goes.
	if _how != null and (want != _how_on or (want == "glint" and (not is_instance_valid(_how_glint) or thing != _how_glint))):
		_drop_hand()
	var id := thing.get_instance_id() if thing != null else 0
	if id != _waiting:
		_waiting = id
		# Something new to tap: the hand comes almost at once (after the present's pop).
		_idle = IDLE_BACK - (1.2 if want == "present" else 0.4)
	if want == "" or _how != null:
		return
	_idle += delta
	if _idle >= IDLE_BACK and _teaching():
		_show_hand(want, thing)


func _teaching() -> bool:
	if _teach < 0:
		_teach = 1 if HowTo.first_times(game.profile, "howto_walk", 3) else 0
	return _teach == 1


## A glint on screen and not yet found (the one nearest ahead of the pet), or null.
func _glint_in_view() -> Glint:
	var width := get_viewport_rect().size.x
	var best: Glint = null
	for g in _glints:
		var p := get_canvas_transform() * g.global_position
		if p.x < 120.0 or p.x > width - 120.0:
			continue
		if best == null or absf(g.position.x - creature.position.x) < absf(best.position.x - creature.position.x):
			best = g
	return best


func _show_hand(want: String, thing: Object) -> void:
	_drop_hand()
	_how = HowTo.new()
	_how.gesture = "tap"
	_how.until_touch = true
	_how_on = want
	if want == "present":
		_how.caption = "Tap the present!"
	else:
		_how_glint = thing as Glint
		_how.caption = "Tap the sparkle!"
	_how.at = _hand_point
	# Where the line at the bottom is, which it stands in for.
	_how.caption_y = 626.0
	_hud_root.add_child(_how)
	_hint_row.visible = false
	_idle = 0.0


func _drop_hand() -> void:
	if _how != null and is_instance_valid(_how):
		_how.dismiss()
		_hand_fade = 0.35
	_how = null
	_how_on = ""


## Where the hand taps, in the HUD's space: the middle of the present, or just above the
## sparkle's mound. It stays put if that thing has just gone.
func _hand_point() -> Vector2:
	var world := Vector2.INF
	if _how_on == "present" and _present != null and is_instance_valid(_present):
		world = _present.to_global(_present.offset)
	elif _how_on == "glint" and is_instance_valid(_how_glint):
		world = _how_glint.global_position + Vector2(0, -14)
	if world != Vector2.INF:
		_how_pt = _hud_root.get_global_transform_with_canvas().affine_inverse() * (get_canvas_transform() * world)
	return _how_pt


# --- The end of the walk ---------------------------------------------------------------------

func _the_end() -> void:
	_ending = true
	_drop_hand()
	creature.stop()
	creature.perform("celebrate", 1.6)
	creature.say("heart")
	_show_hint("What a walk - home time!")
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
	Care.played(pet)
	PetStore.change_need(pet, "fun", 0.2)
	PetStore.change_need(pet, "energy", -0.08)
	PetStore.save_pet(pet)


func _exit_tree() -> void:
	PetStore.save_pet(pet)


func _train(stat: String, amount: float) -> void:
	var levels := Stats.train(pet, stat, amount)
	if levels > 0 and game.profile.advanced():
		Sounds.play("level_up")
		creature.say("star")
		game.reward(3 * levels, "%s's %s is level %d!" % [pet["name"], Stats.label(stat),
			Stats.level(Stats.value(pet, stat))])


func _on_emote(kind: String, at: Vector2) -> void:
	var e := Emote.new()
	e.kind = kind
	e.position = at
	add_child(e)


## A glint in the grass where a present is buried: a little mound of turned earth and three
## pencil twinkles taking turns over it - warm yellow, so it shows on pale grass, but pencil, not
## shine (shine is for bought things).
class Glint extends Node2D:
	var _t := 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		Crayon.fill_blob(self, Vector2(0, 4), Vector2(30, 9), Color(0.8, 0.66, 0.5, 0.55), 5, 0.15)
		for i in 3:
			var at := Vector2((i - 1) * 22.0, -10.0 - (i % 2) * 16.0)
			var a := clampf(0.5 + 0.5 * sin(_t * 4.0 + i * 2.1), 0.0, 1.0)
			var r := 9.0 + 8.0 * a
			var pts := PackedVector2Array()
			for k in 8:
				var rr := r if k % 2 == 0 else r * 0.3
				var ang := -PI / 2.0 + k * PI / 4.0
				pts.append(at + Vector2(cos(ang), sin(ang)) * rr)
			Crayon.marker_fill(self, pts, Color(1.0, 0.9, 0.45, 0.55 + 0.45 * a), 7 + i, 6.0)
			Crayon.marker_line(self, pts, Color(0.93, 0.6, 0.22, 0.5 + 0.5 * a), 2.5, 17 + i)
