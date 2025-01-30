@tool
extends Node
class_name UITransitionComponent

## UI动画组件

## 动画资源
@export var transition: UITransitionResource:
	set(value):
		transition = value
		notify_property_list_changed()

## 当前补间动画
var _current_tween: Tween

## 开始动画
func start() -> void:
	if not transition:
		push_error("No transition resource set")
		return
		
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		
	_current_tween = transition.create_tween(self)
	transition.apply_transition(get_parent(), _current_tween)
	
	if transition.auto_start:
		_current_tween.play()

## 停止动画
func stop() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		_current_tween = null

## 暂停动画
func pause() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.pause()

## 恢复动画
func resume() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.play()

## 重置动画
func reset() -> void:
	stop()
	start()
