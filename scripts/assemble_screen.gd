class_name AssembleScreen
extends Control
## "Put it together!" - every part is already roughly where it goes (PetBuilder lays them out
## from where the kid drew them against the ghost), and here they drag, turn, resize, flip,
## copy and remove parts until it looks right. Drop a part on the head and it rides on the
## head from then on.
##
## Shows the rest pose flat, back to front, exactly as the creature will be built.

var pet: Dictionary
var on_done := Callable()
## Making a pet: back to the last thing drawn, or stop (save it for later / throw it away).
var on_back := Callable()
var on_quit := Callable()

var _area: Control
var _stage: Node2D
var _overlay: Overlay
var _sprites := {}
var _selected := ""
var _dragging := false
var _last := Vector2.ZERO
var _hint: Label
var _tools: Array[Button] = []


func _ready() -> void:
	add_child(UI.paper_background())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	add_child(UI.full_rect(UI.margin(row, 20)))

	_area = Panel.new()
	_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_area.size_flags_stretch_ratio = 1.6
	_area.clip_contents = true
	_area.gui_input.connect(_on_area_input)
	_area.resized.connect(_fit)
	row.add_child(_area)
	_stage = Node2D.new()
	_area.add_child(_stage)
	_overlay = Overlay.new()
	_overlay.screen = self
	_area.add_child(_overlay)

	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 12)
	row.add_child(side)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	if on_back.is_valid():
		top.add_child(UI.icon_button("tool_back", "Back", func(): on_back.call(), 28, Vector2(78, 64)))
	var title := UI.title("Put it together!", 36)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	if on_quit.is_valid():
		top.add_child(UI.icon_button("icon_home", "Stop", func(): on_quit.call(), 28, Vector2(78, 64)))
	side.add_child(top)
	_hint = UI.label("Drag parts to move them. Tap a part to turn it, resize it, or flip it.", 22, true)
	side.add_child(_hint)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	var actions := [
		["edit_turn_left", "Turn", "turn_left"], ["edit_turn_right", "Turn", "turn_right"],
		["edit_smaller", "Smaller", "smaller"], ["edit_bigger", "Bigger", "bigger"],
		["edit_flip", "Flip", "flip"], ["edit_layer", "Front / back", "layer"],
		["edit_copy", "Copy", "copy"], ["edit_remove", "Remove", "remove"],
	]
	for entry in actions:
		var b := UI.icon_button(entry[0], entry[1], _edit.bind(entry[2]), 44, Vector2(0, 84))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_tools.append(b)
		grid.add_child(b)
	side.add_child(grid)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)
	side.add_child(UI.big_icon_button("tool_done", "It's alive!", press_done))

	_rebuild()
	_refresh_tools()


## Scales and centres the creature to fill the area. Only on layout, never mid-drag, or the
## creature would slide out from under the finger.
func _fit() -> void:
	var box := PetBuilder.rest_bounds(pet)
	if box.size.x < 1.0 or box.size.y < 1.0:
		return
	var k := minf(_area.size.x * 0.75 / box.size.x, _area.size.y * 0.75 / box.size.y)
	_stage.scale = Vector2.ONE * k
	_stage.position = _area.size / 2.0 - box.get_center() * k
	_overlay.queue_redraw()


func _rebuild() -> void:
	for c in _stage.get_children():
		c.queue_free()
	_sprites.clear()
	for p in PetBuilder.draw_order(pet):
		var s := Sprite2D.new()
		s.texture = PetStore.texture(pet, p["image"])
		s.centered = false
		s.offset = -PetBuilder.v2(p["pivot"])
		_place(s, p)
		if int(p.get("side", 0)) == 1:
			s.modulate = Color(0.74, 0.74, 0.8)
		_stage.add_child(s)
		_sprites[p["id"]] = s
	_overlay.queue_redraw()


func _place(s: Sprite2D, p: Dictionary) -> void:
	var k := float(p["draw_scale"]) * float(p["scale"])
	s.position = PetBuilder.v2(p["pos"])
	s.rotation = float(p["rot"])
	s.scale = Vector2(-k if p["flip"] else k, k)


func _to_body(local: Vector2) -> Vector2:
	return (local - _stage.position) / _stage.scale.x


func _on_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var at := _to_body(event.position)
			select(_part_at(at))
			_dragging = _selected != ""
			_last = at
		elif _dragging:
			_dragging = false
			PetBuilder.reattach(pet, _selected)
			_rebuild()
	elif event is InputEventMouseMotion and _dragging:
		var at := _to_body(event.position)
		PetBuilder.move_group(pet, _selected, at - _last)
		_last = at
		for p in PetBuilder.group(pet, _selected):
			_place(_sprites[p["id"]], p)
		_overlay.queue_redraw()


## The topmost part with ink under the point. The body is not draggable - everything else is
## stuck onto it - so tapping it just clears the selection.
func _part_at(at: Vector2) -> String:
	var order := PetBuilder.draw_order(pet)
	order.reverse()
	for p in order:
		if p["type"] != "body" and PetBuilder.ink_at(pet, p, at):
			return p["id"]
	return ""


func select(id: String) -> void:
	_selected = id
	if id == "":
		_hint.text = "Drag parts to move them. Tap a part to turn it, resize it, or flip it."
	else:
		var p := PetBuilder.find(pet, id)
		var on := " (on the head)" if PetBuilder.find(pet, p["parent"]).get("type", "") == "head" else ""
		_hint.text = "%s%s - drag it, or use the buttons." % [PartTypes.info(p["type"])["label"], on]
	_refresh_tools()
	_overlay.queue_redraw()


func _refresh_tools() -> void:
	for b in _tools:
		b.disabled = _selected == ""


func _edit(what: String) -> void:
	var id := _selected
	if id == "":
		return
	match what:
		"turn_left":
			PetBuilder.rotate_group(pet, id, -PI / 12.0)
		"turn_right":
			PetBuilder.rotate_group(pet, id, PI / 12.0)
		"smaller":
			PetBuilder.scale_group(pet, id, 1.0 / 1.12)
		"bigger":
			PetBuilder.scale_group(pet, id, 1.12)
		"flip":
			PetBuilder.flip_group(pet, id)
		"layer":
			var p := PetBuilder.find(pet, id)
			p["behind"] = not p["behind"]
		"copy":
			id = PetBuilder.copy_part(pet, id).get("id", id)
		"remove":
			PetBuilder.remove_part(pet, id)
			id = ""
	_rebuild()
	select(id)


func press_done() -> void:
	on_done.call()


## Rings the selected part and marks its joint.
class Overlay extends Node2D:
	var screen: AssembleScreen

	func _draw() -> void:
		var id := screen._selected
		if id == "" or not screen._sprites.has(id):
			return
		var p := PetBuilder.find(screen.pet, id)
		var img: Image = screen.pet["_img"][p["image"]]
		var x := screen._stage.transform * PetBuilder.sprite_xform(p)
		var s := Vector2(img.get_size())
		var ring := PackedVector2Array([x * Vector2.ZERO, x * Vector2(s.x, 0), x * s, x * Vector2(0, s.y),
			x * Vector2.ZERO])
		draw_polyline(ring, UI.ACCENT, 4.0, true)
		var joint := screen._stage.transform * PetBuilder.v2(p["pos"])
		draw_circle(joint, 9.0, Color("#e8344e"))
		draw_arc(joint, 14.0, 0.0, TAU, 24, Color.WHITE, 3.0, true)
