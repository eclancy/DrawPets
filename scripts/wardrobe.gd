class_name Wardrobe
extends RefCounted
## Putting clothes on a creature that could be any shape at all. Each item says where it is
## worn (head, eyes, neck, back); Wardrobe finds that place on THIS pet's drawings - the top of
## its head's ink, the middle of its eyes - and sizes the item to fit it. Clothes are stored
## like parts, in body space, hung on the part they sit on, so a hat nods with its head.
##
## One item per place: a new hat replaces the old hat.


## Puts `item` on the pet, replacing whatever it wore in the same place.
static func put_on(pet: Dictionary, item: Dictionary) -> void:
	var entry := fit(pet, item)
	if entry.is_empty():
		return
	var outfit: Array = pet.get("outfit", [])
	for old in outfit.duplicate():
		var other := Items.get_item(old.get("item", ""))
		if other.get("wear", "") == item.get("wear", ""):
			outfit.erase(old)
	outfit.append(entry)
	pet["outfit"] = outfit


static func take_off_all(pet: Dictionary) -> void:
	pet["outfit"] = []


## Where and how big an item goes on this pet, as an outfit entry.
static func fit(pet: Dictionary, item: Dictionary) -> Dictionary:
	var img: Image = item.get("_img")
	if img == null:
		return {}
	var item_w := float(img.get_width())
	var head := PetBuilder.head(pet)
	var body := PetBuilder.find(pet, "body")
	var host := head if not head.is_empty() else body
	var box := ink_box(pet, host)
	var pos := Vector2.ZERO
	var width := 0.0
	var behind := false
	match item.get("wear", "head"):
		"head":
			var top := PetBuilder.anchor_px(pet["_img"][host["image"]], Vector2(0.5, 0.5), Vector2(0, -1))
			pos = PetBuilder.sprite_xform(host) * (top + Vector2(0, 10))
			width = box.size.x * 0.72
		"eyes":
			var eyes := []
			for p in pet["parts"]:
				if p["type"] == "eye":
					eyes.append(p)
			if eyes.is_empty():
				pos = box.position + box.size * Vector2(0.72, 0.38)
				width = box.size.x * 0.5
			else:
				var lo := PetBuilder.v2(eyes[0]["pos"])
				var hi := lo
				for e in eyes:
					var q := PetBuilder.v2(e["pos"])
					lo = lo.min(q)
					hi = hi.max(q)
				pos = (lo + hi) / 2.0
				width = maxf(hi.x - lo.x, box.size.x * 0.18) * 1.9
				host = PetBuilder.find(pet, eyes[0]["parent"])
		"neck":
			if not head.is_empty():
				pos = PetBuilder.v2(head["pos"]) + Vector2(0, -box.size.y * 0.05)
				width = box.size.x * 0.55
			else:
				pos = box.position + box.size * Vector2(0.75, 0.35)
				width = box.size.x * 0.35
			host = body
		"back":
			var bbox := ink_box(pet, body)
			var top := PetBuilder.anchor_px(pet["_img"][body["image"]], Vector2(0.4, 0.5), Vector2(0, -1))
			pos = PetBuilder.sprite_xform(body) * (top + Vector2(0, 20))
			width = bbox.size.x * 0.55
			behind = item["id"] != "back_backpack"
			host = body
	var k := width / maxf(item_w, 1.0)
	return {"item": item["id"], "parent": host["id"], "pos": PetBuilder.arr(pos), "rot": 0.0,
		"scale": snappedf(k, 0.001), "flip": false, "behind": behind}


## The box round a part's ink, in body space (parts are unrotated when fitted).
static func ink_box(pet: Dictionary, p: Dictionary) -> Rect2:
	var img: Image = pet["_img"].get(p["image"])
	if img == null:
		return Rect2(PetBuilder.v2(p["pos"]), Vector2(100, 100))
	var x := PetBuilder.sprite_xform(p)
	return Rect2(x * Vector2.ZERO, Vector2.ZERO).expand(x * Vector2(img.get_size())).abs()
