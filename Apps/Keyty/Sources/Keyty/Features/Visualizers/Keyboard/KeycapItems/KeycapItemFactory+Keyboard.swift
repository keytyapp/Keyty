//
//  KeycapItemFactory+Keyboard.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapItemFactory {
    static func keycapItems(
        for keystroke: StandardKeyEvent,
        legend: EventLegend,
        palette: KeycapThemePalette
    ) -> [KeycapItem] {
        Self.keycapItems(
            keyCode: keystroke.keyCode,
            legend: legend,
            modifierFlags: keystroke.modifierFlags,
            isPressed: keystroke.type != .keyUp,
            palette: palette
        )
    }

    static func keycapItems(
        keyCode: UInt16,
        legend: EventLegend,
        modifierFlags: NSEvent.ModifierFlags,
        isPressed: Bool,
        palette: KeycapThemePalette
    ) -> [KeycapItem] {
        var result = Self.modifierItems(
            currentFlags: modifierFlags.subtracting(.function),
            releasedFlags: [],
            palette: palette
        )
        guard !legend.text.isEmpty || legend.kind != .text else { return result }

        let identity = KeycapIdentity.keyCode(keyCode)
        result.append(KeycapItem(
            identity: identity,
            legend: Self.keycapLegend(for: keyCode, legend: legend),
            state: KeycapState(isPressed: isPressed),
            layoutHints: Self.layoutHints(forKeyCode: keyCode),
            appearance: palette.appearance(for: identity)
        ))
        return result
    }

    // Legend for a key, with the two keys whose keycap styling differs from
    // what the resolved legend alone describes.
    private static func keycapLegend(for keyCode: UInt16, legend: EventLegend) -> KeycapLegend {
        switch KeyboardSpecialKeyResolver.specialKey(for: keyCode) {
        case .function:
            return .function
        case .capsLock:
            return .capsLock
        case .home:
            return .home
        case .end:
            return .end
        case .pageUp:
            return .pageUp
        case .pageDown:
            return .pageDown
        default:
            return KeycapLegend(legend, mouseIconHeight: Self.mouseIconHeight)
        }
    }

    // Layout is a rendering concern, so it stays here rather than in the legend.
    private static func layoutHints(forKeyCode keyCode: UInt16) -> KeycapLayoutHints {
        switch KeyboardSpecialKeyResolver.specialKey(for: keyCode) {
        case .tab, .escape:
            return KeycapLayoutHints(alignment: .left)
        case .space:
            return KeycapLayoutHints(fixedWidth: 256)
        default:
            return KeycapLayoutHints()
        }
    }
}
