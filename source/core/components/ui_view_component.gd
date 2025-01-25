extends Node
class_name UIViewComponent

## UI视图组件基类
## 提供基础的UI组件功能，包括生命周期管理和数据绑定

# 信号
## 初始化完成，返回初始数据
signal initialized(data: Dictionary)
## 即将销毁，返回最终数据
signal disposing(data: Dictionary)
## 数据更新前
signal data_updating(path: String, value: Variant)
## 数据更新后
signal data_updated(path: String, value: Variant)

## 数据绑定路径
@export var data_paths: Array[String]:
	set(value):
		data_paths = value
		# if Engine.is_editor_hint():
		# 	return
		if _is_initialized:
			push_warning("Cannot change data paths after initialization")
			return
		_update_paths = value

## 初始化时注册的视图类型数据
@export var view_types : Array[UIViewType] = []
## 视图配置
@export var config : UIViewType:
	set(value):
		config = value
		if Engine.is_editor_hint():
			return
		if _is_initialized:
			push_warning("Cannot change config after initialization")
			return
		_config = value

# 属性
var model: ReactiveData:
	set(value):
		if model != null and model.value_changed.is_connected(_on_data_changed):
			model.value_changed.disconnect(_on_data_changed)
		model = value
		if model != null:
			model.value_changed.connect(_on_data_changed)

# 内部变量
var _is_initialized: bool = false          # 是否已初始化
var _update_paths: Array[String] = []      # 更新路径列表
var _view_components: Array[UIViewComponent] = []  # 视图组件列表
var _config: UIViewType                    # 内部配置引用

func _ready() -> void:
	# 注册视图类型
	for view_type in view_types:
		UIManager.register_view_type(view_type)
	
	# 设置初始配置
	_config = config
	# 设置更新路径
	_update_paths = data_paths

	# 查找子视图组件
	_view_components = _find_view_components(_get_view_scene())

func _exit_tree() -> void:
	for view_type in view_types:
		UIManager.unregister_view_type(view_type)

## 初始化
## [param data] 初始化数据
func initialize(data: Dictionary = {}) -> void:
	if _is_initialized:
		push_error("View already initialized")
		return

	# 设置数据模型
	model = ReactiveData.new(data)
	
	# 调用子类初始化
	_initialized(data)
	
	# 初始化视图组件
	_initialize_view_components(data)
	
	# 监听节点树变化
	owner.child_entered_tree.connect(_on_node_added)
	owner.child_exiting_tree.connect(_on_node_removed)
	
	_is_initialized = true
	initialized.emit(data)

## 销毁
func dispose() -> void:
	if not _is_initialized:
		return
	
	var final_data := get_data()
	disposing.emit(final_data)
	
	# 断开节点树变化的信号连接
	if owner:
		if owner.child_entered_tree.is_connected(_on_node_added):
			owner.child_entered_tree.disconnect(_on_node_added)
		if owner.child_exiting_tree.is_connected(_on_node_removed):
			owner.child_exiting_tree.disconnect(_on_node_removed)
	
	# 销毁视图组件
	_dispose_view_components()
	
	# 调用子类销毁
	_disposed()
	
	# 清理数据模型
	model = null
	
	_is_initialized = false

## 更新数据
## [param data] 更新的数据
## [param paths] 更新路径列表，为空则使用配置中的路径
func update_data(data: Dictionary, paths: Array[String] = []) -> void:
	if not model:
		push_error("Cannot update data: model is null")
		return
	
	if not data is Dictionary:
		push_error("Update data must be a Dictionary")
		return
	
	# 更新路径列表
	var update_paths := paths if not paths.is_empty() else _update_paths
	
	# 如果没有指定路径，更新整个数据
	if update_paths.is_empty():
		data_updating.emit("", data)
		model.set_value("", data)
		return
	
	# 更新指定路径的数据
	for path in update_paths:
		if path in data:
			data_updating.emit(path, data[path])
			model.set_value(path, data[path])

## 获取数据
## [param path] 数据路径，为空则返回整个数据
## [param default] 默认值
func get_data(path: String = "", default: Variant = null) -> Variant:
	if not model:
		push_error("Cannot get data: model is null")
		return null
	
	return model.get_value(path, default)

## 注册视图类型
## [param view_type] 视图类型
func register_view_type(view_type: UIViewType) -> void:
	UIManager.register_view_type(view_type)

## 初始化视图组件
## [param data] 初始化数据
func _initialize_view_components(data: Dictionary = {}) -> void:

	# 初始化找到的组件
	for component in _view_components:
		if component != self and not component._is_initialized:
			component.initialize(data)

## 销毁视图组件
func _dispose_view_components() -> void:
	for component in _view_components:
		if component != self:
			component.dispose()
	_view_components.clear()

## 查找视图组件
## [param root] 根节点
## [returns] 视图组件列表
func _find_view_components(root: Node) -> Array[UIViewComponent]:
	var components: Array[UIViewComponent] = []
	
	# 获取所有直接下级视图场景
	var sub_scenes = get_direct_sub_view_scenes(root)
	
	# 获取每个场景的视图组件
	for scene in sub_scenes:
		var component = get_view_component(scene)
		if component and component != self:
			components.append(component)
	
	return components

## 获取当前组件所属的视图场景
## [returns] 当前组件所属的视图场景节点
func _get_view_scene() -> Node:
	return get_parent()

## 子类中实现的初始化方法
## [param data] 初始化数据
func _initialized(data: Dictionary = {}) -> void:
	pass

## 子类中实现的销毁方法
func _disposed() -> void:
	pass

## 节点添加回调
## [param node] 新节点
func _on_node_added(node: Node) -> void:
	# 查找新节点下一级的视图组件并更新缓存
	var components := _find_view_components(node)
	for component in components:
		if not _view_components.has(component):
			_view_components.append(component)

## 节点移除回调
## [param node] 要移除的节点
func _on_node_removed(node: Node) -> void:
	# 查找要移除的下一级视图组件
	var components := _find_view_components(node)
	
	# 从缓存中移除并销毁组件
	for component in components:
		if component in _view_components:
			_view_components.erase(component)
			component.dispose()

## 处理数据更新
## [param path] 更新路径
## [param value] 更新值
func _on_data_changed(path: String, _old_value: Variant, value: Variant) -> void:
	push_warning("[UIViewComponent] Data changed: path=%s, update_paths=%s" % [path, _update_paths])
	
	# 检查是否在更新路径列表中
	if path in _update_paths or path == "":
		push_warning("[UIViewComponent] Path matched, emitting data_updated")
		data_updated.emit(path, value)
	
	# 通知子组件
	for component in _view_components:
		component.update_data({path: value})

## 获取节点的视图组件
## [param node] 要检查的节点
## [returns] 如果节点包含视图组件则返回该组件，否则返回null
static func get_view_component(node: Node) -> UIViewComponent:
	if not node:
		return null
	
	for child in node.get_children():
		if child is UIViewComponent:
			return child
	return null

## 检查节点是否是视图场景（包含视图组件的节点）
## [param node] 要检查的节点
## [returns] 如果节点包含视图组件则返回true
static func is_view_scene(node: Node) -> bool:
	return get_view_component(node) != null

## 获取节点下所有直接下级视图场景
## [param root] 根节点
## [returns] 直接下级视图场景列表
static func get_direct_sub_view_scenes(root: Node) -> Array[Node]:
	var scenes: Array[Node] = []
	if not root:
		return scenes
	
	# 遍历所有子节点
	var stack = [root]
	while not stack.is_empty():
		var current = stack.pop_front()
		
		# 如果当前节点是视图场景，加入列表
		if current != root and is_view_scene(current):
			scenes.append(current)
			continue  # 不再遍历这个场景的子节点
		
		# 将子节点加入栈中继续搜索
		for child in current.get_children():
			stack.append(child)
	
	return scenes
