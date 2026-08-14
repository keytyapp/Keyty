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

    public var displayString: String {
        EventTransformer.shared.transform(self.inputEvent)
    }

    public var isModified: Bool {
        !self.modifierFlags.intersection([.control, .command, .option, .shift]).isEmpty
    }
}
