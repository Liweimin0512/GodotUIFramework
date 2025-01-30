@tool
extends UITransitionResource
class_name UISlideTransition

## 滑动入场效果

## 起始位置偏移
@export var from_offset: Vector2 = Vector2.ZERO
## 目标位置偏移
@export var to_offset: Vector2 = Vector2.ZERO
## 是否相对于当前位置
@export var relative: bool = true

func apply_transition(node: Node, tween: Tween) -> void:
	if node is Control or node is Node2D:
		var property = "position" if node is Node2D else "position_offset"
		var current_pos = node.get(property)
		
		if relative:
			tween.tween_property(
				node,
				property,
				current_pos + to_offset,
				duration
			).from(current_pos + from_offset)
		else:
			tween.tween_property(
				node,
				property,
				to_offset,
				duration
			).from(from_offset)
