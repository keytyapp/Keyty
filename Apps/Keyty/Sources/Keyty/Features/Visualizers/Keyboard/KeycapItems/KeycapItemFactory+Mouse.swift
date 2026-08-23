//
//  KeycapItemFactory+Mouse.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapItemFactory {
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
            height: Self.mouseIconHeight
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
}
