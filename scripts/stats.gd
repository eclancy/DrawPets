class_name Stats
extends RefCounted
## A pet's six stats, trained by playing with it (.ai/pet-life.md):
##   speed    - fetch, chasing, races             strength - tug of war, heavy toys, climbing
##   agility  - catching, bouncing, hurdles       stamina  - long play, chewing, splashing
##   smarts   - puzzle toys, hiding, tricks       charm    - petting, dressing up, dancing
##
## Each is 0-100 and shows as a level 1-10. Training has diminishing returns, so the first
## levels come quickly and the last ones take real play. A stat left untrained for a couple
## of days slowly drops - but never below 75% of its best, and never below where it started.
## Gentle: you can lose a bit of an edge, never the pet's progress.

const LIST := ["speed", "strength", "agility", "stamina", "smarts", "charm"]
const INFO := {
	"speed": {"label": "Speed", "icon": "icon_speed", "how": "fetch, chasing, races"},
	"strength": {"label": "Strength", "icon": "icon_strength", "how": "tug of war, heavy toys, climbing"},
	"agility": {"label": "Agility", "icon": "icon_agility", "how": "catching, bouncing, hurdles"},
	"stamina": {"label": "Stamina", "icon": "icon_stamina", "how": "long play, chewing, splashing"},
	"smarts": {"label": "Smarts", "icon": "icon_smarts", "how": "puzzle toys, hiding, tricks"},
	"charm": {"label": "Charm", "icon": "icon_charm", "how": "petting, dressing up, dancing"},
}
const MAX := 100.0
const GRACE_DAYS := 2.0
const DECAY_PER_DAY := 2.5
const KEEP := 0.75

## Trust grows from love (hearts given by petting, feeding and playing). Thresholds for 1-5.
const TRUST_LOVE := [8, 25, 60, 120, 200]


static func label(stat: String) -> String:
	return INFO[stat]["label"]


static func level(value: float) -> int:
	return clampi(1 + int(value / 10.0), 1, 10)


static func trust(pet: Dictionary) -> int:
	var love := int(pet.get("love", 0))
	var t := 0
	for need in TRUST_LOVE:
		if love >= need:
			t += 1
	return t


## Starting stats. A pet's own choices - its size, its parts, its personality - give it a
## head start somewhere, never a cap: every stat can be trained to 100.
static func starting(pet: Dictionary) -> Dictionary:
	var s := {}
	for stat in LIST:
		s[stat] = 10.0
	var size: String = pet.get("size", "medium")
	var by_size := {"tiny": {"speed": 8, "agility": 6, "strength": -6}, "small": {"speed": 5, "agility": 3},
		"big": {"strength": 5, "stamina": 3, "agility": -2}, "huge": {"strength": 8, "stamina": 4, "speed": -3},
		"giant": {"strength": 12, "stamina": 4, "speed": -5, "agility": -4}}
	for stat in by_size.get(size, {}):
		s[stat] += by_size[size][stat]
	if PetBuilder.count_of(pet, "leg") >= 4:
		s["speed"] += 3
	if PetBuilder.has_type(pet, "wing"):
		s["agility"] += 4
	if PetBuilder.has_type(pet, "fin"):
		s["stamina"] += 3
	if PetBuilder.has_type(pet, "arm"):
		s["strength"] += 3
	if PetBuilder.count_of(pet, "eye") >= 3:
		s["smarts"] += 3
	for word in pet.get("personality", []):
		for stat in Words.PET.get(word, {}).get("train", {}):
			s[stat] += 3
	for stat in LIST:
		s[stat] = clampf(s[stat], 4.0, 30.0)
	return s


## Fills in stats on a pet that has none (a brand new pet).
static func ensure(pet: Dictionary) -> void:
	if pet.has("stats"):
		return
	var start := starting(pet)
	pet["stats"] = start.duplicate()
	pet["stat_base"] = start.duplicate()
	pet["stat_best"] = start.duplicate()
	var now := Time.get_unix_time_from_system()
	var trained := {}
	for stat in LIST:
		trained[stat] = now
	pet["trained"] = trained


static func value(pet: Dictionary, stat: String) -> float:
	return float(pet.get("stats", {}).get(stat, 10.0))


## How much faster this pet trains a stat right now: personality, plus a food boost if one is
## running. Shiny toys multiply the amount at the call site.
static func multiplier(pet: Dictionary, stat: String) -> float:
	var m := 1.0
	for word in pet.get("personality", []):
		m *= float(Words.PET.get(word, {}).get("train", {}).get(stat, 1.0))
	var boost: Dictionary = pet.get("boost", {})
	var boosted: String = boost.get("stat", "")
	if (boosted == stat or boosted == "all") and float(boost.get("until", 0)) > Time.get_unix_time_from_system():
		m *= 1.5
	return m


## Trains a stat. Returns how many levels it went up (usually 0).
static func train(pet: Dictionary, stat: String, amount: float) -> int:
	if stat == "" or not INFO.has(stat):
		return 0
	ensure(pet)
	var old := value(pet, stat)
	var gain := amount * multiplier(pet, stat) * maxf(0.08, 1.0 - old / 115.0)
	var now_v := minf(MAX, old + gain)
	pet["stats"][stat] = snappedf(now_v, 0.01)
	pet["stat_best"][stat] = maxf(float(pet["stat_best"].get(stat, 0.0)), now_v)
	pet["trained"][stat] = Time.get_unix_time_from_system()
	return level(now_v) - level(old)


## Applies days without training. A stat untouched past the grace period slips a little a day,
## down to its floor.
static func slip(pet: Dictionary, hours_away: float) -> void:
	ensure(pet)
	var now := Time.get_unix_time_from_system()
	for stat in LIST:
		var idle_days := (now - float(pet["trained"].get(stat, now))) / 86400.0
		if idle_days <= GRACE_DAYS:
			continue
		var days := minf(hours_away / 24.0, idle_days - GRACE_DAYS)
		var floor_v := maxf(float(pet["stat_base"].get(stat, 10.0)), float(pet["stat_best"].get(stat, 0.0)) * KEEP)
		pet["stats"][stat] = maxf(floor_v, value(pet, stat) - DECAY_PER_DAY * days)
