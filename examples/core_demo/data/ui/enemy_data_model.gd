extends CharacterDataModel
class_name EnemyDataModel

## 敌人数据模型
## 负责管理敌人数据的UI绑定

var _enemy: GameDataTypes.EnemyData

func _init(enemy: GameDataTypes.EnemyData = null) -> void:
	_enemy = enemy if enemy else GameDataTypes.EnemyData.new()
	_character = _enemy
	data_paths = ["name", "hp", "max_hp", "skills", "description", "level_range"]
	validate_data = true

## 验证属性值
func _validate_property_value(property: String, value: Variant) -> bool:
	match property:
		"description":
			return value is String
		"level_range":
			return value is Array and value.size() == 2
		_:
			return super(property, value)

## 筛选数据
func _filter_data(data: Dictionary) -> Dictionary:
	return _enemy.to_dict()

## 更新敌人数据
func update_enemy(enemy: GameDataTypes.EnemyData) -> void:
	_enemy = enemy
	_character = enemy
	var model = get_script().new(enemy)
	update(model)
