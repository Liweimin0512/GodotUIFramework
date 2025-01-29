@tool
extends Node
class_name UIGroupComponent

## UI分组组件
## 提供场景分组和管理功能

## 分组类型
enum GROUP_TYPE {
	EXCLUSIVE,     # 互斥组（同时只能显示一个场景）
	ADDITIVE,      # 叠加组（可以同时显示多个场景）
}

## 场景显示
signal scene_shown(scene: Control)
## 场景关闭
signal scene_closed(scene: Control)
## 所有场景关闭
signal all_scene_closed()

# 属性
## 分组ID
@export var group_name: StringName = &"":
	set(value):
		group_name = value
		if group_name:
			UIManager.register_group(group_name, self)
## 初始化时注册的view
@export var view_types : Array[UIViewType] = []
## 分组类型
@export var group_type: GROUP_TYPE = GROUP_TYPE.EXCLUSIVE

# 内部变量
## 当前场景
var _current_scene: Control = null:
	get:
		return _scenes.values()[-1]
	set(_value):
		push_error("can not set _current_scene")
## 场景
var _scenes : Dictionary[StringName, Control] = {}

#region 生命周期

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	if group_name.is_empty():
		push_error("group_name is empty")
		return
	UIManager.register_group(group_name, self)
	for view_type in view_types:
		UIManager.register_view_type(view_type)

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	if group_name.is_empty():
		return
	UIManager.unregister_group(group_name)
	for view_type in view_types:
		UIManager.unregister_view_type(view_type)

#endregion

#region 公共接口

## 显示场景
## [param id] 场景类型ID
## [param data] 场景数据
## [returns] 创建的场景实例
func show_scene(id: StringName, data: Dictionary = {}) -> Control:
	# 根据配置数据选择显示规则
	var scene_type : UISceneType = UIManager.get_view_type(id) as UISceneType
	if not scene_type:
		push_error("Scene type not found: %s" % id)
		return null
	
	## 检查场景类型
	if group_type == GROUP_TYPE.EXCLUSIVE:
		# 互斥组，关闭当前场景
		close_all_scenes()
	elif scene_type.hide_others:
		# 叠加组，并且scene_type设置为hide_others，隐藏其他场景
		close_all_scenes()
	var scene: Control = _scenes.get(id)
	if scene:
		_scenes.erase(id)
	else:
		scene = UIManager.create_view(id, get_parent(), data)
	if not scene:
		push_error("can not create scene {0} in group {1}".format([id, group_name]))
		return null
	
	var view_component := UIManager.get_view_component(scene)
	if not view_component:
		push_error("can not get view component from scene {0} in group {1}".format([id, group_name]))
		return null
	# 将分组注入view_component
	view_component.set("_group", self)

	# 处理场景堆栈
	_scenes[id] = scene
	scene.show()
	scene_shown.emit(scene)
	return scene

## 关闭指定场景
func close_scene(scene: Control) -> void:
	if not scene:
		push_error("can not close scene, scene is null")
		return
	var scene_id := _scenes.find_key(scene)
	if scene_id == null:
		push_error("can not close scene, scene is not in group")
		return

	# 关闭场景
	UIManager.dispose_view(scene)
	_scenes.erase(scene_id)
	scene_closed.emit(scene)

## 关闭所有场景
func close_all_scenes() -> void:
	for scene in _scenes.values():
		close_scene(scene)
	all_scene_closed.emit()

## 关闭当前场景
func close_current_scene() -> void:
	if not _current_scene: 
		push_warning("No current scene to close")
		return
	close_scene(_current_scene)	

#endregion 公共接口
