//
//  DisplayItem.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

public enum DisplayItem {
    case content(
        text: String,
        sourceEvent: InputEvent,
        startsNewLine: Bool,
        isModified: Bool,
        isMouseEvent: Bool
    )
    case groupBreak
    case flagsChanged(NSEvent.ModifierFlags)
}
