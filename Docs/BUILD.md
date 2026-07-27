# Building Keyty

## Requirements

- **macOS** 11.0 or later
- **Xcode** 16 or later
- **Swift** 5.0
- **Tuist** 4.x

## Cloning

```bash
git clone https://github.com/keytyapp/Keyty.git
cd Keyty
```

## Dependencies

Dependencies are managed via **Swift Package Manager** and resolved automatically by Xcode on first open or build. No manual installation is required.

| Package | Version |
|---|---|
| [AppMover](https://github.com/linearmouse/AppMover) | `a578bf4` |
| [ShortcutRecorder](https://github.com/Kentzo/ShortcutRecorder) | 3.4.0 |
| [Sparkle](https://github.com/sparkle-project/Sparkle) | 2.9.4 |

## Project Generation

Install Tuist, then generate the Xcode project from the checked-in manifest:

```bash
brew install tuist
cd Apps/Keyty
tuist generate
```

## Building in Xcode

1. `cd Apps/Keyty`
2. Run `tuist generate`.
3. Open `Keyty.xcodeproj` in Xcode.
4. Select the **Keyty** scheme from the scheme picker.
5. Choose your target destination (My Mac).
6. Press **Cmd+B** to build, or **Cmd+R** to build and run.

## Building from the Command Line

### Debug build

```bash
cd Apps/Keyty
tuist generate
xcodebuild build \
  -project Keyty.xcodeproj \
  -scheme Keyty \
  -configuration Debug
```

### Release build

```bash
cd Apps/Keyty
tuist generate
xcodebuild build \
  -project Keyty.xcodeproj \
  -scheme Keyty \
  -configuration Release
```

### Archive (for distribution)

```bash
cd Apps/Keyty
tuist generate
xcodebuild archive \
  -project Keyty.xcodeproj \
  -scheme Keyty \
  -configuration Release \
  -archivePath build/Keyty.xcarchive
```

## Packaging

The drag-to-`Applications` DMG is a release artifact, not part of routine debug or CI builds.
Install the pinned release packaging dependencies for the CI-compatible branded
DMG backend:

```bash
python3 -m venv .venv-release
.venv-release/bin/python -m pip install --upgrade pip
.venv-release/bin/python -m pip install -r requirements-release.txt
export KEYTY_DMG_PYTHON="$PWD/.venv-release/bin/python"
```

Build it from a signed release app bundle with:

```bash
scripts/build-dmg.sh \
  --app build/release/Keyty.app \
  --output dist/Keyty.dmg
```

The packaging script uses `dmgbuild` when it is installed. If `dmgbuild` is not
available locally, it falls back to the older Finder AppleScript backend. CI
requires `dmgbuild` so packaging does not depend on an interactive Finder
session.

For the full signed, notarized release flow, including the Sparkle zip and GitHub release artifacts, use the release automation documented in [RELEASING.md](RELEASING.md).

## Running Tests

```bash
cd Apps/Keyty
tuist generate
xcodebuild test \
  -project Keyty.xcodeproj \
  -scheme Keyty \
  -destination 'platform=macOS'
```

## Code Signing

Keyty observes input through macOS Accessibility APIs, so local builds should use
a stable Apple Development signature. Avoid adding `CODE_SIGNING_ALLOWED=NO` to
local builds: ad-hoc code signatures can change between builds, and macOS may
silently drop the app's Accessibility grant.

The checked-in project settings use the maintainer team `NEVA4MAZBL`. To build
and run locally with your own signing identity, sign in to Xcode with your Apple
ID and change the team in **Signing & Capabilities** after generating the
project.

Unsigned builds are only for non-interactive CI jobs that do not need a stable
Accessibility permission grant. The CI-only unsigned flags live in
[`.github/workflows/build.yml`](../.github/workflows/build.yml).
