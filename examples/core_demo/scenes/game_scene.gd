extends Control

## 战斗场景
## 负责处理回合制战斗的主要逻辑

const GameDataTypes = preload("res://addons/GodotUIFramework/examples/core_demo/data/game_data_types.gd")
## 战斗状态枚举
enum BATTLE_STATE { INIT, PLAYER_TURN, ENEMY_TURN, WIN, LOSE }

## 回合指示器
@onready var turn_indicator: MarginContainer = %TurnIndicator
## 角色状态
@onready var player_status: MarginContainer = %PlayerStatus
## 敌人状态
@onready var enemy_status: MarginContainer = %EnemyStatus
## 战斗日志
@onready var battle_log_container: MarginContainer = %BattleLogContainer
## 技能按钮
@onready var skill_buttons: MarginContainer = %SkillButtons
## 场景组件
@onready var scene_component: UISceneComponent = $UISceneComponent

# 战斗数据
var current_state: BATTLE_STATE = BATTLE_STATE.INIT  ## 当前战斗状态
var player_data: GameDataTypes.CharacterData         ## 玩家数据
var enemy_data: GameDataTypes.CharacterData          ## 敌人数据
var turn_count: int = 1                              ## 回合数

func _ready() -> void:
	# 监听场景事件
	scene_component.initialized.connect(_on_initialized)
	skill_buttons.skill_used.connect(_on_skill_button_used)

## 初始化场景
func _on_initialized(data: Dictionary) -> void:
	# 初始化数据
	player_data = GameDataTypes.CharacterData.from_dict(data.get("player", {}))
	enemy_data = GameDataTypes.CharacterData.from_dict(data.get("enemy", {}))
	
	if player_data and enemy_data:
		_start_battle()

## 开始战斗
func _start_battle() -> void:
	# 设置初始状态
	current_state = BATTLE_STATE.PLAYER_TURN
	
	# 更新场景数据
	_update_scene_data()
	
	# 添加战斗日志
	_add_battle_log("战斗开始！")
	_add_battle_log("遭遇了 %s！" % enemy_data.name)

## 添加战斗日志
func _add_battle_log(text: String) -> void:
	var battle_log = GameDataTypes.BattleLogData.new(text)
	scene_component.update_data({
		"battle_log": battle_log.to_dict()
	}, ["battle_log"])

## 更新场景数据
func _update_scene_data() -> void:
	scene_component.update_data({
		"player": player_data.to_dict(),
		"enemy": enemy_data.to_dict(),
		"turn_count": turn_count,
		"state": current_state
	})

## 处理技能使用
func _on_skill_button_used(skill: GameDataTypes.SkillData) -> void:
	if current_state != BATTLE_STATE.PLAYER_TURN:
		return
	
	# 扣除玩家MP
	player_data.mp -= skill.mp_cost
	
	# 计算伤害
	var damage = skill.base_damage
	enemy_data.hp -= damage
	
	# 添加战斗日志
	_add_battle_log("%s 使用了 %s！" % [player_data.name, skill.name])
	_add_battle_log("对 %s 造成了 %d 点伤害！" % [enemy_data.name, damage])
	
	# 检查敌人是否被击败
	if enemy_data.hp <= 0:
		enemy_data.hp = 0
		current_state = BATTLE_STATE.WIN
		_add_battle_log("%s 被击败了！" % enemy_data.name)
		_add_battle_log("战斗胜利！")
	else:
		# 切换到敌人回合
		current_state = BATTLE_STATE.ENEMY_TURN
		_enemy_turn()
	
	# 更新场景数据
	_update_scene_data()

## 敌人回合
func _enemy_turn() -> void:
	# 简单的AI：随机选择一个技能
	await get_tree().create_timer(1.0).timeout
	
	var enemy_skills = enemy_data.skills
	var skill = enemy_skills[randi() % enemy_skills.size()]
	
	# 计算伤害
	var damage = skill.base_damage
	player_data.hp -= damage
	
	# 添加战斗日志
	_add_battle_log("%s 使用了 %s！" % [enemy_data.name, skill.name])
	_add_battle_log("对 %s 造成了 %d 点伤害！" % [player_data.name, damage])
	
	# 检查玩家是否被击败
	if player_data.hp <= 0:
		player_data.hp = 0
		current_state = BATTLE_STATE.LOSE
		_add_battle_log("%s 被击败了！" % player_data.name)
		_add_battle_log("战斗失败！")
	else:
		# 进入下一回合
		current_state = BATTLE_STATE.PLAYER_TURN
		turn_count += 1
		_add_battle_log("第 %d 回合" % turn_count)
	
	# 更新场景数据
	_update_scene_data()
