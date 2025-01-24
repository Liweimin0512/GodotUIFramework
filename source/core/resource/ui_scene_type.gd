extends UIViewType
class_name UISceneType

## UI场景配置资源
## 用于配置UI场景的基本属性和行为

## 场景分组ID，用于管理同组场景的显示和隐藏
@export var group_id: StringName = "":
	set(value):
		group_id = value
	get:
		return group_id

## 是否在显示时隐藏同组其他场景
@export var hide_others: bool = true:
	set(value):
		hide_others = value
	get:
		return hide_others

## 是否为模态场景（显示遮罩）
@export var is_modal: bool = false:
	set(value):
		is_modal = value
	get:
		return is_modal

## 是否阻挡输入事件（模态场景遮罩是否可点击）
@export var block_input: bool = true:
	set(value):
		block_input = value
	get:
		return block_input

## 验证配置是否有效
func validate() -> bool:
	# 基类验证
	if not super():
		return false
	
	# 验证group_id（如果设置了的话）
	if not group_id.is_empty() and not group_id.is_valid_identifier():
		push_error("Invalid group_id: %s" % group_id)
		return false
	
	return true
