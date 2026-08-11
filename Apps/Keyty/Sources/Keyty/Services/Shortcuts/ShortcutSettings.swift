//
//  ShortcutSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

protocol ShortcutSettingsProtocol: AnyObject {
    var capturingHotKeyData: Data? { get set }

    func registerDefaults()
    func resetToDefaults()
}

final class ShortcutSettings: ShortcutSettingsProtocol, HasSettingsStore {
    static let capturingHotKeyKey = "capturingHotKey"

    let store: KeyValueStore

    init(store: KeyValueStore = UserDefaultsStore()) {
        self.store = store
    }

    @Stored(.data(ShortcutSettings.capturingHotKeyKey, default: ShortcutArchiver.defaultShortcutData()))
    var capturingHotKeyData: Data?

    func registerDefaults() {
        self.registerStoredDefaults()
    }

    func resetToDefaults() {
        self.resetStoredSettingsToDefaults()
    }
}
