//
//  PointerRipplesVisualizer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

@MainActor
final class PointerRipplesVisualizer {
    private let settings: any PointerRipplesSettingsProtocol & ReactiveSettings
    private var ripplesWindows: [UUID: PointerRipplesWindow] = [:]
    private var cancellables = Set<AnyCancellable>()

    var isPresentationActive: Bool = false {
        didSet {
            guard self.isPresentationActive else {
                self.dismissAllRipples()
                return
            }
        }
    }

    var isPresented: Bool {
        !self.ripplesWindows.isEmpty
    }

    var isEnabled: Bool {
        get { self.settings.isEnabled }
        set { self.settings.isEnabled = newValue }
    }

    init(settings: any PointerRipplesSettingsProtocol & ReactiveSettings = PointerRipplesSettings()) {
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
extension PointerRipplesVisualizer: PointerVisualizer {
    func display(_ mouseEvent: MouseEvent) {
        guard self.isEnabled, self.isPresentationActive else { return }
        guard PointerRingAnimation.eventPhase(for: mouseEvent.type) == .press else { return }
        self.presentRipple(at: mouseEvent.screenLocation)
    }
}

private extension PointerRipplesVisualizer {
    func settingsDidChange() {
        guard !self.settings.isEnabled else { return }
        self.dismissAllRipples()
    }

    func presentRipple(at screenLocation: NSPoint) {
        let window = PointerRipplesWindow(
            style: .init(
                color: self.settings.color,
                size: self.settings.size,
                thickness: self.settings.thickness,
                shape: self.settings.shape
            ),
            center: screenLocation
        ) { [weak self] identifier in
            self?.ripplesWindows.removeValue(forKey: identifier)
        }
        self.ripplesWindows[window.ringID] = window
        window.present()
    }

    func dismissAllRipples() {
        let windows = self.ripplesWindows.values
        self.ripplesWindows.removeAll()
        windows.forEach { $0.dismiss() }
    }
}
