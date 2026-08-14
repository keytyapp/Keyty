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
        XCTAssertEqual(KeyboardSpecialKey.SystemKey.contextMenu.displayText, "menu")
    }

    func testResolverClassifiesInsertFunctionKeyAsSpecial() {
        let ch = String.functionKey(NSInsertFunctionKey)
        let event = StandardKeyEvent.stub(
            keyCode: .help,
            characters: ch,
            charactersIgnoringModifiers: ch
        )

        XCTAssertTrue(KeyboardSpecialKeyResolver.isSpecial(event))
    }

    func testResolverClassifiesPrintableLetterAsNonSpecial() {
        let event = StandardKeyEvent.stub(
            keyCode: .a,
            characters: "a",
            charactersIgnoringModifiers: "a"
        )

        XCTAssertFalse(KeyboardSpecialKeyResolver.isSpecial(event))
    }

}
