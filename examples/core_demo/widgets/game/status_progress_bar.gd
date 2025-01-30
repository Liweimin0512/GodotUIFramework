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
@export_enum("player", "enemy") var character_type: String = "player":
	set(value):
		character_type = value
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
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

var game_data : GameDataTypes.GameSceneData

func _ready() -> void:
	_update_appearance()
	ui_widget_component.initialized.connect(_on_initialized)

## 处理初始化
func _on_initialized(data: Dictionary) -> void:
	game_data = GameDataTypes.GameSceneData.from_dict(data)
	_update_display()

## 更新外观
func _update_appearance() -> void:
	# 设置状态名称
	if status_label:
		status_label.text = STATUS_NAMES.get(status_type, "未知状态")
	
	# 设置进度条颜色
	if progress_bar:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = progress_color
		progress_bar.add_theme_stylebox_override("fill", style_box)

## 更新显示
func _update_display() -> void:
	if not is_inside_tree() or Engine.is_editor_hint():
		return
	
	var character_data : GameDataTypes.CharacterData
	match character_type:
		"player":
			character_data = game_data.player
		"enemy":
			character_data = game_data.enemy
	if not character_data:
		push_error("can not found character data!")
		return
	
	match status_type:
		"health":
			progress_bar.max_value = character_data.max_hp
			progress_bar.value = character_data.hp
			progress_label.text = "%d / %d" % [character_data.hp, character_data.max_hp]
		"mana":
			if character_type != "enemy":
				progress_bar.max_value = character_data.max_mp
				progress_bar.value = character_data.mp
				progress_label.text = "%d / %d" % [character_data.mp, character_data.max_mp]
