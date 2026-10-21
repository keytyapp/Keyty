//
//  PointerRipplesVisualizerTests.swift
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
final class PointerRipplesVisualizerTests: XCTestCase {
    private var visualizer: PointerRipplesVisualizer!
    private var store: InMemoryKeyValueStore!
    private var settings: PointerRipplesSettings!

    override func setUp() async throws {
        try await super.setUp()
        nonisolated(unsafe) let testCase = self
        await MainActor.run {
            testCase.store = InMemoryKeyValueStore()
            testCase.settings = PointerRipplesSettings(store: testCase.store)
            testCase.settings.registerDefaults()
            testCase.visualizer = PointerRipplesVisualizer(settings: testCase.settings)
        }
    }

    override func tearDown() async throws {
        nonisolated(unsafe) let testCase = self
        await MainActor.run {
            testCase.visualizer = nil
            testCase.settings = nil
            testCase.store = nil
        }
        try await super.tearDown()
    }

    func testIsEnabledDefaultsToDisabled() {
        XCTAssertFalse(self.visualizer.isEnabled)
    }

    func testRegistersDefaultColor() {
        XCTAssertEqual(
            self.store.string(forKey: PointerRipplesSettingsKeys.color),
            PointerRipplesSettingsKeys.defaultColor
        )
    }

    func testRegistersDefaultShape() {
        XCTAssertEqual(
            self.store.string(forKey: PointerRipplesSettingsKeys.shape),
            PointerRipplesSettingsKeys.defaultShape.rawValue
        )
    }

    func testRegistersDefaultDuration() {
        XCTAssertEqual(
            CGFloat(self.store.double(forKey: PointerRipplesSettingsKeys.duration)),
            PointerRipplesSettingsKeys.defaultDuration
        )
    }

    func testDurationClampsDirectSettingsWrites() {
        self.settings.duration = PointerRipplesSettingsKeys.durationRange.upperBound + 1
        XCTAssertEqual(self.settings.duration, PointerRipplesSettingsKeys.durationRange.upperBound)

        self.settings.duration = PointerRipplesSettingsKeys.durationRange.lowerBound - 1
        XCTAssertEqual(self.settings.duration, PointerRipplesSettingsKeys.durationRange.lowerBound)
    }

    func testRipplesSpawnsTransientRingOnPress() async {
        self.visualizer.isEnabled = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(self.mouseEvent(type: .leftMouseDown))

        XCTAssertTrue(self.visualizer.isPresented)

        try? await Task.sleep(nanoseconds: (self.settings.duration * 1.2).nanoseconds)

        XCTAssertFalse(self.visualizer.isPresented)
    }

    func testPresentationDeactivationRemovesActiveRipples() {
        self.visualizer.isEnabled = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(self.mouseEvent(type: .leftMouseDown))
        XCTAssertTrue(self.visualizer.isPresented)

        self.visualizer.isPresentationActive = false

        XCTAssertFalse(self.visualizer.isPresented)
    }

    func testExternalSettingsDisableRemovesActiveRipples() async {
        self.visualizer.isEnabled = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(self.mouseEvent(type: .leftMouseDown))
        XCTAssertTrue(self.visualizer.isPresented)

        self.settings.isEnabled = false
        await Task.yield()

        XCTAssertFalse(self.visualizer.isPresented)
    }
}

private extension PointerRipplesVisualizerTests {
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
