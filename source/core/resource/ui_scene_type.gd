@tool
extends UIWidgetType
class_name UISceneType

## UI场景类型
## 继承自UIWidgetType，添加场景特有的功能

## 分组行为
enum GROUP_BEHAVIOR {
	RESPECT_SCENE,     # 尊重场景配置的分组
	FORCE_GROUP,       # 强制使用当前分组
	ADDITIVE_GROUP     # 添加到当前分组（保留原有分组）
}

## 分组类型
enum GROUP_TYPE {
	EXCLUSIVE,     # 互斥组（同时只能显示一个场景）
	ADDITIVE,      # 叠加组（可以同时显示多个场景）
	INDEPENDENT    # 独立组（不影响其他组的场景）
}

# 属性
## 分组ID
@export var group_id: StringName
## 分组行为
@export var group_behavior: GROUP_BEHAVIOR = GROUP_BEHAVIOR.RESPECT_SCENE
## 分组类型
@export var group_type: GROUP_TYPE = GROUP_TYPE.EXCLUSIVE
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
	
	# 场景类型默认不使用对象池
	reusable = false
	
	if modal and group_type != GROUP_TYPE.EXCLUSIVE:
		push_error("Modal scenes must be exclusive")
		return false
	
	return true

## 复制配置
func duplicate_type() -> UISceneType:
	var copy = super.duplicate_type() as UISceneType
	copy.group_id = group_id
	copy.group_behavior = group_behavior
	copy.group_type = group_type
	copy.layer = layer
	copy.transition_name = transition_name
	copy.hide_others = hide_others
	copy.modal = modal
	return copy
