extends UIViewComponent

## 技能按钮容器组件
## 负责管理技能按钮列表

#@onready var button_container = $GridContainer
#
## 按钮场景
#const SkillButtonScene = preload("res://addons/GodotUIFramework/source/widgets/game/skill_button.tscn")
#
#func _initialized(data: Dictionary) -> void:
	## 监听属性变化
	#watch("skills.available", _on_skills_changed)
	#
	## 初始更新
	#_update_skills(get_value("skills.available", []))
#
### 处理技能列表变化
#func _on_skills_changed(old_value: Array, new_value: Array) -> void:
	#_update_skills(new_value)
#
### 更新技能按钮
#func _update_skills(skills: Array) -> void:
	## 清除旧按钮
	#for child in button_container.get_children():
		#child.queue_free()
	#
	## 添加新按钮
	#for skill in skills:
		#var button = SkillButtonScene.instantiate()
		#button_container.add_child(button)
		#button.initialize({
			#"skill": skill
		#})

func _on_ui_widget_component_initialized(data: Dictionary) -> void:
	pass # Replace with function body.
