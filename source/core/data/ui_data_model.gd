@tool
extends Resource
class_name UIDataModel

## UI数据模型基类
## 提供数据存储和验证的基础功能

# 信号
signal value_changed(property: String, old_value: Variant, new_value: Variant)

# 导出变量
## 数据路径列表，用于限制可访问的数据
## 如果为空，则表示所有属性都可访问
@export var data_paths: Array[String] = []

# 内部变量
var _data: Dictionary = {}
var _watchers: Dictionary[String, Array] = {}

func initialize(data: Dictionary) -> Dictionary:
	if not value_changed.is_connected(_on_value_changed):
		value_changed.connect(_on_value_changed)
	# 配置
	_configure()
	# 过滤数据
	_data = _filter_data(data)
	# 初始化
	_initialize()
	return _data

## 获取数据值
## [param property] 属性路径
## [param default] 默认值
func get_value(property: String = "", default: Variant = null) -> Variant:
	if property.is_empty():
		return _data.duplicate(true)
	
	if not _is_valid_property(property):
		push_error("Invalid property path: %s" % property)
		return default
	
	var value = _get_value_from_path(property)
	return value if value != null else default

## 设置数据值
## [param property] 属性路径
## [param value] 新值
func set_value(property: String, value: Variant) -> void:
	if not _is_valid_property(property):
		push_error("Invalid property path: %s" % property)
		return
	
	if not _validate_property_value(property, value):
		push_error("Invalid value for property: %s" % property)
		return
	
	var old_value = get_value(property)
	if old_value == value:
		return
	
	_set_value_to_path(property, value)
	value_changed.emit(property, old_value, value)

## 检查属性路径是否合法
func _is_valid_property(property: String) -> bool:
	if property.is_empty():
		return false
	
	if data_paths.is_empty():
		return true
	
	for path in data_paths:
		if property.begins_with(path):
			return true
	
	return false

## 从数据路径获取值
func _get_value_from_path(path: String) -> Variant:
	var current = _data
	var parts = path.split(".")
	
	for i in range(parts.size() - 1):
		var part = parts[i]
		if not current.has(part):
			return null
		current = current[part]
		if not current is Dictionary:
			return null
	
	var last = parts[-1]
	if not current.has(last):
		return null
	
	return current[last]

## 设置数据路径的值
func _set_value_to_path(path: String, value: Variant) -> void:
	var current = _data
	var parts = path.split(".")
	
	for i in range(parts.size() - 1):
		var part = parts[i]
		if not current.has(part):
			current[part] = {}
		current = current[part]
	
	current[parts[-1]] = value

## 监听数据
func watch(property: String, callback: Callable) -> void:
	_watchers[property].append(callback)

## 取消监听数据
func unwatch(property: String, callback: Callable) -> void:
	_watchers[property].erase(callback)

## 子类实现：配置
## 用于设置数据路径和其他配置
func _configure() -> void:
	pass

## 子类实现：初始化
## 用于处理额外的初始化工作
func _initialize() -> void:
	pass

## 子类实现：筛选数据
## [param data] 原始数据
## [returns] 筛选后的数据
func _filter_data(data: Dictionary) -> Dictionary:
	if data.is_empty():
		return data
	if data_paths.is_empty():
		return data
	var new_data : Dictionary = {}
	for p in data_paths:
		var value = data.get(p, null)
		if value == null:
			push_error("Missing property: %s" % p)
			continue
		new_data[p] = value
	return new_data

## 子类实现：验证属性值
## [param property] 属性路径
## [param value] 属性值
## [returns] 是否有效
func _validate_property_value(property: String, value: Variant) -> bool:
	return true

func _on_value_changed(property: String, old_value: Variant, new_value: Variant) -> void:
	var callables  = _watchers.get(property, [])
	for callable in callables:
		callable.call(new_value)
