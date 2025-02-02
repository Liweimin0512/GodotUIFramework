@tool
extends UITransitionResource
class_name UIPathTransition

## 路径类型

## 路径节点
var path: Path2D
## 起始位置（0-1）
@export var from_offset: float = 0.0
## 目标位置（0-1）
@export var to_offset: float = 1.0
## 是否跟随路径旋转
@export var rotate: bool = false
## 是否使用相对位置
@export var relative: bool = true

func apply_transition(node: Node, tween: Tween) -> void:
	if not path:
		push_error("No path set for UIPathTransition")
		return
		
	var curve = path.curve
	if not curve:
		push_error("No curve in path for UIPathTransition")
		return
		
	var start_point = curve.sample_baked(curve.get_baked_length() * from_offset)
	var end_point = curve.sample_baked(curve.get_baked_length() * to_offset)
	
	if node is Control:
		var start_pos = start_point if not relative else node.position + start_point
		var end_pos = end_point if not relative else node.position + end_point
		
		tween.tween_method(
			_update_control_position.bind(node, start_pos, end_pos),
			0.0,
			1.0,
			duration
		)
	elif node is Node2D:
		var start_pos = start_point if not relative else node.position + start_point
		var end_pos = end_point if not relative else node.position + end_point
		
		tween.tween_method(
			_update_node2d_position.bind(node, start_pos, end_pos),
			0.0,
			1.0,
			duration
		)

func _update_control_position(progress: float, node: Control, start_pos: Vector2, end_pos: Vector2) -> void:
	if not path:
		return
		
	var curve = path.curve
	var length = curve.get_baked_length()
	var current_offset = lerp(from_offset, to_offset, progress)
	var point = curve.sample_baked(length * current_offset)
	
	if relative:
		point += start_pos.lerp(end_pos, progress)
	
	node.position = point
	
	if rotate:
		var next_point = curve.sample_baked(length * min(current_offset + 0.01, 1.0))
		var angle = (next_point - point).angle()
		node.rotation = angle

func _update_node2d_position(progress: float, node: Node2D, start_pos: Vector2, end_pos: Vector2) -> void:
	if not path:
		return
		
	var curve = path.curve
	var length = curve.get_baked_length()
	var current_offset = lerp(from_offset, to_offset, progress)
	var point = curve.sample_baked(length * current_offset)
	
	if relative:
		point += start_pos.lerp(end_pos, progress)
	
	node.position = point
	
	if rotate:
		var next_point = curve.sample_baked(length * min(current_offset + 0.01, 1.0))
		var angle = (next_point - point).angle()
		node.rotation = angle
