//
//  InputEvent.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

public enum InputEvent {
    case keystroke(StandardKeyEvent)
    case mouse(MouseEvent)
    case mediaKey(MediaKeyEvent)

    public var type: NSEvent.EventType {
        switch self {
        case .keystroke(let event):
            return event.type
        case .mouse(let event):
            return event.type
        case .mediaKey(let event):
            return event.type
        }
    }

    public var modifierFlags: NSEvent.ModifierFlags {
        switch self {
        case .keystroke(let event):
            return event.modifierFlags
        case .mouse(let event):
            return event.modifierFlags
        case .mediaKey(let event):
            return event.modifierFlags
        }
    }

}
