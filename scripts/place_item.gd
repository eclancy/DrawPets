class_name PlaceItem
extends Node2D
## A food or a toy dragged out into a place. It lives on the same ground plane as the creature:
## `position` is the spot on the ground, `z` how high above it, `vz` how fast it is going up.
##
## How it flies comes from the words the kid gave it, never from how it was drawn: "bouncy"
## bounces high, "floaty" glides, "rolly" rolls on, "heavy" barely leaves the hand, "spinny"
## spins. A "stretchy" toy stretches between a pet's mouth and a finger in tug of war. How the
## pets PLAY with it comes from its words too (Words.toy_play): see PlaceScreen's Toys.

## Hit the ground going down at `speed` px/s - the louder the bounce sound.
signal bounced(speed: float)

var item: Dictionary
var is_food := false
var z := 0.0
var vz := 0.0
var vel := Vector2.ZERO
var held := false
var carrier: Creature = null
var radius := 30.0
var bounds := Rect2(40, 460, 1200, 240)
var bites_left := 1.0
var sprite: Sprite2D
## While tugging: the far end of the stretch (a finger), or Vector2.INF.
var stretch_to := Vector2.INF

var _gravity := 1500.0
var _bounce := 0.2
var _friction := 900.0
var _glide := false
var _roll := false
var _spin := 0.0
var _lit := -1.0


func setup(it: Dictionary, display_size: float) -> void:
	item = it
	is_food = it.get("category", "") == "food"
	sprite = Sprite2D.new()
	add_child(sprite)
	var tex: Texture2D = it["_tex"]
	sprite.texture = tex
	var big := maxf(tex.get_width(), tex.get_height())
	sprite.scale = Vector2.ONE * (display_size / maxf(big, 1.0))
	radius = display_size * 0.5
	var shine: String = it.get("shine", "")
	if shine != "":
		Shiny.apply(sprite, it["_img"], shine, it.get("_shine"), -Vector2(tex.get_size()) / 2.0)
	_physics_from_words(it.get("words", []))


func _physics_from_words(words: Array) -> void:
	if is_food:
		_gravity = 1800.0
		_bounce = 0.1
		_friction = 1600.0
		return
	if words.has("bouncy"):
		_bounce = 0.68
		_friction = 300.0
	if words.has("floaty"):
		_glide = true
		_gravity = 420.0
	if words.has("rolly"):
		_roll = true
		_friction = minf(_friction, 220.0)
	if words.has("heavy"):
		_gravity = 2400.0
		_bounce = 0.05
		_friction = 1800.0
	if words.has("soft"):
		_bounce = minf(_bounce, 0.12)
	if words.has("spinny"):
		_spin = 11.0
	elif not _roll:
		_spin = 3.0


func has_word(w: String) -> bool:
	return item.get("words", []).has(w)


## How pets play with it: fetch, tug, cuddle, chew, squeak, puzzle or push. "" for food.
func play() -> String:
	return "" if is_food else Words.toy_play(item.get("words", []))


## True when a global point is on the drawing. `snug` is for a toy in a mouth, where a touch a
## little off it should pet the pet instead.
func hit(point: Vector2, snug := false) -> bool:
	var reach := radius * scale.x * (0.6 if snug else 1.05) + (0.0 if snug else 10.0)
	return sprite.global_position.distance_to(point) < reach


## A little hop where it lies - tapped by a finger, or nosed and batted by a pet.
func hop(up: float, push := Vector2.ZERO) -> void:
	if held or carrier != null:
		return
	vz = up
	z = maxf(z, 1.0)
	vel += push


## Shoved along the ground to `at` by a pet leaning into it; a rolly thing rolls as it goes.
func slide_to(at: Vector2) -> void:
	var dx := at.x - position.x
	position = at.clamp(bounds.position, bounds.end)
	vel = Vector2.ZERO
	if _roll:
		sprite.rotation += dx / maxf(radius, 1.0)


## Heavy toys go a short way however hard they are flung.
func throw_scale() -> float:
	return 0.45 if has_word("heavy") else 1.0


func pick_up(by: Creature) -> void:
	carrier = by
	vel = Vector2.ZERO
	vz = 0.0


func drop_at(at: Vector2, height: float) -> void:
	carrier = null
	position = at
	z = height
	vel = Vector2.ZERO
	vz = 0.0


func landed() -> bool:
	return not held and carrier == null and z <= 0.0 and vz == 0.0 and vel.length() < 6.0


func _process(delta: float) -> void:
	var d := clampf(inverse_lerp(bounds.position.y, bounds.end.y, position.y), 0.0, 1.0)
	scale = Vector2.ONE * lerpf(0.82, 1.12, d)
	z_index = 1 if carrier != null else 0
	var n := Clock.night()
	if n != _lit:
		_lit = n
		sprite.modulate = Color.WHITE if has_word("glowy") else Clock.tint(n)
	if held or carrier != null:
		_place_sprite()
		return

	var gravity := _gravity
	if _glide and z > 2.0 and vel.length() > 160.0:
		gravity *= 0.3
		vel *= 1.0 - 0.3 * delta
	vz -= gravity * delta
	z += vz * delta
	position += vel * delta

	if z <= 0.0:
		z = 0.0
		if vz < -140.0:
			var hit := -vz
			vz = -vz * _bounce
			vel *= 0.85
			bounced.emit(hit)
		else:
			vz = 0.0
	if z <= 0.0 and vz == 0.0:
		vel = vel.move_toward(Vector2.ZERO, _friction * delta)

	if position.x < bounds.position.x or position.x > bounds.end.x:
		vel.x = -vel.x * 0.5
	if position.y < bounds.position.y or position.y > bounds.end.y:
		vel.y = -vel.y * 0.5
	position = position.clamp(bounds.position, bounds.end)

	if _roll:
		sprite.rotation += vel.x * delta / maxf(radius, 1.0)
	elif z > 1.0:
		sprite.rotation += _spin * delta * signf(vel.x + 0.01)
	_place_sprite()


func _place_sprite() -> void:
	if stretch_to != Vector2.INF:
		# Tug of war: the toy runs from its spot to the finger, stretched to fit.
		var a := global_position + Vector2(0, -z * scale.y)
		var span := stretch_to - a
		var tex_w := float(sprite.texture.get_width())
		var base_scale := (radius * 2.0) / maxf(tex_w, 1.0)
		sprite.global_position = a + span / 2.0
		sprite.global_rotation = span.angle()
		sprite.scale = Vector2(maxf(base_scale, span.length() / maxf(tex_w * scale.x, 1.0)), base_scale * 0.8)
	else:
		sprite.position = Vector2(0, -z / scale.y - radius * 0.9)
	queue_redraw()


func end_stretch() -> void:
	stretch_to = Vector2.INF
	var tex_w := float(sprite.texture.get_width())
	var base_scale := (radius * 2.0) / maxf(tex_w, 1.0)
	sprite.scale = Vector2(base_scale, base_scale)
	sprite.rotation = 0.0


func _draw() -> void:
	if has_word("glowy") and _lit > 0.01 and stretch_to == Vector2.INF:
		Crayon.glow(self, sprite.position, radius * 1.7, _lit, 5)
	if held or carrier != null:
		return
	var shrink := clampf(1.0 - z / 500.0, 0.3, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, radius * 0.75 * shrink, Color(0.32, 0.27, 0.5, 0.16))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
