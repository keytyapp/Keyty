//
//  SettingsContext.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

@MainActor
final class SettingsContext {
    let settings: AppSettingsContainer
    let shortcutManager: ShortcutManager
    let pointerRingVisualizer: PointerRingVisualizer
    let pointerRipplesVisualizer: PointerRipplesVisualizer
    let permissionsService: any PermissionsService
    let updateService: any UpdateService
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
        updateService: any UpdateService,
        placementCoordinator: any KeyboardVisualizerPlacementCoordinating
    ) {
        self.settings = settings
        self.shortcutManager = shortcutManager
        self.pointerRingVisualizer = pointerRingVisualizer
        self.pointerRipplesVisualizer = pointerRipplesVisualizer
        self.permissionsService = permissionsService
        self.updateService = updateService
        self.placementCoordinator = placementCoordinator
    }

    func resetAllSettingsToDefaults() {
        self.settings.resetAllSettingsToDefaults()
    }
}
