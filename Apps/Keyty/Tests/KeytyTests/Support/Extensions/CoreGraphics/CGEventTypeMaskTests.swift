//
//  CGEventTypeMaskTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class CGEventTypeMaskTests: XCTestCase {
    func testMaskSetsTheBitMatchingTheEventTypeRawValue() {
        XCTAssertEqual(CGEventType.keyDown.mask, 1 << CGEventMask(CGEventType.keyDown.rawValue))
        XCTAssertEqual(CGEventType.scrollWheel.mask, 1 << CGEventMask(CGEventType.scrollWheel.rawValue))
    }

    func testMaskSetsExactlyOneBit() {
        for type in [CGEventType.keyDown, .keyUp, .flagsChanged, .systemDefined, .scrollWheel] {
            XCTAssertEqual(type.mask.nonzeroBitCount, 1)
        }
    }

    func testEventMaskCombinesEveryEventType() {
        let mask = [CGEventType.keyDown, .keyUp].eventMask

        XCTAssertEqual(mask, CGEventType.keyDown.mask | CGEventType.keyUp.mask)
        XCTAssertNotEqual(mask & CGEventType.keyDown.mask, 0)
        XCTAssertNotEqual(mask & CGEventType.keyUp.mask, 0)
        XCTAssertEqual(mask & CGEventType.flagsChanged.mask, 0)
    }

    func testEventMaskOfEmptySequenceIsZero() {
        XCTAssertEqual([CGEventType]().eventMask, 0)
    }

    func testEventMaskIgnoresRepeatedEventTypes() {
        XCTAssertEqual([CGEventType.keyDown, .keyDown].eventMask, CGEventType.keyDown.mask)
    }

    func testEventMaskCoversSystemDefinedWhoseRawValueIsNotAStandardCase() {
        let mask = [CGEventType.systemDefined].eventMask

        XCTAssertEqual(mask, 1 << CGEventMask(NX_SYSDEFINED))
    }
}
