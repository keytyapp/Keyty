//
//  PointerRingVisualizerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

@MainActor
final class PointerRingVisualizerTests: XCTestCase {
    var visualizer: PointerRingVisualizer!
    private var store: InMemoryKeyValueStore!
    private var settings: PointerRingSettings!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.settings = PointerRingSettings(store: self.store)
        self.settings.registerDefaults()
        self.visualizer = PointerRingVisualizer(settings: self.settings)
    }

    override func tearDown() {
        self.visualizer = nil
        self.settings = nil
        self.store = nil
        super.tearDown()
    }

    func testIsEnabledDefaultsToDisabled() {
        XCTAssertFalse(self.visualizer.isEnabled)
    }

    func testNoteScrollWheelEventIsIgnored() {
        let cgEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel,
                              wheelCount: 1, wheel1: 10, wheel2: 0, wheel3: 0)!
        let nsEvent = NSEvent(cgEvent: cgEvent)!
        XCTAssertNoThrow(self.visualizer.display(MouseEvent(nsEvent: nsEvent)))
    }

    func testRegistersDefaultColor() {
        XCTAssertEqual(
            self.store.string(forKey: PointerRingSettingsKeys.color),
            PointerRingSettingsKeys.defaultColor
        )
    }

    func testRegistersAlwaysVisibleDisabledByDefault() {
        XCTAssertEqual(
            self.store.object(forKey: PointerRingSettingsKeys.alwaysVisible) as? Bool,
            PointerRingSettingsKeys.defaultAlwaysVisible
        )
    }

    func testRegistersDefaultSize() {
        XCTAssertEqual(
            CGFloat(self.store.double(forKey: PointerRingSettingsKeys.size)),
            PointerRingSettingsKeys.defaultSize
        )
    }

    func testRegistersDefaultThickness() {
        XCTAssertEqual(
            CGFloat(self.store.double(forKey: PointerRingSettingsKeys.thickness)),
            PointerRingSettingsKeys.defaultThickness
        )
    }

    func testSizeClampsDirectSettingsWrites() {
        self.settings.size = PointerRingSettingsKeys.sizeRange.upperBound + 100
        XCTAssertEqual(self.settings.size, PointerRingSettingsKeys.sizeRange.upperBound)
        XCTAssertEqual(
            CGFloat(self.store.double(forKey: PointerRingSettingsKeys.size)),
            PointerRingSettingsKeys.sizeRange.upperBound
        )

        self.settings.size = PointerRingSettingsKeys.sizeRange.lowerBound - 100
        XCTAssertEqual(self.settings.size, PointerRingSettingsKeys.sizeRange.lowerBound)
        XCTAssertEqual(
            CGFloat(self.store.double(forKey: PointerRingSettingsKeys.size)),
            PointerRingSettingsKeys.sizeRange.lowerBound
        )
    }

    func testThicknessClampsDirectSettingsWrites() {
        self.settings.thickness = PointerRingSettingsKeys.thicknessRange.upperBound + 100
        XCTAssertEqual(self.settings.thickness, PointerRingSettingsKeys.thicknessRange.upperBound)
        XCTAssertEqual(
            CGFloat(self.store.double(forKey: PointerRingSettingsKeys.thickness)),
            PointerRingSettingsKeys.thicknessRange.upperBound
        )

        self.settings.thickness = PointerRingSettingsKeys.thicknessRange.lowerBound - 100
        XCTAssertEqual(self.settings.thickness, PointerRingSettingsKeys.thicknessRange.lowerBound)
        XCTAssertEqual(
            CGFloat(self.store.double(forKey: PointerRingSettingsKeys.thickness)),
            PointerRingSettingsKeys.thicknessRange.lowerBound
        )
    }

    func testRegistersDefaultShape() {
        XCTAssertEqual(
            self.store.string(forKey: PointerRingSettingsKeys.shape),
            PointerRingSettingsKeys.defaultShape.rawValue
        )
    }

    func testIsEnabledPersists() {
        self.visualizer.isEnabled = true

        XCTAssertEqual(
            self.store.object(forKey: PointerRingSettingsKeys.isEnabled) as? Bool,
            true
        )
    }

    func testExternalSettingsDisableUpdatesVisualizer() async {
        self.visualizer.isEnabled = true
        self.visualizer.isPresentationActive = true
        XCTAssertTrue(self.visualizer.isPresented)

        self.settings.isEnabled = false
        await Task.yield()

        XCTAssertFalse(self.visualizer.isEnabled)
        XCTAssertFalse(self.visualizer.isPresented)
    }

    func testEnabledVisualizerWaitsForPresentationActivation() {
        self.visualizer.isEnabled = true

        XCTAssertFalse(self.visualizer.isPresented)

        self.visualizer.isPresentationActive = true

        XCTAssertTrue(self.visualizer.isPresented)
    }

    func testPresentationDeactivationHidesWithoutDisablingSetting() {
        self.visualizer.isEnabled = true
        self.visualizer.isPresentationActive = true

        self.visualizer.isPresentationActive = false

        XCTAssertFalse(self.visualizer.isPresented)
        XCTAssertTrue(self.visualizer.isEnabled)
        XCTAssertEqual(
            self.store.object(forKey: PointerRingSettingsKeys.isEnabled) as? Bool,
            true
        )
    }

    func testAlwaysVisiblePersists() {
        self.settings.alwaysVisible = true

        XCTAssertEqual(
            self.store.object(forKey: PointerRingSettingsKeys.alwaysVisible) as? Bool,
            true
        )
    }

    func testShapePersists() {
        self.settings.shape = .rhomb

        XCTAssertEqual(
            self.store.string(forKey: PointerRingSettingsKeys.shape),
            PointerRingShape.rhomb.rawValue
        )
    }

    func testRingPathCircleUsesOval() {
        let rect = NSRect(x: 4, y: 6, width: 20, height: 20)
        let path = PointerRingVisualizerWindow.makeVisualizerPath(shape: .circle, rect: rect)

        XCTAssertEqual(path.cgPath.pathElements.map(\.type.rawValue), [
            CGPathElementType.moveToPoint.rawValue,
            CGPathElementType.addCurveToPoint.rawValue,
            CGPathElementType.addCurveToPoint.rawValue,
            CGPathElementType.addCurveToPoint.rawValue,
            CGPathElementType.addCurveToPoint.rawValue,
        ])
        XCTAssertEqual(path.bounds.minX, rect.minX, accuracy: 0.001)
        XCTAssertEqual(path.bounds.minY, rect.minY, accuracy: 0.001)
        XCTAssertEqual(path.bounds.width, rect.width, accuracy: 0.001)
        XCTAssertEqual(path.bounds.height, rect.height, accuracy: 0.001)
    }

    func testRingPathRhombUsesFourCorners() {
        let rect = NSRect(x: 4, y: 6, width: 20, height: 20)
        let rhomb = PointerRingVisualizerWindow.makeVisualizerPath(shape: .rhomb, rect: rect)
        let squircle = PointerRingVisualizerWindow.makeVisualizerPath(shape: .squircle, rect: rect)
        let rotatedSquircle = squircle.rotated(byDegrees: 45, around: NSPoint(x: rect.midX, y: rect.midY))

        XCTAssertEqual(rhomb.cgPath.pathElements.map(\.type), rotatedSquircle.cgPath.pathElements.map(\.type))
        for (lhs, rhs) in zip(rhomb.cgPath.pathElements, rotatedSquircle.cgPath.pathElements) {
            XCTAssertEqual(lhs.points.count, rhs.points.count)
            for (left, right) in zip(lhs.points, rhs.points) {
                XCTAssertEqual(left.x, right.x, accuracy: 0.001)
                XCTAssertEqual(left.y, right.y, accuracy: 0.001)
            }
        }
        XCTAssertEqual(rhomb.bounds.minX, rotatedSquircle.bounds.minX, accuracy: 0.001)
        XCTAssertEqual(rhomb.bounds.minY, rotatedSquircle.bounds.minY, accuracy: 0.001)
        XCTAssertEqual(rhomb.bounds.width, rotatedSquircle.bounds.width, accuracy: 0.001)
        XCTAssertEqual(rhomb.bounds.height, rotatedSquircle.bounds.height, accuracy: 0.001)
    }

    func testRingPathSquircleStaysWithinBounds() {
        let rect = NSRect(x: 4, y: 6, width: 20, height: 20)
        let path = PointerRingVisualizerWindow.makeVisualizerPath(shape: .squircle, rect: rect)

        XCTAssertGreaterThan(path.elementCount, 10)
        XCTAssertEqual(path.bounds.minX, rect.minX, accuracy: 0.001)
        XCTAssertEqual(path.bounds.minY, rect.minY, accuracy: 0.001)
        XCTAssertEqual(path.bounds.maxX, rect.maxX, accuracy: 0.001)
        XCTAssertEqual(path.bounds.maxY, rect.maxY, accuracy: 0.001)
    }
}

private extension NSBezierPath {
    func rotated(byDegrees degrees: CGFloat, around center: NSPoint) -> NSBezierPath {
        let copy = self.copy() as! NSBezierPath
        let transform = NSAffineTransform()
        transform.translateX(by: center.x, yBy: center.y)
        transform.rotate(byDegrees: degrees)
        transform.translateX(by: -center.x, yBy: -center.y)
        copy.transform(using: transform as AffineTransform)
        return copy
    }
}
