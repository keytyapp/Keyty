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
    public let screenLocation: NSPoint
    public let buttonNumber: Int
    public let scrollingDeltaX: CGFloat
    public let scrollingDeltaY: CGFloat
    public let phase: NSEvent.Phase
    public let hasPreciseScrollingDeltas: Bool

    public init(nsEvent event: NSEvent) {
        self.type = event.type
        self.modifierFlags = event.modifierFlags
        self.screenLocation = event.locationInWindow
        self.buttonNumber = event.buttonNumber
        self.scrollingDeltaX = self.type == .scrollWheel ? event.scrollingDeltaX : .zero
        self.scrollingDeltaY = self.type == .scrollWheel ? event.scrollingDeltaY : .zero
        self.phase = self.type == .scrollWheel ? event.phase : []
        self.hasPreciseScrollingDeltas = self.type == .scrollWheel ? event.hasPreciseScrollingDeltas : false
    }

    public init(nsEvent event: NSEvent, cgEvent: CGEvent) {
        self.type = event.type
        self.modifierFlags = event.modifierFlags
        self.screenLocation = event.locationInWindow
        self.buttonNumber = event.buttonNumber
        self.scrollingDeltaX = self.type == .scrollWheel ? event.scrollingDeltaX : .zero
        self.scrollingDeltaY = self.type == .scrollWheel ? event.scrollingDeltaY : .zero
        self.phase = self.type == .scrollWheel ? event.phase : []
        self.hasPreciseScrollingDeltas = self.type == .scrollWheel ? event.hasPreciseScrollingDeltas : false
    }

    public var inputEvent: InputEvent {
        .mouse(self)
    }

    public var hasZeroScrollDelta: Bool {
        self.scrollingDeltaX == 0.0 && self.scrollingDeltaY == 0.0
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
            return self.buttonNumber == 2 ? .middleButton : .otherButton(self.buttonNumber + 1)
        case .scrollWheel:
            guard self.scrollingDeltaX != 0 || self.scrollingDeltaY != 0 else {
                return .generic
            }
            if abs(self.scrollingDeltaY) >= abs(self.scrollingDeltaX) {
                return self.scrollingDeltaY > 0 ? .wheelUp : .wheelDown
            }
            return self.scrollingDeltaX > 0 ? .wheelRight : .wheelLeft
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
