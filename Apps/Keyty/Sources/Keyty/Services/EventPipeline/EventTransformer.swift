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
            return self.transform(keystroke)
        case .mouse(let mouseEvent):
            return self.transform(mouseEvent)
        case .mediaKey(let mediaKey):
            return self.transform(mediaKey)
        }
    }
}

// MARK: - Event Transforms
private extension EventTransformer {
    func transform(_ keystroke: StandardKeyEvent) -> String {
        if let glyph = InputEventGlyphMapper.glyph(for: keystroke.inputEvent) {
            return glyph
        }

        var response = self.modifierPrefix(for: keystroke.modifierFlags)

        if let specialKeyString = KeyboardSpecialKeyResolver.displayText(for: keystroke) {
            return response + specialKeyString
        }

        response += self.uchrData.translatedKeyCode(keystroke.keyCode)

        if keystroke.isModified {
            response = self.legendCased(response)
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

// MARK: - Display Formatting
private extension EventTransformer {
    // Uppercases a legend only when the result keeps its length.
    private func legendCased(_ text: String) -> String {
        let uppercased = text.uppercased()
        return uppercased.count == text.count ? uppercased : text
    }


    // The glyphs for the held modifiers, in Apple's canonical display order.
    private func modifierPrefix(for modifiers: NSEvent.ModifierFlags) -> String {
        KeyboardModifierKey.Kind.canonicalDisplayOrder
            .filter { modifiers.contains($0.flag) }
            .map(\.glyph)
            .joined()
    }
}
