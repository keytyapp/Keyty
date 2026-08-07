//
//  KeyboardModifierKeyKindTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

final class KeyboardModifierKeyKindTests: XCTestCase {
    func testCanonicalDisplayOrderMatchesAppleMenuOrder() {
        XCTAssertEqual(
            KeyboardModifierKey.Kind.canonicalDisplayOrder,
            [.control, .option, .shift, .command]
        )
    }

    func testFlagMapsKindToAggregateModifierFlag() {
        XCTAssertEqual(KeyboardModifierKey.Kind.command.flag, .command)
        XCTAssertEqual(KeyboardModifierKey.Kind.shift.flag, .shift)
        XCTAssertEqual(KeyboardModifierKey.Kind.option.flag, .option)
        XCTAssertEqual(KeyboardModifierKey.Kind.control.flag, .control)
    }
}
