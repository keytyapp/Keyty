# Developing Keyty

This guide covers the local contributor workflow for building, running, testing, and debugging Keyty.

## Prerequisites

- macOS 11.0 or later
- Xcode 16 or later
- A local clone of this repository

## Setup

Clone the repository and open the Xcode project:

```bash
git clone https://github.com/keytyapp/Keyty.git
cd Keyty
brew install tuist
cd Apps/Keyty
tuist generate
open Keyty.xcodeproj
```

Dependencies are managed with Swift Package Manager and should resolve automatically in Xcode.

## Build and Run

For detailed build commands, see [BUILD.md](BUILD.md).

The usual local workflow is:

1. `cd Apps/Keyty`
2. Run `tuist generate` after manifest or dependency changes.
3. Open `Keyty.xcodeproj` in Xcode.
4. Select the `Keyty` scheme.
5. Choose `My Mac` as the run destination.
6. Press `Cmd+R` to build and run.

You can also build and test from the command line with `xcodebuild` if you prefer a terminal-driven workflow.

## Running Tests

Run the test suite from Xcode with `Cmd+U`, or use the `xcodebuild test` command documented in [BUILD.md](BUILD.md).

## Permissions for Local Development

Keyty needs macOS `Accessibility` permission to capture and visualize input events, including when running a debug build from Xcode.

If a local build is not receiving events correctly, the most common cause is stale or missing macOS permission entries for the running app bundle.

For setup and troubleshooting steps, see [PERMISSIONS.md](PERMISSIONS.md).

## Repository Layout

The main project lives under `Apps/Keyty`.

- `Apps/Keyty/Sources/Keyty/App`: app lifecycle, dependency wiring, menus, and shell integration
- `Apps/Keyty/Sources/Keyty/Features`: settings UI and visualizer features
- `Apps/Keyty/Sources/Keyty/Platform`: event capture, permissions, screens, and platform-specific integrations
- `Apps/Keyty/Sources/Keyty/Services`: event transformation, display formatting, shortcuts, presence, and app settings
- `Apps/Keyty/Sources/Keyty/Domain`: core event and keyboard models
- `Apps/Keyty/Sources/Keyty/Presentation`: design tokens and shared presentation assets
- `Apps/Keyty/Sources/Keyty/Resources`: plist, localized strings, icons, and bundled assets
- `Apps/Keyty/Tests/KeytyTests`: unit and feature-level tests

## Common Issues

- No keyboard or mouse events appear:
  Check macOS permissions first. Old app references in **Accessibility** are a common cause.
- Swift packages do not resolve:
  Reopen the project in Xcode and let Swift Package Manager refresh dependencies.
- Xcode project changes are missing:
  Re-run `tuist generate` from `Apps/Keyty` to regenerate `Keyty.xcodeproj` from `Project.swift`.
- The app builds but behaves differently from a release build:
  Confirm you are testing the correct build configuration and that the running app instance is the same one granted in macOS permissions.

## Related Docs

- [BUILD.md](BUILD.md) for Xcode and `xcodebuild` workflows
- [PERMISSIONS.md](PERMISSIONS.md) for macOS permission setup and troubleshooting
- [RELEASING.md](RELEASING.md) for the release process
