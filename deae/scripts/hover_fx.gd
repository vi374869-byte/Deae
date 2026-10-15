extends RefCounted
## Bouncy hover / press animation for any button.
## Usage: HoverFx.add(button)   (with: const HoverFx = preload("res://scripts/hover_fx.gd"))

const HOVER_SCALE := Vector2(1.08, 1.08)
const PRESS_SCALE := Vector2(0.95, 0.95)
const ANIM_TIME := 0.15


static func add(button: BaseButton, tilt_degrees: float = -2.0, hover_scale: Vector2 = HOVER_SCALE) -> void:
	button.resized.connect(func(): button.pivot_offset = button.size / 2.0)
	button.pivot_offset = button.size / 2.0
	button.mouse_entered.connect(func(): _animate(button, hover_scale, tilt_degrees))
	button.mouse_exited.connect(func(): _animate(button, Vector2.ONE, 0.0))
	button.focus_entered.connect(func(): _animate(button, hover_scale, 0.0))
	button.focus_exited.connect(func(): _animate(button, Vector2.ONE, 0.0))
	button.button_down.connect(func(): _animate(button, PRESS_SCALE, 0.0, 0.06))
	button.button_up.connect(func(): _animate(button, hover_scale if button.is_hovered() else Vector2.ONE, 0.0))


static func _animate(button: BaseButton, target_scale: Vector2, tilt: float, time: float = ANIM_TIME) -> void:
	if not button.is_inside_tree():
		return
	if button.has_meta("hover_tween"):
		var old: Tween = button.get_meta("hover_tween")
		if old and old.is_valid():
			old.kill()
	var tween := button.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, time)
	tween.tween_property(button, "rotation_degrees", tilt, time)
	button.set_meta("hover_tween", tween)
