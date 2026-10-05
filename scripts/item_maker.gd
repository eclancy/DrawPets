class_name ItemMaker
extends Control
## Drawing a new thing - a toy, a snack, something for a home, something to wear - and saying
## what it is like: draw it, pick its words (and for clothes, where it is worn), and it joins
## the family's toybox, pantry, decorations or wardrobe for every pet to use.
##
## Used on its own (from a place, through GameRoot.make_item) and inside other screens (the
## creator's "draw its favourite food"). `on_done` gets the new item, or {} if they backed out.

const PROMPTS := {
	"toy": "Draw a TOY! Next you'll say what it's like - bouncy? stretchy? squeaky?",
	"food": "Draw a SNACK! Next you'll say what it tastes like.",
	"furniture": "Draw something for its HOME - a bed, a tree, a slide, a castle, anything!",
	"clothing": "Draw something to WEAR - a hat, glasses, a scarf, a cape...",
}
const QUESTIONS := {"toy": "What's this toy like?", "food": "What's this snack like?",
	"furniture": "What's it like?", "clothing": "What style is it?"}
const WEAR := [["head", "On its head", "hats, crowns, bows"], ["eyes", "Over its eyes", "glasses, masks"],
	["neck", "Round its neck", "scarves, collars, ties"], ["back", "On its back", "capes, wings, bags"]]

var game: GameRoot
var category := "toy"
var prompt := ""
var on_done := Callable()

var _current: Control
var _drawing := {}
var _words := []


func _ready() -> void:
	var s := DrawScreen.new()
	s.subject = category
	s.prompt = prompt if prompt != "" else PROMPTS.get(category, "Draw it!")
	s.can_skip = true
	s.skip_text = "Back"
	s.markers = _markers()
	s.on_done = _drawn
	_show(s)


func _markers() -> Dictionary:
	var out := {}
	for mode in Items.MARKERS:
		var n := game.profile.owned(Items.MARKERS[mode][0])
		if n > 0:
			out[mode] = n
	return out


func _show(screen: Control) -> void:
	if _current != null:
		remove_child(_current)
		_current.queue_free()
	_current = screen
	add_child(UI.full_rect(screen))


func _drawn(result: Dictionary) -> void:
	if result.is_empty():
		on_done.call({})
		return
	_drawing = result
	var s := WordPickerScreen.new()
	s.category = category
	s.question = QUESTIONS.get(category, "What's it like?")
	s.picture = ImageTexture.create_from_image(result["image"])
	s.on_done = _worded
	_show(s)


func _worded(words: Array) -> void:
	_words = words
	if category != "clothing":
		_save({})
		return
	var s := ChoiceScreen.new()
	s.question = "Where is it worn?"
	s.picture = ImageTexture.create_from_image(_drawing["image"])
	s.options = WEAR
	s.on_choose = func(where: String): _save({"wear": where})
	_show(s)


func _save(extra: Dictionary) -> void:
	var img: Image = _drawing["image"]
	var size := Vector2(img.get_size())
	# Things stand on the ground by the middle of their base; hats sit by their brim; scarves
	# hang from their top; everything else is held by its middle.
	var pivot := size / 2.0
	if category == "furniture" or extra.get("wear", "") == "head":
		pivot = Vector2(size.x / 2.0, size.y)
	elif extra.get("wear", "") == "neck":
		pivot = Vector2(size.x / 2.0, 0.0)
	var shine: Dictionary = _drawing.get("shine", {})
	var mode: String = shine.get("mode", "")
	if mode != "":
		game.profile.use_up(Items.MARKERS[mode][0])
	var item := Items.save_drawn(category, img, pivot, _words, mode, shine.get("mask"), extra)
	game.profile.add_drawn_item(item["id"])
	game.reward_daily("drew", 5, 2, "You drew something new!")
	on_done.call(item)
