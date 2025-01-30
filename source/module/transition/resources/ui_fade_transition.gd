@tool
extends UITransitionResource
class_name UIFadeTransition

## 透明度过渡

## 初始透明度
@export var from_alpha: float = 0.0
## 目标透明度
@export var to_alpha: float = 1.0

func apply_transition(node: Node, tween: Tween) -> void:
	if node is CanvasItem:
		tween.tween_property(
			node,
			"modulate:a",
			to_alpha,
			duration
		).from(from_alpha)
