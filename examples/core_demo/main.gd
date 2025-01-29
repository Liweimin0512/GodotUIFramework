extends CanvasLayer

## 启动场景：框架初始化

@onready var ui_group_component: UIGroupComponent = $UIGroupComponent

# 使用示例
func _ready() -> void:
	#UIManager.scene_manager.create_scene("login_scene")
	ui_group_component.show_scene("login_scene")
