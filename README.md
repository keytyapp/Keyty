<h1 align="center">
  <a href="https://keyty.app">
    <img src="Assets/Application/AppIcon/AppIcon.png" alt="Keyty app logo" width="128">
    <br />
    <strong>Keyty</strong>
  </a>
  <br>
</h1>

<div align="center">
   <img src="https://img.shields.io/github/v/release/keytyapp/Keyty?style=flat-square" alt="Releases">
   <img src="https://img.shields.io/github/downloads/keytyapp/Keyty/total?style=flat-square" alt="Downloads">
   <img src="https://img.shields.io/github/stars/keytyapp/Keyty?style=flat-square" alt="Stars">
   <img src="https://img.shields.io/github/license/keytyapp/Keyty?style=flat-square" alt="License">
   <img src="https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square" alt="Platform Support">
</div>

<p align="center">
  <a href="README.md">English</a> |
  <a href="Docs/README.de.md">Deutsch</a> |
  <a href="Docs/README.es.md">Español</a> |
  <a href="Docs/README.fr.md">Français</a> |
  <a href="Docs/README.pl.md">Polski</a> |
  <a href="Docs/README.uk.md">Українська</a> |
  <a href="Docs/README.ja.md">日本語</a> |
  <a href="Docs/README.zh-Hans.md">简体中文</a>
</p>

Keyty is a free, open-source app that visualizes your keyboard and mouse actions in real time,
  making demos, presentations, tutorials, and livestreams easier to follow. It gives your audience a
  clear view of every shortcut, click, and input so you can communicate more effectively on screen.

## Features

### Keyboard

![Keyboard Demo](Docs/Resources/demo.gif)

- Real-time display of keyboard shortcuts, special keys, and typed input
- Customizable overlay styles, themes, size, layout, and fade timing
- Filters for modified keystrokes, special keys, media keys, and mouse events

### Mouse

<p>
  <img src="Docs/Resources/ring_demo.gif" alt="Pointer ring demo" width="49%">
  <img src="Docs/Resources/pointer_icon_demo.gif" alt="Pointer icon demo" width="49%">
</p>

- Visualize mouse clicks and scroll actions alongside keyboard input
- Pointer highlight ring with configurable shape, color, size, and thickness
- Pointer icon overlay with adjustable position, size, background, and tint

## Customization

Keyty can be tuned from Settings to match your workflow and presentation style:

- **Appearance:** Choose keyboard overlay styles, themes, colors, and size.
- **History:** Keep a visual trail of your recent inputs.
- **Filters:** Control whether modified keystrokes, special keys, media keys, and mouse events appear.
- **Mouse:** Configure pointer rings and pointer icons, including visibility, shape, color, size, offset, background, and tint.
- **Placement:** Pick the display, screen anchor, margin, and stacking direction.

## Installation

### GitHub

Download the latest release from [GitHub](https://github.com/keytyapp/Keyty/releases)

### Homebrew

```bash
brew install --cask keytyapp/tap/keyty
```

### Build from Source

To build Keyty locally from source, see [BUILD.md](Docs/BUILD.md).

## Permissions

Keyty requires your permission to receive events from macOS in order to display your keystrokes and mouse clicks. See [PERMISSIONS.md](Docs/PERMISSIONS.md) for setup and troubleshooting.

## Privacy

Input events are processed locally on your Mac. Keyty does not record, store, or upload your keystrokes, typed text, mouse clicks, or pointer activity. See [PRIVACY.md](Docs/PRIVACY.md) for details, including Sparkle update checks.

## Support

If Keyty is useful to you, consider giving the project a ⭐ on GitHub. It helps more people discover it and is the easiest way to support its development.
