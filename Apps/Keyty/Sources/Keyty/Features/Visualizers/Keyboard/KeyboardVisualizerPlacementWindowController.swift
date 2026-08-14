//
//  KeyboardVisualizerPlacementWindowController.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

@MainActor
final class KeyboardVisualizerPlacementWindowController: NSWindowController, KeyboardVisualizerPlacementCoordinating {
    typealias PlacementChangeHandler = @MainActor (Placement) -> Void

    private let settings: KeyboardVisualizerSettings
    private let screensService: any ScreenServiceProvider
    private var onPlacementChanged: PlacementChangeHandler?
    private var placementCancellable: AnyCancellable?
    private var appliedAlignment: Alignment?

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

// MARK: - Placement
extension KeyboardVisualizerPlacementWindowController {
    /// Display and position the preview window resolved to,
    /// normalized to that display's visible frame.
    struct Placement {
        let screenID: CGDirectDisplayID
        let positionX: CGFloat
        let positionY: CGFloat
    }
}

// MARK: - Alignment
extension KeyboardVisualizerPlacementWindowController {
    /// Alignment pair the preview window is currently anchored with.
    struct Alignment: Equatable {
        let horizontal: KeyboardVisualizerAlignment
        let vertical: KeyboardVisualizerAlignment
    }
}

// MARK: - Public API
extension KeyboardVisualizerPlacementWindowController {
    func startSettingPosition(onPlacementChanged: @escaping PlacementChangeHandler) {
        self.onPlacementChanged = onPlacementChanged

        if let window = self.window {
            window.orderFrontRegardless()
            return
        }

        guard let visibleFrame = self.resolvedVisibleFrame() else { return }

        let contentView = KeyboardVisualizerGroupView(items: Self.previewItems(settings: self.settings), settings: self.settings)
        let previewAlignment = self.previewAlignment
        let frame = KeyboardVisualizerAlignment.frame(
            for: contentView.preferredSize,
            atNormalized: CGPoint(
                x: self.settings.customPositionNormalizedX,
                y: self.settings.customPositionNormalizedY
            ),
            in: visibleFrame,
            horizontal: previewAlignment.horizontal,
            vertical: previewAlignment.vertical
        )
        let window = Window(frame: frame, contentView: contentView)
        window.onMoveEnded = { [weak self] in
            self?.notifyPlacementChanged()
        }
        self.window = window
        self.appliedAlignment = previewAlignment
        self.observePlacementChanges()
        window.orderFrontRegardless()
    }

    func stopSettingPosition() -> Placement? {
        guard let window = self.window else { return nil }

        let placement = self.placement(for: self.previewAnchorPoint(in: window.frame))
        window.close()
        self.onPlacementChanged = nil
        self.placementCancellable = nil
        self.appliedAlignment = nil
        self.window = nil
        return placement
    }
}

extension KeyboardVisualizerPlacementWindowController {
    static func placement(
        for point: CGPoint,
        in visibleFrames: [(screenID: CGDirectDisplayID, frame: CGRect)]
    ) -> Placement? {
        guard let visibleFrame = visibleFrames.first(where: { $0.frame.contains(point) })
            ?? Self.nearestVisibleFrame(to: point, in: visibleFrames)
        else {
            return nil
        }

        let position = visibleFrame.frame.normalizedPoint(for: point)

        return Placement(
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
            state: KeycapState(isPressed: false),
            appearance: settings.palette.appearance(for: identity)
        )
    }

    func resolvedVisibleFrame() -> CGRect? {
        self.screensService.visibleFrame(preferring: self.settings.screenID)
    }

    var previewAlignment: Alignment {
        Alignment(
            horizontal: self.settings.effectiveHorizontalAlignment,
            vertical: self.settings.customVerticalAlignment
        )
    }

    func observePlacementChanges() {
        self.placementCancellable = self.settings.placementChanges
            .sink { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.republishAnchorOnAlignmentChange()
                }
            }
    }

    func republishAnchorOnAlignmentChange() {
        let alignment = self.previewAlignment
        guard alignment != self.appliedAlignment else { return }
        self.appliedAlignment = alignment

        self.notifyPlacementChanged()
    }

    func placement(for point: CGPoint) -> Placement? {
        Self.placement(for: point, in: self.visibleFrames())
    }

    func notifyPlacementChanged() {
        guard let window = self.window,
              let placement = self.placement(for: self.previewAnchorPoint(in: window.frame))
        else {
            return
        }

        self.onPlacementChanged?(placement)
    }

    func previewAnchorPoint(in frame: CGRect) -> CGPoint {
        let alignment = self.previewAlignment

        return CGPoint(
            x: alignment.horizontal.anchorX(in: frame),
            y: alignment.vertical.anchorY(in: frame)
        )
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
