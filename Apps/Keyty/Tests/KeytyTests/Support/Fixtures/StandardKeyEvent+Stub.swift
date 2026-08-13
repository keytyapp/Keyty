//
//  StandardKeyEvent+Stub.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
@testable import Keyty

extension StandardKeyEvent {
    // The transformer resolves a legend from the key code and the layout, so
    // `characters` only matters for keys whose meaning comes from the event
    // itself — Help versus Insert, and the arrow function keys.
    static func stub(
        keyCode: KeyboardKeyCode,
        modifiers: NSEvent.ModifierFlags = [],
        characters: String = "",
        charactersIgnoringModifiers: String = ""
    ) -> StandardKeyEvent {
        let event = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: modifiers,
            timestamp: NSDate.timeIntervalSinceReferenceDate,
            windowNumber: 0,
            context: nil,
            characters: characters,
            charactersIgnoringModifiers: charactersIgnoringModifiers,
            isARepeat: false,
            keyCode: keyCode.rawValue
        )!
        return StandardKeyEvent(nsEvent: event)
    }
}
