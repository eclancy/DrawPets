class_name Visitors
extends RefCounted
## Friends' pets, kept on this phone after a swap (.ai/sharing.md): they drop in to visit your
## homes now and then, play, and make friends with your pets. A family's pets are as up to date
## as the last time the kids swapped; swapping again refreshes them. Nothing here ever leaves the
## phone or goes to a server.
##
## On disk: user://visitors/<family id>/<pet id>/pet.json + its drawings. In the profile:
## "friend_families": family id -> {name, pets: [pet ids], met (unix), swaps}.
## In a home a visitor's id is "visit_<family id>_<pet id>", so it never meets one of yours.

const ROOT := "user://visitors"
## The most friend families kept; the one met longest ago goes first.
const MAX_FAMILIES := 30


static func families(profile: Profile) -> Dictionary:
	return profile.data.get("friend_families", {})


## A friend family's pets have arrived: saved (replacing the old copies, but keeping who they have
## made friends with here), and the family remembered. Returns how many pets came.
static func save_family(profile: Profile, pack: Dictionary) -> int:
	var fam: Dictionary = pack["family"]
	var fid: String = fam["id"]
	var dir := "%s/%s" % [ROOT, fid]
	var old_friends := {}
	var old: Dictionary = families(profile).get(fid, {})
	for pid in old.get("pets", []):
		var prev := load_pet(fid, pid)
		if not prev.is_empty():
			old_friends[pid] = prev.get("friends", {})
	_remove_dir(dir)
	var ids := []
	for pet in pack["pets"]:
		var pid: String = pet["id"]
		var folder := "%s/%s" % [dir, pid]
		DirAccess.make_dir_recursive_absolute(folder)
		for file in pet["_img"]:
			(pet["_img"][file] as Image).save_png(folder + "/" + file)
		var plain := {}
		for k in pet:
			if not str(k).begins_with("_"):
				plain[k] = pet[k]
		plain["friends"] = old_friends.get(pid, {})
		var f := FileAccess.open(folder + "/pet.json", FileAccess.WRITE)
		f.store_string(JSON.stringify(plain))
		ids.append(pid)
	var all := families(profile)
	all[fid] = {"name": fam["name"], "pets": ids, "met": int(Time.get_unix_time_from_system()),
		"swaps": int(old.get("swaps", 0)) + 1}
	profile.data["friend_families"] = all
	while all.size() > MAX_FAMILIES:
		var oldest := ""
		for k in all:
			if oldest == "" or int(all[k]["met"]) < int(all[oldest]["met"]):
				oldest = k
		forget(profile, oldest)
	profile.save()
	return ids.size()


## A visiting pet, ready to set up as a Creature: its id is made visit-only.
static func load_pet(fid: String, pid: String) -> Dictionary:
	var folder := "%s/%s/%s" % [ROOT, fid, pid]
	var data = JSON.parse_string(FileAccess.get_file_as_string(folder + "/pet.json")) \
		if FileAccess.file_exists(folder + "/pet.json") else null
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var pet: Dictionary = data
	pet["_img"] = {}
	pet["_tex"] = {}
	for file in PetStore.image_files(pet):
		var img := Image.load_from_file(folder + "/" + file)
		if img != null:
			pet["_img"][file] = img
	pet["_family"] = fid
	pet["_pid"] = pid
	pet["id"] = visit_id(fid, pid)
	return pet


static func visit_id(fid: String, pid: String) -> String:
	return "visit_%s_%s" % [fid, pid]


## A visit_ id back to a visiting pet, or {}.
static func load_by_visit_id(profile: Profile, vid: String) -> Dictionary:
	for fid in families(profile):
		if vid.begins_with("visit_%s_" % fid):
			return load_pet(fid, vid.trim_prefix("visit_%s_" % fid))
	return {}


## After a visit: who it made friends with here is remembered for next time.
static func save_friends(pet: Dictionary) -> void:
	var fid: String = pet.get("_family", "")
	var pid: String = pet.get("_pid", "")
	var path := "%s/%s/%s/pet.json" % [ROOT, fid, pid]
	if fid == "" or not FileAccess.file_exists(path):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		return
	data["friends"] = pet.get("friends", {})
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))


## Someone to come over today: a random pet from a random friend family, or {}.
static func pick(profile: Profile) -> Dictionary:
	var fams := families(profile).keys()
	fams.shuffle()
	for fid in fams:
		var pets: Array = families(profile)[fid].get("pets", []).duplicate()
		pets.shuffle()
		for pid in pets:
			var pet := load_pet(fid, pid)
			if not pet.is_empty():
				return pet
	return {}


## A grown-up took them off the friends list: their pets are deleted from this phone, and your
## pets forget them.
static func forget(profile: Profile, fid: String) -> void:
	_remove_dir("%s/%s" % [ROOT, fid])
	families(profile).erase(fid)
	for h in profile.homes():
		for id in h["pets"]:
			var pet := PetStore.load_pet(id)
			var friends: Dictionary = pet.get("friends", {})
			var gone := friends.keys().filter(func(k): return str(k).begins_with("visit_%s_" % fid))
			if not gone.is_empty():
				for k in gone:
					friends.erase(k)
				PetStore.save_pet(pet)
	profile.save()


static func _remove_dir(path: String) -> void:
	var d := DirAccess.open(path)
	if d == null:
		return
	for sub in d.get_directories():
		_remove_dir(path + "/" + sub)
	for file in d.get_files():
		d.remove(file)
	DirAccess.remove_absolute(path)
