extends UIViewComponent

## 战斗日志容器组件
## 负责显示战斗过程中的日志信息

#@onready var log_container = $ScrollContainer/VBoxContainer
#
#func _initialized(data: Dictionary) -> void:
	## 监听属性变化
	#watch("battle.logs", _on_logs_changed)
	#
	## 初始更新
	#_update_logs(get_value("battle.logs", []))
#
### 处理日志变化
#func _on_logs_changed(old_value: Array, new_value: Array) -> void:
	#_update_logs(new_value)
#
### 更新日志显示
#func _update_logs(logs: Array) -> void:
	## 清除旧日志
	#for child in log_container.get_children():
		#child.queue_free()
	#
	## 添加新日志
	#for log in logs:
		#var label = Label.new()
		#label.text = log
		#log_container.add_child(label)
	#
	## 滚动到底部
	#await get_tree().process_frame
	#log_container.get_parent().scroll_vertical = log_container.get_parent().get_v_scroll_bar().max_value


func _on_initialized(data: Dictionary) -> void:
	pass # Replace with function body.
