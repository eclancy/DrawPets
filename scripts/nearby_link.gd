class_name NearbyLink
extends SwapLink
## Swapping over Google's Nearby Connections - no Wi-Fi network, no internet: the phones find each
## other by Bluetooth and Nearby makes its own fast link for the pets. Driven through the
## DrawPetsNearby Android plugin (addons/drawpets_nearby, android_plugin/).
##
## Both phones advertise and look at once. To keep them from calling each other at the same
## moment, the one with the lower session number makes the call. Nearby then gives both the same
## authentication digits, shown as pictures for the kids to match.

const SERVICE := "dev.ecec.drawpets.swap"
const SINGLETON := "DrawPetsNearby"

var _n: Object
var _session := 0
var _endpoint := ""


## True on a phone with the plugin and Google Play services.
static func usable() -> bool:
	if not Engine.has_singleton(SINGLETON):
		return false
	return bool(Engine.get_singleton(SINGLETON).is_available())


static func plugin() -> Object:
	return Engine.get_singleton(SINGLETON) if Engine.has_singleton(SINGLETON) else null


func begin(name: String) -> void:
	my_name = name
	_n = plugin()
	if _n == null:
		failed.emit("unavailable")
		return
	_session = randi_range(100000, 999999)
	_n.connect("endpoint_found", _on_found)
	_n.connect("connection_initiated", _on_initiated)
	_n.connect("connected", _on_connected)
	_n.connect("connection_failed", _on_connection_failed)
	_n.connect("disconnected", _on_disconnected)
	_n.connect("payload_received", _on_payload)
	_n.connect("transfer_progress", _on_progress)
	_n.connect("error", _on_error)
	_n.start(SERVICE, _endpoint_name())


func _endpoint_name() -> String:
	return "%s|%d" % [my_name, _session]


func _on_found(endpoint_id: String, name: String) -> void:
	if _endpoint != "":
		return
	var bits := name.split("|")
	var theirs := int(bits[bits.size() - 1]) if bits.size() >= 2 else 0
	if _session < theirs:
		_endpoint = endpoint_id
		_n.request_connection(endpoint_id, _endpoint_name())


func _on_initiated(endpoint_id: String, name: String, digits: String, _incoming: bool) -> void:
	if _endpoint != "" and _endpoint != endpoint_id:
		_n.reject_connection(endpoint_id)
		return
	_endpoint = endpoint_id
	friend_name = name.split("|")[0]
	check.emit(friend_name, digits)


func confirm(yes: bool) -> void:
	if _n == null or _endpoint == "":
		return
	if yes:
		_n.accept_connection(_endpoint)
	else:
		_n.reject_connection(_endpoint)
		_endpoint = ""


func _on_connected(endpoint_id: String) -> void:
	if endpoint_id == _endpoint:
		linked.emit()


func send(data: PackedByteArray) -> void:
	if _n != null and _endpoint != "":
		_n.send_bytes(_endpoint, data)


func _on_payload(endpoint_id: String, data: PackedByteArray) -> void:
	if endpoint_id == _endpoint:
		received.emit(data)


func _on_progress(endpoint_id: String, done: int, total: int, _outgoing: bool) -> void:
	if endpoint_id == _endpoint:
		progress.emit(done, total)


func _on_connection_failed(endpoint_id: String, _reason: String) -> void:
	if endpoint_id == _endpoint:
		_endpoint = ""
		failed.emit("no")


func _on_disconnected(endpoint_id: String) -> void:
	if endpoint_id == _endpoint:
		failed.emit("lost")


func _on_error(message: String) -> void:
	push_warning("Nearby: " + message)
	if "MISSING_PERMISSION" in message:
		failed.emit("permission")
	elif "LOCATION_MUST_BE_ON" in message:
		failed.emit("location")
	else:
		failed.emit("unavailable")


func finish() -> void:
	if _n == null:
		return
	for s in ["endpoint_found", "connection_initiated", "connected", "connection_failed", "disconnected",
			"payload_received", "transfer_progress", "error"]:
		for c in _n.get_signal_connection_list(s):
			if c["callable"].get_object() == self:
				_n.disconnect(s, c["callable"])
	_n.stop()
	_n = null


func _exit_tree() -> void:
	finish()
