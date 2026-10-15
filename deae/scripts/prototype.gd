extends Control
## Save slot screen: three side-by-side slots. Empty slot = "+" (new game),
## filled slot = continue from where that story was saved.

const HoverFx = preload("res://scripts/hover_fx.gd")
const UI = preload("res://scripts/ui_kit.gd")
const MAIN_MENU := "res://scenes/main_menu.tscn"
const STORY_SCENE := "res://scenes/story.tscn"

var slot_row: HBoxContainer


func _ready() -> void:
	var column := UI.centered_column(self, 40)
	column.add_child(UI.title("Choose a story", 64))
	slot_row = HBoxContainer.new()
	slot_row.add_theme_constant_override("separation", 48)
	slot_row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(slot_row)
	_build_slots()
	UI.hint(self, "Esc - back to menu")


func _build_slots() -> void:
	for child in slot_row.get_children():
		child.queue_free()
	for i in Game.SLOT_COUNT:
		slot_row.add_child(_make_slot(i))


func _make_slot(slot: int) -> Control:
	var holder := VBoxContainer.new()
	holder.add_theme_constant_override("separation", 14)

	var card := Button.new()
	card.theme_type_variation = &"SlotCard"
	card.custom_minimum_size = Vector2(240, 300)
	holder.add_child(card)

	var info := VBoxContainer.new()
	info.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_theme_constant_override("separation", 8)
	card.add_child(info)

	var save := Game.read_slot(slot)
	var labels: Array[Label] = []
	if save.is_empty():
		var plus := UI.label("+", 140, UI.DARK_PINK)
		labels.append(plus)
		labels.append(UI.label("New Game", 26, Color.BLACK))
		card.pressed.connect(func():
			Game.new_game(slot)
			get_tree().change_scene_to_file(STORY_SCENE))
	else:
		labels.append(UI.label("Slot %d" % (slot + 1), 34, UI.DARK_PINK))
		labels.append(UI.label("Chapter %d" % int(save.get("chapter", 1)), 28))
		labels.append(UI.label("Line %d" % int(save.get("line", 0)), 24))
		var when := Time.get_datetime_string_from_unix_time(int(save.get("updated", 0)), true)
		labels.append(UI.label(when.substr(0, 16), 18))
		labels.append(UI.label("Continue", 28, UI.DARK_PINK))
		card.pressed.connect(func():
			Game.continue_game(slot)
			get_tree().change_scene_to_file(STORY_SCENE))

	for l in labels:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		info.add_child(l)
	# Text turns white while the card is hovered (the card turns dark pink).
	card.mouse_entered.connect(func(): _set_color(labels, Color.WHITE))
	card.mouse_exited.connect(func(): _recolor(labels, save.is_empty()))

	HoverFx.add(card, -2.0 if slot % 2 == 0 else 2.0, Vector2(1.06, 1.06))

	# Delete button under filled slots (click twice to confirm).
	var delete := Button.new()
	delete.text = "Delete"
	delete.add_theme_font_size_override("font_size", 20)
	delete.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	delete.visible = not save.is_empty()
	holder.add_child(delete)
	delete.pressed.connect(func():
		if delete.text == "Delete":
			delete.text = "Sure?"
		else:
			Game.delete_slot(slot)
			_build_slots())
	delete.mouse_exited.connect(func(): delete.text = "Delete")
	HoverFx.add(delete, 0.0)
	if save.is_empty():
		# keep the empty slot the same height as filled ones
		delete.modulate.a = 0.0
		delete.visible = true
		delete.disabled = true
		delete.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_recolor(labels, save.is_empty())
	return holder


func _set_color(labels: Array[Label], color: Color) -> void:
	for l in labels:
		l.add_theme_color_override("font_color", color)


func _recolor(labels: Array[Label], empty: bool) -> void:
	for i in labels.size():
		var pink := (empty and i == 0) or (not empty and (i == 0 or i == labels.size() - 1))
		labels[i].add_theme_color_override("font_color", UI.DARK_PINK if pink else Color.BLACK)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(MAIN_MENU)
