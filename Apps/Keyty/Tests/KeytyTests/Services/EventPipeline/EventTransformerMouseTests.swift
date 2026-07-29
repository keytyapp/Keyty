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

    func makeMouseEvent(type: NSEvent.EventType, buttonNumber: Int,
                        modifiers: NSEvent.ModifierFlags) -> MouseEvent {
        let cgType: CGEventType = {
            switch type {
            case .leftMouseDown: return .leftMouseDown
            case .rightMouseDown: return .rightMouseDown
            default: return .otherMouseDown
            }
        }()
        var cgFlags: CGEventFlags = []
        if modifiers.contains(.shift)   { cgFlags.insert(.maskShift) }
        if modifiers.contains(.command) { cgFlags.insert(.maskCommand) }
        if modifiers.contains(.control) { cgFlags.insert(.maskControl) }
        if modifiers.contains(.option)  { cgFlags.insert(.maskAlternate) }
        let cgEvent = CGEvent(mouseEventSource: nil, mouseType: cgType,
                              mouseCursorPosition: .zero, mouseButton: .left)!
        cgEvent.setIntegerValueField(.mouseEventButtonNumber, value: Int64(buttonNumber))
        cgEvent.flags = cgFlags
        return MouseEvent(nsEvent: NSEvent(cgEvent: cgEvent)!)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        keyboardLayout = try TestKeyboardLayouts.requireUSEnglish()
    }

    // MARK: - Mouse buttons

    func test_MouseEvent_leftMouseDownIsLMB() {
        let event = makeMouseEvent(type: .leftMouseDown, buttonNumber: 0, modifiers: [])
        XCTAssertEqual(transform(event), "LMB")
    }

    func test_MouseEvent_rightMouseDownIsRMB() {
        let event = makeMouseEvent(type: .rightMouseDown, buttonNumber: 1, modifiers: [])
        XCTAssertEqual(transform(event), "RMB")
    }

    func test_MouseEvent_middleMouseDownIsMMB() {
        let event = makeMouseEvent(type: .otherMouseDown, buttonNumber: 2, modifiers: [])
        XCTAssertEqual(transform(event), "MMB")
    }

    func test_MouseEvent_fourthButtonIsMB4() {
        let event = makeMouseEvent(type: .otherMouseDown, buttonNumber: 3, modifiers: [])
        XCTAssertEqual(transform(event), "MB4")
    }

    func test_MouseEvent_fifthButtonIsMB5() {
        let event = makeMouseEvent(type: .otherMouseDown, buttonNumber: 4, modifiers: [])
        XCTAssertEqual(transform(event), "MB5")
    }

    func test_MouseEvent_commandLeftClickShowsCommandLMB() {
        let event = makeMouseEvent(type: .leftMouseDown, buttonNumber: 0, modifiers: .command)
        XCTAssertEqual(transform(event), "⌘LMB")
    }

    func test_MouseEvent_optionShiftRightClickShowsModifiersWithRMB() {
        let event = makeMouseEvent(type: .rightMouseDown, buttonNumber: 1, modifiers: [.option, .shift])
        XCTAssertEqual(transform(event), "⌥⇧RMB")
    }
}
