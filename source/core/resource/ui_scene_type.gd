@tool
extends UIWidgetType
class_name UISceneType

## UI场景类型
## 继承自UIWidgetType，添加场景特有的功能

# 属性
## 分组ID
@export var group_id: StringName
## 层级
@export var layer: int = 0
## 过渡动画名称
@export var transition_name: StringName
## 是否隐藏其他场景
@export var hide_others: bool = false
## 是否模态
@export var modal: bool = false

## 验证配置
func validate() -> bool:
	if not super.validate():
		return false
	return true

## 复制配置
func duplicate_type() -> UISceneType:
	var copy = super.duplicate_type() as UISceneType
	copy.group_id = group_id
	copy.layer = layer
	copy.transition_name = transition_name
	copy.hide_others = hide_others
	copy.modal = modal
	return copy
