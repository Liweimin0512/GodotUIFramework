extends Node2D

## 登录场景：基础UI交互

# login_scene.gd
func _show_loading() -> void:
	# 显示加载界面
	var loading = await UIManager.widget_manager.create_widget("loading")
	loading.show()
	
	# 模拟加载过程
	await get_tree().create_timer(2.0).timeout
	
	# 隐藏加载界面
	loading.hide()
	UIManager.widget_manager.recycle_widget(loading)
