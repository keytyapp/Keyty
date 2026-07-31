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
        displayString: String,
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
    private static let orderedModifiers: [KeyboardModifierKey.Kind] = [.command, .shift, .option, .control]
    private static let orderedModifierLocations: [KeyboardModifierKey.Location] = [.left, .right]

    static func keycapItems(for keystroke: StandardKeyEvent, palette: KeycapThemePalette) -> [KeycapItem] {
        Self.keycapItems(
            keyCode: keystroke.keyCode,
            displayString: keystroke.displayString,
            modifierFlags: keystroke.modifierFlags,
            isPressed: keystroke.type != .keyUp,
            palette: palette
        )
    }

    static func keycapItems(
        keyCode: UInt16,
        displayString: String,
        modifierFlags: NSEvent.ModifierFlags,
        isPressed: Bool,
        palette: KeycapThemePalette
    ) -> [KeycapItem] {
        var result = Self.modifierItems(
            currentFlags: modifierFlags.subtracting(.function),
            releasedFlags: [],
            palette: palette
        )
        let stripped = Self.stripModifierPrefixes(from: displayString)
        guard !stripped.isEmpty else { return result }

        if let symbolName = InputEventSymbolMapper.keystrokeSymbolName(for: keyCode) {
            let identity = KeycapIdentity.keyCode(keyCode)
            result.append(KeycapItem(
                identity: identity,
                legend: KeycapLegend(sfSymbolName: symbolName),
                state: KeycapState(isPressed: isPressed),
                appearance: palette.appearance(for: identity)
            ))
            return result
        }

        if let specialItem = Self.specialKeycapItem(
            keyCode: keyCode,
            isPressed: isPressed,
            palette: palette
        ) {
            result.append(specialItem)
            return result
        }

        let identity = KeycapIdentity.keyCode(keyCode)
        result.append(KeycapItem(
            identity: identity,
            legend: KeycapLegend(symbol: KeyboardGlyphCatalog.displaySymbol(for: stripped)),
            state: KeycapState(isPressed: isPressed),
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

        for modifier in Self.orderedModifiers {
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
        case let .key(keyCode, displayString, modifierFlags, isPressed):
            return Self.keycapItems(
                keyCode: keyCode,
                displayString: displayString,
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

    private static func specialKeycapItem(
        keyCode: UInt16,
        isPressed: Bool,
        palette: KeycapThemePalette
    ) -> KeycapItem? {
        guard let specialKey = KeyboardSpecialKeyResolver.specialKey(for: keyCode) else { return nil }

        let identity = KeycapIdentity.keyCode(keyCode)
        let appearance = palette.appearance(for: identity)
        switch specialKey {
        case .function:
            return KeycapItem(
                identity: identity,
                legend: .function,
                state: KeycapState(isPressed: isPressed),
                appearance: appearance
            )
        case .tab:
            return KeycapItem(
                identity: identity,
                legend: .tab,
                state: KeycapState(isPressed: isPressed),
                layoutHints: KeycapLayoutHints(alignment: .left),
                appearance: appearance
            )
        case .escape:
            return KeycapItem(
                identity: identity,
                legend: .escape,
                state: KeycapState(isPressed: isPressed),
                layoutHints: KeycapLayoutHints(alignment: .left),
                appearance: appearance
            )
        case .delete:
            return KeycapItem(
                identity: identity,
                legend: .delete,
                state: KeycapState(isPressed: isPressed),
                appearance: appearance
            )
        case .forwardDelete:
            return KeycapItem(
                identity: identity,
                legend: .forwardDelete,
                state: KeycapState(isPressed: isPressed),
                appearance: appearance
            )
        case .returnKey:
            return KeycapItem(
                identity: identity,
                legend: .return,
                state: KeycapState(isPressed: isPressed),
                appearance: appearance
            )
        case .keypadEnter:
            return KeycapItem(
                identity: identity,
                legend: .enter,
                state: KeycapState(isPressed: isPressed),
                appearance: appearance
            )
        case .space:
            return KeycapItem(
                identity: identity,
                legend: .space,
                state: KeycapState(isPressed: isPressed),
                layoutHints: KeycapLayoutHints(fixedWidth: 256),
                appearance: appearance
            )
        default:
            return nil
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

    private static func stripModifierPrefixes(from text: String) -> String {
        var remainder = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var changed = true
        while changed {
            changed = false
            for sym in KeyboardGlyphCatalog.modifierSymbols where remainder.hasPrefix(sym) {
                remainder.removeFirst(sym.count)
                changed = true
            }
        }
        return remainder.trimmingCharacters(in: .whitespacesAndNewlines)
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
