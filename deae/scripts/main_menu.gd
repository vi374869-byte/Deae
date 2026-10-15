extends Control

const HoverFx = preload("res://scripts/hover_fx.gd")

# Scene that "Play" opens (the save slot screen).
const PLAY_SCENE := "res://scenes/prototype.tscn"
const SETTINGS_SCENE := "res://scenes/settings.tscn"

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var title: Control = %Title


func _ready() -> void:
	play_button.pressed.connect(func(): get_tree().change_scene_to_file(PLAY_SCENE))
	settings_button.pressed.connect(func(): get_tree().change_scene_to_file(SETTINGS_SCENE))
	quit_button.pressed.connect(func(): get_tree().quit())

	HoverFx.add(play_button, -2.0)
	HoverFx.add(settings_button, 2.0)
	HoverFx.add(quit_button, -2.0)

	_start_title_bob()


func _start_title_bob() -> void:
	# Gentle floating motion on the title.
	await get_tree().process_frame
	title.pivot_offset = title.size / 2.0
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title, "scale", Vector2(1.04, 1.04), 1.2)
	tween.tween_property(title, "scale", Vector2.ONE, 1.2)
