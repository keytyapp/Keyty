//
//  KeyboardVisualizerSpecialKeyFilteringTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

final class KeyboardVisualizerSpecialKeyFilteringTests: XCTestCase {
    func testClassifiesPrintableLetterAsNonSpecial() {
        XCTAssertNil(KeyboardSpecialKeyResolver.specialKey(for: KeyboardKeyCode.a.rawValue))
    }

    func testClassifiesTabAsSpecial() {
        XCTAssertEqual(KeyboardSpecialKeyResolver.specialKey(for: KeyboardKeyCode.tab.rawValue), .tab)
    }

    func testClassifiesArrowKeyAsSpecial() {
        XCTAssertEqual(KeyboardSpecialKeyResolver.specialKey(for: KeyboardKeyCode.upArrow.rawValue), .upArrow)
    }

    func testClassifiesFunctionRowKeyAsSpecial() {
        XCTAssertEqual(KeyboardSpecialKeyResolver.specialKey(for: KeyboardKeyCode.f5.rawValue), .functionRow(5))
    }

    func testClassifiesContextMenuKeyAsSystemKey() {
        XCTAssertEqual(KeyboardSpecialKeyResolver.specialKey(for: KeyboardKeyCode.contextMenu.rawValue), .system(.contextMenu))
        XCTAssertEqual(KeyboardSpecialKey.SystemKey.contextMenu.displayText, UnicodeToken.contextMenu.string)
    }

    func testResolverClassifiesInsertFunctionKeyAsSpecial() {
        let ch = TestKeyboardCharacters.functionKeyCharacter(NSInsertFunctionKey)
        let event = Self.makeKeystroke(
            keyCode: KeyboardKeyCode.help.rawValue,
            characters: ch,
            charactersIgnoringModifiers: ch
        )

        XCTAssertTrue(KeyboardSpecialKeyResolver.isSpecial(event))
    }

    func testResolverClassifiesPrintableLetterAsNonSpecial() {
        let event = Self.makeKeystroke(
            keyCode: KeyboardKeyCode.a.rawValue,
            characters: "a",
            charactersIgnoringModifiers: "a"
        )

        XCTAssertFalse(KeyboardSpecialKeyResolver.isSpecial(event))
    }

    private static func makeKeystroke(
        keyCode: UInt16,
        characters: String,
        charactersIgnoringModifiers: String
    ) -> StandardKeyEvent {
        let event = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [],
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

}
