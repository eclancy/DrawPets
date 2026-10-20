class_name MeetLink
extends SwapLink
## Swapping in a browser (the web version). A browser cannot listen for another phone the way
## LanLink does, so the two devices meet through ecec.dev's meeting point (the meet service in
## EricClancyEngineeringAndCrafts) - only to pass the few notes WebRTC needs to connect them - and
## the pets then go straight from one to the other over WebRTC, encrypted. .ai/sharing.md says
## what the meeting point may and may not do.
##
##   1. Each device shows a swap code: "DRAWPETS2|<room>", the room 128 random bits made here.
##      It waits in its own room as side "a".
##   2. The kid who scans the other's code leaves their own room and joins that one as side "b",
##      and says hello there.
##   3. "a" hears the hello and offers a WebRTC connection; "b" answers; both pass their network
##      candidates. No STUN or TURN server: only addresses on the room's own network, so it only
##      ever connects two devices on the same Wi-Fi (or one on the other's hotspot).
##   4. Over the direct link: HELLO with the family name - scanning was the check, so no pictures
##      - then the pets in pieces, then BYE.

const TAG := "DRAWPETS2"
const SITE := "https://ecec.dev"
## Data channel messages: [u8 kind][payload].
enum { HELLO = 1, START = 2, CHUNK = 3, END = 4, BYE = 5 }
const PIECE := 16000                    # every browser takes a message this big
const MAX_PACK := 16 * 1024 * 1024
const MAX_NOTE := 6000                  # one signalling note
const KEEP_BUFFERED := 512 * 1024       # don't queue more than this in the channel at once
const CONNECT_PATIENCE := 25.0
const ROOM_CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

## Where the meeting point is: "" means this page's own site on the web (and ecec.dev elsewhere).
## Tests point it at a local copy.
static var meet_url := ""

var _room := ""
var _side := "a"
var _key := ""
var _after := 0
var _state := "idle"         # waiting (showing the code), joining, connecting, open, done
var _connecting := 0.0
var _rtc: WebRTCPeerConnection
var _channel: WebRTCDataChannel
var _wait_http: HTTPRequest
var _send_http: HTTPRequest
var _outbox: Array[String] = []
var _wait_failures := 0
var _hello_sent := false
var _linked := false
var _out: Array[PackedByteArray] = []
var _out_total := 0
var _out_sent := 0
var _in := PackedByteArray()
var _in_total := -1
var _got_pack := false
var _printed := false


func _init() -> void:
	by_code = true


func begin(name: String) -> void:
	my_name = name
	_wait_http = HTTPRequest.new()
	_wait_http.timeout = 35.0
	add_child(_wait_http)
	_wait_http.request_completed.connect(_on_waited)
	_send_http = HTTPRequest.new()
	_send_http.timeout = 15.0
	add_child(_send_http)
	_send_http.request_completed.connect(_on_sent)
	_enter_room(_random(22), "a")
	_state = "waiting"


static func _base() -> String:
	if meet_url != "":
		return meet_url
	if OS.has_feature("web"):
		var origin: Variant = JavaScriptBridge.eval("window.location.origin", true)
		if typeof(origin) == TYPE_STRING and str(origin).begins_with("http"):
			return str(origin) + "/api/meet"
	return SITE + "/api/meet"


static func _random(n: int) -> String:
	var bytes := Crypto.new().generate_random_bytes(n)
	var out := ""
	for b in bytes:
		out += ROOM_CHARS[b % 64]
	return out


func _enter_room(room: String, side: String) -> void:
	_room = room
	_side = side
	_key = _random(24)
	_after = 0
	_wait_failures = 0
	_outbox.clear()
	_wait_http.cancel_request()
	_wait_more.call_deferred()


# --- The code ----------------------------------------------------------------------------------

## The same for as long as this device is the one showing it (side "a") - even once a friend has
## scanned it and the two are connecting - so the page does not flicker to "no code".
func code() -> String:
	if _side != "a" or _room == "":
		return ""
	var text := "%s|%s" % [TAG, _room]
	if OS.is_debug_build() and not _printed:
		# Development builds only: lets two browser tabs swap without a camera (.ai/releasing.md).
		_printed = true
		print("MeetLink code: ", text)
	return text


func understands(text: String) -> bool:
	return _read_room(text) != ""


static func _read_room(text: String) -> String:
	var bits := text.strip_edges().split("|")
	if bits.size() != 2 or bits[0] != TAG:
		return ""
	var room: String = bits[1]
	if room.length() < 22 or room.length() > 64:
		return ""
	for ch in room:
		if not ch in ROOM_CHARS:
			return ""
	return room


## Scanned a friend's code: leave our own room, join theirs as "b", and say hello there.
func dial_code(text: String) -> bool:
	var room := _read_room(text)
	if room == "" or _state != "waiting" or room == _room:
		return false
	_enter_room(room, "b")
	_state = "joining"
	_connecting = 0.0
	_new_rtc()
	_note({"t": "hi"})
	return true


# --- Meeting: the notes through the meeting point ------------------------------------------------

func _headers() -> PackedStringArray:
	return PackedStringArray(["Content-Type: application/json"])


func _note(msg: Dictionary) -> void:
	_outbox.append(JSON.stringify(msg))
	_send_next()


func _send_next() -> void:
	if _outbox.is_empty() or _send_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	var body := JSON.stringify({"room": _room, "side": _side, "key": _key, "message": _outbox[0]})
	if _send_http.request(_base() + "/send", _headers(), HTTPClient.METHOD_POST, body) != OK:
		_fail("offline")


func _on_sent(result: int, code: int, _h: PackedStringArray, _b: PackedByteArray) -> void:
	if _state == "done":
		return
	if result != HTTPRequest.RESULT_SUCCESS or code >= 300:
		if _state != "open":  # a late candidate going astray doesn't matter once connected
			_fail("offline" if result != HTTPRequest.RESULT_SUCCESS else "unreachable")
		return
	if not _outbox.is_empty():
		_outbox.remove_at(0)
	_send_next.call_deferred()


func _wait_more() -> void:
	if _state == "done" or _state == "open":
		return
	if _wait_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	var body := JSON.stringify({"room": _room, "side": _side, "key": _key, "after": _after})
	if _wait_http.request(_base() + "/wait", _headers(), HTTPClient.METHOD_POST, body) != OK:
		_fail("offline")


func _on_waited(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if _state == "done" or _state == "open":
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_wait_failures += 1
		if _wait_failures >= 3:
			_fail("offline")
		else:
			get_tree().create_timer(2.0).timeout.connect(_wait_more)
		return
	_wait_failures = 0
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK and typeof(json.data) == TYPE_DICTIONARY:
		var reply: Dictionary = json.data
		var notes: Variant = reply.get("messages", [])
		if typeof(notes) == TYPE_ARRAY:
			for n in notes:
				if typeof(n) == TYPE_STRING and str(n).length() <= MAX_NOTE:
					_on_note(str(n))
		_after = int(reply.get("next", _after))
	_wait_more.call_deferred()


## A note from the other side, untrusted: only the three shapes WebRTC needs.
func _on_note(text: String) -> void:
	var json := JSON.new()
	if json.parse(text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return
	var msg: Dictionary = json.data
	match str(msg.get("t", "")):
		"hi":
			# Someone scanned this phone's code: offer them a connection.
			if _side == "a" and _state == "waiting":
				_say("a friend scanned the code - offering")
				_state = "connecting"
				_connecting = 0.0
				_new_rtc()
				_rtc.create_offer()
		"sdp":
			var kind := str(msg.get("type", ""))
			var sdp := str(msg.get("sdp", ""))
			if _rtc == null or sdp == "":
				return
			if kind == "offer" and _side == "b":
				_say("got the offer - answering")
				_rtc.set_remote_description("offer", sdp)
			elif kind == "answer" and _side == "a":
				_say("got the answer")
				_rtc.set_remote_description("answer", sdp)
		"ice":
			if _rtc != null:
				_rtc.add_ice_candidate(str(msg.get("m", "")), int(msg.get("i", 0)), str(msg.get("c", "")))


# --- The direct link ---------------------------------------------------------------------------

func _new_rtc() -> void:
	_rtc = WebRTCPeerConnection.new()
	# No STUN, no TURN: only this network's own addresses, so only a friend right here.
	if _rtc.initialize({"iceServers": []}) != OK:
		_fail("unavailable")
		return
	_rtc.session_description_created.connect(_on_description)
	_rtc.ice_candidate_created.connect(_on_candidate)
	# Made the same way on both sides, so neither has to wait to be offered it.
	_channel = _rtc.create_data_channel("pets", {"negotiated": true, "id": 1})


func _on_description(kind: String, sdp: String) -> void:
	_rtc.set_local_description(kind, sdp)
	_note({"t": "sdp", "type": kind, "sdp": sdp})


func _on_candidate(media: String, index: int, candidate: String) -> void:
	_note({"t": "ice", "m": media, "i": index, "c": candidate})


func _process(delta: float) -> void:
	if _rtc == null or _state == "done":
		return
	_rtc.poll()
	if _state in ["joining", "connecting"]:
		_connecting += delta
		if _connecting > CONNECT_PATIENCE:
			_fail("unreachable")
			return
	if _channel == null:
		return
	match _channel.get_ready_state():
		WebRTCDataChannel.STATE_OPEN:
			if _state != "open":
				_say("direct link open")
				_state = "open"
				_wait_http.cancel_request()
			if not _hello_sent:
				_hello_sent = true
				_put(HELLO, my_name.to_utf8_buffer())
			while _channel.get_available_packet_count() > 0:
				_on_packet(_channel.get_packet())
			_flush()
		WebRTCDataChannel.STATE_CLOSED:
			if _state == "open" and not _got_pack:
				_fail("lost")


func _put(kind: int, payload: PackedByteArray) -> void:
	var p := PackedByteArray([kind])
	p.append_array(payload)
	_channel.put_packet(p)


func _on_packet(p: PackedByteArray) -> void:
	if p.is_empty():
		return
	var payload := p.slice(1)
	match p[0]:
		HELLO:
			friend_name = payload.get_string_from_utf8().substr(0, 40)
			_say("hello from " + friend_name)
			if not _linked:
				_linked = true
				linked.emit()
		START:
			if payload.size() >= 4:
				_in_total = payload.decode_u32(0)
				_in = PackedByteArray()
				if _in_total > MAX_PACK:
					_fail("lost")
		CHUNK:
			if _in_total < 0 or _in.size() + payload.size() > _in_total:
				_fail("lost")
				return
			_in.append_array(payload)
			progress.emit(_in.size(), _in_total)
		END:
			if _in_total >= 0 and _in.size() == _in_total and not _got_pack:
				_got_pack = true
				_say("got their pets: %d bytes" % _in.size())
				received.emit(_in)
				_put(BYE, PackedByteArray())
		BYE:
			pass


## The pets: START with the size, the bytes in pieces, END. Sent a little at a time (_flush).
func send(data: PackedByteArray) -> void:
	if _channel == null:
		return
	var head := PackedByteArray()
	head.resize(4)
	head.encode_u32(0, data.size())
	_out.append(PackedByteArray([START]) + head)
	for i in range(0, data.size(), PIECE):
		_out.append(PackedByteArray([CHUNK]) + data.slice(i, i + PIECE))
	_out.append(PackedByteArray([END]))
	_out_total = data.size()
	_out_sent = 0


func _flush() -> void:
	while not _out.is_empty() and _channel.get_buffered_amount() < KEEP_BUFFERED:
		var p: PackedByteArray = _out.pop_front()
		_channel.put_packet(p)
		if p[0] == CHUNK:
			_out_sent += p.size() - 1
			progress.emit(_out_sent, _out_total)


## Development builds say how far a swap got, in the browser console.
func _say(what: String) -> void:
	if OS.is_debug_build():
		print("MeetLink: ", what)


func _fail(why: String) -> void:
	if _state == "done":
		return
	_say("failed: " + why)
	finish()
	failed.emit(why)


func confirm(_yes: bool) -> void:
	pass  # a scanned code needs no check


func finish() -> void:
	_state = "done"
	if _wait_http != null:
		_wait_http.cancel_request()
	if _send_http != null:
		_send_http.cancel_request()
	if _channel != null:
		_channel.close()
	if _rtc != null:
		_rtc.close()


func _exit_tree() -> void:
	finish()
