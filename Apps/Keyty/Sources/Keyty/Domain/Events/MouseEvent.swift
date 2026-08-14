//
//  MouseEvent.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

public struct MouseEvent {
    public let type: NSEvent.EventType
    public let modifierFlags: NSEvent.ModifierFlags
    public let locationInWindow: NSPoint
    public let screenLocation: NSPoint
    public let buttonNumber: Int
    public let scrollingDeltaX: CGFloat
    public let scrollingDeltaY: CGFloat
    public let phase: NSEvent.Phase
    public let hasPreciseScrollingDeltas: Bool

    public init(nsEvent event: NSEvent) {
        self.type = event.type
        self.modifierFlags = event.modifierFlags
        self.locationInWindow = event.locationInWindow
        self.screenLocation = event.locationInWindow
        self.buttonNumber = event.buttonNumber
        self.scrollingDeltaX = event.type == .scrollWheel ? event.scrollingDeltaX : .zero
        self.scrollingDeltaY = event.type == .scrollWheel ? event.scrollingDeltaY : .zero
        self.phase = event.type == .scrollWheel ? event.phase : []
        self.hasPreciseScrollingDeltas = event.type == .scrollWheel ? event.hasPreciseScrollingDeltas : false
    }

    public init(nsEvent event: NSEvent, cgEvent: CGEvent) {
        self.type = event.type
        self.modifierFlags = event.modifierFlags
        self.locationInWindow = event.locationInWindow
        self.screenLocation = Self.screenLocation(from: cgEvent)
        self.buttonNumber = event.buttonNumber
        self.scrollingDeltaX = event.type == .scrollWheel ? event.scrollingDeltaX : .zero
        self.scrollingDeltaY = event.type == .scrollWheel ? event.scrollingDeltaY : .zero
        self.phase = event.type == .scrollWheel ? event.phase : []
        self.hasPreciseScrollingDeltas = event.type == .scrollWheel ? event.hasPreciseScrollingDeltas : false
    }

    public var inputEvent: InputEvent {
        .mouse(self)
    }

    public var hasZeroScrollDelta: Bool {
        self.scrollingDeltaX == 0.0 && self.scrollingDeltaY == 0.0
    }

    private static func screenLocation(from cgEvent: CGEvent) -> NSPoint {
        screenLocation(
            from: cgEvent.location,
            screens: NSScreen.screens.map(\.frame),
            mainScreenFrame: NSScreen.main?.frame
        )
    }

    static func screenLocation(
        from location: CGPoint,
        screens: [NSRect],
        mainScreenFrame: NSRect?
    ) -> NSPoint {
        let mainMaxY = mainScreenFrame?.maxY ?? screens.first?.maxY ?? 0
        let screenAndFlippedFrame = screens.lazy.compactMap { screen -> (NSRect, NSRect)? in
            let flippedFrame = NSRect(
                x: screen.minX,
                y: mainMaxY - screen.maxY,
                width: screen.width,
                height: screen.height
            )
            return flippedFrame.contains(location) ? (screen, flippedFrame) : nil
        }.first

        guard let (screen, flippedFrame) = screenAndFlippedFrame else {
            return NSPoint(x: location.x, y: mainMaxY - location.y)
        }

        let x = screen.minX + (location.x - flippedFrame.minX)
        let y = screen.maxY - (location.y - flippedFrame.minY)

        return NSPoint(x: x, y: y)
    }
}

extension MouseEvent {
    public enum Kind: Hashable {
        case leftButton
        case rightButton
        case middleButton
        case otherButton(Int)
        case wheelUp
        case wheelDown
        case wheelLeft
        case wheelRight
        case generic
    }

    public var kind: Kind {
        switch type {
        case .leftMouseDown, .leftMouseUp, .leftMouseDragged:
            return .leftButton
        case .rightMouseDown, .rightMouseUp, .rightMouseDragged:
            return .rightButton
        case .otherMouseDown, .otherMouseUp, .otherMouseDragged:
            return buttonNumber == 2 ? .middleButton : .otherButton(buttonNumber + 1)
        case .scrollWheel:
            guard scrollingDeltaX != 0 || scrollingDeltaY != 0 else {
                return .generic
            }
            if abs(scrollingDeltaY) >= abs(scrollingDeltaX) {
                return scrollingDeltaY > 0 ? .wheelUp : .wheelDown
            }
            return scrollingDeltaX > 0 ? .wheelRight : .wheelLeft
        default:
            return .generic
        }
    }
}

extension MouseEvent.Kind {
    /// Whether this semantic kind represents a scroll-wheel direction rather than a button press.
    public var isScroll: Bool {
        switch self {
        case .wheelUp, .wheelDown, .wheelLeft, .wheelRight:
            return true
        default:
            return false
        }
    }

    /// The user-facing auxiliary button number for `.otherButton`, or `nil` for non-auxiliary kinds.
    public var otherButtonNumber: Int? {
        if case let .otherButton(number) = self {
            return number
        }
        return nil
    }
}
