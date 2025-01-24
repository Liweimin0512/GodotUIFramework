extends Control

## 战斗场景
## 负责处理回合制战斗的主要逻辑

const GameDataTypes = preload("res://addons/GodotUIFramework/examples/core_demo/data/game_data_types.gd")

# 战斗状态枚举
enum BATTLE_STATE { INIT, PLAYER_TURN, ENEMY_TURN, WIN, LOSE }

# 战斗数据
var current_state: BATTLE_STATE = BATTLE_STATE.INIT
var player_data: Dictionary
var enemy_data: Dictionary
var turn_count: int = 1

func _ready() -> void:
	# 监听场景事件
	var scene_component = UIManager.get_scene_component(self)
	if scene_component:
		scene_component.scene_opened.connect(_on_scene_opened)
		scene_component.scene_closed.connect(_on_scene_closed)

## 场景打开处理
func _on_scene_opened(_scene: Control) -> void:
	# 初始化战斗
	if current_state == BATTLE_STATE.INIT:
		_setup(UIManager.scene_manager.get_scene_data(self))
		_start_battle()

## 场景关闭处理
func _on_scene_closed(_scene: Control) -> void:
	# 清理资源
	player_data.clear()
	enemy_data.clear()
	current_state = BATTLE_STATE.INIT
	turn_count = 1

## 初始化场景
func _setup(data: Dictionary) -> void:
	# 获取初始数据
	player_data = data.get("player", {})
	enemy_data = data.get("enemy", {})
	turn_count = data.get("turn_count", 1)
	current_state = data.get("state", BATTLE_STATE.INIT)
	
	# 更新场景数据
	UIManager.scene_manager.update_scene_data(self, data)

## 开始战斗
func _start_battle() -> void:
	# 设置初始状态
	current_state = BATTLE_STATE.PLAYER_TURN
	
	# 更新场景数据
	UIManager.scene_manager.update_scene_data(self, {
		"state": current_state
	})
	
	# 添加战斗日志
	_add_battle_log("战斗开始！")
	_add_battle_log("遭遇了 %s！" % enemy_data.name)

## 添加战斗日志
func _add_battle_log(text: String) -> void:
	var battle_log = UIManager.get_widget_component(%BattleLogContainer)
	if battle_log:
		battle_log.update_data({
			"text": text,
			"type": "append"
		})

## 技能按钮使用处理
func _on_skill_button_used(skill_data: Dictionary) -> void:
	if current_state != BATTLE_STATE.PLAYER_TURN:
		return
	
	_execute_player_skill(skill_data.id)

## 执行玩家技能
func _execute_player_skill(skill_id: String) -> void:
	# 获取技能数据
	var skill = player_data.skills.filter(func(s): return s.id == skill_id)
	if skill.is_empty(): return
	skill = skill[0]
	
	# 检查MP是否足够
	if skill.mp_cost > player_data.mp:
		_add_battle_log("MP不足！")
		return
	
	# 消耗MP
	player_data.mp -= skill.mp_cost
	
	# 执行技能效果
	match skill_id:
		"attack":
			var damage = skill.power + (randi() % 3 - 1)  # 基础伤害±1
			enemy_data.hp = max(0, enemy_data.hp - damage)
			_add_battle_log("%s使用了%s，造成了%d点伤害！" % [
				player_data.name,
				skill.name,
				damage
			])
		
		"heal":
			var heal = skill.power + (randi() % 3 - 1)  # 基础治疗量±1
			var old_hp = player_data.hp
			player_data.hp = min(player_data.max_hp, player_data.hp + heal)
			var actual_heal = player_data.hp - old_hp
			_add_battle_log("%s使用了%s，恢复了%d点生命！" % [
				player_data.name,
				skill.name,
				actual_heal
			])
		
		"fire_ball":
			var damage = skill.power + (randi() % 5 - 2)  # 基础伤害±2
			enemy_data.hp = max(0, enemy_data.hp - damage)
			_add_battle_log("%s使用了%s，造成了%d点伤害！" % [
				player_data.name,
				skill.name,
				damage
			])
	
	# 更新场景数据
	UIManager.scene_manager.update_scene_data(self, {
		"player": player_data,
		"enemy": enemy_data
	})
	
	# 检查战斗是否结束
	if enemy_data.hp <= 0:
		current_state = BATTLE_STATE.WIN
		_add_battle_log("战斗胜利！")
		UIManager.scene_manager.update_scene_data(self, {"state": current_state})
		return
	
	# 切换到敌人回合
	current_state = BATTLE_STATE.ENEMY_TURN
	UIManager.scene_manager.update_scene_data(self, {"state": current_state})
	
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
	UIManager.scene_manager.update_scene_data(self, {
		"player": player_data
	})
	
	# 检查战斗是否结束
	if player_data.hp <= 0:
		current_state = BATTLE_STATE.LOSE
		_add_battle_log("战斗失败...")
		UIManager.scene_manager.update_scene_data(self, {"state": current_state})
		return
	
	# 切换到玩家回合
	current_state = BATTLE_STATE.PLAYER_TURN
	turn_count += 1
	
	# 恢复一点MP
	player_data.mp = min(player_data.max_mp, player_data.mp + 1)
	
	# 更新场景数据
	UIManager.scene_manager.update_scene_data(self, {
		"player": player_data,
		"turn_count": turn_count,
		"state": current_state
	})

func update_player_data(player: GameDataTypes.Character) -> void:
	UIManager.scene_manager.update_scene_data(self, {
		"player": player.to_dict()
	})

func update_enemy_data(enemy: GameDataTypes.Character) -> void:
	UIManager.scene_manager.update_scene_data(self, {
		"enemy": enemy.to_dict()
	})

func update_turn_count(turn_count: int) -> void:
	UIManager.scene_manager.update_scene_data(self, {
		"turn_count": turn_count
	})
