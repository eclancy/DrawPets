class_name Profile
extends RefCounted
## The family's save: gold stars, homes, what has been bought, today's counters, and medals.
## One per device, in user://profile.json. Pets stay in their own folders (PetStore); this is
## everything that belongs to the player rather than to one pet.
##
## Room to grow (.ai/shop.md): a family starts with two homes of two pets each. More room is
## bought with gold stars - but only once the pets they already have trust them enough. You
## earn a bigger family by looking after the one you have.

signal stars_changed(stars: int)

const PATH := "user://profile.json"
const START_HOMES := 2
const START_ROOMS := 2
const MAX_HOMES := 6
const MAX_ROOMS := 6

## Price and the trust every pet must have first, for the Nth extra home (0 = the third home).
const HOME_PRICES := [60, 120, 200, 300]
const HOME_TRUST := [2, 3, 3, 4]
## Price for the Nth extra room in one home (0 = its third room), and the trust its pets need.
const ROOM_PRICES := [30, 50, 80, 120]
const ROOM_TRUST := [1, 2, 3, 3]

## Volumes 0..1, and the microphone - off until a kid (or a grown-up) turns it on.
const DEFAULT_SETTINGS := {"music": 0.8, "sfx": 1.0, "voice": 1.0, "ambience": 0.8, "mic": false}

var data := {}


static func load_or_new() -> Profile:
	var p := Profile.new()
	var text := FileAccess.get_file_as_string(PATH) if FileAccess.file_exists(PATH) else ""
	var parsed = JSON.parse_string(text) if text != "" else null
	p.data = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
	for key in ["stars", "home_slots", "homes", "owned", "items", "places", "results", "daily",
			"once", "settings", "photos"]:
		if not p.data.has(key):
			p.data[key] = {"stars": 0, "home_slots": START_HOMES, "homes": [], "owned": {},
				"items": [], "places": [], "results": {}, "daily": {}, "once": {},
				"settings": DEFAULT_SETTINGS.duplicate(), "photos": []}[key]
	for k in DEFAULT_SETTINGS:
		if not p.data["settings"].has(k):
			p.data["settings"][k] = DEFAULT_SETTINGS[k]
	return p


func settings() -> Dictionary:
	return data["settings"]


func save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()


# --- Stars -----------------------------------------------------------------------------------

func stars() -> int:
	return int(data["stars"])


func add_stars(n: int) -> void:
	data["stars"] = stars() + n
	save()
	stars_changed.emit(stars())


func spend(n: int) -> bool:
	if stars() < n:
		return false
	data["stars"] = stars() - n
	save()
	stars_changed.emit(stars())
	return true


## Today's counters, reset when the date changes.
func today() -> Dictionary:
	var date := Time.get_date_string_from_system()
	if data["daily"].get("date", "") != date:
		data["daily"] = {"date": date}
	return data["daily"]


## Counts something that happened today; true while it is still under `cap` - the reward
## rule for repeatable things (only the first three feeds a day pay out).
func count_today(key: String, cap: int) -> bool:
	var d := today()
	d[key] = int(d.get(key, 0)) + 1
	return int(d[key]) <= cap


## True the first time ever it is called with `key`.
func first_time(key: String) -> bool:
	if data["once"].has(key):
		return false
	data["once"][key] = true
	return true


# --- Things owned ----------------------------------------------------------------------------

func owned(id: String) -> int:
	return int(data["owned"].get(id, 0))


func give(id: String, n := 1) -> void:
	data["owned"][id] = owned(id) + n
	save()


## Uses up one of a consumable. False if there were none.
func use_up(id: String) -> bool:
	if owned(id) <= 0:
		return false
	data["owned"][id] = owned(id) - 1
	save()
	return true


func drawn_items() -> Array:
	return data["items"]


func add_drawn_item(id: String) -> void:
	data["items"].append(id)
	save()


func place_unlocked(id: String) -> bool:
	return not Places.get_place(id).get("special", false) or data["places"].has(id)


func unlock_place(id: String) -> void:
	if not data["places"].has(id):
		data["places"].append(id)
	save()


# --- Homes -----------------------------------------------------------------------------------

func homes() -> Array:
	return data["homes"]


func home(id: String) -> Dictionary:
	for h in homes():
		if h["id"] == id:
			return h
	return {}


func free_plots() -> int:
	return home_slots() - homes().size()


## A home's name, falling back to its place for homes from before homes had names.
static func home_name(h: Dictionary) -> String:
	var n: String = h.get("name", "")
	return n if n != "" else Places.display_name(h.get("place", "meadow"))


func adopted() -> Array:
	if not data.has("adopted"):
		data["adopted"] = []
	return data["adopted"]


func home_slots() -> int:
	return int(data["home_slots"])


## Builds a home on a free plot - a ready-built one from Homes.PREMADE, with the kid's name for it.
func build_home(premade: String, home_name: String) -> Dictionary:
	var info := Homes.info(premade)
	var h := add_home(info.get("place", "meadow"), home_name)
	h["premade"] = premade
	h["items"] = Homes.starting_items(premade)
	save()
	return h


func add_home(place: String, home_name := "") -> Dictionary:
	var h := {"id": "home_%d" % (homes().size() + 1 + randi() % 1000), "place": place,
		"name": home_name if home_name != "" else Places.display_name(place),
		"rooms": START_ROOMS, "pets": [], "items": []}
	homes().append(h)
	save()
	return h


func has_room(h: Dictionary) -> bool:
	return h["pets"].size() < int(h["rooms"])


## Somewhere a new pet could live: a home with a free room, or a free plot for a new home.
func can_add_pet() -> bool:
	if homes().size() < home_slots():
		return true
	for h in homes():
		if has_room(h):
			return true
	return false


func move_in(pet: Dictionary, h: Dictionary) -> void:
	for other in homes():
		other["pets"].erase(pet["id"])
	h["pets"].append(pet["id"])
	pet["home"] = h["id"]
	save()


func pet_count() -> int:
	var n := 0
	for h in homes():
		n += h["pets"].size()
	return n


# --- Room to grow: prices and trust gates ----------------------------------------------------

func next_home_price() -> int:
	var bought := home_slots() - START_HOMES
	return HOME_PRICES[mini(bought, HOME_PRICES.size() - 1)] if home_slots() < MAX_HOMES else -1


func next_home_trust() -> int:
	return HOME_TRUST[mini(home_slots() - START_HOMES, HOME_TRUST.size() - 1)]


func next_room_price(h: Dictionary) -> int:
	var extra := int(h["rooms"]) - START_ROOMS
	return ROOM_PRICES[mini(extra, ROOM_PRICES.size() - 1)] if int(h["rooms"]) < MAX_ROOMS else -1


func next_room_trust(h: Dictionary) -> int:
	return ROOM_TRUST[mini(int(h["rooms"]) - START_ROOMS, ROOM_TRUST.size() - 1)]


## Why more room cannot be bought yet, or "" if it can. `pets` are the pets that must trust
## the kid first: every pet for a new home, that home's pets for a new room.
static func trust_gate(pets: Array, need: int) -> String:
	if pets.is_empty():
		return "Get your first pet settled in first!"
	var behind := []
	for pet in pets:
		if Stats.trust(pet) < need:
			behind.append(pet["name"])
	if behind.is_empty():
		return ""
	return "%s need%s %d trust hearts first" % [", ".join(behind), "s" if behind.size() == 1 else "",
		need]
