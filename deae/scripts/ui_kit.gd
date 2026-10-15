extends RefCounted
## Small helpers so every screen shares the same pink look.

const DARK_PINK := Color(0.9058824, 0.32941177, 0.5019608)
const LIGHT_PINK := Color(1, 0.81960785, 0.8627451)


static func title(text: String, size: int = 72) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", DARK_PINK)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_color_override("font_shadow_color", Color.WHITE)
	l.add_theme_constant_override("outline_size", maxi(6, size / 7))
	l.add_theme_constant_override("shadow_offset_x", 4)
	l.add_theme_constant_override("shadow_offset_y", 4)
	return l


static func label(text: String, size: int = 26, color: Color = Color.BLACK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func centered_column(parent: Control, separation: int = 24) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	center.add_child(box)
	return box


static func hint(parent: Control, text: String) -> void:
	var l := label(text, 20, Color.BLACK)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	l.offset_left = -300
	l.offset_right = 300
	l.offset_top = -50
	l.offset_bottom = -20
	parent.add_child(l)
