extends CharacterDataModel
class_name PlayerDataModel

## 玩家数据模型
## 负责管理玩家数据的UI绑定

var _player: GameDataTypes.PlayerData

func _init(player: GameDataTypes.PlayerData = null) -> void:
	_player = player if player else GameDataTypes.PlayerData.new()
	_character = _player
	data_paths = ["name", "hp", "max_hp", "skills", "avatar", "level", "mp", "max_mp"]
	validate_data = true

## 验证属性值
func _validate_property_value(property: String, value: Variant) -> bool:
	match property:
		"avatar":
			return value is String
		"level", "mp", "max_mp":
			return value is int and value >= 0
		_:
			return super(property, value)

## 筛选数据
func _filter_data(data: Dictionary) -> Dictionary:
	return _player.to_dict()

## 更新玩家数据
func update_player(player: GameDataTypes.PlayerData) -> void:
	_player = player
	_character = player
	var model = get_script().new(player)
	update(model)
