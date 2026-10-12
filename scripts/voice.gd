class_name Voice
extends RefCounted
## A pet's voice (and a drawn toy's sound): a base sound or the kid's own recording, remade with
## the kid's settings (.ai/audio-direction.md).
##
## A recipe is {base, pitch, speed, wobble, echo, bend, robot, backwards}:
##   base       one of BASES, or "recording" for the kid's own (at most Sounds.MAX_RECORD seconds)
##   pitch      semitones, -12 (deeper) .. +12 (higher)
##   speed      0.5 (slower) .. 2.0 (faster) - independent of pitch
##   wobble     0..1, vibrato          echo   0..1, repeats fading away
##   bend       -1..1, the pitch sliding down or up across the sound
##   robot      0..1, ring modulation  backwards  true plays it in reverse
##
## render() does it to the samples, here in GDScript, because the samples have to be readable:
## the bases are raw float files (sfx/voices/*.f32) and recordings are kept as samples.
##
## A pet never makes exactly the same noise twice. speak() repeats the sound a few times - "yip
## yip yip" - and each repeat is a slightly different version (the sliders nudged a little, then
## a small random pitch on top), so it sounds alive rather than like a sample.

const RATE := 22050
const BASES := ["bark", "meow", "chirp", "squeak", "moo", "roar", "hoot", "ribbit", "quack", "oink",
	"baa", "trumpet", "purr", "beep", "gurgle", "boing", "trill", "honk"]
const DEFAULT := {"base": "bark", "pitch": 0.0, "speed": 1.0, "wobble": 0.0, "echo": 0.0, "bend": 0.0,
	"robot": 0.0, "backwards": false}
## The slight differences between the versions a pet uses - the sliders nudged a little.
const NUDGES := [
	{},
	{"pitch": 0.7, "speed": 1.06, "bend": 0.1},
	{"pitch": -0.6, "speed": 0.94, "wobble": 0.08},
]
const SLEEPY := {"pitch": -3.0, "speed": 0.7}
const ASK := {"bend": 0.6}
## How a pet says each thing: [fewest repeats, most repeats, pitch].
const SAYINGS := {"note": [1, 2, 1.0], "heart": [1, 2, 1.06], "star": [2, 3, 1.08], "greet": [2, 3, 1.04],
	"question": [1, 1, 1.0], "tug": [1, 1, 0.95], "hello": [2, 3, 1.03]}

static var _bases := {}
static var _cache := {}


# --- Recipes ---------------------------------------------------------------------------------

## The recipe a pet (or a toy, with key "sound") uses, with every setting filled in.
static func recipe_of(target: Dictionary, key := "voice") -> Dictionary:
	var r: Dictionary = target.get(key, {})
	if r.is_empty():
		r = default_for(target) if key == "voice" else {"base": "squeak"}
	var out := DEFAULT.duplicate()
	out.merge(r, true)
	return out


## A first guess at a pet's voice from what it is: its size, wings, fins.
static func default_for(pet: Dictionary) -> Dictionary:
	var size: String = pet.get("size", "medium")
	var base: String = {"tiny": "squeak", "small": "meow", "medium": "bark", "big": "moo", "huge": "trumpet",
		"giant": "roar"}.get(size, "bark")
	var parts: Array = pet.get("parts", [])
	for p in parts:
		if p.get("type", "") == "wing":
			base = "chirp" if size in ["tiny", "small", "medium"] else base
		elif p.get("type", "") in ["fin", "tentacle"]:
			base = "gurgle"
	var pitch: float = {"tiny": 5.0, "small": 2.0, "medium": 0.0, "big": -2.0, "huge": -3.0,
		"giant": -5.0}.get(size, 0.0)
	return {"base": base, "pitch": pitch}


static func base_samples(id: String) -> PackedFloat32Array:
	if not _bases.has(id):
		var path := "res://sfx/voices/%s.f32" % id
		_bases[id] = FileAccess.get_file_as_bytes(path).to_float32_array() if FileAccess.file_exists(path) \
			else PackedFloat32Array()
	return _bases[id]


## The samples a recipe starts from: the kid's recording if it uses one, else the base.
static func source_of(target: Dictionary, r: Dictionary) -> PackedFloat32Array:
	if r.get("base", "") == "recording":
		var rec: PackedFloat32Array = target.get("_recording", PackedFloat32Array())
		if not rec.is_empty():
			return rec
	var base := base_samples(str(r.get("base", "bark")))
	return base if not base.is_empty() else base_samples("bark")


# --- Making the sound ------------------------------------------------------------------------

## The recipe applied to the samples.
static func render(src: PackedFloat32Array, r: Dictionary) -> PackedFloat32Array:
	if src.size() < 32:
		return src
	var x := src.duplicate()
	if r.get("backwards", false):
		x.reverse()
	var p := pow(2.0, clampf(float(r.get("pitch", 0.0)), -14.0, 14.0) / 12.0)
	var s := clampf(float(r.get("speed", 1.0)), 0.3, 3.0)
	# Stretch first by pitch/speed, then resample by the pitch: the pitch moves by p and the
	# length ends up 1/s - so pitch and speed are separate sliders.
	var t := p / s
	if absf(t - 1.0) > 0.03:
		x = _stretch(x, t)
	x = _resample(x, p, clampf(float(r.get("bend", 0.0)), -1.0, 1.0), clampf(float(r.get("wobble", 0.0)), 0.0, 1.2))
	var robot := clampf(float(r.get("robot", 0.0)), 0.0, 1.0)
	if robot > 0.01:
		for i in x.size():
			x[i] *= (1.0 - robot) + robot * sin(TAU * 110.0 * i / RATE) * 1.4
	var echo := clampf(float(r.get("echo", 0.0)), 0.0, 1.0)
	if echo > 0.01:
		x = _echo(x, echo)
	_finish(x)
	return x


## Overlap-add time stretch: grains of the sound, Hann-windowed, laid down further apart (or
## closer together) than they were taken. Four grains overlap at every point, each nudged to
## line up with what is already there (a short search, every 4th sample), so the grains add
## up instead of cancelling - the bumpy, gargly sound plain overlap-add makes. Cartoon-grade,
## which is what this game wants, and quick enough for a phone.
static func _stretch(x: PackedFloat32Array, t: float) -> PackedFloat32Array:
	var grain := 768
	var hop_out := grain / 4
	var hop_in := hop_out / t
	var search := 64
	var n_out := int(x.size() * t)
	var n_in := x.size()
	var out := PackedFloat32Array()
	out.resize(n_out + grain)
	var norm := PackedFloat32Array()
	norm.resize(n_out + grain)
	var win := PackedFloat32Array()
	win.resize(grain)
	for k in grain:
		win[k] = 0.5 - 0.5 * cos(TAU * k / grain)
	var pos_in := 0.0
	var pos_out := 0
	while pos_out < n_out:
		var i0 := int(pos_in)
		if i0 >= n_in:
			break
		# Where, near i0, does the sound best continue what has already been laid down?
		if pos_out > 0:
			var best := 0
			var best_score := -1e20
			for off in range(-search, search + 1, 4):
				var j0 := i0 + off
				if j0 < 0 or j0 + hop_out >= n_in:
					continue
				var score := 0.0
				for k in range(0, hop_out, 4):
					score += out[pos_out + k] * x[j0 + k]
				if score > best_score:
					best_score = score
					best = off
			i0 = clampi(i0 + best, 0, n_in - 1)
		var count := mini(grain, n_in - i0)
		for k in count:
			out[pos_out + k] += x[i0 + k] * win[k]
			norm[pos_out + k] += win[k]
		pos_in += hop_in
		pos_out += hop_out
	for i in n_out:
		if norm[i] > 0.05:
			out[i] /= norm[i]
	out.resize(n_out)
	return out


## Reads the sound at a varying rate: p (the pitch), sliding by `bend` (up to 7 semitones over
## the sound) and wavering by `wobble` (vibrato).
static func _resample(x: PackedFloat32Array, p: float, bend: float, wobble: float) -> PackedFloat32Array:
	var n_in := x.size()
	var est := n_in / p
	var out := PackedFloat32Array()
	out.resize(int(est * 1.8) + 16)
	var bend_k := bend * 7.0 / 12.0 * log(2.0)
	var depth := wobble * 0.06
	var pos := 0.0
	var i := 0
	var limit := out.size()
	while pos < n_in - 1 and i < limit:
		var prog := minf(1.0, i / est)
		var rate := p * exp(bend_k * prog) * (1.0 + depth * sin(TAU * 6.5 * i / RATE))
		var j := int(pos)
		var f := pos - j
		out[i] = x[j] * (1.0 - f) + x[j + 1] * f
		pos += rate
		i += 1
	out.resize(i)
	return out


static func _echo(x: PackedFloat32Array, amount: float) -> PackedFloat32Array:
	var taps := [[0.12, 0.55], [0.24, 0.32], [0.36, 0.18]]
	var n := x.size()
	var out := x.duplicate()
	out.resize(n + int(0.36 * RATE) + 64)
	for tap: Array in taps:
		var d := int(float(tap[0]) * RATE)
		var g := float(tap[1]) * amount
		for i in n:
			out[i + d] += x[i] * g
	return out


## Normalise to a steady peak and fade the ends, so nothing clicks and every voice is as loud.
static func _finish(x: PackedFloat32Array) -> void:
	var peak := 0.0001
	for v in x:
		peak = maxf(peak, absf(v))
	var g := 0.9 / peak
	var fade := mini(110, x.size() / 4)
	for i in x.size():
		var w := 1.0
		if i < fade:
			w = i / float(fade)
		elif i > x.size() - 1 - fade:
			w = (x.size() - 1 - i) / float(fade)
		x[i] = x[i] * g * w


static func to_stream(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.data = bytes
	return s


# --- Versions, cached ------------------------------------------------------------------------

static func _nudged(r: Dictionary, nudge: Dictionary) -> Dictionary:
	var out := r.duplicate()
	for k in nudge:
		if k == "speed":
			out["speed"] = float(out["speed"]) * float(nudge[k])
		else:
			out[k] = float(out.get(k, 0.0)) + float(nudge[k])
	return out


## One version of a target's sound: 0-2 the everyday nudges, or "sleepy" / "ask". Made once and
## kept until the recipe or the recording changes.
static func version(target: Dictionary, which: Variant, key := "voice") -> AudioStreamWAV:
	var r := recipe_of(target, key)
	var src := source_of(target, r)
	var ck := "%s|%s|%s|%d|%s" % [target.get("id", ""), key, JSON.stringify(r), src.size(), str(which)]
	if not _cache.has(ck):
		var t0 := Time.get_ticks_usec()
		var nudge: Dictionary = NUDGES[int(which)] if which is int else (SLEEPY if which == "sleepy" else ASK)
		_cache[ck] = to_stream(render(src, _nudged(r, nudge)))
		print("[timing] voice %d ms" % ((Time.get_ticks_usec() - t0) / 1000))
		if _cache.size() > 120:
			_cache.erase(_cache.keys()[0])
	return _cache[ck]


## The sound exactly as the recipe says - what the sound maker plays.
static func preview(target: Dictionary, key := "voice") -> AudioStreamWAV:
	return version(target, 0, key)


# --- Talking ---------------------------------------------------------------------------------

## A pet says something: its sound, repeated a few times, each a little different. `creature`
## opens its mouth for each one and is not interrupted while it talks.
static func speak(pet: Dictionary, kind: String, creature: Node = null) -> void:
	if Sounds.main == null or pet.is_empty():
		return
	var now := Time.get_ticks_msec()
	if creature != null and int(creature.get_meta("voice_until", 0)) > now:
		return
	var plan: Array = SAYINGS.get(kind, [1, 1, 1.0])
	var first := version(pet, "ask" if kind == "question" else 0)
	var length := first.get_length()
	var repeats := randi_range(int(plan[0]), int(plan[1]))
	repeats = mini(repeats, maxi(1, int(2.4 / maxf(length, 0.05))))
	var t := 0.0
	var tree := Sounds.main.get_tree()
	# The creature is passed by id: it may be gone (a screen changed) before a repeat plays.
	var cid := creature.get_instance_id() if creature != null else 0
	for k in repeats:
		var v := first if k == 0 else version(pet, randi() % NUDGES.size())
		var pitch := float(plan[2]) * (1.0 + randf_range(-0.05, 0.05))
		var vol := randf_range(-2.0, 0.0)
		var dur := v.get_length() / pitch
		if t <= 0.0:
			_say_one(v, pitch, vol, dur, cid)
		else:
			tree.create_timer(t).timeout.connect(_say_one.bind(v, pitch, vol, dur, cid))
		t += dur * randf_range(0.7, 0.95) + randf_range(0.02, 0.08)
	if creature != null:
		creature.set_meta("voice_until", now + int(t * 1000.0) + 150)


static func _say_one(v: AudioStreamWAV, pitch: float, vol: float, dur: float, creature_id: int) -> void:
	var creature := instance_from_id(creature_id) if creature_id != 0 else null
	if creature_id != 0 and (creature == null or not is_instance_valid(creature)):
		return  # it left before it finished talking
	Sounds.play_stream(v, pitch, vol)
	if creature != null and creature.has_method("open_mouth"):
		creature.open_mouth(dur)


## Sleepy: one slow, low version - the yawn before a nap.
static func yawn(pet: Dictionary, creature: Node = null) -> void:
	var v := version(pet, "sleepy")
	_say_one(v, 1.0, -3.0, v.get_length(), creature.get_instance_id() if creature != null else 0)


## A drawn toy with its own sound makes it - bouncing, squeezed, caught.
static func play_thing(item: Dictionary) -> bool:
	if not item.has("sound"):
		return false
	Sounds.play_stream(version(item, randi() % NUDGES.size(), "sound"), 1.0 + randf_range(-0.05, 0.05))
	return true


# --- Recordings ------------------------------------------------------------------------------

static func save_recording(path: String, samples: PackedFloat32Array) -> void:
	if samples.is_empty():
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		return
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_buffer(samples.to_byte_array())


static func load_recording(path: String) -> PackedFloat32Array:
	if not FileAccess.file_exists(path):
		return PackedFloat32Array()
	return FileAccess.get_file_as_bytes(path).to_float32_array()


## What the mic heard, made ready to use: mono, 22050 Hz, the silence before and after cut off,
## no longer than Sounds.MAX_RECORD, and evened out in loudness. Empty if it was too quiet.
static func process_recording(rec: AudioStreamWAV) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	if rec == null or rec.data.is_empty():
		return out
	var data := rec.data
	var channels := 2 if rec.stereo else 1
	var mono := PackedFloat32Array()
	if rec.format == AudioStreamWAV.FORMAT_16_BITS:
		var frames := data.size() / (2 * channels)
		mono.resize(frames)
		for i in frames:
			var v := 0.0
			for c in channels:
				v += data.decode_s16((i * channels + c) * 2) / 32768.0
			mono[i] = v / channels
	elif rec.format == AudioStreamWAV.FORMAT_8_BITS:
		var frames8 := data.size() / channels
		mono.resize(frames8)
		for i in frames8:
			mono[i] = data.decode_s8(i * channels) / 128.0
	else:
		return out
	var ratio := float(rec.mix_rate) / RATE
	var n := int(mono.size() / ratio)
	out.resize(n)
	for i in n:
		var pos := i * ratio
		var j := int(pos)
		var f := pos - j
		out[i] = mono[j] * (1.0 - f) + (mono[j + 1] * f if j + 1 < mono.size() else 0.0)
	var peak := 0.0
	for v in out:
		peak = maxf(peak, absf(v))
	if peak < 0.02:
		return PackedFloat32Array()
	var gate := maxf(0.02, peak * 0.08)
	var first := 0
	while first < n and absf(out[first]) < gate:
		first += 1
	var last := n - 1
	while last > first and absf(out[last]) < gate:
		last -= 1
	var margin := int(0.03 * RATE)
	first = maxi(0, first - margin)
	last = mini(n - 1, last + margin)
	var length := mini(last - first + 1, int(Sounds.MAX_RECORD * RATE))
	out = out.slice(first, first + length)
	_finish(out)
	return out
