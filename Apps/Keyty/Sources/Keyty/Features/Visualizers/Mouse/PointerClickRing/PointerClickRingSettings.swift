//
//  PointerClickRingSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

protocol PointerClickRingSettingsProtocol: AnyObject {
    var isEnabled: Bool { get set }
    var color: NSColor { get set }
    var size: CGFloat { get set }
    var thickness: CGFloat { get set }
    var shape: PointerRingShape { get set }

    func registerDefaults()
    func resetToDefaults()
}

final class PointerClickRingSettings: PointerClickRingSettingsProtocol, ReactiveSettings, HasSettingsStore {
    let store: KeyValueStore
    private var visualSettingsSnapshot: VisualSettingsSnapshot?
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

    @Stored(.bool(PointerClickRingSettingsKeys.isEnabled, default: PointerClickRingSettingsKeys.defaultIsEnabled))
    var isEnabled: Bool

    @Stored(.color(PointerClickRingSettingsKeys.color, default: PointerClickRingSettingsKeys.automaticVisualizerColor))
    var color: NSColor

    @Stored(.cgFloat(
        PointerClickRingSettingsKeys.size,
        default: PointerClickRingSettingsKeys.defaultSize,
        clamp: PointerClickRingSettingsKeys.sizeRange
    ))
    private var storedSize: CGFloat

    var size: CGFloat {
        get { self.storedSize }
        set { self.storedSize = newValue }
    }

    @Stored(.cgFloat(
        PointerClickRingSettingsKeys.thickness,
        default: PointerClickRingSettingsKeys.defaultThickness,
        clamp: PointerClickRingSettingsKeys.thicknessRange
    ))
    private var storedThickness: CGFloat

    var thickness: CGFloat {
        get { self.storedThickness }
        set { self.storedThickness = newValue }
    }

    @Stored(.enum(PointerClickRingSettingsKeys.shape, default: PointerClickRingSettingsKeys.defaultShape))
    var shape: PointerRingShape

    private var currentVisualSettingsSnapshot: VisualSettingsSnapshot {
        VisualSettingsSnapshot(
            isEnabled: self.isEnabled,
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

private extension PointerClickRingSettings {
    struct VisualSettingsSnapshot: Equatable {
        let isEnabled: Bool
        let colorHex: String
        let size: CGFloat
        let thickness: CGFloat
        let shape: PointerRingShape
    }
}
