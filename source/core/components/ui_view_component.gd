extends Node
class_name UIViewComponent

## UI视图基础组件
## 所有UI组件的基类，提供基本的生命周期和数据管理

## 视图数据模型
var model: Dictionary = {}

## 层级
@export var layer: int = 0
## 过渡动画
@export var transition_name: StringName = ""

## 当前状态
var _is_initialized: bool = false

## 视图配置
var config: UIViewType:
	set(value):
		if config == value:
			return
		var old_config = config
		config = value
		_apply_config()
		config_changed.emit(old_config, value)
	get:
		return config

## 缓存的子视图组件
var _cached_child_components: Array[UIViewComponent] = []
## 是否需要刷新子视图缓存
var _need_refresh_cache: bool = true

## 视图准备好
signal view_ready(view: Control)
## 视图被销毁
signal view_disposed(view: Control)
## 过渡动画开始
signal transition_started(view: Control)
## 过渡动画结束
signal transition_completed(view: Control)

## 配置变更信号
signal config_changed(old_config: UIViewType, new_config: UIViewType)

func _ready() -> void:
	# 监听子节点变化
	owner.child_entered_tree.connect(_on_child_changed)
	owner.child_exiting_tree.connect(_on_child_changed)

## 子节点变化时刷新缓存
func _on_child_changed(_node: Node) -> void:
	_need_refresh_cache = true

## 刷新子视图缓存
func _refresh_child_components() -> void:
	if not _need_refresh_cache:
		return
	
	_cached_child_components.clear()
	_find_child_components_recursive(owner)
	_need_refresh_cache = false

## 递归查找子视图组件
func _find_child_components_recursive(node: Node) -> void:
	for child in node.get_children():
		# 如果当前节点是视图，获取其组件并添加到缓存
		if UIManager.is_view(child):
			var component = UIManager.get_view_component(child)
			if component and component != self:  # 避免自己引用自己
				_cached_child_components.append(component)
			continue  # 如果是视图节点，不再继续遍历其子节点，因为那是另一个视图的职责范围
		
		# 如果不是视图节点，继续递归查找
		_find_child_components_recursive(child)

## 初始化视图
func initialize(data: Dictionary = {}) -> void:
	if _is_initialized:
		return
		
	model = data
	if owner.has_method("_setup"):
		owner.call("_setup", model)
	
	# 初始化所有子视图
	_initialize_child_views(data)
	
	# 播放过渡动画
	await _play_transition()
	
	_is_initialized = true
	view_ready.emit(owner)

## 更新视图数据
func update_data(data: Dictionary) -> void:
	model.merge(data, true)
	if owner.has_method("_refresh"):
		owner.call("_refresh", model)
	
	# 更新所有子视图
	_update_child_views(data)

## 销毁视图
func dispose() -> void:
	if not _is_initialized:
		return
	
	# 播放退出动画
	await _play_transition(false)
	
	# 销毁所有子视图
	_dispose_child_views()
	
	if owner.has_method("_cleanup"):
		owner.call("_cleanup")
	
	_is_initialized = false
	view_disposed.emit(owner)

## 获取视图数据
func get_data() -> Dictionary:
	return model

## 获取层级
func get_layer() -> int:
	return layer

## 设置层级
func set_layer(value: int) -> void:
	layer = value

## 是否已初始化
func is_initialized() -> bool:
	return _is_initialized

## 播放过渡动画
func _play_transition(is_enter: bool = true) -> void:
	if not UIManager.is_module_enabled("transition"): return
	transition_started.emit(owner)
	if is_enter:
		await UIManager.transition_manager.apply_open_transition(owner, transition_name)
	else:
		await UIManager.transition_manager.apply_close_transition(owner, transition_name)
	transition_completed.emit(owner)

## 初始化子视图
func _initialize_child_views(data: Dictionary) -> void:
	_refresh_child_components()
	for component in _cached_child_components:
		component.initialize(data)

## 更新子视图
func _update_child_views(data: Dictionary) -> void:
	_refresh_child_components()
	for component in _cached_child_components:
		component.update_data(data)

## 销毁子视图
func _dispose_child_views() -> void:
	_refresh_child_components()
	for component in _cached_child_components:
		component.dispose()

## 应用配置
## 子类可以重写此方法以实现特定的配置应用逻辑
func _apply_config() -> void:
	pass
