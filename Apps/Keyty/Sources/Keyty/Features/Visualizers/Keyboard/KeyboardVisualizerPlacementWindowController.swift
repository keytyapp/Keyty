//
//  KeyboardVisualizerPlacementWindowController.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

struct KeyboardVisualizerPlacement {
    let screenID: CGDirectDisplayID
    let positionX: CGFloat
    let positionY: CGFloat
}

typealias KeyboardVisualizerPlacementChangeHandler = @MainActor (KeyboardVisualizerPlacement) -> Void

@MainActor
final class KeyboardVisualizerPlacementWindowController: NSWindowController {
    private let settings: KeyboardVisualizerSettings
    private let screensService: any ScreenServiceProvider
    private var onPlacementChanged: KeyboardVisualizerPlacementChangeHandler?

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
    func startSettingPosition(onPlacementChanged: @escaping KeyboardVisualizerPlacementChangeHandler) {
        self.onPlacementChanged = onPlacementChanged

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
        window.onMoveEnded = { [weak self] in
            self?.notifyPlacementChanged()
        }
        self.window = window
        window.orderFrontRegardless()
    }

    func stopSettingPosition() -> KeyboardVisualizerPlacement? {
        guard let window = self.window else { return nil }

        let placement = self.placement(for: CGPoint(x: window.frame.midX, y: window.frame.midY))
        window.close()
        self.onPlacementChanged = nil
        self.window = nil
        return placement
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
            x: (center.x - size.width / 2).clamped(minimum: area.minX, maximum: area.maxX - size.width),
            y: (center.y - size.height / 2).clamped(minimum: area.minY, maximum: area.maxY - size.height)
        )

        return CGRect(origin: origin, size: size)
    }

    static func normalizedPosition(for point: CGPoint, in area: CGRect) -> CGPoint {
        area.normalizedPoint(for: point)
    }

    static func placement(
        for point: CGPoint,
        in visibleFrames: [(screenID: CGDirectDisplayID, frame: CGRect)]
    ) -> KeyboardVisualizerPlacement? {
        guard let visibleFrame = visibleFrames.first(where: { $0.frame.contains(point) })
            ?? Self.nearestVisibleFrame(to: point, in: visibleFrames)
        else {
            return nil
        }

        let position = Self.normalizedPosition(for: point, in: visibleFrame.frame)

        return KeyboardVisualizerPlacement(
            screenID: visibleFrame.screenID,
            positionX: position.x,
            positionY: position.y
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

    func placement(for point: CGPoint) -> KeyboardVisualizerPlacement? {
        Self.placement(for: point, in: self.visibleFrames())
    }

    func notifyPlacementChanged() {
        guard let window = self.window,
              let placement = self.placement(for: CGPoint(x: window.frame.midX, y: window.frame.midY))
        else {
            return
        }

        self.onPlacementChanged?(placement)
    }

    func visibleFrames() -> [(screenID: CGDirectDisplayID, frame: CGRect)] {
        self.screensService.screens.compactMap { screen in
            guard let frame = self.screensService.visibleFrame(for: screen.id) else { return nil }
            return (screen.id, frame)
        }
    }

    static func nearestVisibleFrame(
        to point: CGPoint,
        in visibleFrames: [(screenID: CGDirectDisplayID, frame: CGRect)]
    ) -> (screenID: CGDirectDisplayID, frame: CGRect)? {
        visibleFrames.min { lhs, rhs in
            lhs.frame.squaredDistance(to: point) < rhs.frame.squaredDistance(to: point)
        }
    }
}

extension KeyboardVisualizerPlacementWindowController {
    final class Window: NSPanel {
        var onMoveEnded: (() -> Void)?

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

        override func mouseUp(with event: NSEvent) {
            super.mouseUp(with: event)
            self.onMoveEnded?()
        }
    }
}
