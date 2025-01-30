extends UIViewComponent

## 角色状态组件
## 负责显示角色的HP和MP状态

#@onready var hp_bar = $HPBar
#@onready var mp_bar = $MPBar
#@onready var name_label = $NameLabel
#
## 数据模型
#var _status_data: CharacterStatusData
#
#func _ready() -> void:
	#super._ready()
	#
	## 创建数据模型
	#_status_data = CharacterStatusData.new()
	#_data_model = _status_data
#
#func _initialized(data: Dictionary) -> void:
	## 监听属性变化
	#watch("status.hp", _on_hp_changed)
	#watch("status.mp", _on_mp_changed)
	#watch("status.max_hp", _on_max_hp_changed)
	#watch("status.max_mp", _on_max_mp_changed)
	#
	## 初始更新
	#_update_hp_bar(get_value("status.hp", 100), get_value("status.max_hp", 100))
	#_update_mp_bar(get_value("status.mp", 50), get_value("status.max_mp", 100))
#
### 处理HP变化
#func _on_hp_changed(old_value: int, new_value: int) -> void:
	#_update_hp_bar(new_value, _status_data.max_hp)
#
### 处理MP变化
#func _on_mp_changed(old_value: int, new_value: int) -> void:
	#_update_mp_bar(new_value, _status_data.max_mp)
#
### 处理最大HP变化
#func _on_max_hp_changed(old_value: int, new_value: int) -> void:
	#_update_hp_bar(_status_data.hp, new_value)
#
### 处理最大MP变化
#func _on_max_mp_changed(old_value: int, new_value: int) -> void:
	#_update_mp_bar(_status_data.mp, new_value)
#
### 更新HP进度条
#func _update_hp_bar(current: int, maximum: int) -> void:
	#hp_bar.max_value = maximum
	#hp_bar.value = current
#
### 更新MP进度条
#func _update_mp_bar(current: int, maximum: int) -> void:
	#mp_bar.max_value = maximum
	#mp_bar.value = current


func _on_ui_widget_component_initialized(data: Dictionary) -> void:
	pass # Replace with function body.
