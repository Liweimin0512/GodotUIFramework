# source/module/transition/ui_transition_manager.gd
extends RefCounted
class_name UITransitionManager

## 

## 全局动画配置
var config: Dictionary = {
	"default_duration": 0.3,
	"default_trans_type": Tween.TRANS_QUAD,
	"default_ease_type": Tween.EASE_IN_OUT
}

## 预设动画资源
var presets: Dictionary = {}

## 加载预设动画
func load_preset(name: String, transition: UITransitionResource) -> void:
	presets[name] = transition

## 获取预设动画
func get_preset(name: String) -> UITransitionResource:
	return presets.get(name)

## 移除预设动画
func remove_preset(name: String) -> void:
	presets.erase(name)

## 清除所有预设动画
func clear_presets() -> void:
	presets.clear()

## 创建淡入动画
func create_fade_in() -> UIFadeTransition:
	var transition = UIFadeTransition.new()
	transition.from_alpha = 0.0
	transition.to_alpha = 1.0
	transition.duration = config.default_duration
	transition.trans_type = config.default_trans_type
	transition.ease_type = config.default_ease_type
	return transition

## 创建淡出动画
func create_fade_out() -> UIFadeTransition:
	var transition = UIFadeTransition.new()
	transition.from_alpha = 1.0
	transition.to_alpha = 0.0
	transition.duration = config.default_duration
	transition.trans_type = config.default_trans_type
	transition.ease_type = config.default_ease_type
	return transition

## 创建滑入动画
func create_slide_in(direction: Vector2 = Vector2.RIGHT) -> UISlideTransition:
	var transition = UISlideTransition.new()
	transition.from_offset = direction * 100
	transition.to_offset = Vector2.ZERO
	transition.duration = config.default_duration
	transition.trans_type = config.default_trans_type
	transition.ease_type = config.default_ease_type
	return transition

## 创建滑出动画
func create_slide_out(direction: Vector2 = Vector2.RIGHT) -> UISlideTransition:
	var transition = UISlideTransition.new()
	transition.from_offset = Vector2.ZERO
	transition.to_offset = direction * 100
	transition.duration = config.default_duration
	transition.trans_type = config.default_trans_type
	transition.ease_type = config.default_ease_type
	return transition

## 创建缩放进入动画
func create_scale_in() -> UIScaleTransition:
	var transition = UIScaleTransition.new()
	transition.from_scale = Vector2.ZERO
	transition.to_scale = Vector2.ONE
	transition.duration = config.default_duration
	transition.trans_type = config.default_trans_type
	transition.ease_type = config.default_ease_type
	return transition

## 创建缩放退出动画
func create_scale_out() -> UIScaleTransition:
	var transition = UIScaleTransition.new()
	transition.from_scale = Vector2.ONE
	transition.to_scale = Vector2.ZERO
	transition.duration = config.default_duration
	transition.trans_type = config.default_trans_type
	transition.ease_type = config.default_ease_type
	return transition

## 创建路径动画
func create_path_transition(path: Path2D) -> UIPathTransition:
	var transition = UIPathTransition.new()
	transition.path = path
	transition.duration = config.default_duration
	transition.trans_type = config.default_trans_type
	transition.ease_type = config.default_ease_type
	return transition
