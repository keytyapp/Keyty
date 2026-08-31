//
//  AppSettingsContainer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

final class AppSettingsContainer {
    let store: KeyValueStore
    let appSettings: AppSettings
    let pointerRingSettings: PointerRingSettings
    let pointerRipplesSettings: PointerRipplesSettings
    let pointerIconSettings: PointerIconSettings
    let shortcutSettings: ShortcutSettings
    let keyboardVisualizerSettings: KeyboardVisualizerSettings
    private let settingsOwners: [any HasSettingsStore]

    init(store: KeyValueStore) {
        self.store = store

        let appSettings = AppSettings(store: store)
        let pointerRingSettings = PointerRingSettings(store: store)
        let pointerRipplesSettings = PointerRipplesSettings(store: store)
        let pointerIconSettings = PointerIconSettings(store: store)
        let shortcutSettings = ShortcutSettings(store: store)
        let keyboardVisualizerSettings = KeyboardVisualizerSettings(store: store)

        self.appSettings = appSettings
        self.pointerRingSettings = pointerRingSettings
        self.pointerRipplesSettings = pointerRipplesSettings
        self.pointerIconSettings = pointerIconSettings
        self.shortcutSettings = shortcutSettings
        self.keyboardVisualizerSettings = keyboardVisualizerSettings
        self.settingsOwners = [
            appSettings,
            pointerRingSettings,
            pointerRipplesSettings,
            pointerIconSettings,
            shortcutSettings,
            keyboardVisualizerSettings
        ]
        
        self.registerDefaults()
    }

    private func registerDefaults() {
        self.appSettings.registerDefaults()
        self.pointerRingSettings.registerDefaults()
        self.pointerRipplesSettings.registerDefaults()
        self.pointerIconSettings.registerDefaults()
        self.shortcutSettings.registerDefaults()
        self.keyboardVisualizerSettings.registerDefaults()
    }

    func resetAllSettingsToDefaults() {
        self.appSettings.resetToDefaults()
        self.pointerRingSettings.resetToDefaults()
        self.pointerRipplesSettings.resetToDefaults()
        self.pointerIconSettings.resetToDefaults()
        self.shortcutSettings.resetToDefaults()
        self.keyboardVisualizerSettings.resetToDefaults()
    }

    var transferableSettings: [AnyStoredSetting] {
        self.settingsOwners.flatMap(\.storedSettings)
    }
}
