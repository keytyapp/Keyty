//
//  PointerRingVisualizer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

@MainActor
public final class PointerRingVisualizer {
    private let settings: any PointerRingSettingsProtocol & ReactiveSettings
    private var visualizerWindow: PointerRingVisualizerWindow?
    private var tracker: DisplayTracker?
    private var cancellables = Set<AnyCancellable>()

    var isPresentationActive: Bool = false {
        didSet {
            self.presentationStateDidChange()
        }
    }

    /// Whether the visualizer currently owns a presentation window.
    var isPresented: Bool {
        self.visualizerWindow != nil
    }

    public var isEnabled: Bool {
        didSet {
            self.settings.isEnabled = self.isEnabled
            self.presentationStateDidChange()
        }
    }

    init(settings: any PointerRingSettingsProtocol & ReactiveSettings = PointerRingSettings()) {
        self.settings = settings
        self.isEnabled = settings.isEnabled
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
        self.tracker = nil
        self.visualizerWindow = nil
    }
}

// MARK: - PointerVisualizer

extension PointerRingVisualizer: PointerVisualizer {
    public func display(_ mouseEvent: MouseEvent) {
        guard self.isEnabled else { return }
        if mouseEvent.type == .scrollWheel { return }
        self.visualizerWindow?.update(with: mouseEvent)
    }
}

// MARK: - Private API

private extension PointerRingVisualizer {
    func settingsDidChange() {
        let isEnabled = self.settings.isEnabled
        guard self.isEnabled != isEnabled else {
            self.presentationStateDidChange()
            return
        }

        self.isEnabled = isEnabled
    }

    func presentationStateDidChange() {
        self.isEnabled && self.isPresentationActive ? self.show() : self.hide()
    }

    func show() {
        self.createWindowIfNeeded()
        self.startTracking()
    }

    func hide() {
        self.stopTracking()
        self.destroyWindow()
    }

    func createWindowIfNeeded() {
        guard self.visualizerWindow == nil else { return }
        self.visualizerWindow = PointerRingVisualizerWindow(settings: self.settings)
        self.visualizerWindow?.updatePointerPosition()
        self.visualizerWindow?.orderFrontRegardless()
    }

    func destroyWindow() {
        self.visualizerWindow?.orderOut(self)
        self.visualizerWindow = nil
    }

    func startTracking() {
        guard self.tracker == nil else { return }
        self.tracker = DisplayTracker { [weak self] in
            self?.visualizerWindow?.updatePointerPosition()
        }
        self.tracker?.start()
    }

    func stopTracking() {
        self.tracker?.stop()
        self.tracker = nil
    }
}
