//
//  AppServiceContainer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

@MainActor
final class AppServiceContainer {
    let permissionsService: any PermissionsService
    let pointerVisualizersManager: PointerVisualizersManager
    let keyboardVisualizer: KeyboardVisualizer
    let shortcutManager: ShortcutManager
    let captureController: CaptureController

    init(
        settings: AppSettingsContainer,
        statusShortcutItem: NSMenuItem
    ) {
        let pointerVisualizersManager = PointerVisualizersManager(
            pointerRingSettings: settings.pointerRingSettings,
            pointerIconSettings: settings.pointerIconSettings
        )
        let keyboardVisualizer = KeyboardVisualizer(settings: settings.keyboardVisualizerSettings)
        keyboardVisualizer.activate()
        let permissionsService = SystemPermissionsService()
        let captureController = CaptureController(
            pointerVisualizersManager: pointerVisualizersManager,
            keyboardVisualizer: keyboardVisualizer,
            permissionsService: permissionsService
        )
        let shortcutManager = ShortcutManager(
            settings: settings.shortcutSettings,
            menuItemPresenter: ShortcutMenuItemPresenter(
                statusShortcutItem: statusShortcutItem
            ),
            onToggleCapturingShortcut: { [weak captureController] in
                captureController?.toggleCapturing()
            }
        )

        self.permissionsService = permissionsService
        self.pointerVisualizersManager = pointerVisualizersManager
        self.keyboardVisualizer = keyboardVisualizer
        self.shortcutManager = shortcutManager
        self.captureController = captureController
    }
}
