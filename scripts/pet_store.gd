class_name PetStore
extends RefCounted
## Saving and loading pets. A pet is one folder - user://pets/<id>/pet.json plus the PNGs the
## kid drew - and nothing about it lives anywhere else. That is deliberate: a folder is exactly
## what gets uploaded when a pet is shared through ecec.dev (see .ai/sharing.md).
##
## In memory a pet is a plain Dictionary, the same shape as its JSON, plus two keys that are
## never saved: "_img" (file name -> Image) and "_tex" (file name -> ImageTexture).

const ROOT := "user://pets"
const NEEDS := ["food", "fun", "clean", "energy"]

## Gentle care (.ai/pet-life.md): no need ever drops below this. A forgotten pet is sleepy and
## mopey, never sick, never gone.
const FLOOR := 0.25

## How much each need changes per real hour the app is closed. Energy is negative because a
## pet rests while you are away.
## Food and fun run down over about a day - feed and play every day. Clean runs down over a
## week: one bath day a week fills it (Care).
const DRIFT_PER_HOUR := {"food": 0.05, "fun": 0.04, "clean": 0.0045, "energy": -0.15}


static func new_id() -> String:
	var t := Time.get_datetime_dict_from_system()
	return "pet_%04d%02d%02d_%02d%02d%02d_%03d" % [t.year, t.month, t.day, t.hour, t.minute,
		t.second, randi() % 1000]


static func folder(id: String) -> String:
	return ROOT + "/" + id


static func list_ids() -> Array:
	var ids := []
	var dir := DirAccess.open(ROOT)
	if dir == null:
		return ids
	for name in dir.get_directories():
		if FileAccess.file_exists(folder(name) + "/pet.json"):
			ids.append(name)
	ids.sort()
	return ids


static func load_pet(id: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(folder(id) + "/pet.json")
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var pet: Dictionary = data
	pet["_img"] = {}
	pet["_tex"] = {}
	for file in image_files(pet):
		var img := Image.load_from_file(folder(id) + "/" + file)
		if img != null:
			pet["_img"][file] = img
	pet["_recording"] = Voice.load_recording(folder(id) + "/voice.pcm")
	return pet


## Gone for good - a pet let go to live in the wild (FixScreen).
static func delete_pet(id: String) -> void:
	var dir := folder(id)
	var d := DirAccess.open(dir)
	if d == null:
		return
	for file in d.get_files():
		d.remove(file)
	DirAccess.remove_absolute(dir)


## Writes pet.json, and the drawings (and a recorded voice) too when `with_images` - they only
## change when drawn or recorded. Drawings no longer used - a part redrawn or taken off - are
## deleted, so a folder holds exactly the pet.
static func save_pet(pet: Dictionary, with_images := false) -> void:
	var dir := folder(pet["id"])
	DirAccess.make_dir_recursive_absolute(dir)
	if with_images:
		var used := image_files(pet)
		for file in used:
			if pet["_img"].has(file):
				(pet["_img"][file] as Image).save_png(dir + "/" + file)
		var d := DirAccess.open(dir)
		if d != null:
			for file in d.get_files():
				if file.ends_with(".png") and not used.has(file):
					d.remove(file)
		Voice.save_recording(dir + "/voice.pcm", pet.get("_recording", PackedFloat32Array()))
	var plain := {}
	for key in pet:
		if not str(key).begins_with("_"):
			plain[key] = pet[key]
	var f := FileAccess.open(dir + "/pet.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(plain, "\t"))


static func image_files(pet: Dictionary) -> Array:
	var files := []
	for p in pet.get("parts", []):
		for key in ["image", "shine_image"]:
			var file: String = p.get(key, "")
			if file != "" and not files.has(file):
				files.append(file)
	# The cards the kid drew for its tricks (Tricks).
	for t in pet.get("tricks", {}):
		var card: String = pet["tricks"][t].get("image", "")
		if card != "" and not files.has(card):
			files.append(card)
	return files


static func texture(pet: Dictionary, file: String) -> Texture2D:
	var cache: Dictionary = pet["_tex"]
	if not cache.has(file):
		var img: Image = pet["_img"].get(file)
		if img == null:
			return null
		cache[file] = ImageTexture.create_from_image(img)
	return cache[file]


## Applies the time the app was closed to the pet's needs. Returns the hours away, which the
## place uses to decide how excited the greeting is.
static func catch_up(pet: Dictionary) -> float:
	var now := Time.get_unix_time_from_system()
	var last: float = pet.get("last_seen", now)
	var hours := clampf((now - last) / 3600.0, 0.0, 24.0 * 30.0)
	var needs: Dictionary = pet.get("needs", {})
	for n in NEEDS:
		needs[n] = clampf(float(needs.get(n, 1.0)) - DRIFT_PER_HOUR[n] * hours, FLOOR, 1.0)
	pet["needs"] = needs
	pet["last_seen"] = now
	Stats.slip(pet, hours)
	return hours


static func change_need(pet: Dictionary, need: String, amount: float) -> void:
	var needs: Dictionary = pet["needs"]
	needs[need] = clampf(float(needs.get(need, 1.0)) + amount, FLOOR, 1.0)


## 0..1. Drives tail wag, bounce and how readily it plays.
static func happiness(pet: Dictionary) -> float:
	var needs: Dictionary = pet.get("needs", {})
	var total := 0.0
	for n in NEEDS:
		total += float(needs.get(n, 1.0))
	return clampf(total / NEEDS.size(), 0.0, 1.0)
