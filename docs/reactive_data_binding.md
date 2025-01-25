# 响应式数据绑定系统

## 概述

响应式数据绑定系统是UIFramework中的核心功能之一，它通过信号系统实现数据和UI的自动同步。当数据发生变化时，系统会自动通知相关组件进行更新，使UI始终保持与数据同步。

## 核心概念

### 数据路径

数据路径是一个字符串，用于表示数据在对象中的位置。例如：

- `"player.name"` - 表示玩家名称
- `"player.stats.hp"` - 表示玩家的生命值
- `"inventory.items[0]"` - 表示背包中的第一个物品

### 组件信号

UIViewComponent提供了以下数据相关的信号：

```gdscript
signal initialized(data: Dictionary)       # 组件初始化时触发
signal disposing(data: Dictionary)         # 组件销毁时触发
signal data_updating(path: String, value: Variant)  # 数据即将更新时触发
signal data_updated(path: String, value: Variant)   # 数据更新后触发
```

## 使用方式

### 1. 基础用法

```gdscript
# player_info.gd
extends Control

@onready var ui_view_component: UIViewComponent = $UIViewComponent
@onready var name_label: Label = $NameLabel
@onready var hp_bar: ProgressBar = $HPBar

func _ready() -> void:
    # 连接信号
    ui_view_component.initialized.connect(_on_initialized)
    ui_view_component.data_updated.connect(_on_data_updated)

func _on_initialized(data: Dictionary) -> void:
    # 处理初始数据
    name_label.text = data.get("name", "")
    hp_bar.value = data.get("hp", 0)
    hp_bar.max_value = data.get("max_hp", 100)

func _on_data_updated(path: String, value: Variant) -> void:
    # 处理数据更新
    match path:
        "name":
            name_label.text = value
        "hp":
            hp_bar.value = value
        "max_hp":
            hp_bar.max_value = value
```

### 2. 场景组件中的数据管理

```gdscript
# game_scene.gd
extends Control

@onready var ui_scene_component: UISceneComponent = $UISceneComponent

func _ready() -> void:
    ui_scene_component.initialized.connect(_on_scene_initialized)
    ui_scene_component.data_updated.connect(_on_data_updated)

func _on_scene_initialized(data: Dictionary) -> void:
    # 处理场景初始数据
    var player_data = data.get("player", {})
    var enemy_data = data.get("enemy", {})
    setup_battle(player_data, enemy_data)

func _on_data_updated(path: String, value: Variant) -> void:
    # 处理场景数据更新
    match path:
        "player.hp":
            update_player_hp(value)
        "enemy.hp":
            update_enemy_hp(value)
        "battle.turn":
            update_turn_counter(value)

# 更新数据
func deal_damage(target: String, amount: int) -> void:
    var path = "%s.hp" % target
    var current_hp = ui_scene_component.get_data(path)
    ui_scene_component.update_data(path, current_hp - amount)
```

### 3. 部件组件中的数据管理

```gdscript
# status_effect.gd
extends Control

@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent
@onready var icon: TextureRect = $Icon
@onready var duration: Label = $Duration

func _ready() -> void:
    ui_widget_component.initialized.connect(_on_widget_initialized)
    ui_widget_component.data_updated.connect(_on_data_updated)

func _on_widget_initialized(data: Dictionary) -> void:
    # 设置初始状态
    icon.texture = load(data.get("icon_path", ""))
    duration.text = str(data.get("duration", 0))

func _on_data_updated(path: String, value: Variant) -> void:
    match path:
        "duration":
            duration.text = str(value)
            if value <= 0:
                ui_widget_component.recycle()  # 自动回收
```

## 数据流向

1. **初始化流程**:
   - 组件创建时，通过`initialize()`方法设置初始数据
   - 触发`initialized`信号，组件更新UI显示
   - 子组件会在父组件初始化后自动初始化

2. **更新流程**:
   - 调用`update_data()`方法更新数据
   - 触发`data_updating`信号，允许预处理
   - 更新内部数据
   - 触发`data_updated`信号，组件更新UI显示

3. **销毁流程**:
   - 调用`dispose()`方法时触发`disposing`信号
   - 清理数据和UI资源
   - 对于Widget，可以选择回收到对象池

## 最佳实践

1. **数据结构设计**:
   - 使用清晰的数据路径命名
   - 避免过深的数据嵌套
   - 保持数据结构的一致性

2. **性能优化**:
   - 只监听必要的数据路径
   - 避免频繁的小数据更新
   - 合理使用批量更新

3. **代码组织**:
   - 在组件中集中处理数据逻辑
   - 使用match语句处理不同的数据路径
   - 保持更新处理函数的简洁

4. **调试技巧**:
   - 使用print语句跟踪数据更新
   - 检查信号连接是否正确
   - 验证数据路径的正确性

## 注意事项

1. 避免在数据更新处理中再次触发数据更新，可能导致循环
2. 注意数据类型的一致性，特别是在处理数值时
3. 合理管理组件的生命周期，确保正确清理资源
4. 使用类型提示和空值检查增加代码的健壮性
