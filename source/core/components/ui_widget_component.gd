@tool
extends UIViewComponent
class_name UIWidgetComponent

## UI小部件组件
## 提供可重用UI组件的基础功能

## 初始化时注册的视图类型数据
@export var view_types : Array[UIViewType] = []
## 子视图组件
var _child_components: Array[UIViewComponent] = []

#region 生命周期

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	for view_type in view_types:
		UIManager.register_view_type(view_type)
	if not config:
		push_warning("View config is empty : %s" % get_parent() )
		config = UIViewType.new()
	if not data_model:
		data_model = UIDataModel.new()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	for view_type in view_types:
		UIManager.unregister_view_type(view_type)

func _ready() -> void:
	if Engine.is_editor_hint():
		return

#endregion

#region 公共接口

## 获取所有子视图组件
func get_child_components() -> Array[UIViewComponent]:
	return _child_components

## 创建控件
## [param id] 控件类型ID
## [param data] 控件数据
## [param parent] 父节点
func create_widget(id: StringName, parent: Node = null, data: Dictionary = {}) -> Control:
	return UIManager.create_view(id, parent, data)

## 销毁控件
## [param widget] 控件
func dispose_widget(widget: Node) -> void:
	if not UIManager.is_view_component(widget):
		push_warning("View is not registered: %s" % widget)
		return
	UIManager.dispose_view(widget)

#endregion

#region 内部函数

## 初始化组件
func _initialize(data: Dictionary = {}) -> void:
	# 查找子视图组件
	_child_components = _find_child_components(get_parent())
	_initialize_child_components(data)

## 销毁组件
func _dispose() -> void:
	_child_components = _find_child_components(get_parent())
	_dispose_child_components()

## 更新组件
func _update(data: Dictionary = {}) -> void:
	_child_components = _find_child_components(get_parent())
	_update_child_components(data)

## 初始化子视图组件
## [param data] 初始化数据
func _initialize_child_components(data: Dictionary = {}) -> void:
	if _child_components.is_empty(): return
	print("_initialize_child_components", _child_components)
	# 初始化找到的组件
	for component in _child_components:
		if component != self and not component._is_initialized:
			component.initialize(data)

## 销毁子视图组件
func _dispose_child_components() -> void:
	if _child_components.is_empty(): return
	print("_dispose_child_components", _child_components)
	for component in _child_components:
		if component != self:
			component.dispose()
	_child_components.clear()

## 更新子视图组件
func _update_child_components(data: Dictionary = {}) -> void:
	for component in _child_components:
		if component != self:
			component.update(data)

## 查找子视图组件
func _find_child_components(root: Node) -> Array[UIViewComponent]:
	var components: Array[UIViewComponent] = []
	
	# 获取所有直接下级视图场景
	var sub_scenes = _get_direct_sub_view_scenes(root)
	
	# 获取每个场景的视图组件
	for scene in sub_scenes:
		var component = UIManager.get_view_component(scene)
		if component and component != self:
			components.append(component)
	
	return components

## 获取所有直接下级视图场景
func _get_direct_sub_view_scenes(root: Node) -> Array[Node]:
	var scenes: Array[Node] = []
	if not root:
		return scenes
	
	# 遍历所有子节点
	var stack = [root]
	while not stack.is_empty():
		var current = stack.pop_front()
		
		# 如果当前节点是视图场景，加入列表
		if current != root and UIManager.is_view_node(current):
			scenes.append(current)
			continue  # 不再遍历这个场景的子节点
		
		# 将子节点加入栈中继续搜索
		for child in current.get_children():
			stack.append(child)
	
	return scenes

#endregion
