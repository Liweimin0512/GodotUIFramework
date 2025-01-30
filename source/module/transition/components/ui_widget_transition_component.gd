@tool
extends UITransitionComponent
class_name UIWidgetTransitionComponent

## UI控件动画组件

## 动画类型
enum TransitionType {
	ENTER,      ## 进入动画
	EXIT,       ## 退出动画
	EMPHASIS,   ## 强调动画
	PATH,       ## 路径动画
	CUSTOM      ## 自定义动画
}

## 当前动画类型
@export var type: TransitionType = TransitionType.ENTER:
	set(value):
		type = value
		notify_property_list_changed()

## 进入动画
@export var enter_transition: UITransitionResource
## 退出动画
@export var exit_transition: UITransitionResource
## 强调动画
@export var emphasis_transition: UITransitionResource
## 路径动画
@export var path_transition: UITransitionResource
## 自定义动画
@export var custom_transition: UITransitionResource

## 动画完成信号
signal transition_finished(type: TransitionType)

func _ready() -> void:
	# 根据类型设置当前动画
	_update_current_transition()

## 更新当前动画
func _update_current_transition() -> void:
	match type:
		TransitionType.ENTER:
			transition = enter_transition
		TransitionType.EXIT:
			transition = exit_transition
		TransitionType.EMPHASIS:
			transition = emphasis_transition
		TransitionType.PATH:
			transition = path_transition
		TransitionType.CUSTOM:
			transition = custom_transition

## 播放指定类型的动画
func play(transition_type: TransitionType) -> void:
	type = transition_type
	_update_current_transition()
	start()
	
	if _current_tween:
		_current_tween.finished.connect(
			func(): transition_finished.emit(transition_type),
			CONNECT_ONE_SHOT
		)

## 播放进入动画
func play_enter() -> void:
	play(TransitionType.ENTER)

## 播放退出动画
func play_exit() -> void:
	play(TransitionType.EXIT)

## 播放强调动画
func play_emphasis() -> void:
	play(TransitionType.EMPHASIS)

## 播放路径动画
func play_path() -> void:
	play(TransitionType.PATH)

## 播放自定义动画
func play_custom() -> void:
	play(TransitionType.CUSTOM)
