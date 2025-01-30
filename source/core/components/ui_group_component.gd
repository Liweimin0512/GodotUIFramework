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
## 场景隐藏
signal scene_hidden(scene: Control)
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
## 是否缓存场景实例
@export var cache_scenes: bool = true

# 内部变量
## 场景实例字典
var _scenes : Dictionary[StringName, Control] = {}
## 场景堆栈（用于记录显示顺序）
var _scene_stack: Array[StringName] = []
## 缓存的场景
var _cached_scenes: Dictionary[StringName, Control] = {}

## 当前场景
var _current_scene: Control = null:
	get:
		return _scenes[_scene_stack[-1]] if not _scene_stack.is_empty() else null
	set(_value):
		push_error("can not set _current_scene")

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
	
	var scene: Control = null
	var view_component: UISceneComponent = null
	
	# 检查是否有缓存的场景
	if cache_scenes and _cached_scenes.has(id):
		scene = _cached_scenes[id]
		_cached_scenes.erase(id)
		view_component = UIManager.get_view_component(scene)
		view_component._on_showing()
	else:
		scene = UIManager.create_view(id, get_parent(), data)
		if not scene:
			push_error("can not create scene {0} in group {1}".format([id, group_name]))
			return null
		view_component = UIManager.get_view_component(scene)
		if not view_component:
			push_error("can not get view component from scene {0} in group {1}".format([id, group_name]))
			return null
		# 将分组注入view_component
		view_component.set("_group", self)
		view_component._on_showing()
	
	# 处理当前场景
	if _current_scene:
		var current_id = _scene_stack[-1]
		var current_component = UIManager.get_view_component(_current_scene)
		if current_component:
			current_component._on_hiding()
		
		if group_type == GROUP_TYPE.EXCLUSIVE or scene_type.hide_others:
			# 如果是互斥组或需要隐藏其他场景，则隐藏当前场景
			_hide_scene(current_id, _current_scene)
	
	# 添加新场景到堆栈
	_scenes[id] = scene
	_scene_stack.push_back(id)
	
	scene.show()
	view_component._on_shown()
	scene_shown.emit(scene)
	return scene

## 返回上一个场景
func back_to_previous() -> void:
	if _scene_stack.size() <= 1:
		# 如果只有一个或没有场景，则关闭当前场景
		close_current_scene()
		return
	
	# 获取当前场景
	var current_id = _scene_stack[-1]
	var current_scene = _scenes[current_id]
	var current_component = UIManager.get_view_component(current_scene)
	
	if current_component:
		current_component._on_closing()
	
	# 移除当前场景
	_scenes.erase(current_id)
	_scene_stack.pop_back()
	
	if cache_scenes:
		_cached_scenes[current_id] = current_scene
		current_scene.hide()
		if current_component:
			current_component._on_hidden()
	else:
		UIManager.dispose_view(current_scene)
		if current_component:
			current_component._on_closed()
	
	scene_closed.emit(current_scene)
	
	# 显示上一个场景
	var prev_id = _scene_stack[-1]
	var prev_scene = _scenes[prev_id]
	var prev_component = UIManager.get_view_component(prev_scene)
	
	if prev_component:
		prev_component._on_showing()
	prev_scene.show()
	if prev_component:
		prev_component._on_shown()
	scene_shown.emit(prev_scene)

## 隐藏场景
func _hide_scene(id: StringName, scene: Control) -> void:
	var component = UIManager.get_view_component(scene)
	_scenes.erase(id)
	
	if cache_scenes:
		_cached_scenes[id] = scene
		scene.hide()
		if component:
			component._on_hidden()
	else:
		UIManager.dispose_view(scene)
		if component:
			component._on_closed()
	
	scene_hidden.emit(scene)

## 关闭指定场景
func close_scene(scene: Control) -> void:
	if not scene:
		return
	
	var scene_id := _scenes.find_key(scene)
	if scene_id == null:
		scene_id = _cached_scenes.find_key(scene)
		if scene_id != null:
			_cached_scenes.erase(scene_id)
	else:
		_scenes.erase(scene_id)
		_scene_stack.erase(scene_id)
	
	if scene_id != null:
		var component = UIManager.get_view_component(scene)
		if component:
			component._on_closing()
		UIManager.dispose_view(scene)
		if component:
			component._on_closed()
		scene_closed.emit(scene)

## 关闭所有场景
func close_all_scenes() -> void:
	# 关闭所有显示的场景
	for id in _scene_stack:
		var scene = _scenes[id]
		var component = UIManager.get_view_component(scene)
		if component:
			component._on_closing()
		UIManager.dispose_view(scene)
		if component:
			component._on_closed()
		scene_closed.emit(scene)
	
	_scenes.clear()
	_scene_stack.clear()
	
	# 关闭所有缓存的场景
	for scene in _cached_scenes.values():
		var component = UIManager.get_view_component(scene)
		if component:
			component._on_closing()
		UIManager.dispose_view(scene)
		if component:
			component._on_closed()
		scene_closed.emit(scene)
	
	_cached_scenes.clear()
	all_scene_closed.emit()

## 关闭当前场景
func close_current_scene() -> void:
	if not _current_scene:
		return
	close_scene(_current_scene)

#endregion 公共接口
