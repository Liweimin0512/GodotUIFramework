extends UIViewManager
class_name UISceneManager

## UI场景管理器
## 负责管理UI场景的创建、销毁和分组管理

## 场景创建信号
signal scene_created(scene_id: StringName, scene: Control)
## 场景关闭信号
signal scene_closed(scene_id: StringName, scene: Control)
## 分组场景变化信号
signal group_stack_changed(group_id: StringName, current_scene: Control)

## 分组场景栈
var _group_stacks: Dictionary[StringName, Stack] = {}

## 创建场景
## [param id] 场景ID
## [param data] 初始化数据
## [return] 创建的场景实例
func create_scene(id: StringName, data: Dictionary = {}) -> Control:
	# 获取场景类型
	var scene_type = get_view_type(id) as UISceneType
	if not scene_type:
		push_error("[UISceneManager] Scene type not found: %s" % id)
		return null
	
	# 验证场景配置
	if not scene_type.validate():
		push_error("[UISceneManager] Invalid scene type configuration: %s" % id)
		return null
	
	# 获取父节点
	var parent = _get_scene_parent(scene_type)
	if not parent:
		push_error("[UISceneManager] Cannot find parent for scene: %s" % id)
		return null
	
	# 创建场景实例
	var scene = super.create_view(id, parent, data) as Control
	if not scene:
		return null
	
	# 获取场景组件
	var component = UIManager.get_scene_component(scene)
	if not component:
		push_error("[UISceneManager] Scene component not found: %s" % id)
		scene.queue_free()
		return null
	
	# 设置场景配置
	component.config = scene_type
	
	# 处理分组堆栈
	if not scene_type.group_id.is_empty():
		_push_to_group_stack(scene_type.group_id, scene)
	
	# 发送创建信号
	scene_created.emit(id, scene)
	
	return scene

## 关闭场景
## [param scene] 要关闭的场景
func close_scene(scene: Control) -> void:
	if not scene:
		return
	
	var component = UIManager.get_scene_component(scene)
	if not component:
		scene.queue_free()
		return
	
	# 获取场景ID
	var scene_id = get_view_id(scene)
	
	# 从分组堆栈中移除
	if component.config:
		var group_id = component.config.group_id
		if not group_id.is_empty():
			_pop_from_group_stack(group_id, scene)
	
	# 发送关闭信号
	scene_closed.emit(scene_id, scene)
	
	# 销毁场景
	destroy_view(scene)

## 切换到指定场景
## [param id] 场景ID
## [param data] 初始化数据
## [return] 创建的场景实例
func switch_scene(id: StringName, data: Dictionary = {}) -> Control:
	var scene_type = get_view_type(id) as UISceneType
	if not scene_type:
		push_error("[UISceneManager] Scene type not found: %s" % id)
		return null
	
	# 如果有分组，关闭同组其他场景
	if not scene_type.group_id.is_empty():
		close_group_scenes(scene_type.group_id)
	
	return create_scene(id, data)

## 注册场景类型
## [param scene_type] 场景类型配置
func register_scene_type(scene_type: UISceneType) -> void:
	if not scene_type:
		push_error("[UISceneManager] Cannot register null scene type")
		return
		
	if not scene_type.validate():
		push_error("[UISceneManager] Invalid scene type configuration")
		return
		
	super.register_view_type(scene_type)

## 获取分组当前场景
## [param group_id] 分组ID
## [return] 当前显示的场景
func get_group_current_scene(group_id: StringName) -> Control:
	if not _group_stacks.has(group_id):
		return null
	if _group_stacks[group_id].is_empty:
		return null
	return _group_stacks[group_id].peek()

## 获取分组场景堆栈
## [param group_id] 分组ID
## [return] 场景堆栈
func get_group_stack(group_id: StringName) -> Stack:
	if not _group_stacks.has(group_id):
		_group_stacks[group_id] = Stack.new()
	return _group_stacks[group_id]

## 关闭分组所有场景
## [param group_id] 分组ID
func close_group_scenes(group_id: StringName) -> void:
	if not _group_stacks.has(group_id):
		return
		
	var stack : Stack = _group_stacks[group_id]
	while not stack.is_empty:
		var scene = stack.pop()
		if scene:
			close_scene(scene)
			
	group_stack_changed.emit(group_id, null)

## 获取场景组件
## [param scene] 场景节点
## [return] 场景组件
func get_scene_component(scene: Control) -> UISceneComponent:
	return UIManager.get_scene_component(scene)

## 获取场景父节点
func _get_scene_parent(scene_type: UISceneType) -> Node:
	if not scene_type.group_id.is_empty():
		var group := UIManager.get_group(scene_type.group_id)
		if group:
			return group.ui_root
	return UIManager.get_view_root()

## 将场景压入分组堆栈
func _push_to_group_stack(group_id: StringName, scene: Control) -> void:
	if not _group_stacks.has(group_id):
		_group_stacks[group_id] = Stack.new()
	
	var stack = _group_stacks[group_id]
	var component = UIManager.get_scene_component(scene)
	
	# 如果需要隐藏其他场景
	if component and component.config.hide_others:
		if not stack.is_empty:
			var current = stack.peek()
			if current:
				current.hide()
	
	stack.push(scene)
	group_stack_changed.emit(group_id, scene)

## 从分组堆栈移除场景
func _pop_from_group_stack(group_id: StringName, scene: Control) -> void:
	if not _group_stacks.has(group_id):
		return
		
	var stack = _group_stacks[group_id]
	if stack.is_empty: return
	if stack.peek() == scene:
		stack.pop()
		# 显示上一个场景
		var previous = stack.peek()
		if previous:
			previous.show()
		group_stack_changed.emit(group_id, previous)

## 获取场景数据
## [param scene] 场景实例
## [return] 场景数据
func get_scene_data(scene: Control) -> Dictionary:
	return get_view_data(scene)

## 更新场景数据
## [param scene] 场景实例
## [param data] 更新的数据
func update_scene_data(scene: Control, data: Dictionary) -> void:
	update_view_data(scene, data)
