class_name PartPreview
extends Control
## "Look - it moves!" When a kid taps Done on a part, the creature so far does what that part
## does for a moment: legs walk, a tail wags, eyes blink, wings flap, a mouth chomps. So they see
## straight away that the drawing comes alive, and how each kind of part moves - through the same
## motion recipes the game uses (.ai/creature-pipeline.md), never a canned animation.
##
## Fields, set before it enters the tree: `pet` (the creature to show - the pet so far, or a copy
## with a host still being drawn), `part_type`, `on_done`. Tap to carry on sooner.

## What each part type shows off, and what it says: [how, words].
##   walk / swim / fly - goes back and forth; hop - little hops so springy parts wobble;
##   blink - blinks; anything else is an action Creature plays (look, eat, sniff, wiggle...).
const SHOW := {
	"body": ["hop", "It's alive! It breathes and bounces."],
	"head": ["look", "Its head looks around!"],
	"eye": ["blink", "Its eyes blink!"],
	"mouth": ["eat", "Its mouth opens - to eat, and to talk!"],
	"nose": ["sniff", "Its nose sniffs!"],
	"ear": ["hop", "Its ears bounce!"],
	"horn": ["hop", "Its horns wobble!"],
	"antenna": ["hop", "Its antennae go boing!"],
	"hair": ["hop", "Its hair bounces!"],
	"spike": ["hop", "Its spikes wobble!"],
	"other": ["hop", "Boing!"],
	"leg": ["walk", "Its legs walk!"],
	"foot": ["walk", "Its feet step along!"],
	"claw": ["walk", "Its claws come along too!"],
	"tentacle": ["walk", "Its tentacles wiggle along!"],
	"arm": ["celebrate", "Its arms wave!"],
	"hand": ["celebrate", "Its hands wave!"],
	"wing": ["fly", "Its wings flap - it can fly!"],
	"tail": ["wiggle", "Its tail wags!"],
	"fin": ["swim", "Its fins paddle - it can swim!"],
}
const LENGTH := 2.8
## A tap this soon after it opens is the end of the tap on Done, not a wish to skip.
const IGNORE_TAPS := 0.4

var pet: Dictionary
var part_type := ""
var on_done := Callable()

var _creature: Creature
var _stage: Control
var _how := ""
var _home := Vector2.ZERO
var _dir := 1.0
var _left := LENGTH
var _age := 0.0
var _beat := 0.0
var _done := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var back := ColorRect.new()
	back.color = Color(UI.PAPER, 0.94)
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(UI.full_rect(back))

	var entry: Array = SHOW.get(part_type, ["hop", "Look at it go!"])
	_how = entry[0]
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 10)
	add_child(UI.full_rect(col))
	var title := UI.title(entry[1], 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(title)
	_stage = Control.new()
	_stage.custom_minimum_size = Vector2(640, 400)
	_stage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_stage)
	var hint := UI.label("Tap to keep going", 20)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", UI.INK_SOFT)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(hint)

	_creature = Creature.new()
	_creature.wander = false
	_creature.confine = false
	_creature.depth_scale = false
	_creature.audible = true
	_creature.in_water = _how == "swim"
	_stage.add_child(_creature)
	_creature.setup(pet, 190.0 if _how == "fly" else 230.0)
	_creature.fit_in(Vector2(500.0, 190.0 if _how == "fly" else 230.0))
	_stage.resized.connect(_place)
	_place.call_deferred()
	if _how not in ["walk", "swim", "fly", "hop", "blink"]:
		_creature.perform(_how, LENGTH + 1.0)


func _place() -> void:
	_home = Vector2(_stage.size.x / 2.0, _stage.size.y - 40.0)
	_creature.position = _home


func _process(delta: float) -> void:
	_age += delta
	_left -= delta
	_beat -= delta
	match _how:
		"walk", "swim", "fly":
			if not _creature.is_busy():
				_dir = -_dir
				_creature.go_to(_home + Vector2(_dir * 140.0, 0.0), Callable(), false, _how == "fly")
		"hop":
			if _beat <= 0.0:
				_beat = 0.85
				_creature.perform("hop", 0.7)
		"blink":
			if _beat <= 0.0:
				_beat = 0.7
				_creature.blink_now()
	if _left <= 0.0:
		_finish()


## Carries on now - what a tap does.
func skip() -> void:
	_finish()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and _age > IGNORE_TAPS:
		_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	UI.retire(self)
	on_done.call()
