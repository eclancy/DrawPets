class_name SettingsScreen
extends Control
## Volumes, and the microphone (.ai/audio-direction.md). The mic is off until it is turned on -
## here, or the first time a kid taps Record and says yes - and recordings never leave the
## device. Every mic feature has a touch way round it, so the game is whole with it off.

const ROWS := [["music", "snd_music", "Music"], ["sfx", "snd_speaker", "Sounds"],
	["voice", "snd_voice", "Pet voices"], ["ambience", "icon_home", "Place sounds"]]

var game: GameRoot
var on_back := Callable()

var _mic: Button
## The grown-up buttons - switching Beginner/Advanced, and feedback - are held for a moment, so a
## stray tap never changes the game or opens a box to type in.
const HOLD := 1.5
var _holding := ""          # which held button is down: "mode", "feedback" or none
var _held := 0.0
var _bars := {}
var _mode_bar: ProgressBar
var _mode_label: Label
var _mode_button: Button


func _ready() -> void:
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	add_child(UI.full_rect(UI.margin(col, 30)))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 14)
	top.add_child(UI.icon_button("tool_back", "Back", func(): on_back.call(), 40, Vector2(100, 84)))
	top.add_child(UI.icon("ui_settings", 64))
	top.add_child(UI.title("Settings", 44))
	col.add_child(top)

	var s := game.profile.settings()
	for row in ROWS:
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 16)
		r.add_child(UI.icon(row[1], 60))
		var l := UI.label(row[2], 28)
		l.custom_minimum_size = Vector2(220, 0)
		r.add_child(l)
		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = float(s.get(row[0], 1.0))
		slider.custom_minimum_size = Vector2(0, 56)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.value_changed.connect(_set_volume.bind(row[0]))
		slider.drag_ended.connect(func(_changed: bool): _sample(row[0]))
		r.add_child(slider)
		col.add_child(r)

	var mic_row := HBoxContainer.new()
	mic_row.add_theme_constant_override("separation", 16)
	mic_row.add_child(UI.icon("snd_record", 60))
	var ml := UI.label("Microphone - for recording your pet's very own sound. Recordings stay on this device.", 22, true)
	ml.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mic_row.add_child(ml)
	_mic = UI.button("", toggle_mic, Vector2(180, 72), 26)
	mic_row.add_child(_mic)
	col.add_child(mic_row)
	_refresh_mic()

	# Beginner or Advanced (ModeScreen) - for a grown-up, so it is held, not tapped.
	var mode_row := HBoxContainer.new()
	mode_row.add_theme_constant_override("separation", 16)
	mode_row.add_child(UI.icon("icon_trophy", 60, "none"))
	_mode_label = UI.label("", 22, true)
	_mode_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_row.add_child(_mode_label)
	var hold_col := VBoxContainer.new()
	_mode_button = UI.button("", func(): pass, Vector2(300, 64), 22)
	_mode_bar = _held_button(_mode_button, "mode", hold_col)
	mode_row.add_child(hold_col)
	col.add_child(mode_row)
	_refresh_mode()

	# The version, and feedback for a grown-up (FeedbackScreen) - held too.
	var last := HBoxContainer.new()
	last.add_theme_constant_override("separation", 16)
	var version := "DrawPets %s" % UpdateScreen.current_version()
	if UpdateScreen.newer != "":
		version += " - version %s is out: a grown-up can get it from %s" % [UpdateScreen.newer, UpdateScreen.DOWNLOAD_PAGE]
	var vl := UI.label(version, 18, true)
	vl.add_theme_color_override("font_color", UI.INK_SOFT)
	vl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	last.add_child(vl)
	var fb_col := VBoxContainer.new()
	_held_button(UI.button("Grown-ups, hold: report a bug or idea", func(): pass, Vector2(420, 56), 20), "feedback", fb_col)
	last.add_child(fb_col)
	col.add_child(last)


## A button that does its thing once held for HOLD, with a bar filling under it.
func _held_button(b: Button, what: String, into: Container) -> ProgressBar:
	b.button_down.connect(func(): _holding = what)
	b.button_up.connect(func(): _holding = "")
	into.add_child(b)
	var bar := ProgressBar.new()
	bar.max_value = HOLD
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 12)
	into.add_child(bar)
	_bars[what] = bar
	return bar


func _refresh_mode() -> void:
	var adv := game.profile.advanced()
	_mode_label.text = ("Advanced mode - looking after pets, plus stats, training and competitions." if adv
		else "Beginner mode - looking after pets. No stats, no scores, no contests.")
	_mode_button.text = "Hold: switch to %s" % ("Beginner" if adv else "Advanced")


func _process(delta: float) -> void:
	if _bars.is_empty():
		return
	if _holding != "":
		_held += delta
		if int(_held * 4.0) != int((_held - delta) * 4.0):
			Sounds.play("ui_tap", 1.0 + _held * 0.3)
	else:
		_held = maxf(0.0, _held - delta * 3.0)
	for what in _bars:
		_bars[what].value = _held if what == _holding else 0.0
	if _held >= HOLD:
		var what := _holding
		_held = 0.0
		_holding = ""
		match what:
			"mode":
				switch_mode()
			"feedback":
				game.go_feedback(game.go_settings.bind(on_back))


func switch_mode() -> void:
	game.profile.set_mode("beginner" if game.profile.advanced() else "advanced")
	Sounds.play("star")
	game.toast("Now playing in %s mode." % game.profile.mode().capitalize(), "icon_trophy")
	_refresh_mode()


func _set_volume(v: float, key: String) -> void:
	game.profile.settings()[key] = v
	if Sounds.main != null:
		Sounds.main.apply_settings(game.profile.settings())


func _sample(key: String) -> void:
	game.profile.save()
	match key:
		"sfx":
			Sounds.play("star")
		"voice":
			Sounds.play_stream(Voice.to_stream(Voice.render(Voice.base_samples("bark"), Voice.DEFAULT)))


func toggle_mic() -> void:
	var s := game.profile.settings()
	s["mic"] = not bool(s.get("mic", false))
	game.profile.save()
	if s["mic"] and OS.get_name() == "Android":
		OS.request_permission("android.permission.RECORD_AUDIO")
	_refresh_mic()


func _refresh_mic() -> void:
	var on := bool(game.profile.settings().get("mic", false))
	_mic.text = "On" if on else "Off"
	_mic.add_theme_stylebox_override("normal", UI._box(UI.GOOD if on else UI.CARD, UI.INK, 3))
