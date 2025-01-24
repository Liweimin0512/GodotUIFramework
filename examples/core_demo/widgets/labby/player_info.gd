extends MarginContainer

@onready var avatar_button: TextureButton = %AvatarButton
@onready var player_name: Label = %PlayerName
@onready var player_level: Label = %PlayerLevel

signal pressed

func _setup(data: Dictionary) -> void:
	if "name" in data:
		player_name.text = data.name
	if "level" in data:
		player_level.text = "Lv.%d" % data.level
	# if "experience" in data:
	# 	exp_label.text = "Exp: %d" % data.experience
	if "avatar" in data:
		avatar_button.texture_normal = load(data.avatar)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
	# 针对触摸屏
	if event is InputEventScreenTouch:
		if event.pressed:
			pressed.emit()
