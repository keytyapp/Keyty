//
//  EventTransformerMouseEventTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import XCTest
@testable import Keyty

final class EventTransformerMouseEventTests: XCTestCase {
    var keyboardLayout: TISInputSource!

    func transform(_ event: MouseEvent) -> String {
        EventTransformer(keyboardLayout: keyboardLayout).transform(.mouse(event))
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.keyboardLayout = try TISInputSource.usEnglish()
    }

    // MARK: - Mouse buttons

    func testLeftMouseDownIsLMB() {
        let event = MouseEvent.stub(type: .leftMouseDown, buttonNumber: 0, modifiers: [])
        XCTAssertEqual(transform(event), "LMB")
    }

    func testRightMouseDownIsRMB() {
        let event = MouseEvent.stub(type: .rightMouseDown, buttonNumber: 1, modifiers: [])
        XCTAssertEqual(transform(event), "RMB")
    }

    func testMiddleMouseDownIsMMB() {
        let event = MouseEvent.stub(type: .otherMouseDown, buttonNumber: 2, modifiers: [])
        XCTAssertEqual(transform(event), "MMB")
    }

    func testFourthButtonIsMB4() {
        let event = MouseEvent.stub(type: .otherMouseDown, buttonNumber: 3, modifiers: [])
        XCTAssertEqual(transform(event), "MB4")
    }

    func testFifthButtonIsMB5() {
        let event = MouseEvent.stub(type: .otherMouseDown, buttonNumber: 4, modifiers: [])
        XCTAssertEqual(transform(event), "MB5")
    }

    func testCommandLeftClickShowsCommandLMB() {
        let event = MouseEvent.stub(type: .leftMouseDown, buttonNumber: 0, modifiers: .command)
        XCTAssertEqual(transform(event), KeyboardGlyphCatalog.command + "LMB")
    }

    func testOptionShiftRightClickShowsModifiersWithRMB() {
        let event = MouseEvent.stub(type: .rightMouseDown, buttonNumber: 1, modifiers: [.option, .shift])
        XCTAssertEqual(transform(event), KeyboardGlyphCatalog.option + KeyboardGlyphCatalog.shift + "RMB")
    }
}
