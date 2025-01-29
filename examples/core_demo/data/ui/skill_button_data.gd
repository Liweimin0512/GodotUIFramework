extends UIDataModel
class_name SkillButtonData

## 技能按钮数据模型
## 负责处理技能按钮的状态数据

# 技能属性
var skill_id: String:
	get:
		return get_value("skill.id", "")
	set(value):
		set_value("skill.id", value)

var skill_name: String:
	get:
		return get_value("skill.name", "")
	set(value):
		set_value("skill.name", value)

var skill_description: String:
	get:
		return get_value("skill.description", "")
	set(value):
		set_value("skill.description", value)

var skill_cost: int:
	get:
		return get_value("skill.cost", 0)
	set(value):
		set_value("skill.cost", value)

var skill_enabled: bool:
	get:
		return get_value("skill.enabled", true)
	set(value):
		set_value("skill.enabled", value)

func _init() -> void:
	# 配置数据路径
	data_paths = ["skill"]
	validate_data = true

## 验证属性值
func _validate_property_value(property: String, value: Variant) -> bool:
	match property:
		"skill.id", "skill.name", "skill.description":
			return value is String
		"skill.cost":
			return value is int and value >= 0
		"skill.enabled":
			return value is bool
	return true

## 筛选数据
func _filter_data(data: Dictionary) -> Dictionary:
	var skill = data.get("skill", {})
	return {
		"skill": {
			"id": skill.get("id", ""),
			"name": skill.get("name", ""),
			"description": skill.get("description", ""),
			"cost": skill.get("cost", 0),
			"enabled": skill.get("enabled", true)
		}
	}
