class_name DemoKid
extends Node
## Plays the kid, so the whole game can be checked without a finger on a screen. It goes
## through the real screens and draws through the real DrawCanvas - strokes, bucket fills and
## all - then plays: feeds, fetches, tugs, decorates, shops, dresses up, and enters every
## competition with its own taps. Screenshots of every step land in .shots/demo_*.png.
##
## Its drawings are wobbly on purpose: a demo that only ever draws perfect circles would never
## find the fill leaking through a gap.

var game: GameRoot
var _n := 0


func run() -> void:
	game.profile.add_stars(400)
	await _build_first_home()
	var creator := game.start_creator()
	await _wait(0.5)
	await _make_pet(creator)
	await _wait(2.0)
	await _play_at_home()
	await _adopt()
	await _shop()
	await _competitions()
	game.go_home()
	await _wait(1.0)
	await _shot("home")
	if game.dev.has("quit"):
		get_tree().quit()


func _shot(name: String) -> void:
	_n += 1
	await game.capture("demo_%02d_%s" % [_n, name])


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


## An empty plot: pick a ready-built home and name it.
func _build_first_home() -> void:
	game.go_home()
	await _wait(0.6)
	await _shot("home_empty")
	game.go_build_home()
	await _wait(0.8)
	var b := game.screen as BuildHomeScreen
	await _shot("build_list")
	b._name_it("meadow_cottage")
	await _wait(0.5)
	b.set_home_name("Zorp's Den")
	await _shot("build_name")
	b.press_build()
	await _wait(0.8)
	await _shot("home_built")


# --- Making a pet ----------------------------------------------------------------------------

## What the demo adds while drawing each host.
const ADDONS := {"body": ["wing", "tail"], "head": ["eye", "mouth", "ear"], "arm": ["hand"],
	"leg": ["foot"]}


func _make_pet(creator: Creator) -> void:
	var picker := creator.current as PartPickerScreen
	picker.change("arm", 2)
	await _shot("parts")
	picker.press_next()

	var food_drawn := false
	var shot_addon := false
	while is_instance_valid(creator) and creator.is_inside_tree():
		await _wait(0.4)
		if not is_instance_valid(creator):
			break
		var s := creator.current
		if s is DrawScreen:
			var d := s as DrawScreen
			var host := d.subject
			await _draw(host, d.canvas)
			for type in ADDONS.get(host, []):
				d.on_addon.call(type)
				await _wait(0.5)
				var a := creator.current as DrawScreen
				await _draw(type, a.canvas)
				if not shot_addon:
					shot_addon = true
					await _shot("draw_addon_" + type)
				await a.press_done()
				await _wait(0.5)
			await _wait(0.3)
			await _shot("draw_" + host)
			await d.press_done()
		elif s is AssembleScreen:
			var a := s as AssembleScreen
			a.select(PetBuilder.find(a.pet, "leg_0").get("id", ""))
			await _shot("assemble")
			a.press_done()
		elif s is DetailsScreen:
			var d := s as DetailsScreen
			d.set_pet_name("Zorp")
			d.pick_size("medium")
			d.set_place("meadow")
			await _wait(0.3)
			await _shot("details")
			d.press_next()
		elif s is WordPickerScreen:
			var w := s as WordPickerScreen
			w.toggle("playful")
			w.toggle("sporty")
			await _shot("personality")
			w.press_done()
		elif s is ItemPickerScreen:
			var ip := s as ItemPickerScreen
			if ip.category == "food" and not food_drawn:
				food_drawn = true
				await _shot("pick_food")
				ip._draw_new()
				await _wait(0.4)
				await _draw_item(ip)
			else:
				await _shot("pick_toy")
				ip.on_done.call("kit_rope")
		elif s is HomePickerScreen:
			await _shot("home_picker")
			var hp := s as HomePickerScreen
			hp.on_done.call(game.profile.homes()[0])
		await _wait(0.2)


## The shop's Adopt tab: meet Pip and take it home.
func _adopt() -> void:
	game.go_shop(func(): game.go_home())
	await _wait(1.2)
	var shop := game.screen as ShopScreen
	await _shot("shop_adopt")
	shop._pick_group("adopt_d")
	await _wait(0.8)
	await _shot("shop_adopt_dinos")
	shop._pick_group("adopt_a")
	await _wait(0.6)
	shop.meet("pip")
	await _wait(1.0)
	await _shot("meet")
	game.adopt("pip")
	await _wait(0.8)
	var hp := game.screen as HomePickerScreen
	await _shot("adopt_home")
	hp.on_done.call(game.profile.homes()[0])
	await _wait(2.0)
	await _shot("adopted_at_home")


## Inside the item picker: draw a snack and give it words.
func _draw_item(ip: ItemPickerScreen) -> void:
	var maker := ip._content as ItemMaker
	await _wait(0.3)
	var d := maker._current as DrawScreen
	await _draw("food", d.canvas)
	await _shot("draw_food")
	await d.press_done()
	await _wait(0.3)
	var w := maker._current as WordPickerScreen
	w.toggle("juicy")
	w.toggle("sweet")
	await _shot("food_words")
	w.press_done()


# --- Playing at home -------------------------------------------------------------------------

func _place() -> PlaceScreen:
	return game.screen as PlaceScreen


func _play_at_home() -> void:
	var place := _place()
	await _shot("place")
	var zorp: Creature = place.creatures[0]
	place.open_tab("food")
	place.drop_food("kit_cake", zorp.position + Vector2(240, -40))
	await _wait(1.6)
	await _shot("food_walk")
	await _wait(1.8)
	await _shot("eating")
	await _wait(2.5)
	place.open_tab("toy")
	place.fling_toy("kit_ball", Vector2(640, 620), Vector2(-900, -700))
	await _wait(0.6)
	await _shot("toy_flying")
	await _wait(4.0)
	await _shot("fetched")
	# Tug of war: hold the rope by its mouth, then pull away.
	await _wait(2.5)
	zorp.interrupt()
	place._grab("kit_rope")
	var mouth := zorp.mouth_global()
	place._move_held(mouth)
	for i in 12:
		place._move_held(mouth + Vector2(-20.0 * i, 6.0 * i))
		await _wait(0.08)
	await _shot("tug")
	place._drop_held(mouth + Vector2(-240, 60), Vector2(640, 300))
	await _wait(1.5)
	for i in 6:
		place.stroke_pet(zorp, 60.0)
		await _wait(0.15)
	await _shot("petting")
	# Decorate.
	place.open_tab("furniture")
	place.place_furniture("kit_trampoline", Vector2(330, 600))
	place.place_furniture("kit_bed", Vector2(960, 640))
	place.place_furniture("kit_tree", Vector2(1120, 520))
	place.place_furniture("kit_drum", Vector2(520, 520))
	await _wait(0.5)
	await _shot("decorate")
	place.open_tab("")
	zorp.pet["needs"]["energy"] = 0.3
	place._play_with_furniture(zorp)
	await _wait(5.0)
	await _shot("furniture_play")


func _shop() -> void:
	game.go_shop(func(): game.go_home())
	await _wait(0.8)
	var shop := game.screen as ShopScreen
	await _shot("shop_toys")
	shop._buy_item("shiny_ball", 30)
	shop.show_tab("clothing")
	await _wait(0.4)
	await _shot("shop_clothes")
	shop._buy_item("hat_party", 10)
	shop._buy_item("glasses_sun", 12)
	shop._buy_item("marker_gold", 20)
	shop.show_tab("room")
	await _wait(0.4)
	await _shot("shop_room")
	shop.show_tab("places")
	await _wait(0.4)
	await _shot("shop_places")
	game.go_place(game.profile.homes()[0]["id"])
	await _wait(1.5)
	var place := _place()
	var zorp: Creature = place.creatures[0]
	place.open_tab("clothing")
	place.dress(zorp, Items.get_item("hat_party"))
	place.dress(zorp, Items.get_item("glasses_sun"))
	await _wait(1.5)
	await _shot("dressed")
	place.open_tab("toy")
	place.fling_toy("shiny_ball", Vector2(640, 620), Vector2(700, -900))
	await _wait(0.5)
	await _shot("shiny_toy")
	await _wait(4.0)


# --- Competitions ----------------------------------------------------------------------------

func _competitions() -> void:
	game.go_calendar()
	await _wait(0.8)
	await _shot("calendar")
	var pet_id: String = game.profile.homes()[0]["pets"][0]
	var today := Events.today()
	for kind in ["dash", "hurdles", "marathon", "tug", "tricks", "style"]:
		var ev := today.duplicate()
		ev["kind"] = kind
		ev["practice"] = false
		if kind == "dash":
			game.go_event(ev)
			await _wait(0.6)
			await _shot("event")
		game.go_competition(ev, 0, pet_id)
		await _wait(0.8)
		var comp := game.screen as CompetitionScreen
		if kind == "dash":
			await _shot("intro")
		comp._start()
		await _wait(0.2)
		await _play(kind, comp)
		await _wait(0.8)
		await _shot("podium_" + kind)


func _play(kind: String, comp: CompetitionScreen) -> void:
	var mini = comp._mini
	var t := 0.0
	var shot_taken := false
	while t < 70.0:
		await get_tree().process_frame
		if not is_instance_valid(mini) or comp._mini != mini:
			break
		var dt := get_process_delta_time()
		t += dt
		match kind:
			"dash":
				var v: float = fmod(mini._time, 1.1) / 1.1
				if mini._time > 0.0 and v > 0.78 and v < 0.84:
					mini.tap()
			"hurdles":
				if mini._time > 0.0 and int(mini.racers[0]["next_hurdle"]) < mini.hurdles.size():
					var gap: float = mini.hurdle_x(mini.racers[0], int(mini.racers[0]["next_hurdle"])) - float(mini.racers[0]["x"])
					if gap < 70.0 and gap > 0.0:
						mini.tap()
			"marathon":
				if mini._time > 0.0 and fmod(mini._time, TrackGame.BEAT) < dt:
					mini.tap()
			"tug":
				if mini._ring.value > 0.9:
					mini.tap()
			"tricks":
				if mini._state == "answer" and mini._answer < mini._sequence.size():
					await _wait(0.3)
					if not is_instance_valid(mini) or mini._state != "answer":
						continue
					if mini._round < 4:
						mini.press(mini._sequence[mini._answer])
					else:
						mini.press("sit" if mini._sequence[mini._answer] != "sit" else "jump")
			"style":
				if mini._state == "dress":
					mini.wear(Items.get_item("hat_party"))
					await _wait(0.6)
					await _shot("style_dress")
					mini.start_walk()
				elif mini._state == "walk" and absf(mini._pet.position.x - mini._spot_x) < 40.0:
					mini.tap()
		if not shot_taken and t > 6.0:
			shot_taken = true
			await _shot("play_" + kind)


# --- The drawings ----------------------------------------------------------------------------

func _draw(subject: String, c: DrawCanvas) -> void:
	match subject:
		"body":
			_line(c, _ellipse(Vector2(256, 280), Vector2(200, 120)), UI.PALETTE[0], 12.0, 1)
			await _fill(c, Vector2(256, 280), UI.PALETTE[3])
			for spot in [Vector2(180, 250), Vector2(300, 320), Vector2(330, 230)]:
				_line(c, PackedVector2Array([spot, spot + Vector2(6, 3)]), UI.PALETTE[11], 30.0, 2)
		"head":
			_line(c, _ellipse(Vector2(250, 318), Vector2(105, 100)), UI.PALETTE[0], 12.0, 3)
			await _fill(c, Vector2(250, 318), UI.PALETTE[4])
		"eye":
			_line(c, _ellipse(Vector2(256, 256), Vector2(70, 72)), UI.PALETTE[0], 10.0, 5)
			await _fill(c, Vector2(220, 256), UI.PALETTE[1])
			_line(c, PackedVector2Array([Vector2(282, 256), Vector2(286, 258)]), UI.PALETTE[0], 54.0, 6)
		"mouth":
			# Wide open - the game closes it.
			_line(c, _ellipse(Vector2(256, 256), Vector2(110, 80)), UI.PALETTE[0], 12.0, 16)
			await _fill(c, Vector2(256, 230), UI.PALETTE[2])
			_line(c, PackedVector2Array([Vector2(200, 300), Vector2(256, 285), Vector2(312, 300)]), UI.PALETTE[10], 30.0, 17)
		"ear":
			_line(c, PackedVector2Array([Vector2(196, 444), Vector2(250, 190), Vector2(316, 444),
				Vector2(196, 444)]), UI.PALETTE[0], 11.0, 7)
			await _fill(c, Vector2(256, 380), UI.PALETTE[10])
		"leg":
			_line(c, PackedVector2Array([Vector2(224, 50), Vector2(222, 300), Vector2(290, 300),
				Vector2(288, 50)]), UI.PALETTE[0], 11.0, 8)
			await _fill(c, Vector2(256, 200), UI.PALETTE[3])
		"foot":
			_line(c, PackedVector2Array([Vector2(160, 120), Vector2(160, 250), Vector2(380, 256),
				Vector2(392, 214), Vector2(238, 196), Vector2(226, 120), Vector2(160, 120)]), UI.PALETTE[0], 14.0, 18)
			await _fill(c, Vector2(220, 210), UI.PALETTE[11])
		"arm":
			_line(c, PackedVector2Array([Vector2(238, 50), Vector2(236, 250), Vector2(280, 250),
				Vector2(276, 50)]), UI.PALETTE[0], 10.0, 19)
			await _fill(c, Vector2(256, 150), UI.PALETTE[3])
		"hand":
			_line(c, _ellipse(Vector2(256, 190), Vector2(80, 90)), UI.PALETTE[0], 14.0, 20)
			await _fill(c, Vector2(256, 190), UI.PALETTE[13])
		"tail":
			var wave := PackedVector2Array()
			for i in 18:
				var t := i / 17.0
				wave.append(Vector2(450 - t * 330, 256 - t * 90 - sin(t * TAU) * 40))
			_line(c, wave, UI.PALETTE[0], 36.0, 9)
			_line(c, wave, UI.PALETTE[3], 18.0, 9)
		"wing":
			_line(c, PackedVector2Array([Vector2(300, 452), Vector2(170, 330), Vector2(140, 170),
				Vector2(230, 222), Vector2(270, 120), Vector2(340, 232), Vector2(392, 170),
				Vector2(366, 452), Vector2(300, 452)]), UI.PALETTE[0], 10.0, 10)
			await _fill(c, Vector2(280, 320), UI.PALETTE[7])
		"food":
			_line(c, _ellipse(Vector2(256, 296), Vector2(130, 125)), UI.PALETTE[0], 12.0, 11)
			await _fill(c, Vector2(256, 296), UI.PALETTE[2])
			_line(c, PackedVector2Array([Vector2(256, 172), Vector2(272, 104)]), UI.PALETTE[11], 16.0, 12)
			_line(c, PackedVector2Array([Vector2(272, 130), Vector2(330, 112), Vector2(300, 150),
				Vector2(272, 130)]), UI.PALETTE[6], 10.0, 13)


func _line(c: DrawCanvas, points: PackedVector2Array, color: Color, width: float, seed: int) -> void:
	c.tool = DrawCanvas.Tool.PEN
	c.color = color
	c.shine = ""
	c.brush = width
	# Fill in points every few pixels, then shake them a little: a hand, not a ruler.
	var dense := PackedVector2Array()
	for i in points.size() - 1:
		var a := points[i]
		var b := points[i + 1]
		var steps := maxi(1, int(a.distance_to(b) / 6.0))
		for k in steps:
			dense.append(a.lerp(b, k / float(steps)))
	dense.append(points[points.size() - 1])
	for i in dense.size():
		dense[i] += Vector2(Crayon.noise(seed, i), Crayon.noise(seed + 50, i)) * 1.6
	c.add_stroke(dense)


func _fill(c: DrawCanvas, at: Vector2, color: Color) -> void:
	c.tool = DrawCanvas.Tool.FILL
	c.color = color
	await c.fill_at(at)


func _ellipse(center: Vector2, radius: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 41:
		var a := TAU * i / 40.0 - PI / 2.0
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	return points
