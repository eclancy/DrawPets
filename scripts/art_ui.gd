class_name ArtUI
extends RefCounted
## The pictures on the game's buttons: drawing tools, assembly edits, body-part icons, size
## animals and a few actions. Players start at 7, so buttons should read as pictures first
## - an eraser button IS a picture of an eraser. Baked to res://art/ui/ by tools/bake_art.gd.
##
## House style (same as ArtWear - read scripts/art_wear.gd for examples): coloured pencil or
## marker, an opaque paper-white base under every shape, outlined in a darker shade of its own
## colour, never black, nothing darker than about 30% value. These are shown at 40-64 px, so:
## one bold silhouette, one or two details, thick outlines, fill most of the 512 sheet.
##
## Sheet: 512 x 512, y down, everything centred on (256, 256), pivot "center".

const ASSETS := {
	# Drawing tools.
	"tool_crayon": {"pivot": "center", "look": "a fat wax crayon, tilted, drawing a short squiggle"},
	"tool_fill": {"pivot": "center", "look": "a paint bucket tipping, a drip of paint pouring out"},
	"tool_eraser": {"pivot": "center", "look": "a pink rubber eraser, tilted, with a few rubbed-out crumbs"},
	"tool_dot": {"pivot": "center", "look": "a red map pin / push pin - the 'move the dot' tool"},
	"tool_undo": {"pivot": "center", "look": "a thick curved arrow looping back to the LEFT"},
	"tool_clear": {"pivot": "center", "look": "a crumpled ball of paper"},
	"tool_done": {"pivot": "center", "look": "a big green tick / check mark"},
	"tool_back": {"pivot": "center", "look": "a thick arrow pointing LEFT"},
	"tool_skip": {"pivot": "center", "look": "an arrow hopping over a little line, to the RIGHT"},
	# Looking round a big drawing (CreatureSheet): zoom in and out, see it all, slide it about.
	"tool_zoom_in": {"pivot": "center", "look": "a magnifying glass with a plus in its lens"},
	"tool_zoom_out": {"pivot": "center", "look": "a magnifying glass with a minus in its lens"},
	"tool_fit": {"pivot": "center", "look": "a picture frame with an arrow pointing out of each corner - see the whole page"},
	"tool_hand": {"pivot": "center", "look": "an open hand, fingers spread - slide the page about"},
	# Assembly edits.
	"edit_turn_left": {"pivot": "center", "look": "a curved arrow turning anticlockwise round a dot"},
	"edit_turn_right": {"pivot": "center", "look": "a curved arrow turning clockwise round a dot"},
	"edit_bigger": {"pivot": "center", "look": "a small square and a big square with an arrow growing outward"},
	"edit_smaller": {"pivot": "center", "look": "a big square and a small square with an arrow shrinking inward"},
	"edit_flip": {"pivot": "center", "look": "two mirror-image triangles either side of a dashed line"},
	"edit_layer": {"pivot": "center", "look": "two overlapping cards, one in front of the other, with an up/down arrow"},
	"edit_copy": {"pivot": "center", "look": "two identical sheets of paper, one offset behind the other, a plus"},
	"edit_remove": {"pivot": "center", "look": "a little bin / trash can with its lid lifting"},
	# Body parts - simple, friendly, generic versions a kid would recognise.
	"part_body": {"pivot": "center", "look": "a plain round blob body"},
	"part_head": {"pivot": "center", "look": "a round head in profile facing right, one eye, a smile"},
	"part_arm": {"pivot": "center", "look": "a bendy cartoon arm with a little hand"},
	"part_leg": {"pivot": "center", "look": "a single cartoon leg with a foot, standing"},
	"part_eye": {"pivot": "center", "look": "one big cartoon eye, white with a pupil (pupil dark plum, not black)"},
	"part_mouth": {"pivot": "center", "look": "a wide open smiling mouth with a tongue"},
	"part_ear": {"pivot": "center", "look": "one tall pointy ear, pink inside"},
	"part_horn": {"pivot": "center", "look": "one curved horn"},
	"part_antenna": {"pivot": "center", "look": "a springy antenna with a ball on the end"},
	"part_hair": {"pivot": "center", "look": "a tuft / mane of hair"},
	"part_nose": {"pivot": "center", "look": "a round button nose"},
	"part_wing": {"pivot": "center", "look": "one feathery wing"},
	"part_tail": {"pivot": "center", "look": "a curly fluffy tail"},
	"part_fin": {"pivot": "center", "look": "one fish fin"},
	"part_spike": {"pivot": "center", "look": "a row of three spikes"},
	"part_tentacle": {"pivot": "center", "look": "a curly tentacle with suckers"},
	"part_other": {"pivot": "center", "look": "a mystery: a snail-shell spiral with a little star"},
	"part_hand": {"pivot": "center", "look": "a cartoon hand / paw, open"},
	"part_foot": {"pivot": "center", "look": "a cartoon foot with three toes, side view"},
	"part_claw": {"pivot": "center", "look": "three curved claws"},
	# Sizes - an animal for each, drawn so their relative size is obvious when side by side.
	"size_tiny": {"pivot": "center", "look": "a mouse, small in the sheet"},
	"size_small": {"pivot": "center", "look": "a sitting cat"},
	"size_medium": {"pivot": "center", "look": "a dog"},
	"size_big": {"pivot": "center", "look": "a horse"},
	"size_huge": {"pivot": "center", "look": "an elephant"},
	"size_giant": {"pivot": "center", "look": "a long-neck dinosaur filling the sheet"},
	# Actions.
	"ui_adopt": {"pivot": "center", "look": "a heart with a paw print in it"},
	"ui_build": {"pivot": "center", "look": "a hammer"},
	"ui_sign": {"pivot": "center", "look": "a blank wooden name sign on a post"},
	"ui_plus": {"pivot": "center", "look": "a big friendly plus sign"},
	"ui_minus": {"pivot": "center", "look": "a big friendly minus sign"},
	# Looking after a pet.
	"ui_let_go": {"pivot": "center", "look": "an open garden gate with a little heart floating out of it - letting a pet go off to live in the wild"},
	"ui_move_home": {"pivot": "center", "look": "a little house with a curved arrow swooping into its door"},
	"ui_settings": {"pivot": "center", "look": "a friendly gear / cog"},
	# How to play (HowTo): a hand that shows the gesture - its pivot is the fingertip.
	"ui_point": {"pivot": Vector2(226, 40), "look": "a cartoon hand pointing straight UP with a chunky index finger and fingernail, the rest curled into a fist with the thumb tucked across, a straight wrist and a sleeve cuff"},
	# Sound buttons.
	"snd_play": {"pivot": "center", "look": "a big play triangle inside a circle"},
	"snd_record": {"pivot": "center", "look": "an old round microphone on a little stand, with a red record dot"},
	"snd_stop": {"pivot": "center", "look": "a rounded stop square"},
	"snd_dice": {"pivot": "center", "look": "a tumbling dice showing five dots - surprise me!"},
	"snd_speaker": {"pivot": "center", "look": "a loudspeaker with three sound-wave arcs - sound effects volume"},
	"snd_music": {"pivot": "center", "look": "two joined musical notes - music volume"},
	"snd_voice": {"pivot": "center", "look": "a wide open cartoon mouth with little sound lines - pet voices volume"},
	"snd_mic_off": {"pivot": "center", "look": "the same microphone with a soft diagonal line through it"},
	# The ends of the sound sliders.
	"snd_high": {"pivot": "center", "look": "a tiny bird singing high notes - higher"},
	"snd_low": {"pivot": "center", "look": "a big friendly whale going ooo with low notes - deeper"},
	"snd_fast": {"pivot": "center", "look": "a running rabbit with speed lines - faster"},
	"snd_slow": {"pivot": "center", "look": "a turtle plodding along - slower"},
	"snd_flat": {"pivot": "center", "look": "one calm straight horizontal line - no effect"},
	"snd_wobble": {"pivot": "center", "look": "a big wavy squiggly line - wobbly"},
	"snd_echo": {"pivot": "center", "look": "a mountain with three echo arcs coming off it - echo"},
	"snd_bend_up": {"pivot": "center", "look": "an arrow swooping upward like a ski jump - pitch slides up"},
	"snd_bend_down": {"pivot": "center", "look": "an arrow swooping downward like a slide - pitch slides down"},
	"snd_robot": {"pivot": "center", "look": "a friendly square robot head with antenna - robot voice"},
	"snd_backwards": {"pivot": "center", "look": "a rewind symbol: two triangles pointing LEFT"},
	# Base sounds a pet (or a drawn toy) can start from - each a face or thing MAKING its sound,
	# mouth open, with little sound lines.
	"snd_bark": {"pivot": "center", "look": "a dog's face barking"},
	"snd_meow": {"pivot": "center", "look": "a cat's face meowing"},
	"snd_chirp": {"pivot": "center", "look": "a little chick / songbird chirping"},
	"snd_squeak": {"pivot": "center", "look": "a mouse's face squeaking"},
	"snd_moo": {"pivot": "center", "look": "a cow's face mooing"},
	"snd_roar": {"pivot": "center", "look": "a friendly lion's face roaring, mane"},
	"snd_hoot": {"pivot": "center", "look": "an owl's face hooting"},
	"snd_ribbit": {"pivot": "center", "look": "a frog's face, throat puffed, ribbiting"},
	"snd_quack": {"pivot": "center", "look": "a duck's face quacking"},
	"snd_oink": {"pivot": "center", "look": "a pig's face oinking"},
	"snd_baa": {"pivot": "center", "look": "a sheep's face baa-ing"},
	"snd_trumpet": {"pivot": "center", "look": "an elephant raising its trunk and trumpeting"},
	"snd_purr": {"pivot": "center", "look": "a curled-up sleepy cat purring, eyes shut, little zigzag purr lines"},
	"snd_beep": {"pivot": "center", "look": "a little robot with a speech of beep lines"},
	"snd_gurgle": {"pivot": "center", "look": "a slime blob gurgling with bubbles"},
	"snd_boing": {"pivot": "center", "look": "a coiled spring bouncing"},
	"snd_trill": {"pivot": "center", "look": "a little alien in a flying saucer warbling"},
	"snd_honk": {"pivot": "center", "look": "a goose's face honking"},
}

## Paper laid under every shape first, so each icon is opaque like a cut-out sticker.
const PAPER := Color("#fffdf8")
const SHINE := Color(1, 1, 1, 0.62)
## Pupils and noses: the darkest thing in the set, a dark plum - never black (creatures own black).
const PLUM := Color("#47365f")
## The sound arcs every noisy picture shares, and the inside of every open mouth.
const WAVE := Color("#9d8af4")
const MAW := Color("#c8607e")
const TONGUE := Color("#f79ab0")


static func assets() -> Dictionary:
	return ASSETS


static func draw(id: String, c: CanvasItem) -> void:
	match id:
		"tool_crayon":
			_tool_crayon(c)
		"tool_fill":
			_tool_fill(c)
		"tool_eraser":
			_tool_eraser(c)
		"tool_dot":
			_tool_dot(c)
		"tool_undo":
			_tool_undo(c)
		"tool_clear":
			_tool_clear(c)
		"tool_done":
			_tool_done(c)
		"tool_back":
			_tool_back(c)
		"tool_skip":
			_tool_skip(c)
		"tool_zoom_in":
			_tool_zoom(c, true)
		"tool_zoom_out":
			_tool_zoom(c, false)
		"tool_fit":
			_tool_fit(c)
		"tool_hand":
			_tool_hand(c)
		"edit_turn_left":
			_turn_arrow(c, false)
		"edit_turn_right":
			_turn_arrow(c, true)
		"edit_bigger":
			_resize(c, true)
		"edit_smaller":
			_resize(c, false)
		"edit_flip":
			_flip(c)
		"edit_layer":
			_layer(c)
		"edit_copy":
			_copy(c)
		"edit_remove":
			_bin(c)
		"part_body":
			_part_body(c)
		"part_head":
			_part_head(c)
		"part_arm":
			_part_arm(c)
		"part_leg":
			_part_leg(c)
		"part_eye":
			_part_eye(c)
		"part_mouth":
			_part_mouth(c)
		"part_ear":
			_part_ear(c)
		"part_horn":
			_part_horn(c)
		"part_antenna":
			_part_antenna(c)
		"part_hair":
			_part_hair(c)
		"part_nose":
			_part_nose(c)
		"part_wing":
			_part_wing(c)
		"part_tail":
			_part_tail(c)
		"part_fin":
			_part_fin(c)
		"part_spike":
			_part_spike(c)
		"part_tentacle":
			_part_tentacle(c)
		"part_other":
			_part_other(c)
		"part_hand":
			_part_hand(c)
		"part_foot":
			_part_foot(c)
		"part_claw":
			_part_claw(c)
		"size_tiny":
			_mouse(c)
		"size_small":
			_cat(c)
		"size_medium":
			_dog(c)
		"size_big":
			_horse(c)
		"size_huge":
			_elephant(c)
		"size_giant":
			_dino(c)
		"ui_adopt":
			_adopt(c)
		"ui_point":
			_point(c)
		"ui_build":
			_hammer(c)
		"ui_sign":
			_sign(c)
		"ui_plus":
			_plus(c)
		"ui_minus":
			_minus(c)
		"ui_let_go":
			_let_go(c)
		"ui_move_home":
			_move_home(c)
		"ui_settings":
			_settings(c)
		"snd_play":
			_play(c)
		"snd_record":
			_record(c)
		"snd_stop":
			_stop(c)
		"snd_dice":
			_dice(c)
		"snd_speaker":
			_speaker(c)
		"snd_music":
			_music(c)
		"snd_voice":
			_voice(c)
		"snd_mic_off":
			_mic_off(c)
		"snd_high":
			_high(c)
		"snd_low":
			_low(c)
		"snd_fast":
			_fast(c)
		"snd_slow":
			_slow(c)
		"snd_flat":
			_flat(c)
		"snd_wobble":
			_wobble(c)
		"snd_echo":
			_echo(c)
		"snd_bend_up":
			_bend(c, true)
		"snd_bend_down":
			_bend(c, false)
		"snd_robot":
			_robot(c)
		"snd_backwards":
			_backwards(c)
		"snd_bark":
			_bark(c)
		"snd_meow":
			_meow(c)
		"snd_chirp":
			_chirp(c)
		"snd_squeak":
			_squeak(c)
		"snd_moo":
			_moo(c)
		"snd_roar":
			_roar(c)
		"snd_hoot":
			_hoot(c)
		"snd_ribbit":
			_ribbit(c)
		"snd_quack":
			_quack(c)
		"snd_oink":
			_oink(c)
		"snd_baa":
			_baa(c)
		"snd_trumpet":
			_trumpet(c)
		"snd_purr":
			_purr(c)
		"snd_beep":
			_beep(c)
		"snd_gurgle":
			_gurgle(c)
		"snd_boing":
			_boing(c)
		"snd_trill":
			_trill(c)
		"snd_honk":
			_honk(c)


# --- Drawing tools -----------------------------------------------------------------------------

## Marker: a fat red wax crayon lying corner to corner, tip down at the left, finishing a wave.
static func _tool_crayon(c: CanvasItem) -> void:
	var red := Color("#ef6b6b")
	var from := Vector2(40, 452)
	var to := Vector2(156, 348)
	var nrm := (to - from).normalized().orthogonal()
	var wave := PackedVector2Array()
	for i in 41:
		var t := i / 40.0
		wave.append(from.lerp(to, t) + nrm * sin(t * TAU * 1.5) * 34.0 * (0.5 + 0.5 * t))
	_frame(c, wave, red, 18.0, 701, false)
	var at := Vector2(300, 200)
	var ang := deg_to_rad(-45)
	var mid := Vector2(210, 0)
	var tip := _union([PackedVector2Array([Vector2(10, -16), Vector2(84, -52), Vector2(84, 52), Vector2(10, 16)]),
		Crayon.ellipse(Vector2(12, 0), Vector2(14, 18), 16)])
	_mark(c, _place(tip, mid, at, ang), red.darkened(0.08), 702, 10.0)
	_mark(c, _place(Crayon.rounded_rect(Rect2(76, -60, 330, 120), 22), mid, at, ang), red, 703, 11.0)
	var wrap := _place(Crayon.rounded_rect(Rect2(134, -62, 224, 124), 6), mid, at, ang)
	_mark(c, wrap, red.lightened(0.5), 704, 9.0)
	for x in [162.0, 330.0]:
		var stripe := _place(PackedVector2Array([Vector2(x - 10, -62), Vector2(x + 10, -62),
			Vector2(x + 10, 62), Vector2(x - 10, 62)]), mid, at, ang)
		for piece in Geometry2D.intersect_polygons(stripe, wrap):
			Crayon.marker_fill(c, piece, red, 705 + int(x), 12.0)
	Crayon.marker_line(c, _place(PackedVector2Array([Vector2(186, 0), Vector2(306, 0)]), mid, at, ang),
		red.darkened(0.15), 9.0, 706, false)
	Crayon.line(c, _place1(Vector2(90, -36), mid, at, ang), _place1(Vector2(390, -36), mid, at, ang), SHINE, 10.0, 707)


## Marker: a blue paint bucket tipping over, pink paint pouring off its lip into a puddle.
static func _tool_fill(c: CanvasItem) -> void:
	var blue := Color("#79aeea")
	var paint := Color("#f48fb8")
	var at := Vector2(326, 200)
	var ang := deg_to_rad(-60)
	var o := Vector2.ZERO
	_frame(c, _place(_arc(Vector2(0, -60), Vector2(124, 226), 0.0, PI, 28), o, at, ang), Color("#bbb6da"), 14.0, 711, false)
	var body := _join([[Vector2(-112, -100), Vector2(112, -100)], _arc(Vector2(0, 104), Vector2(86, 22), 0.0, PI, 14)])
	body = _place(body, o, at, ang)
	_under(c, body)
	Crayon.marker_fill(c, body, blue, 712)
	var band := _place(PackedVector2Array([Vector2(-140, 10), Vector2(140, 10), Vector2(140, 44), Vector2(-140, 44)]), o, at, ang)
	for piece in Geometry2D.intersect_polygons(band, body):
		Crayon.marker_fill(c, piece, blue.lightened(0.4), 713, 14.0)
	Crayon.line(c, _place1(Vector2(-80, -70), o, at, ang), _place1(Vector2(-62, 90), o, at, ang), SHINE, 13.0, 714)
	Crayon.marker_line(c, body, blue.darkened(0.5), 11.0, 715)
	_mark(c, _place(Crayon.ellipse(Vector2(0, -100), Vector2(114, 30), 36), o, at, ang), blue.lightened(0.2), 716, 10.0)
	var surface := _place(Crayon.ellipse(Vector2(0, -100), Vector2(92, 18), 32), o, at, ang)
	_under(c, surface)
	Crayon.marker_fill(c, surface, paint, 717, 14.0)
	var lip := _place1(Vector2(-96, -98), o, at, ang)
	var stream := _cubic(lip, lip + Vector2(-50, 40), Vector2(150, 320), Vector2(152, 410), 18)
	var pour := _union([_band(stream, 66.0, 50.0), Crayon.ellipse(lip, Vector2(40, 34), 20),
		Crayon.blob(Vector2(176, 436), Vector2(126, 38), 718, 22, 0.06)])
	_mark(c, pour, paint, 719, 11.0)
	Crayon.line(c, Vector2(176, 300), Vector2(162, 380), SHINE, 10.0, 720)


## Marker: a pink-and-blue rubber eraser block, tilted, with pink crumbs rubbed off its end.
static func _tool_eraser(c: CanvasItem) -> void:
	var pink := Color("#f7a0b4")
	var blue := Color("#7fb6ee")
	var crumbs := [[Vector2(70, 418), 22.0], [Vector2(124, 452), 18.0], [Vector2(62, 470), 15.0],
		[Vector2(176, 474), 13.0], [Vector2(112, 392), 12.0]]
	for i in crumbs.size():
		var at: Vector2 = crumbs[i][0]
		var r: float = crumbs[i][1]
		_pen(c, Crayon.blob(at, Vector2(r, r * 0.85), 721 + i, 10, 0.18), pink, 726 + i, 7.0)
	var at := Vector2(296, 222)
	var ang := deg_to_rad(-28)
	var mid := Vector2(13, 5)
	var k := Vector2(56, -66)
	_block(c, Rect2(-180, -20, 196, 120), k, pink, 731, mid, at, ang)
	_block(c, Rect2(10, -26, 146, 132), k, blue, 741, mid, at, ang)
	for y in [16.0, 64.0]:
		Crayon.line(c, _place1(Vector2(30, y), mid, at, ang), _place1(Vector2(136, y), mid, at, ang),
			Color(1, 1, 1, 0.55), 7.0, 751 + int(y))
	Crayon.line(c, _place1(Vector2(-160, 6), mid, at, ang), _place1(Vector2(-20, 6), mid, at, ang), SHINE, 11.0, 753)


## Marker: a red map pin with a pale hole, standing on its point over a little shadow.
static func _tool_dot(c: CanvasItem) -> void:
	var red := Color("#ef6262")
	_pen(c, Crayon.ellipse(Vector2(256, 462), Vector2(90, 22), 32), Color("#d3cff0"), 761, 7.0)
	var at := Vector2(256, 196)
	var pin := _arc(at, Vector2(150, 150), deg_to_rad(147.6), deg_to_rad(392.4), 44)
	pin.append(Vector2(256, 464))
	_mark(c, pin, red, 762, 12.0)
	_shine(c, _arc(at, Vector2(114, 114), PI * 1.08, PI * 1.42, 10), 16.0, 763)
	var hole := Crayon.ellipse(at, Vector2(58, 58), 32)
	_under(c, hole)
	Crayon.pencil_fill(c, hole, Color("#fff1e8"), 764)
	Crayon.marker_line(c, hole, red.darkened(0.45), 10.0, 765)


## Marker: a fat orange arrow curling round from the bottom right and pointing back LEFT.
static func _tool_undo(c: CanvasItem) -> void:
	var orange := Color("#f7a04a")
	var path := _cubic(Vector2(306, 428), Vector2(478, 420), Vector2(470, 178), Vector2(290, 178), 28)
	path.append(Vector2(214, 178))
	var arrow := _union([_arrow(path, 94.0, 128.0, 240.0), Crayon.ellipse(path[0], Vector2(47, 47), 20)])
	_mark(c, arrow, orange, 771, 12.0)
	_shine(c, _offset(path.slice(12, 29), -24.0), 12.0, 772)


## Marker: a magnifying glass - a pale blue lens in a lavender rim, a stubby orange handle, and a
## plus (or a minus) in the lens.
static func _tool_zoom(c: CanvasItem, plus: bool) -> void:
	var at := Vector2(214, 214)
	var handle := PackedVector2Array([Vector2(318, 286), Vector2(286, 318), Vector2(420, 452), Vector2(452, 420)])
	_mark(c, _round_poly(handle, 22.0), Color("#f7a04a"), 3101, 11.0)
	_mark(c, Crayon.ellipse(at, Vector2(156, 156), 36), Color("#b9a6f0"), 3102, 11.0)
	_mark(c, Crayon.ellipse(at, Vector2(112, 112), 32), Color("#e4f2fd"), 3103, 8.0)
	var sign := Color("#3b6fd6")
	_mark(c, _round_poly(PackedVector2Array([Vector2(150, 196), Vector2(278, 196), Vector2(278, 232),
		Vector2(150, 232)]), 14.0), sign, 3104, 8.0)
	if plus:
		_mark(c, _round_poly(PackedVector2Array([Vector2(196, 150), Vector2(232, 150), Vector2(232, 278),
			Vector2(196, 278)]), 14.0), sign, 3105, 8.0)
	_shine(c, PackedVector2Array([Vector2(150, 160), Vector2(176, 132), Vector2(210, 118)]), 12.0, 3106)


## Marker: a picture frame - see the whole page - with a fat orange arrow out of each corner.
static func _tool_fit(c: CanvasItem) -> void:
	_mark(c, _round_poly(PackedVector2Array([Vector2(146, 166), Vector2(366, 166), Vector2(366, 346),
		Vector2(146, 346)]), 18.0), Color("#b9a6f0"), 3201, 11.0)
	_mark(c, _round_poly(PackedVector2Array([Vector2(184, 202), Vector2(328, 202), Vector2(328, 310),
		Vector2(184, 310)]), 10.0), Color("#fffdf6"), 3202, 7.0)
	var corners := [[Vector2(150, 170), Vector2(-1, -1)], [Vector2(362, 170), Vector2(1, -1)],
		[Vector2(362, 342), Vector2(1, 1)], [Vector2(150, 342), Vector2(-1, 1)]]
	for i in corners.size():
		var from: Vector2 = corners[i][0]
		var d: Vector2 = (corners[i][1] as Vector2).normalized()
		var path := PackedVector2Array([from - d * 6.0, from + d * 40.0, from + d * 74.0])
		_mark(c, _arrow(path, 26.0, 44.0, 74.0), Color("#f7a04a"), 3210 + i, 8.0)


## Marker: an open hand, fingers spread - for sliding the page about.
static func _tool_hand(c: CanvasItem) -> void:
	var skin := Color("#f6c7a1")
	var bits := [_round_poly(PackedVector2Array([Vector2(160, 250), Vector2(352, 250), Vector2(340, 430),
		Vector2(186, 440)]), 60.0)]
	var fingers := [[Vector2(190, 320), Vector2(168, 150)], [Vector2(230, 300), Vector2(226, 96)],
		[Vector2(276, 300), Vector2(284, 106)], [Vector2(318, 310), Vector2(338, 156)]]
	for f in fingers:
		bits.append(_capsule(f[0], f[1], 46.0))
	bits.append(_capsule(Vector2(320, 380), Vector2(438, 290), 50.0))
	_mark(c, _union(bits), skin, 3301, 11.0)


## Marker: a cartoon hand pointing up - a chunky index finger with a fingernail, the other
## fingers curled into a squarish fist (their knuckles showing down its side), the thumb tucked
## across them, a straight wrist and a blue sleeve cuff. Its fingertip is the pivot, so it can touch exactly where
## to tap.
static func _point(c: CanvasItem) -> void:
	var skin := Color("#f6c7a1")
	var cuff := Color("#8fc4ee")
	var line := skin.darkened(0.45)
	# The fist: a squarish palm on a straight wrist, the three curled fingers as bumps down its
	# right side, and the index finger standing up from its left.
	var hand := [_round_poly(PackedVector2Array([Vector2(172, 232), Vector2(348, 232), Vector2(350, 404),
		Vector2(176, 404)]), 46.0)]
	hand.append(PackedVector2Array([Vector2(200, 360), Vector2(338, 360), Vector2(334, 452), Vector2(204, 452)]))
	for i in 3:
		var y := 258.0 + i * 50.0
		hand.append(_capsule(Vector2(312, y), Vector2(352, y + 2), 54.0))
	hand.append(_capsule(Vector2(226, 300), Vector2(226, 82), 90.0))
	_mark(c, _union(hand), skin, 3402, 11.0)
	_mark(c, _round_poly(PackedVector2Array([Vector2(184, 424), Vector2(354, 424), Vector2(358, 500),
		Vector2(180, 500)]), 20.0), cuff, 3401, 10.0)
	# Where the curled fingers meet, and the thumb tucked across their front - fat at its root on
	# the palm's left edge, rounding off at its tip in the middle.
	for i in 2:
		var y := 284.0 + i * 50.0
		Crayon.marker_line(c, PackedVector2Array([Vector2(370, y), Vector2(328, y + 4)]), line, 8.0, 3403 + i, false)
	var thumb := _union([Crayon.ellipse(Vector2(208, 382), Vector2(38, 34), 20),
		_capsule(Vector2(214, 376), Vector2(278, 326), 48.0)])
	_mark(c, thumb, skin.lightened(0.05), 3405, 9.0)
	# A fingernail near the tip, and a shine down the finger.
	var nail := Crayon.ellipse(Vector2(226, 114), Vector2(22, 26), 16)
	Crayon.marker_fill(c, nail, Color("#fde3d0"), 3406)
	Crayon.marker_line(c, nail, line.lightened(0.25), 5.0, 3407)
	Crayon.line(c, Vector2(206, 152), Vector2(206, 236), SHINE, 10.0, 3408)


## Pencil: a crumpled ball of paper - a jagged round lump, creases criss-crossing it, a shaded side.
static func _tool_clear(c: CanvasItem) -> void:
	var white := Color("#fffaf0")
	var shade := Color("#dcdcf2")
	var line := Color("#8c90c0")
	var at := Vector2(256, 256)
	var ball := PackedVector2Array()
	for i in 24:
		var a := TAU * i / 24.0
		var r := 190.0 * (1.0 + Crayon.noise(781, i) * 0.06) * (0.9 if i % 2 == 1 else 1.0)
		ball.append(at + Vector2(cos(a) * r, sin(a) * r * 0.94))
	_under(c, ball)
	Crayon.pencil_fill(c, ball, white, 782)
	for piece in Geometry2D.clip_polygons(ball, _shift(ball, Vector2(-46, -42))):
		Crayon.pencil_fill(c, piece, shade, 783)
	var nodes := [at + Vector2(-34, -30), at + Vector2(46, 20), at + Vector2(-58, 62), at + Vector2(30, -84),
		at + Vector2(92, 104), at + Vector2(-110, -60)]
	var facets := [[0, 3, -19], [1, 4, -2], [2, 5, -12], [0, 2, 1]]
	for i in facets.size():
		var f := PackedVector2Array()
		for j: int in facets[i]:
			if j < 0:
				f.append(ball[-j])
			else:
				var q: Vector2 = nodes[j]
				f.append(q)
		Crayon.pencil_fill(c, f, shade, 784 + i)
	var creases := [[0, 1], [0, 2], [0, 3], [1, 4], [1, 3], [2, 4], [0, 5], [5, 2],
		[0, -15], [3, -19], [3, -21], [1, -1], [4, -4], [4, -7], [2, -9], [5, -13], [5, -11], [1, -23]]
	for i in creases.size():
		var ia: int = creases[i][0]
		var ib: int = creases[i][1]
		var a: Vector2 = nodes[ia]
		var b: Vector2 = ball[absi(ib)]
		if ib >= 0:
			b = nodes[ib]
		Crayon.pencil_line(c, PackedVector2Array([a, a.lerp(b, 0.94)]), line, 6.0, 790 + i, false)
	Crayon.pencil_line(c, ball, line, 11.0, 811)


## Marker: a big green tick.
static func _tool_done(c: CanvasItem) -> void:
	var green := Color("#5fc87a")
	var tick := _union([_capsule(Vector2(84, 266), Vector2(200, 384), 104), _capsule(Vector2(200, 384), Vector2(436, 118), 104)])
	_mark(c, tick, green, 811, 12.0)
	Crayon.line(c, Vector2(100, 250), Vector2(180, 330), SHINE, 13.0, 812)
	Crayon.line(c, Vector2(250, 300), Vector2(410, 122), SHINE, 13.0, 813)


## Marker: a thick blue arrow pointing LEFT.
static func _tool_back(c: CanvasItem) -> void:
	var blue := Color("#6aaeee")
	var path := PackedVector2Array([Vector2(420, 256), Vector2(330, 256), Vector2(236, 256)])
	var arrow := _union([_arrow(path, 128.0, 158.0, 334.0), Crayon.ellipse(path[0], Vector2(64, 64), 24)])
	_mark(c, arrow, blue, 821, 12.0)
	Crayon.line(c, Vector2(250, 224), Vector2(420, 224), SHINE, 13.0, 822)


## Marker: a purple arrow hopping over a little coral post, landing to the RIGHT.
static func _tool_skip(c: CanvasItem) -> void:
	_mark(c, _capsule(Vector2(256, 330), Vector2(256, 456), 48), Color("#f27a6e"), 831, 11.0)
	var path := _cubic(Vector2(66, 418), Vector2(90, 70), Vector2(410, 60), Vector2(428, 330), 32)
	var arrow := _union([_arrow(path, 60.0, 96.0, 164.0), Crayon.ellipse(path[0], Vector2(30, 30), 16)])
	_mark(c, arrow, Color("#9d8af4"), 832, 12.0)
	_shine(c, _offset(path.slice(8, 22), 14.0), 10.0, 833)


# --- Assembly edits ----------------------------------------------------------------------------

## Marker: a teal arrow going round a yellow dot - anticlockwise, or mirrored for clockwise.
static func _turn_arrow(c: CanvasItem, clockwise: bool) -> void:
	var at := Vector2(256, 274)
	var path := _arc(at, Vector2(148, 148), deg_to_rad(192), deg_to_rad(-98), 48)
	var shine := _arc(at, Vector2(170, 170), deg_to_rad(150), deg_to_rad(110), 8)
	if clockwise:
		path = _mirror(path, 256.0)
		shine = _mirror(shine, 256.0)
	_mark(c, _arrow(path, 66.0, 104.0, 176.0), Color("#4fb6dc"), 841, 12.0)
	_shine(c, shine, 12.0, 842)
	_mark(c, Crayon.ellipse(at, Vector2(42, 42), 24), Color("#ffd75e"), 843, 10.0)


## A pale big square, a bright small square in its corner, and an arrow between their corners:
## outward and green to grow, inward and red to shrink.
static func _resize(c: CanvasItem, grow: bool) -> void:
	var blue := Color("#7fb6ee")
	var big := Crayon.rounded_rect(Rect2(52, 52, 408, 408), 34)
	_under(c, big)
	Crayon.pencil_fill(c, big, Color("#e2eefc"), 851)
	Crayon.pencil_line(c, big, blue.darkened(0.45), 11.0, 852)
	_mark(c, Crayon.rounded_rect(Rect2(84, 286, 144, 144), 20), blue, 853, 11.0)
	if grow:
		var path := PackedVector2Array([Vector2(246, 268), Vector2(320, 194), Vector2(382, 132)])
		_mark(c, _arrow(path, 50.0, 84.0, 136.0), Color("#5fc87a"), 854, 11.0)
	else:
		var path := PackedVector2Array([Vector2(414, 98), Vector2(340, 172), Vector2(284, 228)])
		_mark(c, _arrow(path, 50.0, 84.0, 136.0), Color("#f27a6e"), 855, 11.0)


## Marker: a purple triangle, its pale mirror image across a dashed line, a flip arrow above.
static func _flip(c: CanvasItem) -> void:
	var lav := Color("#aaa4ea")
	var y := 150.0
	var k := 0
	while y < 456.0:
		Crayon.marker_line(c, PackedVector2Array([Vector2(256, y), Vector2(256, minf(y + 30.0, 460.0))]),
			lav, 13.0, 861 + k, false)
		y += 50.0
		k += 1
	var left := PackedVector2Array([Vector2(222, 184), Vector2(222, 446), Vector2(52, 446)])
	_mark(c, left, Color("#9d8af4"), 871, 12.0)
	_mark(c, _mirror(left, 256.0), Color("#ddd6fc"), 872, 12.0)
	var path := _cubic(Vector2(128, 146), Vector2(168, 46), Vector2(338, 44), Vector2(378, 120), 20)
	var arrow := _union([_arrow(path, 34.0, 60.0, 104.0), Crayon.ellipse(path[0], Vector2(17, 17), 12)])
	_mark(c, arrow, Color("#f7a04a"), 873, 10.0)


## Marker: a blue card behind a yellow card with a star, and a purple up-and-down arrow.
static func _layer(c: CanvasItem) -> void:
	_mark(c, Crayon.rounded_rect(Rect2(40, 54, 232, 290), 30), Color("#7fb6ee"), 881, 11.0)
	Crayon.line(c, Vector2(66, 90), Vector2(66, 300), SHINE, 11.0, 882)
	_mark(c, Crayon.rounded_rect(Rect2(128, 168, 232, 290), 30), Color("#ffd36b"), 883, 11.0)
	_mark(c, Crayon.star(Vector2(244, 318), 70.0, 884), Color("#f48fb8"), 885, 9.0)
	var path := PackedVector2Array([Vector2(440, 170), Vector2(440, 344)])
	var down := _arrow(path, 46.0, 78.0, 126.0)
	var path2 := PackedVector2Array([Vector2(440, 344), Vector2(440, 170)])
	_mark(c, _union([down, _arrow(path2, 46.0, 78.0, 126.0)]), Color("#a585ee"), 886, 11.0)


## Pencil: two pale blue sheets with lines on them, one behind the other, and a green plus.
static func _copy(c: CanvasItem) -> void:
	var sheet := Color("#d9e8fb")
	var ink := Color("#8db2e0")
	for k in 2:
		var r := Rect2(48 + k * 92, 36 + k * 80, 250, 318)
		var page := Crayon.rounded_rect(r, 24)
		_under(c, page)
		Crayon.pencil_fill(c, page, sheet, 891 + k)
		for i in 4:
			var y := r.position.y + 72.0 + i * 54.0
			var x1 := r.end.x - 42.0 - (70.0 if i == 3 else 0.0)
			Crayon.line(c, Vector2(r.position.x + 42, y), Vector2(x1, y), ink, 10.0, 893 + k * 4 + i)
		Crayon.pencil_line(c, page, Color("#5f8cc4"), 11.0, 901 + k)
	var at := Vector2(384, 388)
	_mark(c, _union([_capsule(at + Vector2(-74, 0), at + Vector2(74, 0), 58),
		_capsule(at + Vector2(0, -74), at + Vector2(0, 74), 58)]), Color("#5fc87a"), 903, 11.0)


## Marker: a coral bin with ribs, its lid tipped up off the left side like it is about to eat.
static func _bin(c: CanvasItem) -> void:
	var red := Color("#ee7a6e")
	var body := PackedVector2Array([Vector2(128, 200), Vector2(384, 200), Vector2(354, 458), Vector2(158, 458)])
	_mark(c, body, red, 911, 12.0)
	for i in 3:
		var x := 202.0 + i * 54.0
		Crayon.marker_line(c, PackedVector2Array([Vector2(x, 248), Vector2(256.0 + (x - 256.0) * 0.9, 420)]),
			red.darkened(0.3), 9.0, 912 + i, false)
	Crayon.line(c, Vector2(156, 236), Vector2(176, 420), SHINE, 12.0, 915)
	_mark(c, Crayon.rounded_rect(Rect2(110, 182, 292, 44), 18), red.lightened(0.18), 916, 11.0)
	var at := Vector2(244, 120)
	var ang := deg_to_rad(22)
	_mark(c, _place(Crayon.rounded_rect(Rect2(-42, -66, 84, 50), 18), Vector2.ZERO, at, ang), red.lightened(0.1), 917, 10.0)
	_mark(c, _place(Crayon.rounded_rect(Rect2(-160, -26, 320, 52), 20), Vector2.ZERO, at, ang), red.lightened(0.18), 918, 11.0)


# --- Body parts --------------------------------------------------------------------------------

## Pencil: a plain mint blob body - round and a little lumpy, a pale tummy low down.
static func _part_body(c: CanvasItem) -> void:
	var mint := Color("#8ed6a6")
	var at := Vector2(256, 256)
	var body := PackedVector2Array()
	for i in 44:
		var a := TAU * i / 44.0
		var rx := 196.0 + 10.0 * sin(a)
		var ry := 182.0
		body.append(at + Vector2(cos(a) * rx, sin(a) * ry) * (1.0 + Crayon.noise(931, i / 4) * 0.025))
	_pen(c, body, mint, 932, 11.0)
	var belly := Crayon.blob(at + Vector2(14, 84), Vector2(118, 80), 933, 18, 0.04)
	_under(c, belly)
	Crayon.pencil_fill(c, belly, Color("#e3f6e8"), 934)
	Crayon.pencil_line(c, belly, mint.darkened(0.3), 7.0, 935)
	_shine(c, _arc(at, Vector2(146, 132), PI * 1.06, PI * 1.38, 10), 18.0, 937)


## Pencil: a round peach head facing right - snout, one big eye, a smile and a pink cheek.
static func _part_head(c: CanvasItem) -> void:
	var peach := Color("#f9b27c")
	var head := _union([Crayon.ellipse(Vector2(226, 256), Vector2(172, 168), 48),
		Crayon.ellipse(Vector2(366, 304), Vector2(98, 78), 32)])
	_pen(c, head, peach, 941, 11.0)
	Crayon.pencil_fill(c, Crayon.ellipse(Vector2(290, 338), Vector2(38, 24), 20), Color("#f7909c"), 942)
	var eye := Crayon.ellipse(Vector2(318, 214), Vector2(44, 52), 28)
	_under(c, eye)
	Crayon.pencil_fill(c, eye, Color("#fffaf0"), 943)
	Crayon.pencil_line(c, eye, peach.darkened(0.45), 8.0, 944)
	_pupil(c, Vector2(336, 222), 25.0)
	Crayon.marker_line(c, _cubic(Vector2(346, 350), Vector2(372, 386), Vector2(420, 384), Vector2(444, 342), 12),
		peach.darkened(0.48), 10.0, 945, false)
	_mark(c, Crayon.ellipse(Vector2(452, 292), Vector2(18, 15), 16), Color("#e98a7e"), 946, 7.0)
	_shine(c, _arc(Vector2(226, 256), Vector2(130, 128), PI * 1.06, PI * 1.36, 10), 16.0, 947)


## Pencil: a bendy blue noodle arm from the shoulder, elbow bent, a mitten hand waving up top.
static func _part_arm(c: CanvasItem) -> void:
	var sky := Color("#86c2f0")
	var path := _cubic(Vector2(104, 456), Vector2(96, 316), Vector2(292, 372), Vector2(294, 258), 24)
	var end := path[path.size() - 1]
	var dir := (end - path[path.size() - 4]).normalized()
	var ang := atan2(dir.x, -dir.y) + deg_to_rad(12)
	var fingers := []
	for a in [-34.0, 0.0, 34.0]:
		var d := Vector2(sin(deg_to_rad(a)), -cos(deg_to_rad(a)))
		fingers.append(_capsule(Vector2(0, -36) + d * 10.0, Vector2(0, -36) + d * 118.0, 50))
	var hand := _union([Crayon.rounded_rect(Rect2(-70, -60, 140, 124), 56), fingers[0], fingers[1], fingers[2],
		_capsule(Vector2(-50, 16), Vector2(-122, -28), 50)])
	hand = _place(hand, Vector2(0, 56), end, ang)
	var arm := _union([_band(path, 92.0, 80.0), Crayon.ellipse(path[0], Vector2(46, 22), 20), hand])
	_pen(c, arm, sky, 951, 11.0)
	_shine(c, _offset(path.slice(2, 14), 26.0), 12.0, 953)


## Pencil: one lilac leg standing - thigh at the top, a knee, a round foot pointing right.
static func _part_leg(c: CanvasItem) -> void:
	var lilac := Color("#b8a2ee")
	var path := _cubic(Vector2(214, 46), Vector2(196, 170), Vector2(258, 250), Vector2(228, 384), 20)
	var leg := _union([_band(path, 136.0, 104.0), Crayon.ellipse(path[0], Vector2(68, 24), 20),
		Crayon.ellipse(Vector2(286, 408), Vector2(150, 62), 40),
		Crayon.rounded_rect(Rect2(150, 400, 270, 66), 28)])
	_pen(c, leg, lilac, 961, 11.0)
	Crayon.pencil_line(c, _cubic(Vector2(204, 250), Vector2(222, 238), Vector2(250, 236), Vector2(270, 244), 8),
		lilac.darkened(0.4), 7.0, 962, false)
	for i in 2:
		var x := 360.0 + i * 36.0
		Crayon.pencil_line(c, PackedVector2Array([Vector2(x, 466), Vector2(x - 4, 430)]), lilac.darkened(0.4), 7.0, 963 + i, false)
	_shine(c, _offset(path.slice(1, 12), -40.0), 12.0, 965)


## Pencil: one big cartoon eye - white, a teal iris, a dark plum pupil and two glints.
static func _part_eye(c: CanvasItem) -> void:
	var line := Color("#7f88c4")
	var eye := Crayon.ellipse(Vector2(256, 256), Vector2(176, 208), 56)
	_under(c, eye)
	Crayon.pencil_fill(c, eye, Color("#fffaf2"), 971)
	Crayon.pencil_fill(c, Crayon.ellipse(Vector2(232, 300), Vector2(130, 140), 40), Color("#eceefa"), 972)
	var iris := Crayon.ellipse(Vector2(282, 272), Vector2(112, 118), 48)
	_mark(c, iris, Color("#4fb6c8"), 973, 9.0)
	_pupil(c, Vector2(290, 278), 62.0)
	c.draw_colored_polygon(Crayon.ellipse(Vector2(330, 340), Vector2(14, 14), 16), Color(1, 1, 1, 0.9))
	Crayon.marker_line(c, eye, line, 13.0, 974)


## Marker: a wide open smile - rose inside, top teeth, a pink tongue, coral lips.
static func _part_mouth(c: CanvasItem) -> void:
	var mouth := _join([_cubic(Vector2(54, 170), Vector2(170, 236), Vector2(342, 236), Vector2(458, 170), 20),
		_cubic(Vector2(458, 170), Vector2(446, 470), Vector2(66, 470), Vector2(54, 170), 24)])
	_under(c, mouth)
	Crayon.marker_fill(c, mouth, Color("#c8607e"), 981)
	var teeth_top := _cubic(Vector2(40, 162), Vector2(170, 228), Vector2(342, 228), Vector2(472, 162), 20)
	var teeth := _join([teeth_top, _offset(_reverse(teeth_top), 44.0)])
	for piece in Geometry2D.intersect_polygons(teeth, mouth):
		_under(c, piece)
		Crayon.pencil_fill(c, piece, Color("#fffaf2"), 982)
		Crayon.pencil_line(c, piece, Color("#c4a4c4"), 6.0, 983)
	for piece in Geometry2D.intersect_polygons(Crayon.ellipse(Vector2(256, 418), Vector2(132, 92), 40), mouth):
		_under(c, piece)
		Crayon.marker_fill(c, piece, Color("#f79ab0"), 984)
		Crayon.marker_line(c, piece, Color("#f79ab0").darkened(0.45), 8.0, 985)
	Crayon.marker_line(c, PackedVector2Array([Vector2(256, 360), Vector2(256, 410)]), Color("#f79ab0").darkened(0.35),
		7.0, 986, false)
	_frame(c, mouth, Color("#f07a8c"), 18.0, 987)


## Marker and pencil: one tall pointy lavender ear, pink inside.
static func _part_ear(c: CanvasItem) -> void:
	var grey := Color("#b7aee0")
	var ear := _join([_cubic(Vector2(140, 448), Vector2(108, 300), Vector2(170, 130), Vector2(286, 40), 20),
		_cubic(Vector2(286, 40), Vector2(374, 150), Vector2(402, 320), Vector2(372, 448), 20),
		_cubic(Vector2(372, 448), Vector2(300, 474), Vector2(212, 474), Vector2(140, 448), 10)])
	_mark(c, ear, grey, 991, 12.0)
	var inner := _scale(ear, Vector2(262, 452), Vector2(0.56, 0.74))
	_under(c, inner)
	Crayon.pencil_fill(c, inner, Color("#f7b0c4"), 992)
	Crayon.pencil_line(c, inner, Color("#f7b0c4").darkened(0.4), 7.0, 993)
	Crayon.line(c, Vector2(180, 380), Vector2(214, 210), SHINE, 12.0, 994)


## Pencil: one curved ivory horn - wide ridged base, sweeping up and over to a point.
static func _part_horn(c: CanvasItem) -> void:
	var ivory := Color("#eec888")
	var spine := _cubic(Vector2(196, 462), Vector2(136, 330), Vector2(196, 160), Vector2(390, 48), 30)
	var horn := _band(spine, 184.0, 4.0)
	_under(c, horn)
	Crayon.pencil_fill(c, horn, ivory, 1001)
	var base := _band(spine.slice(0, 4), 200.0, 190.0)
	for piece in Geometry2D.intersect_polygons(base, horn):
		Crayon.pencil_fill(c, piece, ivory.darkened(0.12), 1002)
	for i: int in [3, 7, 11, 15, 19]:
		var p: Vector2 = spine[i]
		var d := (spine[i + 1] - spine[i - 1]).normalized()
		var w := lerpf(184.0, 4.0, i / 30.0) * 0.5
		Crayon.pencil_line(c, PackedVector2Array([p + d.orthogonal() * w, p + d * w * 0.3, p - d.orthogonal() * w]),
			ivory.darkened(0.4), 8.0, 1003 + i, false)
	_shine(c, _offset(spine.slice(4, 16), 34.0), 13.0, 1030)
	Crayon.pencil_line(c, horn, ivory.darkened(0.5), 11.0, 1031)


## Marker: a green springy stalk on a little base, a pink ball bobbing on top.
static func _part_antenna(c: CanvasItem) -> void:
	var green := Color("#6cc87a")
	var pink := Color("#f48fbf")
	var stalk := PackedVector2Array()
	for i in 121:
		var t := i / 120.0
		var a := t * 3.5 * TAU
		stalk.append(Vector2(244 + t * 40 + sin(a) * 42.0, lerpf(430, 190, t) + (1.0 - cos(a)) * 20.0))
	_frame(c, stalk, green, 20.0, 1041, false)
	_mark(c, _join([_arc(Vector2(250, 452), Vector2(124, 50), PI, TAU, 20)]), green.darkened(0.06), 1042, 11.0)
	var at := Vector2(294, 124)
	_mark(c, Crayon.ellipse(at, Vector2(88, 88), 40), pink, 1043, 12.0)
	_shine(c, _arc(at, Vector2(62, 62), PI * 1.06, PI * 1.42, 10), 15.0, 1044)


## Pencil: a tuft of hair - five pointed locks swooping up and out from a band.
static func _part_hair(c: CanvasItem) -> void:
	var col := Color("#e98cc4")
	var locks := [
		[Vector2(200, 440), Vector2(150, 330), Vector2(90, 290), Vector2(46, 214)],
		[Vector2(318, 440), Vector2(370, 330), Vector2(430, 300), Vector2(470, 222)],
		[Vector2(224, 440), Vector2(170, 300), Vector2(150, 170), Vector2(104, 100)],
		[Vector2(290, 440), Vector2(340, 300), Vector2(368, 170), Vector2(414, 102)],
		[Vector2(254, 440), Vector2(220, 300), Vector2(300, 170), Vector2(250, 36)]]
	var shapes := [Crayon.ellipse(Vector2(258, 440), Vector2(128, 36), 32)]
	var spines := []
	for l in locks:
		var spine := _cubic(l[0], l[1], l[2], l[3], 24)
		spines.append(spine)
		shapes.append(_band(spine, 116.0, 2.0))
	var hair := _union(shapes)
	_under(c, hair)
	Crayon.pencil_fill(c, hair, col, 1051)
	for i in spines.size():
		var s: PackedVector2Array = spines[i]
		Crayon.pencil_line(c, s.slice(3, 18), col.darkened(0.3), 6.0, 1052 + i, false)
	Crayon.pencil_line(c, hair, col.darkened(0.45), 11.0, 1060)


## Marker: a round pink button nose like a puppy's - two nostrils low down, a shine on top.
static func _part_nose(c: CanvasItem) -> void:
	var pink := Color("#f590a8")
	var nose := _join([_cubic(Vector2(58, 176), Vector2(78, 86), Vector2(434, 86), Vector2(454, 176), 20),
		_cubic(Vector2(454, 176), Vector2(472, 296), Vector2(340, 414), Vector2(256, 418), 20),
		_cubic(Vector2(256, 418), Vector2(172, 414), Vector2(40, 296), Vector2(58, 176), 20)])
	_mark(c, nose, pink, 1071, 12.0)
	var dark := pink.darkened(0.42)
	for side in 2:
		var sx := 1.0 if side == 0 else -1.0
		var at := Vector2(256 - sx * 78, 300)
		var nostril := _union([_turn(Crayon.ellipse(at, Vector2(44, 24), 24), at, sx * 0.42),
			Crayon.ellipse(at + Vector2(sx * 22, -10), Vector2(18, 18), 16)])
		_under(c, nostril)
		Crayon.marker_fill(c, nostril, dark.lightened(0.08), 1072 + side, 14.0)
		Crayon.marker_line(c, nostril, dark, 6.0, 1074 + side)
	Crayon.marker_line(c, PackedVector2Array([Vector2(256, 330), Vector2(256, 412)]), dark, 9.0, 1076, false)
	_mark(c, _turn(Crayon.ellipse(Vector2(176, 170), Vector2(72, 36), 28), Vector2(176, 170), -0.12), pink.lightened(0.6), 1077, 0.0)


## Pencil: one feathery wing - a row of long pointed flight feathers under a tapering scalloped edge.
static func _part_wing(c: CanvasItem) -> void:
	var blue := Color("#94c8f2")
	var root := Vector2(400, 222)
	var tips := [Vector2(44, 132), Vector2(54, 214), Vector2(88, 290), Vector2(144, 354), Vector2(218, 404),
		Vector2(304, 432)]
	for i in tips.size():
		var tip: Vector2 = tips[i]
		var feather := _leaf(PackedVector2Array([root, tip]), 128.0 - i * 6.0)
		_pen(c, feather, blue if i % 2 == 0 else blue.lightened(0.14), 1081 + i, 9.0)
		Crayon.pencil_line(c, PackedVector2Array([root.lerp(tip, 0.45), tip.lerp(root, 0.08)]), blue.darkened(0.3),
			5.0, 1088 + i, false)
	var edge := _cubic(Vector2(420, 212), Vector2(370, 130), Vector2(260, 100), Vector2(120, 118), 20)
	var parts := [_band(edge, 140.0, 50.0), Crayon.ellipse(edge[0], Vector2(66, 66), 24)]
	for k in 5:
		var t := k / 4.0
		var r := lerpf(52.0, 30.0, t)
		var p := _offset(edge, lerpf(60.0, 18.0, t))
		var q: Vector2 = p[int(lerpf(2.0, 15.0, t))]
		parts.append(Crayon.ellipse(q, Vector2(r, r), 18))
	var coverts := _union(parts)
	_pen(c, coverts, Color("#cde6fb"), 1095, 10.0)
	_shine(c, _offset(edge.slice(2, 16), -34.0), 13.0, 1096)


## Pencil: a big fluffy fox-orange tail sweeping up and curling over, a cream tip at the end.
static func _part_tail(c: CanvasItem) -> void:
	var orange := Color("#f7a45e")
	var pts := [Vector2(90, 480), Vector2(240, 484), Vector2(360, 420), Vector2(414, 312), Vector2(402, 206),
		Vector2(340, 132), Vector2(262, 104), Vector2(204, 132)]
	var path := _resample(_scale(_spline(pts, 12), Vector2(256, 290), Vector2(0.92, 0.92)), 5.0)
	var n := path.size()
	var widths := PackedFloat32Array()
	for i in n:
		var t := i / float(n - 1)
		widths.append((50.0 + 156.0 * smoothstep(0.0, 0.5, t)) * pow(1.0 - smoothstep(0.62, 1.0, t), 0.55))
	var tail := _fluffy_w(path, widths, 12.0, 0.05, 0.2)
	_under(c, tail)
	Crayon.pencil_fill(c, tail, orange, 1101)
	var i0 := int(n * 0.74)
	var p0 := path[i0]
	var d0 := (path[i0 + 1] - path[i0 - 1]).normalized()
	var n0 := d0.orthogonal()
	var cap := PackedVector2Array()
	for k in 13:
		cap.append(p0 + n0 * lerpf(-140.0, 140.0, k / 12.0) + d0 * (14.0 if k % 2 == 0 else -14.0))
	cap.append(p0 + n0 * 140.0 + d0 * 260.0)
	cap.append(p0 - n0 * 140.0 + d0 * 260.0)
	for piece in Geometry2D.intersect_polygons(cap, tail):
		_under(c, piece)
		Crayon.pencil_fill(c, piece, Color("#fff3dc"), 1102)
	for i in range(10, i0 - 4, 7):
		var p := path[i]
		var d := (path[i + 1] - path[i - 1]).normalized()
		var off := d.orthogonal() * widths[i] * (0.2 if (i / 7) % 2 == 0 else -0.22)
		Crayon.pencil_line(c, PackedVector2Array([p + off - d * 20.0, p + off + d * 22.0]), orange.darkened(0.3), 5.0,
			1103 + i, false)
	Crayon.pencil_line(c, tail, orange.darkened(0.45), 11.0, 1230)


## Marker: one teal fish fin - a fan of ribs with the webbing scalloped between them.
static func _part_fin(c: CanvasItem) -> void:
	var teal := Color("#5cc8c0")
	var pivot := Vector2(156, 432)
	var ribs := 6
	var fin := PackedVector2Array()
	for i in 97:
		var t := i / 96.0
		var a := deg_to_rad(lerpf(-108.0, -6.0, t))
		var r := 336.0 - 44.0 * pow(absf(sin(t * ribs * PI)), 0.7)
		fin.append(pivot + Vector2(cos(a), sin(a)) * r)
	fin.append(Vector2(206, 448))
	fin.append(Vector2(118, 456))
	_under(c, fin)
	Crayon.marker_fill(c, fin, teal, 1241)
	for k in range(1, ribs):
		var a := deg_to_rad(lerpf(-108.0, -6.0, k / float(ribs)))
		var d := Vector2(cos(a), sin(a))
		Crayon.marker_line(c, PackedVector2Array([pivot + d * 70.0, pivot + d * 318.0]), teal.darkened(0.3), 8.0, 1242 + k, false)
	Crayon.marker_line(c, fin, teal.darkened(0.5), 12.0, 1250)
	_mark(c, _turn(Crayon.ellipse(Vector2(160, 440), Vector2(74, 34), 28), Vector2(160, 440), -0.12), teal.darkened(0.1), 1251, 10.0)
	Crayon.line(c, Vector2(110, 160), Vector2(150, 360), SHINE, 12.0, 1252)


## Marker: three green spikes in a row, the middle one tallest, standing on a strip of back.
static func _part_spike(c: CanvasItem) -> void:
	var green := Color("#9bd86a")
	var spikes := [[Vector2(52, 410), Vector2(132, 150), Vector2(204, 410)],
		[Vector2(308, 410), Vector2(388, 150), Vector2(460, 410)],
		[Vector2(160, 410), Vector2(262, 40), Vector2(352, 410)]]
	for i in spikes.size():
		var l: Vector2 = spikes[i][0]
		var tip: Vector2 = spikes[i][1]
		var r: Vector2 = spikes[i][2]
		var spike := _join([_cubic(l, l.lerp(tip, 0.5) + Vector2(-6, 0), tip + Vector2(-14, 40), tip, 12),
			_cubic(tip, tip + Vector2(26, 60), r.lerp(tip, 0.4) + Vector2(14, 0), r, 12)])
		_mark(c, spike, green if i < 2 else green.lightened(0.1), 1261 + i, 12.0)
		Crayon.line(c, l.lerp(tip, 0.25) + Vector2(26, 0), l.lerp(tip, 0.8) + Vector2(6, 0), SHINE, 10.0, 1264 + i)
	_mark(c, Crayon.rounded_rect(Rect2(36, 384, 440, 80), 34), green.darkened(0.12), 1267, 12.0)


## Marker: a purple tentacle rising from a wide base and curling over at the tip, pale suckers inside.
static func _part_tentacle(c: CanvasItem) -> void:
	var purple := Color("#b98ae6")
	var pts := [Vector2(172, 474), Vector2(132, 360), Vector2(178, 262), Vector2(300, 232), Vector2(388, 170),
		Vector2(386, 84), Vector2(312, 52), Vector2(260, 92), Vector2(286, 140)]
	var path := _spline(pts, 10)
	var n := path.size()
	var tent := _union([_band(path, 156.0, 22.0), Crayon.ellipse(path[n - 1], Vector2(11, 11), 12)])
	_under(c, tent)
	Crayon.marker_fill(c, tent, purple, 1271)
	var k := 0
	for i in range(6, n - 8, 7):
		var t := i / float(n - 1)
		var w := lerpf(156.0, 22.0, t) * 0.5
		var d := (path[i + 1] - path[i - 1]).normalized()
		var p := path[i] + d.orthogonal() * w * 0.45
		var r := lerpf(30.0, 10.0, t)
		var s := Crayon.ellipse(p, Vector2(r, r * 0.85), 18)
		_under(c, s)
		Crayon.pencil_fill(c, s, Color("#fbe0f0"), 1272 + k)
		Crayon.pencil_line(c, s, purple.darkened(0.35), 6.0, 1290 + k)
		k += 1
	Crayon.marker_line(c, tent, purple.darkened(0.5), 12.0, 1310)


## Marker: a mystery part - a pink snail shell with a spiral on it, a yellow star twinkling by it.
static func _part_other(c: CanvasItem) -> void:
	var pink := Color("#f4a0a6")
	var at := Vector2(232, 290)
	_mark(c, Crayon.blob(at, Vector2(182, 172), 1321, 22, 0.03), pink, 1322, 12.0)
	var spiral := PackedVector2Array()
	for i in 121:
		var t := i / 120.0
		var a := t * 2.4 * TAU - 0.4
		spiral.append(at + Vector2(14, -6) + Vector2(cos(a), sin(a) * 0.94) * lerpf(10.0, 140.0, t))
	Crayon.marker_line(c, spiral, pink.darkened(0.42), 16.0, 1323, false)
	_shine(c, _arc(at, Vector2(150, 140), PI * 1.1, PI * 1.36, 10), 14.0, 1324)
	_mark(c, Crayon.star(Vector2(412, 104), 76.0, 1325), Color("#ffd75e"), 1326, 10.0)
	_mark(c, _sparkle(Vector2(470, 238), 30.0), Color("#ffe27a"), 1327, 7.0)


## Pencil: an open yellow hand-paw - three fat fingers and a thumb, pink pads on the palm and tips.
static func _part_hand(c: CanvasItem) -> void:
	var yellow := Color("#ffd36b")
	var pad := Color("#f7a0a8")
	var tips := [Vector2(150, 96), Vector2(256, 56), Vector2(362, 96)]
	var bases := [Vector2(196, 250), Vector2(256, 236), Vector2(316, 250)]
	var parts := [Crayon.rounded_rect(Rect2(140, 210, 232, 204), 84), Crayon.rounded_rect(Rect2(192, 380, 128, 92), 30),
		_capsule(Vector2(180, 342), Vector2(74, 268), 70)]
	for i in 3:
		parts.append(_capsule(bases[i], tips[i], 72))
	_pen(c, _union(parts), yellow, 1331, 11.0)
	for i in 3:
		var tip: Vector2 = tips[i]
		var base: Vector2 = bases[i]
		var p := tip.lerp(base, 0.12)
		Crayon.pencil_fill(c, Crayon.ellipse(p, Vector2(20, 20), 16), pad, 1332 + i)
		if i < 2:
			var tip2: Vector2 = tips[i + 1]
			var base2: Vector2 = bases[i + 1]
			Crayon.pencil_line(c, PackedVector2Array([tip.lerp(tip2, 0.5).lerp(base.lerp(base2, 0.5), 0.55),
				base.lerp(base2, 0.5) + Vector2(0, 6)]), yellow.darkened(0.45), 8.0, 1336 + i, false)
	var palm := _union([Crayon.ellipse(Vector2(262, 322), Vector2(64, 50), 28), Crayon.ellipse(Vector2(226, 296), Vector2(26, 26), 16),
		Crayon.ellipse(Vector2(298, 296), Vector2(26, 26), 16)])
	_pen(c, palm, pad, 1340, 7.0)
	Crayon.line(c, Vector2(160, 250), Vector2(162, 380), SHINE, 12.0, 1341)


## Marker: a tan foot from the side - ankle, round heel, and three toes in a row at the front.
static func _part_foot(c: CanvasItem) -> void:
	var tan := Color("#e6b483")
	var foot := _union([Crayon.rounded_rect(Rect2(108, 46, 150, 260), 44),
		Crayon.ellipse(Vector2(196, 376), Vector2(124, 86), 40),
		Crayon.rounded_rect(Rect2(90, 380, 300, 80), 36)])
	_mark(c, foot, tan, 1351, 12.0)
	var toes := [[Vector2(318, 358), 66.0], [Vector2(378, 382), 60.0], [Vector2(430, 412), 50.0]]
	for i in toes.size():
		var at: Vector2 = toes[i][0]
		var r: float = toes[i][1]
		var toe := _union([Crayon.ellipse(at, Vector2(r, r * 0.92), 28),
			Crayon.rounded_rect(Rect2(at.x - r, at.y, r * 2.0, 460.0 - at.y), r * 0.5)])
		_mark(c, toe, tan.lightened(0.05 * i), 1352 + i, 11.0)
		Crayon.pencil_fill(c, Crayon.ellipse(at + Vector2(r * 0.42, -r * 0.3), Vector2(r * 0.32, r * 0.24), 14),
			Color("#fff1dc"), 1356 + i)
	Crayon.line(c, Vector2(132, 80), Vector2(134, 280), SHINE, 13.0, 1360)


## Marker: a lavender paw reaching right, three thick ivory claws hooking down from its toes.
static func _part_claw(c: CanvasItem) -> void:
	var claw_col := Color("#f3dfb4")
	var paw := Color("#c3bce0")
	var toes := [Vector2(250, 150), Vector2(268, 256), Vector2(250, 362)]
	for i in 3:
		var t: Vector2 = toes[i]
		var spine := _cubic(t, t + Vector2(110, -14), t + Vector2(186, 6), t + Vector2(204, 82), 24)
		var claw := _band(spine, 80.0, 2.0)
		_under(c, claw)
		Crayon.marker_fill(c, claw, claw_col, 1371 + i)
		Crayon.line(c, t + Vector2(70, -26), t + Vector2(150, -20), Color(1, 1, 1, 0.8), 9.0, 1374 + i)
		Crayon.marker_line(c, claw, claw_col.darkened(0.5), 11.0, 1377 + i)
	var parts := [Crayon.rounded_rect(Rect2(40, 96, 220, 320), 100)]
	for i in 3:
		var t: Vector2 = toes[i]
		parts.append(Crayon.ellipse(t, Vector2(54, 48), 24))
	_mark(c, _union(parts), paw, 1381, 12.0)
	for i in 2:
		var a: Vector2 = toes[i]
		var b: Vector2 = toes[i + 1]
		var m := a.lerp(b, 0.5)
		Crayon.marker_line(c, PackedVector2Array([m + Vector2(-50, 0), m + Vector2(14, 0)]), paw.darkened(0.45), 9.0,
			1382 + i, false)
	Crayon.line(c, Vector2(76, 150), Vector2(80, 360), SHINE, 13.0, 1384)


# --- Size animals ------------------------------------------------------------------------------

## Marker: a lavender mouse from the side - round ears, pointy pink nose, long curly tail.
static func _mouse(c: CanvasItem) -> void:
	var grey := Color("#c3bce0")
	var pink := Color("#f6aec4")
	_frame(c, _cubic(Vector2(110, 392), Vector2(26, 440), Vector2(4, 300), Vector2(70, 264), 20), pink, 12.0, 1401, false)
	_mark(c, Crayon.ellipse(Vector2(226, 200), Vector2(58, 58), 28), grey.darkened(0.08), 1402, 10.0)
	var body := _join([
		_cubic(Vector2(466, 336), Vector2(414, 252), Vector2(334, 186), Vector2(244, 188)),
		_cubic(Vector2(244, 188), Vector2(142, 190), Vector2(80, 272), Vector2(94, 372)),
		_cubic(Vector2(94, 372), Vector2(106, 438), Vector2(240, 444), Vector2(330, 424)),
		_cubic(Vector2(330, 424), Vector2(400, 408), Vector2(444, 372), Vector2(466, 336))])
	_mark(c, body, grey, 1403, 11.0)
	Crayon.line(c, Vector2(150, 260), Vector2(130, 340), SHINE, 12.0, 1404)
	for f in [Vector2(196, 438), Vector2(328, 426)]:
		var at: Vector2 = f
		_mark(c, Crayon.ellipse(at, Vector2(36, 16), 20), pink, 1405 + int(at.x), 8.0)
	var ear_at := Vector2(306, 186)
	_mark(c, Crayon.ellipse(ear_at, Vector2(74, 74), 32), grey.lightened(0.08), 1406, 11.0)
	_pen(c, Crayon.ellipse(ear_at + Vector2(4, 4), Vector2(44, 44), 24), pink, 1407, 0.0)
	_pupil(c, Vector2(384, 276), 15.0)
	Crayon.pencil_fill(c, Crayon.ellipse(Vector2(388, 330), Vector2(24, 15), 16), pink, 1408)
	_mark(c, Crayon.ellipse(Vector2(462, 334), Vector2(19, 17), 16), Color("#f490b0"), 1409, 7.0)
	for i in 2:
		Crayon.line(c, Vector2(432, 340 + i * 12), Vector2(490, 318 + i * 44), grey.darkened(0.35), 4.0, 1410 + i)


## Marker: a ginger cat sitting side-on, its face turned to us, tail curling up behind.
static func _cat(c: CanvasItem) -> void:
	var ginger := Color("#f6a862")
	var dark := ginger.darkened(0.3)
	var tail := _cubic(Vector2(150, 440), Vector2(36, 446), Vector2(30, 300), Vector2(84, 226), 20)
	_mark(c, _union([_band(tail, 58.0, 46.0), Crayon.ellipse(tail[tail.size() - 1], Vector2(23, 23), 16)]),
		ginger.darkened(0.04), 1421, 11.0)
	var body := _union([Crayon.ellipse(Vector2(206, 364), Vector2(110, 96), 40),
		Crayon.ellipse(Vector2(292, 318), Vector2(84, 136), 40),
		Crayon.rounded_rect(Rect2(110, 380, 262, 80), 30)])
	_mark(c, body, ginger, 1422, 11.0)
	for i in 3:
		var a := deg_to_rad(200.0 + i * 26.0)
		var p := Vector2(196, 360) + Vector2(cos(a), sin(a)) * 80.0
		Crayon.marker_line(c, PackedVector2Array([p, p.lerp(Vector2(196, 360), 0.35)]), dark, 8.0, 1423 + i, false)
	for x in [300.0, 356.0]:
		_mark(c, _capsule(Vector2(x, 320), Vector2(x, 444), 56), ginger.lightened(0.06), 1426 + int(x), 10.0)
	var head := _union([Crayon.ellipse(Vector2(318, 176), Vector2(110, 94), 40),
		PackedVector2Array([Vector2(220, 156), Vector2(232, 34), Vector2(306, 100)]),
		PackedVector2Array([Vector2(330, 100), Vector2(404, 34), Vector2(416, 156)])])
	_mark(c, head, ginger, 1430, 11.0)
	for side in 2:
		var tri := PackedVector2Array([Vector2(244, 126), Vector2(246, 70), Vector2(284, 104)])
		_pen(c, tri if side == 0 else _mirror(tri, 318.0), Color("#f7b0c4"), 1431 + side, 0.0)
	for x in [300.0, 318.0, 336.0]:
		Crayon.marker_line(c, PackedVector2Array([Vector2(x, 92), Vector2(x, 118)]), dark, 7.0, 1433 + int(x), false)
	_pupil(c, Vector2(280, 174), 15.0)
	_pupil(c, Vector2(356, 174), 15.0)
	_mark(c, PackedVector2Array([Vector2(304, 200), Vector2(332, 200), Vector2(318, 216)]), Color("#f490b0"), 1436, 6.0)
	Crayon.marker_line(c, _join([_arc(Vector2(306, 218), Vector2(12, 12), 0.0, PI * 0.9, 6),
		_arc(Vector2(330, 218), Vector2(12, 12), PI * 0.1, PI, 6)]), dark, 6.0, 1437, false)
	for side in 2:
		var sx := 1.0 if side == 0 else -1.0
		for k in 2:
			Crayon.line(c, Vector2(318 + sx * 52, 204 + k * 14), Vector2(318 + sx * 112, 194 + k * 30), dark, 4.0, 1438 + side * 2 + k)


## Marker: a cream dog standing side-on - floppy brown ear, a spot, tail up, friendly snout.
static func _dog(c: CanvasItem) -> void:
	var tan := Color("#ecc38e")
	var brown := Color("#c98f5e")
	var tail := _cubic(Vector2(106, 240), Vector2(60, 214), Vector2(50, 150), Vector2(72, 102), 16)
	_mark(c, _union([_band(tail, 48.0, 32.0), Crayon.ellipse(tail[tail.size() - 1], Vector2(16, 16), 12)]), tan, 1451, 11.0)
	for l in [[Vector2(152, 320), Vector2(160, 446)], [Vector2(292, 320), Vector2(306, 446)]]:
		_mark(c, _capsule(l[0], l[1], 60), tan.darkened(0.1), 1452 + int(l[0].x), 10.0)
	_mark(c, Crayon.rounded_rect(Rect2(80, 196, 292, 158), 78), tan, 1453, 11.0)
	_pen(c, Crayon.blob(Vector2(186, 250), Vector2(56, 40), 1454, 14, 0.12), brown, 1455, 7.0)
	Crayon.line(c, Vector2(120, 226), Vector2(300, 220), SHINE, 12.0, 1456)
	for l in [[Vector2(118, 320), Vector2(114, 452)], [Vector2(328, 320), Vector2(338, 452)]]:
		_mark(c, _capsule(l[0], l[1], 62), tan, 1457 + int(l[0].x), 11.0)
	var head := _union([Crayon.ellipse(Vector2(356, 168), Vector2(86, 80), 40),
		Crayon.ellipse(Vector2(426, 200), Vector2(56, 44), 28)])
	_mark(c, head, tan, 1460, 11.0)
	var ear := _turn(Crayon.ellipse(Vector2(318, 182), Vector2(40, 78), 28), Vector2(318, 120), 0.28)
	_mark(c, ear, brown, 1461, 10.0)
	_pupil(c, Vector2(380, 150), 14.0)
	var nose := Crayon.ellipse(Vector2(474, 188), Vector2(22, 17), 20)
	_under(c, nose)
	Crayon.marker_fill(c, nose, PLUM.lightened(0.3), 1462, 12.0)
	Crayon.marker_line(c, nose, PLUM, 6.0, 1493)
	Crayon.marker_line(c, _cubic(Vector2(408, 232), Vector2(424, 246), Vector2(450, 244), Vector2(466, 226), 8),
		tan.darkened(0.48), 7.0, 1463, false)


## Marker: a chestnut horse side-on - long legs with hooves, a long head, a tufty mane and tail.
static func _horse(c: CanvasItem) -> void:
	var coat := Color("#d79e6c")
	var mane := Color("#b67e58")
	var hoof := Color("#aca5d2")
	var tail := _resample(_cubic(Vector2(94, 206), Vector2(36, 226), Vector2(30, 320), Vector2(52, 412), 18), 5.0)
	var tw := PackedFloat32Array()
	for i in tail.size():
		tw.append(lerpf(56.0, 30.0, i / float(tail.size() - 1)))
	_mark(c, _furry(tail, tw, 5.0, 0.45), mane, 1471, 10.0)
	for l in [[Vector2(150, 270), Vector2(156, 424)], [Vector2(290, 270), Vector2(300, 424)]]:
		var b: Vector2 = l[1]
		_mark(c, _capsule(l[0], b, 42), coat.darkened(0.12), 1472 + int(b.x), 10.0)
		_mark(c, Crayon.rounded_rect(Rect2(b.x - 26, 414, 52, 34), 10), hoof.darkened(0.08), 1473 + int(b.x), 9.0)
	_mark(c, Crayon.ellipse(Vector2(206, 232), Vector2(142, 78), 44), coat, 1474, 11.0)
	Crayon.line(c, Vector2(110, 200), Vector2(250, 180), SHINE, 12.0, 1475)
	for l in [[Vector2(114, 262), Vector2(108, 430)], [Vector2(318, 262), Vector2(328, 430)]]:
		var b: Vector2 = l[1]
		_mark(c, _capsule(l[0], b, 44), coat, 1476 + int(b.x), 11.0)
		_mark(c, Crayon.rounded_rect(Rect2(b.x - 28, 422, 56, 36), 10), hoof, 1477 + int(b.x), 9.0)
	var neck_path := _cubic(Vector2(290, 240), Vector2(332, 176), Vector2(350, 128), Vector2(382, 86), 12)
	var head := _union([_band(neck_path, 124.0, 86.0), _capsule(Vector2(390, 84), Vector2(456, 154), 82),
		PackedVector2Array([Vector2(368, 62), Vector2(382, 10), Vector2(408, 58)])])
	_mark(c, head, coat, 1478, 11.0)
	var mane_path := _resample(_reverse(_offset(neck_path, 52.0)), 5.0)
	var mw := PackedFloat32Array()
	for i in mane_path.size():
		mw.append(lerpf(40.0, 56.0, i / float(mane_path.size() - 1)))
	_mark(c, _furry(mane_path, mw, 6.0, 0.5), mane, 1479, 9.0)
	_mark(c, _leaf(PackedVector2Array([Vector2(386, 58), Vector2(424, 92)]), 30.0), mane, 1480, 7.0)
	_pupil(c, Vector2(412, 100), 13.0)
	_mark(c, Crayon.ellipse(Vector2(466, 150), Vector2(9, 7), 12), mane, 1481, 5.0)


## Marker: a blue-grey elephant side-on - big ear, trunk curling forward, a little tusk.
static func _elephant(c: CanvasItem) -> void:
	var grey := Color("#aab5de")
	_frame(c, _cubic(Vector2(56, 226), Vector2(28, 252), Vector2(26, 296), Vector2(34, 330), 10), grey, 9.0, 1491, false)
	_mark(c, Crayon.blob(Vector2(36, 340), Vector2(16, 20), 1492, 10, 0.2), grey.darkened(0.1), 1493, 7.0)
	for x in [104.0, 254.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 300, 72, 150), 28), grey.darkened(0.12), 1494 + int(x), 10.0)
	_mark(c, Crayon.ellipse(Vector2(196, 244), Vector2(158, 126), 48), grey, 1495, 12.0)
	Crayon.line(c, Vector2(90, 180), Vector2(220, 140), SHINE, 13.0, 1496)
	for x in [66.0, 222.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 296, 86, 164), 30), grey, 1497 + int(x), 11.0)
		for k in 2:
			_pen(c, Crayon.ellipse(Vector2(x + 26 + k * 34, 446), Vector2(12, 9), 12), Color("#eef0fa"), 1498 + k, 5.0)
	var trunk := _cubic(Vector2(400, 230), Vector2(452, 300), Vector2(436, 396), Vector2(470, 422), 20)
	var head := _union([Crayon.ellipse(Vector2(344, 204), Vector2(92, 96), 40), _band(trunk, 82.0, 44.0),
		Crayon.ellipse(trunk[trunk.size() - 1], Vector2(22, 22), 16)])
	_mark(c, head, grey, 1499, 12.0)
	for i in 4:
		var p := trunk[8 + i * 3]
		var d := (trunk[9 + i * 3] - trunk[7 + i * 3]).normalized().orthogonal()
		Crayon.line(c, p + d * 30.0, p - d * 14.0, grey.darkened(0.3), 5.0, 1500 + i, 1.0)
	_pen(c, _band(_cubic(Vector2(402, 286), Vector2(414, 312), Vector2(432, 322), Vector2(452, 318), 10), 26.0, 3.0),
		Color("#fbf3dc"), 1505, 6.0)
	var ear := Crayon.blob(Vector2(304, 214), Vector2(76, 100), 1506, 18, 0.05)
	_mark(c, ear, grey.lightened(0.12), 1507, 11.0)
	Crayon.pencil_fill(c, Crayon.blob(Vector2(310, 222), Vector2(46, 68), 1508, 16, 0.05), Color("#f4c6d6"), 1509)
	_pupil(c, Vector2(382, 172), 13.0)


## Marker: a green long-neck dinosaur - neck up high, long tail down behind, spots on its back.
static func _dino(c: CanvasItem) -> void:
	var green := Color("#7cc77a")
	for x in [150.0, 290.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 344, 62, 108), 24), green.darkened(0.12), 1521 + int(x), 10.0)
	var tail := _cubic(Vector2(150, 318), Vector2(70, 322), Vector2(30, 368), Vector2(10, 440), 20)
	var neck := _cubic(Vector2(316, 300), Vector2(390, 250), Vector2(376, 128), Vector2(416, 84), 20)
	var dino := _union([Crayon.ellipse(Vector2(232, 322), Vector2(142, 92), 48), _band(tail, 120.0, 8.0),
		_band(neck, 106.0, 60.0), Crayon.ellipse(Vector2(434, 74), Vector2(62, 40), 28)])
	_under(c, dino)
	Crayon.marker_fill(c, dino, green, 1522)
	var belly := Crayon.ellipse(Vector2(240, 392), Vector2(128, 44), 32)
	for piece in Geometry2D.intersect_polygons(belly, dino):
		Crayon.marker_fill(c, piece, green.lightened(0.4), 1523, 16.0)
	for s in [[Vector2(200, 268), 26.0], [Vector2(258, 254), 22.0], [Vector2(150, 296), 18.0], [Vector2(306, 276), 16.0]]:
		var at: Vector2 = s[0]
		var r: float = s[1]
		_pen(c, Crayon.blob(at, Vector2(r, r * 0.8), 1524 + int(at.x), 12, 0.12), Color("#d6ef9a"), 1525 + int(at.x), 6.0)
	_shine(c, _offset(neck.slice(2, 16), -30.0), 11.0, 1526)
	Crayon.marker_line(c, dino, green.darkened(0.5), 12.0, 1527)
	for x in [110.0, 312.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 350, 72, 110), 26), green, 1528 + int(x), 11.0)
	_pupil(c, Vector2(446, 62), 11.0)
	Crayon.marker_line(c, _arc(Vector2(456, 74), Vector2(26, 16), 0.3, PI * 0.8, 8), green.darkened(0.5), 6.0, 1529, false)


# --- Actions -----------------------------------------------------------------------------------

## Marker: a pink heart with a pale paw print on it - "give this pet a home".
static func _adopt(c: CanvasItem) -> void:
	var pink := Color("#f26b84")
	var heart := _heart(Vector2(256, 222), 420.0)
	_mark(c, heart, pink, 1541, 12.0)
	_shine(c, _arc(Vector2(168, 166), Vector2(62, 56), PI * 1.02, PI * 1.48, 10), 18.0, 1542)
	var cream := Color("#fff3f3")
	var pads := [Crayon.blob(Vector2(256, 310), Vector2(74, 60), 1543, 16, 0.06)]
	var toes := [Vector2(170, 236), Vector2(222, 186), Vector2(290, 186), Vector2(342, 236)]
	for i in toes.size():
		var at: Vector2 = toes[i]
		pads.append(_turn(Crayon.ellipse(at, Vector2(28, 36), 20), at, (i - 1.5) * 0.3))
	for i in pads.size():
		var p: PackedVector2Array = pads[i]
		_under(c, p)
		Crayon.pencil_fill(c, p, cream, 1544 + i)
		Crayon.pencil_line(c, p, pink.darkened(0.35), 7.0, 1550 + i)


## Marker: a hammer - wooden handle with a red grip, lavender metal head.
static func _hammer(c: CanvasItem) -> void:
	var wood := Color("#e6ae74")
	var metal := Color("#bdb8dc")
	var a := Vector2(96, 444)
	var b := Vector2(316, 200)
	_mark(c, _capsule(a, b, 66), wood, 1561, 11.0)
	_mark(c, _capsule(a, a.lerp(b, 0.36), 78), Color("#ef6b6b"), 1562, 11.0)
	Crayon.line(c, a.lerp(b, 0.42) + Vector2(-18, -14), a.lerp(b, 0.85) + Vector2(-18, -14), SHINE, 10.0, 1563)
	var ang := (b - a).angle() + PI / 2.0
	var at := Vector2(328, 186)
	var o := Vector2.ZERO
	var claw := PackedVector2Array([Vector2(-40, -48), Vector2(-150, -30), Vector2(-196, 8), Vector2(-160, 10),
		Vector2(-120, -2), Vector2(-40, 34)])
	_mark(c, _place(claw, o, at, ang), metal.darkened(0.06), 1564, 11.0)
	_mark(c, _place(Crayon.rounded_rect(Rect2(-60, -54, 170, 108), 18), o, at, ang), metal, 1565, 11.0)
	_mark(c, _place(Crayon.rounded_rect(Rect2(96, -68, 60, 136), 16), o, at, ang), metal.lightened(0.15), 1566, 11.0)
	Crayon.line(c, _place1(Vector2(-40, -30), o, at, ang), _place1(Vector2(90, -30), o, at, ang), SHINE, 11.0, 1567)


## Marker: a blank wooden sign on a post, two nails, a tuft of grass at its foot.
static func _sign(c: CanvasItem) -> void:
	var wood := Color("#e8b47a")
	_mark(c, Crayon.rounded_rect(Rect2(222, 250, 68, 210), 14), wood.darkened(0.12), 1571, 11.0)
	var green := Color("#7cc77a")
	for i in 3:
		var base := Vector2(206 + i * 50, 462)
		var tip := base + Vector2(-30 + i * 30, -64 + absf(i - 1) * 18)
		_mark(c, _leaf(PackedVector2Array([base, tip]), 30.0), green, 1572 + i, 7.0)
	var board := _turn(Crayon.rounded_rect(Rect2(48, 70, 416, 214), 30), Vector2(256, 177), deg_to_rad(-3))
	_mark(c, board, wood, 1575, 12.0)
	for k in 2:
		var y := 140.0 + k * 74.0
		var grain := PackedVector2Array()
		for i in 13:
			var x := lerpf(110, 400, i / 12.0)
			grain.append(Vector2(x, y + sin(i * 0.9 + k) * 6.0 - (x - 256.0) * 0.05))
		Crayon.marker_line(c, grain, wood.darkened(0.25), 6.0, 1576 + k, false)
	for x in [92.0, 420.0]:
		_mark(c, Crayon.ellipse(Vector2(x, 180 - (x - 256.0) * 0.05), Vector2(13, 13), 12), Color("#bdb8dc"), 1578 + int(x), 6.0)
	Crayon.line(c, Vector2(84, 104), Vector2(420, 88), SHINE, 12.0, 1580)


## Marker: a big friendly green plus.
static func _plus(c: CanvasItem) -> void:
	var green := Color("#5fc87a")
	var plus := _union([_capsule(Vector2(96, 256), Vector2(416, 256), 120), _capsule(Vector2(256, 96), Vector2(256, 416), 120)])
	_mark(c, plus, green, 1591, 12.0)
	Crayon.line(c, Vector2(232, 122), Vector2(232, 222), SHINE, 13.0, 1592)
	Crayon.line(c, Vector2(120, 232), Vector2(214, 232), SHINE, 13.0, 1593)


## Marker: a big friendly coral minus.
static func _minus(c: CanvasItem) -> void:
	var red := Color("#f0716e")
	_mark(c, _capsule(Vector2(96, 256), Vector2(416, 256), 120), red, 1601, 12.0)
	Crayon.line(c, Vector2(120, 232), Vector2(384, 232), SHINE, 13.0, 1602)


# --- Looking after a pet -----------------------------------------------------------------------

## Marker: a garden gate swung wide open, a pink heart floating up and out through it.
static func _let_go(c: CanvasItem) -> void:
	var wood := Color("#e8b47a")
	_mark(c, Crayon.rounded_rect(Rect2(26, 420, 460, 50), 24), Color("#9bd87a"), 3100, 10.0)
	# The gate, swung away from us on the right post: its slats narrow towards the far edge.
	var h_top := Vector2(346, 204)
	var h_bot := Vector2(346, 426)
	var f_top := Vector2(484, 240)
	var f_bot := Vector2(484, 402)
	for k in 2:
		var v := 0.3 + k * 0.42
		var a := h_top.lerp(h_bot, v)
		var b := f_top.lerp(f_bot, v)
		_mark(c, PackedVector2Array([a + Vector2(0, -16), b + Vector2(0, -12), b + Vector2(0, 12), a + Vector2(0, 16)]),
			wood.darkened(0.1), 3101 + k, 9.0)
	for i in 3:
		var u0 := i / 3.0 + 0.05
		var u1 := (i + 1) / 3.0 - 0.05
		var t0 := h_top.lerp(f_top, u0)
		var t1 := h_top.lerp(f_top, u1)
		var peak := t0.lerp(t1, 0.5) + Vector2(0, -(t1.x - t0.x) * 0.7)
		_mark(c, PackedVector2Array([t0, peak, t1, h_bot.lerp(f_bot, u1), h_bot.lerp(f_bot, u0)]), wood, 3103 + i, 9.0)
	var brace_a := h_top.lerp(h_bot, 0.74).lerp(f_top.lerp(f_bot, 0.74), 0.06)
	var brace_b := h_top.lerp(h_bot, 0.3).lerp(f_top.lerp(f_bot, 0.3), 0.94)
	_mark(c, _capsule(brace_a, brace_b, 28), wood.darkened(0.1), 3106, 8.0)
	for x in [56.0, 286.0]:
		var post := _join([[Vector2(x, 444), Vector2(x, 190)], _arc(Vector2(x + 30, 190), Vector2(30, 30), PI, TAU, 10),
			[Vector2(x + 60, 444)]])
		_mark(c, post, wood.darkened(0.06), 3110 + int(x), 11.0)
		_mark(c, Crayon.ellipse(Vector2(x + 30, 150), Vector2(26, 26), 18), wood.lightened(0.1), 3111 + int(x), 9.0)
	var heart := _heart(Vector2(201, 206), 186.0)
	_mark(c, heart, Color("#f26b84"), 3120, 12.0)
	_shine(c, _arc(Vector2(164, 172), Vector2(30, 26), PI * 1.02, PI * 1.5, 8), 12.0, 3121)
	for i in 2:
		_mark(c, Crayon.ellipse(Vector2(196 - i * 8, 358 + i * 40), Vector2(13 - i * 3, 13 - i * 3), 12), Color("#f26b84"),
			3122 + i, 6.0)


## Marker: a little yellow house, and a purple arrow swooping round and in at its door.
static func _move_home(c: CanvasItem) -> void:
	var wall := Color("#ffd36b")
	var roof := Color("#f27a6e")
	_mark(c, Crayon.rounded_rect(Rect2(392, 100, 46, 110), 8), roof.darkened(0.08), 3200, 9.0)
	_mark(c, Crayon.rounded_rect(Rect2(198, 226, 260, 228), 12), wall, 3201, 12.0)
	_mark(c, _round_poly(PackedVector2Array([Vector2(156, 262), Vector2(328, 86), Vector2(500, 262)]), 18.0), roof, 3202, 12.0)
	var door := _union([Crayon.rounded_rect(Rect2(290, 358, 80, 96), 6), Crayon.ellipse(Vector2(330, 362), Vector2(40, 40), 24)])
	_mark(c, door, Color("#79aeea"), 3203, 10.0)
	var win := Crayon.rounded_rect(Rect2(388, 300, 50, 50), 8)
	_pen(c, win, Color("#cfe6fb"), 3204, 8.0)
	Crayon.line(c, Vector2(413, 304), Vector2(413, 346), Color("#cfe6fb").darkened(0.45), 6.0, 3205)
	Crayon.line(c, Vector2(392, 325), Vector2(434, 325), Color("#cfe6fb").darkened(0.45), 6.0, 3206)
	var path := _cubic(Vector2(66, 96), Vector2(30, 340), Vector2(140, 412), Vector2(262, 408), 24)
	var arrow := _union([_arrow(path, 50.0, 78.0, 124.0), Crayon.ellipse(path[0], Vector2(25, 25), 16)])
	_mark(c, arrow, Color("#9d8af4"), 3207, 11.0)
	_shine(c, _offset(path.slice(3, 15), -13.0), 9.0, 3208)


## Marker: a friendly blue cog - fat round teeth and a pale hole in the middle.
static func _settings(c: CanvasItem) -> void:
	var blue := Color("#8fb4ea")
	var at := Vector2(256, 256)
	var parts := [Crayon.ellipse(at, Vector2(162, 162), 64)]
	for k in 8:
		var tooth := Crayon.rounded_rect(Rect2(-46, -214, 92, 104), 26)
		parts.append(_shift(_turn(tooth, Vector2.ZERO, k * PI / 4.0), at))
	_mark(c, _union(parts), blue, 3300, 12.0)
	_shine(c, _arc(at, Vector2(124, 124), PI * 1.06, PI * 1.42, 10), 15.0, 3301)
	var hole := Crayon.ellipse(at, Vector2(62, 62), 32)
	_under(c, hole)
	Crayon.pencil_fill(c, hole, Color("#eef3fc"), 3302)
	Crayon.marker_line(c, hole, blue.darkened(0.5), 11.0, 3303)


# --- Sound buttons -----------------------------------------------------------------------------

## Marker: a green button with a big cream play triangle on it.
static func _play(c: CanvasItem) -> void:
	var green := Color("#5fc87a")
	var at := Vector2(256, 256)
	_mark(c, Crayon.ellipse(at, Vector2(206, 206), 72), green, 3400, 12.0)
	_shine(c, _arc(at, Vector2(172, 172), PI * 1.06, PI * 1.4, 12), 16.0, 3401)
	var tri := _round_poly(PackedVector2Array([Vector2(198, 140), Vector2(384, 256), Vector2(198, 372)]), 26.0)
	_under(c, tri)
	Crayon.pencil_fill(c, tri, Color("#fffaf0"), 3402)
	Crayon.marker_line(c, tri, green.darkened(0.5), 11.0, 3403)


## Marker: an old round microphone on its stand, and a red record dot beside it.
static func _record(c: CanvasItem) -> void:
	_mic(c, Vector2(222, 236), 3600)
	var red := Color("#ef6262")
	_mark(c, Crayon.ellipse(Vector2(410, 112), Vector2(62, 62), 32), red, 3620, 11.0)
	_shine(c, _arc(Vector2(410, 112), Vector2(40, 40), PI * 1.08, PI * 1.44, 8), 11.0, 3621)


## Marker: a big rounded coral stop square.
static func _stop(c: CanvasItem) -> void:
	var red := Color("#f0716e")
	_mark(c, Crayon.rounded_rect(Rect2(88, 88, 336, 336), 64), red, 3500, 12.0)
	Crayon.line(c, Vector2(128, 156), Vector2(128, 360), SHINE, 14.0, 3501)


## Marker: a white dice tumbling over, five plum spots on its front, two swooshes behind it.
static func _dice(c: CanvasItem) -> void:
	var at := Vector2(286, 230)
	var mid := Vector2(22, -22)
	var ang := deg_to_rad(-14)
	for i in 2:
		var r := 262.0 + i * 44.0
		_frame(c, _arc(at, Vector2(r, r), PI * (0.64 + i * 0.03), PI * (0.8 - i * 0.02), 10), Color("#aaa4ea"), 13.0,
			3800 + i, false)
	_block(c, Rect2(-140, -100, 240, 240), Vector2(84, -84), Color("#ebe6fb"), 3802, mid, at, ang)
	var spots := [Vector2(-88, -48), Vector2(48, -48), Vector2(-20, 20), Vector2(-88, 88), Vector2(48, 88)]
	for i in spots.size():
		var q: Vector2 = spots[i]
		var p := Crayon.ellipse(_place1(q, mid, at, ang), Vector2(26, 26), 20)
		c.draw_colored_polygon(p, PLUM)
		Crayon.marker_fill(c, p, PLUM.lightened(0.14), 3810 + i, 10.0)
	var top := PackedVector2Array()
	for i in 20:
		var t := TAU * i / 20.0
		top.append(_place1(Vector2(22, -142) + Vector2(cos(t) * 26.0 + sin(t) * 9.0, -sin(t) * 9.0), mid, at, ang))
	c.draw_colored_polygon(top, PLUM)


## Marker: a blue loudspeaker, three sound arcs coming off it.
static func _speaker(c: CanvasItem) -> void:
	var blue := Color("#79aeea")
	var cone := PackedVector2Array([Vector2(150, 196), Vector2(264, 94), Vector2(264, 418), Vector2(150, 316)])
	_mark(c, _round_poly(cone, 14.0), blue, 3900, 12.0)
	_mark(c, Crayon.rounded_rect(Rect2(52, 184, 118, 144), 22), blue.darkened(0.08), 3901, 12.0)
	Crayon.line(c, Vector2(78, 212), Vector2(78, 300), SHINE, 11.0, 3902)
	_waves(c, Vector2(272, 256), 0.0, 3903, 3, 74.0, 60.0, 20.0, 0.62)


## Marker: two pink musical notes joined by a beam.
static func _music(c: CanvasItem) -> void:
	var pink := Color("#e98cc4")
	var h1 := Vector2(146, 384)
	var h2 := Vector2(350, 344)
	# In touching order - a union that meets a part it does not touch keeps only the bigger piece.
	var parts := [_turn(Crayon.ellipse(h1, Vector2(80, 60), 32), h1, -0.38), _capsule(h1 + Vector2(64, -12), h1 + Vector2(64, -270), 40),
		PackedVector2Array([Vector2(194, 92), Vector2(438, 50), Vector2(438, 120), Vector2(194, 162)]),
		_capsule(h2 + Vector2(64, -12), h2 + Vector2(64, -270), 40), _turn(Crayon.ellipse(h2, Vector2(80, 60), 32), h2, -0.38)]
	_mark(c, _round_poly(_union(parts), 6.0), pink, 4000, 12.0)
	for h in [Vector2(146, 384), Vector2(350, 344)]:
		var at: Vector2 = h
		_shine(c, _arc(at, Vector2(52, 36), PI * 1.0, PI * 1.4, 8), 11.0, 4001 + int(at.x))


## Marker: a wide open cartoon mouth - teeth, tongue, coral lips - with sound arcs either side.
static func _voice(c: CanvasItem) -> void:
	var lip := Color("#f07a8c")
	var mouth := _join([_cubic(Vector2(118, 176), Vector2(196, 214), Vector2(316, 214), Vector2(394, 176), 16),
		_cubic(Vector2(394, 176), Vector2(390, 404), Vector2(122, 404), Vector2(118, 176), 20)])
	_under(c, mouth)
	Crayon.marker_fill(c, mouth, MAW, 4100)
	var top := _cubic(Vector2(100, 166), Vector2(196, 206), Vector2(316, 206), Vector2(412, 166), 16)
	for piece in Geometry2D.intersect_polygons(_join([top, _offset(_reverse(top), 36.0)]), mouth):
		_under(c, piece)
		Crayon.pencil_fill(c, piece, Color("#fffaf2"), 4101)
		Crayon.pencil_line(c, piece, Color("#c4a4c4"), 6.0, 4102)
	for piece in Geometry2D.intersect_polygons(Crayon.ellipse(Vector2(256, 360), Vector2(104, 66), 32), mouth):
		_under(c, piece)
		Crayon.marker_fill(c, piece, TONGUE, 4103)
		Crayon.marker_line(c, piece, TONGUE.darkened(0.45), 8.0, 4104)
	_frame(c, mouth, lip, 18.0, 4105)
	_waves(c, Vector2(398, 270), 0.0, 4106, 2, 50.0, 40.0)
	_waves(c, Vector2(114, 270), PI, 4108, 2, 50.0, 40.0)


## Marker: the microphone with a soft coral line through it - no recording.
static func _mic_off(c: CanvasItem) -> void:
	_mic(c, Vector2(256, 236), 3700)
	var a := Vector2(102, 92)
	var b := Vector2(410, 420)
	_under(c, _capsule(a, b, 88))
	_mark(c, _capsule(a, b, 54), Color("#f0716e"), 3720, 11.0)


## An old round microphone on a little stand, centred on `at`: a grille head in a holder, stem, base.
static func _mic(c: CanvasItem, at: Vector2, seed: int) -> void:
	var metal := Color("#bdb8dc")
	var dark := metal.darkened(0.5)
	_mark(c, Crayon.rounded_rect(Rect2(at.x - 104, at.y + 172, 208, 48), 22), metal.darkened(0.06), seed, 11.0)
	_mark(c, Crayon.rounded_rect(Rect2(at.x - 20, at.y + 96, 40, 90), 10), metal.darkened(0.12), seed + 1, 10.0)
	_frame(c, _arc(at + Vector2(0, -24), Vector2(122, 128), 0.0, PI, 24), metal.darkened(0.04), 18.0, seed + 2, false)
	var head := Crayon.ellipse(at + Vector2(0, -64), Vector2(98, 122), 48)
	_under(c, head)
	Crayon.marker_fill(c, head, metal.lightened(0.25), seed + 3)
	var inner: PackedVector2Array = Geometry2D.offset_polygon(head, -20.0)[0]
	for i in 5:
		var y := at.y - 156.0 + i * 46.0
		for piece in Geometry2D.intersect_polyline_with_polygon(
				PackedVector2Array([Vector2(at.x - 130, y), Vector2(at.x + 130, y)]), inner):
			Crayon.marker_line(c, piece, dark.lightened(0.25), 7.0, seed + 4 + i, false)
	for piece in Geometry2D.intersect_polyline_with_polygon(
			PackedVector2Array([Vector2(at.x, at.y - 200), Vector2(at.x, at.y + 80)]), inner):
		Crayon.marker_line(c, piece, dark.lightened(0.25), 7.0, seed + 10, false)
	Crayon.marker_line(c, head, dark, 12.0, seed + 11)
	_shine(c, _arc(at + Vector2(0, -64), Vector2(70, 94), PI * 1.1, PI * 1.38, 8), 13.0, seed + 12)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		_mark(c, Crayon.ellipse(at + Vector2(sx * 122, -24), Vector2(18, 18), 14), metal.darkened(0.04), seed + 13 + k, 7.0)


# --- Ends of the sound sliders -----------------------------------------------------------------

## Marker: a tiny pink bird singing, beak wide open, two little notes climbing up high.
static func _high(c: CanvasItem) -> void:
	var pink := Color("#f48fb8")
	var orange := Color("#f7a04a")
	var at := Vector2(158, 350)
	_note(c, Vector2(302, 214), 0.58, WAVE, 4201)
	_note(c, Vector2(402, 148), 0.7, WAVE, 4202)
	_mark(c, _leaf(PackedVector2Array([at + Vector2(-84, -4), at + Vector2(-150, -82)]), 64.0), pink.darkened(0.08), 4203, 10.0)
	for k in 2:
		var foot := at + Vector2(-30 + k * 50, 92)
		_frame(c, PackedVector2Array([foot, foot + Vector2(-2, 30), foot + Vector2(22, 34)]), orange, 7.0, 4204 + k, false)
	var body := Crayon.ellipse(at, Vector2(126, 108), 44)
	_mark(c, body, pink, 4206, 12.0)
	for piece in Geometry2D.intersect_polygons(Crayon.ellipse(at + Vector2(24, 44), Vector2(78, 52), 28), body):
		Crayon.pencil_fill(c, piece, Color("#fde3ee"), 4207)
	_mark(c, _leaf(PackedVector2Array([at + Vector2(-78, -14), at + Vector2(30, 34)]), 66.0), pink.darkened(0.06), 4208, 9.0)
	_pupil(c, at + Vector2(54, -38), 16.0)
	Crayon.pencil_fill(c, Crayon.ellipse(at + Vector2(72, 2), Vector2(16, 11), 14), Color("#f490a8"), 4209)
	_beak(c, at + Vector2(104, -34), -0.38, 78.0, 50.0, 0.62, orange, 4210)


## Marker: a big friendly blue whale going "ooo", fat notes sinking low beneath it.
static func _low(c: CanvasItem) -> void:
	var blue := Color("#79aeea")
	var at := Vector2(222, 196)
	var tail := _cubic(at + Vector2(150, 16), at + Vector2(206, 6), at + Vector2(218, -50), at + Vector2(220, -104), 14)
	var tip := tail[tail.size() - 1]
	_mark(c, _leaf(PackedVector2Array([tip + Vector2(6, 10), tip + Vector2(-62, -46)]), 54.0), blue.darkened(0.06), 4300, 10.0)
	_mark(c, _leaf(PackedVector2Array([tip + Vector2(-6, 10), tip + Vector2(54, -58)]), 54.0), blue.darkened(0.06), 4301, 10.0)
	var body := _union([Crayon.ellipse(at, Vector2(196, 114), 56), _band(tail, 100.0, 40.0)])
	_under(c, body)
	Crayon.marker_fill(c, body, blue, 4302)
	for piece in Geometry2D.intersect_polygons(Crayon.ellipse(at + Vector2(-16, 92), Vector2(176, 62), 40), body):
		Crayon.pencil_fill(c, piece, Color("#dcecfb"), 4303)
	for k in 3:
		var y := at.y + 56.0 + k * 18.0
		Crayon.pencil_line(c, PackedVector2Array([Vector2(at.x - 120 + k * 16, y), Vector2(at.x + 60 - k * 20, y + 4)]),
			blue.darkened(0.3), 5.0, 4304 + k, false)
	_shine(c, _arc(at, Vector2(150, 82), PI * 1.2, PI * 1.5, 10), 14.0, 4307)
	Crayon.marker_line(c, body, blue.darkened(0.5), 12.0, 4308)
	_pupil(c, at + Vector2(-110, -22), 16.0)
	Crayon.pencil_fill(c, Crayon.ellipse(at + Vector2(-104, 22), Vector2(20, 12), 14), Color("#f4a0b8"), 4309)
	var mouth := Crayon.ellipse(at + Vector2(-166, 30), Vector2(20, 24), 20)
	_under(c, mouth)
	Crayon.marker_fill(c, mouth, MAW, 4310, 10.0)
	Crayon.marker_line(c, mouth, blue.darkened(0.5), 8.0, 4311)
	for k in 3:
		var p := Vector2(150 + k * 26, 66 - k * 6)
		_mark(c, Crayon.ellipse(p, Vector2(15 - k * 3, 15 - k * 3), 12), Color("#a9d4f5"), 4312 + k, 6.0)
	_note(c, Vector2(146, 440), 0.72, WAVE, 4320)
	_note(c, Vector2(292, 466), 0.72, WAVE, 4321)


## Marker: a peach rabbit mid-leap to the right, ears streaming back, speed lines behind it.
static func _fast(c: CanvasItem) -> void:
	var fur := Color("#efc49c")
	var pink := Color("#f6aec4")
	for i in 3:
		var y := 222.0 + i * 66.0
		var x0 := 24.0 + absf(i - 1) * 26.0
		_frame(c, PackedVector2Array([Vector2(x0, y), Vector2(x0 + 92.0 - absf(i - 1) * 20.0, y)]), Color("#9fc6ee"), 14.0,
			4400 + i, false)
	var ear_far := _leaf(PackedVector2Array([Vector2(404, 168), Vector2(316, 42)]), 58.0)
	_mark(c, ear_far, fur.darkened(0.06), 4403, 10.0)
	_mark(c, _union([_capsule(Vector2(250, 330), Vector2(190, 392), 72), _capsule(Vector2(190, 392), Vector2(112, 402), 48)]),
		fur.darkened(0.06), 4404, 11.0)
	_mark(c, _capsule(Vector2(356, 330), Vector2(412, 394), 40), fur.darkened(0.06), 4405, 10.0)
	_mark(c, _turn(Crayon.ellipse(Vector2(288, 288), Vector2(128, 84), 44), Vector2(288, 288), -0.2), fur, 4406, 12.0)
	_pen(c, Crayon.blob(Vector2(168, 262), Vector2(38, 36), 4407, 12, 0.12), Color("#fff6ea"), 4408, 8.0)
	_mark(c, _capsule(Vector2(372, 318), Vector2(452, 362), 42), fur, 4409, 10.0)
	Crayon.line(c, Vector2(214, 250), Vector2(330, 222), SHINE, 12.0, 4410)
	_mark(c, Crayon.ellipse(Vector2(402, 212), Vector2(70, 60), 32), fur, 4411, 12.0)
	var ear := _leaf(PackedVector2Array([Vector2(380, 172), Vector2(262, 70)]), 62.0)
	_mark(c, ear, fur, 4412, 11.0)
	_pen(c, _scale(ear, Vector2(340, 136), Vector2(0.62, 0.5)), pink, 4413, 0.0)
	_pupil(c, Vector2(424, 196), 15.0)
	_mark(c, Crayon.ellipse(Vector2(468, 214), Vector2(12, 10), 12), Color("#f490b0"), 4414, 6.0)
	Crayon.pencil_fill(c, Crayon.ellipse(Vector2(430, 238), Vector2(16, 10), 14), pink, 4415)


## Marker: a green turtle plodding right - a domed patterned shell, stubby legs, a smiley head.
static func _slow(c: CanvasItem) -> void:
	var shell := Color("#7cc77a")
	var skin := Color("#c9e08c")
	_mark(c, _leaf(PackedVector2Array([Vector2(104, 352), Vector2(36, 380)]), 36.0), skin, 4500, 8.0)
	for x in [112.0, 296.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 330, 64, 100), 26), skin.darkened(0.1), 4501 + int(x), 10.0)
	_mark(c, _union([_capsule(Vector2(356, 334), Vector2(420, 276), 72), Crayon.ellipse(Vector2(436, 260), Vector2(58, 52), 28)]),
		skin, 4503, 11.0)
	var dome := _arc(Vector2(250, 352), Vector2(178, 200), PI, TAU, 40)
	_under(c, dome)
	Crayon.marker_fill(c, dome, shell, 4504)
	var hex := PackedVector2Array()
	for k in 6:
		hex.append(Vector2(250, 266) + Vector2.from_angle(k * PI / 3.0) * 58.0)
	for k in 6:
		var p: Vector2 = hex[k]
		for piece in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([p, p + (p - Vector2(250, 266)) * 3.0]), dome):
			Crayon.marker_line(c, piece, shell.darkened(0.38), 8.0, 4505 + k, false)
	Crayon.marker_fill(c, hex, shell.lightened(0.2), 4512, 14.0)
	Crayon.marker_line(c, hex, shell.darkened(0.38), 8.0, 4513)
	_shine(c, _arc(Vector2(250, 352), Vector2(146, 166), PI * 1.12, PI * 1.36, 10), 14.0, 4514)
	Crayon.marker_line(c, dome, shell.darkened(0.5), 12.0, 4515)
	_mark(c, Crayon.rounded_rect(Rect2(58, 334, 384, 42), 21), shell.darkened(0.1), 4516, 11.0)
	for x in [150.0, 334.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 356, 66, 86), 26), skin, 4517 + int(x), 10.0)
	_pupil(c, Vector2(450, 248), 14.0)
	Crayon.marker_line(c, _arc(Vector2(446, 270), Vector2(26, 16), 0.3, PI * 0.7, 8), skin.darkened(0.5), 6.0, 4520, false)


## Marker: one calm, straight teal line - no effect.
static func _flat(c: CanvasItem) -> void:
	_frame(c, PackedVector2Array([Vector2(84, 256), Vector2(256, 256), Vector2(428, 256)]), Color("#4fb6dc"), 54.0, 4600, false)
	Crayon.line(c, Vector2(96, 244), Vector2(400, 244), SHINE, 10.0, 4601)


## Marker: the same teal line gone big and wavy - wobbly.
static func _wobble(c: CanvasItem) -> void:
	var path := PackedVector2Array()
	for i in 97:
		var t := i / 96.0
		path.append(Vector2(lerpf(84, 428, t), 256.0 - sin(t * TAU * 2.0) * 112.0))
	_frame(c, path, Color("#4fb6dc"), 54.0, 4700, false)
	_shine(c, _offset(path.slice(3, 20), 12.0), 10.0, 4701)


## Marker: a lavender mountain with a snowy peak, three echo arcs fading away off its side.
static func _echo(c: CanvasItem) -> void:
	var lav := Color("#a8b2ea")
	var hill := _round_poly(PackedVector2Array([Vector2(28, 452), Vector2(206, 92), Vector2(384, 452)]), 20.0)
	_mark(c, hill, lav, 4800, 12.0)
	var cap := PackedVector2Array([Vector2(90, 246), Vector2(136, 284), Vector2(172, 250), Vector2(208, 290), Vector2(244, 252),
		Vector2(282, 284), Vector2(324, 242), Vector2(206, 30)])
	for piece in Geometry2D.intersect_polygons(cap, hill):
		_under(c, piece)
		Crayon.pencil_fill(c, piece, Color("#f6f8ff"), 4801)
		Crayon.marker_line(c, piece, lav.darkened(0.45), 8.0, 4802)
	Crayon.marker_line(c, hill, lav.darkened(0.5), 12.0, 4803)
	Crayon.line(c, Vector2(186, 160), Vector2(110, 380), SHINE, 12.0, 4804)
	for i in 3:
		var r := 74.0 + i * 54.0
		var col := WAVE.lightened(0.22 * i)
		_frame(c, _arc(Vector2(262, 214), Vector2(r, r), -0.62, 0.62, 16), col, 16.0 - i * 2.0, 4805 + i, false)


## Marker: a fat orange arrow running along flat, then swooping up (or down) at the end.
static func _bend(c: CanvasItem, up: bool) -> void:
	var path := _cubic(Vector2(58, 398), Vector2(290, 402), Vector2(372, 330), Vector2(398, 172), 28)
	if not up:
		path = _flip_y(path, 256.0)
	var arrow := _union([_arrow(path, 72.0, 110.0, 196.0), Crayon.ellipse(path[0], Vector2(36, 36), 20)])
	_mark(c, arrow, Color("#f7a04a"), 4900 if up else 5000, 12.0)
	_shine(c, _offset(path.slice(2, 17), -18.0 if up else 18.0), 11.0, 4901 if up else 5001)


## Marker: a friendly square robot head - round eyes, a grille mouth, bolts for ears, an antenna.
static func _robot(c: CanvasItem) -> void:
	var metal := Color("#a9b4e0")
	_frame(c, PackedVector2Array([Vector2(256, 176), Vector2(256, 98)]), metal.darkened(0.1), 14.0, 5100, false)
	_mark(c, Crayon.ellipse(Vector2(256, 80), Vector2(30, 30), 20), Color("#f48fb8"), 5101, 9.0)
	for x in [74.0, 394.0]:
		_mark(c, Crayon.rounded_rect(Rect2(x, 262, 44, 104), 16), metal.darkened(0.1), 5102 + int(x), 10.0)
	_mark(c, Crayon.rounded_rect(Rect2(104, 168, 304, 278), 48), metal, 5103, 12.0)
	Crayon.line(c, Vector2(128, 210), Vector2(128, 400), SHINE, 13.0, 5104)
	_pen(c, Crayon.rounded_rect(Rect2(142, 206, 228, 206), 34), Color("#e6eafa"), 5105, 8.0)
	for x in [204.0, 308.0]:
		_pen(c, Crayon.ellipse(Vector2(x, 280), Vector2(40, 40), 24), Color("#fffaf2"), 5106 + int(x), 8.0)
		_pupil(c, Vector2(x + 6, 284), 21.0)
	var grille := Crayon.rounded_rect(Rect2(190, 346, 132, 42), 14)
	_mark(c, grille, Color("#f7a8b8"), 5107, 8.0)
	for k in 3:
		var x := 223.0 + k * 33.0
		Crayon.marker_line(c, PackedVector2Array([Vector2(x, 352), Vector2(x, 382)]), Color("#f7a8b8").darkened(0.45), 6.0,
			5108 + k, false)


## Marker: rewind - two blue triangles pointing LEFT.
static func _backwards(c: CanvasItem) -> void:
	var blue := Color("#6aaeee")
	var back := _round_poly(PackedVector2Array([Vector2(234, 256), Vector2(450, 112), Vector2(450, 400)]), 24.0)
	var front := _round_poly(PackedVector2Array([Vector2(46, 256), Vector2(262, 112), Vector2(262, 400)]), 24.0)
	_mark(c, back, blue, 5200, 12.0)
	_mark(c, front, blue.lightened(0.06), 5201, 12.0)
	Crayon.line(c, Vector2(116, 232), Vector2(236, 152), SHINE, 12.0, 5202)
	Crayon.line(c, Vector2(304, 232), Vector2(424, 152), SHINE, 12.0, 5203)


# --- Base sounds -------------------------------------------------------------------------------
# Each one a face or thing MAKING its noise: mouth open, and the same three purple sound arcs
# (`_waves`) coming off it, so the whole set reads as "sounds" at a glance.

## Marker: a cream puppy face barking - floppy brown ears, a big plum nose, mouth wide open.
static func _bark(c: CanvasItem) -> void:
	var tan := Color("#ecc38e")
	var brown := Color("#c98f5e")
	var at := Vector2(194, 250)
	_waves(c, Vector2(338, 356), 0.1, 5300)
	_mark(c, Crayon.ellipse(at, Vector2(136, 126), 48), tan, 5301, 12.0)
	_shine(c, _arc(at, Vector2(104, 96), PI * 1.12, PI * 1.38, 10), 14.0, 5302)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		var e := at + Vector2(sx * 118, -4)
		_mark(c, _turn(Crayon.ellipse(e, Vector2(46, 96), 28), e, -sx * 0.32), brown, 5303 + k, 11.0)
	_pen(c, Crayon.ellipse(at + Vector2(0, 70), Vector2(86, 64), 32), Color("#fff3dc"), 5305, 8.0)
	_maw(c, _d_mouth(at + Vector2(0, 76), 44.0, 62.0), tan.darkened(0.5), 5306)
	var nose := Crayon.ellipse(at + Vector2(0, 42), Vector2(36, 26), 24)
	_under(c, nose)
	Crayon.marker_fill(c, nose, PLUM.lightened(0.3), 5307, 12.0)
	Crayon.marker_line(c, nose, PLUM, 7.0, 5308)
	c.draw_colored_polygon(Crayon.ellipse(at + Vector2(-12, 34), Vector2(11, 6), 12), Color(1, 1, 1, 0.7))
	_pupil(c, at + Vector2(-50, -26), 17.0)
	_pupil(c, at + Vector2(50, -26), 17.0)


## Marker: a ginger cat face meowing - pointy ears, stripes, whiskers, a small round open mouth.
static func _meow(c: CanvasItem) -> void:
	var ginger := Color("#f6a862")
	var dark := ginger.darkened(0.34)
	var at := Vector2(198, 288)
	_waves(c, Vector2(348, 206), -0.5, 5400)
	var ear := PackedVector2Array([at + Vector2(-146, -30), at + Vector2(-122, -200), at + Vector2(-30, -112)])
	_mark(c, _union([Crayon.ellipse(at, Vector2(150, 122), 48), ear, _mirror(ear, at.x)]), ginger, 5401, 12.0)
	var inner := PackedVector2Array([at + Vector2(-118, -84), at + Vector2(-110, -164), at + Vector2(-58, -114)])
	_pen(c, inner, Color("#f7b0c4"), 5402, 0.0)
	_pen(c, _mirror(inner, at.x), Color("#f7b0c4"), 5403, 0.0)
	for k in 3:
		var x := -26.0 + k * 26.0
		Crayon.marker_line(c, PackedVector2Array([at + Vector2(x, -118), at + Vector2(x, -84)]), dark, 8.0, 5404 + k, false)
	_shine(c, _arc(at, Vector2(118, 92), PI * 1.1, PI * 1.32, 10), 13.0, 5407)
	_pupil(c, at + Vector2(-60, -12), 19.0)
	_pupil(c, at + Vector2(60, -12), 19.0)
	_mark(c, PackedVector2Array([at + Vector2(-20, 22), at + Vector2(20, 22), at + Vector2(0, 42)]), Color("#f490b0"), 5408, 6.0)
	_maw(c, Crayon.ellipse(at + Vector2(0, 78), Vector2(30, 32), 24), dark, 5409, 8.0)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		_whiskers(c, at + Vector2(sx * 72, 42), sx, 116.0, dark, 5410 + k * 2)


## Marker: a round blue songbird chirping - beak open, a crest, a little wing and tail.
static func _chirp(c: CanvasItem) -> void:
	var blue := Color("#7fb6ee")
	var orange := Color("#f7a04a")
	var at := Vector2(190, 282)
	_waves(c, Vector2(380, 248), -0.1, 5500)
	for k in 2:
		_mark(c, _leaf(PackedVector2Array([at + Vector2(-90, 10), at + Vector2(-184, -62 + k * 58)]), 58.0), blue.darkened(0.1),
			5501 + k, 10.0)
	for k in 2:
		var foot := at + Vector2(-40 + k * 60, 112)
		_frame(c, PackedVector2Array([foot, foot + Vector2(-4, 34), foot + Vector2(22, 38)]), orange, 8.0, 5503 + k, false)
	for k in 3:
		var base := at + Vector2(-16 + k * 18, -112)
		_mark(c, _leaf(PackedVector2Array([base, base + Vector2(-30 + k * 30, -60 + absf(k - 1) * 10.0)]), 30.0),
			blue.darkened(0.04), 5505 + k, 8.0)
	var body := Crayon.ellipse(at, Vector2(140, 126), 48)
	_mark(c, body, blue, 5508, 12.0)
	for piece in Geometry2D.intersect_polygons(Crayon.ellipse(at + Vector2(36, 56), Vector2(92, 70), 32), body):
		Crayon.pencil_fill(c, piece, Color("#e6f1fc"), 5509)
	_shine(c, _arc(at, Vector2(108, 94), PI * 1.12, PI * 1.36, 10), 14.0, 5510)
	_mark(c, _leaf(PackedVector2Array([at + Vector2(-92, -8), at + Vector2(30, 52)]), 76.0), blue.darkened(0.06), 5511, 10.0)
	_pupil(c, at + Vector2(62, -42), 18.0)
	Crayon.pencil_fill(c, Crayon.ellipse(at + Vector2(76, 2), Vector2(18, 12), 14), Color("#f4a0b8"), 5512)
	_beak(c, at + Vector2(124, -24), -0.1, 86.0, 56.0, 0.56, orange, 5513)


## Marker: a lavender mouse face squeaking - big round pink ears, buck teeth, whiskers.
static func _squeak(c: CanvasItem) -> void:
	var grey := Color("#c3bce0")
	var pink := Color("#f6aec4")
	var at := Vector2(200, 296)
	_waves(c, Vector2(340, 312), 0.0, 5600)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		var e := at + Vector2(sx * 112, -124)
		_mark(c, Crayon.ellipse(e, Vector2(86, 84), 32), grey.lightened(0.06), 5601 + k, 11.0)
		_pen(c, Crayon.ellipse(e + Vector2(sx * 4, 6), Vector2(54, 52), 24), pink, 5603 + k, 0.0)
	var head := _union([Crayon.ellipse(at, Vector2(124, 108), 44), Crayon.ellipse(at + Vector2(0, 46), Vector2(86, 76), 32)])
	_mark(c, head, grey, 5605, 12.0)
	_shine(c, _arc(at, Vector2(96, 84), PI * 1.12, PI * 1.36, 10), 13.0, 5606)
	_pupil(c, at + Vector2(-48, -18), 18.0)
	_pupil(c, at + Vector2(48, -18), 18.0)
	for k in 2:
		Crayon.pencil_fill(c, Crayon.ellipse(at + Vector2(-80 + k * 160, 30), Vector2(20, 13), 14), pink, 5607 + k)
	_maw(c, _d_mouth(at + Vector2(0, 76), 30.0, 42.0), grey.darkened(0.5), 5609, 8.0)
	for k in 2:
		var tooth := Crayon.rounded_rect(Rect2(at.x - 16 + k * 17, at.y + 76, 15, 20), 4)
		_under(c, tooth)
		Crayon.pencil_fill(c, tooth, Color("#fffaf2"), 5610 + k)
		Crayon.pencil_line(c, tooth, grey.darkened(0.45), 5.0, 5612 + k)
	_mark(c, Crayon.ellipse(at + Vector2(0, 52), Vector2(20, 16), 16), Color("#f490b0"), 5614, 6.0)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		_whiskers(c, at + Vector2(sx * 62, 58), sx, 92.0, grey.darkened(0.4), 5615 + k * 2)


## Marker: a cream cow face mooing - brown patches, little horns, ears out sideways, a big pink muzzle.
static func _moo(c: CanvasItem) -> void:
	var cream := Color("#fbf1de")
	var patch := Color("#c99a72")
	var pink := Color("#f7b0bc")
	var at := Vector2(200, 238)
	_waves(c, Vector2(344, 340), 0.05, 5700)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		var horn := _cubic(at + Vector2(sx * 56, -100), at + Vector2(sx * 70, -142), at + Vector2(sx * 100, -160),
			at + Vector2(sx * 122, -152), 10)
		_mark(c, _band(horn, 40.0, 10.0), Color("#f3dfb4"), 5701 + k, 9.0)
		var ear := _leaf(PackedVector2Array([at + Vector2(sx * 90, -66), at + Vector2(sx * 190, -40)]), 64.0)
		_mark(c, ear, cream, 5703 + k, 10.0)
		_pen(c, _scale(ear, at + Vector2(sx * 140, -53), Vector2(0.6, 0.45)), pink, 5705 + k, 0.0)
	var head := Crayon.ellipse(at, Vector2(114, 126), 44)
	_under(c, head)
	Crayon.marker_fill(c, head, cream, 5707)
	for piece in Geometry2D.intersect_polygons(Crayon.blob(at + Vector2(-74, -74), Vector2(70, 56), 5708, 14, 0.12), head):
		Crayon.marker_fill(c, piece, patch, 5709, 16.0)
	for piece in Geometry2D.intersect_polygons(Crayon.blob(at + Vector2(62, -20), Vector2(44, 36), 5710, 14, 0.12), head):
		Crayon.marker_fill(c, piece, patch, 5711, 16.0)
	Crayon.marker_line(c, head, patch.darkened(0.4), 12.0, 5712)
	_pupil(c, at + Vector2(-46, -26), 17.0)
	_pupil(c, at + Vector2(46, -26), 17.0)
	var muzzle := Crayon.ellipse(at + Vector2(0, 98), Vector2(118, 72), 40)
	_mark(c, muzzle, pink, 5713, 11.0)
	for k in 2:
		var n := Crayon.ellipse(at + Vector2(-50 + k * 100, 80), Vector2(15, 11), 14)
		c.draw_colored_polygon(n, pink.darkened(0.32))
	_maw(c, _d_mouth(at + Vector2(0, 112), 42.0, 44.0), pink.darkened(0.5), 5714, 8.0)


## Marker: a friendly lion roaring - a scalloped orange mane, round ears, mouth wide with two fangs.
static func _roar(c: CanvasItem) -> void:
	var mane_col := Color("#ef9650")
	var gold := Color("#ffd36b")
	var at := Vector2(200, 258)
	_waves(c, Vector2(352, 306), 0.05, 5800)
	var mane := PackedVector2Array()
	for i in 112:
		var a := TAU * i / 112.0
		mane.append(at + Vector2(cos(a), sin(a)) * (150.0 + 26.0 * sqrt(absf(sin(a * 7.0)))))
	_mark(c, mane, mane_col, 5801, 12.0)
	for i in 14:
		var d := Vector2.from_angle(TAU * i / 14.0 + PI / 14.0)
		Crayon.marker_line(c, PackedVector2Array([at + d * 126.0, at + d * 152.0]), mane_col.darkened(0.3), 7.0, 5802 + i, false)
	for k in 2:
		var e := at + Vector2(-86 + k * 172, -92)
		_mark(c, Crayon.ellipse(e, Vector2(36, 34), 20), gold, 5820 + k, 10.0)
		Crayon.pencil_fill(c, Crayon.ellipse(e + Vector2(0, 4), Vector2(18, 16), 14), Color("#f7b0a8"), 5822 + k)
	_mark(c, Crayon.ellipse(at + Vector2(0, 8), Vector2(116, 108), 44), gold, 5824, 12.0)
	_shine(c, _arc(at + Vector2(0, 8), Vector2(88, 80), PI * 1.12, PI * 1.36, 10), 13.0, 5825)
	_pen(c, _union([Crayon.ellipse(at + Vector2(-36, 46), Vector2(48, 36), 24), Crayon.ellipse(at + Vector2(36, 46), Vector2(48, 36), 24)]),
		Color("#fff1d6"), 5826, 7.0)
	_maw(c, _d_mouth(at + Vector2(0, 52), 50.0, 62.0), gold.darkened(0.5), 5827)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		var fang := PackedVector2Array([at + Vector2(sx * 40, 54), at + Vector2(sx * 22, 54), at + Vector2(sx * 32, 76)])
		_under(c, fang)
		Crayon.pencil_fill(c, fang, Color("#fffaf2"), 5828 + k)
		Crayon.pencil_line(c, fang, Color("#c4a4c4"), 5.0, 5830 + k)
	_mark(c, _round_poly(PackedVector2Array([at + Vector2(-26, 14), at + Vector2(26, 14), at + Vector2(0, 40)]), 6.0),
		Color("#e98a7e"), 5832, 7.0)
	_pupil(c, at + Vector2(-46, -30), 17.0)
	_pupil(c, at + Vector2(46, -30), 17.0)


## Marker: a brown owl hooting - ear tufts, huge round eyes, a little beak open.
static func _hoot(c: CanvasItem) -> void:
	var brown := Color("#c9a07c")
	var at := Vector2(198, 276)
	_waves(c, Vector2(340, 306), 0.05, 5900)
	var tuft := PackedVector2Array([at + Vector2(-134, -84), at + Vector2(-126, -206), at + Vector2(-46, -142)])
	_mark(c, _union([Crayon.ellipse(at, Vector2(138, 162), 48), tuft, _mirror(tuft, at.x)]), brown, 5901, 12.0)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		_mark(c, _leaf(PackedVector2Array([at + Vector2(sx * 112, -20), at + Vector2(sx * 96, 142)]), 70.0), brown.darkened(0.08),
			5902 + k, 10.0)
	var belly := Crayon.ellipse(at + Vector2(0, 86), Vector2(80, 64), 28)
	_pen(c, belly, Color("#fbecd6"), 5904, 7.0)
	for k in 5:
		var p := at + Vector2(-44 + (k % 3) * 44 + (22 if k > 2 else 0), 64 + (k / 3) * 40)
		Crayon.marker_line(c, PackedVector2Array([p + Vector2(-14, -6), p + Vector2(0, 6), p + Vector2(14, -6)]), brown.darkened(0.3),
			6.0, 5905 + k, false)
	for k in 2:
		var e := at + Vector2(-60 + k * 120, -48)
		_pen(c, Crayon.ellipse(e, Vector2(62, 62), 32), Color("#fff6e6"), 5911 + k, 9.0)
		_mark(c, Crayon.ellipse(e + Vector2(4, 4), Vector2(38, 38), 24), Color("#ffd75e"), 5913 + k, 7.0)
		_pupil(c, e + Vector2(6, 6), 22.0)
	var orange := Color("#f7a04a")
	var gap := Crayon.ellipse(at + Vector2(0, 42), Vector2(18, 14), 16)
	_under(c, gap)
	Crayon.marker_fill(c, gap, MAW, 5915, 10.0)
	_mark(c, _round_poly(PackedVector2Array([at + Vector2(-16, 48), at + Vector2(16, 48), at + Vector2(0, 70)]), 4.0), orange.darkened(0.06),
		5916, 7.0)
	_mark(c, _round_poly(PackedVector2Array([at + Vector2(-24, -2), at + Vector2(24, -2), at + Vector2(0, 38)]), 5.0), orange, 5917, 7.0)


## Marker: a green frog face ribbiting - eyes up on top, a wide open mouth, throat puffed out.
static func _ribbit(c: CanvasItem) -> void:
	var green := Color("#8ccf6a")
	var at := Vector2(204, 258)
	_waves(c, Vector2(370, 290), 0.05, 6000)
	var head := _union([Crayon.ellipse(at, Vector2(160, 104), 48), Crayon.ellipse(at + Vector2(-88, -84), Vector2(62, 60), 28),
		Crayon.ellipse(at + Vector2(88, -84), Vector2(62, 60), 28)])
	_mark(c, head, green, 6001, 12.0)
	_shine(c, _arc(at, Vector2(128, 74), PI * 1.06, PI * 1.24, 8), 12.0, 6002)
	for k in 2:
		var e := at + Vector2(-88 + k * 176, -88)
		_pen(c, Crayon.ellipse(e, Vector2(40, 40), 24), Color("#fffaf2"), 6003 + k, 8.0)
		_pupil(c, e + Vector2(4, 4), 22.0)
	_mark(c, Crayon.ellipse(at + Vector2(0, 118), Vector2(100, 66), 36), Color("#fbe3a6"), 6005, 11.0)
	for k in 2:
		Crayon.pencil_fill(c, Crayon.ellipse(at + Vector2(-124 + k * 248, 4), Vector2(22, 14), 14), Color("#f4a0b0"), 6006 + k)
		c.draw_colored_polygon(Crayon.ellipse(at + Vector2(-18 + k * 36, -12), Vector2(7, 5), 10), green.darkened(0.5))
	var mouth := _join([_cubic(at + Vector2(-112, 18), at + Vector2(-50, 36), at + Vector2(50, 36), at + Vector2(112, 18), 14),
		_cubic(at + Vector2(112, 18), at + Vector2(80, 96), at + Vector2(-80, 96), at + Vector2(-112, 18), 16)])
	_maw(c, mouth, green.darkened(0.5), 6008)


## Marker: a yellow duck quacking - side on, its wide orange bill open.
static func _quack(c: CanvasItem) -> void:
	var yellow := Color("#ffd36b")
	var orange := Color("#f7a04a")
	_waves(c, Vector2(376, 212), -0.05, 6100)
	var body := _union([Crayon.ellipse(Vector2(176, 370), Vector2(148, 88), 44),
		PackedVector2Array([Vector2(56, 340), Vector2(30, 262), Vector2(120, 310)]),
		Crayon.ellipse(Vector2(198, 196), Vector2(96, 92), 40), _capsule(Vector2(200, 240), Vector2(220, 320), 120)])
	_mark(c, body, yellow, 6101, 12.0)
	_shine(c, _arc(Vector2(198, 196), Vector2(70, 66), PI * 1.1, PI * 1.38, 10), 13.0, 6102)
	_mark(c, _leaf(PackedVector2Array([Vector2(90, 350), Vector2(258, 344)]), 86.0), yellow.darkened(0.08), 6103, 10.0)
	var gap := PackedVector2Array([Vector2(272, 196), Vector2(368, 188), Vector2(362, 236), Vector2(272, 222)])
	_under(c, gap)
	Crayon.marker_fill(c, gap, MAW, 6104, 12.0)
	_mark(c, _round_poly(PackedVector2Array([Vector2(270, 214), Vector2(362, 234), Vector2(358, 258), Vector2(266, 240)]), 12.0),
		orange.darkened(0.06), 6105, 9.0)
	_mark(c, _round_poly(PackedVector2Array([Vector2(266, 168), Vector2(372, 164), Vector2(382, 192), Vector2(272, 208)]), 14.0),
		orange, 6106, 9.0)
	_pupil(c, Vector2(222, 166), 17.0)
	Crayon.pencil_fill(c, Crayon.ellipse(Vector2(226, 216), Vector2(18, 12), 14), Color("#f7a0a8"), 6107)


## Marker: a pink pig face oinking - flop ears, a big round snout, mouth open under it.
static func _oink(c: CanvasItem) -> void:
	var pink := Color("#f7aec0")
	var at := Vector2(198, 270)
	_waves(c, Vector2(352, 306), 0.05, 6200)
	var ear := PackedVector2Array([at + Vector2(-140, -44), at + Vector2(-130, -178), at + Vector2(-38, -118)])
	_mark(c, ear, pink.darkened(0.06), 6201, 11.0)
	_mark(c, _mirror(ear, at.x), pink.darkened(0.06), 6202, 11.0)
	_mark(c, Crayon.ellipse(at, Vector2(150, 130), 48), pink, 6203, 12.0)
	_shine(c, _arc(at, Vector2(116, 98), PI * 1.12, PI * 1.36, 10), 14.0, 6204)
	_pupil(c, at + Vector2(-58, -42), 17.0)
	_pupil(c, at + Vector2(58, -42), 17.0)
	for k in 2:
		Crayon.pencil_fill(c, Crayon.ellipse(at + Vector2(-102 + k * 204, 26), Vector2(22, 14), 14), Color("#f590a8"), 6205 + k)
	_mark(c, Crayon.ellipse(at + Vector2(0, 18), Vector2(74, 52), 32), pink.lightened(0.2), 6207, 11.0)
	for k in 2:
		var n := Crayon.ellipse(at + Vector2(-26 + k * 52, 18), Vector2(12, 19), 14)
		c.draw_colored_polygon(n, pink.darkened(0.38))
	_maw(c, _d_mouth(at + Vector2(0, 84), 36.0, 34.0), pink.darkened(0.5), 6208, 8.0)


## Pencil and marker: a sheep baa-ing - a cream cloud of fleece round a lavender face.
static func _baa(c: CanvasItem) -> void:
	var wool := Color("#f7f0e4")
	var face := Color("#b8acd8")
	var at := Vector2(192, 256)
	_waves(c, Vector2(356, 330), 0.05, 6300)
	var puffs := [Crayon.ellipse(at, Vector2(130, 122), 40)]
	for i in 12:
		var a := TAU * i / 12.0
		puffs.append(Crayon.ellipse(at + Vector2(cos(a) * 126.0, sin(a) * 116.0), Vector2(54, 54), 24))
	var fleece := _union(puffs)
	_under(c, fleece)
	Crayon.pencil_fill(c, fleece, wool, 6301)
	for i in 6:
		var a := TAU * i / 6.0 + 0.4
		var p := at + Vector2(cos(a) * 128.0, sin(a) * 118.0)
		Crayon.pencil_line(c, _arc(p, Vector2(20, 18), a + 2.2, a + 4.6, 8), Color("#cbbfa8"), 6.0, 6302 + i, false)
	Crayon.pencil_line(c, fleece, Color("#b4a48c"), 11.0, 6310)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		_mark(c, _leaf(PackedVector2Array([at + Vector2(sx * 58, 4), at + Vector2(sx * 150, 34)]), 52.0), face.darkened(0.06),
			6311 + k, 10.0)
	_mark(c, Crayon.ellipse(at + Vector2(0, 46), Vector2(74, 98), 36), face, 6313, 11.0)
	var tuft := _union([Crayon.ellipse(at + Vector2(-36, -40), Vector2(36, 32), 18), Crayon.ellipse(at + Vector2(0, -54), Vector2(38, 34), 18),
		Crayon.ellipse(at + Vector2(36, -40), Vector2(36, 32), 18)])
	_pen(c, tuft, wool, 6314, 8.0)
	for k in 2:
		var e := at + Vector2(-32 + k * 64, 22)
		_pen(c, Crayon.ellipse(e, Vector2(20, 22), 18), Color("#fffaf2"), 6315 + k, 6.0)
		_pupil(c, e + Vector2(2, 3), 12.0)
	_maw(c, _d_mouth(at + Vector2(0, 92), 30.0, 36.0), face.darkened(0.5), 6317, 8.0)


## Marker: a blue-grey elephant trumpeting - big ear, trunk raised high, mouth open under it.
static func _trumpet(c: CanvasItem) -> void:
	var grey := Color("#aab5de")
	var at := Vector2(200, 316)
	_waves(c, Vector2(364, 156), -0.85, 6400)
	var ear := Crayon.blob(at + Vector2(-86, -10), Vector2(98, 124), 6401, 18, 0.05)
	_mark(c, ear, grey.lightened(0.1), 6402, 11.0)
	Crayon.pencil_fill(c, Crayon.blob(at + Vector2(-92, -4), Vector2(60, 84), 6403, 16, 0.05), Color("#f4c6d6"), 6404)
	var trunk := _cubic(at + Vector2(64, 40), at + Vector2(174, 40), at + Vector2(172, -76), at + Vector2(150, -134), 20)
	var tip := trunk[trunk.size() - 1]
	var head := _union([Crayon.ellipse(at, Vector2(118, 112), 44), _band(trunk, 86.0, 50.0),
		_turn(Crayon.ellipse(tip, Vector2(36, 20), 20), tip, -0.3)])
	_mark(c, head, grey, 6405, 12.0)
	for i in 4:
		var p := trunk[8 + i * 3]
		var d := (trunk[9 + i * 3] - trunk[7 + i * 3]).normalized().orthogonal()
		Crayon.line(c, p + d * 30.0, p - d * 14.0, grey.darkened(0.3), 5.0, 6406 + i, 1.0)
	_shine(c, _arc(at, Vector2(86, 82), PI * 1.12, PI * 1.38, 10), 13.0, 6410)
	_maw(c, Crayon.ellipse(at + Vector2(58, 92), Vector2(30, 24), 20), grey.darkened(0.5), 6411, 8.0)
	_pen(c, _band(_cubic(at + Vector2(94, 66), at + Vector2(110, 90), at + Vector2(130, 98), at + Vector2(150, 94), 10), 26.0, 3.0),
		Color("#fbf3dc"), 6412, 6.0)
	_pupil(c, at + Vector2(30, -34), 16.0)
	Crayon.pencil_fill(c, Crayon.ellipse(at + Vector2(2, 18), Vector2(20, 13), 14), Color("#f4a0b8"), 6413)


## Marker: a ginger cat curled up asleep and purring - eyes shut, the set's sound arcs gone
## rumbly (little zigzag purr lines).
static func _purr(c: CanvasItem) -> void:
	var ginger := Color("#f7b27a")
	var dark := ginger.darkened(0.34)
	var head_at := Vector2(290, 304)
	for i in 3:
		var r := 44.0 + 35.0 * i
		var s := 0.6 * (1.0 - 0.06 * i)
		var rumble := PackedVector2Array()
		for k in 33:
			var t := k / 32.0
			rumble.append(Vector2(386, 276) + Vector2.from_angle(-0.4 + lerpf(-s, s, t)) * (r + sin(t * PI * (3.0 + i)) * 8.0))
		_frame(c, rumble, WAVE, 13.0, 6501 + i, false)
	_mark(c, Crayon.ellipse(Vector2(178, 350), Vector2(160, 98), 48), ginger, 6504, 12.0)
	for k in 3:
		var x := 96.0 + k * 48.0
		Crayon.marker_line(c, PackedVector2Array([Vector2(x, 266), Vector2(x + 12, 302)]), dark, 8.0, 6505 + k, false)
	_shine(c, _arc(Vector2(178, 350), Vector2(130, 74), PI * 1.12, PI * 1.32, 10), 13.0, 6508)
	var tail := _cubic(Vector2(34, 362), Vector2(28, 448), Vector2(196, 464), Vector2(284, 436), 20)
	_mark(c, _union([_band(tail, 50.0, 40.0), Crayon.ellipse(tail[tail.size() - 1], Vector2(20, 20), 14)]), ginger.lightened(0.04), 6509, 11.0)
	var ear := PackedVector2Array([head_at + Vector2(-86, -26), head_at + Vector2(-80, -116), head_at + Vector2(-22, -72)])
	_mark(c, _union([Crayon.ellipse(head_at, Vector2(96, 82), 40), ear, _mirror(ear, head_at.x)]), ginger, 6510, 12.0)
	var inner := PackedVector2Array([head_at + Vector2(-70, -46), head_at + Vector2(-68, -96), head_at + Vector2(-36, -70)])
	_pen(c, inner, Color("#f7b0c4"), 6511, 0.0)
	_pen(c, _mirror(inner, head_at.x), Color("#f7b0c4"), 6512, 0.0)
	for k in 2:
		_shut(c, head_at + Vector2(-38 + k * 76, -6), 22.0, dark, 6513 + k)
		Crayon.pencil_fill(c, Crayon.ellipse(head_at + Vector2(-60 + k * 120, 22), Vector2(18, 11), 14), Color("#f490a8"), 6515 + k)
	_mark(c, PackedVector2Array([head_at + Vector2(-12, 14), head_at + Vector2(12, 14), head_at + Vector2(0, 26)]), Color("#f490b0"), 6517, 5.0)
	Crayon.marker_line(c, _join([_arc(head_at + Vector2(-10, 30), Vector2(10, 10), 0.0, PI * 0.9, 6),
		_arc(head_at + Vector2(10, 30), Vector2(10, 10), PI * 0.1, PI, 6)]), dark, 6.0, 6518, false)
	for k in 2:
		_mark(c, Crayon.ellipse(head_at + Vector2(-34 + k * 64, 84), Vector2(32, 20), 20), ginger.lightened(0.08), 6519 + k, 9.0)


## Marker: a little mint robot beeping - screen face, antenna, a button tummy, little arms.
static func _beep(c: CanvasItem) -> void:
	var mint := Color("#7fd0c8")
	_waves(c, Vector2(334, 190), -0.15, 6600)
	_frame(c, PackedVector2Array([Vector2(200, 116), Vector2(200, 66)]), mint.darkened(0.15), 10.0, 6601, false)
	_mark(c, Crayon.ellipse(Vector2(200, 54), Vector2(24, 24), 18), Color("#ffd75e"), 6602, 8.0)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		_mark(c, _capsule(Vector2(200 + sx * 92, 306), Vector2(200 + sx * 140, 376), 40), mint.darkened(0.08), 6603 + k, 10.0)
		_mark(c, Crayon.rounded_rect(Rect2(200 + sx * 50 - 32, 410, 64, 46), 18), mint.darkened(0.14), 6605 + k, 10.0)
	_mark(c, Crayon.rounded_rect(Rect2(178, 240, 44, 40), 8), mint.darkened(0.1), 6607, 9.0)
	_mark(c, Crayon.rounded_rect(Rect2(98, 268, 204, 156), 34), mint, 6608, 12.0)
	_pen(c, Crayon.rounded_rect(Rect2(138, 300, 124, 82), 16), Color("#e6f7f4"), 6609, 7.0)
	_mark(c, Crayon.ellipse(Vector2(176, 341), Vector2(17, 17), 14), Color("#f48fb8"), 6610, 6.0)
	_mark(c, Crayon.ellipse(Vector2(224, 341), Vector2(17, 17), 14), Color("#ffd75e"), 6611, 6.0)
	_mark(c, Crayon.rounded_rect(Rect2(108, 104, 184, 150), 46), mint.lightened(0.1), 6612, 12.0)
	Crayon.line(c, Vector2(124, 140), Vector2(124, 220), SHINE, 11.0, 6613)
	_pen(c, Crayon.rounded_rect(Rect2(136, 130, 128, 100), 30), Color("#eefaf8"), 6614, 7.0)
	_pupil(c, Vector2(174, 168), 16.0)
	_pupil(c, Vector2(226, 168), 16.0)
	_maw(c, Crayon.rounded_rect(Rect2(182, 194, 36, 28), 11), mint.darkened(0.5), 6615, 6.0)


## Marker: a purple slime blob gurgling - goopy foot, googly eyes, open mouth, bubbles rising.
static func _gurgle(c: CanvasItem) -> void:
	var purple := Color("#b98ae6")
	_waves(c, Vector2(354, 330), 0.05, 6700)
	var blob := _arc(Vector2(204, 404), Vector2(148, 238), PI, TAU, 40)
	blob.append(Vector2(370, 432))
	blob.append(Vector2(390, 454))
	for i in 13:
		var t := i / 12.0
		blob.append(Vector2(lerpf(378, 32, t), 456.0 + sin(t * PI * 4.0) * 6.0))
	blob.append(Vector2(20, 450))
	blob.append(Vector2(38, 430))
	_mark(c, blob, purple, 6701, 12.0)
	_shine(c, _arc(Vector2(204, 404), Vector2(112, 196), PI * 1.12, PI * 1.32, 12), 15.0, 6702)
	for k in 2:
		var e := Vector2(160 + k * 90, 290)
		_pen(c, Crayon.ellipse(e, Vector2(32, 36), 24), Color("#fffaf2"), 6704 + k, 8.0)
		_pupil(c, e + Vector2(4, 6), 18.0)
	var mouth := _join([_cubic(Vector2(156, 360), Vector2(180, 350), Vector2(228, 370), Vector2(254, 358), 10),
		_cubic(Vector2(254, 358), Vector2(258, 430), Vector2(152, 430), Vector2(156, 360), 14)])
	_maw(c, mouth, purple.darkened(0.5), 6706, 8.0)
	for b in [[Vector2(84, 128), 30.0], [Vector2(136, 66), 20.0], [Vector2(54, 50), 14.0], [Vector2(262, 112), 16.0]]:
		var at: Vector2 = b[0]
		var r: float = b[1]
		_pen(c, Crayon.ellipse(at, Vector2(r, r), 20), Color("#f1e6fc"), 6707 + int(at.x), 7.0)
		c.draw_colored_polygon(Crayon.ellipse(at + Vector2(-r * 0.35, -r * 0.35), Vector2(r * 0.28, r * 0.28), 12), Color(1, 1, 1, 0.9))


## Marker: a coral coiled spring boinging up between two lavender plates.
static func _boing(c: CanvasItem) -> void:
	var red := Color("#f27a6e")
	var metal := Color("#bdb8dc")
	_waves(c, Vector2(332, 168), -0.15, 6800)
	_pen(c, Crayon.ellipse(Vector2(200, 462), Vector2(126, 18), 28), Color("#ddd9f2"), 6801, 0.0)
	_mark(c, Crayon.rounded_rect(Rect2(96, 412, 208, 40), 18), metal, 6804, 10.0)
	var coil := PackedVector2Array()
	for i in 181:
		var t := i / 180.0
		var a := t * 3.5 * TAU
		coil.append(Vector2(200 + sin(a) * 92.0, lerpf(404, 168, t) + cos(a) * 22.0))
	_frame(c, coil, red, 22.0, 6805, false)
	_mark(c, Crayon.rounded_rect(Rect2(96, 126, 208, 44), 18), metal, 6806, 10.0)
	Crayon.line(c, Vector2(116, 138), Vector2(284, 138), SHINE, 9.0, 6807)


## Marker: a little green alien in a flying saucer, warbling - glass dome, a row of lights.
static func _trill(c: CanvasItem) -> void:
	var metal := Color("#b9b4e0")
	var green := Color("#9ad97c")
	_waves(c, Vector2(350, 196), -0.3, 6900)
	var dome := _arc(Vector2(200, 316), Vector2(128, 176), PI, TAU, 36)
	_under(c, dome)
	Crayon.pencil_fill(c, dome, Color("#d8ecfb"), 6901)
	for k in 2:
		var sx := -1.0 if k == 0 else 1.0
		var a := Vector2(200 + sx * 30, 184)
		var b := Vector2(200 + sx * 54, 160)
		Crayon.marker_line(c, PackedVector2Array([a, b]), green.darkened(0.4), 8.0, 6902 + k, false)
		_mark(c, Crayon.ellipse(b, Vector2(15, 15), 12), Color("#f48fb8"), 6904 + k, 6.0)
	_mark(c, Crayon.ellipse(Vector2(200, 230), Vector2(80, 68), 32), green, 6906, 11.0)
	_pupil(c, Vector2(170, 218), 20.0)
	_pupil(c, Vector2(230, 218), 20.0)
	_maw(c, Crayon.ellipse(Vector2(200, 256), Vector2(19, 15), 18), green.darkened(0.5), 6907, 7.0)
	Crayon.marker_line(c, dome, Color("#8fb4d8"), 11.0, 6908)
	_shine(c, _arc(Vector2(200, 316), Vector2(100, 144), PI * 1.12, PI * 1.34, 10), 13.0, 6909)
	_mark(c, Crayon.ellipse(Vector2(200, 368), Vector2(96, 30), 28), metal.darkened(0.1), 6910, 10.0)
	_mark(c, Crayon.ellipse(Vector2(200, 328), Vector2(182, 52), 56), metal, 6911, 12.0)
	for k in 5:
		var a := PI * (0.2 + k * 0.15)
		_mark(c, Crayon.ellipse(Vector2(200, 328) + Vector2(cos(a) * 144.0, sin(a) * 28.0), Vector2(14, 12), 12), Color("#ffd75e"),
			6912 + k, 5.0)


## Marker: a white goose honking - long neck, orange beak open, a grey wing.
static func _honk(c: CanvasItem) -> void:
	var white := Color("#ebe8f6")
	var orange := Color("#f7a04a")
	_waves(c, Vector2(382, 150), 0.0, 7000)
	for k in 2:
		var x := 150.0 + k * 70.0
		_mark(c, _round_poly(PackedVector2Array([Vector2(x, 432), Vector2(x + 44, 462), Vector2(x - 30, 462)]), 6.0), orange, 7001 + k, 7.0)
	var neck := _cubic(Vector2(256, 340), Vector2(304, 270), Vector2(236, 214), Vector2(270, 150), 16)
	var goose := _union([Crayon.ellipse(Vector2(180, 372), Vector2(152, 84), 44),
		PackedVector2Array([Vector2(48, 356), Vector2(20, 298), Vector2(104, 330)]), _band(neck, 74.0, 60.0),
		Crayon.ellipse(Vector2(280, 142), Vector2(58, 50), 28)])
	_mark(c, goose, white, 7003, 12.0)
	_shine(c, _offset(neck.slice(4, 14), -20.0), 11.0, 7004)
	var wing := _leaf(PackedVector2Array([Vector2(86, 350), Vector2(272, 352)]), 94.0)
	_mark(c, wing, Color("#cfcbe6"), 7005, 10.0)
	for k in 3:
		var x := 150.0 + k * 40.0
		Crayon.marker_line(c, PackedVector2Array([Vector2(x, 342), Vector2(x + 30, 366)]), Color("#cfcbe6").darkened(0.35), 6.0,
			7006 + k, false)
	_pupil(c, Vector2(292, 128), 15.0)
	_beak(c, Vector2(316, 146), 0.05, 72.0, 48.0, 0.56, orange, 7010)


# --- Drawing helpers ---------------------------------------------------------------------------

static func _under(c: CanvasItem, poly: PackedVector2Array) -> void:
	if poly.size() >= 3:
		c.draw_colored_polygon(poly, PAPER)


## A shape in coloured pencil on paper: opaque, pencil-filled, outlined a darker shade.
static func _pen(c: CanvasItem, poly: PackedVector2Array, col: Color, seed: int, w := 9.0) -> void:
	_under(c, poly)
	Crayon.pencil_fill(c, poly, col, seed)
	if w > 0.0:
		Crayon.pencil_line(c, poly, col.darkened(0.45), w, seed + 31)


## A shape in marker on paper: opaque, marker-filled, outlined a darker shade.
static func _mark(c: CanvasItem, poly: PackedVector2Array, col: Color, seed: int, w := 11.0) -> void:
	_under(c, poly)
	Crayon.marker_fill(c, poly, col, seed)
	Crayon.marker_line(c, poly, col.darkened(0.5), w, seed + 31)


## A coloured line with darker edges: the same wobble twice, wide and dark then narrower in colour.
static func _frame(c: CanvasItem, pts: PackedVector2Array, col: Color, w: float, seed: int,
		closed := true) -> void:
	Crayon.marker_line(c, pts, col.darkened(0.48), w + 11.0, seed, closed)
	Crayon.marker_line(c, pts, col, w, seed, closed)


## A highlight along a path: one smooth translucent white stroke.
static func _shine(c: CanvasItem, pts: PackedVector2Array, w: float, seed: int) -> void:
	c.draw_polyline(Crayon.wobbled(pts, seed, 0.8), SHINE, w, true)


## A dark plum pupil with a white glint - never black.
static func _pupil(c: CanvasItem, at: Vector2, r: float) -> void:
	var p := Crayon.ellipse(at, Vector2(r, r * 1.08), 24)
	c.draw_colored_polygon(p, PLUM)
	Crayon.marker_fill(c, p, PLUM.lightened(0.12), int(at.x * 7.0 + at.y), maxf(6.0, r * 0.5))
	c.draw_colored_polygon(Crayon.ellipse(at + Vector2(-r * 0.32, -r * 0.36), Vector2(r * 0.36, r * 0.36), 16),
		Color(1, 1, 1, 0.95))


## A box in three-quarter view, in a drawing's own frame then placed on the sheet: a front face,
## a lighter top and a slightly darker side, the edges between them drawn in.
static func _block(c: CanvasItem, r: Rect2, k: Vector2, col: Color, seed: int, mid: Vector2, at: Vector2,
		ang: float) -> void:
	var a := r.position
	var b := Vector2(r.end.x, r.position.y)
	var e := r.end
	var d := Vector2(a.x, e.y)
	var whole := _place(PackedVector2Array([d, a, a + k, b + k, e + k, e]), mid, at, ang)
	_under(c, whole)
	Crayon.marker_fill(c, _place(PackedVector2Array([a, b, e, d]), mid, at, ang), col, seed)
	Crayon.marker_fill(c, _place(PackedVector2Array([a, b, b + k, a + k]), mid, at, ang), col.lightened(0.3), seed + 1, 16.0)
	Crayon.marker_fill(c, _place(PackedVector2Array([b, b + k, e + k, e]), mid, at, ang), col.darkened(0.08), seed + 2, 16.0)
	var line := col.darkened(0.5)
	Crayon.marker_line(c, _place(PackedVector2Array([a, b, e]), mid, at, ang), line, 7.0, seed + 3, false)
	Crayon.marker_line(c, _place(PackedVector2Array([b, b + k]), mid, at, ang), line, 7.0, seed + 4, false)
	Crayon.marker_line(c, whole, line, 11.0, seed + 5)


## Sound arcs fanning out from `at` towards angle `ang`: the one sign, across the whole set, that
## something is making a noise. Same colour and weight everywhere.
static func _waves(c: CanvasItem, at: Vector2, ang: float, seed: int, n := 3, r0 := 44.0, gap := 35.0,
		w := 15.0, spread := 0.6) -> void:
	for i in n:
		var r := r0 + gap * i
		var s := spread * (1.0 - 0.06 * i)
		_frame(c, _arc(at, Vector2(r, r), ang - s, ang + s, 14), WAVE, w, seed + i, false)


## An open mouth: rose inside, a pink tongue in the bottom of it, outlined in `line`.
static func _maw(c: CanvasItem, mouth: PackedVector2Array, line: Color, seed: int, w := 9.0) -> void:
	_under(c, mouth)
	Crayon.marker_fill(c, mouth, MAW, seed, 14.0)
	var r := Crayon.bounds(mouth)
	var tongue := Crayon.ellipse(Vector2(r.get_center().x, r.end.y - r.size.y * 0.06), Vector2(r.size.x * 0.34, r.size.y * 0.38), 24)
	for piece in Geometry2D.intersect_polygons(tongue, mouth):
		Crayon.marker_fill(c, piece, TONGUE, seed + 1, 12.0)
	Crayon.marker_line(c, mouth, line, w, seed + 2)


## A D-shaped open mouth hanging from a flat top edge centred on `top`.
static func _d_mouth(top: Vector2, half_w: float, depth: float) -> PackedVector2Array:
	return _join([[top + Vector2(-half_w, 0), top + Vector2(half_w, 0)], _arc(top, Vector2(half_w, depth), 0.0, PI, 16)])


## An open beak from `base` along angle `ang`: top and bottom halves parted by `gape` radians,
## the inside of the mouth showing between them.
static func _beak(c: CanvasItem, base: Vector2, ang: float, length: float, width: float, gape: float,
		col: Color, seed: int) -> void:
	var f := Vector2.from_angle(ang)
	var up := f.orthogonal()
	var top_tip := base + f.rotated(-gape * 0.5) * length
	var bot_tip := base + f.rotated(gape * 0.5) * length * 0.84
	var mouth := PackedVector2Array([base - f * 6.0, base.lerp(top_tip, 0.86), base.lerp(bot_tip, 0.86)])
	_under(c, mouth)
	Crayon.marker_fill(c, mouth, MAW, seed, 12.0)
	_mark(c, PackedVector2Array([base + f * 2.0, bot_tip, base - up * width * 0.42]), col.darkened(0.06), seed + 1, 8.0)
	_mark(c, PackedVector2Array([base + up * width * 0.5, top_tip, base + f * 2.0]), col, seed + 2, 8.0)


## Two whiskers from `at`, out to the side `sx` (-1 left, 1 right).
static func _whiskers(c: CanvasItem, at: Vector2, sx: float, length: float, col: Color, seed: int) -> void:
	for k in 2:
		var a := at + Vector2(0, k * 18.0)
		Crayon.line(c, a, a + Vector2(sx * length, -16.0 + k * 36.0), col, 5.0, seed + k)


## A shut, sleeping eye: a little smile-shaped curve.
static func _shut(c: CanvasItem, at: Vector2, r: float, col: Color, seed: int) -> void:
	Crayon.marker_line(c, _arc(at, Vector2(r, r * 0.7), PI * 0.12, PI * 0.88, 10), col, 9.0, seed, false)


## One musical note (a quaver) with its head at `at`, `s` its size.
static func _note(c: CanvasItem, at: Vector2, s: float, col: Color, seed: int) -> void:
	var head := _turn(Crayon.ellipse(at, Vector2(46, 34) * s, 24), at, -0.38)
	var top := at + Vector2(38, -170) * s
	var stem := _capsule(at + Vector2(38, -6) * s, top, 26.0 * s)
	var flag := _band(_cubic(top, top + Vector2(44, 18) * s, top + Vector2(76, 58) * s, top + Vector2(54, 112) * s, 12),
		34.0 * s, 12.0 * s)
	_mark(c, _union([head, stem, flag]), col, seed, 10.0)


## A polygon with its corners rounded off by r (shrunk, then grown back round).
static func _round_poly(poly: PackedVector2Array, r: float) -> PackedVector2Array:
	var inner := Geometry2D.offset_polygon(poly, -r)
	if inner.is_empty():
		return poly
	var outer := Geometry2D.offset_polygon(inner[0], r, Geometry2D.JOIN_ROUND)
	if outer.is_empty():
		return poly
	return outer[0]


## A fat wax crayon centred on `at`, its point towards -x turned by `ang` (tool_crayon, recoloured).
static func _crayon_stick(c: CanvasItem, at: Vector2, ang: float, col: Color, seed: int) -> void:
	var mid := Vector2(210, 0)
	var tip := _union([PackedVector2Array([Vector2(10, -16), Vector2(84, -52), Vector2(84, 52), Vector2(10, 16)]),
		Crayon.ellipse(Vector2(12, 0), Vector2(14, 18), 16)])
	_mark(c, _place(tip, mid, at, ang), col.darkened(0.08), seed, 10.0)
	_mark(c, _place(Crayon.rounded_rect(Rect2(76, -60, 330, 120), 22), mid, at, ang), col, seed + 1, 11.0)
	var wrap := _place(Crayon.rounded_rect(Rect2(134, -62, 224, 124), 6), mid, at, ang)
	_mark(c, wrap, col.lightened(0.5), seed + 2, 9.0)
	for x in [162.0, 330.0]:
		var stripe := _place(PackedVector2Array([Vector2(x - 10, -62), Vector2(x + 10, -62),
			Vector2(x + 10, 62), Vector2(x - 10, 62)]), mid, at, ang)
		for piece in Geometry2D.intersect_polygons(stripe, wrap):
			Crayon.marker_fill(c, piece, col, seed + 3 + int(x), 12.0)
	Crayon.marker_line(c, _place(PackedVector2Array([Vector2(186, 0), Vector2(306, 0)]), mid, at, ang),
		col.darkened(0.15), 9.0, seed + 4, false)
	Crayon.line(c, _place1(Vector2(90, -36), mid, at, ang), _place1(Vector2(390, -36), mid, at, ang), SHINE, 10.0, seed + 5)


# --- Geometry helpers --------------------------------------------------------------------------

## Points along a cubic Bezier.
static func _cubic(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, n := 16) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n + 1:
		var t := i / float(n)
		var u := 1.0 - t
		pts.append(p0 * u * u * u + p1 * 3.0 * u * u * t + p2 * 3.0 * u * t * t + p3 * t * t * t)
	return pts


## A smooth curve through every point (Catmull-Rom), `per` points per span.
static func _spline(pts: Array, per := 8) -> PackedVector2Array:
	var out := PackedVector2Array()
	var n := pts.size()
	for i in n - 1:
		var p0: Vector2 = pts[maxi(i - 1, 0)]
		var p1: Vector2 = pts[i]
		var p2: Vector2 = pts[i + 1]
		var p3: Vector2 = pts[mini(i + 2, n - 1)]
		for s in per:
			var t := s / float(per)
			var t2 := t * t
			var t3 := t2 * t
			out.append(0.5 * ((2.0 * p1) + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2
				+ (3.0 * p1 - p0 - 3.0 * p2 + p3) * t3))
	var last: Vector2 = pts[n - 1]
	out.append(last)
	return out


## Points along part of an ellipse, from angle a0 to a1 (y down: PI/2 is the bottom).
static func _arc(center: Vector2, radius: Vector2, a0: float, a1: float, n := 24) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n + 1:
		var a := lerpf(a0, a1, i / float(n))
		pts.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	return pts


## Point lists joined end to end, dropping repeated joints and a repeated closing point.
static func _join(parts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for part in parts:
		for q in part:
			var p: Vector2 = q
			if out.is_empty() or out[out.size() - 1].distance_to(p) > 0.5:
				out.append(p)
	if out.size() > 2 and out[0].distance_to(out[out.size() - 1]) < 0.5:
		out.remove_at(out.size() - 1)
	return out


## A strip of width w0 -> w1 along a path, as one polygon.
static func _band(path: PackedVector2Array, w0: float, w1 := -1.0) -> PackedVector2Array:
	if w1 < 0.0:
		w1 = w0
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var n := path.size()
	for i in n:
		var a := path[maxi(i - 1, 0)]
		var b := path[mini(i + 1, n - 1)]
		var normal := (b - a).normalized().orthogonal()
		var w := lerpf(w0, w1, i / float(n - 1)) * 0.5
		left.append(path[i] + normal * w)
		right.append(path[i] - normal * w)
	right.reverse()
	left.append_array(right)
	return left


## A strip along a path with a width per point, its edges bulging in soft scallops.
static func _fluffy_w(path: PackedVector2Array, widths: PackedFloat32Array, bumps: float, depth: float,
		depth_right := -1.0) -> PackedVector2Array:
	if depth_right < 0.0:
		depth_right = depth
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var n := path.size()
	for i in n:
		var t := i / float(n - 1)
		var a := path[maxi(i - 1, 0)]
		var b := path[mini(i + 1, n - 1)]
		var normal := (b - a).normalized().orthogonal()
		var w := widths[i] * 0.5
		left.append(path[i] + normal * w * (1.0 - depth + depth * sqrt(absf(sin(t * bumps * PI)))))
		right.append(path[i] - normal * w * (1.0 - depth_right + depth_right * sqrt(absf(sin(t * bumps * PI + PI * 0.5)))))
	right.reverse()
	left.append_array(right)
	return left


static func _shift(poly: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(p + by)
	return out


## A strip along a path with a width per point, its edges tufted like fur: little pointed tufts.
static func _furry(path: PackedVector2Array, widths: PackedFloat32Array, tufts: float, depth: float) -> PackedVector2Array:
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var n := path.size()
	for i in n:
		var t := i / float(n - 1)
		var a := path[maxi(i - 1, 0)]
		var b := path[mini(i + 1, n - 1)]
		var normal := (b - a).normalized().orthogonal()
		var w := widths[i] * 0.5
		var f1 := 1.0 - depth * absf(fposmod(t * tufts, 1.0) - 0.5) * 2.0
		var f2 := 1.0 - depth * absf(fposmod(t * tufts + 0.5, 1.0) - 0.5) * 2.0
		left.append(path[i] + normal * w * f1)
		right.append(path[i] - normal * w * f2)
	right.reverse()
	left.append_array(right)
	return left


## A path pushed sideways by d along its normal.
static func _offset(path: PackedVector2Array, d: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var n := path.size()
	for i in n:
		var a := path[maxi(i - 1, 0)]
		var b := path[mini(i + 1, n - 1)]
		out.append(path[i] + (b - a).normalized().orthogonal() * d)
	return out


static func _reverse(path: PackedVector2Array) -> PackedVector2Array:
	var out := path.duplicate()
	out.reverse()
	return out


## A leaf: a strip along a path, pointed at both ends, widest in the middle.
static func _leaf(path: PackedVector2Array, width: float) -> PackedVector2Array:
	var fine := path
	if path.size() < 8:
		fine = _resample(path, path[0].distance_to(path[path.size() - 1]) / 12.0)
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var n := fine.size()
	for i in n:
		var a := fine[maxi(i - 1, 0)]
		var b := fine[mini(i + 1, n - 1)]
		var normal := (b - a).normalized().orthogonal()
		var w := width * 0.5 * pow(sin(PI * i / float(n - 1)), 0.75)
		left.append(fine[i] + normal * w)
		right.append(fine[i] - normal * w)
	right.reverse()
	right.remove_at(0)
	right.remove_at(right.size() - 1)
	left.append_array(right)
	return left


## A thick arrow along a path: the strip, and a triangle head past its end.
static func _arrow(path: PackedVector2Array, w: float, head_len: float, head_w: float) -> PackedVector2Array:
	var n := path.size()
	var end := path[n - 1]
	var dir := (end - path[maxi(0, n - 3)]).normalized()
	var normal := dir.orthogonal()
	var head := PackedVector2Array([end - dir * 6.0 + normal * head_w * 0.5, end + dir * head_len,
		end - dir * 6.0 - normal * head_w * 0.5])
	return _union([_band(path, w), head])


## A stadium: a bar from a to b, w wide, with round ends.
static func _capsule(a: Vector2, b: Vector2, w: float) -> PackedVector2Array:
	var ang := (b - a).angle()
	var r := w * 0.5
	var pts := PackedVector2Array()
	for i in 11:
		pts.append(b + Vector2.from_angle(ang - PI / 2.0 + PI * i / 10.0) * r)
	for i in 11:
		pts.append(a + Vector2.from_angle(ang + PI / 2.0 + PI * i / 10.0) * r)
	return pts


## A four-pointed sparkle with curved sides.
static func _sparkle(center: Vector2, size: float, thin := 0.3) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 4:
		var a0 := -PI / 2.0 + i * PI / 2.0
		var tip := center + Vector2.from_angle(a0) * size
		var next := center + Vector2.from_angle(a0 + PI / 2.0) * size
		var ctrl := center + Vector2.from_angle(a0 + PI / 4.0) * size * thin
		for k in 6:
			var t := k / 6.0
			pts.append(tip * (1.0 - t) * (1.0 - t) + ctrl * 2.0 * (1.0 - t) * t + next * t * t)
	return pts


## A heart, point down, with enough points to stay smooth when big.
static func _heart(center: Vector2, size: float, n := 72) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var t := TAU * i / n
		var x := 16.0 * pow(sin(t), 3)
		var y := 13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)
		pts.append(center + Vector2(x, -y) * size / 32.0)
	return pts


## Points every `step` px along a path.
static func _resample(path: PackedVector2Array, step: float) -> PackedVector2Array:
	var out := PackedVector2Array([path[0]])
	var carry := 0.0
	for i in path.size() - 1:
		var a := path[i]
		var b := path[i + 1]
		var seg := a.distance_to(b)
		if seg < 0.001:
			continue
		var d := step - carry
		while d <= seg:
			out.append(a.lerp(b, d / seg))
			d += step
		carry = seg - (d - step)
	if out[out.size() - 1].distance_to(path[path.size() - 1]) > 0.5:
		out.append(path[path.size() - 1])
	return out


## The union of overlapping shapes, as one outline.
static func _union(polys: Array) -> PackedVector2Array:
	var acc: PackedVector2Array = polys[0]
	for i in range(1, polys.size()):
		var next: PackedVector2Array = polys[i]
		acc = _largest(Geometry2D.merge_polygons(acc, next))
	return acc


static func _largest(polys: Array) -> PackedVector2Array:
	var best := PackedVector2Array()
	var best_area := -1.0
	for q in polys:
		var p: PackedVector2Array = q
		var area := 0.0
		for i in p.size():
			area += p[i].cross(p[(i + 1) % p.size()])
		if absf(area) > best_area:
			best_area = absf(area)
			best = p
	return best


static func _mirror(poly: PackedVector2Array, cx: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(Vector2(2.0 * cx - p.x, p.y))
	return out


static func _flip_y(poly: PackedVector2Array, cy: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(Vector2(p.x, 2.0 * cy - p.y))
	return out


static func _scale(poly: PackedVector2Array, about: Vector2, k: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(about + (p - about) * k)
	return out


static func _turn(poly: PackedVector2Array, pivot: Vector2, angle: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(pivot + (p - pivot).rotated(angle))
	return out


## From a drawing's own frame (centred on `mid`) onto the sheet at `at`, turned.
static func _place(poly: PackedVector2Array, mid: Vector2, at: Vector2, angle: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(_place1(p, mid, at, angle))
	return out


static func _place1(p: Vector2, mid: Vector2, at: Vector2, angle: float) -> Vector2:
	return at + (p - mid).rotated(angle)
