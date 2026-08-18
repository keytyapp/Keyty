//
//  PointerClickRingVisualizer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

@MainActor
final class PointerClickRingVisualizer {
    private let settings: any PointerClickRingSettingsProtocol & ReactiveSettings
    private var clickRingWindows: [UUID: PointerClickRingWindow] = [:]
    private var cancellables = Set<AnyCancellable>()

    var isPresentationActive: Bool = false {
        didSet {
            guard self.isPresentationActive else {
                self.dismissAllClickRings()
                return
            }
        }
    }

    var isPresented: Bool {
        !self.clickRingWindows.isEmpty
    }

    var isEnabled: Bool {
        get { self.settings.isEnabled }
        set { self.settings.isEnabled = newValue }
    }

    init(settings: any PointerClickRingSettingsProtocol & ReactiveSettings = PointerClickRingSettings()) {
        self.settings = settings
        self.settings.changes
            .sink { [weak self] in
                Task { @MainActor in
                    self?.settingsDidChange()
                }
            }
            .store(in: &self.cancellables)
    }
}

// MARK: - PointerVisualizer
extension PointerClickRingVisualizer: PointerVisualizer {
    func display(_ mouseEvent: MouseEvent) {
        guard self.isEnabled, self.isPresentationActive else { return }
        guard PointerRingAnimation.eventPhase(for: mouseEvent.type) == .press else { return }
        self.presentClickRing(at: mouseEvent.screenLocation)
    }
}

private extension PointerClickRingVisualizer {
    func settingsDidChange() {
        guard !self.settings.isEnabled else { return }
        self.dismissAllClickRings()
    }

    func presentClickRing(at screenLocation: NSPoint) {
        let window = PointerClickRingWindow(
            style: .init(
                color: self.settings.color,
                size: self.settings.size,
                thickness: self.settings.thickness,
                shape: self.settings.shape
            ),
            center: screenLocation
        ) { [weak self] identifier in
            self?.clickRingWindows.removeValue(forKey: identifier)
        }
        self.clickRingWindows[window.ringID] = window
        window.present()
    }

    func dismissAllClickRings() {
        let windows = self.clickRingWindows.values
        self.clickRingWindows.removeAll()
        windows.forEach { $0.dismiss() }
    }
}
