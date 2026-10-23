class_name BathDay
extends RefCounted
## Bath day (.ai/pet-life.md) - once a week a pet goes to its bath spot (BathScreen) for the
## whole routine: its nails clipped, a wash, its teeth brushed and its coat groomed. Each step
## runs by itself and the kid can rub along to finish it faster.
##
## Which steps come from the parts the kid drew (no feet, hands or claws: no nails to clip) and
## from the coat the kid picked for it (pet["coat"]) - never from the drawing's pixels.

## The coats a kid can pick, and how each is groomed: [id, name, what it is like, step, tool,
## what the bath says when it is groomed, what to do - the step's one line, six words at most].
const COATS := [
	["fur", "Fluffy fur", "soft and furry", "Brush its fur", "kit_brush", "So fluffy!", "Brush its fur all over!"],
	["scales", "Shiny scales", "smooth and scaly", "Polish its scales", "bath_cloth", "So shiny!", "Polish its scales all over!"],
	["feathers", "Soft feathers", "fluffy and feathery", "Smooth its feathers", "bath_comb", "So smooth!", "Smooth its feathers all over!"],
	["skin", "Smooth skin", "bare and smooth", "Rub in some lotion", "bath_lotion", "So soft!", "Rub lotion all over!"],
]
## Where each place bathes - its watering hole. A home with a house has a bathroom instead.
const SPOTS := {
	"meadow": "pond", "forest": "pond", "jungle": "pond", "swamp": "pond", "candy": "pond",
	"castle": "tub", "moon": "tub", "beach": "rockpool", "ocean": "shell", "mountains": "spring",
	"volcano": "spring", "desert": "oasis", "cave": "crystal", "sky": "cloud",
}
## Parts with nails to clip.
const NAILS := ["foot", "hand", "claw"]
const SPOT_NAMES := {
	"tub": "the bathroom", "pond": "the pond", "rockpool": "the rock pool", "shell": "the giant shell",
	"spring": "the hot spring", "oasis": "the oasis", "crystal": "the crystal pool", "cloud": "the cloud puddle",
}


## "in the bathroom", "at the pond".
static func where(spot_id: String) -> String:
	return ("in " if spot_id == "tub" else "at ") + SPOT_NAMES.get(spot_id, "the pond")


## Its coat: the one the kid picked, or a guess from its parts for a pet made before there was a
## choice (fins: scales, wings: feathers, otherwise fur).
static func coat(pet: Dictionary) -> String:
	var c: String = pet.get("coat", "")
	if c != "":
		return c
	if PetBuilder.has_type(pet, "fin"):
		return "scales"
	if PetBuilder.has_type(pet, "wing"):
		return "feathers"
	return "fur"


static func coat_info(id: String) -> Array:
	for c in COATS:
		if c[0] == id:
			return c
	return COATS[0]


## Where this home bathes: "tub" if it has a house (a bathroom), else its place's watering hole.
static func spot(home: Dictionary) -> String:
	for entry in home.get("items", []):
		if Items.get_item(entry.get("item", "")).get("house", false):
			return "tub"
	return SPOTS.get(home.get("place", "meadow"), "pond")


## The steps for this pet, in order: [id, words, tool, what to do, what it says when the step is
## done]. "What to do" is the step's one line - the hand's caption, and the line at the bottom
## once there is no hand - so it is six words at most, one sentence, and says where to rub; the
## step's chip (its tool) already says which step it is.
static func steps(pet: Dictionary) -> Array:
	var out := []
	for t in NAILS:
		if PetBuilder.has_type(pet, t):
			out.append(["nails", "Clip its nails", "bath_clippers", "Rub its paws!", "Nails done!"])
			break
	out.append(["wash", "Give it a wash", "kit_sponge", "Scrub it all over!", "All washed!"])
	out.append(["teeth", "Brush its teeth", "bath_toothbrush", "Brush side to side!", "Sparkly teeth!"])
	var c := coat_info(coat(pet))
	out.append(["groom", c[3], c[4], c[6], c[5]])
	return out
