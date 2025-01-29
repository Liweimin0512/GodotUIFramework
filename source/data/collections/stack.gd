# stack.gd
extends RefCounted
class_name Stack

## 栈, 先进后出

signal stack_changed(old_size: int, new_size: int)

## 内部存储数组
var _items: Array = []

## 获取栈大小
var size: int:
	get:
		return _items.size()

## 判断栈是否为空
var is_empty: bool:
	get:
		return _items.is_empty()

## 获取栈顶元素但不移除
func peek():
	if is_empty:
		push_error("Stack is empty")
		return null
	return _items[-1]

## 压入元素到栈顶
func push(item) -> void:
	if _items.has(item):
		push_error("Stack already contains item")
	stack_changed.emit(size, size + 1)
	_items.push_back(item)

## 弹出栈顶元素
func pop():
	if is_empty:
		push_error("Stack is empty")
		return null
	stack_changed.emit(size, size - 1)
	return _items.pop_back()

## 清空栈
func clear() -> void:
	stack_changed.emit(size, 0)
	_items.clear()

## 转换为数组
func to_array() -> Array:
	return _items.duplicate()

## 指定位置添加元素
## [param index] 元素索引
## [param item] 元素
func insert_at(index: int, item) -> bool:
	if _items.size() < index:
		push_error("Stack index out of range")
		return false
	stack_changed.emit(size, size + 1)
	_items.insert(index, item)
	return true

## 移除指定位置的元素
## [param index] 元素索引
func remove_at(index: int) -> bool:
	if _items.size() <= index:
		push_error("Stack index out of range")
		return false
	stack_changed.emit(size, size - 1)
	_items.remove_at(index)
	return true

## 移除指定元素
## [param item] 元素
func remove(item) -> bool:
	if not _items.has(item):
		push_error("Item not in stack")
		return false
	stack_changed.emit(size, size - 1)
	_items.erase(item)
	return true

## 是否存在元素
## [param item] 元素
func has(item) -> bool:
	return _items.has(item)

## 将元素移动到栈顶
## [param item] 元素
func move_to_top(item) -> bool:
	if not _items.has(item):
		push_error("Item not in stack")
		return false
	stack_changed.emit(size, size)
	_items.erase(item)
	_items.push_back(item)
	return true

## 打印栈内容（用于调试）
func _to_string() -> String:
	return "Stack(size: %d, items: %s)" % [size, str(_items)]
