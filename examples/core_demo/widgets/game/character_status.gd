extends MarginContainer

## 角色状态显示组件
## 用于显示角色的基本信息和状态

# 导出变量
@export var character_type: String = "player"  # "player" 或 "enemy"

# 节点引用
@onready var label_name: Label = %LabelName
@onready var label_level: Label = %LabelLevel
@onready var health_bar: Node = %HealthStatusProgressBar
@onready var mana_bar: Node = %ManaStatusProgressBar

func _ready() -> void:
	# 隐藏敌人的MP条
	if character_type == "enemy" and mana_bar:
		mana_bar.hide()

## 初始化
func _setup(data: Dictionary) -> void:
	var char_data = data.get(character_type, {})
	if not char_data: return
	
	# 更新基本信息
	if label_name:
		label_name.text = char_data.get("name", "未知")
	if label_level:
		label_level.text = "Lv.%d" % char_data.get("level", 1)

## 刷新显示
func _refresh(data: Dictionary) -> void:
	var char_data = data.get(character_type, {})
	if not char_data: return
	
	# 根据状态更新显示样式
	var state = data.get("state", 0)
	var is_active = (character_type == "player" and state == 1) or \
				   (character_type == "enemy" and state == 2)
	
	# 当前回合的角色高亮显示
	modulate = Color.WHITE if is_active else Color(0.7, 0.7, 0.7)
