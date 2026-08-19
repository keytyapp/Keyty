//
//  SettingsContext.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Sparkle

@MainActor
final class SettingsContext {
    let settings: AppSettingsContainer
    let shortcutManager: ShortcutManager
    let pointerRingVisualizer: PointerRingVisualizer
    let pointerRipplesVisualizer: PointerRipplesVisualizer
    let permissionsService: any PermissionsService
    let updater: SPUUpdater
    let placementCoordinator: any KeyboardVisualizerPlacementCoordinating

    var appSettings: any AppSettingsProtocol { self.settings.appSettings }
    var pointerRingSettings: any PointerRingSettingsProtocol { self.settings.pointerRingSettings }
    var pointerRipplesSettings: any PointerRipplesSettingsProtocol { self.settings.pointerRipplesSettings }
    var pointerIconSettings: any PointerIconSettingsProtocol { self.settings.pointerIconSettings }
    var keyboardVisualizerSettings: KeyboardVisualizerSettings { self.settings.keyboardVisualizerSettings }

    init(
        settings: AppSettingsContainer,
        shortcutManager: ShortcutManager,
        pointerRingVisualizer: PointerRingVisualizer,
        pointerRipplesVisualizer: PointerRipplesVisualizer,
        permissionsService: any PermissionsService,
        updater: SPUUpdater,
        placementCoordinator: any KeyboardVisualizerPlacementCoordinating
    ) {
        self.settings = settings
        self.shortcutManager = shortcutManager
        self.pointerRingVisualizer = pointerRingVisualizer
        self.pointerRipplesVisualizer = pointerRipplesVisualizer
        self.permissionsService = permissionsService
        self.updater = updater
        self.placementCoordinator = placementCoordinator
    }

    func resetAllSettingsToDefaults() {
        self.settings.resetAllSettingsToDefaults()
    }
}
