//
//  EventTransformerMouseTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import XCTest
@testable import Keyty

final class EventTransformerMouseTests: XCTestCase {
    var keyboardLayout: TISInputSource!

    func transform(_ event: MouseEvent) -> String {
        EventTransformer(keyboardLayout: keyboardLayout).transform(.mouse(event))
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.keyboardLayout = try TestKeyboardLayouts.requireUSEnglish()
    }

    // MARK: - Mouse buttons

    func test_MouseEvent_leftMouseDownIsLMB() {
        let event = TestMouseEvents.make(type: .leftMouseDown, buttonNumber: 0, modifiers: [])
        XCTAssertEqual(transform(event), "LMB")
    }

    func test_MouseEvent_rightMouseDownIsRMB() {
        let event = TestMouseEvents.make(type: .rightMouseDown, buttonNumber: 1, modifiers: [])
        XCTAssertEqual(transform(event), "RMB")
    }

    func test_MouseEvent_middleMouseDownIsMMB() {
        let event = TestMouseEvents.make(type: .otherMouseDown, buttonNumber: 2, modifiers: [])
        XCTAssertEqual(transform(event), "MMB")
    }

    func test_MouseEvent_fourthButtonIsMB4() {
        let event = TestMouseEvents.make(type: .otherMouseDown, buttonNumber: 3, modifiers: [])
        XCTAssertEqual(transform(event), "MB4")
    }

    func test_MouseEvent_fifthButtonIsMB5() {
        let event = TestMouseEvents.make(type: .otherMouseDown, buttonNumber: 4, modifiers: [])
        XCTAssertEqual(transform(event), "MB5")
    }

    func test_MouseEvent_commandLeftClickShowsCommandLMB() {
        let event = TestMouseEvents.make(type: .leftMouseDown, buttonNumber: 0, modifiers: .command)
        XCTAssertEqual(transform(event), KeyboardGlyphCatalog.command + "LMB")
    }

    func test_MouseEvent_optionShiftRightClickShowsModifiersWithRMB() {
        let event = TestMouseEvents.make(type: .rightMouseDown, buttonNumber: 1, modifiers: [.option, .shift])
        XCTAssertEqual(transform(event), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "RMB")
    }
}
