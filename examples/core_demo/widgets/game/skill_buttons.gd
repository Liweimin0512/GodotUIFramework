extends MarginContainer

## 技能按钮容器
## 用于管理和显示技能按钮列表

# 节点引用
@onready var button_container: HBoxContainer = $HBoxContainer

# 常量
const SkillButton = preload("res://addons/GodotUIFramework/examples/core_demo/widgets/game/skill_button.tscn")

# 信号
signal skill_used(skill_data: Dictionary)

func _ready() -> void:
	# 清空初始按钮
	for child in button_container.get_children():
		child.queue_free()

## 初始化
func _setup(data: Dictionary) -> void:
	var player_data = data.get("player", {})
	var skills = player_data.get("skills", [])
	
	# 创建技能按钮
	for skill in skills:
		var button = SkillButton.instantiate()
		button_container.add_child(button)
		button.skill_used.connect(_on_skill_button_used)
		button._setup(skill)

## 刷新显示
func _refresh(data: Dictionary) -> void:
	var player_data = data.get("player", {})
	var state = data.get("state", 0)
	
	# 获取当前MP值
	var current_mp = player_data.get("mp", 0)
	
	# 更新所有技能按钮状态
	for button in button_container.get_children():
		if not button is Button: continue
		
		# 检查MP是否足够
		var mp_cost = button.skill_data.get("mp_cost", 0)
		var mp_enough = current_mp >= mp_cost
		
		# 检查是否是玩家回合
		var is_player_turn = state == 1  # BATTLE_STATE.PLAYER_TURN
		
		# 更新按钮状态
		button._refresh({
			"enabled": mp_enough and is_player_turn
		})

## 技能按钮使用处理
func _on_skill_button_used(skill_data: Dictionary) -> void:
	skill_used.emit(skill_data)
