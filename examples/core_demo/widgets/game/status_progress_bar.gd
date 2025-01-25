@tool
extends MarginContainer

## 状态进度条
## 用于显示HP/MP等状态值的进度条

const GameDataTypes = preload("res://addons/GodotUIFramework/examples/core_demo/data/game_data_types.gd")
# 常量
const STATUS_NAMES = {
	"health": "生命值",
	"mana": "魔法值"
}

# 导出变量
## 状态类型
@export_enum("health", "mana") var status_type: String = "health":
	set(value):
		status_type = value
		_update_appearance()

## 进度条颜色
@export var progress_color: Color = Color.RED:
	set(value):
		progress_color = value
		_update_appearance()

# 节点引用
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = %ProgressLabel
@onready var status_label: Label = %StatusLabel

var _character_data : GameDataTypes.CharacterData

func _ready() -> void:
	_update_appearance()

func _setup(data: Dictionary = {}) -> void:
	_character_data = GameDataTypes.CharacterData.from_dict(data)
	_update_display()

func _refresh(data: Dictionary = {}) -> void:
	_character_data = GameDataTypes.CharacterData.from_dict(data)
	_update_display()

## 更新外观
func _update_appearance() -> void:
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = progress_color
	if progress_bar:
		progress_bar.add_theme_stylebox_override("fill", style_box)
	if status_label:
		status_label.text = STATUS_NAMES.get(status_type, "")

## 更新显示
func _update_display() -> void:
	var current_value : int
	var max_value : int
	if status_type == "health":
		current_value = _character_data.hp
		max_value = _character_data.max_hp
	elif status_type == "mana":
		current_value = _character_data.mp
		max_value = _character_data.max_mp

	# 更新数值文本
	if progress_label:
		progress_label.text = "{0}/{1}".format([current_value, max_value])
	
	# 更新进度条
	if progress_bar:
		progress_bar.value = current_value
		progress_bar.max_value = max_value

		var ratio = float(current_value) / max_value if max_value > 0 else 0
		var color = progress_color
		
		# 根据状态调整颜色
		if status_type == "health":
			# 生命值低于20%时闪烁红色警告
			if ratio <= 0.2:
				color = Color.RED if Time.get_ticks_msec() % 1000 < 500 else Color.DARK_RED
			# 生命值低于50%时显示黄色警告
			elif ratio <= 0.5:
				color = Color.YELLOW
		
		progress_bar.modulate = color
