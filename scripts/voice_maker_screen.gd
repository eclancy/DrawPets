class_name VoiceMakerScreen
extends Control
## "What does it sound like?" - making a pet's voice (or a drawn toy's sound, with key "sound").
## Pick a base sound, or record your own (up to Sounds.MAX_RECORD seconds), then shape it with
## sliders that each have a picture at both ends: deeper/higher, slower/faster, flat/wobbly,
## dry/echoey, bend down/bend up, plain/robot, and backwards. Every change plays the result.
##
## Edits `target[key]` (the recipe) and `target["_recording"]` in place. Set the fields, add it
## to the tree; `on_done` is called when the kid taps Done.

const SLIDERS := [
	["pitch", "snd_low", "snd_high", -12.0, 12.0, 0.5],
	["speed", "snd_slow", "snd_fast", -1.0, 1.0, 0.05],
	["wobble", "snd_flat", "snd_wobble", 0.0, 1.0, 0.05],
	["echo", "snd_flat", "snd_echo", 0.0, 1.0, 0.05],
	["bend", "snd_bend_down", "snd_bend_up", -1.0, 1.0, 0.05],
	["robot", "snd_flat", "snd_robot", 0.0, 1.0, 0.05],
]

var game: GameRoot
var target: Dictionary
var key := "voice"
var title_text := ""
var on_done := Callable()
## Offers "No sound" (a drawn toy does not have to make one): calls on_skip.
var on_skip := Callable()

var _r := {}
var _sliders := {}
var _bases := {}
var _backwards: Button
var _creature: Creature
var _message: Label
var _overlay: Control
var _wait := 0.0
var _recording := false
var _record_t := 0.0
var _record_bar: ProgressBar
var _quiet := false


func _ready() -> void:
	_r = Voice.recipe_of(target, key).duplicate()
	add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	add_child(UI.full_rect(UI.margin(row, 18)))

	# Left: who is making the sound, and a big Play.
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(390, 0)
	left.add_theme_constant_override("separation", 10)
	row.add_child(left)
	var stage := UI.place_button(target.get("place", "meadow"), "", Vector2(390, 470))
	stage.pressed.connect(play)
	left.add_child(stage)
	if key == "voice" and not target.get("parts", []).is_empty():
		_creature = Creature.new()
		_creature.wander = false
		_creature.confine = false
		_creature.depth_scale = false
		stage.add_child(_creature)
		_creature.setup(target, 240.0)
		# The stage may already be its final size (it has a minimum size), so place the pet now as
		# well as on every resize.
		var place := func(): _creature.position = Vector2(stage.size.x / 2.0, stage.size.y - 60.0)
		stage.resized.connect(place)
		place.call_deferred()
	elif target.has("_tex"):
		var pic := UI.item_picture(target, 260)
		pic.position = Vector2(65, 100)
		stage.add_child(pic)
	left.add_child(UI.big_icon_button("snd_play", "Play it!", play))

	# Right: the base sounds, the sliders, and Done.
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)
	row.add_child(col)
	var name: String = target.get("name", "")
	col.add_child(UI.title(title_text if title_text != "" else "What does %s sound like?" % (name if name != "" else "it"), 30))
	_message = UI.label("Pick a sound to start from - or record your own!", 21, true)
	_message.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(_message)
	var grid := GridContainer.new()
	grid.columns = 10
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	for base in Voice.BASES:
		grid.add_child(_base_button(base, "snd_" + base))
	grid.add_child(_base_button("recording", "snd_record"))
	var rec := Button.new()
	rec.custom_minimum_size = Vector2(80, 80)
	rec.tooltip_text = "Record your own"
	rec.add_theme_stylebox_override("normal", UI._box(Color("#ffe4e0"), Color("#d0482a"), 3, 14))
	var rec_pic := UI.icon("snd_record", 44)
	rec_pic.position = Vector2(18, 4)
	rec.add_child(rec_pic)
	var rec_l := UI.label("Record", 17)
	rec_l.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	rec_l.offset_top = -27
	rec_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rec_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rec.add_child(rec_l)
	rec.pressed.connect(press_record)
	grid.add_child(rec)
	col.add_child(grid)

	for s in SLIDERS:
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		line.add_child(UI.icon(s[1], 44))
		var slider := HSlider.new()
		slider.min_value = s[3]
		slider.max_value = s[4]
		slider.step = s[5]
		slider.custom_minimum_size = Vector2(0, 46)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.value_changed.connect(_slid.bind(s[0]))
		_sliders[s[0]] = slider
		line.add_child(slider)
		line.add_child(UI.icon(s[2], 44))
		col.add_child(line)

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 8)
	_backwards = UI.icon_button("snd_backwards", "Backwards", toggle_backwards, 40, Vector2(148, 84))
	_backwards.toggle_mode = true
	bottom.add_child(_backwards)
	bottom.add_child(UI.icon_button("snd_dice", "Surprise me", surprise, 40, Vector2(148, 84)))
	if on_skip.is_valid():
		bottom.add_child(UI.icon_button("tool_skip", "No sound", func(): on_skip.call(), 40, Vector2(148, 84)))
	var done := UI.big_icon_button("tool_done", "Done!", press_done)
	done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(done)
	col.add_child(bottom)
	_show_recipe()


func _base_button(base: String, icon: String) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(80, 80)
	b.toggle_mode = true
	b.tooltip_text = base.capitalize()
	var pic := UI.icon(icon, 44)
	pic.position = Vector2(18, 4)
	b.add_child(pic)
	var l := UI.label("Mine" if base == "recording" else base.capitalize(), 17)
	l.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	l.offset_top = -27
	l.clip_text = true
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(l)
	b.pressed.connect(pick_base.bind(base))
	_bases[base] = b
	return b


## Puts the recipe on the controls without each one setting off a preview.
func _show_recipe() -> void:
	for k in _sliders:
		var v: float = float(_r.get(k, 0.0))
		if k == "speed":
			v = log(maxf(v, 0.01)) / log(2.0)
		_sliders[k].set_value_no_signal(v)
	_backwards.set_pressed_no_signal(bool(_r.get("backwards", false)))
	var has_rec: bool = not target.get("_recording", PackedFloat32Array()).is_empty()
	_bases["recording"].visible = has_rec
	for b in _bases:
		_bases[b].set_pressed_no_signal(b == _r.get("base", ""))


func pick_base(base: String) -> void:
	_r["base"] = base
	_apply()


func _slid(v: float, which: String) -> void:
	_r[which] = pow(2.0, v) if which == "speed" else v
	_wait = 0.3  # play once the finger settles


func toggle_backwards() -> void:
	_r["backwards"] = _backwards.button_pressed
	_apply()


## A random but sensible sound: any base, the sliders nudged, the odd effect.
func surprise() -> void:
	var bases: Array = Voice.BASES.duplicate()
	if not target.get("_recording", PackedFloat32Array()).is_empty():
		bases.append("recording")
	_r["base"] = bases.pick_random()
	_r["pitch"] = snappedf(randf_range(-7.0, 7.0), 0.5)
	_r["speed"] = pow(2.0, randf_range(-0.6, 0.6))
	_r["wobble"] = randf() * 0.6 if randf() < 0.4 else 0.0
	_r["echo"] = randf() * 0.6 if randf() < 0.3 else 0.0
	_r["bend"] = randf_range(-0.8, 0.8) if randf() < 0.4 else 0.0
	_r["robot"] = randf() * 0.7 if randf() < 0.15 else 0.0
	_r["backwards"] = randf() < 0.1
	_apply()


func _apply() -> void:
	target[key] = _r.duplicate()
	_show_recipe()
	play()


## Plays the sound as it is now - and the pet says it, mouth and all.
func play() -> void:
	target[key] = _r.duplicate()
	var v := Voice.preview(target, key)
	Sounds.play_stream(v)
	if _creature != null:
		_creature.open_mouth(v.get_length())
		_creature.perform("greet", minf(v.get_length() + 0.2, 1.4))


func _process(delta: float) -> void:
	if _wait > 0.0:
		_wait -= delta
		if _wait <= 0.0:
			play()
	if _recording:
		_record_t += delta
		_record_bar.value = _record_t
		if _record_t >= Sounds.MAX_RECORD:
			stop_record()


func press_done() -> void:
	target[key] = _r.duplicate()
	on_done.call()


# --- Recording -------------------------------------------------------------------------------

func press_record() -> void:
	if not bool(game.profile.settings().get("mic", false)):
		_ask_mic()
		return
	_begin_record()


## The mic is off until someone says yes - and a kid can say no.
func _ask_mic() -> void:
	_overlay_open()
	var col := _overlay.get_meta("col") as VBoxContainer
	col.add_child(UI.icon("snd_record", 90))
	col.add_child(UI.title("Use the microphone?", 36))
	col.add_child(UI.label("You can record your pet's very own sound. It stays on this device - nobody else hears it.", 22, true))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.add_child(UI.icon_button("snd_mic_off", "No thanks", _overlay_close, 44, Vector2(180, 96)))
	var yes := UI.big_icon_button("snd_record", "Yes, record!", _mic_yes)
	yes.custom_minimum_size = Vector2(300, 96)
	row.add_child(yes)
	col.add_child(row)


func _mic_yes() -> void:
	game.profile.settings()["mic"] = true
	game.profile.save()
	_overlay_close()
	_begin_record()


func _begin_record() -> void:
	if OS.get_name() == "Android" and not OS.request_permission("android.permission.RECORD_AUDIO"):
		get_tree().on_request_permissions_result.connect(_on_permission, CONNECT_ONE_SHOT)
		return
	start_record()


func _on_permission(permission: String, granted: bool) -> void:
	if permission.ends_with("RECORD_AUDIO") and granted:
		start_record()
	else:
		_say("The microphone isn't allowed - you can still pick a sound!")


func start_record() -> void:
	if not Sounds.record_start():
		_say("The microphone isn't working - you can still pick a sound!")
		return
	_recording = true
	_record_t = 0.0
	_overlay_open()
	var col := _overlay.get_meta("col") as VBoxContainer
	col.add_child(UI.icon("snd_record", 90))
	col.add_child(UI.title("Make your pet's sound!", 38))
	col.add_child(UI.label("Up to %d seconds." % int(Sounds.MAX_RECORD), 22))
	_record_bar = ProgressBar.new()
	_record_bar.max_value = Sounds.MAX_RECORD
	_record_bar.show_percentage = false
	_record_bar.custom_minimum_size = Vector2(420, 26)
	col.add_child(_record_bar)
	col.add_child(UI.big_icon_button("snd_stop", "Stop", stop_record))


func stop_record() -> void:
	if not _recording:
		return
	_recording = false
	_overlay_close()
	use_recording(Voice.process_recording(Sounds.record_stop()))


## A recording to use - from the mic, or (the demo) made up.
func use_recording(samples: PackedFloat32Array) -> void:
	if samples.is_empty():
		_say("I couldn't hear that! Try again, a little louder.")
		Sounds.play("ui_nope")
		return
	target["_recording"] = samples
	_r["base"] = "recording"
	_say("That's your sound! Now make it higher, faster, wobblier...")
	_apply()


func _say(text: String) -> void:
	_message.text = text
	_message.add_theme_color_override("font_color", UI.ACCENT)


func _overlay_open() -> void:
	_overlay_close()
	_overlay = Control.new()
	add_child(UI.full_rect(_overlay))
	var dim := ColorRect.new()
	dim.color = Color(0.23, 0.21, 0.4, 0.35)
	_overlay.add_child(UI.full_rect(dim))
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(640, 0)
	_overlay.add_child(panel)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)
	_overlay.set_meta("col", col)


func _overlay_close() -> void:
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
