class_name Words
extends RefCounted
## Every describing word a kid can pick, and what it DOES. Kids never type a description:
## they tap a few of these, and the words become behaviour - a "stretchy" toy is for tug of
## war, a "cozy" bed is where it naps, a "hot" place is where a "warm"-loving pet is happiest.
##
## The game never reads a drawing; it reads these. That is how a toy drawn as three wobbly
## lines can still bounce exactly the way the kid meant it to (.ai/pet-life.md).
##
## Each word: hint (shown under it), and the stat it trains or boosts where that applies.

## How a toy flies and how the pet plays with it. The stat is what playing with it trains.
const TOY := {
	"bouncy": {"hint": "bounces high", "stat": "agility"},
	"stretchy": {"hint": "for tug of war", "stat": "strength"},
	"floaty": {"hint": "glides a long way", "stat": "agility"},
	"rolly": {"hint": "rolls and rolls", "stat": "speed"},
	"squeaky": {"hint": "tap it to squeak", "stat": "charm"},
	"soft": {"hint": "for cuddles", "stat": "charm"},
	"heavy": {"hint": "hard work to push", "stat": "strength"},
	"chewy": {"hint": "a long happy chew", "stat": "stamina"},
	"puzzly": {"hint": "a treat hides inside", "stat": "smarts"},
	"spinny": {"hint": "spins in the air", "stat": "agility"},
	"glowy": {"hint": "glows in the dark", "stat": ""},
}

## What a toy is FOR. The first of these words a toy has decides how a pet plays with it, so a
## rope (stretchy, chewy) is for tug of war and a bouncy chewy thing is fetched, then chewed. A
## toy with none of them - only glowy, say - is a fetch toy.
##   fetch   flick it: everyone chases, the catcher brings it back and holds it out to you
##   tug     hold it out: a pet grabs the other end - pull, let go, pull, in time
##   cuddle  put it down: a pet hugs it, then naps with it on something cozy
##   chew    put it down: a pet lies down with it for a long chew
##   squeak  put it down and tap it: squeak! and the pets pounce on it
##   puzzle  put it down: a pet noses it about (a tap rolls it too) until the treat falls out
##   push    put it down: a pet leans into it and shoves it along
const TOY_PLAY := [["stretchy", "tug"], ["soft", "cuddle"], ["puzzly", "puzzle"], ["heavy", "push"],
	["bouncy", "fetch"], ["rolly", "fetch"], ["floaty", "fetch"], ["spinny", "fetch"],
	["chewy", "chew"], ["squeaky", "squeak"]]

## Shown when a toy comes out of the drawer, so a kid knows what to do with it. Each says only a
## move that works (PlaceScreen): flick and let go, hold it still, put it down, tap it.
const PLAY_HINT := {
	"fetch": "Flick it up and let go - fetch!",
	"tug": "Hold it out - a pet will grab the other end!",
	"cuddle": "Put it down - someone wants a cuddle.",
	"chew": "Put it down for a good long chew.",
	"squeak": "Put it down, then tap it to squeak!",
	"puzzle": "Put it down - tap it to roll the treat out!",
	"push": "Put it down - who's strong enough to push it?",
}

## What a food is like. Eating one gives a training boost to its stat for a while, and every
## pet has favourite words (from its favourite food) that make a food a treat.
const FOOD := {
	"sweet": {"hint": "a sugary treat", "stat": "charm"},
	"crunchy": {"hint": "crunch crunch", "stat": "strength"},
	"juicy": {"hint": "drippy and fresh", "stat": "stamina"},
	"spicy": {"hint": "zoom! hot hot", "stat": "speed"},
	"healthy": {"hint": "good for it", "stat": "stamina"},
	"fishy": {"hint": "brain food", "stat": "smarts"},
	"meaty": {"hint": "big and filling", "stat": "strength"},
	"buggy": {"hint": "wriggly snack", "stat": "agility"},
	"cold": {"hint": "brr, refreshing", "stat": "speed"},
	"chewy": {"hint": "takes a while", "stat": "stamina"},
	"weird": {"hint": "who knows?!", "stat": "smarts"},
}

## Furniture and scenery in a place. These decide what pets do with it.
const FURNITURE := {
	"cozy": {"hint": "naps on it", "stat": ""},
	"bouncy": {"hint": "jumps on it", "stat": "agility"},
	"climbable": {"hint": "climbs up top", "stat": "strength"},
	"hidey": {"hint": "hides in it", "stat": "smarts"},
	"splashy": {"hint": "splashes in it", "stat": "stamina"},
	"shady": {"hint": "cool spot in the heat", "stat": ""},
	"warm": {"hint": "warm spot in the cold", "stat": ""},
	"musical": {"hint": "dances to it", "stat": "charm"},
	"tasty": {"hint": "drops a snack every day", "stat": ""},
	"scratchy": {"hint": "scratches it", "stat": "strength"},
	"slidey": {"hint": "slides down it", "stat": "speed"},
	"fancy": {"hint": "feels fancy near it", "stat": "charm"},
	"glowy": {"hint": "lights up at night", "stat": ""},
}

## Clothes. A Style Show has a theme word; clothes with that word score.
const CLOTHING := {
	"fancy": {"hint": "very posh"}, "cozy": {"hint": "snug"}, "sporty": {"hint": "ready to win"},
	"silly": {"hint": "ha ha"}, "spooky": {"hint": "ooooo"}, "cool": {"hint": "too cool"},
	"warm": {"hint": "for the cold"}, "brave": {"hint": "hero time"},
}

## A pet's personality - two picked when it is made. `train` multiplies how fast a stat grows.
const PET := {
	"playful": {"hint": "always wants to play", "train": {"agility": 1.2}},
	"sleepy": {"hint": "loves a nap", "train": {"stamina": 1.2}},
	"cuddly": {"hint": "loves being petted", "train": {"charm": 1.3}},
	"brave": {"hint": "never scared", "train": {"strength": 1.2}},
	"shy": {"hint": "trusts slowly, then lots", "train": {"smarts": 1.2}},
	"curious": {"hint": "explores everything", "train": {"smarts": 1.25}},
	"hungry": {"hint": "always snacking", "train": {"strength": 1.1}},
	"sporty": {"hint": "born to race", "train": {"speed": 1.25, "strength": 1.15}},
	"clever": {"hint": "learns fast", "train": {"smarts": 1.4}},
	"silly": {"hint": "a total goofball", "train": {"charm": 1.15, "agility": 1.1}},
	"fancy": {"hint": "loves dressing up", "train": {"charm": 1.4}},
	"calm": {"hint": "steady and chill", "train": {"stamina": 1.3}},
}

## What a place is like. Shown when picking a favourite place; a pet loves places that share
## words with its favourite one, and furniture is used by them ("shady" when it is hot).
const PLACE := {
	"hot": "", "warm": "", "cool": "", "cold": "", "outside": "", "inside": "", "wet": "",
	"dry": "", "sandy": "", "snowy": "", "grassy": "", "rocky": "", "high": "", "bouncy": "",
	"sweet": "", "fancy": "", "sparkly": "", "muddy": "",
}

const BY_CATEGORY := {"toy": TOY, "food": FOOD, "furniture": FURNITURE, "clothing": CLOTHING,
	"pet": PET}

## How many words a kid picks for each kind of thing.
const PICK := {"toy": 2, "food": 2, "furniture": 2, "clothing": 2, "pet": 2}


static func table(category: String) -> Dictionary:
	return BY_CATEGORY.get(category, {})


static func hint(category: String, word: String) -> String:
	var entry = table(category).get(word, {})
	return entry.get("hint", "") if entry is Dictionary else ""


static func stat_of(category: String, word: String) -> String:
	var entry = table(category).get(word, {})
	return entry.get("stat", "") if entry is Dictionary else ""


## How a toy with these words is played with: fetch, tug, cuddle, chew, squeak, puzzle or push.
static func toy_play(words: Array) -> String:
	for entry in TOY_PLAY:
		if words.has(entry[0]):
			return entry[1]
	return "fetch"


## The first stat any of these words trains, or "" if none do.
static func first_stat(category: String, words: Array) -> String:
	for w in words:
		var s := stat_of(category, w)
		if s != "":
			return s
	return ""
