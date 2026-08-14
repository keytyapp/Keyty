//
//  CGRectNormalizedPointTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics
import XCTest
@testable import Keyty

final class CGRectNormalizedPointTests: XCTestCase {
    func testNormalizedPointReturnsPointRelativeToRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
        let point = rect.normalizedPoint(for: CGPoint(x: 35, y: 45))

        XCTAssertEqual(point.x, 0.25, accuracy: 0.0001)
        XCTAssertEqual(point.y, 0.5, accuracy: 0.0001)
    }

    func testNormalizedPointClampsPointBelowRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
        let point = rect.normalizedPoint(for: CGPoint(x: 0, y: 10))

        XCTAssertEqual(point.x, 0, accuracy: 0.0001)
        XCTAssertEqual(point.y, 0, accuracy: 0.0001)
    }

    func testNormalizedPointClampsPointAboveRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
        let point = rect.normalizedPoint(for: CGPoint(x: 120, y: 80))

        XCTAssertEqual(point.x, 1, accuracy: 0.0001)
        XCTAssertEqual(point.y, 1, accuracy: 0.0001)
    }

    func testNormalizedPointUsesOneForEmptyDimensions() {
        let rect = CGRect(x: 10, y: 20, width: 0, height: 0)
        let point = rect.normalizedPoint(for: CGPoint(x: 10.5, y: 20.25))

        XCTAssertEqual(point.x, 0.5, accuracy: 0.0001)
        XCTAssertEqual(point.y, 0.25, accuracy: 0.0001)
    }

    func testPointForNormalizedReturnsPointInsideRect() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
        let point = rect.point(forNormalized: CGPoint(x: 0.25, y: 0.5))

        XCTAssertEqual(point.x, 35, accuracy: 0.0001)
        XCTAssertEqual(point.y, 45, accuracy: 0.0001)
    }

    func testPointForNormalizedInvertsNormalizedPoint() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
        let original = CGPoint(x: 35, y: 45)
        let point = rect.point(forNormalized: rect.normalizedPoint(for: original))

        XCTAssertEqual(point.x, original.x, accuracy: 0.0001)
        XCTAssertEqual(point.y, original.y, accuracy: 0.0001)
    }
}
