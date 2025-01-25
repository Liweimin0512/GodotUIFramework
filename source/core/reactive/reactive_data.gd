extends RefCounted
class_name ReactiveData

signal value_changed(path: String, old_value: Variant, new_value: Variant)
signal child_value_changed(path: String, old_value: Variant, new_value: Variant)

var _data: Dictionary = {}
var _watchers: Dictionary = {}

func _init(initial_data: Dictionary = {}) -> void:
	_data = initial_data.duplicate(true)

## 获取值
## [param path] 数据路径，为空则返回整个数据
## [param default] 默认值
## [return] 值
func get_value(path: String, default: Variant = null) -> Variant:
	if path.is_empty():
		return _data
	
	var parts = path.split(".")
	var current = _data
	
	for part in parts:
		if current is Dictionary and part in current:
			current = current[part]
		else:
			return default
	
	return current

## 设置值
## [param path] 数据路径
## [param value] 值
func set_value(path: String, value: Variant) -> void:
	if path.is_empty():
		var old_data = _data.duplicate(true)
		_data = value if value is Dictionary else {}
		value_changed.emit("", old_data, _data)
		return
	
	var parts = path.split(".")
	var current = _data
	var parent = null
	var last_key = parts[-1]
	
	# 遍历路径
	for i in range(parts.size() - 1):
		var part = parts[i]
		if not (current is Dictionary):
			current = {}
		if not (part in current):
			current[part] = {}
		parent = current
		current = current[part]
	
	# 获取旧值
	var old_value = current.get(last_key) if current is Dictionary else null
	
	# 设置新值
	if not (current is Dictionary):
		current = {}
		if parent:
			parent[parts[-2]] = current
	current[last_key] = value
	
	# 发送信号
	value_changed.emit(path, old_value, value)
	
	# 向上传播变化
	var current_path = path
	while "." in current_path:
		current_path = current_path.substr(0, current_path.rfind("."))
		child_value_changed.emit(current_path, old_value, value)

## 更新多个值
## [param values] 更新的值
## [param base_path] 基础路径，为空则从根路径开始更新
func update_values(values: Dictionary, base_path: String = "") -> void:
	for key in values:
		var path = key if base_path.is_empty() else base_path + "." + key
		var value = values[key]
		
		if value is Dictionary:
			update_values(value, path)
		else:
			set_value(path, value)

## 监听值变化
## [param path] 监听的数据路径
## [param callback] 变化回调
func watch(path: String, callback: Callable) -> void:
	if not path in _watchers:
		_watchers[path] = []
	_watchers[path].append(callback)
	
	# 连接信号
	if not value_changed.is_connected(_on_value_changed):
		value_changed.connect(_on_value_changed)
	if not child_value_changed.is_connected(_on_child_value_changed):
		child_value_changed.connect(_on_child_value_changed)

## 取消监听
## [param path] 监听的数据路径
## [param callback] 变化回调
func unwatch(path: String, callback: Callable) -> void:
	if path in _watchers:
		_watchers[path].erase(callback)
		if _watchers[path].is_empty():
			_watchers.erase(path)
	
	# 如果没有监听器，断开信号
	if _watchers.is_empty():
		if value_changed.is_connected(_on_value_changed):
			value_changed.disconnect(_on_value_changed)
		if child_value_changed.is_connected(_on_child_value_changed):
			child_value_changed.disconnect(_on_child_value_changed)

## 值变化处理
## [param path] 变化的数据路径
## [param old_value] 旧值
## [param new_value] 新值
func _on_value_changed(path: String, old_value: Variant, new_value: Variant) -> void:
	if path in _watchers:
		for callback in _watchers[path]:
			callback.call(old_value, new_value)

## 子值变化处理
## [param path] 变化的数据路径
## [param old_value] 旧值
## [param new_value] 新值
func _on_child_value_changed(path: String, old_value: Variant, new_value: Variant) -> void:
	if path in _watchers:
		for callback in _watchers[path]:
			callback.call(old_value, new_value)

## 转换为字典
## [return] 字典
func to_dict() -> Dictionary:
	return _data.duplicate(true)
