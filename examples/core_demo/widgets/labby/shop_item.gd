extends MarginContainer

@onready var label: Label = $VBoxContainer/MarginContainer/Label
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

var slot_index : int = 0:
	set(value):
		slot_index = value
		label.text = str(slot_index)

signal item_clicked(item_index: int)

func _on_ui_widget_component_initialized(data: Dictionary) -> void:
	ui_widget_component.watch_data("selected_index", _on_selected_index_changed)
	if data.is_empty(): return
	slot_index = data.slot_index

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			item_clicked.emit(slot_index)

func _on_ui_widget_component_disposing() -> void:
	print("shop_item disposing")

func _on_ui_widget_component_updated(data: Dictionary) -> void:
	print("shop_item updated: ", data)

func _on_selected_index_changed(value: int) -> void:
	if slot_index == value:
		print("_on_selected_index_changed: ", value)
