# UIFramework 快速入门

## 安装

1. 将 `GodotUIFramework` 文件夹复制到你的项目的 `addons` 目录下
2. 在Godot编辑器中启用插件：Project -> Project Settings -> Plugins -> GodotUIFramework -> Enable

## 基本概念

UIFramework 基于以下核心概念：

- **视图组件(UIViewComponent)**: 所有UI组件的基类，提供数据绑定和生命周期管理
- **场景组件(UISceneComponent)**: 处理场景级别的功能，如场景切换和数据流
- **分组组件(UIGroupComponent)**: 管理一组相关场景，处理场景堆栈
- **部件组件(UIWidgetComponent)**: 可重用的UI组件，支持对象池管理

## 快速开始

### 1. 创建场景

```gdscript
# game_scene.tscn
# 添加UISceneComponent节点到场景根节点

# game_scene.gd
extends Control

@onready var ui_scene_component: UISceneComponent = $UISceneComponent

func _ready() -> void:
    # 监听场景事件
    ui_scene_component.initialized.connect(_on_scene_initialized)
    ui_scene_component.data_updated.connect(_on_data_updated)

func _on_scene_initialized(data: Dictionary) -> void:
    # 处理初始数据
    var player_data = data.get("player", {})
    update_player_info(player_data)

func _on_data_updated(path: String, value: Variant) -> void:
    # 处理数据更新
    match path:
        "player.hp":
            update_hp_bar(value)
```

### 2. 创建分组

```gdscript
# main.tscn
# 添加UIGroupComponent节点到场景根节点

# main.gd
extends Control

@onready var ui_group_component: UIGroupComponent = $UIGroupComponent

func _ready() -> void:
    # 注册分组
    UIManager.register_group("main", ui_group_component)
    
    # 切换到初始场景
    ui_group_component.switch_scene("main_menu", {
        "player": {
            "name": "Player1",
            "level": 1
        }
    })
```

### 3. 创建可重用部件

```gdscript
# hp_bar.tscn
# 添加UIWidgetComponent节点到部件根节点

# hp_bar.gd
extends Control

@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
    ui_widget_component.initialized.connect(_on_widget_initialized)
    ui_widget_component.data_updated.connect(_on_data_updated)

func _on_widget_initialized(data: Dictionary) -> void:
    progress_bar.max_value = data.get("max", 100)
    progress_bar.value = data.get("current", 0)

func _on_data_updated(path: String, value: Variant) -> void:
    match path:
        "current":
            progress_bar.value = value
        "max":
            progress_bar.max_value = value
```

### 4. 使用部件

```gdscript
# player_info.gd
extends Control

@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

func _ready() -> void:
    # 创建血条
    var hp_bar = ui_widget_component.create_widget("hp_bar", self, {
        "current": 100,
        "max": 100
    })
```

## 数据绑定

框架提供了响应式的数据绑定系统：

```gdscript
# 更新数据
ui_scene_component.update_data("player.hp", 80)

# 监听数据更新
func _on_data_updated(path: String, value: Variant) -> void:
    match path:
        "player.hp":
            hp_bar.value = value
        "player.name":
            name_label.text = value
```

## 场景管理

使用分组组件管理场景：

```gdscript
# 创建新场景
ui_group_component.create_scene("game_scene", initial_data)

# 切换场景
ui_group_component.switch_scene("battle_scene", battle_data)

# 关闭当前场景
ui_group_component.close_scene(current_scene)
```

## 最佳实践

1. 组件化设计
   - 将UI逻辑封装在对应的组件中
   - 使用信号进行组件间通信
   - 保持组件的独立性

2. 数据管理
   - 使用响应式数据绑定
   - 保持数据流向清晰
   - 合理组织数据结构

3. 资源管理
   - 使用对象池管理频繁创建的UI元素
   - 及时释放不需要的资源
   - 注意内存使用
