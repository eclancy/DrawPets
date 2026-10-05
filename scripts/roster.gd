class_name Roster
extends RefCounted
## Creatures the game drew part by part - the competition rivals and the pets in the shop's
## Adopt tab - put together exactly the way a kid's pet is: set_body, then PetBuilder.add_parts
## for each part type in PartTypes.ORDER, so they lay out and move the same way.
##
## A roster entry is {name, look, parts}. Its parts map a part type to how many - or
## "<type>_on_<host>" for an add-on that is not on its usual host ("claw_on_arm": 2). Art ids
## are "<creature>_<part key>", baked to res://art/<group>/ with their dots in pivots.json.

static var _pivots := {}


## A creature as a pet dictionary, or {} if its body has not been drawn. `from_files` reads the
## PNGs straight off disk (the baker, before Godot has imported them).
static func assemble(group: String, id: String, entry: Dictionary, pivots := {},
		from_files := false) -> Dictionary:
	var body := _image(group, id + "_body", from_files)
	if body == null:
		return {}
	var pet := PetBuilder.new_pet()
	pet["name"] = entry.get("name", id.capitalize())
	PetBuilder.set_body(pet, body)
	var parts: Dictionary = entry.get("parts", {})
	for type in PartTypes.ORDER:
		for key in parts:
			var split := split_key(key)
			if split[0] != type:
				continue
			var art := "%s_%s" % [id, key]
			var img := _image(group, art, from_files)
			if img == null:
				continue
			PetBuilder.add_parts(pet, type, int(parts[key]), img, _pivot(group, art, pivots), {}, split[1])
	return pet


## "claw_on_arm" -> ["claw", "arm"]; "horn" -> ["horn", ""] (its usual host).
static func split_key(key: String) -> Array:
	if key.contains("_on_"):
		var bits := key.split("_on_")
		return [bits[0], bits[1]]
	return [key, ""]


static func _image(group: String, art: String, from_files: bool) -> Image:
	var path := "res://art/%s/%s.png" % [group, art]
	if from_files:
		var global := ProjectSettings.globalize_path(path)
		return Image.load_from_file(global) if FileAccess.file_exists(global) else null
	if ResourceLoader.exists(path):
		var tex = load(path)
		if tex is Texture2D:
			return tex.get_image()
	return null


static func _pivot(group: String, art: String, pivots: Dictionary) -> Vector2:
	var table := pivots
	if table.is_empty():
		if not _pivots.has(group):
			var path := "res://art/%s/pivots.json" % group
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
			_pivots[group] = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
		table = _pivots[group]
	var p = table.get(art)
	return Vector2(float(p[0]), float(p[1])) if p is Array else Vector2(60, 60)
