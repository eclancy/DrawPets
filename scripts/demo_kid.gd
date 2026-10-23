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
	game.profile.set_mode("advanced")  # everything, first; the Beginner game has its own turn
	if not game.dev.has("hour"):
		Clock.forced_hour = 12.0  # midday, whatever the real clock says - the night has its own turn
	await _build_first_home()
	var creator := await _draft_round_trip()
	await _make_pet(creator)
	await _wait(2.0)
	await _play_at_home()
	await _adopt()
	await _friends()
	await _swap()
	await _let_go_pip()
	await _settings()
	await _shop()
	await _competitions()
	await _beginner()
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

## The parts the demo draws on its creature, in the order it taps them (after the body).
const PARTS := ["head", "eye", "mouth", "ear", "leg", "foot", "tail", "wing", "arm", "hand"]


## Starts a pet, draws its body, stops with "Save it for later" - then starts a new pet from
## home and picks the saved one up again, body and all. Returns the creator carrying on.
func _draft_round_trip() -> Creator:
	var creator := game.start_creator()
	await _wait(0.6)
	await _shot("sheet_start")
	await _draw_part("body", creator.sheet.canvas)
	await _wait(0.3)
	creator.on_quit_for_demo()
	await _wait(0.4)
	await _shot("stop_drawing")
	await creator._quit_save()
	await _wait(1.0)
	creator = game.start_creator()
	await _wait(0.6)
	await _shot("draft_offer")
	creator.resume_draft()
	await _wait(0.6)
	return creator


## The whole creature on its one sheet: Done with the body (it bounces), then each part picked,
## drawn where it goes and shown off - zoomed in for the eyes. Legs are one leg, two copies slid
## along the belly and one more drawn by hand; the ear and the wing are copied too, the wing's copy
## put behind the body. Done on a part with nothing drawn moves on. Then back to the head to add
## to it, "It's finished!", back to the drawing from its name, and finished again.
func _draw_creature(sheet: CreatureSheet) -> void:
	await _shot("draft_resumed")
	await sheet.press_done()
	await _through_preview(sheet, "preview_body")
	await _wait(0.3)
	await _shot("sheet_next_head")
	for type in PARTS:
		if sheet.active != type:
			await sheet.pick(type)
		await _wait(0.2)
		if type == "eye":
			# Closer, for something small.
			var c := sheet.canvas
			c.zoom_at(2.6, c._sheet.position + Vector2(745, 290) * c._sheet.scale.x)
			await _wait(0.2)
		match type:
			"leg":
				await _draw_legs(sheet)
			"ear":
				await _draw_part("ear", sheet.canvas)
				await _copy_to(sheet, Vector2(130, -24))
			"wing":
				await _draw_part("wing", sheet.canvas)
				await _copy_to(sheet, Vector2(-70, -16))
				await sheet.press_stack()
				await _wait(0.3)
			_:
				await _draw_part(type, sheet.canvas)
		await _wait(0.2)
		if type in ["head", "eye", "wing"]:
			await _shot("sheet_" + type)
		if type == "eye":
			sheet.canvas.reset_view()
		await sheet.press_done()
		await _through_preview(sheet, "preview_" + type if type in ["eye", "leg", "wing", "tail"] else "")
		await _wait(0.3)
	# Done on a part with nothing drawn: no horns, thanks - it moves on.
	await sheet.pick("horn")
	await sheet.press_done()
	await _wait(0.3)
	print("[demo] Done on an empty part moves on: %s" % (sheet.active != "horn"))
	# Back to the head, to give it a spot - its lines come back to draw on.
	await sheet.pick("head")
	await _wait(0.3)
	_line(sheet.canvas, PackedVector2Array([Vector2(660, 230), Vector2(664, 232)]), UI.PALETTE[11], 30.0, 40)
	await _shot("back_to_head")
	await sheet.press_done()
	await _through_preview(sheet)
	await _wait(0.4)
	await _shot("sheet_done")
	var creator := sheet.get_parent() as Creator
	await sheet.press_finished()
	await _wait(0.6)
	# From its name, back to the drawing (it is all still there), and finished again.
	var details := creator.current as DetailsScreen
	if details != null:
		await _shot("details_first")
		details._back()
		await _wait(0.8)
		await _shot("back_to_drawing")
		var again := creator.current as CreatureSheet
		print("[demo] back to drawing from its name: %s" % (again != null and again.layers.has("leg")))
		if again != null:
			await again.press_finished()
	var counts := {}
	for part in creator.pet["parts"]:
		counts[part["type"]] = int(counts.get(part["type"], 0)) + 1
	print("[demo] parts: legs %d ears %d wings %d feet %d arms %d" % [counts.get("leg", 0),
		counts.get("ear", 0), counts.get("wing", 0), counts.get("foot", 0), counts.get("arm", 0)])


## Legs, one at a time: one drawn and coloured, copied and slid along twice, a fourth drawn as an
## outline by hand - and coloured from a fresh page, which makes that leg the bold one again.
func _draw_legs(sheet: CreatureSheet) -> void:
	var c := sheet.canvas
	_line(c, _leg_outline(320.0), UI.PALETTE[0], 11.0, 8)
	await _fill(c, Vector2(342, 690), UI.PALETTE[3])
	await _wait(0.2)
	await _shot("sheet_leg_one")
	for x in [420.0, 520.0]:
		await sheet.press_copy()
		await _wait(0.3)
		if x == 420.0:
			await _shot("sheet_leg_copy")
		var r := c.loaded_rect()
		c.drag_copy(r.get_center(), r.get_center() + Vector2(x - 2.0 - r.position.x, 570.0 - r.position.y))
		await _wait(0.2)
	await sheet.press_another()
	await _wait(0.2)
	_line(c, _leg_outline(620.0), UI.PALETTE[0], 11.0, 11)
	await _wait(0.2)
	await _shot("sheet_leg")
	# Another, then thought better of it: undo takes the empty one back.
	await sheet.press_another()
	sheet._undo()
	await _wait(0.2)
	print("[demo] undo took back the empty leg: %s" % (sheet.layers.get("leg", []).size() == 4))
	# A fresh page, and the bucket inside the fourth leg: it becomes the bold one, coloured.
	await sheet.press_another()
	c.tool = DrawCanvas.Tool.FILL
	c.color = UI.PALETTE[3]
	await c.fill_at(Vector2(642, 690))
	await _wait(0.6)
	var last: Dictionary = sheet.layers["leg"].back()
	print("[demo] bucket switched to the fourth leg: %s" % (last["at"].x > 600.0))
	await _shot("sheet_leg_switched")


func _leg_outline(x: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x, 570), Vector2(x - 2, 720), Vector2(x + 46, 720), Vector2(x + 44, 570)])


## Copy this part, and slide the copy `by` from where the one copied is.
func _copy_to(sheet: CreatureSheet, by: Vector2) -> void:
	var src: Dictionary = sheet._bold
	await sheet._fold()
	src = sheet._bold
	await sheet.press_copy()
	await _wait(0.3)
	var r := sheet.canvas.loaded_rect()
	var goal: Vector2 = src["at"] + by
	sheet.canvas.drag_copy(r.get_center(), r.get_center() + goal - r.position)
	await _wait(0.2)


func _make_pet(creator: Creator) -> void:
	var food_drawn := false
	var drawn := false
	while is_instance_valid(creator) and creator.is_inside_tree():
		await _wait(0.4)
		if not is_instance_valid(creator):
			break
		var s := creator.current
		if s is CreatureSheet and not drawn:
			drawn = true
			await _draw_creature(s as CreatureSheet)
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
		elif s is ChoiceScreen:
			await _shot("coat")
			(s as ChoiceScreen).choose("fur")
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
		elif s is VoiceMakerScreen:
			await _make_voice(s as VoiceMakerScreen)
		await _wait(0.2)


## After Done on a part, the creature shows it off (PartPreview). Shoot it if asked, then tap
## through it the way a kid would.
func _through_preview(node: Node, shot_name := "") -> void:
	await _wait(0.3)
	for p in node.get_children():
		if p is PartPreview and not p.is_queued_for_deletion():
			if shot_name != "":
				await _wait(1.2)
				await _shot(shot_name)
			(p as PartPreview).skip()
	await _wait(0.3)


## Making its voice: pick a base, slide it higher and wobblier, then "record" (a made-up
## recording - there is no microphone here) and use that instead.
func _make_voice(v: VoiceMakerScreen) -> void:
	v.pick_base("meow")
	await _wait(0.4)
	v._sliders["pitch"].value = 5.0
	v._sliders["wobble"].value = 0.4
	await _wait(0.6)
	await _shot("voice_maker")
	var fake := PackedFloat32Array()
	fake.resize(int(Voice.RATE * 0.5))
	for i in fake.size():
		var t := i / float(Voice.RATE)
		fake[i] = sin(TAU * (500.0 + 900.0 * t) * t) * sin(PI * t / 0.5) * 0.6
	v.use_recording(fake)
	await _wait(0.6)
	await _shot("voice_recorded")
	v.pick_base("meow")
	await _wait(0.3)
	v.press_done()


## Letting Pip go to live in the wild (it was adopted, so it goes back to the shop).
func _let_go_pip() -> void:
	var h: Dictionary = game.profile.homes()[0]
	var pip_id: String = h["pets"][h["pets"].size() - 1]
	game.go_let_go(pip_id, h["id"])
	await _wait(1.0)
	await _shot("let_go")
	(game.screen as LetGoScreen).goodbye()
	await _wait(2.5)
	await _shot("let_go_goodbye")
	await _wait(3.5)
	await _shot("after_let_go")


func _settings() -> void:
	game.go_settings()
	await _wait(0.6)
	await _shot("settings")


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


## Friends: Pip (shy, cuddly) has moved in with Zorp (playful, sporty) - a shy pet takes its time.
## Then, some days later as it were, they are friends: a nuzzle, a chase, and it's on their cards.
func _friends() -> void:
	var place := _place()
	if place == null or place.creatures.size() < 2:
		return
	var zorp: Creature = place.creatures[0]
	var pip: Creature = place.creatures[1]
	for c in [zorp, pip]:
		c.interrupt()
	zorp.position = Vector2(420, 560)
	pip.position = Vector2(760, 580)
	place.meet(zorp, pip)
	await _wait(2.2)
	await _shot("friends_meet")
	zorp.pet["friends"][pip.pet["id"]]["f"] = 44.0
	pip.pet["friends"][zorp.pet["id"]]["f"] = 44.0
	for p in [zorp.pet, pip.pet]:
		for id in p["friends"]:
			p["friends"][id]["today"] = 0.0
	zorp.go_to(place._beside(pip, zorp), place._nuzzle.bind(zorp, pip))
	await _until(func(): return zorp.action() == "nuzzle", 6.0)
	await _wait(0.6)
	await _shot("friends_made")
	await _wait(1.5)
	place.chase(zorp, pip)
	await _wait(0.9)
	await _shot("friends_chase")
	await _wait(1.6)
	place._show_panel(zorp)
	await _wait(0.3)
	await _shot("friends_card")
	place._panel.visible = false


## Friends from a swap: the demo cannot meet another phone, so it pretends a family swapped -
## its own pets, unpacked as the Mango family - then shows the Friends page and a visitor.
func _swap() -> void:
	var pack := PetPack.unpack(PetPack.pack(game.profile))
	pack["family"] = {"id": "0123456789abcdef", "name": "Mango"}
	Visitors.save_family(game.profile, pack)
	game.go_swap()
	await _wait(1.0)
	await _shot("friends_page")
	# The swap code page - listening on this PC only, so no firewall prompt.
	var was := LanLink.bind_host
	LanLink.bind_host = "127.0.0.1"
	(game.screen as SwapScreen)._use_way("code")
	await _wait(0.8)
	await _shot("swap_code")
	(game.screen as SwapScreen)._main()
	LanLink.bind_host = was
	var home_id: String = game.profile.homes()[0]["id"]
	game.profile.today().erase("visitor_" + home_id)
	game.go_place(home_id)
	await _wait(3.0)
	await _shot("visitor")


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
	await _toys(place, zorp)
	await _petting(place, zorp)
	# Decorate.
	place.open_tab("furniture")
	place.place_furniture("kit_trampoline", Vector2(330, 600))
	place.place_furniture("kit_bed", Vector2(960, 640))
	place.place_furniture("kit_tree", Vector2(1120, 520))
	place.place_furniture("kit_drum", Vector2(520, 520))
	place.place_furniture("kit_lamp", Vector2(760, 540))
	await _wait(0.5)
	await _shot("decorate")
	place.open_tab("")
	zorp.pet["needs"]["energy"] = 0.3
	place._play_with_furniture(zorp)
	await _wait(5.0)
	await _shot("furniture_play")
	await _night()
	await _bath()
	await _bath_day()
	await _walk()
	await _tricks()
	await _photo()
	await _listening()


## Calling by voice: the Listen button (the mic is said yes to), then a call - here faked, since
## the demo has no room to clap in - and everyone comes running.
func _listening() -> void:
	var place := _place()
	place.toggle_listening()
	await _wait(0.4)
	await _shot("listen_ask")
	place._mic_yes()
	await _wait(0.4)
	place.creatures[0].go_to(Vector2(300, 480))
	await _wait(1.0)
	place.heard_call()
	await _wait(0.8)
	await _shot("listen_called")
	await _wait(1.6)
	await _shot("listen_came")
	place.toggle_listening()
	game.profile.settings()["mic"] = false


## A photo: everyone jumps, snap, a frame and two stickers, into the album and the journal.
func _photo() -> void:
	var place := _place()
	place.open_tab("camera")
	await _wait(0.4)
	place.pose("happy")
	await _wait(0.5)
	await _shot("camera")
	place.snap()
	await _wait(0.6)
	var ed := place._editor
	ed.set_frame("hearts")
	ed.add_sticker("star")
	ed.add_sticker("hello", Vector2(650, 110))
	await _wait(0.4)
	await _shot("photo_editor")
	await ed.keep_it()
	await _wait(0.6)
	place.open_tab("")
	var zorp: Creature = place.creatures[0]
	place._show_panel(zorp)
	await _wait(0.3)
	await _shot("pet_card_journal")
	place._panel.on_journal.call(zorp.pet)
	await _wait(1.0)
	await _shot("journal")
	game.go_album()
	await _wait(1.0)
	await _shot("album")
	var album := game.screen as AlbumScreen
	album.show_photo(Album.photos(game.profile)[0])
	await _wait(0.4)
	await _shot("album_photo")
	game.go_place(game.profile.homes()[0]["id"])
	await _wait(1.0)


## Tricks: draw a card for SPIN, then teach it with circles - four lessons at most.
func _tricks() -> void:
	_place().go_tricks()
	await _wait(1.0)
	var ts := game.screen as TrickScreen
	await _shot("tricks")
	ts.pick("spin")
	await _wait(0.5)
	var d := ts._drawing as DrawScreen
	await _draw("card", d.canvas)
	await _shot("trick_card")
	await d.press_done()
	await _wait(0.6)
	await _shot("trick_show_card")
	var circle := Tricks.swipe_path("circle", Vector2(300, 300), 240.0)
	ts.swipe(Tricks.swipe_path("up", Vector2(300, 300), 240.0))  # the wrong swipe first
	await _wait(1.0)
	await _shot("trick_wrong")
	for i in 6:
		ts.swipe(circle)
		await _wait(1.3)
		if Tricks.knows(ts.pet, "spin"):
			break
	await _shot("trick_learned")
	ts.go_home()
	await _wait(1.0)


## Bath day: off to the bathroom, then nails, a wash, teeth and a brush - the tools work by
## themselves, and the demo kid rubs along to hurry them. Then a snack in the bowl back home.
func _bath_day() -> void:
	var place := _place()
	place.open_tab("bath")
	await _wait(0.3)
	place.go_bath()
	await _until(func(): return game.screen is BathScreen, 10.0)
	var bath := game.screen as BathScreen
	await _wait(1.6)
	var shot_steps := {}
	var t := 0.0
	while not bath._finished and t < 60.0:
		var i := bath._done_pts.find(false)
		if bath._wait <= 0.0 and i >= 0 and bath._step >= 0:
			bath.rub_at(bath._points[i])
			if not shot_steps.has(bath._step) and bath._done_pts.count(true) >= 2:
				shot_steps[bath._step] = true
				await _shot("bath_day_" + str(bath._steps[bath._step][0]))
		else:
			bath.rub_at(Vector2.ZERO, false)
		await _wait(0.06)
		t += 0.06
	bath.rub_at(Vector2.ZERO, false)
	await _wait(1.2)
	await _shot("bath_day_done")
	bath.go_home()
	await _wait(1.2)
	place = _place()
	var zorp: Creature = place.creatures[0]
	zorp.pet["needs"]["food"] = 0.4
	place.open_tab("food")
	place.drop_food("kit_apple", place._bowl.position)
	await _until(func(): return zorp.action() == "eat_bowl", 8.0)
	await _wait(0.6)
	await _shot("bowl_eat")
	await _wait(2.6)
	place.open_tab("")


## A walk: off along the place, a glint in the grass, a dig, a present - and drawing what's in it.
func _walk() -> void:
	_place().go_walk()
	await _wait(1.5)
	var walk := game.screen as WalkScreen
	await _shot("walk")
	walk.creature.position.x = walk._glints[0].position.x - 420.0  # skip ahead to the first glint
	walk.creature.interrupt()
	await _until(func(): return walk._present != null, 12.0)
	if walk._present == null:
		# It should have found one by now: say why not, then send it straight to the glint.
		push_warning("demo walk: no present - pet %s action '%s' busy %s ending %s glints %s" % [walk.creature.position,
			walk.creature.action(), walk.creature.is_busy(), walk._ending, walk._glints.map(func(g): return g.position)])
		if not walk._glints.is_empty():
			walk._find(walk._glints[0])
		await _until(func(): return walk._present != null, 8.0)
	await _wait(0.4)
	await _shot("present")
	walk.open_present("food", "crunchy")
	await _wait(0.8)
	var maker := game.screen as ItemMaker
	var d := maker._current as DrawScreen
	await _shot("present_draw")
	await _draw("food", d.canvas)
	await d.press_done()
	await _wait(0.4)
	var w := maker._current as WordPickerScreen
	w.toggle("sweet")
	await _shot("present_words")
	w.press_done()
	await _wait(1.2)
	await _shot("present_home")


## Mud and a bath: a shower of rain, a dig, muddy paws - then the sponge, a shake, squeaky clean.
func _bath() -> void:
	var place := _place()
	var zorp: Creature = place.creatures[0]
	place.start_rain(5.0)
	zorp.go_to(Vector2(400, 560))
	await _wait(1.2)
	await _shot("rain")
	place._dig(zorp)
	await _wait(1.0)
	await _shot("dig")
	await _wait(1.8)
	place.get_muddy(zorp, 5, "all")
	place.open_tab("bath")
	await _wait(0.5)
	await _shot("muddy")
	place._grab("kit_sponge")
	for k in 40:
		var spots: Array = zorp.pet.get("mud", [])
		if spots.is_empty():
			break
		var at := Mud.where_is(zorp, spots[0])
		if at.x == INF:
			break
		for w in 3:
			place._move_held(at + Vector2(18.0 * (w % 2) - 9.0, 6.0 * w))
			await _wait(0.05)
		if k == 2:
			await _shot("scrubbing")
	for w in 12:  # a good long wash all over
		place._move_held(zorp.global_position + Vector2(28.0 * (w % 2) - 14.0, -zorp.height_px * 0.5))
		await _wait(0.04)
	await _wait(0.4)
	await _shot("shake")
	place._drop_held(zorp.global_position, Vector2(640, 300))
	await _wait(1.2)
	await _shot("clean")
	place.open_tab("")


## Half past nine: the place goes lavender, lamps glow, everyone is curled up asleep - and a tap
## wakes one gently. Then dusk, then morning, when they stretch and say good morning.
func _night() -> void:
	var home_id: String = _place().home["id"]
	Clock.forced_hour = 21.5
	game.go_place(home_id)
	await _wait(2.0)
	await _shot("night")
	var place := _place()
	place.boop(place.creatures[0])
	await _wait(0.8)
	await _shot("night_wake")
	place._panel.visible = false
	await _wait(1.5)
	Clock.forced_hour = 19.7
	game.go_place(home_id)
	await _wait(1.0)
	await _shot("dusk")
	Clock.forced_hour = 8.0
	game.go_place(home_id)
	await _wait(1.4)
	await _shot("morning")
	Clock.forced_hour = 12.0
	game.go_place(home_id)
	await _wait(0.6)


## Every toy the way its words say: fetch and throw again, a rope held out, a teddy, a chew bone,
## a squeaky duck, a treat ball and a big log.
func _toys(place: PlaceScreen, zorp: Creature) -> void:
	place.open_tab("toy")
	place.fling_toy("kit_ball", Vector2(640, 620), Vector2(-900, -700))
	await _wait(0.6)
	await _shot("toy_flying")
	await _until(func(): return place.toy_state == "offer", 8.0)
	await _wait(0.4)
	await _shot("fetch_offer")
	# Take it out of its mouth and throw it again.
	place.take_toy(place.toy.sprite.global_position)
	place._held = null
	place._held_kind = ""
	place.toy.held = false
	place._finger = Vector2(900, 640)
	place.throw_toy(Vector2(700, -650))
	await _until(func(): return place.toy_state == "offer", 8.0)
	await _shot("fetched_again")
	await _wait(5.5)  # nobody takes it: it drops it

	# Hold the rope out, away from it: it comes for the other end. Then pull.
	place._grab("kit_rope")
	var hold := Vector2(clampf(zorp.position.x - 260.0, 200.0, 1080.0), 520.0)
	for i in 50:
		place._move_held(hold)
		if place._tug != null:
			break
		await _wait(0.1)
	await _shot("tug_grab")
	for i in 12:
		place._move_held(hold + Vector2(-16.0 * i, 6.0 * i))
		await _wait(0.08)
	await _shot("tug")
	place._drop_held(hold + Vector2(-190, 70), Vector2(640, 300))
	await _wait(2.0)

	place.put_toy("kit_teddy", zorp.position + Vector2(160, 10))
	await _wait(3.0)
	await _shot("cuddle")
	await _wait(2.5)
	place.put_toy("kit_chew_bone", zorp.position + Vector2(-150, 0))
	await _wait(3.0)
	await _shot("chew")
	await _wait(3.5)
	place.put_toy("kit_duck", Vector2(clampf(zorp.position.x + 220.0, 200.0, 1080.0), 560))
	await _wait(1.0)
	place.tap_toy()
	await _until(func(): return zorp.is_leaping(), 6.0)
	await _wait(0.25)
	await _shot("pounce")
	await _wait(1.5)
	place.put_toy("kit_puzzle_ball", Vector2(clampf(zorp.position.x - 200.0, 200.0, 1080.0), 570))
	await _wait(3.0)
	await _shot("puzzle_nudge")
	await _until(func(): return place.toy_state == "", 12.0)
	await _wait(0.3)
	await _shot("puzzle_treat")
	await _wait(1.5)
	place.put_toy("kit_log", Vector2(300, 580))
	await _until(func(): return place._pushing, 8.0)
	await _wait(1.2)
	await _shot("push")
	await _until(func(): return place.toy_state == "", 8.0)
	await _wait(1.0)


## Rub its head, then its body until it rolls over; then a tap says hello and opens its card.
func _petting(place: PlaceScreen, zorp: Creature) -> void:
	zorp.interrupt()
	await _wait(0.5)
	var head := zorp.global_position + Vector2(0, -zorp.height_px)
	for part in zorp.parts:
		if part.type == "head":
			head = part.sprite.get_global_transform() * part.sprite.get_rect().get_center()
	for i in 8:
		place.stroke_pet(zorp, 60.0, head + Vector2(18.0 * (i % 2), 0), 500.0)
		await _wait(0.12)
	await _shot("petting_head")
	var tummy := zorp.global_position + Vector2(0, -zorp.height_px * 0.35)
	place._pet_hearts = 0
	for i in 14:
		place.stroke_pet(zorp, 60.0, tummy + Vector2(24.0 * (i % 2), 0), 500.0)
		await _wait(0.12)
	await _wait(0.4)
	await _shot("belly_rub")
	await _wait(1.5)
	place.boop(zorp)
	await _wait(0.3)
	await _shot("boop")
	place._panel.visible = false


## Waits until `done` returns true, or `limit` seconds pass.
func _until(done: Callable, limit: float) -> void:
	var t := 0.0
	while t < limit and not done.call():
		await _wait(0.1)
		t += 0.1


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

## The Beginner game: the pet card's today list, the fun-day calendar, and a Talent Show - no
## stats, no scores. (Fun days follow the real date, so the demo plays the Talent Show whatever
## today is.)
func _beginner() -> void:
	game.profile.set_mode("beginner")
	var home_id: String = game.profile.homes()[0]["id"]
	game.go_place(home_id)
	await _wait(1.2)
	var place := _place()
	place._show_panel(place.creatures[0])
	await _wait(0.3)
	await _shot("beginner_card")
	game.go_calendar()
	await _wait(1.0)
	await _shot("beginner_calendar")
	game.go_fun_day(FunDays.today())
	await _wait(0.8)
	await _shot("fun_day_pick")
	var pet_id: String = game.profile.homes()[0]["pets"][0]
	game.go_stage("talent", home_id, pet_id)
	await _wait(1.0)
	var stage := game.screen as StageScreen
	for t in ["spin", "wave", "dance"]:
		stage.act(t)
		await _wait(1.4)
	await _shot("talent_show")
	stage.finale()
	await _wait(1.2)
	await _shot("talent_show_rosette")
	game.go_stage("parade", home_id, pet_id)
	await _wait(1.0)
	stage = game.screen as StageScreen
	stage.wear(Items.get_item("hat_crown"))
	stage.parade()
	await _wait(2.0)
	await _shot("costume_parade")
	await _wait(3.0)
	game.go_place(home_id, pet_id, false, "party")
	await _wait(2.0)
	await _shot("pet_party")
	game.profile.set_mode("advanced")


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
	# A whole cup: the tug's three rounds, with the first-time showing how, can take a while.
	while t < (150.0 if kind == "tug" else 70.0):
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
				# On the take-off mark, while it glows - which always clears.
				if mini._time > 0.0 and mini.pad_lit():
					mini.tap()
			"marathon":
				if mini._time > 0.0 and fmod(mini._time, TrackGame.BEAT) < dt:
					mini.tap()
			"tug":
				# A thumb following the guide a little late, lifting off to let go every other beat.
				if mini._t > -2.0 * TugGame.BEAT and not mini._over:
					var beat := int(floor(mini._t / TugGame.BEAT))
					var lift := beat % 2 == 0 and not TugGame.is_pull(mini._t)
					if lift and mini._held:
						mini.release()
					elif not lift and not mini._held:
						mini.press(900.0 - mini._h * TugGame.STROKE)
					if mini._held:
						mini.drag(900.0 - TugGame.guide_at(mini._t - 0.08) * TugGame.STROKE)
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

## A part of the creature, drawn where it goes on the one sheet (CreatureSheet.SIZE), facing right.
func _draw_part(type: String, c: DrawCanvas) -> void:
	match type:
		"body":
			_line(c, _ellipse(Vector2(470, 470), Vector2(230, 140)), UI.PALETTE[0], 14.0, 1)
			await _fill(c, Vector2(470, 470), UI.PALETTE[3])
			for spot in [Vector2(380, 430), Vector2(500, 530), Vector2(560, 420)]:
				_line(c, PackedVector2Array([spot, spot + Vector2(6, 3)]), UI.PALETTE[11], 34.0, 2)
		"head":
			_line(c, _ellipse(Vector2(730, 300), Vector2(120, 108)), UI.PALETTE[0], 14.0, 3)
			await _fill(c, Vector2(750, 280), UI.PALETTE[4])
		"eye":
			for e in [[Vector2(712, 280), 24.0, 5], [Vector2(790, 272), 20.0, 6]]:
				_line(c, _ellipse(e[0], Vector2(e[1], e[1] * 1.1)), UI.PALETTE[0], 6.0, e[2])
				await _fill(c, e[0] - Vector2(e[1] * 0.5, 0), UI.PALETTE[1])
				_line(c, PackedVector2Array([e[0] + Vector2(5, 2), e[0] + Vector2(7, 3)]), UI.PALETTE[0], e[1], e[2] + 10)
		"mouth":
			# Wide open - the game closes it.
			_line(c, _ellipse(Vector2(790, 350), Vector2(42, 26)), UI.PALETTE[0], 7.0, 16)
			await _fill(c, Vector2(790, 342), UI.PALETTE[2])
			_line(c, PackedVector2Array([Vector2(768, 362), Vector2(790, 356), Vector2(812, 362)]), UI.PALETTE[10], 12.0, 17)
		"ear":
			_line(c, PackedVector2Array([Vector2(632, 240), Vector2(606, 112), Vector2(696, 206),
				Vector2(632, 240)]), UI.PALETTE[0], 10.0, 7)
			await _fill(c, Vector2(636, 196), UI.PALETTE[10])
		"leg":
			for i in 4:
				var x := 320.0 + i * 100.0
				_line(c, PackedVector2Array([Vector2(x, 570), Vector2(x - 2, 720), Vector2(x + 46, 720),
					Vector2(x + 44, 570)]), UI.PALETTE[0], 11.0, 8 + i)
				await _fill(c, Vector2(x + 22, 690), UI.PALETTE[3])
		"foot":
			for i in 4:
				var x := 320.0 + i * 100.0
				_line(c, _ellipse(Vector2(x + 34, 732), Vector2(36, 15)), UI.PALETTE[0], 9.0, 18 + i)
				await _fill(c, Vector2(x + 44, 734), UI.PALETTE[11])
		"tail":
			var wave := PackedVector2Array()
			for i in 18:
				var t := i / 17.0
				wave.append(Vector2(270 - t * 200, 450 - t * 120 - sin(t * TAU) * 30))
			_line(c, wave, UI.PALETTE[0], 34.0, 9)
			_line(c, wave, UI.PALETTE[3], 16.0, 9)
		"wing":
			_line(c, PackedVector2Array([Vector2(420, 362), Vector2(360, 230), Vector2(380, 130),
				Vector2(450, 200), Vector2(500, 110), Vector2(540, 220), Vector2(560, 352),
				Vector2(420, 362)]), UI.PALETTE[0], 10.0, 10)
			await _fill(c, Vector2(470, 260), UI.PALETTE[7])
		"arm":
			var arm := PackedVector2Array([Vector2(640, 470), Vector2(700, 520), Vector2(760, 548)])
			_line(c, arm, UI.PALETTE[0], 30.0, 19)
			_line(c, arm, UI.PALETTE[3], 16.0, 19)
		"hand":
			_line(c, _ellipse(Vector2(782, 556), Vector2(24, 22)), UI.PALETTE[0], 8.0, 20)
			await _fill(c, Vector2(782, 556), UI.PALETTE[13])


func _draw(subject: String, c: DrawCanvas) -> void:
	match subject:
		"card":
			var swirl := PackedVector2Array()
			for i in 40:
				var t := i / 39.0
				var a := t * TAU * 2.2
				swirl.append(Vector2(256, 256) + Vector2(cos(a), sin(a)) * (20.0 + t * 150.0))
			_line(c, swirl, UI.PALETTE[7], 22.0, 30)
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
