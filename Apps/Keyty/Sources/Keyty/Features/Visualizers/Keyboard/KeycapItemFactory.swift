//
//  KeycapItemFactory.swift
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

/// Centralizes conversion into `KeycapItem` so runtime input events
/// and settings previews are built from the same rules.
///
/// Each item resolves its own appearance from the `KeycapThemePalette` by its
/// `KeycapIdentity`, so per-key-type theming applies uniformly across every branch.
enum KeycapItemFactory {
    private static let mouseIconHeight: CGFloat = 44
    private static let orderedModifierLocations: [KeyboardModifierKey.Location] = [.left, .right]

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

    static func mouseItem(for mouseEvent: MouseEvent, palette: KeycapThemePalette) -> KeycapItem {
        Self.mouseItem(
            for: mouseEvent.kind,
            isPressed: Self.isPressedMouseEvent(mouseEvent),
            palette: palette
        )
    }

    static func mouseItem(
        for kind: MouseEvent.Kind,
        isPressed: Bool,
        palette: KeycapThemePalette
    ) -> KeycapItem {
        let identity = KeycapIdentity.mouse(kind)
        let appearance = palette.appearance(for: identity)
        if let icon = MouseEventDisplayRenderer.templateIconImage(
            for: kind,
            height: mouseIconHeight
        ) {
            return KeycapItem(
                identity: identity,
                legend: KeycapLegend(
                    image: icon,
                    imageBadgeText: kind.otherButtonNumber.map(String.init)
                ),
                state: KeycapState(isPressed: isPressed),
                appearance: appearance
            )
        }

        return KeycapItem(
            identity: identity,
            legend: KeycapLegend(symbol: InputEventGlyphMapper.mouseDisplayText(for: kind)),
            state: KeycapState(isPressed: isPressed),
            layoutHints: KeycapLayoutHints(fixedWidth: 112),
            appearance: appearance
        )
    }

    static func mediaKeyItem(for mediaKey: MediaKeyEvent, palette: KeycapThemePalette) -> KeycapItem {
        Self.mediaKeyItem(for: mediaKey.kind, isPressed: mediaKey.isPressed, palette: palette)
    }

    static func mediaKeyItem(
        for kind: MediaKeyEvent.Kind,
        isPressed: Bool,
        palette: KeycapThemePalette
    ) -> KeycapItem {
        let identity = KeycapIdentity.media(kind)
        return KeycapItem(
            identity: identity,
            legend: KeycapLegend(
                sfSymbolName: InputEventSymbolMapper.mediaKeySymbolName(for: kind)
            ),
            state: KeycapState(isPressed: isPressed),
            appearance: palette.appearance(for: identity)
        )
    }

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

    // Legend for a key, with the two keys whose keycap styling differs from
    // what the resolved legend alone describes.
    private static func keycapLegend(for keyCode: UInt16, legend: EventLegend) -> KeycapLegend {
        switch KeyboardSpecialKeyResolver.specialKey(for: keyCode) {
        case .function:
            return .function
        case .capsLock:
            return .capsLock
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

    private static func isPressedMouseEvent(_ mouseEvent: MouseEvent) -> Bool {
        switch mouseEvent.type {
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            return true
        case .leftMouseUp, .rightMouseUp, .otherMouseUp:
            return false
        default:
            return false
        }
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

private extension KeyboardModifierKey {
    var legendAlignment: KeycapLegendAlignment {
        switch self.location {
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}
