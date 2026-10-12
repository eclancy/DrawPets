class_name PartTypes
extends RefCounted
## Every kind of body part a kid can give a creature, and everything the game needs to know
## about one: what it attaches to, where its red "attach here" dot sits on the drawing sheet,
## how much the sheet is zoomed, and where it goes on its host. How each one MOVES lives in
## CreaturePart - one motion recipe per type. See .ai/creature-pipeline.md.
##
## A creature is drawn in stages (Creator): the body, then each MAIN part (heads, arms, legs),
## and while drawing each one the kid adds the things that go ON it - horns on a head, hands on
## an arm, claws on a leg. Those are its ADD-ONS, and they ride on it.
##
## Coordinates:
##   host    - what the part attaches to: body, head, arm or leg. Face parts go on the head,
##             or on the body when a creature has no head.
##   dot     - on the 512 px drawing sheet. The kid draws the part starting from it, and it
##             becomes the part's joint, so the drawing's own direction is its rest pose.
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
##   count   - how many the kid gets when they add one (they can change it).

const SHEET := 512

## The parts asked for up front - "how many heads, arms and legs?".
const MAIN := ["head", "arm", "leg"]

## What can be added while drawing each host. Face parts join the body's list when a creature
## has no head.
const ADDONS := {
	"body": ["wing", "tail", "fin", "spike", "tentacle", "other"],
	"head": ["eye", "mouth", "ear", "horn", "antenna", "hair", "nose", "spike"],
	"arm": ["hand", "claw"],
	"leg": ["foot", "claw"],
}
const FACE := ["eye", "mouth", "ear", "horn", "antenna", "hair", "nose"]
## Every creature needs these somewhere on its face host: eyes blink, mouths open.
const REQUIRED := ["eye", "mouth"]

## The order parts are built in - which is also the order they stack in. Hosts come before
## what goes on them, and face parts after the body's wings and spikes, so a face on a headless
## creature is never hidden behind its own wing.
const ORDER := ["head", "leg", "arm", "wing", "tail", "fin", "spike", "tentacle", "other",
	"eye", "ear", "mouth", "nose", "horn", "antenna", "hair", "hand", "foot", "claw"]

const BODY := {
	"label": "Body", "plural": "Body", "max": 1, "zoom": 1.0, "dot": Vector2(256, 256),
	"prompt": "Draw the SHAPE of your creature's BODY, facing right. Make it big! Its legs, wings and the rest come next.",
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
		"zoom": 1.0, "pairs": false, "spread": 0.16,
		"prompt": "Draw the SHAPE of the HEAD, facing right. The red dot is its neck - start there. Eyes, mouth and ears come next!"},
	"eye": {"label": "Eye", "plural": "Eyes", "max": 8, "host": "head", "count": 2,
		"anchor": Vector2(0.68, 0.4), "body_anchor": Vector2(0.78, 0.3), "dot": Vector2(256, 256),
		"zoom": 3.0, "pairs": false, "spread": 0.12,
		"prompt": "Draw ONE eye around the red dot. It will blink!"},
	"ear": {"far": Vector2(0.5, 0.0), "body_far": Vector2(0.4, 0.0), "label": "Ear", "plural": "Ears",
		"max": 4, "host": "head",
		"count": 2, "anchor": Vector2(0.4, 0.5), "body_anchor": Vector2(0.55, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(256, 430), "zoom": 1.8, "pairs": true, "spread": 0.0,
		"prompt": "Draw ONE ear growing UP from the red dot."},
	"mouth": {"label": "Mouth", "plural": "Mouths", "max": 2, "host": "head", "count": 1,
		"anchor": Vector2(0.73, 0.72), "body_anchor": Vector2(0.82, 0.55), "dot": Vector2(256, 256),
		"zoom": 2.5, "pairs": false, "spread": 0.1,
		"prompt": "Draw the MOUTH WIDE OPEN around the red dot. We'll close it, and open it when it eats, barks and yawns!"},
	"nose": {"label": "Nose", "plural": "Noses", "max": 2, "host": "head", "count": 1,
		"anchor": Vector2(0.74, 0.54), "body_anchor": Vector2(0.83, 0.42),
		"dot": Vector2(256, 256), "zoom": 2.5, "pairs": false, "spread": 0.1,
		"prompt": "Draw the NOSE around the red dot - it goes between the eyes, a bit to the front."},
	"horn": {"far": Vector2(0.46, 0.0), "body_far": Vector2(0.38, 0.0), "label": "Horn", "plural": "Horns",
		"max": 6, "host": "head",
		"count": 2, "anchor": Vector2(0.42, 0.5), "body_anchor": Vector2(0.56, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(256, 440), "zoom": 1.8, "pairs": true, "spread": 0.15,
		"prompt": "Draw ONE horn pointing UP from the red dot."},
	"antenna": {"far": Vector2(0.42, 0.0), "body_far": Vector2(0.36, 0.0), "label": "Antenna",
		"plural": "Antennae", "max": 4,
		"host": "head", "count": 2, "anchor": Vector2(0.44, 0.5), "body_anchor": Vector2(0.58, 0.5),
		"edge": Vector2(0, -1), "dot": Vector2(256, 450), "zoom": 1.5, "pairs": true, "spread": 0.1,
		"prompt": "Draw ONE antenna boinging UP from the red dot."},
	"hair": {"label": "Hair", "plural": "Hair", "max": 2, "host": "head", "count": 1,
		"anchor": Vector2(0.3, 0.5), "body_anchor": Vector2(0.4, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(300, 400), "zoom": 1.3, "pairs": false, "spread": 0.2,
		"prompt": "Draw its HAIR or MANE, growing up from the red dot."},
	"leg": {"far": Vector2(-0.11, -0.015), "label": "Leg", "plural": "Legs", "max": 8, "host": "body", "count": 4,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 70),
		"zoom": 1.0, "pairs": true, "spread": 0.3,
		"prompt": "Draw ONE leg hanging DOWN from the red dot. You can add a foot or claws to it."},
	"arm": {"far": Vector2(-0.12, -0.01), "label": "Arm", "plural": "Arms", "max": 6, "host": "body",
		"count": 2, "anchor": Vector2(0.72, 0.38), "headless_anchor": Vector2(0.7, 0.66),
		"dot": Vector2(256, 70), "zoom": 1.2,
		"pairs": true, "spread": 0.0,
		"prompt": "Draw ONE arm hanging DOWN from the red dot - the dot is its shoulder. You can add a hand or claws."},
	"wing": {"far": Vector2(-0.12, -0.02), "label": "Wing", "plural": "Wings", "max": 4, "host": "body",
		"count": 2, "anchor": Vector2(0.45, 0.5), "edge": Vector2(0, -1), "dot": Vector2(300, 440),
		"zoom": 1.0, "pairs": true, "spread": 0.2,
		"prompt": "Draw ONE wing growing UP from the red dot. Wings let it fly!"},
	"tail": {"label": "Tail", "plural": "Tails", "max": 3, "host": "body", "count": 1,
		"anchor": Vector2(0.5, 0.55), "edge": Vector2(-1, 0), "dot": Vector2(440, 256),
		"zoom": 1.0, "pairs": false, "spread": 0.15,
		"prompt": "Draw the TAIL going LEFT from the red dot. It wags when it's happy!"},
	"fin": {"label": "Fin", "plural": "Fins", "max": 6, "host": "body", "count": 2,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, -1), "dot": Vector2(256, 430),
		"zoom": 1.3, "pairs": false, "spread": 0.25,
		"prompt": "Draw ONE fin growing UP from the red dot. Fins let it swim!"},
	"spike": {"label": "Spike", "plural": "Spikes", "max": 10, "host": "body", "count": 3,
		"anchor": Vector2(0.45, 0.5), "edge": Vector2(0, -1), "dot": Vector2(256, 440),
		"zoom": 1.5, "pairs": false, "spread": 0.35,
		"prompt": "Draw ONE spike pointing UP from the red dot."},
	"tentacle": {"label": "Tentacle", "plural": "Tentacles", "max": 8, "host": "body", "count": 4,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 60),
		"zoom": 1.0, "pairs": true, "spread": 0.3,
		"prompt": "Draw ONE tentacle dangling DOWN from the red dot. Make it wiggly!"},
	"other": {"label": "Other", "plural": "Other things", "max": 6, "host": "body", "count": 1,
		"anchor": Vector2(0.5, 0.45), "dot": Vector2(256, 256), "zoom": 1.0,
		"pairs": false, "spread": 0.3,
		"prompt": "Draw anything else it has, around the red dot. Shell? Backpack? Jetpack?"},
	"hand": {"label": "Hand", "plural": "Hands", "max": 1, "host": "arm", "count": 1,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 80),
		"zoom": 2.0, "pairs": false, "spread": 0.0,
		"prompt": "Draw a HAND (or paw) hanging DOWN from the red dot - the dot is its wrist."},
	"foot": {"label": "Foot", "plural": "Feet", "max": 1, "host": "leg", "count": 1,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(190, 140),
		"zoom": 1.8, "pairs": false, "spread": 0.0,
		"prompt": "Draw a FOOT from the red dot - its ankle. Point the toes to the RIGHT."},
	"claw": {"label": "Claw", "plural": "Claws", "max": 5, "host": "leg", "count": 3,
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 120),
		"zoom": 3.0, "pairs": false, "spread": 0.3,
		"prompt": "Draw ONE claw poking DOWN from the red dot."},
}

## Food and toys have no body to attach to; the dot is just their middle.
const ITEM := {"label": "Item", "max": 1, "zoom": 1.0, "dot": Vector2(256, 256)}


static func info(type: String) -> Dictionary:
	if type == "body":
		return BODY
	return TYPES.get(type, ITEM)


static func label_for(type: String, count: int) -> String:
	var i := info(type)
	return i["label"] if count == 1 else i.get("plural", i["label"])


## What can be added while drawing `host` - face parts join the body's list when there is no head.
static func addons_for(host: String, has_head: bool) -> Array:
	var list: Array = ADDONS.get(host, []).duplicate()
	if host == "body" and not has_head:
		list = FACE + list
	return list


## The art icon for a part type.
static func icon(type: String) -> String:
	return "part_" + type
