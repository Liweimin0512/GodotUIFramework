extends UIDataModel
class_name CharacterDataModel

## 角色数据模型
## 负责管理角色数据的UI绑定

var character_name : StringName = ""
var hp : int = 0
var max_hp : int = 0
var skills : Array[Ability] = []

func _init(
		p_name : String = "",
		p_hp : int = 0,
		p_max_hp : int = 0,
		p_skills : Array = [],
	) -> void:
	data_paths = ["name", "hp", "max_hp", "skills"]
	validate_data = true

	character_name = p_name
	hp = p_hp
	max_hp = p_max_hp
	skills = p_skills

## 验证属性值
func _validate_property_value(property: String, value: Variant) -> bool:
	match property:
		"name":
			return value is StringName
		"hp", "max_hp":
			return value is int and value >= 0
		"skills":
			return value is Array
	return true

## 筛选数据
func _filter_data(data: Dictionary) -> Dictionary:
	return data.character
