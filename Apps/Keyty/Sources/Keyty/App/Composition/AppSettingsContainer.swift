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
    let appSettings: any AppSettingsProtocol
    let pointerRingSettings: any PointerRingSettingsProtocol & ReactiveSettings
    let pointerRipplesSettings: any PointerRipplesSettingsProtocol & ReactiveSettings
    let pointerIconSettings: any PointerIconSettingsProtocol & ReactiveSettings
    let shortcutSettings: any ShortcutSettingsProtocol
    let keyboardVisualizerSettings: KeyboardVisualizerSettings

    init(store: KeyValueStore) {
        self.store = store

        self.appSettings = AppSettings(store: store)
        self.pointerRingSettings = PointerRingSettings(store: store)
        self.pointerRipplesSettings = PointerRipplesSettings(store: store)
        self.pointerIconSettings = PointerIconSettings(store: store)
        self.shortcutSettings = ShortcutSettings(store: store)
        self.keyboardVisualizerSettings = KeyboardVisualizerSettings(store: store)
        
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
}
