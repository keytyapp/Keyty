//
//  KeycapLegend.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Visual content rendered inside a keycap.
///
/// This answers "what should be drawn?" independently from semantic identity.
struct KeycapLegend {
    let symbol: String
    let image: NSImage?
    let imageBadgeText: String?
    let sfSymbolName: String?
    let label: String?
    let rendersSymbolWithLabel: Bool

    init(
        symbol: String = "",
        image: NSImage? = nil,
        imageBadgeText: String? = nil,
        sfSymbolName: String? = nil,
        label: String? = nil,
        rendersSymbolWithLabel: Bool = false
    ) {
        self.symbol = symbol
        self.image = image
        self.imageBadgeText = imageBadgeText
        self.sfSymbolName = sfSymbolName
        self.label = label
        self.rendersSymbolWithLabel = rendersSymbolWithLabel
    }
}

// MARK: - Helpers
extension KeycapLegend {
    /// Renders a resolved legend, loading its resource at this renderer's size.
    init(_ legend: EventLegend, mouseIconHeight: CGFloat) {
        switch legend.kind {
        case .text:
            self.init(symbol: legend.text, label: legend.label)
        case .symbol(let name):
            self.init(sfSymbolName: name, label: legend.label)
        case .mouseIcon(let kind):
            self.init(
                symbol: legend.text,
                image: MouseEventDisplayRenderer.templateIconImage(for: kind, height: mouseIconHeight),
                imageBadgeText: kind.otherButtonNumber.map(String.init),
                label: legend.label
            )
        }
    }

    static func modifier(_ modifier: KeyboardModifierKey.Kind) -> KeycapLegend {
        KeycapLegend(symbol: modifier.glyph, label: modifier.label)
    }
    
    static func character(_ symbol: String) -> KeycapLegend {
        KeycapLegend(symbol: symbol)
    }
}

// MARK: - Instances
extension KeycapLegend {
    static let function = KeycapLegend(sfSymbolName: "globe", label: KeyboardSpecialKey.function.label, rendersSymbolWithLabel: true)
    static let tab = KeycapLegend(symbol: KeyboardGlyphCatalog.tab, label: KeyboardSpecialKey.tab.label)
    static let escape = KeycapLegend(symbol: KeyboardGlyphCatalog.symbol(for: .escape), label: KeyboardSpecialKey.escape.label)
    static let delete = KeycapLegend(symbol: KeyboardGlyphCatalog.symbol(for: .delete), label: KeyboardSpecialKey.delete.label)
    static let forwardDelete = KeycapLegend(symbol: KeyboardGlyphCatalog.symbol(for: .forwardDelete), label: KeyboardSpecialKey.forwardDelete.label)
    static let `return` = KeycapLegend(symbol: KeyboardGlyphCatalog.symbol(for: .returnKey), label: KeyboardSpecialKey.returnKey.label)
    static let enter = KeycapLegend(symbol: KeyboardGlyphCatalog.symbol(for: .keypadEnter), label: KeyboardSpecialKey.keypadEnter.label)
    static let space = KeycapLegend(symbol: KeyboardGlyphCatalog.symbol(for: .space))
    static let capsLock = KeycapLegend(label: KeyboardSpecialKey.capsLock.label)
}
