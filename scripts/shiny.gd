class_name Shiny
extends Node2D
## Makes a drawing special: a metallic (or rainbow, or glitter) tint, a band of light that
## sweeps across it every couple of seconds, and four-pointed sparkles that twinkle over it.
## Shiny things are the only art in the game that is not plain pencil or marker - that is
## what makes them worth saving up for (.ai/shop.md).
##
## Use Shiny.apply(target, image, mode): it sets the shine material on the target (a Sprite2D,
## TextureRect or anything drawing the image) and adds the sparkles as a child. With a mask,
## only the masked pixels shine - that is how the shiny marker makes one stroke shine.

const MODES := ["gold", "silver", "rainbow", "glitter"]

const SHADER := "
shader_type canvas_item;
uniform int mode = 0;
uniform bool use_mask = false;
uniform sampler2D shine_mask : filter_linear;
uniform float speed = 0.45;

vec3 hue(float h) {
	return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float m = use_mask ? texture(shine_mask, UV).a : 1.0;
	float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	vec3 metal;
	if (mode == 2) {
		metal = mix(c.rgb, hue(UV.x * 0.9 + UV.y * 0.6 + TIME * 0.12) * (0.6 + 0.55 * lum), 0.7);
	} else if (mode == 1) {
		metal = vec3(0.78, 0.84, 0.95) * (0.45 + 0.75 * lum) + vec3(0.1) * (1.0 - UV.y);
	} else if (mode == 3) {
		metal = mix(c.rgb, vec3(1.0, 0.86, 0.98) * (0.55 + 0.6 * lum), 0.45);
	} else {
		metal = vec3(1.0, 0.8, 0.28) * (0.42 + 0.85 * lum) + vec3(0.14, 0.1, 0.0) * (1.0 - UV.y);
	}
	vec3 col = mix(c.rgb, metal, 0.8 * m);
	float sweep = UV.x * 0.8 + UV.y * 0.6 - mod(TIME * speed, 2.6) + 0.5;
	float band = smoothstep(0.13, 0.0, abs(sweep)) + 0.5 * smoothstep(0.05, 0.0, abs(sweep - 0.22));
	col += band * 0.55 * m;
	if (mode == 3) {
		vec2 cell = floor(UV * 80.0);
		float g = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
		float twinkle = 0.5 + 0.5 * sin(TIME * 4.0 + g * 40.0);
		col += step(0.93, g) * twinkle * 0.7 * m;
	}
	COLOR = vec4(col, c.a);
}
"

static var _shader: Shader

var _spots := PackedVector2Array()
var _phase := PackedFloat32Array()
var _size := 10.0
var _time := 0.0


static func material(mode: String, mask: Texture2D = null) -> ShaderMaterial:
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER
	var mat := ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("mode", maxi(0, MODES.find(mode)))
	mat.set_shader_parameter("use_mask", mask != null)
	if mask != null:
		mat.set_shader_parameter("shine_mask", mask)
	return mat


## Makes `target` shiny. `image` is what it draws (for placing sparkles on its ink), drawn with
## its top-left at `origin` and `px` local units per image pixel. Returns the sparkles node.
static func apply(target: CanvasItem, image: Image, mode: String, mask: Image = null,
		origin := Vector2.ZERO, px := 1.0) -> Shiny:
	var mask_tex: Texture2D = ImageTexture.create_from_image(mask) if mask != null else null
	target.material = material(mode, mask_tex)
	var s := Shiny.new()
	s._scatter(mask if mask != null else image, origin, px)
	target.add_child(s)
	return s


## Picks sparkle spots on the drawing's ink (or on the masked strokes), hashed, never random.
func _scatter(image: Image, origin: Vector2, px: float) -> void:
	if image == null:
		return
	var w := image.get_width()
	var h := image.get_height()
	_size = maxf(w, h) * px * 0.07
	var seed := w * 31 + h * 17
	var tries := 0
	while _spots.size() < 7 and tries < 400:
		var x := int(absf(Crayon.noise(seed, tries)) * (w - 1))
		var y := int(absf(Crayon.noise(seed + 1, tries)) * (h - 1))
		tries += 1
		if image.get_pixel(x, y).a > 0.5:
			_spots.append(origin + Vector2(x, y) * px)
			_phase.append(absf(Crayon.noise(seed + 2, tries)) * TAU)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	for i in _spots.size():
		var t := sin(_time * 2.6 + _phase[i])
		if t <= 0.2:
			continue
		var s := _size * (t - 0.2) / 0.8
		if s < 1.5:
			continue
		var p := _spots[i]
		var c := Color(1, 1, 0.92, 0.95)
		var points := PackedVector2Array()
		for k in 8:
			var r := s if k % 2 == 0 else s * 0.22
			var a := k * PI / 4.0 + _time * 0.6
			points.append(p + Vector2(cos(a), sin(a)) * r)
		draw_colored_polygon(points, c)
		draw_circle(p, s * 0.18, Color.WHITE)
