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
        switch items[0] {
        case .content(_, let sourceEvent, _, _, _):
            XCTAssertEqual(sourceEvent.type, .leftMouseUp)
        default:
            XCTFail("Expected content item")
        }

        switch items[1] {
        case .groupBreak:
            break
        default:
            XCTFail("Expected group break item")
        }
    }

    func testMouseUpWithoutModifiersEmitsContentAndGroupBreak() {
        let processor = EventProcessor()
        var items: [DisplayItem] = []
        processor.onItemProduced = { items.append($0) }

        processor.noteMouseEvent(TestMouseEvents.make(type: .leftMouseUp, buttonNumber: 0, modifiers: []))

        XCTAssertEqual(items.count, 2)
        switch items[0] {
        case .content(_, let sourceEvent, _, _, _):
            XCTAssertEqual(sourceEvent.type, .leftMouseUp)
        default:
            XCTFail("Expected content item")
        }

        switch items[1] {
        case .groupBreak:
            break
        default:
            XCTFail("Expected group break item")
        }
    }
}
