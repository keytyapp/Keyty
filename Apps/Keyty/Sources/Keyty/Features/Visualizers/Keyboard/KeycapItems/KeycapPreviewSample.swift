//
//  KeycapPreviewSample.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum KeycapPreviewSample {
    case key(
        keyCode: UInt16,
        legend: EventLegend,
        modifierFlags: NSEvent.ModifierFlags = [],
        isPressed: Bool = false
    )
    case mouse(MouseEvent.Kind, isPressed: Bool = false)
    case media(MediaKeyEvent.Kind, isPressed: Bool = false)
    case modifiers(
        current: NSEvent.ModifierFlags = [],
        released: NSEvent.ModifierFlags = []
    )
}
