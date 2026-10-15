class_name LanLink
extends SwapLink
## Swapping over a local network: two phones on the same Wi-Fi, or one joined to the other's
## hotspot. They find each other by a broadcast on the room's network, then the pets go straight
## from one phone to the other over TCP - nothing goes out to the internet.
##
## The phone with the lower session number dials; the other answers. After hello, both work out
## the same check digits from the two session numbers, and the kids match the pictures.
##
## Frames on the wire: [u32 length][u8 kind][payload].

const PORT := 47811          # discovery: the first free of PORT..PORT+3 (two copies on one PC)
const TCP_PORT := 47821      # the first free of TCP_PORT..TCP_PORT+3
const TAG := "DRAWPETS1"
const MAX_FRAME := 16 * 1024 * 1024
enum { HELLO = 1, YES = 2, NO = 3, PACK = 4, BYE = 5 }

## Where to listen: everywhere on a phone; tests on one PC set "127.0.0.1" (no firewall prompt).
static var bind_host := "*"

var _udp := PacketPeerUDP.new()
var _server := TCPServer.new()
var _tcp_port := 0
var _peer: StreamPeerTCP
var _session := 0
var _peer_session := 0
var _state := "idle"         # looking, talking, done
var _announce_in := 0.0
var _hello_sent := false
var _said_yes := false
var _they_said_yes := false
var _linked := false
var _buf := PackedByteArray()
var _got_pack := false


func begin(name: String) -> void:
	my_name = name
	_session = randi_range(100000, 999999)
	var bound := false
	for p in range(PORT, PORT + 4):
		if _udp.bind(p, bind_host) == OK:
			bound = true
			break
	for p in range(TCP_PORT, TCP_PORT + 4):
		if _server.listen(p, bind_host) == OK:
			_tcp_port = p
			break
	if not bound or _tcp_port == 0:
		failed.emit("busy")
		return
	_udp.set_broadcast_enabled(true)
	var n := NearbyLink.plugin()
	if n != null:
		n.acquire_multicast_lock()  # Android drops broadcasts without it
	_state = "looking"


func _process(delta: float) -> void:
	match _state:
		"looking":
			_announce_in -= delta
			if _announce_in <= 0.0:
				_announce_in = 0.5
				_announce()
			_listen()
			if _server.is_connection_available():
				_take(_server.take_connection())
		"talking":
			_talk()


func _announce() -> void:
	var msg := ("%s|%d|%d|%s" % [TAG, _session, _tcp_port, my_name.uri_encode()]).to_utf8_buffer()
	for p in range(PORT, PORT + 4):
		for host in ["255.255.255.255", "127.0.0.1"]:
			_udp.set_dest_address(host, p)
			_udp.put_packet(msg)


func _listen() -> void:
	while _udp.get_available_packet_count() > 0:
		var pkt := _udp.get_packet().get_string_from_utf8()
		var ip := _udp.get_packet_ip()
		var bits := pkt.split("|")
		if bits.size() != 4 or bits[0] != TAG:
			continue
		var theirs := int(bits[1])
		if theirs == _session or theirs <= 0:
			continue
		if _session < theirs:
			var tcp := StreamPeerTCP.new()
			if tcp.connect_to_host(ip, int(bits[2])) == OK:
				_take(tcp)
				return


func _take(tcp: StreamPeerTCP) -> void:
	_peer = tcp
	_peer.set_no_delay(true)
	_state = "talking"


func _talk() -> void:
	_peer.poll()
	var status := _peer.get_status()
	if status == StreamPeerTCP.STATUS_CONNECTING:
		return
	if status != StreamPeerTCP.STATUS_CONNECTED:
		_lost()
		return
	if not _hello_sent:
		_hello_sent = true
		var hello := PackedByteArray()
		hello.resize(4)
		hello.encode_u32(0, _session)
		hello.append_array(my_name.to_utf8_buffer())
		_frame(HELLO, hello)
	var n := _peer.get_available_bytes()
	if n > 0:
		var got := _peer.get_partial_data(n)
		if got[0] == OK:
			_buf.append_array(got[1])
	while _buf.size() >= 5:
		var size := _buf.decode_u32(0)
		if size > MAX_FRAME:
			_lost()
			return
		if _buf.size() < 5 + size:
			progress.emit(_buf.size(), 5 + size)
			return
		var kind := _buf[4]
		var payload := _buf.slice(5, 5 + size)
		_buf = _buf.slice(5 + size)
		_on_frame(kind, payload)


func _on_frame(kind: int, payload: PackedByteArray) -> void:
	match kind:
		HELLO:
			if payload.size() < 4:
				return
			_peer_session = payload.decode_u32(0)
			var friend := payload.slice(4).get_string_from_utf8().substr(0, 40)
			check.emit(friend, _digits())
		YES:
			_they_said_yes = true
			_maybe_linked()
		NO:
			failed.emit("no")
			_reset()
		PACK:
			_got_pack = true
			received.emit(payload)
			_frame(BYE, PackedByteArray())
		BYE:
			_state = "done"


## The same three digits on both phones, from both session numbers.
func _digits() -> String:
	var lo := mini(_session, _peer_session)
	var hi := maxi(_session, _peer_session)
	return "%03d" % (absi(hash("%d-%d" % [lo, hi])) % 1000)


func confirm(yes: bool) -> void:
	if _peer == null:
		return
	if yes:
		_said_yes = true
		_frame(YES, PackedByteArray())
		_maybe_linked()
	else:
		_frame(NO, PackedByteArray())
		_reset()


func _maybe_linked() -> void:
	if _said_yes and _they_said_yes and not _linked:
		_linked = true
		linked.emit()


func send(data: PackedByteArray) -> void:
	_frame(PACK, data)
	progress.emit(data.size(), data.size())


func _frame(kind: int, payload: PackedByteArray) -> void:
	if _peer == null or _peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return
	var head := PackedByteArray()
	head.resize(5)
	head.encode_u32(0, payload.size())
	head[4] = kind
	head.append_array(payload)
	_peer.put_data(head)


func _lost() -> void:
	if _state != "done" and not _got_pack:
		failed.emit("lost")
	_reset()


## Back to looking for someone (or finished).
func _reset() -> void:
	if _peer != null:
		_peer.disconnect_from_host()
	_peer = null
	_buf.clear()
	_hello_sent = false
	_said_yes = false
	_they_said_yes = false
	_linked = false
	_state = "looking" if _state != "done" else "done"


func finish() -> void:
	_state = "done"
	if _peer != null:
		_peer.disconnect_from_host()
	_server.stop()
	_udp.close()
	var n := NearbyLink.plugin()
	if n != null:
		n.release_multicast_lock()


func _exit_tree() -> void:
	finish()
