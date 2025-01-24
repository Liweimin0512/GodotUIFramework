extends Node

## 测试数据管理器

## 玩家初始数据模板
const PLAYER_DATA_TEMPLATES := {
	"test": {
		"name": "新手冒险者",
		"hp": 100,
		"max_hp": 100,
		"mp": 50,
		"max_mp": 50,
		"skills": [
			{
				"id": "attack",
				"name": "攻击",
				"damage": 15,
				"mp_cost": 0,
				"description": "基础攻击"
			},
			{
				"id": "heal",
				"name": "治疗",
				"heal": 20,
				"mp_cost": 10,
				"description": "恢复生命值"
			}
		]
	},
	"test2": {
		"name": "老练的冒险者",
		"hp": 120,
		"max_hp": 120,
		"mp": 80,
		"max_mp": 80,
		"skills": [
			{
				"id": "attack",
				"name": "强化攻击",
				"damage": 20,
				"mp_cost": 0,
				"description": "增强的基础攻击"
			},
			{
				"id": "heal",
				"name": "强效治疗",
				"heal": 30,
				"mp_cost": 15,
				"description": "强力的治疗魔法"
			},
			{
				"id": "fire_ball",
				"name": "火球术",
				"damage": 25,
				"mp_cost": 15,
				"description": "造成火焰伤害"
			}
		]
	}
}

## 敌人数据
const ENEMY_DATA := {
	"goblin": {
		"name": "哥布林",
		"hp": 50,
		"max_hp": 50,
		"skills": ["attack"],
		"description": "常见的小怪",
		"level_range": [1, 1]  # 适合的玩家等级范围
	},
	"orc": {
		"name": "兽人",
		"hp": 80,
		"max_hp": 80,
		"skills": ["attack", "rage"],
		"description": "强壮的兽人战士",
		"level_range": [1, 2]
	},
	"dragon": {
		"name": "龙",
		"hp": 150,
		"max_hp": 150,
		"skills": ["attack", "fire_breath"],
		"description": "强大的龙",
		"level_range": [2, 3]
	}
}

## 技能效果
const SKILL_EFFECTS := {
	"attack": {
		"damage": [10, 15],  # 伤害范围
		"hit_rate": 0.9,     # 命中率
		"crit_rate": 0.1     # 暴击率
	},
	"heal": {
		"heal": [20, 25]
	},
	"fire_ball": {
		"damage": [25, 30],
		"hit_rate": 0.8,
		"crit_rate": 0.15
	},
	"rage": {
		"damage": [15, 20],
		"self_damage": 5     # 自身受到的伤害
	},
	"fire_breath": {
		"damage": [30, 40],
		"hit_rate": 0.7
	}
}

## Buff效果
const BUFF_EFFECTS := {
	"burning": {
		"name": "燃烧",
		"damage_per_turn": 5,
		"duration": 3
	},
	"healing": {
		"name": "恢复",
		"heal_per_turn": 5,
		"duration": 3
	},
	"rage": {
		"name": "狂暴",
		"damage_boost": 1.5,
		"duration": 2
	}
}

## 战斗事件文本模板
const BATTLE_EVENT_TEMPLATES := {
	"attack": "{attacker} 对 {target} 发动攻击，造成 {damage} 点伤害",
	"heal": "{caster} 使用治疗，恢复 {amount} 点生命值",
	"fire_ball": "{caster} 释放火球术，对 {target} 造成 {damage} 点伤害",
	"miss": "{attacker} 的攻击被 {target} 闪避",
	"crit": "暴击！{attacker} 造成 {damage} 点伤害",
	"buff_applied": "{target} 获得了 {buff} 效果",
	"buff_removed": "{target} 的 {buff} 效果消失了",
	"buff_tick": "{buff} 效果触发，{target} {effect_description}"
}

## 根据用户名获取玩家初始数据
static func get_player_init_data(username: String) -> Dictionary:
	if username in PLAYER_DATA_TEMPLATES:
		return PLAYER_DATA_TEMPLATES[username].duplicate(true)
	return PLAYER_DATA_TEMPLATES["test"].duplicate(true)  # 默认返回新手数据

## 根据玩家等级获取适合的敌人列表
static func get_suitable_enemies(player_level: int) -> Array:
	var suitable_enemies := []
	for enemy_id in ENEMY_DATA:
		var enemy = ENEMY_DATA[enemy_id]
		if player_level >= enemy.level_range[0] and player_level <= enemy.level_range[1]:
			suitable_enemies.append(enemy_id)
	return suitable_enemies

## 获取随机敌人数据
static func get_random_enemy_data(player_level: int) -> Dictionary:
	var suitable_enemies = get_suitable_enemies(player_level)
	if suitable_enemies.is_empty():
		# 如果没有合适的敌人，返回最基础的哥布林
		return ENEMY_DATA["goblin"].duplicate(true)
	
	var random_enemy = suitable_enemies[randi() % suitable_enemies.size()]
	return ENEMY_DATA[random_enemy].duplicate(true)
