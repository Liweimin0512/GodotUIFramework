@tool
extends Node

## UI管理器
## 负责管理UI资源、视图和分组

# 信号
signal view_registered(view_type: UIViewType)
signal view_unregistered(id: StringName)
signal group_registered(name: StringName, group: UIGroupComponent)
signal group_unregistered(name: StringName)

# 内部变量
var _view_types: Dictionary = {}
var _groups: Dictionary = {}
var _components: Dictionary = {}
var _resource_manager: UIResourceManager

## 初始化
func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resource_manager = UIResourceManager.new()

func _process(delta: float) -> void:
	_resource_manager.process(delta)

## 视图类型管理
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
## [param view_type] 要取消注册的视图类型
func unregister_view_type(view_type: UIViewType) -> void:
	if not _view_types.has(view_type.ID):
		push_warning("View type not registered: %s" % view_type.ID)
		return
		
	_view_types.erase(view_type.ID)
	view_unregistered.emit(view_type.ID)

func get_view_type(id: StringName) -> UIViewType:
	return _view_types.get(id)

## 创建场景
func create_scene(id: StringName, data: Dictionary = {}) -> Control:
	var scene_type := get_view_type(id) as UISceneType
	if not scene_type:
		push_error("Scene type not found: %s" % id)
		return null
	
	var group := get_group(scene_type.group_id)
	if not group:
		push_error("Group not found: %s" % scene_type.group_id)
		return null
	
	return group.create_scene(id, data)

## 分组管理
## [param name] 分组名称
## [param group] 分组组件
func register_group(name: StringName, group: UIGroupComponent) -> void:
	_groups[name] = group
	group_registered.emit(name, group)

## 分组取消注册
## [param name] 分组名称
func unregister_group(name: StringName) -> void:
	if not _groups.has(name):
		push_warning("Group not registered: %s" % name)
		return
	
	_groups.erase(name)
	group_unregistered.emit(name)

## 分组获取
## [param name] 分组名称
func get_group(name: StringName) -> UIGroupComponent:
	return _groups.get(name)

## 组件管理
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
	
	push_error("View has no view component: %s" % view)
	return null

func get_widget_component(view: Node) -> UIWidgetComponent:
	var component := get_view_component(view)
	if  component is UIWidgetComponent:
		return component
	push_error("View is not a widget: %s" % view)	
	return null

func get_scene_component(view: Node) -> UISceneComponent:
	var component := get_view_component(view)
	if  component is UISceneComponent:
		return component
	push_error("View is not a scene: %s" % view)	
	return null

## 清理组件缓存
## [param view] 视图节点
func clear_component_cache(view: Node = null) -> void:
	if view:
		_components.erase(view)
	else:
		_components.clear()

## 创建视图实例
## [param id] 视图ID
## [param parent] 父节点
## [param data] 初始化数据
## [return] 创建的视图实例
func create_view(id: StringName, parent: Node, data: Dictionary = {}) -> Control:
	var view_type := get_view_type(id)
	if not view_type:
		push_error("View type not found: %s" % id)
		return null
	
	# 加载场景资源
	var scene_res := _resource_manager.get_cached_resource(view_type.scene_path)
	if not scene_res:
		# 如果缓存中没有，尝试立即加载
		scene_res = _resource_manager.load_resource(view_type.scene_path, UIResourceManager.LoadMode.IMMEDIATE)
		if not scene_res:
			push_error("Failed to load scene: %s" % view_type.scene_path)
			return null
	
	# 实例化场景
	var instance = scene_res.instantiate()
	if not instance is Control:
		push_error("Scene instance is not a Control node: %s" % view_type.scene_path)
		instance.free()
		return null
	
	# 添加到父节点
	parent.add_child(instance)
	
	# 初始化视图组件
	var component := get_view_component(instance)
	if component:
		component.config = view_type
		component.initialize(data)
	
	return instance

# 资源管理
func load_resource(path: String, mode: UIResourceManager.LoadMode = UIResourceManager.LoadMode.IMMEDIATE) -> Resource:
	return _resource_manager.load_resource(path, mode)

func get_cached_resource(path: String) -> Resource:
	return _resource_manager.get_cached_resource(path)

func clear_resource_cache(path: String = "") -> void:
	_resource_manager.clear_resource_cache(path)

func get_from_pool(id: StringName) -> Node:
	return _resource_manager.get_instance(id)

func recycle_to_pool(id: StringName, instance: Node) -> void:
	_resource_manager.recycle_instance(id, instance)
