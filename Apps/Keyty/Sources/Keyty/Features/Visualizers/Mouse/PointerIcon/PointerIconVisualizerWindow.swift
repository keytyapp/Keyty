//
//  PointerIconVisualizerWindow.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

final class PointerIconVisualizerWindow: NSWindow {
    private let settings: any PointerIconSettingsProtocol & ReactiveSettings
    private let cursorVisibilityProvider: any CursorVisibilityProviding
    private let pointerContentView: PointerIconContentView
    private var cancellables = Set<AnyCancellable>()

    init(
        settings: any PointerIconSettingsProtocol & ReactiveSettings,
        cursorVisibilityProvider: any CursorVisibilityProviding
    ) {
        self.settings = settings
        self.cursorVisibilityProvider = cursorVisibilityProvider
        self.pointerContentView = PointerIconContentView(settings: settings)
        super.init(
            contentRect: NSRect(origin: .zero, size: PointerIconContentView.windowSize(settings: settings)),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.alphaValue = 1
        self.ignoresMouseEvents = true
        self.collectionBehavior = .canJoinAllSpaces

        self.pointerContentView.visibilityDidChange = { [weak self] _ in
            self?.refreshVisibility()
        }
        self.contentView = self.pointerContentView

        settings.changes
            .sink { [weak self] in
                Task { @MainActor in
                    self?.settingsDidChange()
                }
            }
            .store(in: &self.cancellables)
    }

    private func settingsDidChange() {
        let newSize = PointerIconContentView.windowSize(settings: self.settings)
        self.setContentSize(newSize)
        self.contentView?.needsDisplay = true
        self.update(screenLocation: NSEvent.mouseLocation)
        self.refreshVisibility()
    }

    func update(screenLocation: NSPoint) {
        let size = self.frame.size
        let origin = self.settings.anchor.origin(relativeTo: screenLocation, windowSize: size, offset: self.settings.offset)
        self.setFrameOrigin(origin)
    }

    func update(mouseEvent: MouseEvent) {
        self.pointerContentView.handle(mouseEvent: mouseEvent)
        self.refreshVisibility()
    }

    func refreshVisibility() {
        if Self.shouldBeVisible(
            isEnabled: self.settings.isEnabled,
            alwaysVisible: self.settings.alwaysVisible,
            isTransientlyVisible: self.pointerContentView.isTransientlyVisible,
            isCursorVisible: self.cursorVisibilityProvider.isCursorVisible
        ) {
            self.orderFrontRegardless()
        } else {
            self.orderOut(nil)
        }
    }

    static func shouldBeVisible(
        isEnabled: Bool,
        alwaysVisible: Bool,
        isTransientlyVisible: Bool,
        isCursorVisible: Bool
    ) -> Bool {
        guard isEnabled else { return false }
        return isTransientlyVisible || (alwaysVisible && isCursorVisible)
    }
}

private extension PointerIconAnchor {
    func origin(relativeTo cursor: NSPoint, windowSize: NSSize, offset: CGFloat) -> NSPoint {
        switch self {
        case .bottomRight:
            return NSPoint(x: cursor.x + offset, y: cursor.y - windowSize.height - offset)
        case .bottomLeft:
            return NSPoint(x: cursor.x - windowSize.width - offset, y: cursor.y - windowSize.height - offset)
        case .topRight:
            return NSPoint(x: cursor.x + offset, y: cursor.y + offset)
        case .topLeft:
            return NSPoint(x: cursor.x - windowSize.width - offset, y: cursor.y + offset)
        }
    }
}
