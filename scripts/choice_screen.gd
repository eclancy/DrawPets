class_name ChoiceScreen
extends Control
## One question with a few big answers, shown next to the drawing it is about: "What kind of
## toy is it?" with their toy drawing beside it.

const FOOD_KINDS := [
	["sweet", "Sweet treat", "cake, candy, honey"], ["fruit", "Fruit or veg", "apple, carrot"],
	["meat", "Meaty", "bones, burgers"], ["fish", "Fishy", "fish, shrimp"],
	["bugs", "Bugs!", "crunchy, wriggly"], ["weird", "Something weird", "rocks, socks, stars"],
]
const TOY_KINDS := [
	["ball", "Ball", "bounces and rolls"], ["frisbee", "Flying disc", "glides a long way"],
	["stick", "Stick", "spins through the air"], ["squeaky", "Squeaky toy", "squeaks when it lands"],
	["plush", "Plushie", "soft and floppy"], ["rope", "Rope", "for tug of war"],
]

var question := ""
var picture: Texture2D
var options := []
var on_choose := Callable()


func _ready() -> void:
	add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 30)
	add_child(UI.full_rect(UI.margin(row, 28)))

	var art := TextureRect.new()
	art.texture = picture
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(art)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_stretch_ratio = 1.3
	col.add_theme_constant_override("separation", 14)
	row.add_child(col)
	col.add_child(UI.title(question, 36))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for o in options:
		var b := UI.button("%s\n%s" % [o[1], o[2]], choose.bind(o[0]), Vector2(0, 96), 24)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		grid.add_child(b)
	col.add_child(grid)


func choose(id: String) -> void:
	on_choose.call(id)
