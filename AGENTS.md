# AGENTS.md

## Project

Keyty is a Tuist-managed macOS app for visualizing keyboard and mouse input. The main app lives in `Apps/Keyty`.

Use the existing docs instead of duplicating them:

- Build/test workflow: `Docs/BUILD.md`
- Contributor workflow: `Docs/DEVELOPING.md`
- macOS permissions: `Docs/PERMISSIONS.md`
- Releases: `Docs/RELEASING.md`

## Commands

From `Apps/Keyty`:

```bash
tuist generate
xcodebuild build \
  -project Keyty.xcodeproj \
  -scheme Keyty \
  -configuration Debug

xcodebuild test \
  -project Keyty.xcodeproj \
  -scheme Keyty \
  -destination 'platform=macOS'
```

Debug builds are signed with the `Apple Development` identity (see `appDebugSettings`
in `Project.swift`). Do not add `CODE_SIGNING_ALLOWED=NO` to local builds: it falls back
to ad-hoc signing, whose code hash changes on every build, and macOS then silently drops
the app's Accessibility grant. Both targets write to the same Debug
products directory, so an unsigned test run invalidates the grants of a signed build too.
CI (`.github/workflows/build.yml`) has no signing identity and keeps those flags.

Run `tuist generate` after changing `Project.swift`, dependencies, build settings, resources, or generated project structure.

## Git Workflow

- Use Conventional Commits for commit messages and branch names.
- Branch names should follow `<type>/<short-description>`, for example `fix/menu-bar-position` or `feat/input-overlay-theme`.
- Commit messages should follow `<type>(<scope>): <description>` when a scope is useful, for example `fix(settings): clamp overlay opacity`.

## Code Style

- Follow the existing Swift style: explicit `self.`, small focused types, protocol-backed services/settings, and XCTest coverage near the touched feature.
- New Swift source files should use the existing file header with BSD-3-Clause SPDX metadata.
- Keep app composition under `App/Composition`; keep platform APIs under `Platform`; keep transformation, formatting, settings, shortcuts, and presence logic under `Services`; keep domain models under `Domain`.
- Prefer existing helpers and extensions before adding new abstractions.
- For reusable helpers on Apple types that are not project-specific, prefer shared Foundation/AppKit extensions, such as `TimeInterval.nanoseconds`, instead of private helpers in feature views.
- Avoid broad refactors unless they are necessary for the requested change.

## UI and Presentation

- Use `Apps/Keyty/Sources/Keyty/Presentation` tokens for spacing, sizing, typography, colors, stroke widths, and radii.
- Do not introduce raw spacing, padding, fixed frame sizes, or corner radii when a token exists.
- Add shared UI primitives under `Features/Settings` or `Presentation` only when reuse is clear.
- User-facing strings should go through localized resources and the generated `L10n` accessors where practical.

## Settings and State

- Use the existing `KeyValueStore`, `StoredSetting`, and settings container patterns for persisted preferences.
- Clamp or sanitize user-controlled numeric settings at the model/settings layer.
- Use reactive settings publishers when a value affects live placement or rendering.

## Tests

- Add or update focused XCTest coverage for behavior changes.
- Match test paths to source areas under `Apps/Keyty/Tests/KeytyTests`.
- Event transformer tests may depend on keyboard layout behavior; preserve existing assumptions unless intentionally changing them.
