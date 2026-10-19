extends SceneTree
## Bakes the game's own drawings into PNGs under res://art/<group>/, with pivots.json beside
## them, and a contact sheet of the group into .shots/art_<group>.png for looking at.
##
##   "$GODOT_BIN" --path . -s tools/bake_art.gd -- --group=things [--only=kit_bed,kit_ball]
##   then: "$GODOT_BIN" --headless --path . --import
##
## Each group is one script (scripts/art_<group>.gd) with a static assets() table and a static
## draw(id, canvas). The baker only loads the groups it is asked for, so one group being
## mid-edit never stops another from baking. It needs a window (not --headless): it renders.
##
## Each drawing is made on a 512 px sheet and cropped to its ink. Pivots in pivots.json are in
## the cropped image's pixels:
##   "center" - the middle of the ink        (toys, food, icons, glasses)
##   "bottom" - the middle of the ink's base (furniture: where it stands on the ground)
##   "top"    - the middle of the ink's top  (things that hang: scarves, capes)
##   Vector2  - a point on the sheet         (creature parts: the red dot they grow from)

const GROUPS := ["things", "wear", "ui", "homes", "rivals", "adopt_a", "adopt_b", "adopt_c", "adopt_d", "brand"]
const SHEET := 512

var _painter: Painter
var _viewport: SubViewport


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := {}
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var kv := arg.substr(2).split("=", true, 1)
			args[kv[0]] = kv[1] if kv.size() > 1 else "true"
	var groups: Array = GROUPS if not args.has("group") else Array(args["group"].split(","))
	var only: Array = [] if not args.has("only") else Array(args["only"].split(","))

	_viewport = SubViewport.new()
	_viewport.size = Vector2i(SHEET, SHEET)
	_viewport.transparent_bg = true
	_viewport.disable_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_viewport)
	_painter = Painter.new()
	_viewport.add_child(_painter)

	for group in groups:
		await _bake_group(group, only)
	quit()


func _bake_group(group: String, only: Array) -> void:
	var path := "res://scripts/art_%s.gd" % group
	if not FileAccess.file_exists(path):
		return
	var art: GDScript = load(path)
	if art == null:
		push_error("Could not load %s - fix its parse errors and bake again." % path)
		return
	var assets: Dictionary = art.assets()
	var dir := "res://art/" + group
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))

	var pivots := {}
	var old := FileAccess.get_file_as_string(dir + "/pivots.json")
	if old != "":
		var parsed = JSON.parse_string(old)
		if typeof(parsed) == TYPE_DICTIONARY:
			pivots = parsed

	var baked := []
	for id in assets:
		if not only.is_empty() and not only.has(id):
			continue
		_painter.art = art
		_painter.id = id
		_painter.queue_redraw()
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var img := _viewport.get_texture().get_image()
		var used := img.get_used_rect()
		if used.size.x < 2 or used.size.y < 2:
			push_warning("%s drew nothing" % id)
			continue
		var crop := img.get_region(used)
		Crayon.unpremultiply(crop)
		crop.save_png(ProjectSettings.globalize_path("%s/%s.png" % [dir, id]))
		var pivot := _pivot(assets[id].get("pivot", "center"), used)
		pivots[id] = [snappedf(pivot.x, 0.1), snappedf(pivot.y, 0.1)]
		baked.append([id, crop, pivot])
		print("baked %s/%s  %dx%d" % [group, id, used.size.x, used.size.y])

	var f := FileAccess.open(dir + "/pivots.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(pivots, "\t", true))
	f.close()
	await _contact_sheet(group, baked)
	if art.get_script_constant_map().has("ROSTER"):
		await _assembled(group, art, pivots)


## Puts every creature in a roster together the way the game will (Roster.assemble - the same
## PetBuilder.add_parts a kid's pet goes through) and draws them side by side in their rest pose
## into .shots/art_<group>_assembled.png. Proportions are judged here, not on the contact sheet.
func _assembled(group: String, art: GDScript, pivots: Dictionary) -> void:
	var roster: Dictionary = art.ROSTER
	var pets := []
	for id in roster:
		var pet := Roster.assemble(group, id, roster[id], pivots, true)
		if not pet.is_empty():
			pets.append([roster[id]["name"], pet])
	if pets.is_empty():
		return
	var vp := SubViewport.new()
	vp.size = Vector2i(1600, 400 * ceili(pets.size() / 4.0))
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var bg := Sheet.new()
	bg.size_px = Vector2(vp.size)
	vp.add_child(bg)
	for i in pets.size():
		var pet: Dictionary = pets[i][1]
		var box := PetBuilder.rest_bounds(pet)
		var holder := Node2D.new()
		var k := minf(340.0 / maxf(box.size.x, 1.0), 300.0 / maxf(box.size.y, 1.0))
		holder.scale = Vector2(k, k)
		holder.position = Vector2(200 + (i % 4) * 400, 190 + (i / 4) * 400) - box.get_center() * k
		vp.add_child(holder)
		for p in PetBuilder.draw_order(pet):
			var s := Sprite2D.new()
			s.texture = PetStore.texture(pet, p["image"])
			s.centered = false
			s.offset = -PetBuilder.v2(p["pivot"])
			var sc := float(p["draw_scale"]) * float(p["scale"])
			s.position = PetBuilder.v2(p["pos"])
			s.rotation = float(p["rot"])
			s.scale = Vector2(-sc if p["flip"] else sc, sc)
			if int(p.get("side", 0)) == 1:
				s.modulate = Color(0.74, 0.74, 0.8)
			holder.add_child(s)
		var label := Label.new()
		label.text = pets[i][0]
		label.position = Vector2(20 + (i % 4) * 400, 360 + (i / 4) * 400)
		label.add_theme_color_override("font_color", Color("#3b3566"))
		vp.add_child(label)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://.shots/art_%s_assembled.png" % group))
	print("assembled: .shots/art_%s_assembled.png" % group)
	vp.queue_free()


static func _pivot(spec, used: Rect2i) -> Vector2:
	var r := Rect2(used)
	if spec is Vector2:
		return spec - r.position
	match spec:
		"bottom":
			return Vector2(r.size.x / 2.0, r.size.y)
		"top":
			return Vector2(r.size.x / 2.0, 0.0)
	return r.size / 2.0


## Every baked drawing in a grid on paper, with its id and a red dot on its pivot.
func _contact_sheet(group: String, baked: Array) -> void:
	if baked.is_empty():
		return
	const CELL := 220
	const COLS := 8
	var rows := ceili(baked.size() / float(COLS))
	var vp := SubViewport.new()
	vp.size = Vector2i(CELL * COLS, CELL * rows)
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var sheet := Sheet.new()
	sheet.cell = CELL
	sheet.cols = COLS
	sheet.size_px = Vector2(vp.size)
	for entry in baked:
		sheet.entries.append([entry[0], ImageTexture.create_from_image(entry[1]), entry[2]])
	vp.add_child(sheet)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var out := ProjectSettings.globalize_path("res://.shots")
	DirAccess.make_dir_recursive_absolute(out)
	vp.get_texture().get_image().save_png(out + "/art_%s.png" % group)
	print("contact sheet: .shots/art_%s.png" % group)
	vp.queue_free()


class Painter extends Node2D:
	var art: GDScript
	var id := ""

	func _draw() -> void:
		if art != null and id != "":
			art.draw(id, self)


class Sheet extends Node2D:
	var entries := []
	var cell := 220
	var cols := 8
	var size_px := Vector2.ZERO

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size_px), Color("#f6f1e4"))
		var font := ThemeDB.fallback_font
		for i in entries.size():
			var origin := Vector2((i % cols) * cell, (i / cols) * cell)
			var tex: Texture2D = entries[i][1]
			var box := Vector2(cell - 20, cell - 44)
			var k := minf(1.0, minf(box.x / tex.get_width(), box.y / tex.get_height()))
			var size := Vector2(tex.get_size()) * k
			var at := origin + Vector2((cell - size.x) / 2.0, 8 + (box.y - size.y) / 2.0)
			draw_rect(Rect2(origin + Vector2(4, 4), Vector2(cell - 8, cell - 8)), Color(1, 1, 1, 0.6))
			draw_texture_rect(tex, Rect2(at, size), false)
			var pivot: Vector2 = entries[i][2]
			draw_circle(at + pivot * k, 4.0, Color("#e8344e"))
			draw_string(font, origin + Vector2(8, cell - 12), entries[i][0], HORIZONTAL_ALIGNMENT_LEFT,
				cell - 16, 14, Color("#3b3566"))
