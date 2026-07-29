//
//  TestKeystrokes.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
@testable import Keyty

enum TestKeystrokes {
    static func make(
        keyCode: UInt16,
        modifiers: NSEvent.ModifierFlags = [],
        characters: String,
        charactersIgnoringModifiers: String
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
            keyCode: keyCode
        )!
        return StandardKeyEvent(nsEvent: event)
    }
}
