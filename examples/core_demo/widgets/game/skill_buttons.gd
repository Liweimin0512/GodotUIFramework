extends MarginContainer

## 技能按钮容器
## 用于管理和显示技能按钮列表

const GameDataTypes = preload("res://addons/GodotUIFramework/examples/core_demo/data/game_data_types.gd")

# 节点引用
@onready var button_container: HBoxContainer = $HBoxContainer
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

var _game_data : GameDataTypes.GameSceneData

# 信号
signal skill_used(skill: GameDataTypes.SkillData)

func _ready() -> void:
	# 清空初始按钮
	for child in button_container.get_children():
		child.queue_free()
	
	ui_widget_component.initialized.connect(_on_initialized)
	ui_widget_component.data_updated.connect(_on_data_updated)

## 处理初始化
func _on_initialized(data: Dictionary) -> void:
	_game_data = GameDataTypes.GameSceneData.from_dict(data)
	var skills := _game_data.player.skills
	_update_skill_buttons(skills)

## 处理数据更新
func _on_data_updated(path: String, value: Variant) -> void:
	if path != "player.skills": return
	_game_data.player_data.skills = value as Array
	match path:
		"skills":
			_update_skill_buttons(value)
		"mp":
			_update_mp(value)

## 更新技能按钮
func _update_skill_buttons(skills: Array) -> void:
	# 清空现有按钮
	for child in button_container.get_children():
		child.queue_free()
	
	var index := 0
	# 创建新按钮
	for skill_dict in skills:
		var skill := GameDataTypes.SkillData.from_dict(skill_dict)
		if not skill:
			continue
		
		var skill_button := ui_widget_component.create_widget("skill_button", button_container, _game_data.to_dict())
		skill_button.skill_used.connect(_on_skill_button_used)
		skill_button.index = index
		index += 1

## 更新MP值
func _update_mp(mp: int) -> void:
	for button in button_container.get_children():
		button.update_mp(mp)

## 处理技能按钮使用
func _on_skill_button_used(skill: GameDataTypes.SkillData) -> void:
	skill_used.emit(skill)
