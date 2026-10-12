extends SceneTree
## Renders a base sound through each of the voice sliders (Voice.render) into .shots/voice_check/,
## so the effects can be looked at as spectrograms - nobody on this project can hear them:
##
##   "$GODOT_BIN" --headless --path . -s tools/voice_check.gd -- --base=meow
##   python tools/audio/sheet.py .shots/voice_check     -> .shots/voice_check.png
##
## Higher should shift every band up, faster should be shorter at the same pitch, bend should
## slope, wobble should wave, echo should repeat, robot should add sidebands, backwards should flip.

const CASES := [
	["plain", {}], ["higher", {"pitch": 7.0}], ["deeper", {"pitch": -7.0}], ["faster", {"speed": 2.0}],
	["slower", {"speed": 0.5}], ["wobbly", {"wobble": 1.0}], ["echo", {"echo": 1.0}],
	["bend_up", {"bend": 1.0}], ["bend_down", {"bend": -1.0}], ["robot", {"robot": 1.0}],
	["backwards", {"backwards": true}], ["nudge_1", {"pitch": 0.7, "speed": 1.06, "bend": 0.1}],
]


func _initialize() -> void:
	var base := "meow"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--base="):
			base = arg.substr(7)
	var out := ProjectSettings.globalize_path("res://.shots/voice_check")
	DirAccess.make_dir_recursive_absolute(out)
	var src := Voice.base_samples(base)
	for i in CASES.size():
		var r: Dictionary = Voice.DEFAULT.duplicate()
		r["base"] = base
		r.merge(CASES[i][1], true)
		var t := Time.get_ticks_msec()
		var samples := Voice.render(src, r)
		var ms := Time.get_ticks_msec() - t
		Voice.to_stream(samples).save_to_wav("%s/%02d_%s.wav" % [out, i, CASES[i][0]])
		print("%-10s %5.2f s  rendered in %d ms" % [CASES[i][0], samples.size() / float(Voice.RATE), ms])
	quit()
