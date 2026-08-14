//
//  EventLegendResolver.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Carbon

/// Resolves an input event into the legend that represents it on screen.
///
/// This is the single place that decides what a key shows: renderers consume
/// the result without re-deriving anything from it.
struct EventLegendResolver {
    private let uchrData: UnsafePointer<UCKeyboardLayout>

    init(keyboardLayout: TISInputSource) {
        self.uchrData = keyboardLayout.unicodeKeyboardLayout
    }

    func legend(for event: InputEvent) -> EventLegend {
        switch event {
        case .keystroke(let keystroke):
            return self.legend(for: keystroke)
        case .mouse(let mouseEvent):
            return self.legend(for: mouseEvent)
        case .mediaKey(let mediaKey):
            return self.legend(for: mediaKey)
        }
    }

    /// Resolves a key with no event behind it, for previews and samples.
    ///
    /// Keys told apart by their characters rather than their key code — Help
    /// versus Insert — resolve to the key code's meaning here.
    func legend(forKeyCode keyCode: KeyboardKeyCode, modifiers: NSEvent.ModifierFlags = []) -> EventLegend {
        self.legend(for: .keystroke(StandardKeyEvent(keyCode: keyCode.rawValue, modifierFlags: modifiers)))
    }
}

// MARK: - Per-Event Resolution
private extension EventLegendResolver {
    func legend(for keystroke: StandardKeyEvent) -> EventLegend {
        let modifiers = Self.modifiers(in: keystroke.modifierFlags)
        let specialKey = KeyboardSpecialKeyResolver.specialKey(for: keystroke)

        if let symbolName = InputEventSymbolMapper.keystrokeSymbolName(for: keystroke.keyCode) {
            return EventLegend(
                modifiers: modifiers,
                kind: .symbol(symbolName),
                text: specialKey?.displayText ?? self.translatedKey(keystroke),
                label: specialKey?.label
            )
        }

        if let specialKey {
            return EventLegend(
                modifiers: modifiers,
                kind: .text,
                text: specialKey.displayText,
                label: specialKey.label
            )
        }

        return EventLegend(
            modifiers: modifiers,
            kind: .text,
            text: self.translatedKey(keystroke)
        )
    }

    func legend(for mouseEvent: MouseEvent) -> EventLegend {
        EventLegend(
            modifiers: Self.modifiers(in: mouseEvent.modifierFlags),
            kind: .mouseIcon(mouseEvent.kind),
            text: InputEventGlyphMapper.mouseDisplayText(for: mouseEvent.kind)
        )
    }

    func legend(for mediaKey: MediaKeyEvent) -> EventLegend {
        let symbolName = InputEventSymbolMapper.mediaKeySymbolName(for: mediaKey.kind)
        return EventLegend(
            kind: symbolName.map(EventLegend.Kind.symbol) ?? .text,
            text: InputEventGlyphMapper.mediaKeyGlyph(for: mediaKey)
        )
    }
}

// MARK: - Layout Translation
private extension EventLegendResolver {
    // The legend printed on the physical key, which is uppercase on a real
    // keyboard whether or not a modifier is held.
    func translatedKey(_ keystroke: StandardKeyEvent) -> String {
        Self.legendCased(self.uchrData.translatedKeyCode(keystroke.keyCode))
    }

    // Uppercases a legend only when the result keeps its length.
    static func legendCased(_ text: String) -> String {
        let uppercased = text.uppercased()
        return uppercased.count == text.count ? uppercased : text
    }

    static func modifiers(in flags: NSEvent.ModifierFlags) -> [KeyboardModifierKey.Kind] {
        KeyboardModifierKey.Kind.canonicalDisplayOrder.filter { flags.contains($0.flag) }
    }
}
