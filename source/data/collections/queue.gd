@tool
extends RefCounted
class_name Queue

## 队列数据结构
## 提供先进先出（FIFO）的数据访问方式

#region 内部变量
var _items: Array = []
#endregion

#region 属性
## 是否为空
var is_empty: bool:
	get:
		return _items.is_empty()

## 队列大小
var size: int:
	get:
		return _items.size()

## 队首元素
var front: Variant:
	get:
		return peek()
#endregion

#region 公共方法
## 入队
## [param item] 要入队的元素
func enqueue(item: Variant) -> void:
	_items.push_back(item)

## 出队
## [returns] 队首元素，队列为空时返回null
func dequeue() -> Variant:
	if is_empty:
		return null
	return _items.pop_front()

## 查看队首元素
## [returns] 队首元素，队列为空时返回null
func peek() -> Variant:
	if is_empty:
		return null
	return _items.front()

## 清空队列
func clear() -> void:
	_items.clear()

## 转换为数组
## [returns] 包含所有元素的数组
func to_array() -> Array:
	return _items.duplicate()

## 检查元素是否在队列中
## [param item] 要检查的元素
## [returns] 是否存在
func has(item: Variant) -> bool:
	return _items.has(item)

## 移除指定元素
## [param item] 要移除的元素
## [returns] 是否成功移除
func remove(item: Variant) -> bool:
	var index = _items.find(item)
	if index != -1:
		_items.remove_at(index)
		return true
	return false

## 获取迭代器
## [returns] 队列迭代器
func iterator() -> QueueIterator:
	return QueueIterator.new(self)
#endregion

#region 内部类
## 队列迭代器
class QueueIterator:
	var _queue: Queue
	var _index: int = 0
	
	func _init(queue: Queue) -> void:
		_queue = queue
	
	## 是否有下一个元素
	func has_next() -> bool:
		return _index < _queue.size
	
	## 获取下一个元素
	func next() -> Variant:
		if not has_next():
			return null
		var item = _queue._items[_index]
		_index += 1
		return item
	
	## 重置迭代器
	func reset() -> void:
		_index = 0
#endregion
