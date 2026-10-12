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
