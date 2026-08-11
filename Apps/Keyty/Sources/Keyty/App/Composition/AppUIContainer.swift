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
        self.aboutWindowController = AboutWindowController()
        let keyboardVisualizerPlacementWindowController = KeyboardVisualizerPlacementWindowController(
            settings: settings.keyboardVisualizerSettings
        )
        self.keyboardVisualizerPlacementWindowController = keyboardVisualizerPlacementWindowController
        self.permissionsOnboardingWindowController = PermissionsOnboardingWindowController(
            permissionsService: services.permissionsService
        )
        let settingsContext = SettingsContext(
            settings: settings,
            shortcutManager: services.shortcutManager,
            pointerRingVisualizer: services.pointerVisualizersManager.ring,
            permissionsService: services.permissionsService,
            updater: updater,
            placementCoordinator: keyboardVisualizerPlacementWindowController
        )
        let settingsWindowController = SettingsWindowController(context: settingsContext)
        self.settingsWindowController = settingsWindowController
    }
}
