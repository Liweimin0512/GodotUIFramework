extends Button

## 技能按钮
## 用于显示和触发技能

const GameDataTypes = preload("res://addons/GodotUIFramework/examples/core_demo/data/game_data_types.gd")

# 节点引用
@onready var icon_rect: TextureRect = %IconRect
@onready var cost_label: Label = %CostLabel
@onready var cooldown_label: Label = %CooldownLabel
@onready var ui_widget_component: UIWidgetComponent = %UIWidgetComponent

# 属性
var skill: GameDataTypes.SkillData
var current_mp: int = 0
var index : int = 0:
	set(value):
		index = value
		skill = GameDataTypes.SkillData.from_dict(game_data.player.skills[index])
		_update_display()
var game_data : GameDataTypes.GameSceneData

# 信号
signal skill_used(skill: GameDataTypes.SkillData)

func _ready() -> void:
	ui_widget_component.initialized.connect(_on_initialized)

## 更新MP值
func update_mp(mp: int) -> void:
	current_mp = mp
	_update_state()

## 更新显示
func _update_display() -> void:
	if not skill:
		return
	
	# 更新技能图标
	if not skill.icon_path.is_empty():
		if ResourceLoader.exists(skill.icon_path):
			icon_rect.texture = load(skill.icon_path)
	
	# 更新技能名称
	text = skill.name
	
	# 更新MP消耗
	cost_label.text = str(skill.mp_cost)
	
	# 更新状态
	_update_state()

## 更新状态
func _update_state() -> void:
	if not skill:
		return
	
	# 检查MP是否足够
	disabled = current_mp < skill.mp_cost

## 处理按钮点击
func _on_pressed() -> void:
	if not disabled and skill:
		skill_used.emit(skill)

func _on_initialized(data: Dictionary) -> void:
	game_data = GameDataTypes.GameSceneData.from_dict(data)
	
