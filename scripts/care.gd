class_name Care
extends RefCounted
## The rhythm of looking after a pet (.ai/pet-life.md): feed it and play with it every day, and
## a bath day once a week. Shown on its card as a gentle "today" list - never a telling-off, and
## needs never fall below their floor (PetStore).

## The clean need at which it is bath day: it gets there about a week after a bath.
const BATH_DAY := 0.45


static func today() -> String:
	return Time.get_date_string_from_system()


static func fed(pet: Dictionary) -> void:
	pet["fed_on"] = today()


static func played(pet: Dictionary) -> void:
	pet["played_on"] = today()


static func bathed(pet: Dictionary) -> void:
	pet["bathed_on"] = today()
	PetStore.change_need(pet, "clean", 1.0)


static func is_bath_day(pet: Dictionary) -> bool:
	return float(pet.get("needs", {}).get("clean", 1.0)) <= BATH_DAY


## Whole days till bath day (0 when it is today).
static func days_to_bath(pet: Dictionary) -> int:
	var clean := float(pet.get("needs", {}).get("clean", 1.0))
	var per_day: float = PetStore.DRIFT_PER_HOUR["clean"] * 24.0
	return maxi(0, ceili((clean - BATH_DAY) / per_day))


## How today is going, for its card.
static func today_lines(pet: Dictionary) -> Array:
	var out := []
	out.append("Fed today - yum!" if pet.get("fed_on", "") == today() else "Hungry? Time for food!")
	out.append("Played today!" if pet.get("played_on", "") == today() else "Wants to play!")
	var days := days_to_bath(pet)
	if days <= 0:
		out.append("It's bath day!")
	else:
		out.append("Bath day in %d %s." % [days, "day" if days == 1 else "days"])
	return out
