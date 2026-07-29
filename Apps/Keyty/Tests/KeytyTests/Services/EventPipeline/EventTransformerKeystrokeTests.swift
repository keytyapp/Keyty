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
        EventTransformer(keyboardLayout: keyboardLayout).transform(.keystroke(event))
    }

    func makeKeystroke(keyCode: UInt16, modifiers: NSEvent.ModifierFlags,
                       characters: String, charactersIgnoringModifiers: String) -> StandardKeyEvent {
        let event = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: modifiers,
            timestamp: NSDate.timeIntervalSinceReferenceDate,
            windowNumber: 0,
            context: nil,
            characters: characters,
            charactersIgnoringModifiers: charactersIgnoringModifiers,
            isARepeat: false,
            keyCode: keyCode
        )!
        return StandardKeyEvent(nsEvent: event)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        keyboardLayout = try TestKeyboardLayouts.requireUSEnglish()
    }

    // MARK: - Numbers

    func test_KCKeystroke_convertsCtrlNumberToNumber() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.control, characters: "7", charactersIgnoringModifiers: "7")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.control + "7")
    }

    func test_KCKeystroke_convertsShiftNumberToShiftNumber() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.shift, characters: "&", charactersIgnoringModifiers: "&")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.shift + "7")
    }

    func test_KCKeystroke_convertsCtrlShiftNumberToNumber() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.controlShift, characters: "7", charactersIgnoringModifiers: "&")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + "7")
    }

    func test_KCKeystroke_convertsCmdNumberToNumber() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.command, characters: "7", charactersIgnoringModifiers: "7")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.command + "7")
    }

    func test_KCKeystroke_convertsCmdShiftNumberToNumber() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandShift, characters: "7", charactersIgnoringModifiers: "&")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "7")
    }

    func test_KCKeystroke_convertsCmdOptNumberToNumber() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandOption, characters: "¶", charactersIgnoringModifiers: "7")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.command + "7")
    }

    func test_KCKeystroke_convertsShiftOptionNumberToNumber() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.optionShift, characters: "»", charactersIgnoringModifiers: "7")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "7")
    }

    func test_KCKeystroke_convertsCmdOptShiftNumberToShiftedNumber() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.commandOptionShift, characters: "‡", charactersIgnoringModifiers: "&")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "7")
    }

    // MARK: - Letters

    func test_KCKeystroke_convertsCtrlLetterToUppercaseLetter() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.control, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.control + "A")
    }

    func test_KCKeystroke_convertsCtrlShiftLetterToLetter() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlShift, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + "A")
    }

    func test_KCKeystroke_convertsCtrlShiftCmdLetterToLetter() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlCommandShift, characters: "^A", charactersIgnoringModifiers: "A")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.shift + KeyboardGlyphCatalog.command + "A")
    }

    func test_KCKeystroke_convertsCtrlOptLetterToUppercaseLetter() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlOption, characters: "^A", charactersIgnoringModifiers: "a")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.option + "A")
    }

    func test_KCKeystroke_convertsCtrlOptShiftLetterToLetter() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.a.rawValue, modifiers: TestModifierFlags.controlOptionShift, characters: "^A", charactersIgnoringModifiers: "A")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.control + KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "A")
    }

    func test_KCKeystroke_displaysOptLetterByDefault() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.u.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "u")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.option + "U")
    }

    // MARK: - Function Row

    func test_KCKeystroke_convertsFnF1ToBrightnessDecrease() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.brightnessDown.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(transform(keystroke), UnicodeToken.brightnessDown.string)
    }

    func test_KCKeystroke_convertsFnF2ToBrightnessIncrease() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.brightnessUp.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(transform(keystroke), UnicodeToken.brightnessUp.string)
    }

    func test_KCKeystroke_convertsFnF3ToMissionControl() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.missionControl.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(transform(keystroke), UnicodeToken.missionControl.string)
    }

    func test_KCKeystroke_convertsFnF4ToLauncher() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.launchpad.rawValue, modifiers: TestModifierFlags.function, characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(transform(keystroke), UnicodeToken.launchpad.string)
    }

    // MARK: - JIS layout

    func test_KCKeystroke_convertsEisuKey() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.eisu.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(transform(keystroke), "英数")
    }

    func test_KCKeystroke_convertsKanaKey() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.kana.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(transform(keystroke), "かな")
    }

    // MARK: - Option-modified characters

    func test_optionShiftNumberDisplaysExplicitModifiers() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.digit7.rawValue, modifiers: TestModifierFlags.optionShift, characters: "»", charactersIgnoringModifiers: "7")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "7")
    }

    // MARK: - Special Cases

    func test_tabKey() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.tab.rawValue, modifiers: TestModifierFlags.none, characters: "\t", charactersIgnoringModifiers: "\t")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.tab)
    }

    func test_returnAndKeypadEnterUseDifferentSymbols() {
        keystroke = makeKeystroke(
            keyCode: KeyboardKeyCode.returnKey.rawValue,
            modifiers: TestModifierFlags.none,
            characters: "\r",
            charactersIgnoringModifiers: "\r"
        )
        XCTAssertEqual(transform(keystroke), UnicodeToken.returnKey.string)

        keystroke = makeKeystroke(
            keyCode: KeyboardKeyCode.keypadEnter.rawValue,
            modifiers: TestModifierFlags.none,
            characters: "\r",
            charactersIgnoringModifiers: "\r"
        )
        XCTAssertEqual(transform(keystroke), UnicodeToken.keypadEnter.string)
    }

    func test_deleteAndForwardDeleteUseDifferentSymbols() {
        keystroke = makeKeystroke(
            keyCode: KeyboardKeyCode.delete.rawValue,
            modifiers: TestModifierFlags.none,
            characters: UnicodeToken.delete.string,
            charactersIgnoringModifiers: UnicodeToken.delete.string
        )
        XCTAssertEqual(transform(keystroke), UnicodeToken.delete.string)

        keystroke = makeKeystroke(
            keyCode: KeyboardKeyCode.forwardDelete.rawValue,
            modifiers: TestModifierFlags.none,
            characters: UnicodeToken.forwardDelete.string,
            charactersIgnoringModifiers: UnicodeToken.forwardDelete.string
        )
        XCTAssertEqual(transform(keystroke), UnicodeToken.forwardDelete.string)
    }

    func test_shiftTab() {
        let ch = String(UnicodeScalar(0x19)!)
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.tab.rawValue, modifiers: TestModifierFlags.shift, characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.backTab)
    }

    func test_arrowKeysUseFilledTriangleSymbols() {
        let cases: [(KeyboardKeyCode, String)] = [
            (.leftArrow, UnicodeToken.leftArrow.string),
            (.upArrow, UnicodeToken.upArrow.string),
            (.downArrow, UnicodeToken.downArrow.string),
            (.rightArrow, UnicodeToken.rightArrow.string)
        ]

        for (keyCode, expected) in cases {
            keystroke = makeKeystroke(
                keyCode: keyCode.rawValue,
                modifiers: TestModifierFlags.none,
                characters: expected,
                charactersIgnoringModifiers: expected
            )
            XCTAssertEqual(transform(keystroke), expected)
        }
    }

    func test_insertFunctionKeyDisplaysInsertForHelpKeyCode() {
        let ch = Self.appKitFunctionKey(NSInsertFunctionKey)
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(transform(keystroke), "ins")
    }

    func test_helpFunctionKeyDisplaysHelpForHelpKeyCode() {
        let ch = Self.appKitFunctionKey(NSHelpFunctionKey)
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: ch, charactersIgnoringModifiers: ch)
        XCTAssertEqual(transform(keystroke), UnicodeToken.questionMark.string + UnicodeToken.enclosingCircle.string)
    }

    func test_helpKeyCodeWithoutSemanticCharactersDefaultsToInsert() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.help.rawValue, modifiers: [], characters: "", charactersIgnoringModifiers: "")
        XCTAssertEqual(transform(keystroke), "ins")
    }

    // MARK: - US English - Special Cases with Modifiers

    func test_optionShiftUp() {
        let ch = Self.appKitFunctionKey(NSUpArrowFunctionKey)
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.upArrow.rawValue, modifiers: TestModifierFlags.functionOptionShiftNumericPad, characters: ch, charactersIgnoringModifiers: ch)

        XCTAssertEqual(
            transform(keystroke),
            KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + UnicodeToken.upArrow.string
        )
    }

    func test_optionUSpecialCase() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.u.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "u")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.option + "U")
    }

    func test_optionESpecialCase() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.e.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "e")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.option + "E")
    }

    func test_optionBacktickSpecialCase() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.grave.rawValue, modifiers: TestModifierFlags.option, characters: "", charactersIgnoringModifiers: "`")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.option + "`")
    }

    // MARK: - German - Special Case

    func test_commandßDisplaysCommandß() {
        keystroke = makeKeystroke(keyCode: KeyboardKeyCode.minus.rawValue, modifiers: TestModifierFlags.command, characters: "ß", charactersIgnoringModifiers: "ß")
        XCTAssertEqual(transform(keystroke), KeyboardGlyphCatalog.command + "ß")
    }

    private static func appKitFunctionKey(_ key: Int) -> String {
        String(UnicodeScalar(key)!)
    }
}
