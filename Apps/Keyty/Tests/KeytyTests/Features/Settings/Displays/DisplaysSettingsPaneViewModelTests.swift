//
//  DisplaysSettingsPaneViewModelTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Combine
import XCTest
@testable import Keyty

@MainActor
final class DisplaysSettingsPaneViewModelTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var keyboardVisualizerSettings: KeyboardVisualizerSettings!
    private var screensService: TestScreenService!
    private var startSettingCallCount = 0
    private var stopSettingCallCount = 0
    private var model: DisplaysSettingsPaneViewModel!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.keyboardVisualizerSettings = KeyboardVisualizerSettings(store: self.store)
        self.screensService = TestScreenService()
        self.startSettingCallCount = 0
        self.stopSettingCallCount = 0
        self.model = DisplaysSettingsPaneViewModel(
            screensService: self.screensService,
            keyboardVisualizerSettings: self.keyboardVisualizerSettings,
            startSettingKeyboardVisualizerPosition: { [weak self] in
                self?.startSettingCallCount += 1
            },
            stopSettingKeyboardVisualizerPosition: { [weak self] in
                self?.stopSettingCallCount += 1
            }
        )
    }

    override func tearDown() {
        self.model = nil
        self.stopSettingCallCount = 0
        self.startSettingCallCount = 0
        self.screensService = nil
        self.keyboardVisualizerSettings = nil
        self.store = nil
        super.tearDown()
    }

    func testToggleCustomPositionSettingFlipsLocalFlagOnly() {
        self.keyboardVisualizerSettings.customPositionX = 0.25
        self.keyboardVisualizerSettings.customPositionY = 0.75

        self.model.toggleCustomPositionSetting()

        XCTAssertTrue(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionX, 0.25, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionY, 0.75, accuracy: 0.0001)

        self.model.toggleCustomPositionSetting()

        XCTAssertFalse(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionX, 0.25, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionY, 0.75, accuracy: 0.0001)
    }

    func testToggleCustomPositionSettingStartsAndStopsPlacementController() {
        self.model.toggleCustomPositionSetting()

        XCTAssertTrue(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.startSettingCallCount, 1)
        XCTAssertEqual(self.stopSettingCallCount, 0)

        self.model.toggleCustomPositionSetting()

        XCTAssertFalse(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.startSettingCallCount, 1)
        XCTAssertEqual(self.stopSettingCallCount, 1)
    }

    func testChangingPlacementModeStopsPositionSetting() {
        self.model.placementMode = .custom
        self.model.toggleCustomPositionSetting()

        self.model.placementMode = .anchored

        XCTAssertFalse(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.stopSettingCallCount, 1)
    }
}

@MainActor
final class KeyboardVisualizerPlacementWindowControllerTests: XCTestCase {
    func testFramePlacesHandleCenterAtNormalizedPosition() {
        let area = CGRect(x: 100, y: 200, width: 800, height: 600)
        let size = CGSize(width: 120, height: 80)

        let frame = KeyboardVisualizerPlacementWindowController.frame(
            forNormalizedPosition: CGPoint(x: 0.25, y: 0.75),
            in: area,
            size: size
        )

        XCTAssertEqual(frame.midX, 300, accuracy: 0.0001)
        XCTAssertEqual(frame.midY, 650, accuracy: 0.0001)
    }

    func testFrameClampsHandleInsideVisibleFrame() {
        let area = CGRect(x: 100, y: 200, width: 800, height: 600)
        let size = CGSize(width: 120, height: 80)

        let frame = KeyboardVisualizerPlacementWindowController.frame(
            forNormalizedPosition: CGPoint(x: 0, y: 1),
            in: area,
            size: size
        )

        XCTAssertEqual(frame.minX, area.minX, accuracy: 0.0001)
        XCTAssertEqual(frame.maxY, area.maxY, accuracy: 0.0001)
    }

    func testNormalizedPositionClampsPointToVisibleFrame() {
        let area = CGRect(x: 100, y: 200, width: 800, height: 600)

        let position = KeyboardVisualizerPlacementWindowController.normalizedPosition(
            for: CGPoint(x: 980, y: 140),
            in: area
        )

        XCTAssertEqual(position.x, 1, accuracy: 0.0001)
        XCTAssertEqual(position.y, 0, accuracy: 0.0001)
    }
}

private final class TestScreenService: ScreenServiceProvider {
    private let screensSubject: CurrentValueSubject<[Screen], Never>

    let screens: [Screen]

    var screensDidChange: AnyPublisher<[Screen], Never> {
        self.screensSubject.eraseToAnyPublisher()
    }

    init() {
        self.screens = [
            Screen(
                id: 1,
                displayName: "Display",
                wallpaperImageURL: nil,
                frame: CGRect(x: 0, y: 0, width: 1920, height: 1080)
            ),
        ]
        self.screensSubject = CurrentValueSubject(self.screens)
    }

    func display(for id: CGDirectDisplayID) -> Screen? {
        self.screens.first { $0.id == id }
    }

    func mainDisplay() -> Screen? {
        self.screens.first
    }

    func visibleFrame(for id: CGDirectDisplayID) -> CGRect? {
        self.display(for: id)?.frame
    }

    func mainVisibleFrame() -> CGRect? {
        self.mainDisplay()?.frame
    }
}
