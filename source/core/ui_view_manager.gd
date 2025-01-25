extends RefCounted
class_name UIViewManager

## 视图类型注册表
var _view_types: Dictionary[StringName, UIViewType] = {}
var _active_components: Dictionary = {}

signal view_created(view: Node)
signal view_disposed(view: Node)

## 注册视图类型
func register_view_type(view_type: UIViewType) -> void:
	if _view_types.has(view_type.ID):
		push_warning("View type already registered: %s" % view_type.ID)
		return
		
	_view_types[view_type.ID] = view_type
	
	# 处理预加载
	if view_type.preload_mode == UIViewType.PRELOAD_MODE.PRELOAD:
		UIManager.resource_manager.load_scene(
			view_type.scene_path, 
			UIResourceManager.LoadMode.IMMEDIATE
		)
	elif view_type.preload_mode == UIViewType.PRELOAD_MODE.LAZY_LOAD:
		UIManager.resource_manager.load_scene(
			view_type.scene_path, 
			UIResourceManager.LoadMode.LAZY
		)

## 注销视图类型
func unregister_view_type(id: StringName) -> void:
	if not _view_types.has(id):
		push_warning("View type not registered: %s" % id)
		return
		
	var view_type = _view_types[id]
	UIManager.resource_manager.clear_cache(view_type.scene_path)
	_view_types.erase(id)

## 创建视图实例
func create_view(id: StringName, parent: Node, data: Dictionary = {}) -> Control:
	var view_type = get_view_type(id)
	if not view_type:
		push_error("View type not found: %s" % id)
		return null
	
	var view = UIManager.resource_manager.get_instance(
		view_type.scene_path,
		view_type.scene_path,
		view_type.cache_mode == UIViewType.CACHE_MODE.CACHE_IN_MEMORY
	)
	
	if not view:
		return null
	
	if parent:
		parent.add_child(view)
	
	var component : UIViewComponent
	if UIManager.is_scene(view):
		component = UIManager.get_scene_component(view)
	elif UIManager.is_widget(view):
		component = UIManager.get_widget_component(view)
	if component:
		component.initialize(data)
	else:
		push_error("can not found view component in node: {0}".format([view]))
	view_created.emit(view)
	return view

## 销毁视图
func destroy_view(view: Control) -> void:
	if not view: return
	var component = UIManager.get_view_component(view)
	if component:
		component.dispose()
	view_disposed.emit(view)

## 更新视图数据
## [param view] 视图实例
## [param data] 更新的数据
## [param paths] 变更的数据路径，为空则表示全部更新
func update_view_data(view: Node, data: Dictionary, paths: Array[String] = []) -> void:
	# 获取视图组件
	var component = get_view_component(view)
	if not component: return
	
	# 如果没有指定路径，则从数据中获取顶级路径
	if paths.is_empty():
		paths = _get_data_paths(data)
	
	# 检查是否需要更新
	if component.should_update(paths):
		component.update_data(data)

## 获取视图类型
func get_view_type(id: StringName) -> UIViewType:
	return _view_types.get(id)

## 获取视图组件
func get_view_component(view: Node) -> Node:
	if not view: return null
	
	# 检查缓存
	if view in _active_components:
		return _active_components[view]
	
	# 查找组件
	var component = _find_view_component(view)
	if component:
		_active_components[view] = component
	
	return component

## 获取视图ID
func get_view_id(view: Control) -> StringName:
	var view_component = UIManager.get_view_component(view)
	if not view_component:
		push_error("can not found view component in node: {0}".format([view]))
		return ""
	var config : UIViewType = view_component.config as UIViewType
	return config.ID

## 获取视图数据
## [param view] 视图实例
## [return] 视图数据
func get_view_data(view: Control) -> Dictionary:
	var component = UIManager.get_view_component(view)
	if not component:
		push_error("View component not found: %s" % view.name)
		return {}
	return component.get_data()

## 查找视图组件
func _find_view_component(view: Node) -> Node:
	if not view: return null
	
	# 查找子节点
	for child in view.get_children():
		if child.get_script() and child.get_script().resource_path.contains("ui_view_component.gd"):
			return child
	
	return null

## 从数据字典中获取所有数据路径
func _get_data_paths(data: Dictionary, base_path: String = "") -> Array[String]:
	var paths: Array[String] = []
	
	for key in data:
		var path = key if base_path.is_empty() else base_path + "." + key
		paths.append(path)
		
		if data[key] is Dictionary:
			paths.append_array(_get_data_paths(data[key], path))
	
	return paths
