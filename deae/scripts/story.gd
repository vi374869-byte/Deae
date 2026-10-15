extends Control
## Placeholder story screen. Replace with the real visual novel later.
## Each step forward is saved automatically to the slot being played.

const UI = preload("res://scripts/ui_kit.gd")
const SLOT_SCREEN := "res://scenes/prototype.tscn"

var info: Label


func _ready() -> void:
	if Game.current_slot < 0:
		Game.new_game(0)  # running this scene on its own (F6): use slot 1
	var column := UI.centered_column(self, 20)
	column.add_child(UI.title("Story", 72))
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 0)
	column.add_child(panel)
	info = UI.label("", 30)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)
	_refresh()
	UI.hint(self, "Click or Space - next line (auto-saves)    Esc - save slots")


func _refresh() -> void:
	info.text = "Slot %d\nChapter %d  -  Line %d" % [
		Game.current_slot + 1, int(Game.data.get("chapter", 1)), int(Game.data.get("line", 0))]


func _advance() -> void:
	Game.data["line"] = int(Game.data.get("line", 0)) + 1
	if Game.data["line"] > 10:  # placeholder: 10 lines per chapter
		Game.data["line"] = 0
		Game.data["chapter"] = int(Game.data.get("chapter", 1)) + 1
	Game.save_current()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Game.save_current()
			get_tree().change_scene_to_file(SLOT_SCREEN)
		elif event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_advance()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
