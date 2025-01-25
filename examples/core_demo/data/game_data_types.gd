extends Object

## 角色数据结构
class CharacterData:
	extends BaseData

	var name: String
	var hp: int
	var max_hp: int
	var skills: Array
	
	func _init(
			p_name : String = "",
			p_hp : int = 0,
			p_max_hp : int = 0,
			p_skills : Array = [],
			) -> void:
		name = p_name
		hp = p_hp
		max_hp = p_max_hp
		skills = p_skills

	func to_dict() -> Dictionary:
		return {
			"name": name,
			#"level": level,
			"hp": hp,
			"max_hp": max_hp,
			#"mp": mp,
			#"max_mp": max_mp,
			"skills": skills
		}
	
	static func _from_dict(data: Dictionary) -> CharacterData:
		var char = CharacterData.new(
			data.get("name", ""),
			data.get("hp", 0),
			data.get("max_hp", 100),
			data.get("skills", [])
		)
		return char

	static func _check_data(data: Dictionary) -> bool:
		if not data.has("name"):
			return false
		if not data.has("hp"):
			return false
		if not data.has("max_hp"):
			return false
		if not data.has("skills"):
			return false
		return true
		if not data.has("name"):
			return false
		if not data.has("hp"):
			return false
		if not data.has("max_hp"):
			return false
		if not data.has("skills"):
			return false
		return true

class PlayerData:
	extends CharacterData
	
	var avatar: String
	var level: int
	var mp: int
	var max_mp: int

	func _init(
			p_name : String = "",
			p_level : int = 0,
			p_avatar : String = "",
			p_hp : int = 0,
			p_max_hp : int = 0,
			p_mp : int = 0,
			p_max_mp : int = 0,
			p_skills : Array = [],
			) -> void:
		super(p_name, p_hp, p_max_hp, p_skills)
		avatar = p_avatar
		level = p_level
		mp = p_mp
		max_mp = p_max_mp
	
	func to_dict() -> Dictionary:
		var d := {}
		d["avatar"] = avatar
		d["level"] = level
		d["mp"] = mp
		d["max_mp"] = max_mp
		d.merge(super())
		return d
	
	static func _from_dict(data: Dictionary) -> PlayerData:
		var player = PlayerData.new(
			data.get("name", ""),
			data.get("level", 0),
			data.get("avatar", ""),
			data.get("hp", 0),
			data.get("max_hp", 100),
			data.get("mp", 0),
			data.get("max_mp", 0),
			data.get("skills", [])
			)
		return player

	static func _check_data(data: Dictionary) -> bool:
		if not super(data): return false
		if not data.has("level"):
			return false
		if not data.has("avatar"):
			return false
		if not data.has("mp"):
			return false
		if not data.has("max_mp"):
			return false
		return true

## 敌人数据结构
class EnemyData:
	extends CharacterData
	
	var description : String
	var level_range : Array
	
	func _init(
			p_name : String = "",
			p_level_range : Array = [0, 0],
			p_description : String = "",
			p_hp : int = 0,
			p_max_hp : int = 0,
			p_skills : Array = [],
			) -> void:
		super(p_name, p_hp, p_max_hp, p_skills)
		description = p_description
		level_range = p_level_range

	func to_dict() -> Dictionary:
		var d := {}
		d["description"] = description
		d["level_range"] = level_range
		d.merge(super())
		return d

	static func _from_dict(data: Dictionary) -> EnemyData:
		var enemy = EnemyData.new(
			data.get("name", ""),
			data.get("level_range", [0, 0]),
			data.get("description", ""),
			data.get("hp", 0),
			data.get("max_hp", 0),
			data.get("skills", [])
		)
		return enemy

	static func _check_data(data: Dictionary) -> bool:
		if not super(data): return false
		if not data.has("level_range"):
			return false
		if not data.has("description"):
			return false
		return true

## 场景数据结构
class GameSceneData:
	extends BaseData

	var player: PlayerData
	var enemy: EnemyData
	var turn_count: int
	var state: int

	func _init(
			p_player : PlayerData = PlayerData.new(),
			p_enemy : EnemyData = EnemyData.new(),
			p_turn_count : int = 1,
			p_state : int = 0
			) -> void:
		player = p_player
		enemy = p_enemy
		turn_count = p_turn_count
		state = p_state
	
	func to_dict() -> Dictionary:
		return {
			"player": player.to_dict(),
			"enemy": enemy.to_dict(),
			"turn_count": turn_count,
			"state": state
		}

	static func _from_dict(data: Dictionary) -> GameSceneData:
		if not data.has("player"):
			return null
		if not data.has("enemy"):
			return null
		if not data.has("turn_count"):
			return null
		if not data.has("state"):
			return null
		var scene_data = GameSceneData.new(
			CharacterData.from_dict(data.get("player", {})),
			CharacterData.from_dict(data.get("enemy", {})),
			data.get("turn_count", 1),
			data.get("state", 0)
		)
		return scene_data

	static func _check_data(data: Dictionary) -> bool:
		if not data.has("player"):
			return false
		if not data.has("enemy"):
			return false
		if not data.has("turn_count"):
			return false
		if not data.has("state"):
			return false
		return true

## 技能数据结构
class SkillData:
	extends BaseData

	var id: String
	var name: String
	var description: String
	var damage: int
	var mp_cost: int

	func _init(
			p_id : String = "",
			p_name : String = "",
			p_description : String = "",
			p_damage : int = 0,
			p_mp_cost : int = 0
			) -> void:
		id = p_id
		name = p_name
		description = p_description
		damage = p_damage
		mp_cost = p_mp_cost

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"description": description,
			"damage": damage,
			"mp_cost": mp_cost
		}
	
	static func _from_dict(data: Dictionary) -> SkillData:
		var skill = SkillData.new(
			data.get("id", ""),
			data.get("name", ""),
			data.get("description", ""),
			data.get("damage", 0),
			data.get("mp_cost", 0)
		)
		return skill

	static func _check_data(data: Dictionary) -> bool:
		if not data.has("id"):
			return false
		if not data.has("name"):
			return false
		if not data.has("description"):
			return false
		if not data.has("damage"):
			return false
		if not data.has("mp_cost"):
			return false
		return true

## 战斗日志数据结构
class BattleLogData:
	extends BaseData

	var type: String
	var text: String
	var color: String

	func _init(
			p_text: String, 
			p_type: String = "append", 
			p_color: String = "white"
			) -> void:
		type = p_type
		text = p_text
		color = p_color

	func to_dict() -> Dictionary:
		return {
			"type": type,
			"text": text,
			"color": color
		}

	## 将字典转换为战斗日志数据实例
	static func _from_dict(data: Dictionary) -> BattleLogData:
		var log = BattleLogData.new(
			data.get("text", ""),
			data.get("type", ""),
			data.get("color", "")
		)
		return log

	## 检查数据是否合法
	static func _check_data(data: Dictionary) -> bool:
		if data.has("text") and data.has("type") and data.has("color"):
			return true
		return false

## 数据结构基类
class BaseData:

	## 将数据实例转换为字典
	func to_dict() -> Dictionary:
		return {}
	
	## 将字典转换为数据实例
	static func from_dict(data: Dictionary) -> BaseData:
		if data.is_empty(): 
			push_error("[GameDataTypes] 数据为空")
			return null
		if not _check_data(data):
			push_error("[GameDataTypes] 数据不合法")
			return null
		return _from_dict(data)

	## 检查数据是否合法
	static func _check_data(data: Dictionary) -> bool:
		return true
	
	## 创建一个新的数据实例,子类需要重写此函数
	static func _from_dict(data: Dictionary) -> BaseData:
		return BaseData.new()