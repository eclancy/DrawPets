class_name Family
extends RefCounted
## Who this family is to its friends (.ai/sharing.md): a random id and a made-up nickname - "the
## Mango family" - never a real name. Kept in the profile; made the first time it is needed.

## Nickname words: friendly, made up, and nothing like a real surname.
const NAMES := ["Mango", "Pickle", "Comet", "Bubble", "Maple", "Pebble", "Clover", "Noodle", "Sprout",
	"Waffle", "Jellybean", "Marble", "Pudding", "Sunny", "Biscuit", "Button", "Twinkle", "Puddle",
	"Acorn", "Cupcake", "Rainbow", "Starfish", "Teacup", "Zigzag"]


static func get_or_make(profile: Profile) -> Dictionary:
	var f: Dictionary = profile.data.get("family", {})
	if not f.has("id"):
		var bytes := Crypto.new().generate_random_bytes(8)
		f = {"id": bytes.hex_encode(), "name": NAMES[bytes[0] % NAMES.size()]}
		profile.data["family"] = f
		profile.save()
	return f


static func id(profile: Profile) -> String:
	return get_or_make(profile)["id"]


## "Mango" -> "the Mango family".
static func called(name: String) -> String:
	return "the %s family" % name
