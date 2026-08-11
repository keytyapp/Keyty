//
//  AppSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

protocol AppSettingsProtocol: AnyObject {
    var visibleAtLaunch: Bool { get set }

    func registerDefaults()
    func resetToDefaults()
}

final class AppSettings: AppSettingsProtocol, HasSettingsStore {
    static let visibleAtLaunchKey = "alwaysShowSettings"

    let store: KeyValueStore

    init(store: KeyValueStore = UserDefaultsStore()) {
        self.store = store
    }

    @Stored(.bool(AppSettings.visibleAtLaunchKey, default: true))
    var visibleAtLaunch: Bool

    func registerDefaults() {
        self.registerStoredDefaults()
    }

    func resetToDefaults() {
        self.resetStoredSettingsToDefaults()
    }
}
