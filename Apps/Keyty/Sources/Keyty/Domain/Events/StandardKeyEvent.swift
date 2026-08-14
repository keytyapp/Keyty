//
//  StandardKeyEvent.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

public struct StandardKeyEvent {
    public let type: NSEvent.EventType
    public let modifierFlags: NSEvent.ModifierFlags
    public let keyCode: UInt16
    public let characters: String?
    public let charactersIgnoringModifiers: String?

    /// A key identified only by its code, for previews and samples that have no
    /// event behind them.
    public init(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags = []) {
        self.type = .keyDown
        self.modifierFlags = modifierFlags
        self.keyCode = keyCode
        self.characters = nil
        self.charactersIgnoringModifiers = nil
    }

    public init(nsEvent event: NSEvent) {
        self.type = event.type
        self.modifierFlags = event.modifierFlags
        self.keyCode = event.keyCode
        self.characters = event.characters
        self.charactersIgnoringModifiers = event.charactersIgnoringModifiers
    }

    public var inputEvent: InputEvent {
        .keystroke(self)
    }

    public var isModified: Bool {
        !self.modifierFlags.intersection([.control, .command, .option, .shift]).isEmpty
    }
}
