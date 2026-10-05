class_name CreaturePart
extends Node2D
## One drawn part hung on its joint, plus that part type's motion recipe.
##
## This is the idea the whole game rests on (.ai/creature-pipeline.md): motion comes from the
## TYPE of part, not from the creature. A leg steps, a tail wags, an eye blinks, an antenna
## boings - whatever creature it is on and however many there are. So any combination a kid
## invents animates on the first try, and nobody ever authors an animation for one creature.
##
## The node's origin is the joint (the red dot the kid drew from). `base` is its rest
## transform relative to its parent; every frame the recipe's rotation/squash is applied in
## the part's own frame on top of it. The drawing itself is never touched - parts only ever
## rotate and squash, they are not warped or redrawn.

## How springy each wobbly type is: [stiffness, damping]. Low stiffness = more boing.
const SPRINGS := {
	"antenna": [55.0, 4.0], "hair": [45.0, 5.0], "ear": [120.0, 7.0],
	"horn": [420.0, 14.0], "spike": [480.0, 16.0], "other": [160.0, 9.0],
	"clothing": [260.0, 12.0], "hand": [300.0, 12.0],
}

## How far a mouth is squashed when shut. Kids draw it wide open; shut is that drawing
## squeezed to a line, and it opens back up to the drawing they made.
const MOUTH_SHUT := 0.14

var type := ""
var base := Transform2D.IDENTITY
var sprite: Sprite2D
var pair := 0
var side := 0
var spring := 0.0
var spring_vel := 0.0
var _offset := 0.0


## `image` is the drawing (for placing sparkles if it is shiny); `shine_mask` limits the shine
## to the strokes drawn with a shiny marker.
func setup(p: Dictionary, texture: Texture2D, image: Image = null, shine_mask: Image = null) -> void:
	type = p["type"]
	pair = int(p.get("pair", 0))
	side = int(p.get("side", 0))
	name = p["id"]
	_offset = absf(Crayon.noise(hash(p["id"]), 3)) * 6.0
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	var s := float(p["draw_scale"]) * float(p["scale"])
	sprite.scale = Vector2(s, s)
	sprite.offset = -PetBuilder.v2(p["pivot"])
	if int(p.get("side", 0)) == 1:
		# Far-side copies sit a shade darker, which reads as depth - the cutout trick. Only the
		# far copy: a tail tucked behind the body is still on the near side.
		sprite.modulate = Color(0.74, 0.74, 0.8)
	add_child(sprite)
	var shine: String = p.get("shine", "")
	if shine != "" and image != null:
		Shiny.apply(sprite, image, shine, shine_mask, sprite.offset)


func animate(c: Creature, delta: float) -> void:
	var rot := 0.0
	var sc := Vector2.ONE
	var off := Vector2.ZERO
	var t := c.time + _offset
	# Near and far legs, and front and back pairs, step out of phase: a diagonal trot on four
	# legs, a plain walk on two, a ripple on eight.
	var gait := c.phase + float(side + pair) * PI

	match type:
		"body":
			var breathe := sin(c.time * c.breath_speed) * c.breath
			sc = Vector2(1.0 - breathe * 0.5 - c.squash * 0.5, 1.0 + breathe + c.squash)
			off.y = -c.bob
		"head":
			rot = sin(t * 1.1) * 0.035 + c.head_tilt + c.nod * sin(c.time * 13.0)
		"eye":
			sc.y = maxf(0.08, 1.0 - c.blink)
		"mouth":
			sc.y = lerpf(MOUTH_SHUT, 1.0, clampf(c.mouth_open, 0.0, 1.0))
		"nose":
			sc = Vector2.ONE * (1.0 + c.sniff * 0.12 * sin(c.time * 26.0))
		"leg":
			rot = sin(gait) * 0.5 * c.stride + c.tuck * 0.45
		"arm":
			rot = -sin(gait) * 0.4 * c.stride + c.wave * sin(c.time * 14.0 + side) * 0.7
		"wing":
			var beat := sin(c.time * 17.0 + side * 0.4)
			rot = -beat * 0.55 * c.flap + sin(t * 2.0) * 0.04
			sc.x = 1.0 - c.flap * 0.15 * absf(beat)
		"tail":
			rot = sin(c.time * c.wag_speed + _offset) * c.wag
		"fin":
			rot = sin(t * (4.0 + 6.0 * c.swim) + pair * 0.7) * (0.1 + 0.15 * c.swim)
		"tentacle":
			rot = sin(t * 2.4 + pair * 1.3 + side) * 0.22 + sin(gait) * 0.3 * c.stride
		"foot", "claw":
			rot = 0.0  # rides its leg rigidly
		_:
			rot = _spring(c, delta)
			if type == "ear":
				rot += c.ear_droop + sin(t * 1.7) * 0.03

	transform = base * Transform2D(rot, sc, 0.0, off)


## Secondary motion: the part lags behind the body's moves and wobbles back. The rig is
## mirrored when the creature faces left, so acceleration is turned into the rig's own frame.
func _spring(c: Creature, delta: float) -> float:
	var k: Array = SPRINGS.get(type, SPRINGS["other"])
	var accel_x := c.accel.x * c.facing
	var target := clampf(-accel_x * 0.0005 + c.bob_vel * 0.0025, -0.6, 0.6)
	spring_vel += (k[0] * (target - spring) - k[1] * spring_vel) * delta
	spring += spring_vel * delta
	return spring
