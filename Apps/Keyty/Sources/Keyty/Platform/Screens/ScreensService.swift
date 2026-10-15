//
//  ScreensService.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

@MainActor
protocol ScreenServiceProvider: AnyObject {
    var screens: [Screen] { get }
    var screensDidChange: AnyPublisher<[Screen], Never> { get }

    func display(for id: CGDirectDisplayID) -> Screen?
    func mainDisplay() -> Screen?
    func visibleFrame(for id: CGDirectDisplayID) -> CGRect?
    func mainVisibleFrame() -> CGRect?
}

@MainActor
final class ScreensService {
    static let shared = ScreensService()

    var screens: [Screen] {
        self.screensSubject.value
    }

    var screensDidChange: AnyPublisher<[Screen], Never> {
        self.screensSubject.eraseToAnyPublisher()
    }

    private let screensSubject: CurrentValueSubject<[Screen], Never>
    private var observer: NSObjectProtocol?

    init() {
        self.screensSubject = CurrentValueSubject(Self.currentScreens())

        self.observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.refresh()
            }
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - ScreenServiceProvider
extension ScreensService: ScreenServiceProvider {
    /// Returns the connected display matching `id`, or `nil` when `id == 0` or the
    /// stored display is no longer connected.
    func display(for id: CGDirectDisplayID) -> Screen? {
        guard id != 0 else { return nil }
        return self.screens.first { $0.id == id }
    }

    /// Returns the current main display when available, otherwise `nil`.
    func mainDisplay() -> Screen? {
        guard let mainID = NSScreen.main?.displayID else {
            return nil
        }
        return self.display(for: mainID)
    }

    /// Returns the current visible frame for `id`, or `nil` when the ID is unset or
    /// no longer matches a connected screen.
    func visibleFrame(for id: CGDirectDisplayID) -> CGRect? {
        guard id != 0 else { return nil }
        return NSScreen.screens.first { $0.displayID == id }?.visibleFrame
    }

    /// Returns the current main screen visible frame when available.
    func mainVisibleFrame() -> CGRect? {
        NSScreen.main?.visibleFrame
    }
}

private extension ScreensService {
    func refresh() {
        self.screensSubject.send(Self.currentScreens())
    }

    private static func currentScreens() -> [Screen] {
        NSScreen.screens.map(Screen.init)
    }
}
