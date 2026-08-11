//
//  PointerIconSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

protocol PointerIconSettingsProtocol: AnyObject {
    var isEnabled: Bool { get set }
    var alwaysVisible: Bool { get set }
    var anchor: PointerIconAnchor { get set }
    var offset: CGFloat { get set }
    var backgroundColor: NSColor { get set }
    var tintColor: NSColor { get set }
    var sizeIndex: Int { get set }
    var iconSize: NSSize { get }

    func registerDefaults()
    func resetToDefaults()
}

final class PointerIconSettings: PointerIconSettingsProtocol, ReactiveSettings, HasSettingsStore {
    let store: KeyValueStore
    private let changesSubject = PassthroughSubject<Void, Never>()
    private var storeChangesCancellable: AnyCancellable?

    init(store: KeyValueStore = UserDefaultsStore()) {
        self.store = store
        storeChangesCancellable = store.changes
            .sink { [weak self] in
                self?.storeDidChange()
            }
    }

    var changes: AnyPublisher<Void, Never> {
        self.changesSubject.eraseToAnyPublisher()
    }

    @Stored(.bool(PointerIconSettingsKeys.isEnabled, default: false))
    var isEnabled: Bool

    @Stored(.bool(PointerIconSettingsKeys.alwaysVisible, default: PointerIconSettingsKeys.defaultAlwaysVisible))
    var alwaysVisible: Bool

    @Stored(.enum(PointerIconSettingsKeys.anchor, default: PointerIconSettingsKeys.defaultAnchor))
    var anchor: PointerIconAnchor

    @Stored(.cgFloat(PointerIconSettingsKeys.offset, default: PointerIconSettingsKeys.defaultOffset))
    private var storedOffset: CGFloat

    var offset: CGFloat {
        get { self.storedOffset >= 0 ? self.storedOffset : PointerIconSettingsKeys.defaultOffset }
        set { self.storedOffset = max(0, newValue) }
    }

    @Stored(.color(PointerIconSettingsKeys.backgroundColor, default: PointerIconSettingsKeys.defaultBackgroundColor))
    var backgroundColor: NSColor

    @Stored(.color(PointerIconSettingsKeys.tintColor, default: PointerIconSettingsKeys.defaultTintColor))
    var tintColor: NSColor

    @Stored(.int(PointerIconSettingsKeys.size, default: PointerIconSettingsKeys.defaultSizeIndex))
    private var storedSizeIndex: Int

    var sizeIndex: Int {
        get {
            let index = self.storedSizeIndex
            guard index >= 0, index < PointerIconSettingsKeys.iconSizes.count else {
                return PointerIconSettingsKeys.defaultSizeIndex
            }
            return index
        }
        set {
            self.storedSizeIndex = min(max(0, newValue), PointerIconSettingsKeys.iconSizes.count - 1)
        }
    }

    var iconSize: NSSize {
        PointerIconSettingsKeys.iconSizes[sizeIndex]
    }

    func registerDefaults() {
        self.registerStoredDefaults()
    }

    func resetToDefaults() {
        self.resetStoredSettingsToDefaults()
    }

    private func storeDidChange() {
        self.changesSubject.send()
    }
}
