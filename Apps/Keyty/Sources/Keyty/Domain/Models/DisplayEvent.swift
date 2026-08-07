//
//  DisplayEvent.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

public enum DisplayEvent {
    case keystroke(StandardKeyEvent)
    case mouse(MouseEvent)
    case mediaKey(MediaKeyEvent)
    case modifierStateChanged(NSEvent.ModifierFlags)
    case groupBreak
}
