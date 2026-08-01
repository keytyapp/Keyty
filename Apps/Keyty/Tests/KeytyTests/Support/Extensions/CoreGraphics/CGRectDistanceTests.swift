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
    func test_squaredDistanceToPoint_returnsZeroForPointInsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(rect.squaredDistance(to: CGPoint(x: 40, y: 30)), 0)
    }

    func test_squaredDistanceToPoint_usesHorizontalDistanceOutsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(rect.squaredDistance(to: CGPoint(x: 4, y: 30)), 36)
    }

    func test_squaredDistanceToPoint_usesVerticalDistanceOutsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(rect.squaredDistance(to: CGPoint(x: 40, y: 75)), 25)
    }

    func test_squaredDistanceToPoint_usesDiagonalDistanceOutsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(rect.squaredDistance(to: CGPoint(x: 4, y: 75)), 61)
    }
}
