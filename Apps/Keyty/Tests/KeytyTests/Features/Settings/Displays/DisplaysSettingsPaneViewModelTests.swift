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

final class DisplaysSettingsPaneViewModelTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var keyboardVisualizerSettings: KeyboardVisualizerSettings!
    private var screensService: TestScreenService!
    private var model: DisplaysSettingsPaneViewModel!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.keyboardVisualizerSettings = KeyboardVisualizerSettings(store: self.store)
        self.screensService = TestScreenService()
        self.model = DisplaysSettingsPaneViewModel(
            screensService: self.screensService,
            keyboardVisualizerSettings: self.keyboardVisualizerSettings
        )
    }

    override func tearDown() {
        self.model = nil
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
