//
//  PointerIconVisualizerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

@MainActor
final class PointerIconVisualizerTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var settings: PointerIconSettings!
    private var visualizer: PointerIconVisualizer!

    override func setUp() {
        super.setUp()
        store = InMemoryKeyValueStore()
        settings = PointerIconSettings(store: store)
        settings.registerDefaults()
        visualizer = PointerIconVisualizer(settings: settings)
    }

    override func tearDown() {
        visualizer = nil
        settings = nil
        store = nil
        super.tearDown()
    }

    func testIsEnabledDefaultsToDisabled() {
        XCTAssertFalse(visualizer.isEnabled)
    }

    func testRegistersDefaultAnchor() {
        XCTAssertEqual(
            store.integer(forKey: PointerIconSettingsKeys.anchor),
            PointerIconSettingsKeys.defaultAnchor.rawValue
        )
    }

    func testRegistersDefaultOffset() {
        XCTAssertEqual(
            CGFloat(store.double(forKey: PointerIconSettingsKeys.offset)),
            PointerIconSettingsKeys.defaultOffset
        )
    }

    func testRegistersAlwaysVisibleEnabledByDefault() {
        XCTAssertEqual(
            store.object(forKey: PointerIconSettingsKeys.alwaysVisible) as? Bool,
            PointerIconSettingsKeys.defaultAlwaysVisible
        )
    }

    func testRegistersDefaultSizeIndex() {
        XCTAssertEqual(
            store.integer(forKey: PointerIconSettingsKeys.size),
            PointerIconSettingsKeys.defaultSizeIndex
        )
    }

    func testWindowSizeScalesBackgroundPaddingWithIconSize() {
        let basePadding = Spacing.md

        settings.sizeIndex = 0
        let smallIconHeight = settings.iconSize.height
        let smallWindowSize = PointerIconContentView.windowSize(settings: settings)

        settings.sizeIndex = 6
        let mediumIconHeight = settings.iconSize.height
        let mediumWindowSize = PointerIconContentView.windowSize(settings: settings)

        settings.sizeIndex = PointerIconSettingsKeys.iconSizes.count - 1
        let largeIconHeight = settings.iconSize.height
        let largeWindowSize = PointerIconContentView.windowSize(settings: settings)

        XCTAssertEqual(PointerIconContentView.scaledPadding(for: 32), basePadding / 2)
        XCTAssertEqual(PointerIconContentView.scaledPadding(for: 64), basePadding)
        XCTAssertEqual(PointerIconContentView.scaledPadding(for: 96), basePadding * 1.5)
        XCTAssertEqual(mediumWindowSize.height - mediumIconHeight, basePadding * 2, accuracy: 0.001)
        XCTAssertEqual(smallWindowSize.height - smallIconHeight, basePadding, accuracy: 0.001)
        XCTAssertEqual(largeWindowSize.height - largeIconHeight, basePadding * 3, accuracy: 0.001)
    }

    func testIsEnabledPersists() {
        visualizer.isEnabled = true

        XCTAssertEqual(
            store.object(forKey: PointerIconSettingsKeys.isEnabled) as? Bool,
            true
        )
    }

    func testEnabledVisualizerWaitsForPresentationActivation() {
        visualizer.isEnabled = true

        XCTAssertFalse(visualizer.isPresented)

        visualizer.isPresentationActive = true

        XCTAssertTrue(visualizer.isPresented)
    }

    func testPresentationDeactivationHidesWithoutDisablingSetting() {
        visualizer.isEnabled = true
        visualizer.isPresentationActive = true

        visualizer.isPresentationActive = false

        XCTAssertFalse(visualizer.isPresented)
        XCTAssertTrue(visualizer.isEnabled)
        XCTAssertEqual(
            store.object(forKey: PointerIconSettingsKeys.isEnabled) as? Bool,
            true
        )
    }

    func testPointerIconIgnoresZeroDeltaScrollAfterRightClick() throws {
        let view = PointerIconContentView(settings: settings)

        view.handle(mouseEvent: try makeMouseEvent(type: .rightMouseDown, button: .right, buttonNumber: 1))
        XCTAssertEqual(view.displayedKind, .rightButton)
        XCTAssertTrue(view.isTransientlyVisible)

        view.handle(mouseEvent: MouseEvent.scrollStub())

        XCTAssertEqual(view.displayedKind, .rightButton)
        XCTAssertTrue(view.isTransientlyVisible)
    }

    func testIdleAlwaysVisibleIconFollowsNativeCursorVisibility() {
        XCTAssertTrue(
            PointerIconVisualizer.VisibilityPolicy.shouldShow(
                isEnabled: true,
                isPresentationActive: true,
                alwaysVisible: true,
                isTransientlyVisible: false,
                isCursorVisible: true
            )
        )
        XCTAssertFalse(
            PointerIconVisualizer.VisibilityPolicy.shouldShow(
                isEnabled: true,
                isPresentationActive: true,
                alwaysVisible: true,
                isTransientlyVisible: false,
                isCursorVisible: false
            )
        )
    }

    func testTransientPointerActivityRemainsVisibleWhenNativeCursorIsHidden() {
        XCTAssertTrue(
            PointerIconVisualizer.VisibilityPolicy.shouldShow(
                isEnabled: true,
                isPresentationActive: true,
                alwaysVisible: true,
                isTransientlyVisible: true,
                isCursorVisible: false
            )
        )
    }

    func testDisabledPointerIconRemainsHidden() {
        XCTAssertFalse(
            PointerIconVisualizer.VisibilityPolicy.shouldShow(
                isEnabled: false,
                isPresentationActive: true,
                alwaysVisible: true,
                isTransientlyVisible: true,
                isCursorVisible: true
            )
        )
    }

    private func makeMouseEvent(type: CGEventType, button: CGMouseButton = .left, buttonNumber: Int = 0) throws -> MouseEvent {
        guard let cgEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: type,
            mouseCursorPosition: CGPoint(x: 20, y: 20),
            mouseButton: button
        ), let nsEvent = NSEvent(cgEvent: cgEvent) else {
            throw TestError.eventCreationFailed
        }
        cgEvent.setIntegerValueField(.mouseEventButtonNumber, value: Int64(buttonNumber))
        return MouseEvent(nsEvent: nsEvent)
    }

    private enum TestError: Error {
        case eventCreationFailed
    }
}
