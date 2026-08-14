//
//  EventTap+Event.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension EventTap {
    enum Event {
        case keystroke(StandardKeyEvent)
        case mouse(MouseEvent)
        case mediaKey(MediaKeyEvent)
        case modifierFlags(NSEvent.ModifierFlags)
    }
}
