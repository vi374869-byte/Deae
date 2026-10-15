extends Control

const HoverFx = preload("res://scripts/hover_fx.gd")
const UI = preload("res://scripts/ui_kit.gd")
const MAIN_MENU := "res://scenes/main_menu.tscn"

var restart_button: Button
var restart_armed := false


func _ready() -> void:
	var column := UI.centered_column(self, 28)
	column.add_child(UI.title("Settings"))

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 0)
	column.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 26)
	panel.add_child(rows)

	# Volume
	var vol_row := HBoxContainer.new()
	vol_row.add_theme_constant_override("separation", 20)
	rows.add_child(vol_row)
	var vol_label := UI.label("Volume")
	vol_label.custom_minimum_size.x = 150
	vol_row.add_child(vol_label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = Game.volume
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vol_row.add_child(slider)
	var vol_value := UI.label("%d%%" % roundi(Game.volume * 100), 26, UI.DARK_PINK)
	vol_value.custom_minimum_size.x = 80
	vol_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vol_row.add_child(vol_value)
	slider.value_changed.connect(func(v: float):
		Game.set_volume(v)
		vol_value.text = "%d%%" % roundi(v * 100)
		Game.save_settings())

	# Fullscreen
	var full_row := HBoxContainer.new()
	rows.add_child(full_row)
	var full_label := UI.label("Fullscreen")
	full_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	full_row.add_child(full_label)
	var full_toggle := CheckButton.new()
	full_toggle.button_pressed = Game.fullscreen
	full_row.add_child(full_toggle)
	full_toggle.toggled.connect(func(on: bool):
		Game.set_fullscreen(on)
		Game.save_settings())

	# Restart story (press twice to confirm)
	restart_button = Button.new()
	restart_button.text = "Restart Story"
	restart_button.custom_minimum_size = Vector2(0, 60)
	rows.add_child(restart_button)
	restart_button.pressed.connect(_on_restart_pressed)
	restart_button.mouse_exited.connect(_disarm_restart)
	HoverFx.add(restart_button, 0.0, Vector2(1.04, 1.04))

	# Back
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(280, 64)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(back)
	back.pressed.connect(_go_back)
	HoverFx.add(back)

	UI.hint(self, "Esc - back to menu")


func _on_restart_pressed() -> void:
	if not restart_armed:
		restart_armed = true
		restart_button.text = "Erase ALL saves? Click again"
		return
	Game.delete_all_slots()
	restart_armed = false
	restart_button.text = "All saves erased"


func _disarm_restart() -> void:
	if restart_armed:
		restart_armed = false
		restart_button.text = "Restart Story"


func _go_back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_go_back()
