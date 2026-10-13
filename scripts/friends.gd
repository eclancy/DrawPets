class_name Friends
extends RefCounted
## Friendships between pets (.ai/pet-life.md). Pets get to know each other, become friends, then
## best friends - quicker when they click. Never enemies: a pair that does not click just takes
## longer, and a shy pet warms up slowly (rule 3, gentle care).
##
## Who clicks comes only from what the kid chose (rule 4 - never the drawing):
##   attitude  its personality words: playful pets like playful, silly and sporty ones; shy pets
##             like calm and cuddly ones and take their time with boisterous or bigger ones...
##   interest  the same favourite place, the same way to play, the same favourite food words -
##             and a favourite place that points at a kind (a beach lover likes swimmers)
##   kind      from the parts it was given: fliers (wings), swimmers (fins), wrigglers (no legs)
##             and walkers
##
## Kept in pet["friends"]: other pet's id -> {"f": 0-100, "name", "day", "today"} - on both pets.
## Party guests (the rival pets) can be friends too; only the family's pets are saved.

## [points, name, hearts]: getting to know, friends, best friends.
const LEVELS := [[0.0, "", 0], [15.0, "getting to know", 1], [45.0, "friends", 2], [80.0, "best friends", 3]]
## The most a pair's friendship grows in a day: best friends take a few days.
const PER_DAY := 22.0

## What each attitude warms to: other personality words, kinds of pet, coats and sizes.
const ATTITUDES := {
	"playful": {"likes": ["playful", "silly", "sporty"]},
	"sleepy": {"likes": ["sleepy", "calm", "cuddly"]},
	"cuddly": {"likes": ["cuddly", "shy", "sleepy"], "coats": ["fur", "feathers"]},
	"brave": {"likes": ["shy", "brave"], "bigger": true},
	"shy": {"likes": ["calm", "shy", "cuddly"], "slow_with": ["playful", "sporty", "silly"]},
	"curious": {"likes": ["curious", "clever"], "different": true},
	"hungry": {"likes": ["hungry"], "food": true},
	"sporty": {"likes": ["sporty", "playful", "brave"]},
	"clever": {"likes": ["clever", "curious", "calm"]},
	"silly": {"likes": ["silly", "playful"]},
	"fancy": {"likes": ["fancy"], "dressed": true},
	"calm": {"likes": ["calm", "sleepy", "shy"]},
}
const KIND_NAMES := {"flier": "fliers", "swimmer": "swimmers", "wriggler": "wrigglers", "walker": "walkers"}
## A favourite place that points at a kind of pet.
const PLACE_KINDS := {"wet": "swimmer", "high": "flier"}
const PLAY_NAMES := {"fetch": "fetch", "tug": "tug of war", "cuddle": "cuddles", "chew": "a good chew",
	"squeak": "squeaky toys", "puzzle": "puzzles", "push": "pushing big things"}
const SIZE_ORDER := ["tiny", "small", "medium", "big", "huge", "giant"]


## What kind of pet it is, from its parts.
static func kind_of(pet: Dictionary) -> String:
	if PetBuilder.has_type(pet, "wing"):
		return "flier"
	if PetBuilder.has_type(pet, "fin"):
		return "swimmer"
	if not PetBuilder.has_type(pet, "leg") and not PetBuilder.has_type(pet, "tentacle"):
		return "wriggler"
	return "walker"


## How much `a` takes to `b`: {score 0.4-2.0 (1 is ordinary), reasons, slow}. One way round - a
## shy pet can adore a calm one that hardly notices it.
static func liking(a: Dictionary, b: Dictionary) -> Dictionary:
	var score := 1.0
	var reasons := []
	var slow := false
	var name: String = a.get("name", "It")
	var a_words: Array = a.get("personality", [])
	var b_words: Array = b.get("personality", [])
	for w in a_words:
		var att: Dictionary = ATTITUDES.get(w, {})
		for bw in b_words:
			if bw in att.get("likes", []):
				score += 0.25
				reasons.append("both %s" % w if bw == w else "%s likes %s pets" % [name, bw])
			if bw in att.get("slow_with", []):
				score -= 0.3
				slow = true
				reasons.append("%s is shy with %s pets - give it time" % [name, bw])
		if att.get("different", false) and kind_of(a) != kind_of(b):
			score += 0.2
			reasons.append("%s is curious about %s" % [name, KIND_NAMES[kind_of(b)]])
		if BathDay.coat(b) in att.get("coats", []):
			score += 0.15
			reasons.append("%s loves soft, fluffy pets" % name)
		if att.get("bigger", false) and _size(b) > _size(a):
			score += 0.15
			reasons.append("%s likes big pets" % name)
		if att.get("dressed", false) and not b.get("outfit", []).is_empty():
			score += 0.15
			reasons.append("%s likes a pet who dresses up" % name)
		if att.get("food", false) and _shares_food(a, b):
			score += 0.2
			reasons.append("snack buddies")
	if a_words.has("shy") and _size(b) > _size(a) + 1:
		score -= 0.2
		slow = true
		reasons.append("%s is shy around big pets" % name)
	# Interests.
	var a_place: String = a.get("place", "")
	if a_place != "" and a_place == b.get("place", ""):
		score += 0.25
		reasons.append("both dream of %s" % Places.display_name(a_place))
	for tag in Places.tags(a_place):
		if PLACE_KINDS.get(tag, "") == kind_of(b) and kind_of(a) != kind_of(b):
			score += 0.15
			reasons.append("%s loves %s" % [name, KIND_NAMES[kind_of(b)]])
			break
	var a_play := _play(a)
	if a_play != "" and a_play == _play(b):
		score += 0.2
		reasons.append("both love %s" % PLAY_NAMES.get(a_play, a_play))
	if not a_words.has("hungry") and _shares_food(a, b):
		score += 0.1
		reasons.append("both like the same snacks")
	# Once each - and "Zorp likes playful pets" says nothing "both playful" has not.
	var uniq := []
	for r in reasons:
		var said := false
		for w in ATTITUDES:
			if r == "%s likes %s pets" % [name, w] and reasons.has("both " + w):
				said = true
		if not uniq.has(r) and not said:
			uniq.append(r)
	return {"score": clampf(score, 0.4, 2.0), "reasons": uniq, "slow": slow}


## How well two pets get on, both ways round: 0.4-2.0, 1 is ordinary.
static func fit(a: Dictionary, b: Dictionary) -> float:
	return (float(liking(a, b)["score"]) + float(liking(b, a)["score"])) / 2.0


## The best reasons two pets get on, both ways round, for hints and pages. `shy_first` puts the
## gentle reason one of them is slow to warm up first - for when they have just met.
static func why(a: Dictionary, b: Dictionary, most := 2, shy_first := false) -> Array:
	var all: Array = liking(a, b)["reasons"].duplicate()
	for x in liking(b, a)["reasons"]:
		if not all.has(x):
			all.append(x)
	var shy := all.filter(func(x): return "shy" in str(x))
	var warm := all.filter(func(x): return not "shy" in str(x))
	return (shy + warm if shy_first else warm + shy).slice(0, most)


static func points(a: Dictionary, b_id: String) -> float:
	return float(a.get("friends", {}).get(b_id, {}).get("f", 0.0))


static func has_met(a: Dictionary, b_id: String) -> bool:
	return a.get("friends", {}).has(b_id)


## 0 strangers, 1 getting to know, 2 friends, 3 best friends.
static func level(f: float) -> int:
	var lv := 0
	for i in LEVELS.size():
		if f >= float(LEVELS[i][0]):
			lv = i
	return lv


static func level_name(lv: int) -> String:
	return LEVELS[clampi(lv, 0, LEVELS.size() - 1)][1]


## Time together: friendship grows by `amount`, times how well they get on, up to PER_DAY a
## day. Returns the new level if they just reached one (2 friends, 3 best friends), else 0.
static func grow(a: Dictionary, b: Dictionary, amount: float) -> int:
	var before := level(points(a, b["id"]))
	var gain := amount * fit(a, b)
	var today := Time.get_date_string_from_system()
	var entry := _entry(a, b)
	if entry["day"] != today:
		entry["day"] = today
		entry["today"] = 0.0
	gain = minf(gain, PER_DAY - float(entry["today"]))
	if gain <= 0.0:
		return 0
	for pair in [[a, b], [b, a]]:
		var e := _entry(pair[0], pair[1])
		e["f"] = minf(100.0, float(e["f"]) + gain)
		e["day"] = today
		e["today"] = float(e.get("today", 0.0)) + gain
		e["name"] = pair[1].get("name", "")
	var after := level(points(a, b["id"]))
	return after if after > before and after >= 2 else 0


## Meeting for the first time: they know of each other now (a point of friendship).
static func meet(a: Dictionary, b: Dictionary) -> void:
	for pair in [[a, b], [b, a]]:
		var e := _entry(pair[0], pair[1])
		e["f"] = maxf(float(e["f"]), 1.0)
		e["name"] = pair[1].get("name", "")


static func _entry(a: Dictionary, b: Dictionary) -> Dictionary:
	var all: Dictionary = a.get("friends", {})
	if not all.has(b["id"]):
		all[b["id"]] = {"f": 0.0, "name": b.get("name", ""), "day": "", "today": 0.0}
	a["friends"] = all
	return all[b["id"]]


## Its friends, closest first: [{id, name, f, level}] - only those it has got to know.
static func list(pet: Dictionary) -> Array:
	var out := []
	var all: Dictionary = pet.get("friends", {})
	for id in all:
		var f := float(all[id].get("f", 0.0))
		if level(f) >= 1:
			out.append({"id": id, "name": all[id].get("name", "?"), "f": f, "level": level(f)})
	out.sort_custom(func(x, y): return x["f"] > y["f"])
	return out


## "Best friends with Pip. Friends with Biscuit." - for its card.
static func summary(pet: Dictionary, most := 3) -> String:
	var groups := {3: [], 2: [], 1: []}
	for f in list(pet).slice(0, most):
		groups[int(f["level"])].append(f["name"])
	var bits := []
	if not groups[3].is_empty():
		bits.append("Best friends with %s." % " and ".join(groups[3]))
	if not groups[2].is_empty():
		bits.append("Friends with %s." % " and ".join(groups[2]))
	if not groups[1].is_empty():
		bits.append("Getting to know %s." % " and ".join(groups[1]))
	return " ".join(bits)


## "both playful" -> "Both playful" (String.capitalize would make it "Both Playful").
static func sentence(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1) if s != "" else s


static func _size(pet: Dictionary) -> int:
	return SIZE_ORDER.find(pet.get("size", "medium"))


static func _play(pet: Dictionary) -> String:
	var toy := Items.get_item(str(pet.get("toy", {}).get("item", "")))
	return "" if toy.is_empty() else Words.toy_play(toy.get("words", []))


static func _shares_food(a: Dictionary, b: Dictionary) -> bool:
	var fa := Items.get_item(str(a.get("food", {}).get("item", "")))
	var fb := Items.get_item(str(b.get("food", {}).get("item", "")))
	if fa.is_empty() or fb.is_empty():
		return false
	for w in fa.get("words", []):
		if fb.get("words", []).has(w):
			return true
	return false
