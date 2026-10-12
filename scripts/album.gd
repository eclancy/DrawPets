class_name Album
extends RefCounted
## The family photo album: photos taken in a home with the camera (PhotoEditor), framed and
## stickered, kept in user://photos/ with a list in the profile. They stay in the game - never
## saved to the phone's gallery, never shared (.ai/sharing.md).

const DIR := "user://photos"
## The most photos kept; the oldest go first.
const MAX := 120


## Keeps a finished photo; returns its id.
static func add(profile: Profile, img: Image, home_id: String, pet_ids: Array) -> String:
	DirAccess.make_dir_recursive_absolute(DIR)
	var id := "photo_" + PetStore.new_id().substr(4)
	img.save_png("%s/%s.png" % [DIR, id])
	var list: Array = profile.data.get("photos", [])
	list.append({"id": id, "t": int(Time.get_unix_time_from_system()), "home": home_id, "pets": pet_ids})
	while list.size() > MAX:
		var old: Dictionary = list.pop_front()
		DirAccess.remove_absolute("%s/%s.png" % [DIR, old["id"]])
	profile.data["photos"] = list
	profile.save()
	return id


## Every photo, newest first: [{id, t, home, pets}].
static func photos(profile: Profile) -> Array:
	var list: Array = profile.data.get("photos", []).duplicate()
	list.reverse()
	return list


static func texture(id: String) -> Texture2D:
	var path := "%s/%s.png" % [DIR, id]
	if id == "" or not FileAccess.file_exists(path):
		return null
	var img := Image.load_from_file(path)
	return ImageTexture.create_from_image(img) if img != null else null


static func remove(profile: Profile, id: String) -> void:
	var list: Array = profile.data.get("photos", [])
	for i in range(list.size() - 1, -1, -1):
		if list[i]["id"] == id:
			list.remove_at(i)
	DirAccess.remove_absolute("%s/%s.png" % [DIR, id])
	profile.save()
