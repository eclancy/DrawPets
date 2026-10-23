class_name CompetitionScreen
extends Node2D
## A competition, start to finish: meet the rivals, see how to play, play the event's mini-game,
## then the podium, ribbons and prizes (.ai/competitions.md).
##
## Every event mixes the pet's stat with the kid's timing, so a well-trained pet does well even
## with clumsy tapping, and great tapping can carry a pet a cup above its training. Every
## mini-game emits `finished` with [{who: "player" or a rival index, score}] - higher is better.
##
## How to play is shown before it is told: the intro plays a little picture of the event's cue
## with the hand doing the move in time (HowPanel), and the words sit beside it for readers.
## There is always a way out - Back on the intro, and a small Stop while playing.

## The podium's title for a pet that did not make the top three, by mini-game. ("Out in round
## N" for the tug, which is a knockout.)
const WELL_DONE := {"track": "What a race - well done!", "tricks": "What a show - well done!",
	"style": "What a show - well done!"}
## Where the podium stands: left of the middle, so the toasts have the top right to themselves.
const PODIUM_X := 560.0

var game: GameRoot
var event: Dictionary
var tier := 0
var pet: Dictionary
var rivals: Array = []

var _layer: CanvasLayer
var _overlay: Control
var _mini: Node2D
var _stop: Button
var _asking: Control
## Scores that came in while "Stop playing?" was up - a game on its last beat finishes on a
## timer that the question does not stop. Kept till the kid answers, so the podium never pops
## up over the question: Keep playing shows it, Stop leaves.
var _held: Array = []


func _ready() -> void:
	Stats.ensure(pet)
	rivals = Rivals.field(event["kind"], tier, 3, Events.seed_of(event, tier))
	_layer = CanvasLayer.new()
	_layer.layer = 10
	add_child(_layer)
	_intro()


func _exit_tree() -> void:
	# The podium moved the toasts aside; the next screen has them back in the middle.
	if game != null and is_instance_valid(game):
		game.toasts_aside(false)


func _clear_overlay() -> void:
	if _overlay != null:
		UI.retire(_overlay)
	_asking = null
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
	_overlay.add_child(UI.fit_safe(UI.margin(col, 20)))
	var info := Events.info(event["kind"])
	var stat: String = info["stat"]
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	# Back to picking the pet and cup - the game's method, as this screen is gone when it runs.
	top.add_child(UI.icon_button("tool_back", "Back", game.go_event.bind(_back_event()), 40, Vector2(100, 84)))
	top.add_child(UI.icon(Stats.INFO[stat]["icon"], 64))
	top.add_child(UI.title("%s - %s" % [info["name"], Events.TIERS[tier]["name"]], 42))
	col.add_child(top)

	# How to play: the picture doing it, and beside it the tip and the sentence for readers.
	var how := HBoxContainer.new()
	how.alignment = BoxContainer.ALIGNMENT_CENTER
	how.add_theme_constant_override("separation", 24)
	var words := VBoxContainer.new()
	words.custom_minimum_size = Vector2(470, 0)
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	words.add_theme_constant_override("separation", 12)
	var tip := UI.title("", 40)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Room for two lines whatever the tip says, so the sentence under it holds still when the
	# picture's next step brings a longer or shorter one.
	tip.custom_minimum_size.y = 2.0 * tip.get_line_height()
	tip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	words.add_child(tip)
	words.add_child(UI.label(info["how"], 22, true))
	var panel := HowPanel.new()
	panel.kind = event["kind"]
	panel.pet = pet
	panel.profile = game.profile
	panel.theme_word = Events.theme(event)
	panel.tips = info.get("tips", [])
	panel.tip_label = tip
	how.add_child(panel)
	how.add_child(words)
	col.add_child(how)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	for e in entrants():
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(220, 0)
		card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if e["who"] is String:
			card.add_theme_stylebox_override("panel", UI._box(Color("#fff0c2"), UI.ACCENT, 5))
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(190, 180)
		card.add_child(holder)
		var c := Creature.new()
		c.wander = false
		c.confine = false
		c.depth_scale = false
		c.position = Vector2(95, 128)
		holder.add_child(c)
		c.setup(e["pet"], 100.0)
		if not (e["who"] is String):
			c.facing = -1.0
		var l := UI.label("%s\n%s Lv%d" % [e["name"], Stats.label(stat), Stats.level(Stats.value(e["pet"], stat))], 18)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.position = Vector2(0, 132)
		l.size = Vector2(190, 48)
		holder.add_child(l)
		row.add_child(card)
	col.add_child(row)
	col.add_child(UI.big_button("Ready!", _start))


## Where Back on the intro goes: the event's own screen with this pet and cup still picked. A
## practice goes back through the Fun Fair, so it stays a practice.
func _back_event() -> Dictionary:
	var back := event.duplicate()
	back["tier"] = tier
	back["pet_id"] = pet.get("id", "")
	if event.get("practice", false):
		back["pick"] = event["kind"]
		back["kind"] = "fair"
	return back


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
	_add_stop()


# --- A way out -------------------------------------------------------------------------------

## A small Stop in the corner while playing. Most events take a tap anywhere, so a stray tap on
## it only asks first - the game waits meanwhile - and only "Stop" leaves, for the calendar.
func _add_stop() -> void:
	_stop = UI.icon_button("snd_stop", "Stop", _ask_stop, 34, Vector2(84, 80))
	_stop.position = Vector2(14.0 + UI.safe_insets.x, 14.0)
	_overlay.add_child(_stop)


## Whether a press at `pos` (screen space) is on the Stop button. A game reading every touch in
## _input sees that press before the button does, and can leave it alone with this.
func is_over_stop(pos: Vector2) -> bool:
	return _stop != null and is_instance_valid(_stop) and _stop.is_visible_in_tree() \
		and _stop.get_global_rect().has_point(pos)


func _ask_stop() -> void:
	if _mini == null or _asking != null:
		return
	_mini.process_mode = Node.PROCESS_MODE_DISABLED
	_asking = Control.new()
	_asking.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var veil := UI.paper_background()
	veil.color = Color(UI.PAPER, 0.8)
	# It catches every tap, so nothing reaches the waiting game underneath.
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	_asking.add_child(veil)
	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	card.grow_vertical = Control.GROW_DIRECTION_BOTH
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 20)
	var ask := UI.title("Stop playing?", 44)
	ask.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(ask)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	row.add_child(UI.big_icon_button("snd_play", "Keep playing", _keep_playing))
	# The game's own method: this screen is freed by the time the calendar opens.
	row.add_child(UI.icon_button("icon_calendar", "Stop", game.go_calendar, 48, Vector2(130, 96)))
	col.add_child(row)
	card.add_child(UI.margin(col, 22))
	_asking.add_child(card)
	_overlay.add_child(UI.full_rect(_asking))


func _keep_playing() -> void:
	if _asking != null:
		UI.retire(_asking)
		_asking = null
	if _mini != null:
		_mini.process_mode = Node.PROCESS_MODE_INHERIT
	if not _held.is_empty():
		var scores := _held
		_held = []
		_results(scores)


# --- Results ---------------------------------------------------------------------------------

## Places, prizes, ribbons, training - then the podium.
func _results(scores: Array) -> void:
	if _asking != null:
		_held = scores
		return
	# The podium's winner stands in the middle at the top - the toasts go to the side.
	game.toasts_aside(true)
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
	if not practice and place <= 3:
		Journal.add(pet, "Came %s in the %s, %s!" % [_ordinal(place), Events.info(event["kind"]).get("name", ""),
			Events.TIERS[tier]["name"]])
	PetStore.save_pet(pet)

	var prize: Array = Events.TIERS[tier]["prize"]
	if practice:
		game.reward_daily("fair", 3, 1, "Practice makes perfect!")
	elif first_try:
		game.reward(prize[place - 1], "%s place in the %s!" % [_ordinal(place), Events.TIERS[tier]["name"]])
	else:
		game.reward_daily("rematch", 3, 1, "Good try!")
	# These leave the pet's name out (it is on the podium): the toasts sit down the right while
	# it is up, and a long name made them wide enough to cover the winner on the top step.
	if gained > 0:
		game.reward(3 * gained, "%s went up!" % Stats.label(stat))
	if place == 1 and tier >= 2 and p.owned("neck_medal") == 0:
		p.give("neck_medal")
		game.toast("You won a GOLD MEDAL to wear!", "icon_trophy")
	_podium(scores, place)


## The title, and a line under it, for how the kid's pet did - in the event's own words.
func _headline(scores: Array, place: int) -> Array:
	var kind: String = Events.info(event["kind"])["game"]
	var mine := 0.0
	for s in scores:
		if s["who"] is String:
			mine = float(s["score"])
	var title: String = "You came %s!" % _ordinal(place) if place <= 3 else WELL_DONE.get(kind, "Well done!")
	var line := ""
	match kind:
		"tug":
			# A knockout: the score is rounds won (and a half), so say which round ended it.
			var wins := int(mine)
			if wins >= 3:
				line = "You won all three rounds!"
			elif place > 3:
				title = "Out in round %d - well pulled!" % (wins + 1)
			else:
				line = "Out in round %d - well pulled!" % (wins + 1)
		"tricks":
			var rounds := int(mine)
			if rounds > 0:
				line = "You got %d round%s right!" % [rounds, "" if rounds == 1 else "s"]
	return [title, line]


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

	var words := _headline(scores, place)
	var title := UI.title(words[0], 48)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.offset_top = 14
	stage.add_child(title)
	if words[1] != "":
		var line := UI.title(words[1], 26)
		line.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		line.grow_horizontal = Control.GROW_DIRECTION_BOTH
		line.offset_top = 76
		stage.add_child(line)

	var podium := Sprite2D.new()
	podium.texture = Items.art_texture("prop_podium")
	podium.centered = false
	var pimg := podium.texture.get_image()
	var k := 460.0 / maxf(pimg.get_width(), 1.0)
	podium.scale = Vector2(k, k)
	podium.position = Vector2(PODIUM_X - pimg.get_width() * k / 2.0, 640.0 - pimg.get_height() * k)
	stage.add_child(podium)
	var tops := [Vector2(PODIUM_X, 640 - pimg.get_height() * k * 0.92),
		Vector2(PODIUM_X - 155, 640 - pimg.get_height() * k * 0.62),
		Vector2(PODIUM_X + 155, 640 - pimg.get_height() * k * 0.45)]
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

	# Everyone in order, with their pet's level in the event's stat - the half of the score
	# that is training, so a kid can see why a rival was hard to beat.
	var stat: String = Events.info(event["kind"])["stat"]
	var list := VBoxContainer.new()
	list.position = Vector2(36.0 + UI.safe_insets.x, 140)
	list.add_theme_constant_override("separation", 2)
	for i in scores.size():
		var e: Dictionary = all[0] if scores[i]["who"] is String else all[int(scores[i]["who"]) + 1]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var l := UI.label("%d. %s" % [i + 1, e["name"]], 24)
		if scores[i]["who"] is String:
			l.add_theme_color_override("font_color", UI.ACCENT)
		row.add_child(l)
		row.add_child(UI.icon(Stats.INFO[stat]["icon"], 26))
		var lv := UI.label("Lv%d" % Stats.level(Stats.value(e["pet"], stat)), 18)
		lv.add_theme_color_override("font_color", UI.INK_SOFT)
		lv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(lv)
		list.add_child(row)
	stage.add_child(list)

	var buttons := HBoxContainer.new()
	buttons.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	buttons.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	buttons.grow_vertical = Control.GROW_DIRECTION_BEGIN
	buttons.offset_right = -24 - UI.safe_insets.z
	buttons.offset_bottom = -24
	buttons.add_theme_constant_override("separation", 12)
	buttons.add_child(UI.icon_button("tool_undo", "Try again", game.go_competition.bind(event, tier, pet["id"]), 44,
		Vector2(130, 96)))
	var calendar := UI.big_icon_button("icon_calendar", "Calendar", game.go_calendar)
	calendar.custom_minimum_size.y = 96
	buttons.add_child(calendar)
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


## How to play, shown: a little moving picture of the event's cue - the ring, the jump mark, the
## drum, the rope's handle, the cards, the spotlight - with the hand (HowTo) doing the move in
## time with it, and the kid's own pet answering each press the way it will in the game. It loops
## until Ready!, putting the event's tip for each step (Events "tips") in `tip_label`. Its sounds
## play for the first two goes only, so the intro does not nag.
##
## The Dash's ring and the Marathon's drum are the race's own (RingMeter, timed by TrackGame's
## numbers), and the tug's TAP! / STOP sign is the tug's own (TugGame.TapSign), so what the kid learns here
## is exactly what they will see.
class HowPanel extends Control:
	const SIZE := Vector2(520, 270)
	const GREEN := Color("#7cc96b")
	const GOOD_WORD := Color("#3f9a3a")
	const SAND := Color("#efd9b4")
	## Where the Dash's ring and the Marathon's drum sit, and how big they are.
	const RING_AT := Vector2(130, 128)
	const RING_SIZE := 184.0
	const DRUM_AT := Vector2(124, 150)
	const DRUM_SIZE := 196.0
	const HURDLE_CYCLE := 1.6
	## Where the tug's TAP! / STOP sign sits.
	const TUG_SIGN := Vector2(330, 112)
	const HURDLE_GAP := 520.0
	## How far ahead the hurdle is when its mark lights up, and the mark before it. The pet takes
	## off as the hand touches (HowTo's finger is down from 0.42 of its go, so at 0.45) and is at
	## the top of its leap - LEAP high, LEAP_TIME long - just as the hurdle passes under it, the
	## way a jump off a lit mark always clears in the race. The mark is under the pet as it goes.
	const HURDLE_AHEAD := 72.0
	const MARK_BEFORE := 60.0
	const HURDLE_H := 46.0
	const LEAP := 66.0
	const LEAP_TIME := 0.7
	const TAKE_OFF := 0.45
	## The tricks and style pictures play their steps over this long, the hand pressing at these.
	const SHOW := 6.0
	const TRICK_TAPS := [3.3, 4.5]
	const STYLE_TAPS := [1.0, 4.4]

	var kind := "dash"
	var pet: Dictionary
	var profile: Profile
	var theme_word := ""
	var tips: Array = []
	var tip_label: Label

	var _t := 0.0
	var _cycle := 1.0
	var _pet: Creature
	var _pet_at := Vector2.ZERO
	var _hand: HowTo
	var _ring: RingMeter
	var _sign: TugGame.TapSign
	var _word: Label
	var _word_t := 0.0
	var _boost := 0.0
	var _scroll := 0.0
	var _energy := 0.8
	var _flash := 0.0
	## Pictures drawn every frame are held here: a texture nothing holds is freed after the draw
	## call that used it, and shows as a white square.
	var _tex: Texture2D
	var _card_tex := {}
	var _cards: Array = []
	var _order: Array = []
	var _clothes: Array = []
	var _back := UI._box(UI.CARD, UI.INK, 3)
	var _edge := UI._box(UI.CARD, UI.INK, 3)

	func _ready() -> void:
		custom_minimum_size = SIZE
		clip_contents = true
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_edge.draw_center = false
		match kind:
			"dash":
				_cycle = TrackGame.TURN
				_add_pet(Vector2(400, 228), 84.0)
				_add_ring("sweep", TrackGame.GREEN_ZONE, RING_AT, RING_SIZE)
			"hurdles":
				_cycle = HURDLE_CYCLE
				_tex = Items.art_texture("prop_hurdle")
				_add_pet(Vector2(140, 150), 72.0)
			"marathon":
				_cycle = TrackGame.BEAT
				_add_pet(Vector2(400, 228), 84.0)
				# Green for as long either side of the BOOM as a tap counts, as in the race.
				_add_ring("drum", Vector2(1.0 - TrackGame.ON_BEAT / (TrackGame.BEAT * 0.5), 1.0), DRUM_AT, DRUM_SIZE)
			"tug":
				_cycle = TugGame.CYCLE
				_add_pet(Vector2(150, 254), 70.0)
				_pet.perform("tug", 9999.0)
				_sign = TugGame.TapSign.new()
				_sign.radius = 50.0
				_sign.position = TUG_SIGN - TugGame.TapSign.BOX / 2.0
				add_child(_sign)
			"tricks":
				_cycle = SHOW
				_add_pet(Vector2(78, 168), 84.0)
				_cards = Tricks.known(pet)
				for t in ["spin", "jump", "sit", "wave", "roll", "bow", "dance"]:
					if _cards.size() >= 3:
						break
					if not _cards.has(t):
						_cards.append(t)
				_cards = _cards.slice(0, 3)
				_order = [_cards[2], _cards[0]]
				for t in _cards:
					_card_tex[t] = Tricks.card_texture(pet, t)
			"style":
				_cycle = SHOW
				_add_pet(Vector2(340, 228), 84.0)
				_clothes = _pick_clothes()
		_word = UI.title("", 30)
		_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_word.size = Vector2(240, 44)
		_word.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_word)
		_hand = HowTo.new()
		_hand.hand_height = 84.0
		_hand.gesture = "tap"
		_hand.at = _tap_point
		_hand.phase = _hand_phase
		if kind == "tug":
			_hand.on_press = _tug_tap
		add_child(_hand)
		_say_tip()

	func _add_pet(at: Vector2, h: float) -> void:
		_pet = Creature.new()
		_pet.wander = false
		_pet.confine = false
		_pet.depth_scale = false
		_pet.driven = true
		_pet_at = at
		_pet.position = at
		add_child(_pet)
		_pet.setup(pet, h)

	## The race's own ring, centred on `at`.
	func _add_ring(look: String, zone: Vector2, at: Vector2, side: float) -> void:
		_ring = RingMeter.new()
		_ring.style = look
		_ring.zone = zone
		add_child(_ring)
		_ring.size = Vector2(side, side)
		_ring.position = at - _ring.size / 2.0

	## A hat with today's theme word for the starred button (one the kid has, if they do), and
	## two without it beside it. The game's own things are sorted by their catalog entry before
	## any picture loads, and it stops at three hats: loading every toy, food and chair to find
	## them froze the intro for most of a second.
	func _pick_clothes() -> Array:
		var star := ""
		var others := []
		var ids: Array = Items.available(profile, "clothing") if profile != null else []
		for id in Items.KIT.keys() + Items.SHOP.keys():
			if not ids.has(id):
				ids.append(id)
		for id in ids:
			if star != "" and others.size() >= 2:
				break
			var known: Dictionary = Items.catalog(id)
			if not known.is_empty() and (known.get("category", "") != "clothing" or known.get("wear", "") != "head"):
				continue
			var item := Items.get_item(id)
			if item.get("category", "") != "clothing" or item.get("wear", "") != "head":
				continue
			var words: Array = item.get("words", [])
			if words.has(theme_word):
				if star == "":
					star = id
			elif others.size() < 2:
				others.append(id)
		if star == "" and not others.is_empty():
			star = others.pop_back()
		var out := []
		for id in [others[0] if others.size() > 0 else "", star, others[1] if others.size() > 1 else ""]:
			out.append(Items.get_item(id))
		return out

	# --- The clock ---------------------------------------------------------------------------

	## Seconds into this go of the picture.
	func _in() -> float:
		return fmod(_t, _cycle)

	## True when `at` seconds into a go was passed this frame.
	func _passed(before: float, at: float) -> bool:
		return floor((_t - at) / _cycle) != floor((before - at) / _cycle)

	## Sounds for the first two goes only.
	func _loud() -> bool:
		return _t < maxf(2.0 * _cycle, 4.5)

	func _play(sound: String) -> void:
		if _loud():
			Sounds.play(sound)

	func _pop(text: String, at: Vector2, color := UI.INK) -> void:
		_word.text = text
		_word.position = at - _word.size / 2.0
		_word.add_theme_color_override("font_color", color)
		_word_t = 0.8

	func _say_tip() -> void:
		if tip_label == null or tips.is_empty():
			return
		var i := 0
		if kind == "tricks" and _in() >= 2.9:
			i = 1
		elif kind == "style" and _in() >= 2.4:
			i = 1
		var text: String = tips[mini(i, tips.size() - 1)]
		if tip_label.text != text:
			tip_label.text = text

	## Where the hand is in its poke (HowTo's phase: it presses at 0.5), from the picture's clock.
	func _hand_phase() -> float:
		match kind:
			"dash":
				var zone := TrackGame.GREEN_ZONE
				return fposmod(_in() / TrackGame.TURN - (zone.x + zone.y) / 2.0 + 0.5, 1.0)
			"marathon":
				return fposmod(_in() / TrackGame.BEAT + 0.5, 1.0)
			"tricks":
				return _poke(TRICK_TAPS)
			"style":
				return _poke(STYLE_TAPS)
			"tug":
				return TugGame.hint_phase(_t)
		return _in() / _cycle

	## The poke nearest now, at `taps` seconds into the go: down on time, up between them.
	func _poke(taps: Array) -> float:
		var near := float(taps[0])
		for p in taps:
			if absf(_in() - float(p)) < absf(_in() - near):
				near = float(p)
		return clampf(0.5 + (_in() - near) / 0.8, 0.0, 0.999)

	## Where the hand pokes.
	func _tap_point() -> Vector2:
		match kind:
			"dash":
				return RING_AT + Vector2(0, 8)
			"hurdles":
				return Vector2(_pet_at.x + HURDLE_AHEAD - MARK_BEFORE, _pet_at.y + 8.0)
			"marathon":
				return DRUM_AT + Vector2(0, 8)
			"tug":
				return TUG_SIGN + Vector2(0, 10)
			"tricks":
				var a := _card_rect(_cards.find(_order[0])).get_center()
				var b := _card_rect(_cards.find(_order[1])).get_center()
				return a.lerp(b, smoothstep(3.7, 4.1, _in()))
			"style":
				var a := _cloth_rect(1).get_center()
				return a.lerp(_pet_at + Vector2(0, -56), smoothstep(2.6, 3.4, _in()))
		return SIZE / 2.0

	## The hand taps the sign: on TAP! the pet heaves the rope.
	func _tug_tap() -> void:
		_sign.pop = 1.0
		_boost = 0.35
		if _loud():
			Sounds.play_varied("tug", 1.0, 0.06)

	# --- Each frame --------------------------------------------------------------------------

	func _process(delta: float) -> void:
		var before := _t
		_t += delta
		_word_t = maxf(0.0, _word_t - delta)
		_word.modulate.a = clampf(_word_t * 3.0, 0.0, 1.0)
		_flash = maxf(0.0, _flash - delta * 2.5)
		_boost = maxf(0.0, _boost - delta)
		match kind:
			"dash":
				_dash(before, delta)
			"hurdles":
				_hurdles(before)
			"marathon":
				_marathon(before, delta)
			"tug":
				_tug(before)
			"tricks":
				_tricks(before)
			"style":
				_style(before, delta)
		_say_tip()
		# A driven creature walks itself along; this one runs on the spot.
		if _pet != null:
			_pet.position = _pet_at
		queue_redraw()

	func _dash(before: float, delta: float) -> void:
		_ring.value = _in() / TrackGame.TURN
		# The hand pokes as the sweep comes into the green: a burst of speed.
		if _passed(before, (TrackGame.GREEN_ZONE.x + 0.02) * TrackGame.TURN):
			_boost = 0.85
			_ring.flash = 1.0
			_pop("ZOOM!", _pet_at + Vector2(0, -116), GOOD_WORD)
			_play("good")
		var speed := 260.0 if _boost > 0.0 else 120.0
		_pet.drive_velocity = Vector2(speed, 0)
		_scroll += speed * delta

	func _hurdles(before: float) -> void:
		_pet.drive_velocity = Vector2(HURDLE_GAP / HURDLE_CYCLE, 0)
		_scroll = _t * HURDLE_GAP / HURDLE_CYCLE
		if _passed(before, TAKE_OFF * HURDLE_CYCLE):
			_pet.leap(LEAP, LEAP_TIME)
			_play("jump")
		if _passed(before, (0.5 + HURDLE_AHEAD / HURDLE_GAP) * HURDLE_CYCLE):
			_pop("Over!", _pet_at + Vector2(10, -124), GOOD_WORD)

	func _marathon(before: float, delta: float) -> void:
		_pet.drive_velocity = Vector2(110, 0)
		_scroll += 110.0 * delta
		# The ring swells to green on the BOOM, as in the race.
		var p := _in()
		_ring.value = 1.0 - minf(p, TrackGame.BEAT - p) / (TrackGame.BEAT * 0.5)
		# On the drum, every beat: the hand pokes, the drum booms, the pet keeps its energy up.
		_energy = maxf(0.3, _energy - delta * 0.15)
		if _passed(before, 0.0):
			_ring.beat = 1.0
			_ring.flash = 1.0
			_energy = minf(0.95, _energy + 0.09)
			_pop("BOOM!", Vector2(DRUM_AT.x + 170.0, 70.0), UI.ACCENT.darkened(0.2))
			_word_t = 0.35
			_play("drum_beat")

	## TAP! - the hand taps away and the pet heaves, leaning back - then STOP: the hand keeps still
	## and so does the pet.
	func _tug(before: float) -> void:
		_sign.t = _t
		var pulling := TugGame.is_pull(_t)
		_pet.effort = clampf(0.4 + 2.0 * _boost, 0.0, 1.0) if pulling else 0.0
		_pet_at.x = 150.0 - 22.0 * _pet.effort
		if _passed(before, 0.0):
			_play("drum_beat")
		if _passed(before, TugGame.TAP_TIME):
			_play("slide")


	func _tricks(before: float) -> void:
		_hand.visible = _in() > 2.9 and _in() < 5.4
		if _passed(before, 0.2):
			_pet.do_trick(_order[0])
			_play("card_flip")
		if _passed(before, 1.5):
			_pet.do_trick(_order[1])
			_play("card_flip")
		for i in 2:
			if _passed(before, float(TRICK_TAPS[i]) - 0.05):
				_pet.do_trick(_order[i])
				_play("ui_tap" if i == 0 else "correct")
		if _passed(before, 5.0):
			_pop("Yes!", Vector2(400, 56), GOOD_WORD)

	func _style(before: float, delta: float) -> void:
		var walking := _in() >= 2.4
		_pet.drive_velocity = Vector2(70, 0) if walking else Vector2.ZERO
		if walking:
			_scroll += 70.0 * delta
		if _passed(before, float(STYLE_TAPS[0]) - 0.05):
			_pet.perform("wiggle", 0.5)
			_play("dress")
		if _passed(before, float(STYLE_TAPS[1]) - 0.05):
			_flash = 1.0
			_pet.perform("celebrate", 0.6)
			_pop("Perfect pose!", _pet_at + Vector2(0, -150), GOOD_WORD)
			_play("camera")

	# --- The picture -------------------------------------------------------------------------

	func _draw() -> void:
		var all := Rect2(Vector2.ZERO, size)
		draw_style_box(_back, all)
		match kind:
			"dash":
				_draw_ground(Rect2(250, 208, 266, 58), 2)
				if _boost > 0.0:
					for i in 3:
						var y := _pet_at.y - 30.0 - i * 18.0
						var x := _pet_at.x - 70.0 - i * 10.0
						Crayon.line(self, Vector2(x - 60.0, y), Vector2(x, y), Color(UI.ACCENT, 0.7), 5.0, 60 + i)
			"hurdles":
				_draw_ground(Rect2(4, 118, 512, 72), 3)
				_draw_hurdles()
			"marathon":
				_draw_ground(Rect2(250, 208, 266, 58), 4)
				_draw_energy()
			"tug":
				var mouth := _pet.mouth_global() - _pet.global_position + _pet.position
				Crayon.line(self, mouth, Vector2(SIZE.x + 10.0, mouth.y - 4.0), Color("#c9a26b"), 7.0, 71, 1.5)
			"tricks":
				_draw_tricks()
			"style":
				_draw_style()
		# The edge goes on last, so nothing in the picture runs over it.
		draw_style_box(_edge, all)

	## A strip of track or runway with marks going by, so a pet running on the spot is running.
	func _draw_ground(r: Rect2, seed: int, color := SAND) -> void:
		Crayon.fill(self, PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end,
			Vector2(r.position.x, r.end.y)]), color, seed, 12.0, 0.0, 5.0)
		var y := r.position.y + r.size.y * 0.55
		var x := r.position.x - fposmod(_scroll, 60.0)
		while x < r.end.x:
			if x > r.position.x:
				Crayon.line(self, Vector2(x, y), Vector2(minf(x + 26.0, r.end.x), y), Color(1, 1, 1, 0.9), 4.0, seed)
			x += 60.0

	## Hurdles coming at the pet, each with a mark on the ground before it that lights up when
	## it is time to jump.
	func _draw_hurdles() -> void:
		var u := _in() / HURDLE_CYCLE
		var base := _pet_at.x + HURDLE_AHEAD + (0.5 - u) * HURDLE_GAP
		var hh := HURDLE_H
		var hw := hh * _tex.get_width() / maxf(_tex.get_height(), 1.0)
		for k: int in [-1, 0, 1]:
			var hx: float = base + k * HURDLE_GAP
			var spot := Vector2(hx - MARK_BEFORE, _pet_at.y + 8.0)
			var lit: bool = k == 0 and absf(u - 0.5) < 0.09
			if lit:
				Crayon.fill_blob(self, spot, Vector2(34, 15), Color(GREEN, 0.9), 91, 0.05)
				Crayon.marker_line(self, Crayon.ellipse(spot, Vector2(42, 20), 32), Color(1, 0.85, 0.3, 0.9), 6.0, 92)
			else:
				Crayon.marker_line(self, Crayon.ellipse(spot, Vector2(26, 11), 28), Color(1, 1, 1, 0.95), 5.0, 93)
			draw_texture_rect(_tex, Rect2(hx - hw / 2.0, _pet_at.y + 6.0 - hh, hw, hh), false)

	## The pet's energy over it, as the same battery the race shows over the kid's pet
	## (TrackGame's YOU tag): a beat on the drum tops it up.
	func _draw_energy() -> void:
		var body := Rect2(_pet_at.x - 40.0, 92.0, 74.0, 30.0)
		var nub := Rect2(body.end.x - 2.0, body.position.y + 8.0, 10.0, 14.0)
		Crayon.fill(self, Crayon.rounded_rect(nub, 3.0), UI.INK_SOFT, 104, 4.0, 0.0, 3.0)
		Crayon.fill(self, Crayon.rounded_rect(body, 8.0), UI.CARD, 101, 5.0, 0.0, 4.0)
		var inner := body.grow(-5.0)
		var full := Rect2(inner.position, Vector2(maxf(6.0, inner.size.x * _energy), inner.size.y))
		Crayon.fill(self, Crayon.rounded_rect(full, 4.0), RingMeter.GREEN, 102, 4.0, 0.0, 4.0)
		Crayon.marker_line(self, Crayon.rounded_rect(body, 8.0), UI.INK_SOFT, 4.0, 103)

	func _card_rect(i: int) -> Rect2:
		return Rect2(150.0 + i * 120.0, 130.0, 104.0, 92.0)

	## The trick show: the pet's cards come up one at a time over it, then the hand taps the same
	## ones in the row, in the same order - each gets its number and a tick.
	func _draw_tricks() -> void:
		var showing := ""
		if _in() >= 0.2 and _in() < 1.3:
			showing = _order[0]
		elif _in() >= 1.5 and _in() < 2.6:
			showing = _order[1]
		if showing != "":
			var r := Rect2(176, 12, 100, 100)
			Crayon.fill(self, Crayon.rounded_rect(r, 12.0), Color("#fff6d6"), 111, 9.0, 0.0, 4.0)
			Crayon.marker_line(self, Crayon.rounded_rect(r, 12.0), UI.ACCENT, 4.0, 112)
			draw_texture_rect(_card_tex[showing], r.grow(-12.0), false)
			_draw_number(r.position + Vector2(r.size.x + 20.0, 22.0), _order.find(showing) + 1)
		var font := get_theme_default_font()
		for i in _cards.size():
			var r := _card_rect(i)
			var t: String = _cards[i]
			var done := -1
			for n in 2:
				if _order[n] == t and _in() >= float(TRICK_TAPS[n]) - 0.05 and _in() < 5.6:
					done = n
			Crayon.fill(self, Crayon.rounded_rect(r, 12.0), Color("#fff6d6") if done >= 0 else UI.CARD, 113 + i, 9.0, 0.0, 4.0)
			Crayon.marker_line(self, Crayon.rounded_rect(r, 12.0), UI.INK, 3.0, 116 + i)
			draw_texture_rect(_card_tex[t], Rect2(r.position + Vector2(24, 6), Vector2(56, 56)), false)
			var name := Tricks.display_name(t)
			var w := font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
			draw_string(font, Vector2(r.get_center().x - w / 2.0, r.end.y - 10.0), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UI.INK)
			if done >= 0:
				_draw_number(r.position + Vector2(10, 10), done + 1)
				var tick := PackedVector2Array([r.end + Vector2(-30, -48), r.end + Vector2(-21, -38), r.end + Vector2(-6, -60)])
				Crayon.marker_line(self, tick, GREEN.darkened(0.2), 6.0, 119 + i, false)

	## 1, 2... in a little orange ring: the order the cards go in.
	func _draw_number(at: Vector2, n: int) -> void:
		Crayon.marker_line(self, Crayon.ellipse(at, Vector2(9, 9), 16), UI.ACCENT, 14.0, 121 + n)
		var font := get_theme_default_font()
		var s := str(n)
		var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		draw_string(font, at + Vector2(-w / 2.0, 8.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, UI.CARD)

	func _cloth_rect(i: int) -> Rect2:
		return Rect2(24.0 + i * 82.0, 108.0, 72.0, 72.0)

	## The style show: first the hand picks the clothes with the STAR and on they go; then the
	## spotlight comes along the runway and the hand taps as it lights up the pet - flash!
	func _draw_style() -> void:
		var walking := _in() >= 2.4
		_draw_ground(Rect2(4, 208, 512, 58), 5, Color("#f2a7c3"))
		var star: Dictionary = _clothes[1]
		if not walking:
			for i in _clothes.size():
				var item: Dictionary = _clothes[i]
				if item.is_empty():
					continue
				var r := _cloth_rect(i)
				var picked := i == 1 and _in() >= float(STYLE_TAPS[0]) - 0.05
				Crayon.fill(self, Crayon.rounded_rect(r, 10.0), Color("#fff6d6") if picked else UI.CARD, 131 + i, 9.0, 0.0, 4.0)
				Crayon.marker_line(self, Crayon.rounded_rect(r, 10.0), UI.INK, 3.0, 134 + i)
				if not (i == 1 and picked):
					draw_texture_rect(item["_tex"], r.grow(-8.0), false)
				if i == 1:
					var at := r.position + Vector2(r.size.x - 6.0, 8.0)
					Crayon.fill(self, Crayon.star(at, 15.0, 137), UI.HILITE, 138, 5.0, 0.0, 3.0)
					Crayon.marker_line(self, Crayon.star(at, 15.0, 137), Color("#d9a520"), 2.5, 139)
		else:
			# The spotlight waits on the runway ahead, as in the show, and the pet walks into it:
			# it goes by at the runway's own pace and is on the pet when the hand taps.
			var sx := _pet_at.x + (float(STYLE_TAPS[1]) - _in()) * 70.0
			var cone := PackedVector2Array([Vector2(sx - 20.0, -10.0), Vector2(sx + 20.0, -10.0),
				Vector2(sx + 78.0, 250.0), Vector2(sx - 78.0, 250.0)])
			Crayon.fill(self, cone, Color(1, 0.93, 0.55, 0.45), 141, 12.0, 0.0, 6.0)
			if _flash > 0.0:
				Crayon.fill_blob(self, _pet_at + Vector2(0, -50), Vector2(90, 80), Color(1, 1, 0.85, _flash * 0.8), 142, 0.15)
		# Once picked, the hat hops from its button onto the pet's head.
		if _in() >= float(STYLE_TAPS[0]) - 0.05 and not star.is_empty():
			var k := smoothstep(float(STYLE_TAPS[0]), float(STYLE_TAPS[0]) + 0.35, _in())
			var top := _pet.top_global() - _pet.global_position + _pet.position
			var at := _cloth_rect(1).get_center().lerp(top + Vector2(0, -10), k)
			var s := 52.0
			draw_texture_rect(star["_tex"], Rect2(at - Vector2(s, s) / 2.0, Vector2(s, s)), false)
