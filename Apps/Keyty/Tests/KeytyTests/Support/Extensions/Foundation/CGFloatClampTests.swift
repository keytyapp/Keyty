//
//  CGFloatClampTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics
import XCTest
@testable import Keyty

final class CGFloatClampTests: XCTestCase {
    func testClampedToRangeKeepsValueInsideRange() {
        XCTAssertEqual(CGFloat(4).clamped(to: 1...8), 4)
    }

    func testClampedToRangeLimitsValueBelowRange() {
        XCTAssertEqual(CGFloat(-2).clamped(to: 1...8), 1)
    }

    func testClampedToRangeLimitsValueAboveRange() {
        XCTAssertEqual(CGFloat(10).clamped(to: 1...8), 8)
    }

    func testClampedMinimumMaximumReturnsMinimumWhenMaximumIsBelowMinimum() {
        XCTAssertEqual(CGFloat(4).clamped(minimum: 8, maximum: 1), 8)
    }
}
