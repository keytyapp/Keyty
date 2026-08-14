//
//  EventLegendResolverStandardKeyEventTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import XCTest
@testable import Keyty

final class EventLegendResolverStandardKeyEventTests: XCTestCase {
    var resolver: EventLegendResolver!

    func legend(_ event: StandardKeyEvent) -> EventLegend {
        self.resolver.legend(for: InputEvent.keystroke(event))
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.resolver = EventLegendResolver(keyboardLayout: try TISInputSource.usEnglish())
    }
}

// MARK: - Modifiers

extension EventLegendResolverStandardKeyEventTests {
    /// Written out independently of the `canonicalDisplayOrder` the resolver
    /// reads, so a reordering there fails here.
    private static let expectedModifierOrder: [KeyboardModifierKey.Kind] = [.control, .option, .shift, .command]

    private static var allModifierCombinations: [(modifiers: NSEvent.ModifierFlags, kinds: [KeyboardModifierKey.Kind], name: String)] {
        (0..<16).map { combination in
            var kinds: [KeyboardModifierKey.Kind] = []
            var flags: NSEvent.ModifierFlags = []
            for (index, kind) in Self.expectedModifierOrder.enumerated() where combination & (1 << index) != 0 {
                kinds.append(kind)
                flags.insert(kind.flag)
            }
            return (.recorded(flags), kinds, kinds.isEmpty ? "no modifiers" : kinds.map(\.glyph).joined())
        }
    }

    func testModifiersAreReportedInCanonicalOrder() {
        for (modifiers, kinds, name) in Self.allModifierCombinations {
            let legend = self.legend(.stub(keyCode: .digit7, modifiers: modifiers))

            XCTAssertEqual(legend.modifiers, kinds, "for \(name)")
            XCTAssertEqual(legend.text, "7", "for \(name)")
        }
    }

    /// A digit has no distinct uppercase form, so only letters show the casing rule.
    func testLetterTextIsUppercasedOnlyWhenModified() {
        for (modifiers, kinds, name) in Self.allModifierCombinations {
            let legend = self.legend(.stub(keyCode: .a, modifiers: modifiers))

            XCTAssertEqual(legend.text, kinds.isEmpty ? "a" : "A", "for \(name)")
            XCTAssertEqual(legend.kind, .text, "for \(name)")
        }
    }

    /// Option produces a dead key or an alternate character, but the legend stays
    /// the one printed on the key.
    func testOptionTextIgnoresTheAlternateCharacter() {
        for (keyCode, expected) in [(KeyboardKeyCode.u, "U"), (.e, "E"), (.grave, "`")] {
            let legend = self.legend(.stub(keyCode: keyCode, modifiers: .recorded(.option)))

            XCTAssertEqual(legend.text, expected, "for \(keyCode)")
            XCTAssertEqual(legend.modifiers, [.option], "for \(keyCode)")
        }
    }
}

// MARK: - Legend Casing

extension EventLegendResolverStandardKeyEventTests {
    /// German ß uppercases to "SS", which would misreport the key's legend.
    func testTextThatExpandsWhenUppercasedIsLeftAlone() throws {
        let german = EventLegendResolver(keyboardLayout: try TISInputSource.german())
        let legend = german.legend(for: InputEvent.keystroke(.stub(keyCode: .minus, modifiers: .recorded(.command))))

        XCTAssertEqual(legend.text, "ß")
        XCTAssertEqual(legend.modifiers, [.command])
    }
}

// MARK: - Keys Named by the Layout

extension EventLegendResolverStandardKeyEventTests {
    func testEditingKeysUseDistinctSymbols() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.tab, KeyboardGlyphCatalog.tab),
            (.returnKey, UnicodeToken.returnKey.string),
            (.keypadEnter, UnicodeToken.keypadEnter.string),
            (.delete, UnicodeToken.delete.string),
            (.forwardDelete, UnicodeToken.forwardDelete.string)
        ]

        for (keyCode, expected) in cases {
            XCTAssertEqual(self.legend(.stub(keyCode: keyCode)).text, expected, "for \(keyCode)")
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
            XCTAssertEqual(self.legend(.stub(keyCode: keyCode)).text, expected, "for \(keyCode)")
        }
    }

    func testModifiersAccompanyASpecialKeySymbol() {
        let character = String.functionKey(NSUpArrowFunctionKey)
        let legend = self.legend(.stub(
            keyCode: .upArrow,
            modifiers: .recorded([.function, .option, .shift, .numericPad]),
            characters: character,
            charactersIgnoringModifiers: character
        ))

        XCTAssertEqual(legend.modifiers, [.option, .shift])
        XCTAssertEqual(legend.text, UnicodeToken.upArrow.string)
    }

    /// System keys prefer an SF Symbol, and keep a short name behind it.
    func testSystemKeysResolveToSymbolsWithATextFallback() {
        let cases: [(KeyboardKeyCode, String, String)] = [
            (.brightnessDown, "sun.min.fill", "dimmer"),
            (.brightnessUp, "sun.max.fill", "brighter"),
            (.missionControl, "square.grid.2x2.fill", "mission"),
            (.launchpad, "square.grid.3x3.fill", "launchpad")
        ]

        for (keyCode, symbolName, text) in cases {
            let legend = self.legend(.stub(keyCode: keyCode, modifiers: .recorded(.function)))

            XCTAssertEqual(legend.kind, .symbol(symbolName), "for \(keyCode)")
            XCTAssertEqual(legend.text, text, "for \(keyCode)")
        }
    }

    func testJapaneseInputKeysUseTheirOwnLabels() {
        for (keyCode, specialKey) in [(KeyboardKeyCode.eisu, KeyboardSpecialKey.eisu), (.kana, .kana)] {
            XCTAssertEqual(self.legend(.stub(keyCode: keyCode)).text, specialKey.displayText, "for \(keyCode)")
        }
    }
}

// MARK: - Keys Named by the Event

extension EventLegendResolverStandardKeyEventTests {
    /// macOS reuses the Help key code for Insert on many external keyboards, so
    /// these three are told apart by the event's characters, not the key code.
    func testHelpKeyCodeResolvesFromTheEventCharacters() {
        let insertCharacter = String.functionKey(NSInsertFunctionKey)
        let insert = self.legend(.stub(
            keyCode: .help,
            characters: insertCharacter,
            charactersIgnoringModifiers: insertCharacter
        ))
        XCTAssertEqual(insert.text, KeyboardSpecialKey.insert.displayText)

        let helpCharacter = String.functionKey(NSHelpFunctionKey)
        let help = self.legend(.stub(
            keyCode: .help,
            characters: helpCharacter,
            charactersIgnoringModifiers: helpCharacter
        ))
        XCTAssertEqual(help.text, "help")

        let withoutCharacters = self.legend(.stub(keyCode: .help))
        XCTAssertEqual(withoutCharacters.text, KeyboardSpecialKey.insert.displayText)
    }
}

// MARK: - Key-Code-Only Resolution

extension EventLegendResolverStandardKeyEventTests {
    /// Previews resolve without an event behind them; they must match the
    /// visualizer, which is what the settings samples rely on.
    func testKeyCodeOnlyResolutionMatchesTheEventPath() {
        for keyCode: KeyboardKeyCode in [.a, .space, .escape, .tab, .returnKey, .brightnessUp] {
            let fromEvent = self.legend(.stub(keyCode: keyCode))
            let fromKeyCode = self.resolver.legend(forKeyCode: keyCode)

            XCTAssertEqual(fromKeyCode, fromEvent, "for \(keyCode)")
        }
    }

    func testSpaceResolvesToItsSymbolRatherThanItsName() {
        let legend = self.resolver.legend(forKeyCode: .space)

        XCTAssertEqual(legend.text, UnicodeToken.visibleSpace.string)
        XCTAssertEqual(legend.kind, .text)
    }
}
