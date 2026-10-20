class_name LanLink
extends SwapLink
## Swapping over a local network: two phones on the same Wi-Fi, or one joined to the other's
## hotspot. The pets go straight from one phone to the other over TCP - nothing goes out to the
## internet. Two ways to find each other:
##   broadcast  both phones call out on the room's network; the lower session number dials, and
##              both work out the same check digits from the two session numbers for the kids
##              to match as pictures
##   by code    one phone shows a swap code (a QR code: where to find it, and a secret); the
##              other scans it and dials straight there. Scanning is the check, so there are no
##              pictures - and no broadcast, which an iPhone allows only with Apple's say-so.
##
## Frames on the wire: [u32 length][u8 kind][payload]. HELLO is [u32 session][u32 secret][name]:
## the secret is the scanned code's (0 when found by broadcast), and the phone that showed the
## code says nothing at all until a hello with the right secret arrives.

const PORT := 47811          # discovery: the first free of PORT..PORT+3 (two copies on one PC)
const TCP_PORT := 47821      # the first free of TCP_PORT..TCP_PORT+3
const TAG := "DRAWPETS1"
const MAX_FRAME := 16 * 1024 * 1024
## How long to keep calling the addresses in a scanned code.
const DIAL_PATIENCE := 10.0
## How long a caller to a shown code gets to say the secret before it is hung up on.
const HELLO_PATIENCE := 5.0
## Network interfaces a friend's phone cannot be on (mobile data, VPNs, virtual machines).
const SKIP := ["rmnet", "ccmni", "radio", "dummy", "tun", "ppp", "vethernet", "docker", "virtualbox",
	"vmware", "loopback", "bluetooth"]
## Interfaces to list first in a code: Wi-Fi, hotspot, Ethernet.
const PREFER := ["wlan", "swlan", "ap", "softap", "eth", "wi-fi", "wifi"]
enum { HELLO = 1, YES = 2, NO = 3, PACK = 4, BYE = 5 }

## Where to listen: everywhere on a phone; tests on one PC set "127.0.0.1" (no firewall prompt).
static var bind_host := "*"

var _udp := PacketPeerUDP.new()
var _server := TCPServer.new()
var _tcp_port := 0
var _peer: StreamPeerTCP
var _session := 0
var _peer_session := 0
var _secret := 0             # in the code this phone shows
var _secrets: Array[int] = []  # every secret this phone has shown: a code scanned just before
                             # it changed (the phone joined a hotspot) still works
var _code_where := ""
var _code_text := ""
var _dial_secret := 0        # from the code this phone scanned
var _their_secret := 0       # the secret a caller to this phone's code said
var _dials: Array[StreamPeerTCP] = []
var _dialing := 0.0
var _await_hello := false    # a caller to this phone's code: nothing until the right secret
var _waited := 0.0
var _state := "idle"         # looking, dialing, talking, done
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
	_secret = _new_secret()
	for p in range(TCP_PORT, TCP_PORT + 4):
		if _server.listen(p, bind_host) == OK:
			_tcp_port = p
			break
	if _tcp_port == 0:
		failed.emit("busy")
		return
	if not by_code:
		var bound := false
		for p in range(PORT, PORT + 4):
			if _udp.bind(p, bind_host) == OK:
				bound = true
				break
		if not bound:
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
			if not by_code:
				_announce_in -= delta
				if _announce_in <= 0.0:
					_announce_in = 0.5
					_announce()
				_listen()
			if _state == "looking" and _server.is_connection_available():
				_take(_server.take_connection(), by_code)
		"dialing":
			_dial(delta)
		"talking":
			_talk(delta)


# --- Finding each other by broadcast -----------------------------------------------------------

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


# --- Finding each other by code ----------------------------------------------------------------

## What this phone's swap code says: "DRAWPETS1|<secret>|<port>|<address>,<address>" - or "" when
## it is on no network a friend's phone could reach. The same until the addresses change.
func code() -> String:
	var ips := my_addresses()
	if ips.is_empty() or _tcp_port == 0:
		return ""
	var where := ",".join(ips)
	if where != _code_where:
		_code_where = where
		_code_text = _easy_code(where)
	return _code_text


## A code for these addresses, with a secret that makes it easy to scan: one with no lookalike
## corner squares (QrCode.lookalikes). Nearly every secret gives one at the first or second try.
func _easy_code(where: String) -> String:
	var best := ""
	var best_secret := _secret
	var fewest := -1
	for i in 12:
		var text := "%s|%08x|%d|%s" % [TAG, _secret, _tcp_port, where]
		var n := QrCode.lookalikes(QrCode.encode(text))
		if fewest < 0 or n < fewest:
			best = text
			best_secret = _secret
			fewest = n
		if n == 0:
			break
		_secret = _new_secret()
	_secret = best_secret
	if not _secrets.has(_secret):
		_secrets.append(_secret)
	return best


static func _new_secret() -> int:
	var s := 0
	while s == 0:
		s = randi()
	return s


func understands(text: String) -> bool:
	return not read_code(text).is_empty()


func dial_code(text: String) -> bool:
	var scanned := read_code(text)
	return not scanned.is_empty() and dial(scanned)


## A scanned code, checked: {secret, port, ips} - or {} if it is not a DrawPets swap code. A code
## can only send the game to one of its own ports on a home or hotspot network address - never
## out to the internet, whatever QR code a kid points the camera at.
static func read_code(text: String) -> Dictionary:
	var bits := text.strip_edges().split("|")
	if bits.size() != 4 or bits[0] != TAG:
		return {}
	if bits[1].length() != 8 or not bits[1].is_valid_hex_number():
		return {}
	var secret := bits[1].hex_to_int()
	if secret == 0 or not bits[2].is_valid_int():
		return {}
	var port := int(bits[2])
	if port < TCP_PORT or port >= TCP_PORT + 4:
		return {}
	var ips := PackedStringArray()
	for ip in bits[3].split(",", false):
		if _reachable(ip) and not ips.has(ip) and ips.size() < 3:
			ips.append(ip)
	if ips.is_empty():
		return {}
	return {"secret": secret, "port": port, "ips": ips}


## This phone's addresses a friend could reach: Wi-Fi and hotspot first, at most three.
static func my_addresses() -> PackedStringArray:
	if bind_host == "127.0.0.1":
		return PackedStringArray(["127.0.0.1"])
	var first := PackedStringArray()
	var then := PackedStringArray()
	for itf in IP.get_local_interfaces():
		var name := str(itf.get("name", "")).to_lower()
		var friendly := str(itf.get("friendly", "")).to_lower()
		if SKIP.any(func(s): return s in name or s in friendly):
			continue
		var preferred := PREFER.any(func(s): return name.begins_with(s) or friendly.begins_with(s))
		for ip in itf.get("addresses", []):
			if not private_ipv4(ip) or first.has(ip) or then.has(ip):
				continue
			if preferred:
				first.append(ip)
			else:
				then.append(ip)
	first.append_array(then)
	return first.slice(0, 3)


## 10.x, 172.16-31.x and 192.168.x: home, school and hotspot networks, never the internet.
static func private_ipv4(ip: String) -> bool:
	var p := ip.split(".")
	if p.size() != 4:
		return false
	for s in p:
		if not s.is_valid_int() or int(s) < 0 or int(s) > 255:
			return false
	var a := int(p[0])
	var b := int(p[1])
	return a == 10 or (a == 172 and b >= 16 and b <= 31) or (a == 192 and b == 168)


static func _reachable(ip: String) -> bool:
	if bind_host == "127.0.0.1":
		return ip == "127.0.0.1"
	return private_ipv4(ip)


## Calls the phone whose code was scanned, at every address in it at once; the first to answer
## wins. False if this link is busy with someone already.
func dial(scanned: Dictionary) -> bool:
	if _state != "looking":
		return false
	_dial_secret = scanned["secret"]
	_dialing = 0.0
	_dials.clear()
	for ip in scanned["ips"]:
		var t := StreamPeerTCP.new()
		if t.connect_to_host(ip, scanned["port"]) == OK:
			_dials.append(t)
	_state = "dialing"
	if _dials.is_empty():
		_give_up_dialing()
	return true


func _dial(delta: float) -> void:
	_dialing += delta
	for t: StreamPeerTCP in _dials.duplicate():
		t.poll()
		var status := t.get_status()
		if status == StreamPeerTCP.STATUS_CONNECTED:
			_dials.erase(t)
			_hang_up_dials()
			_take(t)
			return
		if status != StreamPeerTCP.STATUS_CONNECTING:
			_dials.erase(t)
	if _dials.is_empty() or _dialing > DIAL_PATIENCE:
		_give_up_dialing()


func _give_up_dialing() -> void:
	_hang_up_dials()
	_dial_secret = 0
	_state = "looking"
	failed.emit("unreachable")


func _hang_up_dials() -> void:
	for t in _dials:
		t.disconnect_from_host()
	_dials.clear()


# --- Talking -----------------------------------------------------------------------------------

func _take(tcp: StreamPeerTCP, await_hello := false) -> void:
	_peer = tcp
	_peer.set_no_delay(true)
	_await_hello = await_hello
	_waited = 0.0
	_state = "talking"


func _talk(delta: float) -> void:
	_peer.poll()
	var status := _peer.get_status()
	if status == StreamPeerTCP.STATUS_CONNECTING:
		return
	if status != StreamPeerTCP.STATUS_CONNECTED:
		if _await_hello:
			_reset()  # a caller who never said the secret: keep showing the code
		else:
			_lost()
		return
	if _await_hello:
		_waited += delta
		if _waited > HELLO_PATIENCE:
			_reset()
			return
	elif not _hello_sent:
		_send_hello()
	var n := _peer.get_available_bytes()
	if n > 0:
		var got := _peer.get_partial_data(n)
		if got[0] == OK:
			_buf.append_array(got[1])
	while _buf.size() >= 5 and _peer != null:
		var size := _buf.decode_u32(0)
		if size > MAX_FRAME or (_await_hello and size > 4096):
			_lost()
			return
		if _buf.size() < 5 + size:
			progress.emit(_buf.size(), 5 + size)
			return
		var kind := _buf[4]
		var payload := _buf.slice(5, 5 + size)
		_buf = _buf.slice(5 + size)
		_on_frame(kind, payload)


func _send_hello() -> void:
	_hello_sent = true
	var hello := PackedByteArray()
	hello.resize(8)
	hello.encode_u32(0, _session)
	# The scanned code's secret: the one this phone scanned, or the one its caller said back.
	var secret := _dial_secret if _dial_secret != 0 else _their_secret
	hello.encode_u32(4, secret)
	hello.append_array(my_name.to_utf8_buffer())
	_frame(HELLO, hello)


func _on_frame(kind: int, payload: PackedByteArray) -> void:
	if _await_hello and kind != HELLO:
		_reset()
		return
	match kind:
		HELLO:
			if payload.size() < 8 or _peer_session != 0:
				return
			var secret := payload.decode_u32(4)
			if _dial_secret != 0:
				# This phone scanned their code: only the phone that showed it knows the secret.
				if secret != _dial_secret:
					_lost()
					return
			elif _await_hello:
				# They scanned this phone's code.
				if not _secrets.has(secret):
					_reset()
					return
				_their_secret = secret
				_await_hello = false
				_send_hello()
			_peer_session = payload.decode_u32(0)
			friend_name = payload.slice(8).get_string_from_utf8().substr(0, 40)
			if secret != 0 and (by_code or _dial_secret != 0):
				# Scanning was the check: straight on to the pets.
				_said_yes = true
				_they_said_yes = true
				_maybe_linked()
			else:
				check.emit(friend_name, _digits())
		YES:
			_they_said_yes = true
			_maybe_linked()
		NO:
			failed.emit("no")
			_reset()
		PACK:
			if not _linked:
				return
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
	_await_hello = false
	_dial_secret = 0
	_their_secret = 0
	_peer_session = 0
	friend_name = ""
	_state = "looking" if _state != "done" else "done"


func finish() -> void:
	_state = "done"
	_hang_up_dials()
	if _peer != null:
		_peer.disconnect_from_host()
	_server.stop()
	_udp.close()
	if not by_code:
		var n := NearbyLink.plugin()
		if n != null:
			n.release_multicast_lock()


func _exit_tree() -> void:
	finish()
