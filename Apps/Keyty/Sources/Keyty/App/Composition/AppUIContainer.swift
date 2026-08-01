//
//  AppUIContainer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Sparkle

@MainActor
final class AppUIContainer {
    let aboutWindowController: AboutWindowController
    let keyboardVisualizerPlacementWindowController: KeyboardVisualizerPlacementWindowController
    let permissionsOnboardingWindowController: PermissionsOnboardingWindowController
    let settingsWindowController: SettingsWindowController

    init(
        settings: AppSettingsContainer,
        services: AppServiceContainer,
        updater: SPUUpdater
    ) {
        aboutWindowController = AboutWindowController()
        let keyboardVisualizerPlacementWindowController = KeyboardVisualizerPlacementWindowController(
            settings: settings.keyboardVisualizerSettings
        )
        self.keyboardVisualizerPlacementWindowController = keyboardVisualizerPlacementWindowController
        permissionsOnboardingWindowController = PermissionsOnboardingWindowController(
            permissionsService: services.permissionsService
        )
        settingsWindowController = SettingsWindowController(
            shortcutManager: services.shortcutManager,
            appSettings: settings.appSettings,
            pointerRingVisualizer: services.pointerVisualizersManager.ring,
            pointerRingSettings: settings.pointerRingSettings,
            pointerIconSettings: settings.pointerIconSettings,
            keyboardVisualizerSettings: settings.keyboardVisualizerSettings,
            startSettingKeyboardVisualizerPosition: { [weak keyboardVisualizerPlacementWindowController] onPlacementChanged in
                keyboardVisualizerPlacementWindowController?.startSettingPosition(onPlacementChanged: onPlacementChanged)
            },
            stopSettingKeyboardVisualizerPosition: { [weak keyboardVisualizerPlacementWindowController] in
                keyboardVisualizerPlacementWindowController?.stopSettingPosition()
            },
            permissionsService: services.permissionsService,
            updater: updater
        )
    }
}
