//
//  PointerClickRingVisualizerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import CoreGraphics
import XCTest
@testable import Keyty

@MainActor
final class PointerClickRingVisualizerTests: XCTestCase {
    private var visualizer: PointerClickRingVisualizer!
    private var store: InMemoryKeyValueStore!
    private var settings: PointerClickRingSettings!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.settings = PointerClickRingSettings(store: self.store)
        self.settings.registerDefaults()
        self.visualizer = PointerClickRingVisualizer(settings: self.settings)
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

    func testRegistersDefaultColor() {
        XCTAssertEqual(
            self.store.string(forKey: PointerClickRingSettingsKeys.color),
            PointerClickRingSettingsKeys.defaultColor
        )
    }

    func testRegistersDefaultShape() {
        XCTAssertEqual(
            self.store.string(forKey: PointerClickRingSettingsKeys.shape),
            PointerClickRingSettingsKeys.defaultShape.rawValue
        )
    }

    func testClickRingSpawnsTransientRingOnPress() async {
        self.visualizer.isEnabled = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(self.mouseEvent(type: .leftMouseDown))

        XCTAssertTrue(self.visualizer.isPresented)

        try? await Task.sleep(nanoseconds: (PointerRingAnimation.spawnAnimationDuration * 1.2).nanoseconds)

        XCTAssertFalse(self.visualizer.isPresented)
    }

    func testPresentationDeactivationRemovesActiveClickRings() {
        self.visualizer.isEnabled = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(self.mouseEvent(type: .leftMouseDown))
        XCTAssertTrue(self.visualizer.isPresented)

        self.visualizer.isPresentationActive = false

        XCTAssertFalse(self.visualizer.isPresented)
    }

    func testExternalSettingsDisableRemovesActiveClickRings() async {
        self.visualizer.isEnabled = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(self.mouseEvent(type: .leftMouseDown))
        XCTAssertTrue(self.visualizer.isPresented)

        self.settings.isEnabled = false
        await Task.yield()

        XCTAssertFalse(self.visualizer.isPresented)
    }
}

private extension PointerClickRingVisualizerTests {
    func mouseEvent(type: CGEventType) -> MouseEvent {
        let cgEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: type,
            mouseCursorPosition: CGPoint(x: 120, y: 80),
            mouseButton: .left
        )!
        let nsEvent = NSEvent(cgEvent: cgEvent)!
        return MouseEvent(nsEvent: nsEvent, cgEvent: cgEvent)
    }
}
