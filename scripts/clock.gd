class_name Clock
extends RefCounted
## The time of day, from the device's own clock (.ai/places.md): day, a warm dusk in the evening,
## a pale-lavender night - never dark (.ai/art-direction.md) - and a dawn. There is no day/night
## switch; `--hour=N` (and the demo) can pretend, to see it.

## The night sky and the tint over a place at night. Light: creatures own black.
const NIGHT_SKY := [Color("#c2b6e6"), Color("#e6dff5")]
const DUSK_SKY := [Color("#f2bcc8"), Color("#fde2c6")]
const NIGHT_TINT := Color(0.84, 0.81, 0.97)
const DUSK_TINT := Color(1.0, 0.9, 0.86)
const GLOW := Color("#ffe9a3")

## -1 follows the device clock; otherwise the hour it pretends it is (0-24).
static var forced_hour := -1.0
static var _night := 0.0
static var _checked := -1000000


static func hour() -> float:
	if forced_hour >= 0.0:
		return forced_hour
	var t := Time.get_datetime_dict_from_system()
	return float(t["hour"]) + float(t["minute"]) / 60.0


## How much it is night: 0 all day, rising through dusk (7-8:30 pm), 1 all night, falling through
## dawn (6-7:30 am). Read at most once a second.
static func night() -> float:
	var now := Time.get_ticks_msec()
	if now - _checked < 1000 and forced_hour < 0.0:
		return _night
	_checked = now
	var h := hour()
	if h >= 20.5 or h < 6.0:
		_night = 1.0
	elif h >= 19.0:
		_night = smoothstep(19.0, 20.5, h)
	elif h < 7.5:
		_night = 1.0 - smoothstep(6.0, 7.5, h)
	else:
		_night = 0.0
	return _night


static func is_night() -> bool:
	return night() >= 0.5


## Morning: dawn till eleven - when pets wake up and say good morning.
static func is_morning() -> bool:
	var h := hour()
	return h >= 6.0 and h < 11.0


## The pink-orange of a sunset or sunrise, for a night amount `n`: most halfway through dusk.
static func dusk(n: float) -> float:
	return sin(n * PI)


## A sky's two colours, `n` of the way to night.
static func sky(day: Array, n: float) -> Array:
	var d := dusk(n)
	var out := []
	for i in 2:
		out.append((day[i] as Color).lerp(NIGHT_SKY[i], n).lerp(DUSK_SKY[i], d * 0.55))
	return out


## Multiplied over everything in a place but its creatures (and things that glow), `n` of the way
## to night - lavender at night, warm at dusk, white by day.
static func tint(n := -1.0) -> Color:
	if n < 0.0:
		n = night()
	return Color.WHITE.lerp(NIGHT_TINT, n).lerp(DUSK_TINT, dusk(n) * 0.5)
