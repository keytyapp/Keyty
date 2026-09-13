# Privacy

Keyty visualizes keyboard and mouse activity on screen. Because that requires observing input events, Keyty asks macOS for Input Monitoring permission. Accessibility remains available as a fallback for existing installs.

## Input Events

Keyboard and mouse events are processed locally on your Mac for real-time visualization.

Keyty does not record, store, or upload:

- Keystrokes
- Typed text
- Captured shortcut activity
- Mouse clicks
- Scroll events
- Pointer movement

Input events are used only to render the active visual overlays.

## Local Settings

Keyty stores app preferences locally using macOS user defaults. These preferences include settings such as overlay style, colors, size, visibility, display placement, and the configured toggle shortcut.

Stored settings do not include a history of captured keyboard or mouse activity.

## Network Access

Keyty does not include analytics or third-party tracking.

Network access is limited to:

- Sparkle update checks against the configured update feed
- Links opened by the user, such as GitHub, the website, feedback email, or documentation

## Update Checks

Keyty uses Sparkle for app updates. If automatic update checks are enabled, Sparkle may periodically contact the configured update feed to check for new versions.

If the anonymous system profile option is enabled in Settings, Sparkle update checks may include basic system information used for update compatibility and aggregate update statistics.

Automatic update checks and anonymous system profile sharing can be controlled from Keyty's Update settings.

## Permissions

Input Monitoring permission is preferred so Keyty can observe input events and render them in the overlay. Accessibility remains a supported fallback; only one permission is required.

For setup and troubleshooting details, see [PERMISSIONS.md](PERMISSIONS.md).
