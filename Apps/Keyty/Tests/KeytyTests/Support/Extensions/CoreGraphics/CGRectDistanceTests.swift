//
//  CGRectDistanceTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics
import XCTest
@testable import Keyty

final class CGRectDistanceTests: XCTestCase {
    func testSquaredDistanceToPointReturnsZeroForPointInsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(rect.squaredDistance(to: CGPoint(x: 40, y: 30)), 0)
    }

    func testSquaredDistanceToPointUsesHorizontalDistanceOutsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(rect.squaredDistance(to: CGPoint(x: 4, y: 30)), 36)
    }

    func testSquaredDistanceToPointUsesVerticalDistanceOutsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(rect.squaredDistance(to: CGPoint(x: 40, y: 75)), 25)
    }

    func testSquaredDistanceToPointUsesDiagonalDistanceOutsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(rect.squaredDistance(to: CGPoint(x: 4, y: 75)), 61)
    }
}
