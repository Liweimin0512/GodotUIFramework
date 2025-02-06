# ui_scene_component.gd 的修改建议
@tool
extends UISceneComponent

## 场景动画组件
@onready var _animation_component: UIAnimationComponent = $UIAnimationComponent

func switch_scene(id: StringName, data: Dictionary = {}) -> Control:
    if _animation_component and _animation_component.animations.size() > 0:
        # 等待当前场景的退出动画
        await _animation_component.all_animations_completed
        
    var new_scene = _group.show_scene(id, data)
    
    if new_scene and _animation_component:
        _animation_component.play_all_animations()
    
    return new_scene