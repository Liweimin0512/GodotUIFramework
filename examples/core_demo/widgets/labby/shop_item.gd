extends MarginContainer

var slot_index : int = 0

signal item_clicked(item_index: int)

func _on_ui_widget_component_initialized(data: Dictionary) -> void:
	if data.is_empty(): return
	slot_index = data.slot_index

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			item_clicked.emit(slot_index)
