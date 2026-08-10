# Releasing Keyty

## Prerequisites

- Developer ID signing and notarization must be set up in Xcode
- Access to the GitHub repository and releases page
- Access to the appcast published at `https://keyty.app/appcast.xml`

The release lane signs with the maintainer Developer ID team by default:

| Setting | Default | Override |
|---|---|---|
| Developer ID team | `NEVA4MAZBL` | `KEYTY_RELEASE_TEAM_ID` |
| Release signing identity | `Developer ID Application` | `KEYTY_RELEASE_CODE_SIGN_IDENTITY` |
| Local notarytool profile | `Keyty-Notary` | `KEYTY_NOTARY_PROFILE` |
| Sparkle enclosure URL prefix | Current GitHub release asset URL | `APPCAST_DOWNLOAD_PREFIX` |

Contributor/local development signing is separate from release signing. Local
builds should use a stable Apple Development signature so macOS keeps the app's
Accessibility grant; release builds require a Developer ID certificate and
notarization credentials.

For local notarization, create the default profile once:

```bash
xcrun notarytool store-credentials Keyty-Notary \
  --apple-id <apple-id> \
  --team-id NEVA4MAZBL \
  --password <app-specific-password>
```

Alternatively, set `NOTARY_APPLE_ID` and `NOTARY_PASSWORD` for a one-off local
run, or use the CI-style `NOTARY_KEY_PATH`, `NOTARY_KEY_ID`, and
`NOTARY_ISSUER` API key variables.

## GitHub Release Workflow

The `Release` workflow runs on tags matching `v*` and can also be started
manually from GitHub Actions. It runs `bundle exec fastlane release`, creates
the GitHub release, and uploads the generated `dist/` directory as an Actions
artifact named `appcast-artifacts`.

Configure these repository secrets before running the workflow:

| Secret | Description |
|---|---|
| `DEVELOPER_ID_CERTIFICATE_BASE64` | Base64-encoded `.p12` containing the Developer ID Application certificate and private key |
| `DEVELOPER_ID_CERTIFICATE_PASSWORD` | Password for the `.p12` certificate |
| `RELEASE_KEYCHAIN_PASSWORD` | Temporary keychain password used by the workflow |
| `NOTARY_KEY_BASE64` | Base64-encoded App Store Connect API key `.p8` for notarization |
| `NOTARY_KEY_ID` | App Store Connect API key ID |
| `NOTARY_ISSUER` | App Store Connect issuer ID |
| `SPARKLE_ED_KEY_BASE64` | Base64-encoded Sparkle EdDSA private key |
| `HOMEBREW_TAP_DISPATCH_TOKEN` | Optional token with permission to dispatch workflows in `keytyapp/homebrew-tap`; when present, the release workflow triggers the tap repo's cask-update automation after publishing `v*` release assets |

Optionally configure these repository variables:

| Variable | Description |
|---|---|
| `APPCAST_DOWNLOAD_PREFIX` | Sparkle enclosure URL prefix. By default, the release lane uses the current GitHub release asset URL, such as `https://github.com/keytyapp/Keyty/releases/download/v0.8.0/` |
| `KEYTY_RELEASE_TEAM_ID` | Developer ID team, default `NEVA4MAZBL` |

The release workflow uploads generated appcast artifacts as an Actions artifact.
Publish `appcast.xml` from that artifact through the Vercel-hosted site so
Sparkle reads `https://keyty.app/appcast.xml`. Update archives are hosted as
GitHub release assets by default.

When `HOMEBREW_TAP_DISPATCH_TOKEN` is configured, the same workflow also
dispatches `keyty_release_published` to `keytyapp/homebrew-tap` with the new
release version, tag, DMG URL, and DMG SHA-256 so the tap repo can open its own
cask update pull request.

Before generating a new appcast, the release lane downloads the currently
published appcast from `https://keyty.app/appcast.xml` into the Sparkle input
directory. Sparkle then updates that feed with the new release and preserves all
existing appcast items. If the feed returns `404`, the lane starts a new appcast;
other fetch failures stop the lane before creating the GitHub release.

## Distribution Artifacts

- `Keyty.zip` is the Sparkle update archive and the input to appcast generation.
- `Keyty.dmg` is the manual-download artifact attached to the GitHub release.
- The stable artifact names support GitHub's latest-release download URLs, for example `https://github.com/keytyapp/Keyty/releases/latest/download/Keyty.dmg`.
- Appcast generation reads the zip from an appcast-only directory so the DMG is
  not scanned as a duplicate update.
- The production appcast is cumulative. Previous appcast items keep their
  original tag-specific GitHub asset URLs, while the new item uses the current
  release tag.
- The DMG is built by [`scripts/build-dmg.sh`](../scripts/build-dmg.sh) from the signed app bundle and includes a drag-to-`Applications` layout.
- `dmgbuild` is the preferred branded DMG backend because it does not require an interactive Finder session. The packaging script falls back to the older Finder AppleScript backend when `dmgbuild` is unavailable locally.

## Beta Distribution

Use the beta lane when you need signed and notarized artifacts for local testing
or direct distribution, but do not want to create a GitHub release, update the
Sparkle appcast, or publish anything to Vercel:

```bash
bundle exec fastlane beta
```

The beta lane writes artifacts to `dist/beta/`:

- `Keyty.zip`
- `Keyty.dmg`

You can override the version or build number for a one-off test:

```bash
bundle exec fastlane beta version:0.8.0 build:123
```

## Release Checklist

1. Update the app version in the Xcode project build settings:
   - `MARKETING_VERSION` for the user-facing version
   - `CURRENT_PROJECT_VERSION` for the build number used by Sparkle
2. Commit the version changes and any release packaging updates.
3. Create an annotated tag for the release, for example:

```bash
git tag -a v<NEW_VERSION> -m "Version <NEW_VERSION>"
```

4. Push the release commit and tag:

```bash
git push origin HEAD
git push --tags
```

5. Let the GitHub `Release` workflow build, sign, notarize, staple, and create the GitHub release.
6. Confirm the GitHub release contains both the zipped app and the DMG.
7. Download the `appcast-artifacts` workflow artifact and publish `appcast.xml` through the Vercel-hosted site.
8. Verify the published appcast artifacts are available at the feed host:
   - `https://keyty.app/appcast.xml`
   - `https://github.com/keytyapp/Keyty/releases/download/v<NEW_VERSION>/Keyty.zip`
   - `https://github.com/keytyapp/Keyty/releases/latest/download/Keyty.dmg`
9. Inspect the `appcast-artifacts` workflow artifact if you need to verify the exact files generated:
   - `appcast/Keyty.zip` for Sparkle
   - `Keyty.dmg` for GitHub Releases/manual downloads
   - `appcast.xml`
10. Update the Homebrew cask if needed.

## Local Release Fallback

Use the local Fastlane lane only when intentionally releasing from a maintainer
Mac instead of GitHub Actions. Do not run both paths for the same version.

The lane regenerates the Tuist Xcode project, builds the signed app, notarizes
it, staples it, creates the Sparkle zip, builds the DMG, notarizes the DMG, and
publishes both GitHub release artifacts:

```bash
bundle exec fastlane release
```

After it completes, publish the updated `dist/appcast.xml` through the
Vercel-hosted site.
