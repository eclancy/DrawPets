class_name FunDays
extends RefCounted
## Beginner's calendar (.ai/competitions.md): a fun day every day, worked out from the date like
## the competition calendar (Events), but nobody is scored, nobody is ranked and there are no
## rivals - friendly pets come as guests and an audience. Everyone who joins in gets a rosette.
##   Sun  Pet Party       Mon  Treasure Hunt    Tue  Talent Show    Wed  Spa Day
##   Thu  Costume Parade  Fri  Dance Party      Sat  Photo Day

const KINDS := {
	"party": {"name": "Pet Party", "icon": "icon_heart", "how": "Two friends come to play at your home!"},
	"treasure": {"name": "Treasure Hunt", "icon": "prop_present", "how": "A walk with extra glints to dig up!"},
	"talent": {"name": "Talent Show", "icon": "icon_tricks", "how": "Show off its tricks - everybody cheers!"},
	"spa": {"name": "Spa Day", "icon": "icon_bath", "how": "A bubbly bath, just for fun."},
	"parade": {"name": "Costume Parade", "icon": "icon_wardrobe", "how": "Dress up and parade down the catwalk!"},
	"dance": {"name": "Dance Party", "icon": "trick_dance", "how": "Everybody dance!"},
	"photo": {"name": "Photo Day", "icon": "icon_camera", "how": "Take a photo of your pets for the album."},
}
const WEEK := ["party", "treasure", "talent", "spa", "parade", "dance", "photo"]


static func today() -> Dictionary:
	return for_unix(Time.get_unix_time_from_system())


## The fun day on a day: {kind, key (the date), weekday, day, month, year}.
static func for_unix(unix: float) -> Dictionary:
	var ev := Events.for_unix(unix)
	ev["kind"] = WEEK[int(ev["weekday"])]
	return ev


static func info(kind: String) -> Dictionary:
	return KINDS.get(kind, KINDS["party"])


static func joined(profile: Profile, key: String) -> bool:
	return profile.data.get("fun_days", {}).has(key)


## Joined in today's fun day: a rosette on the calendar, and stars once a day.
static func join(game: GameRoot, kind: String) -> void:
	var ev := today()
	if ev["kind"] != kind or joined(game.profile, ev["key"]):
		return
	var days: Dictionary = game.profile.data.get("fun_days", {})
	days[ev["key"]] = kind
	game.profile.data["fun_days"] = days
	Sounds.play("ribbon")
	game.reward_daily("fun_day", 1, 3, "A rosette for joining the %s!" % info(kind)["name"])
	game.profile.save()


## The home a pet lives in.
static func home_of(profile: Profile, pet_id: String) -> Dictionary:
	for h in profile.homes():
		if h["pets"].has(pet_id):
			return h
	return {}


## Friendly pets for a party or an audience - the same ones all day.
static func friends(count: int) -> Array:
	var ids := Rivals.ids()
	var start := absi(hash(today()["key"])) % ids.size()
	var out := []
	for i in count:
		out.append(Rivals.build(ids[(start + i * 3) % ids.size()]))
	return out
