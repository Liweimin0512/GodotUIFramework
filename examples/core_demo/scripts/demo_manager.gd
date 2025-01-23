extends Node

# demo_manager.gd
func _ready() -> void:
	# 初始化UI框架
	await UIManager.initialize()
	
	# 预加载常用资源
	await _preload_resources()
	
	# 注册场景
	_register_scenes()
	
	# 切换到登录场景
	await UIManager.scene_manager.switch_scene("login")

func _register_scenes() -> void:
	UIManager.scene_manager.register_scene("login", "res://scenes/login_scene.tscn")
	UIManager.scene_manager.register_scene("lobby", "res://scenes/lobby_scene.tscn")
	UIManager.scene_manager.register_scene("game", "res://scenes/game_scene.tscn")

func _preload_resources() -> void:
	pass
