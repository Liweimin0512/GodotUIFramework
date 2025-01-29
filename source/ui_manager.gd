@tool
extends Node

## UI管理器
## 负责管理UI资源、视图、数据和分组

#region 信号
signal view_registered(view_type: UIViewType)
signal view_unregistered(id: StringName)
signal group_registered(name: StringName, group: UIGroupComponent)
signal group_unregistered(name: StringName)
signal component_registered(component: UIViewComponent)
signal component_unregistered(component: UIViewComponent)
signal data_updated(model: UIDataModel, property: String, old_value: Variant, new_value: Variant)
#endregion

#region 内部变量
## 视图类型字典
var _view_types: Dictionary = {}
## 分组字典
var _groups: Dictionary = {}
## 资源管理器
var _resource_manager: UIResourceManager
## 视图组件缓存
var _components : Dictionary
#endregion

#region 初始化
func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resource_manager = UIResourceManager.new()

func _process(delta: float) -> void:
	_resource_manager.process(delta)
#endregion

#region 视图管理

## 注册视图类型
func register_view_type(view_type: UIViewType) -> void:
	if _view_types.has(view_type.ID):
		push_warning("View type already registered: %s" % view_type.ID)
		return
		
	_view_types[view_type.ID] = view_type
	view_registered.emit(view_type)
	
	# 处理预加载
	if view_type.preload_mode == UIViewType.PRELOAD_MODE.PRELOAD:
		_resource_manager.load_resource(view_type.scene_path, UIResourceManager.LoadMode.IMMEDIATE)
	elif view_type.preload_mode == UIViewType.PRELOAD_MODE.LAZY_LOAD:
		_resource_manager.load_resource(view_type.scene_path, UIResourceManager.LoadMode.LAZY)

## 视图类型取消注册
func unregister_view_type(view_type: UIViewType) -> void:
	if not _view_types.has(view_type.ID):
		push_warning("View type not registered: %s" % view_type.ID)
		return
		
	_view_types.erase(view_type.ID)
	view_unregistered.emit(view_type.ID)

## 获取视图类型
func get_view_type(id: StringName) -> UIViewType:
	return _view_types.get(id)

## 创建视图实例
func create_view(id: StringName, parent: Node, data: Dictionary = {}) -> Control:
	var view_type := get_view_type(id)
	if not view_type:
		push_error("View type not found: %s" % id)
		return null
	
	# 加载场景资源
	var scene_res := _resource_manager.get_cached_resource(view_type.scene_path) as PackedScene
	if not scene_res:
		# 如果缓存中没有，尝试立即加载
		scene_res = _resource_manager.load_resource(view_type.scene_path, UIResourceManager.LoadMode.IMMEDIATE)
		if not scene_res:
			push_error("Failed to load scene: %s" % view_type.scene_path)
			return null
	
	# 实例化场景
	var instance = get_from_pool(view_type.ID)
	if not instance:
		instance = scene_res.instantiate()
	if not instance is Control:
		push_error("Scene instance is not a Control node: %s" % view_type.scene_path)
		instance.free()
		return null

	# 初始化视图组件
	var component : UIViewComponent = get_view_component(instance)
	if not component:
		push_error("View has no view component: %s" % instance)
		return null
	_components[instance] = component
	component.config = view_type
	
	# 添加到父节点
	if parent:
		parent.add_child(instance)
	
	component.initialize(data)
	
	return instance

## 移除视图实例
func dispose_view(view: Node) -> void:
	var view_component := get_view_component(view)
	if not view_component:
		push_error("View has no view component: %s" % view)
		return
	var config = view_component.config
	if not config:
		push_error("view has no config: %s" % view)
		return
	view_component.dispose()
	recycle_to_pool(config.ID, view)

## 获取视图组件
func get_view_component(view: Node) -> UIViewComponent:
	if not view:
		push_error("View node is null")
		return null
	
	if _components.has(view):
		if _components[view] is UIViewComponent:
			return _components[view]
	
	for child in view.get_children():
		if child is UIViewComponent:
			_components[view] = child
			return child
	
	#push_error("View has no view component: %s" % view)
	return null

## 清理组件缓存
func clear_component_cache(view: Node = null) -> void:
	if view:
		_components.erase(view)
	else:
		_components.clear()

## 判断是否为view
func is_view_node(node: Node) -> bool:
	if get_view_component(node):
		return true
	#push_warning("Node is not a view: %s" % node)
	return false

## 判断是否为view component
func is_view_component(component: Node) -> bool:
	var view_component := get_view_component(component.get_parent())
	if view_component:
		return true
	push_warning("Node is not a view component: %s" % component)
	return false

#endregion

#region 分组管理
## 注册分组
func register_group(name: StringName, group: UIGroupComponent) -> void:
	_groups[name] = group
	group_registered.emit(name, group)

## 取消注册分组
func unregister_group(name: StringName) -> void:
	if not _groups.has(name):
		push_warning("Group not registered: %s" % name)
		return
	
	_groups.erase(name)
	group_unregistered.emit(name)

## 获取分组
func get_group(name: StringName) -> UIGroupComponent:
	return _groups.get(name)

#endregion

#region 资源管理
## 加载资源
func load_resource(path: String, mode: UIResourceManager.LoadMode = UIResourceManager.LoadMode.IMMEDIATE) -> Resource:
	return _resource_manager.load_resource(path, mode)

## 获取缓存资源
func get_cached_resource(path: String) -> Resource:
	return _resource_manager.get_cached_resource(path)

## 清理资源缓存
func clear_resource_cache(path: String = "") -> void:
	_resource_manager.clear_resource_cache(path)

## 从对象池获取实例
func get_from_pool(id: StringName) -> Node:
	var view_type := get_view_type(id)
	if not view_type:
		push_error("View type not found: %s" % id)
		return null
	if view_type.cache_mode != UIViewType.CACHE_MODE.CACHE_IN_MEMORY:
		var view = load_resource(view_type.scene_path).instantiate()
		return view
	return _resource_manager.get_instance(id)

## 回收实例到对象池
func recycle_to_pool(id: StringName, instance: Node) -> void:
	var view_type := get_view_type(id)
	if not view_type:
		push_error("View type not found: %s" % id)
		return
	if view_type.cache_mode != UIViewType.CACHE_MODE.CACHE_IN_MEMORY:
		instance.get_parent().remove_child(instance)
		instance.queue_free()
	else:
		if _resource_manager.get_instance_count(id) < view_type.pool_capacity:
			_resource_manager.recycle_instance(id, instance)
#endregion
