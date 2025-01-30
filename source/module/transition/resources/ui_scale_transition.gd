@tool
extends UITransitionResource
class_name UIScaleTransition

## 缩放类型

## 起始缩放
@export var from_scale: Vector2 = Vector2.ZERO
## 目标缩放
@export var to_scale: Vector2 = Vector2.ONE
## 缩放中心点
@export var pivot: Vector2 = Vector2(0.5, 0.5)
## 是否相对于当前缩放
@export var relative: bool = true

func apply_transition(node: Node, tween: Tween) -> void:
	if node is Control:
		# 设置缩放中心点
		node.set_pivot_offset(node.size * pivot)
		
		if relative:
			var current_scale = node.scale
			tween.tween_property(
				node,
				"scale",
				current_scale * to_scale,
				duration
			).from(current_scale * from_scale)
		else:
			tween.tween_property(
				node,
				"scale",
				to_scale,
				duration
			).from(from_scale)
	elif node is Node2D:
		if relative:
			var current_scale = node.scale
			tween.tween_property(
				node,
				"scale",
				current_scale * to_scale,
				duration
			).from(current_scale * from_scale)
		else:
			tween.tween_property(
				node,
				"scale",
				to_scale,
				duration
			).from(from_scale)
