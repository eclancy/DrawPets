class_name Furniture
extends Node2D
## Something standing in a home: a bed, a tree, a trampoline - from the starter kit, the shop,
## or drawn by a kid. Its origin is where it stands on the ground. What pets DO with it comes
## from its words (Words.FURNITURE): they nap on "cozy" things, bounce on "bouncy" ones, climb
## "climbable" ones. See PlaceScreen._play_with_furniture.

var item: Dictionary
## Its entry in the home's saved list: {item, pos, scale, flip}.
var entry: Dictionary
var sprite: Sprite2D
var height_px := 120.0
var bounds := Rect2(40, 460, 1200, 240)
var selected := false
var _lit := -1.0


func setup(it: Dictionary, e: Dictionary) -> void:
	item = it
	entry = e
	sprite = Sprite2D.new()
	add_child(sprite)
	Items.dress_sprite(sprite, it)
	position = PetBuilder.v2(e["pos"])
	apply_size()


func apply_size() -> void:
	var img_h := float(item["_img"].get_height())
	var wanted := float(item.get("height", 150)) * float(entry.get("scale", 1.0))
	var k := wanted / maxf(img_h, 1.0)
	sprite.scale = Vector2(-k if entry.get("flip", false) else k, k)
	height_px = wanted
	queue_redraw()


func has_word(w: String) -> bool:
	return item.get("words", []).has(w)


func words() -> Array:
	return item.get("words", [])


## How high a pet sits when it climbs on, perches on, or lies on it.
func perch_height() -> float:
	if has_word("cozy") and not has_word("climbable"):
		return height_px * 0.45
	if has_word("bouncy"):
		return height_px * 0.6
	return height_px * 0.62


## Where a pet naps on it: on top of a bed or a cushion; on the doorstep of anything it would
## hide in (a house, a tent), so it can still be seen.
func nap_spot() -> Vector2:
	if has_word("hidey"):
		var w := absf(sprite.scale.x) * float(item["_img"].get_width())
		return position + Vector2(randf_range(-0.18, 0.18) * w, 16)
	return position + Vector2(randf_range(-0.22, 0.22) * height_px, 3)


func nap_height() -> float:
	return 0.0 if has_word("hidey") else perch_height()


func hit(point: Vector2) -> bool:
	var g := sprite.get_global_transform()
	var img: Image = item["_img"]
	var local := g.affine_inverse() * point - sprite.offset
	var x := int(local.x)
	var y := int(local.y)
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return false
	return img.get_pixel(x, y).a > 0.2


func _process(_delta: float) -> void:
	var d := clampf(inverse_lerp(bounds.position.y, bounds.end.y, position.y), 0.0, 1.0)
	scale = Vector2.ONE * lerpf(0.82, 1.12, d)
	# The night tint, as the place has it - except on something glowy, which lights up instead.
	var n := Clock.night()
	if n != _lit:
		_lit = n
		sprite.modulate = Color.WHITE if has_word("glowy") else Clock.tint(n)
		queue_redraw()


func _draw() -> void:
	var w := absf(sprite.scale.x) * float(item["_img"].get_width()) * 0.45
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, w, Color(0.32, 0.27, 0.5, 0.14))
	if has_word("glowy") and _lit > 0.01:
		Crayon.glow(self, Vector2.ZERO, w * 2.2, _lit, 11)  # a pool of light on the ground
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if has_word("glowy"):
		Crayon.glow(self, Vector2(0, -height_px * 0.58), maxf(height_px * 0.7, w * 1.3), _lit, 3)
	if selected:
		var h := height_px
		draw_rect(Rect2(-w, -h - 6, w * 2.0, h + 12), UI.ACCENT, false, 4.0)
