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

// MARK: - Numbers

extension EventTransformerKeystrokeTests {
    func test_convertsCtrlNumberToNumber() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.control, characters: "7", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.control + "7")
    }

    func test_convertsShiftNumberToShiftNumber() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.shift, characters: "&", charactersIgnoringModifiers: "&")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.shift + "7")
    }

    func test_convertsCtrlShiftNumberToNumber() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.controlShift, characters: "7", charactersIgnoringModifiers: "&")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + "7")
    }

    func test_convertsCmdNumberToNumber() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.command, characters: "7", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.command + "7")
    }

    func test_convertsCmdShiftNumberToNumber() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandShift, characters: "7", charactersIgnoringModifiers: "&")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "7")
    }

    func test_convertsCmdOptNumberToNumber() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandOption, characters: "¶", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.command + "7")
    }

    func test_convertsShiftOptionNumberToNumber() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.optionShift, characters: "»", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "7")
    }

    func test_convertsCmdOptShiftNumberToShiftedNumber() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandOptionShift, characters: "‡", charactersIgnoringModifiers: "&")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "7")
    }
}

// MARK: - Letters

extension EventTransformerKeystrokeTests {
    func test_convertsCtrlLetterToUppercaseLetter() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.control, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.control + "A")
    }

    func test_convertsCtrlShiftLetterToLetter() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlShift, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + "A")
    }

    func test_convertsCtrlShiftCmdLetterToLetter() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlCommandShift, characters: "^A", charactersIgnoringModifiers: "A")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "A")
    }

    func test_convertsCtrlOptLetterToUppercaseLetter() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlOption, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.option + "A")
    }

    func test_convertsCtrlOptShiftLetterToLetter() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlOptionShift, characters: "^A", charactersIgnoringModifiers: "A")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "A")
    }

    func test_displaysOptLetterByDefault() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.u.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "u")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.option + "U")
    }
}

// MARK: - Function Row
extension EventTransformerKeystrokeTests {
    func test_convertsFnF1ToBrightnessDecrease() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.brightnessDown.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(keystroke), UnicodeToken.brightnessDown.string)
    }

    func test_convertsFnF2ToBrightnessIncrease() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.brightnessUp.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(keystroke), UnicodeToken.brightnessUp.string)
    }

    func test_convertsFnF3ToMissionControl() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.missionControl.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(keystroke), UnicodeToken.missionControl.string)
    }

    func test_convertsFnF4ToLauncher() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.launchpad.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(keystroke), UnicodeToken.launchpad.string)
    }
}

// MARK: - JIS layout
extension EventTransformerKeystrokeTests {
    func test_convertsEisuKey() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.eisu.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(keystroke), KeyboardSpecialKey.eisu.displayText)
    }

    func test_convertsKanaKey() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.kana.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(keystroke), KeyboardSpecialKey.kana.displayText)
    }
}

// MARK: - Option-modified characters

extension EventTransformerKeystrokeTests {
    func test_optionShiftNumberDisplaysExplicitModifiers() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.optionShift, characters: "»", charactersIgnoringModifiers: "7")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "7")
    }
}

// MARK: - Special Cases

extension EventTransformerKeystrokeTests {
    func test_tabKey() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.tab.rawValue, modifiers: TestModifierFlags.none, characters: "\t", charactersIgnoringModifiers: "\t")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.tab)
    }

    func test_returnAndKeypadEnterUseDifferentSymbols() {
        let returnKey = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.returnKey.rawValue,
            modifiers: TestModifierFlags.none,
            characters: "\r",
            charactersIgnoringModifiers: "\r"
        )
        XCTAssertEqual(self.transform(returnKey), UnicodeToken.returnKey.string)

        let keypadEnter = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.keypadEnter.rawValue,
            modifiers: TestModifierFlags.none,
            characters: "\r",
            charactersIgnoringModifiers: "\r"
        )
        XCTAssertEqual(self.transform(keypadEnter), UnicodeToken.keypadEnter.string)
    }

    func test_deleteAndForwardDeleteUseDifferentSymbols() {
        let deleteKey = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.delete.rawValue,
            modifiers: TestModifierFlags.none,
            characters: UnicodeToken.delete.string,
            charactersIgnoringModifiers: UnicodeToken.delete.string
        )
        XCTAssertEqual(self.transform(deleteKey), UnicodeToken.delete.string)

        let forwardDelete = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.forwardDelete.rawValue,
            modifiers: TestModifierFlags.none,
            characters: UnicodeToken.forwardDelete.string,
            charactersIgnoringModifiers: UnicodeToken.forwardDelete.string
        )
        XCTAssertEqual(self.transform(forwardDelete), UnicodeToken.forwardDelete.string)
    }

    func test_shiftTab() {
        let ch = TestKeyboardCharacters.backTab
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.tab.rawValue, modifiers: TestModifierFlags.shift, characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.backTab)
    }

    func test_arrowKeysUseFilledTriangleSymbols() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.leftArrow, UnicodeToken.leftArrow.string),
            (.upArrow, UnicodeToken.upArrow.string),
            (.downArrow, UnicodeToken.downArrow.string),
            (.rightArrow, UnicodeToken.rightArrow.string)
        ]

        for (keyCode, expected) in cases {
            let keystroke = TestKeystrokes.make(
                keyCode: keyCode.rawValue,
                modifiers: TestModifierFlags.none,
                characters: expected,
                charactersIgnoringModifiers: expected
            )
            XCTAssertEqual(self.transform(keystroke), expected)
        }
    }

    func test_insertFunctionKeyDisplaysInsertForHelpKeyCode() {
        let ch = TestKeyboardCharacters.functionKeyCharacter(NSInsertFunctionKey)
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(self.transform(keystroke), KeyboardSpecialKey.insert.displayText)
    }

    func test_helpFunctionKeyDisplaysHelpForHelpKeyCode() {
        let ch = TestKeyboardCharacters.functionKeyCharacter(NSHelpFunctionKey)
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(self.transform(keystroke), UnicodeToken.questionMark.string + UnicodeToken.enclosingCircle.string)
    }

    func test_helpKeyCodeWithoutSemanticCharactersDefaultsToInsert() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(self.transform(keystroke), KeyboardSpecialKey.insert.displayText)
    }
}

// MARK: - US English - Special Cases with Modifiers

extension EventTransformerKeystrokeTests {
    func test_optionShiftUp() {
        let ch = TestKeyboardCharacters.functionKeyCharacter(NSUpArrowFunctionKey)
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.upArrow.rawValue, modifiers: TestModifierFlags.functionOptionShiftNumericPad, characters: ch, charactersIgnoringModifiers: ch)

        XCTAssertEqual(
            self.transform(keystroke),
            KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + UnicodeToken.upArrow.string
        )
    }

    func test_optionUSpecialCase() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.u.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "u")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.option + "U")
    }

    func test_optionESpecialCase() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.e.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "e")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.option + "E")
    }

    func test_optionBacktickSpecialCase() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.grave.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "`")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.option + "`")
    }
}

// MARK: - German - Special Case

extension EventTransformerKeystrokeTests {
    func test_commandßDisplaysCommandß() {
        let keystroke = TestKeystrokes.make(keyCode: KeyboardKeyCode.minus.rawValue, modifiers: TestModifierFlags.command, characters: "ß", charactersIgnoringModifiers: "ß")
        XCTAssertEqual(self.transform(keystroke), KeyboardGlyphCatalog.command + "ß")
    }
}
