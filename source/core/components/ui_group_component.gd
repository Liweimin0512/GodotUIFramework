extends Node
class_name UIGroupComponent

## UI分组组件
## 提供场景分组和管理功能

# 信号
## 场景创建
signal scene_created(scene: Control)
## 场景销毁
signal scene_disposed(scene: Control)
## 场景切换
signal scene_switched(old_scene: Control, new_scene: Control)
## 场景隐藏
signal scene_hidden(scene: Control)
## 场景显示
signal scene_shown(scene: Control)

# 属性
## 分组ID
@export var group_name: StringName = &"":
	set(value):
		group_name = value
		if group_name:
			UIManager.register_group(group_name, self)
## 初始化时注册的view
@export var view_types : Array[UIViewType] = []

# 内部变量
var _current_scene: Control = null
var _scene_stack: Stack = Stack.new()

## 初始化
func _ready() -> void:
	if not group_name.is_empty():
		UIManager.register_group(group_name, self)
	for view_type in view_types:
		UIManager.register_view_type(view_type)

## 销毁
func _exit_tree() -> void:
	if not group_name.is_empty():
		UIManager.unregister_group(group_name)
	for view_type in view_types:
		UIManager.unregister_view_type(view_type)
	# 清理场景
	close_all_scenes()

## 创建场景
## [param id] 场景ID
## [param data] 场景数据
## [return] 创建的场景实例
func create_scene(id: StringName, data: Dictionary = {}) -> Control:
	var scene_type := UIManager.get_view_type(id) as UISceneType
	if not scene_type:
		push_error("Scene type not found: %s" % id)
		return null
	
	# 检查场景类型
	if scene_type.group_type == UISceneType.GROUP_TYPE.EXCLUSIVE:
		# 独占场景，关闭其他场景
		close_all_scenes()
	elif scene_type.group_type == UISceneType.GROUP_TYPE.ADDITIVE:
		# 叠加场景，根据配置处理其他场景
		if scene_type.hide_others:
			hide_other_scenes(null)  # 先隐藏其他场景
	
	# 创建场景
	var scene = UIManager.create_view(id, get_parent(), data)
	if not scene:
		push_error("Failed to create scene: %s" % id)
		return null

	var view_component := UIManager.get_view_component(scene)
	if not view_component:
		push_error("Failed to get view component: %s" % id)
		return null

	view_component.set("_group", self)	

	# 处理场景堆栈
	_scene_stack.push(scene)
	_current_scene = scene
	
	scene_created.emit(scene)
	return scene

## 关闭场景
## [param scene] 要关闭的场景
func close_scene(scene: Control) -> void:
	if not scene:
		return
	
	# 从场景堆栈中移除
	var scenes := _scene_stack.to_array()
	scenes.erase(scene)
	_scene_stack.clear()
	for s in scenes:
		_scene_stack.push(s)
	
	# 更新当前场景
	if scene == _current_scene:
		_current_scene = _scene_stack.peek()
	
	# 销毁场景
	var component = UIManager.get_view_component(scene)
	if component:
		component.dispose()
	scene.queue_free()
	
	scene_disposed.emit(scene)

## 切换场景
## [param id] 场景ID
## [param data] 场景数据
## [return] 创建的场景实例
func switch_scene(id: StringName, data: Dictionary = {}) -> Control:
	var old_scene = _current_scene
	
	# 创建新场景
	var new_scene = create_scene(id, data)
	if not new_scene:
		return null
	
	# 关闭旧场景
	if old_scene:
		close_scene(old_scene)
	
	scene_switched.emit(old_scene, new_scene)
	return new_scene

## 添加场景
## [param scene] 要添加的场景
func add_scene(scene: Control) -> void:
	if not scene:
		return
	
	_scene_stack.push(scene)
	_current_scene = scene
	scene_created.emit(scene)

## 隐藏其他场景
## [param except] 不隐藏的场景
func hide_other_scenes(except: Control) -> void:
	for scene in _scene_stack.to_array():
		if scene != except:
			scene.hide()
			scene_hidden.emit(scene)
		else:
			scene.show()
			scene_shown.emit(scene)

## 显示其他场景
func show_other_scenes() -> void:
	for scene in _scene_stack.to_array():
		if not scene.visible:
			scene.show()
			scene_shown.emit(scene)

## 关闭所有场景
func close_all_scenes() -> void:
	while not _scene_stack.is_empty:
		var scene = _scene_stack.pop()
		if scene:
			var component = UIManager.get_view_component(scene)
			if component:
				component.dispose()
			scene.queue_free()
			scene_disposed.emit(scene)
	
	_current_scene = null

## 获取当前场景
## [return] 当前场景
func get_current_scene() -> Control:
	return _current_scene

## 获取场景堆栈
## [return] 场景堆栈
func get_scene_stack() -> Array[Control]:
	return _scene_stack.to_array()

## 获取场景数量
## [return] 场景数量
func get_scene_count() -> int:
	return _scene_stack.size
