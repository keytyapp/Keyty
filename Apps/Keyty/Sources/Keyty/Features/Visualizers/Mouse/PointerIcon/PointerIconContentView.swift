//
//  PointerIconContentView.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

final class PointerIconContentView: NSView {
    private let settings: any PointerIconSettingsProtocol
    private var resetWorkItem: DispatchWorkItem?
    var visibilityDidChange: ((Bool) -> Void)?
    private(set) var isTransientlyVisible = false
    private(set) var displayedKind: MouseEvent.Kind = .generic
    private var icon: NSImage = Constants.baseIcon {
        didSet { self.needsDisplay = true }
    }

    init(settings: any PointerIconSettingsProtocol) {
        self.settings = settings
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(settings:) instead.")
    }

    static func windowSize(settings: any PointerIconSettingsProtocol) -> NSSize {
        Self.windowSize(iconSize: settings.iconSize)
    }

    static func windowSize(iconSize: NSSize) -> NSSize {
        let icon = Self.fittedSize(for: Constants.baseIcon.size, targetHeight: iconSize.height)
        let padding = Self.scaledPadding(for: iconSize.height)
        return NSSize(width: icon.width + padding * 2, height: icon.height + padding * 2)
    }

    static func renderedImage(
        icon: NSImage = Constants.baseIcon,
        displayedKind: MouseEvent.Kind = .generic,
        iconSize: NSSize,
        backgroundColor: NSColor,
        tintColor: NSColor
    ) -> NSImage {
        let image = NSImage(size: Self.windowSize(iconSize: iconSize))
        image.lockFocus()
        Self.drawIcon(
            icon,
            displayedKind: displayedKind,
            iconSize: iconSize,
            backgroundColor: backgroundColor,
            tintColor: tintColor,
            in: NSRect(origin: .zero, size: image.size)
        )
        image.unlockFocus()
        return image
    }

    static func visualState(for mouseEvent: MouseEvent) -> VisualState? {
        if mouseEvent.type == .scrollWheel, !Self.shouldDisplayScroll(for: mouseEvent) {
            return nil
        }

        let icon = Self.icon(for: mouseEvent)
        let displayedKind = mouseEvent.type == .scrollWheel ? mouseEvent.kind : Self.displayedKind(for: mouseEvent)
        let isTransientlyVisible: Bool

        switch mouseEvent.type {
        case .leftMouseDown, .rightMouseDown, .otherMouseDown,
             .leftMouseDragged, .rightMouseDragged, .otherMouseDragged:
            isTransientlyVisible = true
        case .leftMouseUp, .rightMouseUp, .otherMouseUp:
            isTransientlyVisible = false
        case .scrollWheel:
            isTransientlyVisible = MouseEventDisplayRenderer.scrollIcon(for: mouseEvent.kind) != nil
        default:
            isTransientlyVisible = false
        }

        return VisualState(
            icon: icon,
            displayedKind: displayedKind,
            isTransientlyVisible: isTransientlyVisible
        )
    }

    func handle(mouseEvent: MouseEvent) {
        guard let visualState = Self.visualState(for: mouseEvent) else {
            return
        }

        self.resetWorkItem?.cancel()
        self.resetWorkItem = nil

        if Self.isMouseRelease(mouseEvent.type) {
            self.scheduleReset(after: TimeInterval(self.settings.clickDisplayDuration))
            return
        }

        self.displayedKind = visualState.displayedKind
        self.icon = visualState.icon
        self.setTransientlyVisible(visualState.isTransientlyVisible)

        if mouseEvent.type == .scrollWheel, MouseEventDisplayRenderer.scrollIcon(for: mouseEvent.kind) != nil {
            self.scheduleReset(after: TimeInterval(self.settings.scrollDisplayDuration))
        }
    }

    private static func icon(for mouseEvent: MouseEvent) -> NSImage {
        switch mouseEvent.type {
        case .leftMouseUp, .rightMouseUp, .otherMouseUp:
            return Constants.baseIcon
        default:
            return MouseEventDisplayRenderer.scrollIcon(for: mouseEvent.kind)
                ?? MouseEventDisplayRenderer.sourceIcon(for: mouseEvent.kind)
                ?? Constants.baseIcon
        }
    }

    private static func shouldDisplayScroll(for mouseEvent: MouseEvent) -> Bool {
        guard mouseEvent.type == .scrollWheel else { return true }
        return MouseEventDisplayRenderer.scrollIcon(for: mouseEvent.kind) != nil
    }

    private static func displayedKind(for mouseEvent: MouseEvent) -> MouseEvent.Kind {
        switch mouseEvent.type {
        case .leftMouseUp, .rightMouseUp, .otherMouseUp:
            return .generic
        default:
            return mouseEvent.kind
        }
    }

    private static func isMouseRelease(_ eventType: NSEvent.EventType) -> Bool {
        switch eventType {
        case .leftMouseUp, .rightMouseUp, .otherMouseUp:
            return true
        default:
            return false
        }
    }

    private func scheduleReset(after duration: TimeInterval) {
        guard duration > 0 else {
            self.resetToIdle()
            return
        }

        let item = DispatchWorkItem { [weak self] in
            self?.resetToIdle()
            self?.resetWorkItem = nil
        }
        self.resetWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: item)
    }

    private func resetToIdle() {
        self.icon = Constants.baseIcon
        self.displayedKind = .generic
        self.setTransientlyVisible(false)
    }

    private func setTransientlyVisible(_ isVisible: Bool) {
        guard self.isTransientlyVisible != isVisible else { return }
        self.isTransientlyVisible = isVisible
        self.visibilityDidChange?(isVisible)
    }

    override func draw(_ dirtyRect: NSRect) {
        Self.drawIcon(
            self.icon,
            displayedKind: self.displayedKind,
            iconSize: self.settings.iconSize,
            backgroundColor: self.settings.backgroundColor,
            tintColor: self.settings.tintColor,
            in: self.bounds
        )
    }

    static func scaledPadding(for iconHeight: CGFloat) -> CGFloat {
        guard Constants.basePaddingIconHeight > 0 else { return Constants.basePadding }
        return round(Constants.basePadding * (iconHeight / Constants.basePaddingIconHeight))
    }

    private static func drawIcon(
        _ icon: NSImage,
        displayedKind: MouseEvent.Kind,
        iconSize: NSSize,
        backgroundColor: NSColor,
        tintColor: NSColor,
        in bounds: NSRect
    ) {
        let borderInset = Constants.borderWidth / 2
        let capsuleRect = bounds.insetBy(dx: borderInset, dy: borderInset)
        let capsuleRadius = capsuleRect.width / 2
        let capsulePath = NSBezierPath(roundedRect: capsuleRect, xRadius: capsuleRadius, yRadius: capsuleRadius)
        backgroundColor.setFill()
        capsulePath.fill()
        tintColor.withAlphaComponent(0.2).setStroke()
        capsulePath.lineWidth = Constants.borderWidth
        capsulePath.stroke()

        let fittedIconSize = Self.fittedSize(for: icon.size, targetHeight: iconSize.height)
        let badged = displayedKind.otherButtonNumber != nil
            ? MouseEventDisplayRenderer.iconImage(
                for: displayedKind,
                height: fittedIconSize.height,
                color: tintColor
            )
            : nil
        let tinted = badged ?? icon.tinted(with: tintColor, size: fittedIconSize)
        let padding = Self.scaledPadding(for: iconSize.height)
        let iconRect = NSRect(
            x: padding, y: padding,
            width: fittedIconSize.width, height: fittedIconSize.height
        )
        tinted.draw(in: iconRect, from: .zero, operation: .sourceOver, fraction: 1)
    }

    private static func fittedSize(for sourceSize: NSSize, targetHeight: CGFloat) -> NSSize {
        guard sourceSize.height > 0 else { return sourceSize }
        let scale = targetHeight / sourceSize.height
        return NSSize(width: sourceSize.width * scale, height: targetHeight)
    }
}

// MARK: - Visual State
extension PointerIconContentView {
    struct VisualState {
        let icon: NSImage
        let displayedKind: MouseEvent.Kind
        let isTransientlyVisible: Bool

        static let idle = Self(
            icon: Constants.baseIcon,
            displayedKind: .generic,
            isTransientlyVisible: false
        )

        static let leftClick = Self(
            icon: MouseEventDisplayRenderer.sourceIcon(for: .leftButton) ?? Constants.baseIcon,
            displayedKind: .leftButton,
            isTransientlyVisible: true
        )

        static let rightClick = Self(
            icon: MouseEventDisplayRenderer.sourceIcon(for: .rightButton) ?? Constants.baseIcon,
            displayedKind: .rightButton,
            isTransientlyVisible: true
        )

        static let scrollUp = Self(
            icon: MouseEventDisplayRenderer.scrollIcon(for: .wheelUp) ?? Constants.baseIcon,
            displayedKind: .wheelUp,
            isTransientlyVisible: true
        )

        static let scrollDown = Self(
            icon: MouseEventDisplayRenderer.scrollIcon(for: .wheelDown) ?? Constants.baseIcon,
            displayedKind: .wheelDown,
            isTransientlyVisible: true
        )
    }
}

// MARK: - Constants
private extension PointerIconContentView {
    enum Constants {
        static let basePadding: CGFloat = Spacing.md
        static let basePaddingIconHeight: CGFloat = 64
        static let borderWidth: CGFloat = 1
        static let baseIcon: NSImage = NSImage.mouseDefault
    }
}
