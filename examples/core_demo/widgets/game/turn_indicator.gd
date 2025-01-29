extends UIViewComponent

## 回合指示器组件
## 负责显示当前回合和行动角色

@onready var turn_label = $TurnLabel
@onready var character_label = $CharacterLabel

#func _initialized(data: Dictionary) -> void:
	## 监听属性变化
	#watch("turn.index", _on_turn_index_changed)
	#watch("turn.character", _on_turn_character_changed)
	#
	## 初始更新
	#_update_turn_label(get_value("turn.index", 1))
	#_update_character_label(get_value("turn.character", "player"))
#
### 处理回合索引变化
#func _on_turn_index_changed(old_value: int, new_value: int) -> void:
	#_update_turn_label(new_value)
#
### 处理当前角色变化
#func _on_turn_character_changed(old_value: String, new_value: String) -> void:
	#_update_character_label(new_value)
#
### 更新回合标签
#func _update_turn_label(turn: int) -> void:
	#turn_label.text = "回合 %d" % turn
#
### 更新角色标签
#func _update_character_label(character: String) -> void:
	#character_label.text = "当前行动: %s" % character.capitalize()
