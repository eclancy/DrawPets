class_name SwapLink
extends Node
## How a pet swap gets from one phone to the other (SwapScreen, .ai/sharing.md) - always directly,
## between two phones in the same place; never through the internet or a server.
##   NearbyLink  Google's Nearby Connections (Bluetooth and a direct Wi-Fi link it makes itself)
##   LanLink     the fallback: the same Wi-Fi, or one phone's hotspot
## Both go: begin -> check (show the same pictures on both phones) -> confirm -> linked ->
## send / received -> finish.

## A friend's phone is ready: both phones show `digits` as pictures, and the kids say yes.
signal check(friend_name: String, digits: String)
## Both said yes: the pets can go.
signal linked
signal received(data: PackedByteArray)
signal progress(done: int, total: int)
## Something went wrong: "permission", "unavailable", "lost", "no", "busy".
signal failed(why: String)

var my_name := ""


func begin(_name: String) -> void:
	pass


func confirm(_yes: bool) -> void:
	pass


func send(_data: PackedByteArray) -> void:
	pass


func finish() -> void:
	pass


## Which link this phone can use: Nearby when Google Play services are there, else the Wi-Fi one.
static func best() -> SwapLink:
	if NearbyLink.usable():
		return NearbyLink.new()
	return LanLink.new()
