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
    private let pointerContentView: PointerIconContentView
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
        self.pointerContentView = PointerIconContentView(settings: settings)
        self.pointerContentView.visibilityDidChange = { [weak self] _ in
            self?.syncPresentation()
        }
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

extension PointerIconVisualizer {
    enum VisibilityPolicy {
        static func shouldShow(
            isEnabled: Bool,
            isPresentationActive: Bool,
            alwaysVisible: Bool,
            isTransientlyVisible: Bool,
            isCursorVisible: Bool
        ) -> Bool {
            guard isEnabled, isPresentationActive else { return false }
            return isTransientlyVisible || (alwaysVisible && isCursorVisible)
        }
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
    func display(_ mouseEvent: MouseEvent) {
        guard self.isEnabled else { return }
        self.pointerContentView.handle(mouseEvent: mouseEvent)
        self.syncPresentation()
    }
}

// MARK: - Private API
private extension PointerIconVisualizer {
    func settingsDidChange() {
        self.syncPresentation()
    }

    func presentationStateDidChange() {
        self.syncPresentation()
    }

    func showIfNeeded() {
        if self.window == nil {
            self.window = PointerIconVisualizerWindow(
                contentView: self.pointerContentView,
                contentSize: PointerIconContentView.windowSize(settings: self.settings)
            )
        }
    }

    func hide() {
        self.stopTracking()
        self.destroyWindow()
    }

    func syncPresentation() {
        guard self.isEnabled && self.isPresentationActive else {
            self.hide()
            return
        }

        self.showIfNeeded()
        self.startTracking()
        self.window?.updateContentSize(PointerIconContentView.windowSize(settings: self.settings))
        self.window?.update(
            screenLocation: NSEvent.mouseLocation,
            anchor: self.settings.anchor,
            offset: self.settings.offset
        )
        self.window?.setVisible(self.shouldShowWindow)
    }

    var shouldShowWindow: Bool {
        VisibilityPolicy.shouldShow(
            isEnabled: self.isEnabled,
            isPresentationActive: self.isPresentationActive,
            alwaysVisible: self.settings.alwaysVisible,
            isTransientlyVisible: self.pointerContentView.isTransientlyVisible,
            isCursorVisible: self.cursorVisibilityProvider.isCursorVisible
        )
    }

    func startTracking() {
        guard self.tracker == nil else { return }
        self.tracker = DisplayTracker { [weak self] in
            self?.syncPresentation()
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
