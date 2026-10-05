class_name PartTypes
extends RefCounted
## Every kind of body part a kid can give a creature, and everything the game needs to know
## about one: where its red "attach here" dot sits on the drawing sheet, how much the sheet is
## zoomed, where it goes on the body, and how many may be drawn. How each one MOVES lives in
## CreaturePart - one motion recipe per type. See .ai/creature-pipeline.md.
##
## Coordinates:
##   dot     - on the 512 px drawing sheet. The kid draws the part starting from it, and it
##             becomes the part's joint, so the drawing's own direction is its rest pose.
##   anchor  - where on the reference drawing (the head, or the body) the part attaches, as a
##             fraction of that drawing's ink box. With `edge`, the anchor walks from there in
##             that direction to the last ink it finds - legs land on the bottom of the body,
##             not somewhere inside it.
##   zoom    - how magnified the sheet is compared to the body sheet. Eyes are drawn at 3x so
##             a thumb can draw one; they come out a third the size.
##   pairs   - copies come in near/far pairs, the far one drawn behind and darker (the cutout
##             animation trick DrawFight uses for back limbs).
##   spread  - how far apart (as a fraction of the reference width) copies are fanned out.
##   far     - where the far copy of a pair sits relative to the near one, as a fraction of
##             the reference drawing's size (default (-0.07, -0.02)). Ears need more room
##             than legs or the two read as one.

const SHEET := 512

## The order parts are drawn in. Head comes first so face parts can attach to it.
const ORDER := ["head", "eye", "ear", "mouth", "nose", "horn", "antenna", "hair",
	"leg", "arm", "wing", "tail", "fin", "spike", "tentacle", "other"]

const BODY := {
	"label": "Body", "plural": "Body", "max": 1, "zoom": 1.0, "dot": Vector2(256, 256),
	"prompt": "Draw your creature's BODY, facing right. Make it big! The head, legs and the rest come next.",
}

const TYPES := {
	"head": {"label": "Head", "plural": "Head", "max": 1, "ref": "body",
		"anchor": Vector2(0.82, 0.5), "edge": Vector2(0, -1), "dot": Vector2(200, 410),
		"zoom": 1.0, "pairs": false, "spread": 0.0,
		"prompt": "Draw the HEAD, facing right. The red dot is its neck - start there."},
	"eye": {"label": "Eye", "plural": "Eyes", "max": 8, "ref": "head",
		"anchor": Vector2(0.66, 0.4), "body_anchor": Vector2(0.78, 0.3), "dot": Vector2(256, 256),
		"zoom": 3.0, "pairs": false, "spread": 0.12,
		"min": 1, "prompt": "Draw ONE eye around the red dot. It will blink!"},
	"ear": {"far": Vector2(-0.22, 0.0), "label": "Ear", "plural": "Ears", "max": 4, "ref": "head",
		"anchor": Vector2(0.4, 0.5), "body_anchor": Vector2(0.6, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(256, 430), "zoom": 1.8, "pairs": true, "spread": 0.0,
		"prompt": "Draw ONE ear growing UP from the red dot."},
	"mouth": {"label": "Mouth", "plural": "Mouths", "max": 2, "ref": "head",
		"anchor": Vector2(0.82, 0.72), "body_anchor": Vector2(0.88, 0.55), "dot": Vector2(256, 256),
		"zoom": 2.5, "pairs": false, "spread": 0.1, "min": 1,
		"prompt": "Draw the MOUTH WIDE OPEN around the red dot. We'll close it, and open it when it eats, barks and yawns!"},
	"nose": {"label": "Nose", "plural": "Noses", "max": 2, "ref": "head",
		"anchor": Vector2(0.5, 0.5), "body_anchor": Vector2(0.5, 0.4), "edge": Vector2(1, 0),
		"dot": Vector2(180, 256), "zoom": 2.5, "pairs": false, "spread": 0.1,
		"prompt": "Draw the NOSE sticking out to the RIGHT of the red dot."},
	"horn": {"far": Vector2(-0.16, 0.0), "label": "Horn", "plural": "Horns", "max": 6, "ref": "head",
		"anchor": Vector2(0.55, 0.5), "body_anchor": Vector2(0.7, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(256, 440), "zoom": 1.8, "pairs": true, "spread": 0.15,
		"prompt": "Draw ONE horn pointing UP from the red dot."},
	"antenna": {"far": Vector2(-0.18, 0.0), "label": "Antenna", "plural": "Antennae", "max": 4, "ref": "head",
		"anchor": Vector2(0.45, 0.5), "body_anchor": Vector2(0.65, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(256, 450), "zoom": 1.5, "pairs": true, "spread": 0.1,
		"prompt": "Draw ONE antenna boinging UP from the red dot."},
	"hair": {"label": "Hair", "plural": "Hair", "max": 2, "ref": "head",
		"anchor": Vector2(0.3, 0.5), "body_anchor": Vector2(0.4, 0.5), "edge": Vector2(0, -1),
		"dot": Vector2(300, 400), "zoom": 1.3, "pairs": false, "spread": 0.2,
		"prompt": "Draw its HAIR or MANE, growing up from the red dot."},
	"leg": {"label": "Leg", "plural": "Legs", "max": 8, "ref": "body",
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 70),
		"zoom": 1.0, "pairs": true, "spread": 0.3,
		"prompt": "Draw ONE leg hanging DOWN from the red dot, foot and all."},
	"arm": {"far": Vector2(-0.12, -0.01), "label": "Arm", "plural": "Arms", "max": 6, "ref": "body",
		"anchor": Vector2(0.72, 0.38), "dot": Vector2(256, 70), "zoom": 1.2,
		"pairs": true, "spread": 0.0,
		"prompt": "Draw ONE arm hanging DOWN from the red dot - the dot is its shoulder."},
	"wing": {"far": Vector2(-0.12, -0.02), "label": "Wing", "plural": "Wings", "max": 4, "ref": "body",
		"anchor": Vector2(0.45, 0.5), "edge": Vector2(0, -1), "dot": Vector2(300, 440),
		"zoom": 1.0, "pairs": true, "spread": 0.2,
		"prompt": "Draw ONE wing growing UP from the red dot. Wings let it fly!"},
	"tail": {"label": "Tail", "plural": "Tails", "max": 3, "ref": "body",
		"anchor": Vector2(0.5, 0.55), "edge": Vector2(-1, 0), "dot": Vector2(440, 256),
		"zoom": 1.0, "pairs": false, "spread": 0.15,
		"prompt": "Draw the TAIL going LEFT from the red dot. It wags when it's happy!"},
	"fin": {"label": "Fin", "plural": "Fins", "max": 6, "ref": "body",
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, -1), "dot": Vector2(256, 430),
		"zoom": 1.3, "pairs": false, "spread": 0.25,
		"prompt": "Draw ONE fin growing UP from the red dot. Fins let it swim!"},
	"spike": {"label": "Spike", "plural": "Spikes", "max": 10, "ref": "body",
		"anchor": Vector2(0.45, 0.5), "edge": Vector2(0, -1), "dot": Vector2(256, 440),
		"zoom": 1.5, "pairs": false, "spread": 0.35,
		"prompt": "Draw ONE spike pointing UP from the red dot."},
	"tentacle": {"label": "Tentacle", "plural": "Tentacles", "max": 8, "ref": "body",
		"anchor": Vector2(0.5, 0.5), "edge": Vector2(0, 1), "dot": Vector2(256, 60),
		"zoom": 1.0, "pairs": true, "spread": 0.3,
		"prompt": "Draw ONE tentacle dangling DOWN from the red dot. Make it wiggly!"},
	"other": {"label": "Other", "plural": "Other things", "max": 6, "ref": "body",
		"anchor": Vector2(0.5, 0.45), "dot": Vector2(256, 256), "zoom": 1.0,
		"pairs": false, "spread": 0.3,
		"prompt": "Draw anything else it has, around the red dot. Shell? Backpack? Jetpack?"},
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
