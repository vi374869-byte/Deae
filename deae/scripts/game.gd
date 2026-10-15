extends Node
## Autoload "Game": the three story save slots and the player's settings.
## Saves live in the user folder (Godot menu: Project > Open User Data Folder).

const SLOT_COUNT := 3
const SETTINGS_PATH := "user://settings.cfg"

## Slot currently being played (-1 = none).
var current_slot := -1
## Progress of the slot being played. Story code changes this, then calls save_current().
var data := {}

var volume := 0.8
var fullscreen := false


func _ready() -> void:
	load_settings()


# ---------------- save slots ----------------

func slot_path(slot: int) -> String:
	return "user://save_slot_%d.json" % (slot + 1)


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


func read_slot(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(slot_path(slot)))
	return parsed if parsed is Dictionary else {}


func new_game(slot: int) -> void:
	current_slot = slot
	var now := Time.get_unix_time_from_system()
	data = {
		"version": 1,
		"chapter": 1,
		"line": 0,
		"created": now,
		"updated": now,
	}
	save_current()


func continue_game(slot: int) -> void:
	current_slot = slot
	data = read_slot(slot)


func save_current() -> void:
	if current_slot < 0:
		return
	data["updated"] = Time.get_unix_time_from_system()
	var file := FileAccess.open(slot_path(current_slot), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))


func delete_slot(slot: int) -> void:
	if slot_exists(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(slot)))
	if slot == current_slot:
		current_slot = -1
		data = {}


func delete_all_slots() -> void:
	for i in SLOT_COUNT:
		delete_slot(i)


# ---------------- settings ----------------

func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus, volume <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.0001)))


func set_fullscreen(on: bool) -> void:
	fullscreen = on
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "volume", volume)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.save(SETTINGS_PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		volume = cfg.get_value("audio", "volume", volume)
		fullscreen = cfg.get_value("display", "fullscreen", fullscreen)
	set_volume(volume)
	set_fullscreen(fullscreen)
