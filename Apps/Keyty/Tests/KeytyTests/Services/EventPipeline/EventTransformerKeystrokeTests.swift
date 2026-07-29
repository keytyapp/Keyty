//
//  EventTransformerKeystrokeTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

// NOTE: These tests assume a US-English layout and may break under other locales.
// The correct modifier ordering is Control-Option-Shift-Command (as shown in Apple menus).

import Carbon
import XCTest
@testable import Keyty

final class EventTransformerKeystrokeTests: XCTestCase {
    var keystroke: StandardKeyEvent!
    var keyboardLayout: TISInputSource!

    func transform(_ event: StandardKeyEvent) -> String {
        EventTransformer(keyboardLayout: self.keyboardLayout).transform(.keystroke(event))
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.keyboardLayout = try TestKeyboardLayouts.requireUSEnglish()
    }
}

// MARK: - Numbers

extension EventTransformerKeystrokeTests {
    func test_KCKeystroke_convertsCtrlNumberToNumber() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.control, characters: "7", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.control + "7")
    }

    func test_KCKeystroke_convertsShiftNumberToShiftNumber() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.shift, characters: "&", charactersIgnoringModifiers: "&")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.shift + "7")
    }

    func test_KCKeystroke_convertsCtrlShiftNumberToNumber() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.controlShift, characters: "7", charactersIgnoringModifiers: "&")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + "7")
    }

    func test_KCKeystroke_convertsCmdNumberToNumber() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.command, characters: "7", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.command + "7")
    }

    func test_KCKeystroke_convertsCmdShiftNumberToNumber() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandShift, characters: "7", charactersIgnoringModifiers: "&")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "7")
    }

    func test_KCKeystroke_convertsCmdOptNumberToNumber() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandOption, characters: "¶", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.command + "7")
    }

    func test_KCKeystroke_convertsShiftOptionNumberToNumber() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.optionShift, characters: "»", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "7")
    }

    func test_KCKeystroke_convertsCmdOptShiftNumberToShiftedNumber() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandOptionShift, characters: "‡", charactersIgnoringModifiers: "&")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "7")
    }
}

// MARK: - Letters

extension EventTransformerKeystrokeTests {
    func test_KCKeystroke_convertsCtrlLetterToUppercaseLetter() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.control, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.control + "A")
    }

    func test_KCKeystroke_convertsCtrlShiftLetterToLetter() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlShift, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + "A")
    }

    func test_KCKeystroke_convertsCtrlShiftCmdLetterToLetter() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlCommandShift, characters: "^A", charactersIgnoringModifiers: "A")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "A")
    }

    func test_KCKeystroke_convertsCtrlOptLetterToUppercaseLetter() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlOption, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.option + "A")
    }

    func test_KCKeystroke_convertsCtrlOptShiftLetterToLetter() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlOptionShift, characters: "^A", charactersIgnoringModifiers: "A")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "A")
    }

    func test_KCKeystroke_displaysOptLetterByDefault() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.u.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "u")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.option + "U")
    }
}

// MARK: - Function Row
extension EventTransformerKeystrokeTests {
    func test_KCKeystroke_convertsFnF1ToBrightnessDecrease() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.brightnessDown.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.brightnessDown.string)
    }

    func test_KCKeystroke_convertsFnF2ToBrightnessIncrease() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.brightnessUp.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.brightnessUp.string)
    }

    func test_KCKeystroke_convertsFnF3ToMissionControl() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.missionControl.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.missionControl.string)
    }

    func test_KCKeystroke_convertsFnF4ToLauncher() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.launchpad.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.launchpad.string)
    }
}

// MARK: - JIS layout
extension EventTransformerKeystrokeTests {
    func test_KCKeystroke_convertsEisuKey() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.eisu.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardSpecialKey.eisu.displayText)
    }

    func test_KCKeystroke_convertsKanaKey() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.kana.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardSpecialKey.kana.displayText)
    }
}

// MARK: - Option-modified characters

extension EventTransformerKeystrokeTests {
    func test_optionShiftNumberDisplaysExplicitModifiers() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.optionShift, characters: "»", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "7")
    }
}

// MARK: - Special Cases

extension EventTransformerKeystrokeTests {
    func test_tabKey() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.tab.rawValue, modifiers: TestModifierFlags.none, characters: "\t", charactersIgnoringModifiers: "\t")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.tab)
    }

    func test_returnAndKeypadEnterUseDifferentSymbols() {
        self.keystroke = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.returnKey.rawValue,
            modifiers: TestModifierFlags.none,
            characters: "\r",
            charactersIgnoringModifiers: "\r"
        )
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.returnKey.string)

        self.keystroke = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.keypadEnter.rawValue,
            modifiers: TestModifierFlags.none,
            characters: "\r",
            charactersIgnoringModifiers: "\r"
        )
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.keypadEnter.string)
    }

    func test_deleteAndForwardDeleteUseDifferentSymbols() {
        self.keystroke = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.delete.rawValue,
            modifiers: TestModifierFlags.none,
            characters: UnicodeToken.delete.string,
            charactersIgnoringModifiers: UnicodeToken.delete.string
        )
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.delete.string)

        self.keystroke = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.forwardDelete.rawValue,
            modifiers: TestModifierFlags.none,
            characters: UnicodeToken.forwardDelete.string,
            charactersIgnoringModifiers: UnicodeToken.forwardDelete.string
        )
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.forwardDelete.string)
    }

    func test_shiftTab() {
        let ch = TestKeyboardCharacters.backTab
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.tab.rawValue, modifiers: TestModifierFlags.shift, characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.backTab)
    }

    func test_arrowKeysUseFilledTriangleSymbols() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.leftArrow, UnicodeToken.leftArrow.string),
            (.upArrow, UnicodeToken.upArrow.string),
            (.downArrow, UnicodeToken.downArrow.string),
            (.rightArrow, UnicodeToken.rightArrow.string)
        ]

        for (keyCode, expected) in cases {
            self.keystroke = TestKeystrokes.make(
                keyCode: keyCode.rawValue,
                modifiers: TestModifierFlags.none,
                characters: expected,
                charactersIgnoringModifiers: expected
            )
            XCTAssertEqual(self.transform(self.keystroke), expected)
        }
    }

    func test_insertFunctionKeyDisplaysInsertForHelpKeyCode() {
        let ch = TestKeyboardCharacters.functionKeyCharacter(NSInsertFunctionKey)
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(self.transform(self.keystroke), "ins")
    }

    func test_helpFunctionKeyDisplaysHelpForHelpKeyCode() {
        let ch = TestKeyboardCharacters.functionKeyCharacter(NSHelpFunctionKey)
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(self.transform(self.keystroke), UnicodeToken.questionMark.string + UnicodeToken.enclosingCircle.string)
    }

    func test_helpKeyCodeWithoutSemanticCharactersDefaultsToInsert() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(self.keystroke), "ins")
    }
}

// MARK: - US English - Special Cases with Modifiers

extension EventTransformerKeystrokeTests {
    func test_optionShiftUp() {
        let ch = TestKeyboardCharacters.functionKeyCharacter(NSUpArrowFunctionKey)
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.upArrow.rawValue, modifiers: TestModifierFlags.functionOptionShiftNumericPad, characters: ch, charactersIgnoringModifiers: ch)

        XCTAssertEqual(
            self.transform(self.keystroke),
            KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + UnicodeToken.upArrow.string
        )
    }

    func test_optionUSpecialCase() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.u.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "u")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.option + "U")
    }

    func test_optionESpecialCase() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.e.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "e")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.option + "E")
    }

    func test_optionBacktickSpecialCase() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.grave.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "`")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.option + "`")
    }
}

// MARK: - German - Special Case

extension EventTransformerKeystrokeTests {
    func test_commandßDisplaysCommandß() {
        self.keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.minus.rawValue, modifiers: TestModifierFlags.command, characters: "ß", charactersIgnoringModifiers: "ß")
        XCTAssertEqual(self.transform(self.keystroke), KeyboardGlyphCatalog.command + "ß")
    }

}
