//
//  EventTransformerKeystrokeTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import XCTest
@testable import Keyty

final class EventTransformerKeystrokeTests: XCTestCase {
    var transformer: EventTransformer!

    func transform(_ event: StandardKeyEvent) -> String {
        self.transformer.transform(.keystroke(event))
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.transformer = EventTransformer(keyboardLayout: try TestKeyboardLayouts.requireUSEnglish())
    }
}

// MARK: - Modifier Glyphs

extension EventTransformerKeystrokeTests {
    /// The order the glyphs are expected in, written out independently of the
    /// `canonicalDisplayOrder` the transformer reads, so a reordering there fails here.
    private static let expectedGlyphOrder: [(flag: NSEvent.ModifierFlags, glyph: String)] = [
        (.control, KeyboardGlyphCatalog.control),
        (.option, KeyboardGlyphCatalog.option),
        (.shift, KeyboardGlyphCatalog.shift),
        (.command, KeyboardGlyphCatalog.command)
    ]

    /// Every combination of the four modifiers, as flags plus a readable name.
    private static var allModifierCombinations: [(modifiers: NSEvent.ModifierFlags, name: String)] {
        (0..<16).map { combination in
            var modifiers: NSEvent.ModifierFlags = []
            var names: [String] = []
            for (index, entry) in Self.expectedGlyphOrder.enumerated() where combination & (1 << index) != 0 {
                modifiers.insert(entry.flag)
                names.append(entry.glyph)
            }
            return (modifiers, names.isEmpty ? "no modifiers" : names.joined())
        }
    }

    private func expectedPrefix(for modifiers: NSEvent.ModifierFlags) -> String {
        Self.expectedGlyphOrder
            .filter { modifiers.contains($0.flag) }
            .map(\.glyph)
            .joined()
    }

    func test_modifierGlyphsPrecedeTheLegendInCanonicalOrder() {
        for (modifiers, name) in Self.allModifierCombinations {
            let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: modifiers)

            XCTAssertEqual(
                self.transform(keystroke),
                self.expectedPrefix(for: modifiers) + "7",
                "for \(name)"
            )
        }
    }

    /// A digit has no distinct uppercase form, so only letters show the casing rule.
    func test_letterLegendIsUppercasedOnlyWhenModified() {
        for (modifiers, name) in Self.allModifierCombinations {
            let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: modifiers)
            let expectedLegend = modifiers.isEmpty ? "a" : "A"

            XCTAssertEqual(
                self.transform(keystroke),
                self.expectedPrefix(for: modifiers) + expectedLegend,
                "for \(name)"
            )
        }
    }

    /// Option produces a dead key or an alternate character, but the legend stays
    /// the one printed on the key.
    func test_optionLegendIgnoresTheAlternateCharacter() {
        let cases: [(KeyboardKeyCode, String)] = [(.u, "U"), (.e, "E"), (.grave, "`")]

        for (keyCode, expectedLegend) in cases {
            let keystroke = TestKeystrokes.make(keyCode: keyCode.rawValue, modifiers: TestModifierFlags.option)

            XCTAssertEqual(
                self.transform(keystroke),
                KeyboardGlyphCatalog.option + expectedLegend,
                "for \(keyCode)"
            )
        }
    }
}

// MARK: - Legend Casing

extension EventTransformerKeystrokeTests {
    /// German ß uppercases to "SS", which would misreport the key's legend.
    func test_legendThatExpandsWhenUppercasedIsLeftAlone() throws {
        let german = EventTransformer(keyboardLayout: try TestKeyboardLayouts.requireGerman())
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.minus.rawValue, modifiers: TestModifierFlags.command)

        XCTAssertEqual(german.transform(.keystroke(keystroke)), KeyboardGlyphCatalog.command + "ß")
    }
}

// MARK: - Keys Named by the Layout

extension EventTransformerKeystrokeTests {
    func test_editingKeysUseDistinctSymbols() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.tab, KeyboardGlyphCatalog.tab),
            (.returnKey, UnicodeToken.returnKey.string),
            (.keypadEnter, UnicodeToken.keypadEnter.string),
            (.delete, UnicodeToken.delete.string),
            (.forwardDelete, UnicodeToken.forwardDelete.string)
        ]

        for (keyCode, expected) in cases {
            let keystroke = TestKeystrokes.make(keyCode: keyCode.rawValue)
            XCTAssertEqual(self.transform(keystroke), expected, "for \(keyCode)")
        }
    }

    func test_arrowKeysUseFilledTriangleSymbols() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.leftArrow, UnicodeToken.leftArrow.string),
            (.upArrow, UnicodeToken.upArrow.string),
            (.downArrow, UnicodeToken.downArrow.string),
            (.rightArrow, UnicodeToken.rightArrow.string)
        ]

        for (keyCode, expected) in cases {
            let keystroke = TestKeystrokes.make(keyCode: keyCode.rawValue)
            XCTAssertEqual(self.transform(keystroke), expected, "for \(keyCode)")
        }
    }

    func test_modifiersPrefixASpecialKeySymbol() {
        let character = TestKeyboardCharacters.functionKeyCharacter(NSUpArrowFunctionKey)
        let keystroke = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.upArrow.rawValue,
            modifiers: TestModifierFlags.functionOptionShiftNumericPad,
            characters: character,
            charactersIgnoringModifiers: character
        )

        XCTAssertEqual(
            self.transform(keystroke),
            KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + UnicodeToken.upArrow.string
        )
    }

    func test_systemKeysUseTheirOwnNames() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.brightnessDown, "dimmer"),
            (.brightnessUp, "brighter"),
            (.missionControl, "mission"),
            (.launchpad, "launchpad")
        ]

        for (keyCode, expected) in cases {
            let keystroke = TestKeystrokes.make(keyCode: keyCode.rawValue, modifiers: TestModifierFlags.function)
            XCTAssertEqual(self.transform(keystroke), expected, "for \(keyCode)")
        }
    }

    func test_japaneseInputKeysUseTheirOwnLabels() {
        let cases: [(KeyboardKeyCode, KeyboardSpecialKey)] = [(.eisu, .eisu), (.kana, .kana)]

        for (keyCode, specialKey) in cases {
            let keystroke = TestKeystrokes.make(keyCode: keyCode.rawValue)
            XCTAssertEqual(self.transform(keystroke), specialKey.displayText, "for \(keyCode)")
        }
    }
}

// MARK: - Keys Named by the Event

extension EventTransformerKeystrokeTests {
    /// macOS reuses the Help key code for Insert on many external keyboards, so
    /// these three keys are told apart by the event's characters, not the key code.
    func test_helpKeyCodeResolvesFromTheEventCharacters() {
        let insertCharacter = TestKeyboardCharacters.functionKeyCharacter(NSInsertFunctionKey)
        let insert = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.help.rawValue,
            characters: insertCharacter,
            charactersIgnoringModifiers: insertCharacter
        )
        XCTAssertEqual(self.transform(insert), KeyboardSpecialKey.insert.displayText)

        let helpCharacter = TestKeyboardCharacters.functionKeyCharacter(NSHelpFunctionKey)
        let help = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.help.rawValue,
            characters: helpCharacter,
            charactersIgnoringModifiers: helpCharacter
        )
        XCTAssertEqual(self.transform(help), "help")

        let withoutCharacters = TestKeystrokes.make(keyCode: KeyboardKeyCode.help.rawValue)
        XCTAssertEqual(self.transform(withoutCharacters), KeyboardSpecialKey.insert.displayText)
    }
}
