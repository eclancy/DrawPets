class_name SwapLink
extends Node
## How a pet swap gets from one phone to the other (SwapScreen, .ai/sharing.md) - always directly,
## between two phones in the same place; never through the internet or a server.
##   NearbyLink  Google's Nearby Connections (Bluetooth and a direct Wi-Fi link it makes itself)
##   LanLink     the fallback: the same Wi-Fi, or one phone's hotspot - found by a broadcast, or
##               by scanning a swap code (QR) one phone shows
##   MeetLink    in a browser (the web version): a swap code, a meeting point on ecec.dev to
##               introduce the two devices, then WebRTC straight between them
## They go: begin -> check (show the same pictures on both phones) -> confirm -> linked ->
## send / received -> finish. A scanned code needs no check: begin -> linked.

## A friend's phone is ready: both phones show `digits` as pictures, and the kids say yes.
signal check(friend_name: String, digits: String)
## Both said yes: the pets can go.
signal linked
signal received(data: PackedByteArray)
signal progress(done: int, total: int)
## Something went wrong: "permission", "location", "unavailable", "lost", "no", "busy",
## "unreachable" (nobody answered at a scanned code's address).
signal failed(why: String)

var my_name := ""
## The friend family's nickname, once their phone has said hello.
var friend_name := ""
## Finds the friend by a swap code one device shows and the other scans (set before begin).
var by_code := false


func begin(_name: String) -> void:
	pass


func confirm(_yes: bool) -> void:
	pass


func send(_data: PackedByteArray) -> void:
	pass


func finish() -> void:
	pass


## Swapping by code: what this device's code says ("" while it has none to show)...
func code() -> String:
	return ""


## ...whether a scanned code is one this link can call...
func understands(_text: String) -> bool:
	return false


## ...and calling it. False if this link is busy.
func dial_code(_text: String) -> bool:
	return false


## Which link this phone can use: Nearby when Google Play services are there, else the Wi-Fi one.
static func best() -> SwapLink:
	if OS.has_feature("web"):
		return MeetLink.new()
	if NearbyLink.usable():
		return NearbyLink.new()
	return LanLink.new()


## The link for swapping by code: a browser meets through ecec.dev, an app calls over the Wi-Fi.
static func for_code() -> SwapLink:
	if OS.has_feature("web"):
		return MeetLink.new()
	var lan := LanLink.new()
	lan.by_code = true
	return lan
