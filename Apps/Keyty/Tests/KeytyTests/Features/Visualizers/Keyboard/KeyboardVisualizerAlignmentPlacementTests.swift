//
//  KeyboardVisualizerAlignmentPlacementTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class KeyboardVisualizerAlignmentPlacementTests: XCTestCase {
    private let area = CGRect(x: 100, y: 200, width: 800, height: 600)
    private let size = CGSize(width: 120, height: 80)

    func testFrameCentersContentOnNormalizedPosition() {
        let frame = KeyboardVisualizerAlignment.center.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.25, y: 0.75),
            in: self.area
        )

        XCTAssertEqual(frame.midX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.midY, 650, accuracy: 0.0001)
    }

    func testFramePlacesLeadingEdgeOnNormalizedPosition() {
        let frame = KeyboardVisualizerAlignment.leading.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.25, y: 0.75),
            in: self.area
        )

        XCTAssertEqual(frame.minX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.midY, 650, accuracy: 0.0001)
    }

    func testFramePlacesTrailingEdgeOnNormalizedPosition() {
        let frame = KeyboardVisualizerAlignment.trailing.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.25, y: 0.75),
            in: self.area
        )

        XCTAssertEqual(frame.maxX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.midY, 650, accuracy: 0.0001)
    }

    func testFrameClampsContentInsideVisibleFrame() {
        let frame = KeyboardVisualizerAlignment.center.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0, y: 1),
            in: self.area
        )

        XCTAssertEqual(frame.minX, self.area.minX, accuracy: 0.0001)
        XCTAssertEqual(frame.maxY, self.area.maxY, accuracy: 0.0001)
    }

    func testAnchorXUsesAlignmentSpecificEdge() {
        let frame = CGRect(x: 180, y: 200, width: 120, height: 80)

        XCTAssertEqual(KeyboardVisualizerAlignment.leading.anchorX(in: frame), 180, accuracy: 0.0001)
        XCTAssertEqual(KeyboardVisualizerAlignment.center.anchorX(in: frame), 240, accuracy: 0.0001)
        XCTAssertEqual(KeyboardVisualizerAlignment.trailing.anchorX(in: frame), 300, accuracy: 0.0001)
    }

    func testOriginXResolvesAlignedEdgeOntoAnchor() {
        XCTAssertEqual(
            KeyboardVisualizerAlignment.leading.originX(for: 120, anchoredAt: 300),
            300,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            KeyboardVisualizerAlignment.center.originX(for: 120, anchoredAt: 300),
            240,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            KeyboardVisualizerAlignment.trailing.originX(for: 120, anchoredAt: 300),
            180,
            accuracy: 0.0001
        )
    }

    func testAnchoredFrameRoundTripsThroughItsOwnAnchor() {
        for alignment in KeyboardVisualizerAlignment.allCases {
            let frame = alignment.frame(
                for: self.size,
                atNormalized: CGPoint(x: 0.25, y: 0.75),
                in: self.area
            )

            XCTAssertEqual(
                self.area.normalizedPoint(for: CGPoint(x: alignment.anchorX(in: frame), y: frame.midY)).x,
                0.25,
                accuracy: 0.0001,
                "\(alignment) should place its own anchor edge back on the normalized position"
            )
        }
    }
}
