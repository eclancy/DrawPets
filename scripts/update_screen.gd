class_name UpdateScreen
extends Control
## The first thing a downloaded Windows or Linux copy shows: checks ecec.dev for a newer version and, if
## there is one, installs it and restarts - no questions. The same design as DrawFight's, Wizard
## Wars' and Wizard Survivors' UpdateScreen (C# there, GDScript here); how a release is laid out
## is in .ai/releasing.md.
##
## ecec.dev/drawpets/version.json redirects to the newest GitHub Release's version.json, which
## names a small patch (DrawPets.pck - every script, picture and sound) and the full zip (needed
## only when the Godot engine itself changed). The running game cannot overwrite its own files on
## Windows, so the new ones are unpacked to user://update/ and a little script waits for the game
## to close, copies them over, and starts it again.
##
## Anything that goes wrong, from no internet onwards, just goes on into the game. An update is
## never worth not being able to play.
##
## Linux works the same, from version.json's own "linux" pair, with a shell script instead of a
## .cmd - and the script unpacks the full download itself (`tar -xzf`): it is a tarball, so the
## game binary keeps its permission to run, and GDScript cannot read one.
##
## On Android a game cannot replace itself, so there it only finds out (check_quietly), in the
## background, and the home screen tells a grown-up where to get the new one.
##
## The update check sends nothing about the player: a plain request for version.json.

const VERSION_URL := "https://ecec.dev/drawpets/version.json"
## Points a build at a test server instead - see .ai/releasing.md.
const URL_OVERRIDE := "DRAWPETS_UPDATE_URL"
const PCK := "DrawPets.pck"
const CHECK_TIMEOUT := 5.0
const DOWNLOAD_TIMEOUT := 900.0
const DOWNLOAD_PAGE := "ecec.dev/drawpets/download"

## Called when there is nothing to install (or it failed): carry on into the game.
var on_done: Callable

## Once per launch.
static var _checked := false
## A newer version than this copy, once the quiet check (Android) has found one.
static var newer := ""

var _http: HTTPRequest
var _state := "checking"     # checking, downloading, installing, done
var _new_version := ""
var _work := ""
var _title: Label
var _detail: Label
var _bar: ProgressBar
var _frames := 0


static func current_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))


static func engine_version() -> String:
	var v := Engine.get_version_info()
	return "%d.%d.%d" % [v["major"], v["minor"], v["patch"]]


## Only an exported Windows or Linux build updates itself, and only once per launch. Running from
## the editor or from `godot --path .` never does, and `--no-update` turns it off for testing a build.
static func should_check() -> bool:
	if _checked or not OS.has_feature("template") or not (OS.get_name() == "Windows" or _linux()):
		return false
	return not ("--no-update" in OS.get_cmdline_user_args() or "--no-update" in OS.get_cmdline_args())


## "0.10.0" is newer than "0.9.2": compared number by number, not as text.
static func is_newer(candidate: String, current: String) -> bool:
	var a := candidate.split(".")
	var b := current.split(".")
	for i in maxi(a.size(), b.size()):
		var x := int(a[i]) if i < a.size() and a[i].is_valid_int() else 0
		var y := int(b[i]) if i < b.size() and b[i].is_valid_int() else 0
		if x != y:
			return x > y
	return false


static func _linux() -> bool:
	return OS.get_name() == "Linux"


static func _url() -> String:
	var url := OS.get_environment(URL_OVERRIDE)
	return url if url != "" else VERSION_URL


static func _headers() -> PackedStringArray:
	return PackedStringArray(["User-Agent: DrawPets/%s" % current_version()])


## The newest release's version.json, checked: {} unless it names a version.
static func _read_release(result: int, code: int, body: PackedByteArray) -> Dictionary:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return {}
	# Not JSON.parse_string: that logs an engine error for a page that isn't JSON (a site that
	# answers with its home page), and this is not an error - it just means no update.
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return {}
	var info: Variant = json.data
	if typeof(info) != TYPE_DICTIONARY or str(info.get("version", "")) == "":
		return {}
	return info


# --- Android: just find out ------------------------------------------------------------------

## In the background, once per launch, never in the way: if there is a newer version, `newer`
## says which, and HomeScreen tells a grown-up where to get it.
static func check_quietly(parent: Node) -> void:
	if _checked or not OS.has_feature("template") or OS.get_name() != "Android":
		return
	_checked = true
	var http := HTTPRequest.new()
	http.timeout = CHECK_TIMEOUT
	parent.add_child(http)
	http.request_completed.connect(_on_quiet_check.bind(http))
	if http.request(_url(), _headers()) != OK:
		http.queue_free()


static func _on_quiet_check(result: int, code: int, _headers_in: PackedStringArray, body: PackedByteArray,
		http: HTTPRequest) -> void:
	http.queue_free()
	var info := _read_release(result, code, body)
	if not info.is_empty() and is_newer(str(info["version"]), current_version()):
		newer = str(info["version"])
		print("UpdateScreen: %s is out (this is %s)" % [newer, current_version()])


# --- Windows: install it ---------------------------------------------------------------------

func _ready() -> void:
	_checked = true
	add_child(UI.paper_background())
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 18)
	add_child(UI.full_rect(col))
	_title = UI.title("", 44)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_title)
	_detail = UI.label("", 26)
	_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail.add_theme_color_override("font_color", UI.INK_SOFT)
	col.add_child(_detail)
	_bar = ProgressBar.new()
	_bar.max_value = 1.0
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(460, 22)
	_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_bar.visible = false
	col.add_child(_bar)

	_http = HTTPRequest.new()
	_http.timeout = CHECK_TIMEOUT
	_http.use_threads = true
	add_child(_http)
	_http.request_completed.connect(_on_version)
	if _http.request(_url(), _headers()) != OK:
		_finish()


func _process(_delta: float) -> void:
	_frames += 1
	match _state:
		"checking":
			# Most checks finish before anyone could read this; it only shows when the internet is
			# slow, and then it says why the game has not started.
			_title.text = "Checking for updates..." if _frames > 45 else ""
		"downloading":
			var total := _http.get_body_size()
			var done := float(_http.get_downloaded_bytes()) / total if total > 0 else 0.0
			_title.text = "Updating DrawPets"
			_detail.text = "Getting version %s...  %d%%" % [_new_version, roundi(done * 100.0)]
			_bar.visible = true
			_bar.value = done
		"installing":
			_title.text = "Updating DrawPets"
			_detail.text = "Nearly done - DrawPets will start again by itself."
			_bar.value = 1.0


func _on_version(result: int, code: int, _headers_in: PackedStringArray, body: PackedByteArray) -> void:
	var info := _read_release(result, code, body)
	if info.is_empty():
		print("UpdateScreen: no update (could not read the version)")
		_finish()
		return
	var latest := str(info["version"])
	if not is_newer(latest, current_version()):
		print("UpdateScreen: %s is up to date" % current_version())
		_finish()
		return
	var install_dir := OS.get_executable_path().get_base_dir()
	if not _can_write(install_dir):
		print("UpdateScreen: %s is out, but %s is not writable" % [latest, install_dir])
		_finish()
		return
	# Linux has its own pair; a release from before there was a Linux build has none.
	var files: Dictionary = info
	if _linux():
		if typeof(info.get("linux")) != TYPE_DICTIONARY:
			print("UpdateScreen: %s has no Linux build" % latest)
			_finish()
			return
		files = info["linux"]
	# The patch only works on the engine it was built with; anything else takes the full download.
	var url := str(files.get("full", ""))
	if str(info.get("engine", "")) == engine_version() and str(files.get("patch", "")) != "":
		url = str(files["patch"])
	if url == "":
		_finish()
		return
	_new_version = latest
	_download.call_deferred(url)


func _download(url: String) -> void:
	_work = ProjectSettings.globalize_path("user://update")
	_remove_dir(_work)
	DirAccess.make_dir_recursive_absolute(_work)
	_state = "downloading"
	_http.request_completed.disconnect(_on_version)
	_http.request_completed.connect(_on_downloaded)
	# The five seconds were for the check, not for a full zip on a slow connection.
	_http.timeout = DOWNLOAD_TIMEOUT
	_http.download_file = _work + ("/update.tar.gz" if url.ends_with(".tar.gz") else "/update.zip")
	if _http.request(url, _headers()) != OK:
		_finish()


func _on_downloaded(result: int, code: int, _headers_in: PackedStringArray, _body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		print("UpdateScreen: the download failed (%d, HTTP %d)" % [result, code])
		_finish()
		return
	_state = "installing"
	_install.call_deferred()


func _install() -> void:
	if _linux():
		_install_linux()
		return
	var from := _unpack(_work + "/update.zip", _work + "/files")
	if from == "":
		print("UpdateScreen: the update has no %s" % PCK)
		_finish()
		return
	var script := _work + "/apply.cmd"
	var f := FileAccess.open(script, FileAccess.WRITE)
	if f == null:
		_finish()
		return
	f.store_string(_apply_script(from, OS.get_executable_path().get_base_dir(), OS.get_executable_path(),
		OS.get_process_id()))
	f.close()
	print("UpdateScreen: %s -> %s ready, restarting" % [current_version(), _new_version])
	# The script waits for this process to end, so it has to be started first.
	OS.create_process("cmd.exe", PackedStringArray(["/c", _win(script)]))
	get_tree().quit()


## Linux: the patch is a zip, unpacked here as on Windows; the full download is a tarball, which
## apply.sh unpacks. Either way apply.sh copies the new files over, once the game has closed.
func _install_linux() -> void:
	var tarball := _work + "/update.tar.gz"
	var from := _work + "/files"
	if FileAccess.file_exists(tarball):
		DirAccess.make_dir_recursive_absolute(from)
	else:
		from = _unpack(_work + "/update.zip", from)
		tarball = ""
		if from == "":
			print("UpdateScreen: the update has no %s" % PCK)
			_finish()
			return
	var script := _work + "/apply.sh"
	var f := FileAccess.open(script, FileAccess.WRITE)
	if f == null:
		_finish()
		return
	f.store_string(_apply_script_linux(tarball, from, OS.get_executable_path().get_base_dir(),
		OS.get_executable_path(), OS.get_process_id()))
	f.close()
	print("UpdateScreen: %s -> %s ready, restarting" % [current_version(), _new_version])
	OS.create_process("/bin/sh", PackedStringArray([script]))
	get_tree().quit()


## Unzips into `to`; returns the folder holding DrawPets.pck (the full zip keeps everything in a
## DrawPets/ folder so it unzips tidily for a person; the patch does not), or "" if it has none.
static func _unpack(zip_path: String, to: String) -> String:
	var z := ZIPReader.new()
	if z.open(zip_path) != OK:
		return ""
	for name in z.get_files():
		if name.ends_with("/"):
			continue
		if name.begins_with("/") or ":" in name or ".." in name.split("/"):
			z.close()
			return ""  # not a zip this game made
		var out := to + "/" + name
		DirAccess.make_dir_recursive_absolute(out.get_base_dir())
		var f := FileAccess.open(out, FileAccess.WRITE)
		if f == null:
			z.close()
			return ""
		f.store_buffer(z.read_file(name))
		f.close()
	z.close()
	DirAccess.remove_absolute(zip_path)
	if FileAccess.file_exists(to + "/" + PCK):
		return to
	for sub in DirAccess.get_directories_at(to):
		if FileAccess.file_exists(to + "/" + sub + "/" + PCK):
			return to + "/" + sub
	return ""


static func _can_write(dir: String) -> bool:
	var probe := dir + "/.update-probe"
	var f := FileAccess.open(probe, FileAccess.WRITE)
	if f == null:
		return false
	f.close()
	DirAccess.remove_absolute(probe)
	return true


static func _remove_dir(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for sub in DirAccess.get_directories_at(path):
		_remove_dir(path + "/" + sub)
	for file in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path + "/" + file)
	DirAccess.remove_absolute(path)


static func _win(path: String) -> String:
	return path.replace("/", "\\")


## Waits for the game to close, copies the new files over the old, and starts it again. `ping` is
## the sleep because `timeout` refuses to run without a console to read from. robocopy retries a
## locked file a few times, which covers the moment Windows takes to let go of a closed game.
static func _apply_script(from: String, to: String, exe: String, pid: int) -> String:
	return ("@echo off\r\n" +
		":wait\r\n" +
		"tasklist /FI \"PID eq %d\" 2>nul | find \"%d\" >nul\r\n" % [pid, pid] +
		"if not errorlevel 1 (\r\n" +
		"  ping -n 2 127.0.0.1 >nul\r\n" +
		"  goto wait\r\n" +
		")\r\n" +
		"robocopy \"%s\" \"%s\" /E /R:10 /W:1 /NFL /NDL /NJH /NJS /NP >nul\r\n" % [_win(from), _win(to)] +
		"start \"\" \"%s\"\r\n" % _win(exe) +
		"rmdir /s /q \"%s\"\r\n" % _win(from))


## The same on Linux: wait for the game to close, unpack the tarball if that is what came (into
## `from`, then use the folder in it that holds DrawPets.pck), copy the new files over, keep the
## game runnable, and start it again.
static func _apply_script_linux(tarball: String, from: String, to: String, exe: String, pid: int) -> String:
	var s := "#!/bin/sh\n"
	s += "while kill -0 %d 2>/dev/null; do sleep 0.5; done\n" % pid
	# Whatever happens, the game starts again: a download that will not unpack is just skipped.
	if tarball != "":
		s += "tar -xzf %s -C %s 2>/dev/null\n" % [_quoted(tarball), _quoted(from)]
	s += "PCK=$(find %s -name %s | head -n 1)\n" % [_quoted(from), PCK]
	s += "[ -n \"$PCK\" ] && cp -Rf \"$(dirname \"$PCK\")/.\" %s\n" % _quoted(to + "/")
	s += "chmod +x %s\n" % _quoted(exe)
	s += "rm -rf %s\n" % _quoted(from)
	if tarball != "":
		s += "rm -f %s\n" % _quoted(tarball)
	s += "cd %s && nohup %s >/dev/null 2>&1 &\n" % [_quoted(to), _quoted(exe)]
	return s


## A path in single quotes for sh, with any quote in it kept.
static func _quoted(path: String) -> String:
	return "'" + path.replace("'", "'\\''") + "'"


func _finish() -> void:
	if _state == "done":
		return
	_state = "done"
	if on_done.is_valid():
		on_done.call()
