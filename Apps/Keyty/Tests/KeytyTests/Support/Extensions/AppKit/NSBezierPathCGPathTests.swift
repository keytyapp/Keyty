//
//  NSBezierPathCGPathTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics
import XCTest
@testable import Keyty

final class NSBezierPathCGPathTests: XCTestCase {
    func testCGPathEmptyPathProducesEmptyCGPath() {
        let path = NSBezierPath()

        XCTAssertTrue(path.cgPath.isEmpty)
        XCTAssertEqual(path.cgPath.pathElements.map(\.type), [])
    }

    func testCGPathLinePathPreservesElementTypes() {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 10, y: 10))
        path.line(to: NSPoint(x: 30, y: 10))
        path.line(to: NSPoint(x: 30, y: 40))
        path.close()

        let elementTypes = path.cgPath.pathElements.map(\.type.rawValue)

        XCTAssertEqual(
            Array(elementTypes.prefix(4)),
            [
                CGPathElementType.moveToPoint.rawValue,
                CGPathElementType.addLineToPoint.rawValue,
                CGPathElementType.addLineToPoint.rawValue,
                CGPathElementType.closeSubpath.rawValue,
            ]
        )
    }

    func testCGPathCurvePathPreservesCurveElement() {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0, y: 0))
        path.curve(
            to: NSPoint(x: 30, y: 15),
            controlPoint1: NSPoint(x: 10, y: 25),
            controlPoint2: NSPoint(x: 20, y: -10)
        )

        let elements = path.cgPath.pathElements
        XCTAssertEqual(
            elements.map(\.type.rawValue),
            [
                CGPathElementType.moveToPoint.rawValue,
                CGPathElementType.addCurveToPoint.rawValue,
            ]
        )
        XCTAssertEqual(elements[1].points.count, 3)
    }

    func testCGPathBoundingBoxMatchesBezierPathBounds() {
        let path = NSBezierPath(
            roundedRect: NSRect(x: 12, y: 18, width: 44, height: 28),
            xRadius: 14,
            yRadius: 14
        )

        XCTAssertEqual(path.cgPath.boundingBox.minX, path.bounds.minX, accuracy: 0.001)
        XCTAssertEqual(path.cgPath.boundingBox.minY, path.bounds.minY, accuracy: 0.001)
        XCTAssertEqual(path.cgPath.boundingBox.width, path.bounds.width, accuracy: 0.001)
        XCTAssertEqual(path.cgPath.boundingBox.height, path.bounds.height, accuracy: 0.001)
    }
}
