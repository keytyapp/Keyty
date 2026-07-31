//
//  KeyboardVisualizerPlacementWindowController.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

@MainActor
final class KeyboardVisualizerPlacementWindowController: NSWindowController {
    private let settings: KeyboardVisualizerSettings
    private let screensService: any ScreenServiceProvider

    init(
        settings: KeyboardVisualizerSettings,
        screensService: any ScreenServiceProvider = ScreensService.shared
    ) {
        self.settings = settings
        self.screensService = screensService
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(settings:screensService:) instead.")
    }
}

// MARK: - Public API
extension KeyboardVisualizerPlacementWindowController {
    func startSettingPosition() {
        if let window = self.window {
            window.orderFrontRegardless()
            return
        }

        guard let visibleFrame = self.resolvedVisibleFrame() else { return }

        let contentView = KeyboardVisualizerGroupView(items: Self.previewItems(settings: self.settings), settings: self.settings)
        let size = contentView.preferredSize
        let frame = Self.frame(
            forNormalizedPosition: CGPoint(x: self.settings.customPositionX, y: self.settings.customPositionY),
            in: visibleFrame,
            size: size
        )
        let window = Window(frame: frame, contentView: contentView)
        self.window = window
        window.orderFrontRegardless()
    }

    func stopSettingPosition() {
        guard let window = self.window else { return }

        if let visibleFrame = self.resolvedVisibleFrame() {
            let position = Self.normalizedPosition(
                for: CGPoint(x: window.frame.midX, y: window.frame.midY),
                in: visibleFrame
            )
            self.settings.customPositionX = position.x
            self.settings.customPositionY = position.y
        }

        window.close()
        self.window = nil
    }
}

extension KeyboardVisualizerPlacementWindowController {
    static func frame(
        forNormalizedPosition position: CGPoint,
        in area: CGRect,
        size: CGSize
    ) -> CGRect {
        let center = CGPoint(
            x: area.minX + area.width * position.x,
            y: area.minY + area.height * position.y
        )
        let origin = CGPoint(
            x: Self.clamped(center.x - size.width / 2, minimum: area.minX, maximum: area.maxX - size.width),
            y: Self.clamped(center.y - size.height / 2, minimum: area.minY, maximum: area.maxY - size.height)
        )

        return CGRect(origin: origin, size: size)
    }

    static func normalizedPosition(for point: CGPoint, in area: CGRect) -> CGPoint {
        CGPoint(
            x: Self.clamped((point.x - area.minX) / max(area.width, 1), minimum: 0, maximum: 1),
            y: Self.clamped((point.y - area.minY) / max(area.height, 1), minimum: 0, maximum: 1)
        )
    }

    static func previewItems(settings: KeyboardVisualizerSettings) -> [KeycapItem] {
        [
            Self.previewItem(keyCode: .t, symbol: "T", settings: settings),
            Self.previewItem(keyCode: .e, symbol: "E", settings: settings),
            Self.previewItem(keyCode: .s, symbol: "S", settings: settings),
            Self.previewItem(keyCode: .t, symbol: "T", settings: settings),
        ]
    }
}

private extension KeyboardVisualizerPlacementWindowController {
    static func previewItem(
        keyCode: KeyboardKeyCode,
        symbol: String,
        settings: KeyboardVisualizerSettings
    ) -> KeycapItem {
        let identity = KeycapIdentity.keyCode(keyCode.rawValue)

        return KeycapItem(
            identity: identity,
            legend: .character(symbol),
            state: KeycapState(isPressed: true),
            appearance: settings.palette.appearance(for: identity)
        )
    }

    func resolvedVisibleFrame() -> CGRect? {
        self.screensService.visibleFrame(for: self.settings.screenID)
            ?? self.screensService.mainVisibleFrame()
    }

    static func clamped(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        guard maximum >= minimum else { return minimum }
        return min(max(value, minimum), maximum)
    }
}

extension KeyboardVisualizerPlacementWindowController {
    final class Window: NSPanel {
        init(frame: CGRect, contentView: NSView) {
            super.init(
                contentRect: frame,
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )

            self.level = .screenSaver
            self.isOpaque = false
            self.backgroundColor = .clear
            self.hasShadow = true
            self.isMovableByWindowBackground = true
            self.isReleasedWhenClosed = false
            self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            contentView.frame = CGRect(origin: .zero, size: frame.size)
            self.contentView = contentView
        }
    }
}
