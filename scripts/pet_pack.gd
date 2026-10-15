class_name PetPack
extends RefCounted
## A family's pets packed up to hop across to a friend's phone (.ai/sharing.md), and unpacked -
## checked to the last field - on the other side.
##
## What travels: each pet's drawings, its layout, its name, size, favourite place, personality,
## coat, a generated voice, and clothes from the game's own catalog. NEVER a voice recording (a
## recorded voice is swapped for the generated one), its journal, photos, friends, stars or
## anything about the child (CLAUDE.md rule 8).
##
## A pack is var_to_bytes of {"v", "family": {id, name}, "pets": [{pet, images}]}, zstd
## compressed, behind a magic header. Everything that arrives is untrusted: sizes are capped,
## every value is type-checked against the game's own tables, and every image is re-decoded.

const MAGIC := "DPAK1"
const MAX_PACKED := 8 * 1024 * 1024
const MAX_UNPACKED := 24 * 1024 * 1024
const MAX_PETS := 40
const MAX_PARTS := 80
const MAX_IMAGES := 64
const MAX_IMAGE_BYTES := 2 * 1024 * 1024
const MAX_IMAGE_SIDE := 1024
const MAX_NAME := 24
const PART_KEYS := ["id", "type", "parent", "image", "shine_image", "shine", "pos", "pivot", "rot",
	"scale", "draw_scale", "flip", "behind", "pair", "side"]
const OUTFIT_KEYS := ["item", "parent", "pos", "rot", "scale", "flip", "behind"]


## Every pet in the family, packed.
static func pack(profile: Profile) -> PackedByteArray:
	var fam := Family.get_or_make(profile)
	var pets := []
	for h in profile.homes():
		for pid in h["pets"]:
			var pet := PetStore.load_pet(pid)
			if not pet.is_empty() and pets.size() < MAX_PETS:
				pets.append(_outgoing(pet))
	var data := {"v": 1, "family": {"id": fam["id"], "name": fam["name"]}, "pets": pets}
	var raw := var_to_bytes(data)
	var out := MAGIC.to_ascii_buffer()
	out.append_array(_u32(raw.size()))
	out.append_array(raw.compress(FileAccess.COMPRESSION_ZSTD))
	return out


## Only what may travel - see the top of this file.
static func _outgoing(pet: Dictionary) -> Dictionary:
	var p := {}
	for k in ["id", "name", "size", "place", "personality", "coat"]:
		if pet.has(k):
			p[k] = pet[k]
	if not p.has("coat"):
		p["coat"] = BathDay.coat(pet)
	var voice: Dictionary = pet.get("voice", {})
	if voice.get("base", "") == "recording" or voice.is_empty():
		voice = Voice.default_for(pet)  # a child's recording never leaves the device
	p["voice"] = voice.duplicate()
	var parts := []
	for part in pet.get("parts", []):
		var q := {}
		for k in PART_KEYS:
			if part.has(k):
				q[k] = part[k]
		parts.append(q)
	p["parts"] = parts
	var outfit := []
	for o in pet.get("outfit", []):
		if Items.is_catalog(str(o.get("item", ""))):  # a drawn hat stays home
			var q := {}
			for k in OUTFIT_KEYS:
				if o.has(k):
					q[k] = o[k]
			outfit.append(q)
	p["outfit"] = outfit
	for k in ["food", "toy"]:
		var item := str(pet.get(k, {}).get("item", ""))
		if Items.is_catalog(item):
			p[k] = {"item": item}
	var images := {}
	for file in PetStore.image_files({"parts": parts}):
		var img: Image = pet["_img"].get(file)
		if img != null:
			images[file] = img.save_png_to_buffer()
	return {"pet": p, "images": images}


## A friend's pack, checked: {"family": {id, name}, "pets": [pet dicts with _img]} - or {} if it
## is not a good pack. Pets that fail a check are left out; the rest come through.
static func unpack(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 9 or bytes.size() > MAX_PACKED or bytes.slice(0, 5).get_string_from_ascii() != MAGIC:
		return {}
	var size := bytes.decode_u32(5)
	if size <= 0 or size > MAX_UNPACKED:
		return {}
	var raw := bytes.slice(9).decompress(size, FileAccess.COMPRESSION_ZSTD)
	if raw.size() != size:
		return {}
	var data = bytes_to_var(raw)  # no objects: allow_objects is false
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var fam = data.get("family")
	if typeof(fam) != TYPE_DICTIONARY:
		return {}
	var fid := _hex(fam.get("id"))
	var fname: String = fam.get("name", "") if typeof(fam.get("name")) == TYPE_STRING else ""
	if fid == "" or not Family.NAMES.has(fname):
		return {}
	var pets := []
	var list = data.get("pets")
	if typeof(list) != TYPE_ARRAY:
		return {}
	for entry in list.slice(0, MAX_PETS):
		var pet := _incoming(entry)
		if not pet.is_empty():
			pets.append(pet)
	return {"family": {"id": fid, "name": fname}, "pets": pets}


static func _incoming(entry) -> Dictionary:
	if typeof(entry) != TYPE_DICTIONARY or typeof(entry.get("pet")) != TYPE_DICTIONARY \
			or typeof(entry.get("images")) != TYPE_DICTIONARY:
		return {}
	var src: Dictionary = entry["pet"]
	var pet := {}
	var pid := _token(src.get("id"))
	if pid == "":
		return {}
	pet["id"] = pid
	pet["name"] = _text(src.get("name"), MAX_NAME)
	if pet["name"] == "":
		pet["name"] = "Friend"
	pet["size"] = src.get("size") if Creature.SIZES.has(src.get("size")) else "medium"
	pet["place"] = src.get("place") if Places.DATA.has(src.get("place")) else "meadow"
	var words := []
	if typeof(src.get("personality")) == TYPE_ARRAY:
		for w in src["personality"]:
			if typeof(w) == TYPE_STRING and Words.PET.has(w) and words.size() < 3:
				words.append(w)
	pet["personality"] = words
	var coats := BathDay.COATS.map(func(c): return c[0])
	pet["coat"] = src.get("coat") if coats.has(src.get("coat")) else "fur"
	pet["voice"] = _voice(src.get("voice"))
	for k in ["food", "toy"]:
		var it = src.get(k)
		if typeof(it) == TYPE_DICTIONARY and typeof(it.get("item")) == TYPE_STRING and Items.is_catalog(it["item"]):
			pet[k] = {"item": it["item"]}
	# Its drawings: re-decoded, and small enough.
	var imgs: Dictionary = entry["images"]
	if imgs.size() > MAX_IMAGES:
		return {}
	var images := {}
	for file in imgs:
		var name := _file(file)
		var buf = imgs[file]
		if name == "" or typeof(buf) != TYPE_PACKED_BYTE_ARRAY or buf.size() > MAX_IMAGE_BYTES:
			return {}
		var img := Image.new()
		if img.load_png_from_buffer(buf) != OK or img.get_width() > MAX_IMAGE_SIDE or img.get_height() > MAX_IMAGE_SIDE:
			return {}
		img.convert(Image.FORMAT_RGBA8)
		images[name] = img
	# Its parts: every field checked, every drawing present.
	if typeof(src.get("parts")) != TYPE_ARRAY or src["parts"].is_empty() or src["parts"].size() > MAX_PARTS:
		return {}
	var parts := []
	var ids := {}
	for q in src["parts"]:
		var part := _part(q, images)
		if part.is_empty() or ids.has(part["id"]):
			return {}
		ids[part["id"]] = true
		parts.append(part)
	for part in parts:
		if part["parent"] != "" and not ids.has(part["parent"]):
			return {}
	if not parts.any(func(p): return p["type"] == "body"):
		return {}
	pet["parts"] = parts
	var outfit := []
	if typeof(src.get("outfit")) == TYPE_ARRAY:
		for o in src["outfit"].slice(0, 8):
			if typeof(o) == TYPE_DICTIONARY and typeof(o.get("item")) == TYPE_STRING and Items.is_catalog(o["item"]) \
					and ids.has(str(o.get("parent", ""))):
				outfit.append({"item": o["item"], "parent": str(o["parent"]), "pos": _v2(o.get("pos")),
					"rot": _num(o.get("rot")), "scale": clampf(_num(o.get("scale"), 1.0), 0.05, 8.0),
					"flip": o.get("flip") == true, "behind": o.get("behind") == true})
	pet["outfit"] = outfit
	pet["needs"] = {"food": 1.0, "fun": 1.0, "clean": 1.0, "energy": 1.0}
	pet["_img"] = images
	pet["_tex"] = {}
	return pet


static func _part(q, images: Dictionary) -> Dictionary:
	if typeof(q) != TYPE_DICTIONARY:
		return {}
	var type = q.get("type")
	if typeof(type) != TYPE_STRING or not (type == "body" or PartTypes.TYPES.has(type)):
		return {}
	var image := _file(q.get("image"))
	if image == "" or not images.has(image):
		return {}
	var part := {"id": _token(q.get("id")), "type": type, "parent": _token(q.get("parent")),
		"image": image, "pos": _v2(q.get("pos")), "pivot": _v2(q.get("pivot")), "rot": _num(q.get("rot")),
		"scale": clampf(_num(q.get("scale"), 1.0), 0.05, 8.0), "draw_scale": clampf(_num(q.get("draw_scale"), 1.0), 0.05, 8.0),
		"flip": q.get("flip") == true, "behind": q.get("behind") == true,
		"pair": clampi(int(_num(q.get("pair"))), 0, 8), "side": clampi(int(_num(q.get("side"))), 0, 1)}
	if part["id"] == "":
		return {}
	var shine_image := _file(q.get("shine_image"))
	if shine_image != "" and images.has(shine_image) and Shiny.MODES.has(q.get("shine")):
		part["shine_image"] = shine_image
		part["shine"] = q["shine"]
	return part


static func _voice(v) -> Dictionary:
	var out := Voice.DEFAULT.duplicate()
	if typeof(v) != TYPE_DICTIONARY:
		return out
	if typeof(v.get("base")) == TYPE_STRING and Voice.BASES.has(v["base"]):
		out["base"] = v["base"]
	for k in Voice.DEFAULT:
		if k == "base":
			continue
		if typeof(Voice.DEFAULT[k]) == TYPE_BOOL:
			out[k] = v.get(k) == true
		else:
			out[k] = clampf(_num(v.get(k), float(Voice.DEFAULT[k])), -24.0, 24.0)
	return out


# --- Checks for one value at a time ---------------------------------------------------------

static func _num(x, fallback := 0.0) -> float:
	if typeof(x) == TYPE_FLOAT or typeof(x) == TYPE_INT:
		var f := float(x)
		if is_finite(f) and absf(f) < 100000.0:
			return f
	return fallback


static func _v2(x) -> Array:
	if typeof(x) == TYPE_ARRAY and x.size() == 2:
		return [_num(x[0]), _num(x[1])]
	return [0.0, 0.0]


## Letters, digits, _ and - only, short: ids and file stems ("" for anything else, or empty).
static func _token(x) -> String:
	if typeof(x) != TYPE_STRING:
		return ""
	var s: String = x
	if s.length() > 64:
		return ""
	for ch in s:
		if not (ch.is_valid_identifier() or ch.is_valid_int() or ch == "-" or ch == "_"):
			return ""
	return s


## A drawing's file name: a token and ".png".
static func _file(x) -> String:
	if typeof(x) != TYPE_STRING or not str(x).ends_with(".png"):
		return ""
	var stem := _token(str(x).trim_suffix(".png"))
	return stem + ".png" if stem != "" else ""


static func _hex(x) -> String:
	if typeof(x) != TYPE_STRING or str(x).length() != 16 or not str(x).is_valid_hex_number():
		return ""
	return str(x).to_lower()


## Printable text, at most `most` characters.
static func _text(x, most: int) -> String:
	if typeof(x) != TYPE_STRING:
		return ""
	var out := ""
	for ch in str(x):
		if ch.unicode_at(0) >= 32 and ch.unicode_at(0) != 127:
			out += ch
	return out.strip_edges().substr(0, most)


static func _u32(n: int) -> PackedByteArray:
	var b := PackedByteArray()
	b.resize(4)
	b.encode_u32(0, n)
	return b
