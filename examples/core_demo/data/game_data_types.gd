extends Object

## 角色数据结构
class CharacterData:
	extends BaseData

	var name: String
	var level: int
	var hp: int
	var max_hp: int
	var mp: int
	var max_mp: int
	var skills: Array[SkillData]
	
	func to_dict() -> Dictionary:
		return {
			"name": name,
			"level": level,
			"hp": hp,
			"max_hp": max_hp,
			"mp": mp,
			"max_mp": max_mp
			"skills": skills
		}
	
	static func from_dict(data: Dictionary) -> CharacterData:
		var char = CharacterData.new()
		char.name = data.get("name", "")
		char.level = data.get("level", 1)
		char.hp = data.get("hp", 0)
		char.max_hp = data.get("max_hp", 100)
		char.mp = data.get("mp", 0)
		char.max_mp = data.get("max_mp", 100)
		char.skills = data.get("skills", [])
		return char

## 场景数据结构
class GameSceneData:
	extends BaseData

	var player: CharacterData
	var enemy: CharacterData
	var turn_count: int
	var state: int
	
	func to_dict() -> Dictionary:
		return {
			"player": player.to_dict(),
			"enemy": enemy.to_dict(),
			"turn_count": turn_count,
			"state": state
		}
	
	static func from_dict(data: Dictionary) -> GameSceneData:
		var scene_data = GameSceneData.new()
		scene_data.player = CharacterData.from_dict(data.get("player", {}))
		scene_data.enemy = CharacterData.from_dict(data.get("enemy", {}))
		scene_data.turn_count = data.get("turn_count", 1)
		scene_data.state = data.get("state", 0)
		return scene_data

## 技能数据结构
class SkillData:
	extends BaseData

	var id: String
	var name: String
	var description: String
	var damage: int
	var mp_cost: int

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"description": description,
			"damage": damage,
			"mp_cost": mp_cost
		}
	
	static func from_dict(data: Dictionary) -> SkillData:
		var skill = SkillData.new()
		skill.id = data.get("id", "")
		skill.name = data.get("name", "")
		skill.description = data.get("description", "")
		skill.damage = data.get("damage", 0)
		skill.mp_cost = data.get("mp_cost", 0)
		return skill

## 战斗日志数据结构
class BattleLogData:
	extends BaseData

	var type: String
	var text: String
	var color: String

	func to_dict() -> Dictionary:
		return {
			"type": type,
			"text": text,
			"color": color
		}
	
	static func from_dict(data: Dictionary) -> BattleLogData:
		var log = BattleLogData.new()
		log.type = data.get("type", "")
		log.text = data.get("text", "")
		log.color = data.get("color", "")
		return log

## 数据结构基类
class BaseData:

	func to_dict() -> Dictionary:
		return {}
	
	static func from_dict(data: Dictionary) -> BaseData:
		return BaseData.new()
