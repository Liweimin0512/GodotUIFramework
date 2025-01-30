# 动画模块

动画模块提供了一套完整的UI动画解决方案，支持场景切换和控件动画效果。该模块采用组件化设计，通过资源系统实现动画的配置和复用。

## 特性

- 基于Tween的高性能动画系统
- 资源化的动画配置
- 组件化的使用方式
- 支持多种动画类型
- 支持自定义动画路径
- 预设动画管理

## 动画资源

### UITransitionResource

基础动画资源类，定义了动画的基本属性：

```gdscript
@export var duration: float = 0.3           # 动画时长
@export var trans_type: Tween.TransitionType # 动画缓动类型
@export var ease_type: Tween.EaseType       # 缓动曲线
@export var auto_start: bool = true         # 是否自动启动
```

### 内置动画类型

1. **UIFadeTransition** - 淡入淡出动画
```gdscript
@export var from_alpha: float = 0.0  # 初始透明度
@export var to_alpha: float = 1.0    # 目标透明度
```

2. **UISlideTransition** - 滑动动画
```gdscript
@export var from_offset: Vector2     # 起始位置偏移
@export var to_offset: Vector2       # 目标位置偏移
@export var relative: bool = true    # 是否相对于当前位置
```

3. **UIScaleTransition** - 缩放动画
```gdscript
@export var from_scale: Vector2      # 起始缩放
@export var to_scale: Vector2        # 目标缩放
@export var pivot: Vector2           # 缩放中心点
@export var relative: bool = true    # 是否相对于当前缩放
```

4. **UIPathTransition** - 路径动画
```gdscript
@export var path: Path2D            # 路径节点
@export var from_offset: float      # 起始位置（0-1）
@export var to_offset: float        # 目标位置（0-1）
@export var rotate: bool = false    # 是否跟随路径旋转
@export var relative: bool = true   # 是否使用相对位置
```

## 动画组件

### UITransitionComponent

基础动画组件，提供动画控制功能：

```gdscript
@export var transition: UITransitionResource  # 动画资源

# 方法
func start()   # 开始动画
func stop()    # 停止动画
func pause()   # 暂停动画
func resume()  # 恢复动画
func reset()   # 重置动画
```

### UIWidgetTransitionComponent

控件动画组件，支持多种动画类型：

```gdscript
enum TransitionType {
    ENTER,      # 进入动画
    EXIT,       # 退出动画
    EMPHASIS,   # 强调动画
    PATH,       # 路径动画
    CUSTOM      # 自定义动画
}

@export var enter_transition: UITransitionResource     # 进入动画
@export var exit_transition: UITransitionResource      # 退出动画
@export var emphasis_transition: UITransitionResource  # 强调动画
@export var path_transition: UITransitionResource     # 路径动画
@export var custom_transition: UITransitionResource   # 自定义动画

# 信号
signal transition_finished(type: TransitionType)  # 动画完成信号

# 方法
func play_enter()    # 播放进入动画
func play_exit()     # 播放退出动画
func play_emphasis() # 播放强调动画
func play_path()     # 播放路径动画
func play_custom()   # 播放自定义动画
```

## 动画管理器

UITransitionManager提供全局动画管理功能：

```gdscript
# 全局配置
var config: Dictionary = {
    "default_duration": 0.3,
    "default_trans_type": Tween.TRANS_QUAD,
    "default_ease_type": Tween.EASE_IN_OUT
}

# 预设动画管理
func load_preset(name: String, transition: UITransitionResource)
func get_preset(name: String) -> UITransitionResource
func remove_preset(name: String)
func clear_presets()

# 便捷创建方法
func create_fade_in() -> UIFadeTransition
func create_fade_out() -> UIFadeTransition
func create_slide_in(direction: Vector2 = Vector2.RIGHT) -> UISlideTransition
func create_slide_out(direction: Vector2 = Vector2.RIGHT) -> UISlideTransition
func create_scale_in() -> UIScaleTransition
func create_scale_out() -> UIScaleTransition
func create_path_transition(path: Path2D) -> UIPathTransition
```

## 使用示例

### 1. 基础动画

```gdscript
# 创建淡入动画组件
@onready var fade_component = $FadeComponent
fade_component.transition = UIManager.transition_manager.create_fade_in()
fade_component.start()
```

### 2. 控件动画

```gdscript
# 创建控件动画组件
@onready var widget_component = $WidgetComponent

# 配置不同类型的动画
widget_component.enter_transition = UIManager.transition_manager.create_slide_in()
widget_component.exit_transition = UIManager.transition_manager.create_fade_out()
widget_component.emphasis_transition = UIManager.transition_manager.create_scale_in()

# 播放动画
widget_component.play_enter()  # 播放进入动画
await widget_component.transition_finished  # 等待动画完成
widget_component.play_exit()   # 播放退出动画
```

### 3. 路径动画

```gdscript
# 创建路径动画
@onready var path_component = $PathComponent
@onready var path = $Path2D

# 配置路径动画
var path_transition = UIManager.transition_manager.create_path_transition(path)
path_transition.rotate = true  # 启用旋转
path_component.transition = path_transition

# 播放动画
path_component.start()
```

### 4. 预设动画

```gdscript
# 创建并保存预设动画
var slide_right = UIManager.transition_manager.create_slide_in(Vector2.RIGHT)
UIManager.transition_manager.load_preset("slide_right", slide_right)

# 使用预设动画
var transition = UIManager.transition_manager.get_preset("slide_right")
component.transition = transition
```

## 最佳实践

1. **动画资源复用**：
   - 将常用的动画配置保存为预设
   - 在同类型的UI元素间共享动画资源

2. **性能优化**：
   - 适当设置动画时长，避免过长的动画时间
   - 当节点不可见时停止动画
   - 及时清理不需要的动画组件

3. **动画设计**：
   - 为不同类型的UI元素设计合适的动画效果
   - 注意动画的连贯性和流畅度
   - 避免过于复杂的动画效果影响用户体验

4. **错误处理**：
   - 检查动画资源是否正确加载
   - 处理动画播放过程中可能出现的异常
   - 在动画完成后进行必要的清理工作
