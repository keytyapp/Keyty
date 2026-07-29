//
//  EventTransformer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import Foundation
import AppKit

public final class EventTransformer {
    private let keyboardLayout: TISInputSource
    private let uchrData: UnsafePointer<UCKeyboardLayout>

    public static var shared: EventTransformer {
        EventTransformer(keyboardLayout: KeyboardInputSourceManager.shared.currentInputSource)
    }

    init(keyboardLayout: TISInputSource) {
        self.keyboardLayout = keyboardLayout
        self.uchrData = keyboardLayout.unicodeKeyboardLayout
    }

    public func transform(_ event: InputEvent) -> String {
        switch event {
        case .keystroke(let keystroke):
            return transform(keystroke)
        case .mouse(let mouseEvent):
            return transform(mouseEvent)
        case .mediaKey(let mediaKey):
            return transform(mediaKey)
        }
    }

    private func shouldReturnOriginalCharacters(keyCode: UInt16, characters: String?) -> Bool {
        keyCode == KeyboardKeyCode.minus.rawValue && characters == "ß"
    }

    private func modifierPrefix(
        for modifiers: NSEvent.ModifierFlags,
        includesDeferredShift: Bool = true
    ) -> String {
        let hasOptionModifier = modifiers.contains(.option)
        let hasShiftModifier = modifiers.contains(.shift)
        let usesShortcutStyle = !modifiers.intersection([.control, .command]).isEmpty
        var needsShiftGlyph = false
        var response = ""

        if modifiers.contains(.control) {
            response += KeyboardGlyphCatalog.control
        }

        if hasOptionModifier {
            response += KeyboardGlyphCatalog.option
        }

        if hasShiftModifier {
            if usesShortcutStyle || hasOptionModifier {
                response += KeyboardGlyphCatalog.shift
            } else {
                needsShiftGlyph = true
            }
        }

        if modifiers.contains(.command) {
            if needsShiftGlyph {
                response += KeyboardGlyphCatalog.shift
                needsShiftGlyph = false
            }
            response += KeyboardGlyphCatalog.command
        }

        if needsShiftGlyph && includesDeferredShift {
            response += KeyboardGlyphCatalog.shift
        }

        return response
    }
}

private extension EventTransformer {
    func transform(_ keystroke: StandardKeyEvent) -> String {
        if let glyph = InputEventGlyphMapper.glyph(for: keystroke.inputEvent) {
            return glyph
        }

        let modifiers = keystroke.modifierFlags
        let hasOptionModifier = modifiers.contains(.option)
        let hasShiftModifier = modifiers.contains(.shift)
        let isCommand = !modifiers.intersection([.control, .command]).isEmpty
        var response = self.modifierPrefix(for: modifiers, includesDeferredShift: false)

        if hasShiftModifier && !keystroke.isCommand && !hasOptionModifier && keystroke.keyCode == KeyboardKeyCode.tab.rawValue {
            response += KeyboardGlyphCatalog.backTab
            return response
        }

        if hasShiftModifier && !isCommand && !hasOptionModifier {
            response += KeyboardGlyphCatalog.shift
        }

        if let specialKeyString = KeyboardSpecialKeyResolver.displayText(for: keystroke) {
            response += specialKeyString
            return response
        }

        if isCommand,
           shouldReturnOriginalCharacters(keyCode: keystroke.keyCode, characters: keystroke.characters) {
            response += keystroke.characters ?? ""
        } else {
            response += uchrData.translatedKeyCode(keystroke.keyCode)
        }

        if isCommand || hasShiftModifier || hasOptionModifier {
            if keystroke.keyCode != KeyboardKeyCode.minus.rawValue {
                response = response.uppercased()
            }
        }

        return response
    }

    func transform(_ mouseEvent: MouseEvent) -> String {
        var response = self.modifierPrefix(for: mouseEvent.modifierFlags)
        response += InputEventGlyphMapper.mouseDisplayText(for: mouseEvent.kind)
        return response
    }

    func transform(_ mediaKey: MediaKeyEvent) -> String {
        InputEventGlyphMapper.mediaKeyGlyph(for: mediaKey)
    }
}
