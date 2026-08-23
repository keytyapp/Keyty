//
//  KeycapItemFactory+Modifiers.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapItemFactory {
    static func modifierItems(
        currentFlags: NSEvent.ModifierFlags,
        releasedFlags: NSEvent.ModifierFlags,
        palette: KeycapThemePalette
    ) -> [KeycapItem] {
        var items: [KeycapItem] = []
        let currentModifierKeys = KeyboardModifierKey.keys(in: currentFlags)
        let releasedModifierKeys = KeyboardModifierKey.keys(in: releasedFlags)

        for modifier in KeyboardModifierKey.Kind.canonicalDisplayOrder {
            let modifierKeys = Self.orderedModifierKeys(
                for: modifier,
                currentModifierKeys: currentModifierKeys,
                releasedModifierKeys: releasedModifierKeys
            )
            if !modifierKeys.isEmpty {
                for modifierKey in modifierKeys {
                    items.append(Self.modifierItem(
                        modifierKey,
                        isPressed: currentModifierKeys.contains(modifierKey),
                        palette: palette
                    ))
                }
                continue
            }

            if currentFlags.contains(modifier.flag) || releasedFlags.contains(modifier.flag) {
                let modifierKey = KeyboardModifierKey(modifier, location: .left)
                items.append(Self.modifierItem(
                    modifierKey,
                    isPressed: currentFlags.contains(modifier.flag),
                    palette: palette
                ))
            }
        }

        if currentFlags.contains(.function) || releasedFlags.contains(.function) {
            items.append(Self.functionItem(isPressed: currentFlags.contains(.function), palette: palette))
        }
        return items
    }

    private static func modifierItem(
        _ modifierKey: KeyboardModifierKey,
        isPressed: Bool,
        palette: KeycapThemePalette
    ) -> KeycapItem {
        let identity = KeycapIdentity.modifier(modifierKey)
        return KeycapItem(
            identity: identity,
            legend: KeycapLegend(symbol: modifierKey.kind.glyph, label: modifierKey.kind.label),
            state: KeycapState(isPressed: isPressed),
            layoutHints: KeycapLayoutHints(alignment: modifierKey.legendAlignment),
            appearance: palette.appearance(for: identity)
        )
    }

    private static func orderedModifierKeys(
        for modifier: KeyboardModifierKey.Kind,
        currentModifierKeys: Set<KeyboardModifierKey>,
        releasedModifierKeys: Set<KeyboardModifierKey>
    ) -> [KeyboardModifierKey] {
        let keys = currentModifierKeys.union(releasedModifierKeys)
        return Self.orderedModifierLocations
            .map { KeyboardModifierKey(modifier, location: $0) }
            .filter { keys.contains($0) }
    }

    private static func functionItem(
        isPressed: Bool,
        palette: KeycapThemePalette
    ) -> KeycapItem {
        let identity = KeycapIdentity.keyCode(KeyboardKeyCode.function.rawValue)
        return KeycapItem(
            identity: identity,
            legend: .function,
            state: KeycapState(isPressed: isPressed),
            appearance: palette.appearance(for: identity)
        )
    }
}
