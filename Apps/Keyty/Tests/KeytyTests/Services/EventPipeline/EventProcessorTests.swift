//
//  EventProcessorTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class EventProcessorTests: XCTestCase {
    func testMouseUpEmitsContentAndGroupBreakWhenModifierIsHeld() {
        let processor = EventProcessor()
        var items: [DisplayItem] = []
        processor.onItemProduced = { items.append($0) }

        processor.noteMouseEvent(TestMouseEvents.make(type: .leftMouseUp, buttonNumber: 0, modifiers: [.command]))

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].kind, .content)
        XCTAssertEqual(items[0].sourceEvent?.type, .leftMouseUp)
        XCTAssertEqual(items[1].kind, .groupBreak)
    }

    func testMouseUpWithoutModifiersEmitsContentAndGroupBreak() {
        let processor = EventProcessor()
        var items: [DisplayItem] = []
        processor.onItemProduced = { items.append($0) }

        processor.noteMouseEvent(TestMouseEvents.make(type: .leftMouseUp, buttonNumber: 0, modifiers: []))

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].kind, .content)
        XCTAssertEqual(items[0].sourceEvent?.type, .leftMouseUp)
        XCTAssertEqual(items[1].kind, .groupBreak)
    }

}
