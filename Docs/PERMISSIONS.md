# Permissions

Keyty needs macOS privacy permission to capture and display keyboard and mouse activity. If this permission is missing or granted to the wrong app build, input events may not appear in the overlay.

## Required Permissions

Keyty supports the following macOS permissions:

- `Input Monitoring` (preferred): allows Keyty to passively observe the input events needed for keyboard and mouse visualization.
- `Accessibility` (fallback): remains supported for existing installs and grants.

## Granting Permissions

To grant permissions on current macOS versions:

1. Open **System Settings**.
2. Go to **Privacy & Security**.
3. Open **Input Monitoring** and enable `Keyty`.
4. Restart Keyty if macOS asks you to do so.

Accessibility remains available as a fallback in Keyty's **Permissions** pane, but only one of these permissions is required.

If `Keyty` is not listed yet, launch the app once and return to these settings after macOS has registered it.

## Permissions in App

Keyty includes a **Permissions** pane in Settings that shows the current status of both permissions and provides an **Open Settings** action when access has not been granted.

Use this pane when setting up a fresh install or when diagnosing why input events are not being captured.

## Troubleshooting

If Keyty is running but no keyboard or mouse activity appears:

1. Quit Keyty.
2. Open **System Settings > Privacy & Security**.
3. Check **Input Monitoring** and **Accessibility** for existing `Keyty` entries that refer to an older app build or moved app bundle.
4. Launch Keyty again.
5. Re-enable `Keyty` in **Input Monitoring**.
6. Restart the app if macOS requires it.

Common causes:

- The granted permission points to a different copy of the app than the one currently running
- macOS has not refreshed the permission state until the app is restarted

For debug builds launched from Xcode, permission issues are especially common after rebuilding, moving, or renaming the app bundle.

### Last-Resort Permission Reset

If the app is still listed in System Settings but macOS does not deliver input events, reset Keyty's saved privacy decisions and grant the permissions again:

1. Quit Keyty.
2. Run:

   ```bash
   tccutil reset ListenEvent app.keyty.Keyty
   ```

3. Launch Keyty.
4. Re-enable `Keyty` in **Input Monitoring**.
5. Restart Keyty if macOS asks you to do so.

These commands reset only Keyty's entries for the relevant privacy services. Avoid broader resets such as `tccutil reset All` unless you intentionally want macOS to forget privacy decisions for other apps too.

## Related Docs

- [DEVELOPING.md](DEVELOPING.md) for local development workflow
- [BUILD.md](BUILD.md) for build and test commands
