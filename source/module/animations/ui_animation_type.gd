# ui_animation_type.gd
@tool
extends Resource
class_name UIAnimationType

## 动画ID
@export var id: StringName
## 动画播放延迟（秒）
@export var play_delay: float = 0.0
## 动画完成延迟（秒）
@export var complete_delay: float = 0.0
## 前置动画ID列表
@export var prerequisite_animations: Array[StringName] = []
## 前置事件名称列表
@export var prerequisite_events: Array[StringName] = []
## 是否自动播放
@export var auto_play: bool = false
## 动画时长
@export var duration: float = 0.3
## 动画曲线
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
## 动画过渡类型
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR

## 创建动画
func create_tween(target: Node) -> Tween:
    return null

## 获取总时长（包括延迟）
func get_total_duration() -> float:
    return play_delay + duration + complete_delay