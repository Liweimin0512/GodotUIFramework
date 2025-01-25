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
@onready var scene_component : UISceneComponent = $UISceneComponent

# 战斗数据
var current_state: BATTLE_STATE = BATTLE_STATE.INIT  ## 当前战斗状态
var player_data: GameDataTypes.CharacterData         ## 玩家数据
var enemy_data: GameDataTypes.CharacterData          ## 敌人数据
var turn_count: int = 1                              ## 回合数

func _ready() -> void:
	# 监听场景事件
	scene_component.data_updated.connect(_on_data_updated)
	skill_buttons.skill_used.connect(_on_skill_button_used)

## 初始化场景
func _setup(data: Dictionary) -> void:
	# 获取初始数据
	player_data = GameDataTypes.CharacterData.from_dict(data.get("player", {}))
	enemy_data = GameDataTypes.CharacterData.from_dict(data.get("enemy", {}))
	turn_count = data.get("turn_count", 1)
	current_state = data.get("state", BATTLE_STATE.INIT)
	
	# 更新场景数据
	_update_scene_data()
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
	UIManager.widget_manager.update_widget_data(battle_log_container, {
		"battle_log": battle_log.to_dict()
	})

## 技能按钮使用处理
func _on_skill_button_used(skill_data: Dictionary) -> void:
	if current_state != BATTLE_STATE.PLAYER_TURN:
		push_warning("当前不是玩家回合")
		return
	_execute_player_skill(skill_data.id)

## 执行玩家技能
func _execute_player_skill(skill_id: String) -> void:
	# 获取技能数据
	var skill = player_data.skills.filter(func(s): return s.id == skill_id)
	if skill.is_empty(): return
	skill = skill[0]
	var skill_data : GameDataTypes.SkillData = GameDataTypes.SkillData.from_dict(skill)
	
	# 检查MP是否足够
	if skill_data.mp_cost > player_data.mp:
		_add_battle_log("MP不足！")
		return
	
	# 消耗MP
	player_data.mp -= skill_data.mp_cost
	
	# 执行技能效果
	match skill_id:
		"attack":
			var damage = skill_data.power + (randi() % 3 - 1)  # 基础伤害±1
			enemy_data.hp = max(0, enemy_data.hp - damage)
			_add_battle_log("%s使用了%s，造成了%d点伤害！" % [
				player_data.name,
				skill_data.name,
				damage
			])
		
		"heal":
			var heal = skill_data.power + (randi() % 3 - 1)  # 基础治疗量±1
			var old_hp = player_data.hp
			player_data.hp = min(player_data.max_hp, player_data.hp + heal)
			var actual_heal = player_data.hp - old_hp
			_add_battle_log("%s使用了%s，恢复了%d点生命！" % [
				player_data.name,
				skill_data.name,
				actual_heal
			])
		
		"fire_ball":
			var damage = skill_data.power + (randi() % 5 - 2)  # 基础伤害±2
			enemy_data.hp = max(0, enemy_data.hp - damage)
			_add_battle_log("%s使用了%s，造成了%d点伤害！" % [
				player_data.name,
				skill_data.name,
				damage
			])
	
	# 更新场景数据
	_update_scene_data()
	
	# 检查战斗是否结束
	if enemy_data.hp <= 0:
		current_state = BATTLE_STATE.WIN
		_add_battle_log("战斗胜利！")
		return
	
	# 切换到敌人回合
	current_state = BATTLE_STATE.ENEMY_TURN
	_update_scene_data()
	
	# 执行敌人回合
	_execute_enemy_turn()

## 执行敌人回合
func _execute_enemy_turn() -> void:
	# 等待一小段时间
	await get_tree().create_timer(1.0).timeout
	
	# 执行攻击
	var damage = enemy_data.attack + (randi() % 3 - 1)  # 基础伤害±1
	player_data.hp = max(0, player_data.hp - damage)
	
	_add_battle_log("%s发动攻击，造成了%d点伤害！" % [
		enemy_data.name,
		damage
	])
	
	# 更新场景数据
	_update_scene_data()
	
	# 检查战斗是否结束
	if player_data.hp <= 0:
		current_state = BATTLE_STATE.LOSE
		_add_battle_log("战斗失败！")
		return
	
	# 切换到玩家回合
	current_state = BATTLE_STATE.PLAYER_TURN
	turn_count += 1
	_update_scene_data()

## 更新场景数据
func _update_scene_data() -> void:
	scene_component.update_data({
		"state": current_state,
		"turn_count": turn_count,
		"player": player_data.to_dict(),
		"enemy": enemy_data.to_dict()
	})

## 数据更新处理
func _on_data_updated(data: Dictionary) -> void:
	# 更新子组件数据
	UIManager.widget_manager.update_widget_data(player_status, {
		"player": data.get("player", {})
	})
	UIManager.widget_manager.update_widget_data(enemy_status, {
		"enemy": data.get("enemy", {})
	})
	UIManager.widget_manager.update_widget_data(skill_buttons, {
		"skills": data.get("player", {}).get("skills", []),
		"mp": data.get("player", {}).get("mp", 0)
	})
	UIManager.widget_manager.update_widget_data(turn_indicator, {
		"state": data.get("state", BATTLE_STATE.INIT),
		"turn_count": data.get("turn_count", 1)
	})
