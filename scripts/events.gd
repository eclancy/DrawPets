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

const KINDS := {
	"dash": {"name": "Dash Race", "stat": "speed", "game": "track",
		"how": "Tap when the ring turns GREEN for a burst of speed!"},
	"hurdles": {"name": "Hop Hurdles", "stat": "agility", "game": "track",
		"how": "Tap to JUMP each hurdle. Don't jump too early!"},
	"marathon": {"name": "Big Marathon", "stat": "stamina", "game": "track",
		"how": "Tap along with the drum - steady, not too fast!"},
	"tug": {"name": "Tug-of-War Cup", "stat": "strength", "game": "tug",
		"how": "Tap HEAVE! when the ring is at its biggest. Win three rounds!"},
	"tricks": {"name": "Trick Show", "stat": "smarts", "game": "tricks",
		"how": "Watch the trick cards, then tap them back in the same order!"},
	"style": {"name": "Style Show", "stat": "charm", "game": "style",
		"how": "Dress for the theme, then tap to POSE when you're in the spotlight!"},
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
