//
//  KeycapItemFactory+Media.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapItemFactory {
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
}
