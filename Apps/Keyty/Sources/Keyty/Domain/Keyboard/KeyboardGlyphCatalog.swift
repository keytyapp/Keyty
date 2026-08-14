//
//  KeyboardGlyphCatalog.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

/// Shared display glyphs used by keyboard visualizers.
///
/// This type is intentionally narrow:
/// - it maps known key names to the symbols we render on screen
/// - it exposes the common modifier glyphs in one place
///
/// It is not a key model, storage type, or event transformer.
enum KeyboardGlyphCatalog {
    static let command = KeyboardModifierKey.Kind.command.glyph
    static let shift = KeyboardModifierKey.Kind.shift.glyph
    static let option = KeyboardModifierKey.Kind.option.glyph
    static let control = KeyboardModifierKey.Kind.control.glyph
    
    static let tab = UnicodeToken.tab.string

    /// Physical key codes for left and right command, shift, option, and control keys.
    static let modifierKeyCodes: Set<KeyboardKeyCode> = Set(KeyboardModifierKey.Kind.allCases.flatMap(\.keyCodes))

    static func isModifierKeyCode(_ rawValue: UInt16) -> Bool {
        guard let keyCode = KeyboardKeyCode(rawValue: rawValue) else { return false }
        return modifierKeyCodes.contains(keyCode)
    }

    /// Returns the glyph we show for a typed keyboard key when it has a semantic visual representation.
    static func symbol(for key: KeyboardSpecialKey) -> String {
        key.displayText
    }

}
