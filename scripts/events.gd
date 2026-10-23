class_name Events
extends RefCounted
## The competition calendar (.ai/competitions.md). It is worked out from the date on this
## device - nothing is synced or downloaded - so every week has the same rhythm:
##   Sun  Fun Fair (practise any event)     Mon  Dash Race (speed)
##   Tue  Trick Show (smarts)               Wed  Tug-of-War Cup (strength)
##   Thu  Style Show (charm)                Fri  Hop Hurdles (agility)
##   Sat  Big Marathon (stamina)
## Every event runs four cups. A cup opens once a pet has reached its level in the event's
## stat, so a kid always has something they can enter and something to train towards.

## "how" is the one sentence that says how to play, and every game makes it true on screen.
## "tips" say the same in six words or fewer, beside the little moving picture on the intro
## (CompetitionScreen.HowPanel) while its hand does the move - one per step of the event. They
## are the very words the game's own hand says when it plays, so the kid meets them twice.
const KINDS := {
	"dash": {"name": "Dash Race", "stat": "speed", "game": "track",
		"how": "Tap when the ring lights up GREEN for a burst of speed!",
		"tips": ["TAP when it's GREEN!"]},
	"hurdles": {"name": "Hop Hurdles", "stat": "agility", "game": "track",
		"how": "Tap to JUMP when the mark in front of a hurdle lights up!",
		"tips": ["TAP to JUMP when it glows!"]},
	"marathon": {"name": "Big Marathon", "stat": "stamina", "game": "track",
		"how": "Tap with every BOOM of the drum - not too fast!",
		"tips": ["TAP on every BOOM!"]},
	"tug": {"name": "Tug-of-War Cup", "stat": "strength", "game": "tug",
		"how": "Slide the knot LEFT with the ring, then let it go RIGHT - in time! Win three rounds!",
		"tips": ["Pull left, let go, again!"]},
	"tricks": {"name": "Trick Show", "stat": "smarts", "game": "tricks",
		"how": "Watch your pet's trick cards, then TAP the same cards in the same order!",
		"tips": ["Watch the cards...", "TAP the same cards!"]},
	"style": {"name": "Style Show", "stat": "charm", "game": "style",
		"how": "Pick clothes with a STAR, then TAP when you're in the spotlight!",
		"tips": ["Tap clothes with a STAR!", "TAP when the light's on you!"]},
}
const WEEK := ["fair", "dash", "tricks", "tug", "style", "hurdles", "marathon"]
const TIERS := [
	{"name": "Sprout Cup", "level": 1, "rivals": [8.0, 22.0], "prize": [12, 8, 5, 2]},
	{"name": "Star Cup", "level": 3, "rivals": [22.0, 40.0], "prize": [20, 12, 8, 3]},
	{"name": "Gold Cup", "level": 5, "rivals": [40.0, 62.0], "prize": [30, 18, 12, 4]},
	{"name": "Rainbow Cup", "level": 7, "rivals": [62.0, 86.0], "prize": [45, 25, 15, 5]},
]
## Style Show themes - each one a clothing word, so the outfit can match it.
const THEMES := ["fancy", "cozy", "sporty", "silly", "spooky", "cool", "warm", "brave"]
const MONTHS := ["January", "February", "March", "April", "May", "June", "July", "August",
	"September", "October", "November", "December"]


static func today() -> Dictionary:
	return for_unix(Time.get_unix_time_from_system())


## The event on a day: {kind, key (the date), weekday, day, month, year}.
static func for_unix(unix: float) -> Dictionary:
	var d := Time.get_datetime_dict_from_unix_time(int(unix))
	var kind: String = WEEK[int(d["weekday"])]
	return {"kind": kind, "key": "%04d-%02d-%02d" % [d["year"], d["month"], d["day"]],
		"weekday": d["weekday"], "day": d["day"], "month": d["month"], "year": d["year"]}


static func info(kind: String) -> Dictionary:
	if kind == "fair":
		return {"name": "Fun Fair", "stat": "", "how": "Practise any event you like!"}
	return KINDS.get(kind, {})


static func icon(kind: String) -> String:
	var stat: String = info(kind).get("stat", "")
	return Stats.INFO[stat]["icon"] if stat != "" else "icon_trophy"


static func result_key(event: Dictionary, tier: int) -> String:
	return "%s_%s_%d" % [event["key"], event["kind"], tier]


## A number that is the same all day for one event - for picking rivals and themes.
static func seed_of(event: Dictionary, tier: int) -> int:
	return hash(result_key(event, tier))


static func theme(event: Dictionary) -> String:
	return THEMES[absi(hash(event["key"])) % THEMES.size()]


static func tier_open(pet: Dictionary, kind: String, tier: int) -> bool:
	var stat: String = info(kind).get("stat", "")
	if stat == "":
		return true
	return Stats.level(Stats.value(pet, stat)) >= int(TIERS[tier]["level"])
