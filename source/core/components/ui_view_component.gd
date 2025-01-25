extends Node
class_name UIViewComponent

## UI视图基础组件
## 所有UI组件的基类，提供基本的生命周期和数据管理

## 视图数据模型
var model: ReactiveData:
	set = set_model

## 层级
@export var layer: int = 0
## 过渡动画
@export var transition_name: StringName = ""
## 数据路径数组，支持逻辑表达式
@export var data_paths: Array[String] = []
## 路径解析器
var _path_parser: DataPathParser
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
## 数据更新信号
signal data_updated(data: Dictionary)

func _init() -> void:
	_path_parser = DataPathParser.new()

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
		
	model = ReactiveData.new()
	model.update_values(data)
	if owner.has_method("_setup"):
		owner.call("_setup", model.to_dict())
	
	# 初始化所有子视图
	_initialize_child_views(data)
	
	# 播放过渡动画
	await _play_transition()
	
	_is_initialized = true
	view_ready.emit(owner)

## 更新视图数据
func update_data(data: Dictionary) -> void:
	# 合并数据
	model.update_values(data)
	
	# 发送更新信号
	data_updated.emit(model.to_dict())
	
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
	return model.to_dict()

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
		if component.should_update(data.keys()):
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

## 检查数据路径是否匹配
func should_update(changed_paths: Array) -> bool:
	# 如果没有指定数据路径，则始终更新
	if data_paths.is_empty():
		return true
	
	# 检查每个数据路径表达式
	for path_expr in data_paths:
		if _path_parser.evaluate(path_expr, changed_paths):
			return true
	
	return false

## 设置数据模型
func set_model(value: ReactiveData) -> void:
	# 解除旧模型的监听
	if model:
		model.value_changed.disconnect(_on_model_value_changed)
		model.child_value_changed.disconnect(_on_model_child_value_changed)
	
	model = value
	
	# 设置新模型的监听
	if model:
		if not model.value_changed.is_connected(_on_model_value_changed):
			model.value_changed.connect(_on_model_value_changed)
		if not model.child_value_changed.is_connected(_on_model_child_value_changed):
			model.child_value_changed.connect(_on_model_child_value_changed)
		
		# 初始更新
		data_updated.emit(model.to_dict())

## 数据变化处理
func _on_model_value_changed(path: String, old_value: Variant, new_value: Variant) -> void:
	if should_update([path]):
		data_updated.emit(model.to_dict())

## 子数据变化处理
func _on_model_child_value_changed(path: String, old_value: Variant, new_value: Variant) -> void:
	if should_update([path]):
		data_updated.emit(model.to_dict())

## 数据路径解析器
class DataPathParser:
	# 运算符
	const OP_AND = "&"
	const OP_OR = "|"
	const OP_NOT = "!"
	
	## 解析并计算路径表达式
	func evaluate(expr: String, changed_paths: Array) -> bool:
		# 移除空格
		expr = expr.strip_edges()
		
		# 处理NOT运算
		if expr.begins_with(OP_NOT):
			return not evaluate(expr.substr(1), changed_paths)
		
		# 处理AND运算
		if OP_AND in expr:
			var parts = expr.split(OP_AND)
			for part in parts:
				if not evaluate(part.strip_edges(), changed_paths):
					return false
			return true
		
		# 处理OR运算
		if OP_OR in expr:
			var parts = expr.split(OP_OR)
			for part in parts:
				if evaluate(part.strip_edges(), changed_paths):
					return true
			return false
		
		# 基本路径匹配
		return _match_path(expr, changed_paths)
	
	## 检查基本路径是否匹配
	func _match_path(path: String, changed_paths: Array) -> bool:
		for changed_path in changed_paths:
			# 完全匹配
			if path == changed_path:
				return true
			
			# 前缀匹配（父路径）
			if changed_path.begins_with(path + "."):
				return true
			
			# 后缀匹配（子路径）
			if path.begins_with(changed_path + "."):
				return true
		
		return false
