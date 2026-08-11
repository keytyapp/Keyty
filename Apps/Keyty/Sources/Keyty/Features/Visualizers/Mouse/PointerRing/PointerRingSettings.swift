//
//  PointerRingSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

protocol PointerRingSettingsProtocol: AnyObject {
    var isEnabled: Bool { get set }
    var alwaysVisible: Bool { get set }
    var color: NSColor { get set }
    var size: CGFloat { get set }
    var thickness: CGFloat { get set }
    var shape: PointerRingShape { get set }

    func registerDefaults()
    func resetToDefaults()
}

private struct PointerRingVisualSettingsSnapshot: Equatable {
    let alwaysVisible: Bool
    let colorHex: String
    let size: CGFloat
    let thickness: CGFloat
    let shape: PointerRingShape
}

final class PointerRingSettings: PointerRingSettingsProtocol, ReactiveSettings, HasSettingsStore {
    let store: KeyValueStore
    private var visualSettingsSnapshot: PointerRingVisualSettingsSnapshot?
    private let changesSubject = PassthroughSubject<Void, Never>()
    private var storeChangesCancellable: AnyCancellable?

    var changes: AnyPublisher<Void, Never> {
        self.changesSubject.eraseToAnyPublisher()
    }

    init(store: KeyValueStore = UserDefaultsStore()) {
        self.store = store
        self.storeChangesCancellable = self.store.changes
            .sink { [weak self] in
                self?.storeDidChange()
            }
        self.visualSettingsSnapshot = self.currentVisualSettingsSnapshot
    }

    @Stored(.bool(PointerRingSettingsKeys.isEnabled, default: PointerRingSettingsKeys.defaultIsEnabled))
    var isEnabled: Bool

    @Stored(.bool(PointerRingSettingsKeys.alwaysVisible, default: PointerRingSettingsKeys.defaultAlwaysVisible))
    var alwaysVisible: Bool

    @Stored(.color(PointerRingSettingsKeys.color, default: PointerRingSettingsKeys.automaticVisualizerColor))
    var color: NSColor

    @Stored(.cgFloat(
        PointerRingSettingsKeys.size,
        default: PointerRingSettingsKeys.defaultSize,
        clamp: PointerRingSettingsKeys.sizeRange
    ))
    private var storedSize: CGFloat

    var size: CGFloat {
        get { self.storedSize }
        set { self.storedSize = newValue }
    }

    @Stored(.cgFloat(
        PointerRingSettingsKeys.thickness,
        default: PointerRingSettingsKeys.defaultThickness,
        clamp: PointerRingSettingsKeys.thicknessRange
    ))
    private var storedThickness: CGFloat

    var thickness: CGFloat {
        get { self.storedThickness }
        set { self.storedThickness = newValue }
    }

    @Stored(.enum(PointerRingSettingsKeys.shape, default: PointerRingSettingsKeys.defaultShape))
    var shape: PointerRingShape
    
    private var currentVisualSettingsSnapshot: PointerRingVisualSettingsSnapshot {
        PointerRingVisualSettingsSnapshot(
            alwaysVisible: self.alwaysVisible,
            colorHex: self.color.hexString,
            size: self.size,
            thickness: self.thickness,
            shape: self.shape
        )
    }

    func registerDefaults() {
        self.registerStoredDefaults()
        self.visualSettingsSnapshot = self.currentVisualSettingsSnapshot
    }

    func resetToDefaults() {
        self.resetStoredSettingsToDefaults()
    }

    private func storeDidChange() {
        let snapshot = self.currentVisualSettingsSnapshot
        guard snapshot != self.visualSettingsSnapshot else { return }
        self.visualSettingsSnapshot = snapshot

        self.changesSubject.send(())
    }
}
