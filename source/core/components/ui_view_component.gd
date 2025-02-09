@tool
extends Node
class_name UIViewComponent

## UI视图组件基类
## 提供UI组件的基础功能

# 信号
## 初始化完成，返回初始数据
signal initialized(data: Dictionary)
## 即将销毁，返回最终数据
signal disposing
## 更新数据
signal updated(data: Dictionary)

## 视图配置
@export var config: UIViewType = UIViewType.new()
@export var data_model : UIDataModel = UIDataModel.new()

## 是否已经初始化
var _is_initialized := false

func _ready() -> void:
	if not _is_initialized:
		initialize()

## 初始化
func initialize(data: Dictionary = {}) -> void:
	if Engine.is_editor_hint():
		return
	if _is_initialized:
		push_error("View already initialized")
		return
	var new_data := data_model.initialize(data)
	_initialize(new_data)

	_is_initialized = true
	initialized.emit(new_data)

## 销毁
func dispose() -> void:
	if Engine.is_editor_hint():
		return
	if not _is_initialized:
		push_error("View not initialized: %s" % get_parent())
		return
	_dispose()
	
	_is_initialized = false
	disposing.emit()

## 更新
func update(data:Dictionary = {}) -> void:
	if Engine.is_editor_hint():
		return
	var new_data = data_model.update(data)
	if not new_data.is_empty():
		_update(new_data)
		updated.emit(new_data)

## 监听数据
func watch_data(property: String, callback: Callable) -> void:
	if not _is_initialized:
		push_error("View not initialized")
		return
	data_model.watch(property, callback)

## 停止监听数据
func unwatch_data(property: String, callback: Callable) -> void:
	if not _is_initialized:
		push_error("View not initialized")
		return
	data_model.unwatch(property, callback)

## 初始化, 子类实现
func _initialize(data: Dictionary = {}) -> void:
	pass

## 销毁, 子类实现
func _dispose() -> void:
	pass

## 更新, 子类实现
func _update(data: Dictionary = {}) -> void:
	pass
