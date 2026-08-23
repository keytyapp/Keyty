//
//  KeycapItemFactory+Preview.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapItemFactory {
    static func items(for sample: KeycapPreviewSample, palette: KeycapThemePalette) -> [KeycapItem] {
        switch sample {
        case let .key(keyCode, legend, modifierFlags, isPressed):
            return Self.keycapItems(
                keyCode: keyCode,
                legend: legend,
                modifierFlags: modifierFlags,
                isPressed: isPressed,
                palette: palette
            )
        case let .mouse(kind, isPressed):
            return [Self.mouseItem(for: kind, isPressed: isPressed, palette: palette)]
        case let .media(kind, isPressed):
            return [Self.mediaKeyItem(for: kind, isPressed: isPressed, palette: palette)]
        case let .modifiers(current, released):
            return Self.modifierItems(currentFlags: current, releasedFlags: released, palette: palette)
        }
    }
}
