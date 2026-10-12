class_name Tricks
extends RefCounted
## Tricks a pet can learn (.ai/pet-life.md): seven, each taught by its own swipe. The kid draws a
## symbol on a card for a trick - anything they like - then shows the card and does the swipe.
## Only the swipe's SHAPE is read (read_swipe), never the drawing (rule 4). Smarts make a pet
## learn faster. The Trick Show (TrickGame) is played with the pet's own cards.
##
## A pet's tricks are pet["tricks"]: trick -> {"image": "card_<trick>.png", "learned": 0-1}.

const ALL := ["sit", "jump", "spin", "roll", "wave", "bow", "dance"]
const INFO := {
	"sit": {"name": "Sit", "swipe": "down", "how": "swipe DOWN"},
	"jump": {"name": "Jump", "swipe": "up", "how": "swipe UP"},
	"spin": {"name": "Spin", "swipe": "circle", "how": "draw a CIRCLE"},
	"roll": {"name": "Roll over", "swipe": "side", "how": "swipe SIDEWAYS"},
	"wave": {"name": "Wave", "swipe": "zigzag", "how": "ZIGZAG side to side"},
	"bow": {"name": "Bow", "swipe": "v", "how": "swipe down and back up, like a V"},
	"dance": {"name": "Dance", "swipe": "hill", "how": "swipe up and back down, like a hill"},
}


static func display_name(trick: String) -> String:
	return INFO.get(trick, {}).get("name", trick.capitalize())


## The tricks this pet has a card for: trick -> {image, learned}.
static func cards(pet: Dictionary) -> Dictionary:
	return pet.get("tricks", {})


static func learned(pet: Dictionary, trick: String) -> float:
	return float(cards(pet).get(trick, {}).get("learned", 0.0))


static func knows(pet: Dictionary, trick: String) -> bool:
	return learned(pet, trick) >= 1.0


## Every trick the pet knows, in the order of ALL.
static func known(pet: Dictionary) -> Array:
	return ALL.filter(func(t): return knows(pet, t))


## The picture for a trick: the kid's own card if the pet has one, else the game's trick art.
static func card_texture(pet: Dictionary, trick: String) -> Texture2D:
	var file: String = cards(pet).get(trick, {}).get("image", "")
	if file != "" and pet.get("_img", {}).has(file):
		return PetStore.texture(pet, file)
	return Items.art_texture("trick_" + trick)


## How much one good lesson teaches: a quarter, more for a clever pet - four lessons at most.
static func lesson(pet: Dictionary) -> float:
	return 0.25 + Stats.value(pet, "smarts") / 240.0


## What shape a finger drew: "up", "down", "side", "circle", "zigzag", "v" (down then up), "hill"
## (up then down), or "" for a tap or a scribble. Screen y grows downwards.
static func read_swipe(points: PackedVector2Array) -> String:
	if points.size() < 4:
		return ""
	var box := Rect2(points[0], Vector2.ZERO)
	var length := 0.0
	for i in range(1, points.size()):
		box = box.expand(points[i])
		length += points[i].distance_to(points[i - 1])
	var big := maxf(box.size.x, box.size.y)
	if big < 50.0:
		return ""
	var net := points[points.size() - 1] - points[0]
	# Round and back to the start: a circle.
	if length > big * 2.4 and net.length() < big * 0.45 and minf(box.size.x, box.size.y) > big * 0.4:
		return "circle"
	# Side to side and back again, at least twice: a zigzag.
	var turns := 0
	var dir := 0.0
	var reach := points[0].x  # as far as it got going this way
	for p in points:
		if dir == 0.0:
			if absf(p.x - reach) > 24.0:
				dir = signf(p.x - reach)
				reach = p.x
		elif (p.x - reach) * dir > 0.0:
			reach = p.x
		elif absf(p.x - reach) > 24.0:
			turns += 1
			dir = -dir
			reach = p.x
	if turns >= 2 and box.size.x > box.size.y * 0.7:
		return "zigzag"
	# Down and back up (a V), or up and back down (a hill).
	var low := 0
	var high := 0
	for i in points.size():
		if points[i].y > points[low].y:
			low = i
		if points[i].y < points[high].y:
			high = i
	var n := points.size()
	var first := points[0].y
	var last := points[n - 1].y
	var dip := box.size.y * 0.45
	if low > n * 0.15 and low < n * 0.85 and points[low].y - first > dip and points[low].y - last > dip:
		return "v"
	if high > n * 0.15 and high < n * 0.85 and first - points[high].y > dip and last - points[high].y > dip:
		return "hill"
	# A straight-ish stroke: whichever way it mostly went.
	if absf(net.y) > absf(net.x) * 1.4:
		return "down" if net.y > 0.0 else "up"
	if absf(net.x) > absf(net.y) * 1.4:
		return "side"
	return ""


## The swipe for a trick drawn as a path around `center`, `size` across - shown to the kid as a
## moving dotted line, and done by the demo kid's finger.
static func swipe_path(swipe: String, center: Vector2, size: float) -> PackedVector2Array:
	var h := size * 0.5
	var pts := PackedVector2Array()
	match swipe:
		"up":
			for i in 12:
				pts.append(center + Vector2(0, h - i * size / 11.0))
		"down":
			for i in 12:
				pts.append(center + Vector2(0, -h + i * size / 11.0))
		"side":
			for i in 12:
				pts.append(center + Vector2(-h + i * size / 11.0, 0))
		"circle":
			for i in 33:
				var a := -PI / 2.0 + TAU * i / 32.0
				pts.append(center + Vector2(cos(a), sin(a)) * h * 0.8)
		"zigzag":
			var xs := [-h, h, -h, h, -h * 0.2]
			for i in xs.size() - 1:
				for k in 6:
					var x: float = lerpf(xs[i], xs[i + 1], k / 6.0)
					pts.append(center + Vector2(x, -h * 0.3 + i * h * 0.15))
		"v":
			for i in 13:
				var t := i / 12.0
				pts.append(center + Vector2(-h * 0.7 + t * h * 1.4, -h + (1.0 - absf(t * 2.0 - 1.0)) * size))
		"hill":
			for i in 13:
				var t := i / 12.0
				pts.append(center + Vector2(-h * 0.7 + t * h * 1.4, h - (1.0 - absf(t * 2.0 - 1.0)) * size))
	return pts
