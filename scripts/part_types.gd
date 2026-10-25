class_name PartTypes
extends RefCounted
## Every kind of body part a creature can have, and everything the game needs to know about
## one. How each one MOVES lives in CreaturePart - one motion recipe per type. See
## .ai/creature-pipeline.md.
##
## A kid draws their creature on one sheet (CreatureSheet), a part type at a time, and PartCutter
## works out what rides on what. The ready-made creatures (Roster) are built from a drawing per
## part instead, laid out by PetBuilder.add_parts with these:
##   host    - what the part attaches to: body, head, arm or leg. Face parts go on the head,
##             or on the body when a creature has no head.
##   dot     - on the 512 px drawing sheet. The part is drawn starting from it, and it becomes
##             the part's joint, so the drawing's own direction is its rest pose.
##   anchor  - where on the host's drawing the part attaches, as a fraction of its ink box.
##             With `edge`, the anchor walks from there in that direction to the last ink it
##             finds - legs land on the bottom of the body, hands on the end of the arm.
##             `body_anchor` is used instead when a face part goes on a body.
##   zoom    - how magnified the sheet is compared to the body sheet. Eyes are drawn at 3x so
##             a thumb can draw one; they come out a third the size.
##   pairs   - copies come in near/far pairs, the far one drawn behind and darker (the cutout
##             animation trick DrawFight uses for back limbs).
##   spread  - how far apart (as a fraction of the host's width) copies are fanned out.
##   far     - where the far copy of a pair sits relative to the near one, as a fraction of
##             the host drawing's size (default (-0.07, -0.02)).
##   headless_anchor - used instead on a creature with no head, whose face is on its body:
##             arms go lower, under the face rather than across it.
##   count   - how many a ready-made creature usually gets.

const SHEET := 512

## The parts other parts ride on, besides the body: face parts on a head, hands on an arm, feet
## and claws on a leg.
const MAIN := ["head", "arm", "leg"]
const FACE := ["eye", "mouth", "ear", "horn", "antenna", "hair", "nose"]

## The order parts are built in: hosts come before what goes on them. (A kid's pet stacks its
## parts as they were stacked on the sheet - each drawing's `behind` and `z`; a ready-made
## creature stacks in this order, so a face on a headless one is never behind its own wing.)
const ORDER := ["head", "leg", "arm", "wing", "tail", "fin", "spike", "tentacle", "other",
	"eye", "ear", "mouth", "nose", "horn", "antenna", "hair", "hand", "foot", "claw"]

const BODY := {
	"label": "Body", "plural": "Body", "max": 1, "zoom": 1.0, "dot": Vector2(256, 256)
}

## Faces are THREE-QUARTER, turned to the right - the way the whole creature faces - never
## straight at the camera: both eyes show, set in the right-hand part of the head; the nose sits
## between them but nearer the far (right) eye and a little lower; the mouth goes under the
## nose; ears, horns and antennae go on either side of the eyes - the near one at the back-left
## of the head, the far one at the top right, behind the head and a shade darker. A lone horn
## goes between them. Every kid's pet is laid out like this first, and the ready-made creatures
## follow it unless they are drawn in true profile.

const TYPES := {
	"head": {"label": "Head", "plural": "Heads", "max": 3, "host": "body", "count": 1,
		"anchor": Vector2(0.82, 0.5), "edge": Vector2(0, -1), "dot": Vector2(200, 410),
		"zoom": 1.0, "pairs": false, "spread": 0.16},
	"eye": {"label": "Eye", "plural": "Eyes", "max": 8, "host": "head", "count": 2,
		"anchor": Vector2(0.68, 0.4), "body_anchor": Vector2(0.78, 0.3), "dot": Vector2(256, 256),
		"zoom": 3.0, "pairs": false, "spread": 0.12},
	"ear": {"far": Vector2(0.5, 0.0), "body_far": Vector2(0.4, 0.0), "label": "Ear", "plural": "Ears",
		"max": 4, "host": "head",
		"count": 2, "anchor": Vector2(0.4, 0.5), "body_anchor": Vector2(0.55, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(256, 430), "zoom": 1.8, "pairs": true, "spread": 0.0},
	"mouth": {"label": "Mouth", "plural": "Mouths", "max": 2, "host": "head", "count": 1,
		"anchor": Vector2(0.73, 0.72), "body_anchor": Vector2(0.82, 0.55), "dot": Vector2(256, 256),
		"zoom": 2.5, "pairs": false, "spread": 0.1},
	"nose": {"label": "Nose", "plural": "Noses", "max": 2, "host": "head", "count": 1,
		"anchor": Vector2(0.74, 0.54), "body_anchor": Vector2(0.83, 0.42),
		"dot": Vector2(256, 256), "zoom": 2.5, "pairs": false, "spread": 0.1},
	"horn": {"far": Vector2(0.46, 0.0), "body_far": Vector2(0.38, 0.0), "label": "Horn", "plural": "Horns",
		"max": 6, "host": "head",
		"count": 2, "anchor": Vector2(0.42, 0.5), "body_anchor": Vector2(0.56, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(256, 440), "zoom": 1.8, "pairs": true, "spread": 0.15},
	"antenna": {"far": Vector2(0.42, 0.0), "body_far": Vector2(0.36, 0.0), "label": "Antenna",
		"plural": "Antennae", "max": 4,
		"host": "head", "count": 2, "anchor": Vector2(0.44, 0.5), "body_anchor": Vector2(0.58, 0.5),
		"edge": Vector2(0, -1), "dot": Vector2(256, 450), "zoom": 1.5, "pairs": true, "spread": 0.1},
	"hair": {"label": "Hair", "plural": "Hair", "max": 2, "host": "head", "count": 1,
		"anchor": Vector2(0.3, 0.5), "body_anchor": Vector2(0.4, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(300, 400), "zoom": 1.3, "pairs": false, "spread": 0.2},
	"leg": {"far": Vector2(-0.11, -0.015), "label": "Leg", "plural": "Legs", "max": 8, "host": "body", "count": 4,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 70),
		"zoom": 1.0, "pairs": true, "spread": 0.3},
	"arm": {"far": Vector2(-0.12, -0.01), "label": "Arm", "plural": "Arms", "max": 6, "host": "body",
		"count": 2, "anchor": Vector2(0.72, 0.38), "headless_anchor": Vector2(0.7, 0.66),
		"dot": Vector2(256, 70), "zoom": 1.2,
		"pairs": true, "spread": 0.0},
	"wing": {"far": Vector2(-0.12, -0.02), "label": "Wing", "plural": "Wings", "max": 4, "host": "body",
		"count": 2, "anchor": Vector2(0.45, 0.5), "edge": Vector2(0, -1), "dot": Vector2(300, 440),
		"zoom": 1.0, "pairs": true, "spread": 0.2},
	"tail": {"label": "Tail", "plural": "Tails", "max": 3, "host": "body", "count": 1,
		"anchor": Vector2(0.5, 0.55), "edge": Vector2(-1, 0), "dot": Vector2(440, 256),
		"zoom": 1.0, "pairs": false, "spread": 0.15},
	"fin": {"label": "Fin", "plural": "Fins", "max": 6, "host": "body", "count": 2,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, -1), "dot": Vector2(256, 430),
		"zoom": 1.3, "pairs": false, "spread": 0.25},
	"spike": {"label": "Spike", "plural": "Spikes", "max": 10, "host": "body", "count": 3,
		"anchor": Vector2(0.45, 0.5), "edge": Vector2(0, -1), "dot": Vector2(256, 440),
		"zoom": 1.5, "pairs": false, "spread": 0.35},
	"tentacle": {"label": "Tentacle", "plural": "Tentacles", "max": 8, "host": "body", "count": 4,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 60),
		"zoom": 1.0, "pairs": true, "spread": 0.3},
	"other": {"label": "Other", "plural": "Other things", "max": 6, "host": "body", "count": 1,
		"anchor": Vector2(0.5, 0.45), "dot": Vector2(256, 256), "zoom": 1.0,
		"pairs": false, "spread": 0.3},
	"hand": {"label": "Hand", "plural": "Hands", "max": 1, "host": "arm", "count": 1,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 80),
		"zoom": 2.0, "pairs": false, "spread": 0.0},
	"foot": {"label": "Foot", "plural": "Feet", "max": 1, "host": "leg", "count": 1,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(190, 140),
		"zoom": 1.8, "pairs": false, "spread": 0.0},
	"claw": {"label": "Claw", "plural": "Claws", "max": 5, "host": "leg", "count": 3,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 120),
		"zoom": 3.0, "pairs": false, "spread": 0.3},
}

## Drawing the creature on one sheet (CreatureSheet): what to draw, big across the top of the
## sheet, and where or how, under it. The kid draws it right where it goes - touching what it
## grows from.
const DRAW := {
	"body": ["Draw its BODY", "Big, and facing right. No legs yet!"],
	"head": ["Draw its HEAD", "Touching the body."],
	"eye": ["Draw an EYE", "On its head. It blinks!"],
	"mouth": ["Draw its MOUTH", "Wide open - it eats and talks!"],
	"nose": ["Draw its NOSE", "On its head. It sniffs!"],
	"ear": ["Draw an EAR", "On its head."],
	"horn": ["Draw a HORN", "On its head, touching it."],
	"antenna": ["Draw an ANTENNA", "On its head. Boing!"],
	"hair": ["Draw its HAIR", "Or a mane - on its head."],
	"leg": ["Draw a LEG", "Coming down from the body. It walks!"],
	"arm": ["Draw an ARM", "Coming out of the body. It waves!"],
	"wing": ["Draw a WING", "Touching the body. It flaps!"],
	"tail": ["Draw its TAIL", "Coming out of the body. It wags!"],
	"fin": ["Draw a FIN", "Touching the body. It swims!"],
	"spike": ["Draw its SPIKES", "Along its back."],
	"tentacle": ["Draw a TENTACLE", "Dangling from the body."],
	"other": ["Draw anything else", "A shell? A jetpack?"],
	"hand": ["Draw a HAND", "On the end of an arm."],
	"foot": ["Draw a FOOT", "On the bottom of a leg."],
	"claw": ["Draw CLAWS", "On a foot or a hand."],
}
## The next of several ("LEG 2 of 4"), and after "Copy this leg".
const DRAW_NEXT := ["%s %d of %d", "Draw it - or copy the last one."]
const DRAG_COPY := "Drag the copy where it goes!"
## A creature needs a body, and eyes and a mouth on it somewhere.
const NEEDED := ["body", "eye", "mouth"]

## Drawing a pet is guided (.ai/creature-pipeline.md): the kid says up front how many of these it
## has - type -> [fewest, most, to start with], a cat or a dog to start - then draws them one at a
## time, in GUIDE_ORDER, and is asked "Anything else?" at the end for the rest. The body and the
## mouth are always one each.
const PLAN_ASK := {"head": [0, 3, 1], "eye": [1, 8, 2], "ear": [0, 4, 2], "arm": [0, 6, 0],
	"leg": [0, 8, 4], "tail": [0, 3, 1]}
const PLAN_ORDER := ["head", "eye", "ear", "arm", "leg", "tail"]
## The order the parts are drawn in: what a part grows from before the part (a hand after the
## arms), the face together.
const GUIDE_ORDER := ["body", "head", "eye", "mouth", "nose", "ear", "horn", "antenna", "hair",
	"arm", "hand", "leg", "foot", "claw", "tail", "wing", "fin", "spike", "tentacle", "other"]
## Drawn as a bunch, not counted: some spikes, some hair, some claws - yes or no.
const BUNCH := ["hair", "spike", "claw"]
## How many "Anything else?" starts a part at when it is tapped: a pair of wings, a nose. Hands
## and feet start at one per arm and per leg.
const MORE_START := {"head": 1, "eye": 2, "ear": 2, "arm": 2, "leg": 4, "tail": 1, "nose": 1,
	"horn": 2, "antenna": 2, "hair": 1, "wing": 2, "fin": 2, "spike": 1, "tentacle": 4, "claw": 1,
	"other": 1, "hand": 2, "foot": 4}

## Food and toys have no body to attach to; the dot is just their middle.
const ITEM := {"label": "Item", "max": 1, "zoom": 1.0, "dot": Vector2(256, 256)}


## The plan for a new pet from the counts picked up front: [[type, how many], ...] in the order
## they are drawn, with the body and a mouth.
static func plan_from(counts: Dictionary) -> Array:
	var all := counts.duplicate()
	all["body"] = 1
	all["mouth"] = 1
	var out := []
	for type in GUIDE_ORDER:
		if int(all.get(type, 0)) > 0:
			out.append([type, int(all[type])])
	return out


## Adds `counts` (type -> how many) to a plan in place, keeping it in drawing order; 0 takes a
## part out of it.
static func add_to_plan(plan: Array, counts: Dictionary) -> void:
	var all := {}
	for e in plan:
		all[str(e[0])] = int(e[1])
	for type in counts:
		all[type] = int(counts[type])
	plan.clear()
	for type in GUIDE_ORDER:
		if int(all.get(type, 0)) > 0:
			plan.append([type, int(all[type])])


## The most of a part a pet can be planned with: a hand for every arm, a foot for every leg (a
## part's own "max" is per host for those).
static func most(type: String) -> int:
	match type:
		"hand":
			return int(TYPES["arm"]["max"])
		"foot":
			return int(TYPES["leg"]["max"])
	return int(info(type)["max"])


## How many of `type` a plan has (0 if none).
static func planned(plan: Array, type: String) -> int:
	for e in plan:
		if str(e[0]) == type:
			return int(e[1])
	return 0


static func info(type: String) -> Dictionary:
	if type == "body":
		return BODY
	return TYPES.get(type, ITEM)


## One of a part, in words: "leg", "eye" - "thing" for anything else.
static func one_name(type: String) -> String:
	return "thing" if type == "other" else str(info(type)["label"]).to_lower()


static func label_for(type: String, count: int) -> String:
	var i := info(type)
	return i["label"] if count == 1 else i.get("plural", i["label"])


## The art icon for a part type.
static func icon(type: String) -> String:
	return "part_" + type
