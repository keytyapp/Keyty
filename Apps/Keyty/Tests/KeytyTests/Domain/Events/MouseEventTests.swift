//
//  MouseEventTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class MouseEventTests: XCTestCase {
    func testCGBackedMouseEventUsesNSEventLocationForScreenLocation() {
        let cgEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: CGPoint(x: 120, y: 80),
            mouseButton: .left
        )!
        let nsEvent = NSEvent(cgEvent: cgEvent)!

        let event = MouseEvent(nsEvent: nsEvent, cgEvent: cgEvent)

        XCTAssertEqual(event.screenLocation, nsEvent.locationInWindow)
    }
}
