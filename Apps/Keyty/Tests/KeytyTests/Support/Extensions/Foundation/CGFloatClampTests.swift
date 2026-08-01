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
    func test_clampedToRange_keepsValueInsideRange() {
        XCTAssertEqual(CGFloat(4).clamped(to: 1...8), 4)
    }

    func test_clampedToRange_limitsValueBelowRange() {
        XCTAssertEqual(CGFloat(-2).clamped(to: 1...8), 1)
    }

    func test_clampedToRange_limitsValueAboveRange() {
        XCTAssertEqual(CGFloat(10).clamped(to: 1...8), 8)
    }

    func test_clampedMinimumMaximum_returnsMinimumWhenMaximumIsBelowMinimum() {
        XCTAssertEqual(CGFloat(4).clamped(minimum: 8, maximum: 1), 8)
    }
}
