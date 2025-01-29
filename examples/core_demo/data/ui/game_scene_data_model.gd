extends UIDataModel
class_name GameSceneDataModel

## 游戏场景数据模型
## 负责管理游戏场景数据的UI绑定

var _player_model: PlayerDataModel
var _enemy_model: EnemyDataModel
var _turn_count: int = 0
var _state: int = 0

func _init(
			player_model: PlayerDataModel = null,
			enemy_model: EnemyDataModel = null,
			turn_count : int = 0,
			state : int = 0
		) -> void:
	data_paths = ["turn_count", "state"]
	validate_data = true
	
	_player_model = player_model
	_enemy_model = enemy_model
	_turn_count = turn_count
	_state = state
	
	# 监听子模型变化
	_player_model.value_changed.connect(_on_player_changed)
	_enemy_model.value_changed.connect(_on_enemy_changed)

## 验证属性值
func _validate_property_value(property: String, value: Variant) -> bool:
	match property:
		"turn_count":
			return value is int and value >= 0
		"state":
			return value is int
	return true

## 筛选数据
func _filter_data(data: Dictionary) -> Dictionary:
	return {
		"turn_count": _turn_count,
		"state": _state
	}

## 更新场景数据
func update_scene(scene_data: GameSceneData) -> void:
	_player_model = scene_data.player
	_enemy_model = scene_data.enemy
	_turn_count = scene_data.turn_count
	var model = get_script().new(_player_model, _enemy_model, _turn_count, _state)
	update(model)

## 获取玩家数据模型
func get_player_model() -> PlayerDataModel:
	return _player_model

## 获取敌人数据模型
func get_enemy_model() -> EnemyDataModel:
	return _enemy_model

## 处理玩家数据变化
func _on_player_changed(property: String, old_value: Variant, new_value: Variant) -> void:
	match property:
		"hp":
			_scene.player.hp = new_value
		"mp":
			_scene.player.mp = new_value
		"max_hp":
			_scene.player.max_hp = new_value
		"max_mp":
			_scene.player.max_mp = new_value
		"skills":
			_scene.player.skills = new_value

## 处理敌人数据变化
func _on_enemy_changed(property: String, old_value: Variant, new_value: Variant) -> void:
	match property:
		"hp":
			_scene.enemy.hp = new_value
		"max_hp":
			_scene.enemy.max_hp = new_value
		"skills":
			_scene.enemy.skills = new_value
