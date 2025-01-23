extends Node2D

## 大厅场景：复杂UI布局

# lobby_scene.gd
func _load_news_panel() -> void:
	# 异步加载新闻面板
	var panel = await UIManager.resource_manager.load_scene(
		"res://widgets/lobby/news_panel.tscn",
		UIResourceManager.LoadMode.LAZY
	)
	
	# 创建实例并显示
	var instance = panel.instantiate()
	add_child(instance)
