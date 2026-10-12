class_name Journal
extends RefCounted
## A pet's journal (.ai/pet-life.md) - it writes itself. Big moments go in as they happen: a
## first fetch, a first bath, a trick learned, a cup won, a present found, a new home - and every
## photo the pet is in. Kept in pet["journal"] as [{"t": unix time, "text": "...", "photo": id}],
## newest last. Like everything a kid makes, it stays on the device.

## The most entries kept: the oldest go first (but never the day it was drawn, which is made up
## from pet["created"] each time).
const MAX := 150


## Writes a line in the journal, with a photo if there is one.
static func add(pet: Dictionary, text: String, photo := "") -> void:
	var entries: Array = pet.get("journal", [])
	entries.append({"t": int(Time.get_unix_time_from_system()), "text": text, "photo": photo})
	while entries.size() > MAX:
		entries.remove_at(0)
	pet["journal"] = entries


## Writes a line only the first time `key` happens to this pet - its first fetch, its first bath.
static func add_once(pet: Dictionary, key: String, text: String) -> void:
	var once: Array = pet.get("journal_once", [])
	if once.has(key):
		return
	once.append(key)
	pet["journal_once"] = once
	add(pet, text)


## Every entry, oldest first, starting with the day it was drawn (or adopted).
static func entries(pet: Dictionary) -> Array:
	var first := "%s was drawn!" % pet.get("name", "It")
	if pet.has("adopted_from"):
		first = "%s was adopted!" % pet.get("name", "It")
	var out := [{"t": int(pet.get("created", 0)), "text": first, "photo": ""}]
	out.append_array(pet.get("journal", []))
	return out


## "Mon 12 Oct" - short enough for a page, and the day of the week a kid remembers.
static func date_text(t: int) -> String:
	if t <= 0:
		return ""
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))  # minutes from UTC
	var d := Time.get_date_dict_from_unix_time(t + bias * 60)
	var days := ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var months := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	return "%s %d %s" % [days[int(d["weekday"])], int(d["day"]), months[int(d["month"]) - 1]]
