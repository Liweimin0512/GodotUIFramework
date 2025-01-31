# Godot UI Framework

<div align="center">

[English](README.md) | [简体中文](README_zh.md)

![Godot v4.x](https://img.shields.io/badge/Godot-v4.x-478cbf?logo=godot-engine&logoColor=white)
[![GitHub license](https://img.shields.io/github/license/Liweimin0512/GodotUIFramework)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/Liweimin0512/GodotUIFramework)](https://github.com/Liweimin0512/GodotUIFramework/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/Liweimin0512/GodotUIFramework)](https://github.com/Liweimin0512/GodotUIFramework/issues)
[![GitHub forks](https://img.shields.io/github/forks/Liweimin0512/GodotUIFramework)](https://github.com/Liweimin0512/GodotUIFramework/network)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

一个为Godot 4.x设计的高度模块化、易扩展的UI框架

[快速开始](#快速开始) •
[文档](#文档) •
[示例](#示例) •
[贡献](CONTRIBUTING.md) •
[支持](#支持)

</div>

## ✨ 特性

- 🎯 **模块化设计**：每个功能都是独立的模块，可以根据需要启用或禁用
- 🔌 **插件式架构**：轻松扩展和自定义功能
- 🎨 **主题系统**：灵活的主题管理，支持动态切换
- 🌍 **本地化支持**：完整的多语言解决方案
- ✨ **动画系统**：丰富的过渡动画效果
- 📱 **响应式布局**：适配不同屏幕尺寸
- 🎮 **游戏友好**：专为游戏UI设计，支持各种游戏特定功能
- 🔧 **易于集成**：简单的设置过程，少量配置
- 📦 **组件库**：丰富的预建UI组件
- 🛠️ **开发工具**：内置调试和开发工具

## 🚀 快速开始

### 前提条件

- Godot Engine 4.x
- 基本的GDScript和Godot UI系统知识

### 安装

1. 从[发布页面](https://github.com/Liweimin0512/GodotUIFramework/releases)下载最新版本
2. 将`GodotUIFramework`文件夹复制到你的Godot项目的`addons`目录下
3. 在Godot编辑器中启用插件：项目 -> 项目设置 -> 插件 -> GodotUIFramework -> 启用

### 快速上手

```gdscript
# 初始化UI管理器
func _ready():
    UIManager.init()
    
# 创建一个简单的UI场景
var scene = UIScene.new()
scene.add_widget(UILabel.new("你好，世界！"))
UIManager.show_scene(scene)
```

## 📚 文档

查看我们的[文档](docs/)获取详细信息：

- [快速入门指南](docs/getting_started.md)
- [主题系统](docs/theme.md)
- [本地化](docs/localization.md)
- [动画系统](docs/transition.md)
- [布局系统](docs/layout.md)
- [组件](docs/widgets.md)
- [API参考](docs/api.md)

## 🎮 示例

查看我们的[示例](examples/)目录获取更多演示：

- 主题切换示例
- 多语言切换示例
- 动画效果展示
- 响应式布局示例
- 完整的游戏UI实现

## 🤝 贡献

我们欢迎任何形式的贡献！请在提交任何更改之前阅读我们的[贡献指南](CONTRIBUTING.md)。

### 开发环境设置

```bash
# 克隆仓库
git clone https://github.com/Liweimin0512/GodotUIFramework.git

# 在Godot中打开项目
# 运行测试以确保一切正常
```

## 📄 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 💖 支持

如果你遇到任何问题或有任何建议：

1. 查看[文档](docs/)
2. 搜索[已存在的issues](https://github.com/Liweimin0512/GodotUIFramework/issues)
3. 创建新的[issue](https://github.com/Liweimin0512/GodotUIFramework/issues/new)

### 社区

- 加入我们的[Discord服务器](https://discord.gg/your-discord-link)
- 关注我们的[Twitter](https://twitter.com/your-twitter-handle)
- 为项目点赞 ⭐ 以显示你的支持！

## 🙏 致谢

- 感谢所有为这个项目做出贡献的开发者！
- 特别感谢[老李游戏学院](https://wx.zsxq.com/group/28885154818841)的每一位同学！
- 由Godot社区用 ❤️ 构建

---

<div align="center">
由Liweimin0512用 ❤️ 构建
</div>
