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
        let frame = KeyboardVisualizerAlignment.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.25, y: 0.75),
            in: self.area,
            horizontal: .center,
            vertical: .center
        )

        XCTAssertEqual(frame.midX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.midY, 650, accuracy: 0.0001)
    }

    func testFramePlacesLeadingEdgeOnNormalizedPosition() {
        let frame = KeyboardVisualizerAlignment.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.25, y: 0.75),
            in: self.area,
            horizontal: .leading,
            vertical: .center
        )

        XCTAssertEqual(frame.minX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.midY, 650, accuracy: 0.0001)
    }

    func testFramePlacesTrailingEdgeOnNormalizedPosition() {
        let frame = KeyboardVisualizerAlignment.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.25, y: 0.75),
            in: self.area,
            horizontal: .trailing,
            vertical: .center
        )

        XCTAssertEqual(frame.maxX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.midY, 650, accuracy: 0.0001)
    }

    func testFramePlacesBottomEdgeOnNormalizedPosition() {
        let frame = KeyboardVisualizerAlignment.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.25, y: 0.5),
            in: self.area,
            horizontal: .center,
            vertical: .leading
        )

        XCTAssertEqual(frame.midX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.minY, 500, accuracy: 0.0001)
    }

    func testFramePlacesTopEdgeOnNormalizedPosition() {
        let frame = KeyboardVisualizerAlignment.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.25, y: 0.5),
            in: self.area,
            horizontal: .center,
            vertical: .trailing
        )

        XCTAssertEqual(frame.midX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.maxY, 500, accuracy: 0.0001)
    }

    func testFrameClampsContentInsideVisibleFrame() {
        let frame = KeyboardVisualizerAlignment.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0, y: 1),
            in: self.area,
            horizontal: .center,
            vertical: .center
        )

        XCTAssertEqual(frame.minX, self.area.minX, accuracy: 0.0001)
        XCTAssertEqual(frame.maxY, self.area.maxY, accuracy: 0.0001)
    }

    func testFrameClampsBottomAlignedContentInsideVisibleFrame() {
        let frame = KeyboardVisualizerAlignment.frame(
            for: self.size,
            atNormalized: CGPoint(x: 0.5, y: 1),
            in: self.area,
            horizontal: .center,
            vertical: .leading
        )

        XCTAssertEqual(frame.maxY, self.area.maxY, accuracy: 0.0001)
    }

    func testAnchorXUsesAlignmentSpecificEdge() {
        let frame = CGRect(x: 180, y: 200, width: 120, height: 80)

        XCTAssertEqual(KeyboardVisualizerAlignment.leading.anchorX(in: frame), 180, accuracy: 0.0001)
        XCTAssertEqual(KeyboardVisualizerAlignment.center.anchorX(in: frame), 240, accuracy: 0.0001)
        XCTAssertEqual(KeyboardVisualizerAlignment.trailing.anchorX(in: frame), 300, accuracy: 0.0001)
    }

    func testAnchorYUsesAlignmentSpecificEdge() {
        let frame = CGRect(x: 180, y: 200, width: 120, height: 80)

        XCTAssertEqual(KeyboardVisualizerAlignment.leading.anchorY(in: frame), 200, accuracy: 0.0001)
        XCTAssertEqual(KeyboardVisualizerAlignment.center.anchorY(in: frame), 240, accuracy: 0.0001)
        XCTAssertEqual(KeyboardVisualizerAlignment.trailing.anchorY(in: frame), 280, accuracy: 0.0001)
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

    func testOriginYResolvesAlignedEdgeOntoAnchor() {
        XCTAssertEqual(
            KeyboardVisualizerAlignment.leading.originY(for: 80, anchoredAt: 300),
            300,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            KeyboardVisualizerAlignment.center.originY(for: 80, anchoredAt: 300),
            260,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            KeyboardVisualizerAlignment.trailing.originY(for: 80, anchoredAt: 300),
            220,
            accuracy: 0.0001
        )
    }

    func testAnchoredFrameRoundTripsThroughItsOwnAnchor() {
        for horizontal in KeyboardVisualizerAlignment.allCases {
            for vertical in KeyboardVisualizerAlignment.allCases {
                let frame = KeyboardVisualizerAlignment.frame(
                    for: self.size,
                    atNormalized: CGPoint(x: 0.25, y: 0.75),
                    in: self.area,
                    horizontal: horizontal,
                    vertical: vertical
                )
                let anchor = self.area.normalizedPoint(
                    for: CGPoint(
                        x: horizontal.anchorX(in: frame),
                        y: vertical.anchorY(in: frame)
                    )
                )

                XCTAssertEqual(
                    anchor.x,
                    0.25,
                    accuracy: 0.0001,
                    "\(horizontal) should place its own anchor edge back on the normalized position"
                )
                XCTAssertEqual(
                    anchor.y,
                    0.75,
                    accuracy: 0.0001,
                    "\(vertical) should place its own anchor edge back on the normalized position"
                )
            }
        }
    }
}
