//
//  EventTransformerStandardKeyEventTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import XCTest
@testable import Keyty

final class EventTransformerStandardKeyEventTests: XCTestCase {
    var transformer: EventTransformer!

    func transform(_ event: StandardKeyEvent) -> String {
        self.transformer.transform(.keystroke(event))
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.transformer = EventTransformer(keyboardLayout: try TISInputSource.usEnglish())
    }
}

// MARK: - Modifier Glyphs

extension EventTransformerStandardKeyEventTests {
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

    func testModifierGlyphsPrecedeTheLegendInCanonicalOrder() {
        for (modifiers, name) in Self.allModifierCombinations {
            let keystroke = StandardKeyEvent.stub(keyCode: .digit7, modifiers: modifiers)

            XCTAssertEqual(
                self.transform(keystroke),
                self.expectedPrefix(for: modifiers) + "7",
                "for \(name)"
            )
        }
    }

    /// A digit has no distinct uppercase form, so only letters show the casing rule.
    func testLetterLegendIsUppercasedOnlyWhenModified() {
        for (modifiers, name) in Self.allModifierCombinations {
            let keystroke = StandardKeyEvent.stub(keyCode: .a, modifiers: modifiers)
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
    func testOptionLegendIgnoresTheAlternateCharacter() {
        let cases: [(KeyboardKeyCode, String)] = [(.u, "U"), (.e, "E"), (.grave, "`")]

        for (keyCode, expectedLegend) in cases {
            let keystroke = StandardKeyEvent.stub(keyCode: keyCode, modifiers: .recorded(.option))

            XCTAssertEqual(
                self.transform(keystroke),
                KeyboardGlyphCatalog.option + expectedLegend,
                "for \(keyCode)"
            )
        }
    }
}

// MARK: - Legend Casing

extension EventTransformerStandardKeyEventTests {
    /// German ß uppercases to "SS", which would misreport the key's legend.
    func testLegendThatExpandsWhenUppercasedIsLeftAlone() throws {
        let german = EventTransformer(keyboardLayout: try TISInputSource.german())
        let keystroke = StandardKeyEvent.stub(keyCode: .minus, modifiers: .recorded(.command))

        XCTAssertEqual(german.transform(.keystroke(keystroke)), KeyboardGlyphCatalog.command + "ß")
    }
}

// MARK: - Keys Named by the Layout

extension EventTransformerStandardKeyEventTests {
    func testEditingKeysUseDistinctSymbols() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.tab, KeyboardGlyphCatalog.tab),
            (.returnKey, UnicodeToken.returnKey.string),
            (.keypadEnter, UnicodeToken.keypadEnter.string),
            (.delete, UnicodeToken.delete.string),
            (.forwardDelete, UnicodeToken.forwardDelete.string)
        ]

        for (keyCode, expected) in cases {
            let keystroke = StandardKeyEvent.stub(keyCode: keyCode)
            XCTAssertEqual(self.transform(keystroke), expected, "for \(keyCode)")
        }
    }

    func testArrowKeysUseFilledTriangleSymbols() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.leftArrow, UnicodeToken.leftArrow.string),
            (.upArrow, UnicodeToken.upArrow.string),
            (.downArrow, UnicodeToken.downArrow.string),
            (.rightArrow, UnicodeToken.rightArrow.string)
        ]

        for (keyCode, expected) in cases {
            let keystroke = StandardKeyEvent.stub(keyCode: keyCode)
            XCTAssertEqual(self.transform(keystroke), expected, "for \(keyCode)")
        }
    }

    func testModifiersPrefixASpecialKeySymbol() {
        let character = String.functionKey(NSUpArrowFunctionKey)
        let keystroke = StandardKeyEvent.stub(
            keyCode: .upArrow,
            modifiers: .recorded([.function, .option, .shift, .numericPad]),
            characters: character,
            charactersIgnoringModifiers: character
        )

        XCTAssertEqual(
            self.transform(keystroke),
            KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + UnicodeToken.upArrow.string
        )
    }

    func testSystemKeysUseTheirOwnNames() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.brightnessDown, "dimmer"),
            (.brightnessUp, "brighter"),
            (.missionControl, "mission"),
            (.launchpad, "launchpad")
        ]

        for (keyCode, expected) in cases {
            let keystroke = StandardKeyEvent.stub(keyCode: keyCode, modifiers: .recorded(.function))
            XCTAssertEqual(self.transform(keystroke), expected, "for \(keyCode)")
        }
    }

    func testJapaneseInputKeysUseTheirOwnLabels() {
        let cases: [(KeyboardKeyCode, KeyboardSpecialKey)] = [(.eisu, .eisu), (.kana, .kana)]

        for (keyCode, specialKey) in cases {
            let keystroke = StandardKeyEvent.stub(keyCode: keyCode)
            XCTAssertEqual(self.transform(keystroke), specialKey.displayText, "for \(keyCode)")
        }
    }
}

// MARK: - Keys Named by the Event

extension EventTransformerStandardKeyEventTests {
    /// macOS reuses the Help key code for Insert on many external keyboards, so
    /// these three keys are told apart by the event's characters, not the key code.
    func testHelpKeyCodeResolvesFromTheEventCharacters() {
        let insertCharacter = String.functionKey(NSInsertFunctionKey)
        let insert = StandardKeyEvent.stub(
            keyCode: .help,
            characters: insertCharacter,
            charactersIgnoringModifiers: insertCharacter
        )
        XCTAssertEqual(self.transform(insert), KeyboardSpecialKey.insert.displayText)

        let helpCharacter = String.functionKey(NSHelpFunctionKey)
        let help = StandardKeyEvent.stub(
            keyCode: .help,
            characters: helpCharacter,
            charactersIgnoringModifiers: helpCharacter
        )
        XCTAssertEqual(self.transform(help), "help")

        let withoutCharacters = StandardKeyEvent.stub(keyCode: .help)
        XCTAssertEqual(self.transform(withoutCharacters), KeyboardSpecialKey.insert.displayText)
    }
}
