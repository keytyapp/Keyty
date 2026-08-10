//
//  PointerIconVisualizer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

@MainActor
final class PointerIconVisualizer {
    private let settings: any PointerIconSettingsProtocol & ReactiveSettings
    private let cursorVisibilityProvider: any CursorVisibilityProviding
    private var cancellables = Set<AnyCancellable>()
    private var window: PointerIconVisualizerWindow?
    private var tracker: DisplayTracker?

    var isPresentationActive: Bool = false {
        didSet {
            self.presentationStateDidChange()
        }
    }

    /// Whether the visualizer currently owns a presentation window.
    var isPresented: Bool {
        self.window != nil
    }

    init(
        settings: any PointerIconSettingsProtocol & ReactiveSettings = PointerIconSettings(),
        cursorVisibilityProvider: any CursorVisibilityProviding = SystemCursorVisibilityProvider()
    ) {
        self.settings = settings
        self.cursorVisibilityProvider = cursorVisibilityProvider
        self.settings.changes
            .sink { [weak self] in
                Task { @MainActor in
                    self?.settingsDidChange()
                }
            }
            .store(in: &self.cancellables)
        self.presentationStateDidChange()
    }

    deinit {
        self.tracker?.stop()
    }
}

// MARK: - Public API
extension PointerIconVisualizer {
    var isEnabled: Bool {
        get { self.settings.isEnabled }
        set {
            self.settings.isEnabled = newValue
            self.presentationStateDidChange()
        }
    }
}

// MARK: - PointerVisualizer
extension PointerIconVisualizer: PointerVisualizer {
    func noteMouseEvent(_ mouseEvent: MouseEvent) {
        guard self.isEnabled else { return }
        self.window?.update(mouseEvent: mouseEvent)
    }
}

// MARK: - Private API
private extension PointerIconVisualizer {
    func settingsDidChange() {
        self.presentationStateDidChange()
    }

    func presentationStateDidChange() {
        self.isEnabled && self.isPresentationActive ? self.show() : self.hide()
    }

    func show() {
        if self.window == nil {
            self.window = PointerIconVisualizerWindow(
                settings: self.settings,
                cursorVisibilityProvider: self.cursorVisibilityProvider
            )
        }
        self.window?.update(screenLocation: NSEvent.mouseLocation)
        self.window?.refreshVisibility()
        self.startTracking()
    }

    func hide() {
        self.stopTracking()
        self.destroyWindow()
    }

    func startTracking() {
        guard self.tracker == nil else { return }
        self.tracker = DisplayTracker { [weak self] in
            self?.window?.update(screenLocation: NSEvent.mouseLocation)
            self?.window?.refreshVisibility()
        }
        self.tracker?.start()
    }

    func stopTracking() {
        self.tracker?.stop()
        self.tracker = nil
    }

    func destroyWindow() {
        self.window?.orderOut(nil)
        self.window = nil
    }
}
