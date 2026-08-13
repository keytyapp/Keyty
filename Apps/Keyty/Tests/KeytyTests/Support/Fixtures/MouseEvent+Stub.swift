//
//  MouseEvent+Stub.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
@testable import Keyty

extension MouseEvent {
    static func stub(
        type: NSEvent.EventType,
        buttonNumber: Int = 0,
        modifiers: NSEvent.ModifierFlags = []
    ) -> MouseEvent {
        let cgEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: Self.cgMouseEventType(for: type),
            mouseCursorPosition: .zero,
            mouseButton: Self.cgMouseButton(for: type)
        )!
        cgEvent.setIntegerValueField(.mouseEventButtonNumber, value: Int64(buttonNumber))
        cgEvent.flags = Self.cgEventFlags(for: modifiers)
        return MouseEvent(nsEvent: NSEvent(cgEvent: cgEvent)!)
    }

    static func scrollStub(deltaX: Int32 = 0, deltaY: Int32 = 0) -> MouseEvent {
        let cgEvent = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: deltaY,
            wheel2: deltaX,
            wheel3: 0
        )!
        return MouseEvent(nsEvent: NSEvent(cgEvent: cgEvent)!)
    }

    private static func cgMouseEventType(for nsEventType: NSEvent.EventType) -> CGEventType {
        switch nsEventType {
        case .leftMouseDown: return .leftMouseDown
        case .leftMouseUp: return .leftMouseUp
        case .rightMouseDown: return .rightMouseDown
        case .rightMouseUp: return .rightMouseUp
        case .otherMouseDown: return .otherMouseDown
        case .otherMouseUp: return .otherMouseUp
        default: return .otherMouseDown
        }
    }

    private static func cgMouseButton(for nsEventType: NSEvent.EventType) -> CGMouseButton {
        switch nsEventType {
        case .rightMouseDown, .rightMouseUp: return .right
        default: return .left
        }
    }

    private static func cgEventFlags(for modifierFlags: NSEvent.ModifierFlags) -> CGEventFlags {
        var flags: CGEventFlags = []
        if modifierFlags.contains(.shift) { flags.insert(.maskShift) }
        if modifierFlags.contains(.command) { flags.insert(.maskCommand) }
        if modifierFlags.contains(.control) { flags.insert(.maskControl) }
        if modifierFlags.contains(.option) { flags.insert(.maskAlternate) }
        if modifierFlags.contains(.function) { flags.insert(.maskSecondaryFn) }
        return flags
    }
}
