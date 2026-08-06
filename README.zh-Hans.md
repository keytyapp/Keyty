<h1 align="center">
  <a href="https://keyty.app">
    <img src="Assets/Application/AppIcon/AppIcon.png" alt="Keyty 应用标志" width="128">
    <br />
    <strong>Keyty</strong>
  </a>
  <br>
</h1>

<div>
   <img src="https://img.shields.io/github/v/release/keytyapp/Keyty?style=flat-square" alt="版本">
   <img src="https://img.shields.io/github/downloads/keytyapp/Keyty/total?style=flat-square" alt="下载量">
   <img src="https://img.shields.io/github/stars/keytyapp/Keyty?style=flat-square" alt="Star 数">
   <img src="https://img.shields.io/github/license/keytyapp/Keyty?style=flat-square" alt="许可证">
   <img src="https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square" alt="平台支持">
</div>

Keyty 是一款免费开源应用，可实时可视化你的键盘和鼠标操作，
  让演示、演讲、教程和直播更容易被观众跟上。它会清晰展示每一个快捷键、
  点击和输入内容，帮助你更有效地在屏幕上进行讲解。

## 功能

### 键盘

![键盘演示](Docs/Resources/demo.gif)

- 实时显示键盘快捷键、特殊按键和输入的文本
- 可自定义叠加层样式、主题、大小、布局和淡出时间
- 支持过滤修饰键组合、特殊按键、多媒体按键和鼠标事件

### 鼠标

<p>
  <img src="Docs/Resources/ring_demo.gif" alt="指针高亮环演示" width="49%">
  <img src="Docs/Resources/pointer_icon_demo.gif" alt="指针图标演示" width="49%">
</p>

- 与键盘输入一起可视化鼠标点击和滚动操作
- 指针高亮环支持配置形状、颜色、大小和粗细
- 指针图标叠加层支持调整位置、大小、背景和色调

## 自定义

你可以在“设置”中调整 Keyty，使其匹配你的工作流和演示风格：

- **外观：** 选择键盘叠加层样式、主题、颜色和大小。
- **历史记录：** 保留最近输入的可视化轨迹。
- **过滤器：** 控制是否显示修饰键组合、特殊按键、多媒体按键和鼠标事件。
- **鼠标：** 配置指针高亮环和指针图标，包括可见性、形状、颜色、大小、偏移、背景和色调。
- **位置：** 选择显示器、屏幕锚点、边距和堆叠方向。

## 安装

### GitHub

从 [GitHub](https://github.com/keytyapp/Keyty/releases) 下载最新版本

### Homebrew

```bash
brew install --cask keytyapp/tap/keyty
```

### 从源码构建

如需在本地从源码构建 Keyty，请参阅 [BUILD.md](Docs/BUILD.md)。

## 权限

Keyty 需要获得你的授权，才能接收来自 macOS 的事件并显示按键和鼠标点击。有关设置和故障排除，请参阅 [PERMISSIONS.md](Docs/PERMISSIONS.md)。

## 隐私

输入事件仅在你的 Mac 本地处理。Keyty 不会记录、存储或上传你的按键、输入文本、鼠标点击或指针活动。更多细节（包括 Sparkle 更新检查）请参阅 [PRIVACY.md](Docs/PRIVACY.md)。

## 支持

如果 Keyty 对你有帮助，欢迎在 GitHub 上给项目点一个 ⭐。这能帮助更多人发现这个项目，也是支持项目开发最简单的方式。
