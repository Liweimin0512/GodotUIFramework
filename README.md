# Godot UI Framework

一个为Godot 4.x设计的高度模块化、易扩展的UI框架。

## 特性

- 🎯 **模块化设计**：每个功能都是独立的模块，可以根据需要启用或禁用
- 🔌 **插件式架构**：轻松扩展和自定义功能
- 🎨 **主题系统**：灵活的主题管理，支持动态切换
- 🌍 **本地化支持**：完整的多语言解决方案
- ✨ **动画系统**：丰富的过渡动画效果
- 📱 **响应式布局**：适配不同屏幕尺寸
- 🎮 **游戏友好**：专为游戏UI设计，支持各种游戏特定功能

## 安装

1. 下载最新版本的框架
2. 将`GodotUIFramework`文件夹复制到你的Godot项目的`addons`目录下
3. 在Godot编辑器中启用插件：项目 -> 项目设置 -> 插件 -> GodotUIFramework -> 启用

## 快速开始

```gdscript
# 初始化UI管理器
func _ready():
    UIManager.init()
    
# 创建一个简单的UI场景
var scene = UIScene.new()
scene.add_widget(UILabel.new("Hello, World!"))
UIManager.show_scene(scene)
```

## 文档

详细文档请查看 [docs](docs/) 目录：

- [快速入门](docs/getting_started.md)
- [主题系统](docs/theme.md)
- [本地化](docs/localization.md)
- [动画系统](docs/transition.md)
- [布局系统](docs/layout.md)
- [组件](docs/widgets.md)

## 示例

查看 [examples](examples/) 目录获取更多示例：

- 主题切换示例
- 多语言切换示例
- 动画效果示例
- 响应式布局示例

## 贡献

我们欢迎任何形式的贡献！请查看我们的[贡献指南](CONTRIBUTING.md)。

## 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 支持

如果你遇到任何问题或有任何建议，请：

1. 查看[文档](docs/)
2. 搜索[已存在的issues](https://github.com/Liweimin0512/GodotUIFramework/issues)
3. 创建新的[issue](https://github.com/Liweimin0512/GodotUIFramework/issues/new)

## 鸣谢

感谢所有为这个项目做出贡献的开发者！
感谢老李的知识星球[老李游戏学院](https://wx.zsxq.com/group/28885154818841)的每一位同学！