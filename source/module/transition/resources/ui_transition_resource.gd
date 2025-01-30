@tool
extends Resource
class_name UITransitionResource

## 动画时长
@export var duration: float = 0.3
## 动画缓动类型
@export var trans_type: Tween.TransitionType = Tween.TRANS_QUAD
## 缓动曲线
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
## 是否自动启动
@export var auto_start: bool = true

## 创建补间动画
func create_tween(node: Node) -> Tween:
	var tween = node.create_tween()
	tween.set_trans(trans_type)
	tween.set_ease(ease_type)
	return tween

## 应用动画
## [param node] 目标节点
## [param tween] 补间动画对象
func apply_transition(_node: Node, _tween: Tween) -> void:
	push_error("UITransitionResource.apply_transition() must be overridden")
