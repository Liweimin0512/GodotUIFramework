@tool
extends UIViewType
class_name UIWidgetType

## UI控件类型
## 继承自UIViewType，添加控件特有的功能

# 属性
## 是否可重用（用于对象池）
@export var reusable: bool = false
## 池容量（仅当reusable为true时有效）
@export var pool_capacity: int = 10
## 自动扩容（仅当reusable为true时有效）
@export var auto_expand: bool = true

## 验证配置
func validate() -> bool:
	if not super.validate():
		return false
	
	if reusable and pool_capacity <= 0:
		push_error("Pool capacity must be greater than 0")
		return false
	
	return true

## 复制配置
func duplicate_type() -> UIWidgetType:
	var copy = super.duplicate() as UIWidgetType
	copy.reusable = reusable
	copy.pool_capacity = pool_capacity
	copy.auto_expand = auto_expand
	return copy
