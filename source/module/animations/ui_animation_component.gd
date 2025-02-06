# ui_animation_component.gd
@tool
extends Node
class_name UIAnimationComponent

## 动画开始信号
signal animation_started(id: StringName)
## 动画完成信号
signal animation_completed(id: StringName)
## 所有动画完成信号
signal all_animations_completed

## 动画配置字典
@export var animations: Array[UIAnimationType] = []

## 运行中的动画
var _running_animations: Dictionary = {}
## 等待前置条件的动画
var _pending_animations: Array[StringName] = []
## 已完成的动画
var _completed_animations: Array[StringName] = []

## 播放指定动画
func play_animation(id: StringName) -> void:
    var anim = _find_animation(id)
    if not anim:
        return
        
    # 检查前置条件
    if _check_prerequisites(anim):
        _start_animation(anim)
    else:
        _pending_animations.append(id)

## 播放所有动画
func play_all_animations() -> void:
    for anim in animations:
        if anim.auto_play:
            play_animation(anim.id)

## 停止动画
func stop_animation(id: StringName) -> void:
    if _running_animations.has(id):
        _running_animations[id].kill()
        _running_animations.erase(id)

## 检查前置条件
func _check_prerequisites(anim: UIAnimationType) -> bool:
    # 检查前置动画
    for prereq_id in anim.prerequisite_animations:
        if not _completed_animations.has(prereq_id):
            return false
    return true

## 开始播放动画
func _start_animation(anim: UIAnimationType) -> void:
    var tween = anim.create_tween(get_parent())
    _running_animations[anim.id] = tween
    
    animation_started.emit(anim.id)
    
    # 动画完成回调
    tween.finished.connect(func():
        _running_animations.erase(anim.id)
        _completed_animations.append(anim.id)
        animation_completed.emit(anim.id)
        
        # 检查等待的动画
        var pending_copy = _pending_animations.duplicate()
        _pending_animations.clear()
        for pending_id in pending_copy:
            play_animation(pending_id)
            
        # 检查是否所有动画都完成了
        if _running_animations.is_empty():
            all_animations_completed.emit()
    )