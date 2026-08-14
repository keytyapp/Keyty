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
    private var placementCoordinator: FakeKeyboardVisualizerPlacementCoordinator!
    private var model: DisplaysSettingsPaneViewModel!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.keyboardVisualizerSettings = KeyboardVisualizerSettings(store: self.store)
        self.screensService = TestScreenService()
        self.placementCoordinator = FakeKeyboardVisualizerPlacementCoordinator()
        self.model = DisplaysSettingsPaneViewModel(
            screensService: self.screensService,
            keyboardVisualizerSettings: self.keyboardVisualizerSettings,
            placementCoordinator: self.placementCoordinator
        )
    }

    override func tearDown() {
        self.model = nil
        self.placementCoordinator = nil
        self.screensService = nil
        self.keyboardVisualizerSettings = nil
        self.store = nil
        super.tearDown()
    }

    func testToggleCustomPositionSettingFlipsLocalFlagOnly() {
        self.keyboardVisualizerSettings.customPositionNormalizedX = 0.25
        self.keyboardVisualizerSettings.customPositionNormalizedY = 0.75

        self.model.toggleCustomPositionSetting()

        XCTAssertTrue(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedX, 0.25, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedY, 0.75, accuracy: 0.0001)

        self.model.toggleCustomPositionSetting()

        XCTAssertFalse(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedX, 0.25, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedY, 0.75, accuracy: 0.0001)
    }

    func testToggleCustomPositionSettingStartsAndStopsPlacementController() {
        self.model.toggleCustomPositionSetting()

        XCTAssertTrue(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.placementCoordinator.startSettingCallCount, 1)
        XCTAssertEqual(self.placementCoordinator.stopSettingCallCount, 0)

        self.model.toggleCustomPositionSetting()

        XCTAssertFalse(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.placementCoordinator.startSettingCallCount, 1)
        XCTAssertEqual(self.placementCoordinator.stopSettingCallCount, 1)
    }

    func testChangingPlacementModeStopsPositionSetting() {
        self.model.placementMode = .custom
        self.model.toggleCustomPositionSetting()

        self.model.placementMode = .anchored

        XCTAssertFalse(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.placementCoordinator.stopSettingCallCount, 1)
    }

    func testAnchorSelectionReflectsPlacementMode() {
        self.model.selectedAnchor = .topLeft
        self.model.placementMode = .anchored

        XCTAssertEqual(self.model.anchorSelection, .anchor(.topLeft))

        self.model.placementMode = .custom

        XCTAssertEqual(self.model.anchorSelection, .custom)
    }

    func testSettingAnchorSelectionUpdatesAnchoredPlacement() {
        self.model.placementMode = .custom

        self.model.anchorSelection = .anchor(.topRight)

        XCTAssertEqual(self.model.placementMode, .anchored)
        XCTAssertEqual(self.keyboardVisualizerSettings.placementMode, .anchored)
        XCTAssertEqual(self.model.selectedAnchor, .topRight)
        XCTAssertEqual(self.keyboardVisualizerSettings.anchor, .topRight)
    }

    func testSettingCustomAnchorSelectionUpdatesCustomPlacement() {
        self.model.anchorSelection = .custom

        XCTAssertEqual(self.model.placementMode, .custom)
        XCTAssertEqual(self.keyboardVisualizerSettings.placementMode, .custom)
        XCTAssertEqual(self.model.anchorSelection, .custom)
    }

    func testCustomHorizontalAlignmentUpdatesSettings() {
        self.model.customHorizontalAlignment = .trailing

        XCTAssertEqual(self.keyboardVisualizerSettings.customHorizontalAlignment, .trailing)
    }

    func testPlacementChangesRefreshCustomHorizontalAlignment() {
        self.keyboardVisualizerSettings.customHorizontalAlignment = .leading

        XCTAssertEqual(self.model.customHorizontalAlignment, .leading)
    }

    func testFinishingCustomPositionSettingStopsAndAppliesReturnedPlacement() {
        self.placementCoordinator.placementToReturn = KeyboardVisualizerPlacementWindowController.Placement(
            screenID: 2,
            positionX: 0.3,
            positionY: 0.7
        )

        self.model.toggleCustomPositionSetting()
        self.model.finishCustomPositionSetting()

        XCTAssertFalse(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.placementCoordinator.stopSettingCallCount, 1)
        XCTAssertEqual(self.model.selectedScreenID, 2)
        XCTAssertEqual(self.keyboardVisualizerSettings.screenID, 2)
        XCTAssertEqual(self.model.customPositionNormalizedX, 0.3, accuracy: 0.0001)
        XCTAssertEqual(self.model.customPositionNormalizedY, 0.7, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedX, 0.3, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedY, 0.7, accuracy: 0.0001)
    }

    func testFinishingCustomPositionSettingDoesNothingWhenNotSetting() {
        self.model.finishCustomPositionSetting()

        XCTAssertFalse(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.placementCoordinator.stopSettingCallCount, 0)
    }

    func testStoppingCustomPositionSettingAppliesReturnedPlacement() {
        self.placementCoordinator.placementToReturn = KeyboardVisualizerPlacementWindowController.Placement(
            screenID: 2,
            positionX: 0.25,
            positionY: 0.75
        )

        self.model.toggleCustomPositionSetting()
        self.model.toggleCustomPositionSetting()

        XCTAssertEqual(self.model.selectedScreenID, 2)
        XCTAssertEqual(self.keyboardVisualizerSettings.screenID, 2)
        XCTAssertEqual(self.model.customPositionNormalizedX, 0.25, accuracy: 0.0001)
        XCTAssertEqual(self.model.customPositionNormalizedY, 0.75, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedX, 0.25, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedY, 0.75, accuracy: 0.0001)
    }

    func testPlacementChangeWhileSettingAppliesPlacement() {
        self.model.toggleCustomPositionSetting()

        self.placementCoordinator.placementChangeHandler?(
            KeyboardVisualizerPlacementWindowController.Placement(
                screenID: 2,
                positionX: 0.4,
                positionY: 0.6
            )
        )

        XCTAssertTrue(self.model.isSettingCustomPosition)
        XCTAssertEqual(self.model.selectedScreenID, 2)
        XCTAssertEqual(self.keyboardVisualizerSettings.screenID, 2)
        XCTAssertEqual(self.model.customPositionNormalizedX, 0.4, accuracy: 0.0001)
        XCTAssertEqual(self.model.customPositionNormalizedY, 0.6, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedX, 0.4, accuracy: 0.0001)
        XCTAssertEqual(self.keyboardVisualizerSettings.customPositionNormalizedY, 0.6, accuracy: 0.0001)
    }
}

@MainActor
private final class FakeKeyboardVisualizerPlacementCoordinator: KeyboardVisualizerPlacementCoordinating {
    private(set) var startSettingCallCount = 0
    private(set) var stopSettingCallCount = 0
    var placementToReturn: KeyboardVisualizerPlacementWindowController.Placement?
    var placementChangeHandler: KeyboardVisualizerPlacementWindowController.PlacementChangeHandler?

    func startSettingPosition(
        onPlacementChanged: @escaping KeyboardVisualizerPlacementWindowController.PlacementChangeHandler
    ) {
        self.startSettingCallCount += 1
        self.placementChangeHandler = onPlacementChanged
    }

    func stopSettingPosition() -> KeyboardVisualizerPlacementWindowController.Placement? {
        self.stopSettingCallCount += 1
        return self.placementToReturn
    }
}

@MainActor
final class KeyboardVisualizerPlacementWindowControllerTests: XCTestCase {




    func testAlignmentChangeKeepsPreviewInPlaceAndMovesAnchorToNewEdge() {
        let settings = KeyboardVisualizerSettings(store: InMemoryKeyValueStore())
        settings.placementMode = .custom
        settings.stackAxis = .vertical
        settings.customHorizontalAlignment = .center
        settings.customPositionNormalizedX = 0.25
        settings.customPositionNormalizedY = 0.5

        let screensService = TestScreenService()
        let screenWidth = screensService.screens[0].frame.width
        let controller = KeyboardVisualizerPlacementWindowController(
            settings: settings,
            screensService: screensService
        )
        controller.startSettingPosition { placement in
            settings.applyCustomPlacement(
                screenID: placement.screenID,
                normalizedX: placement.positionX,
                normalizedY: placement.positionY
            )
        }

        guard let window = controller.window else {
            return XCTFail("Expected the preview window to be created")
        }
        let previewFrame = window.frame
        XCTAssertEqual(previewFrame.midX, 480, accuracy: 0.0001)

        settings.customHorizontalAlignment = .leading
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        XCTAssertEqual(window.frame, previewFrame)
        XCTAssertEqual(
            settings.customPositionNormalizedX,
            previewFrame.minX / screenWidth,
            accuracy: 0.0001
        )

        settings.customHorizontalAlignment = .trailing
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        XCTAssertEqual(window.frame, previewFrame)
        XCTAssertEqual(
            settings.customPositionNormalizedX,
            previewFrame.maxX / screenWidth,
            accuracy: 0.0001
        )

        _ = controller.stopSettingPosition()
    }



    func testPlacementUsesScreenContainingPoint() {
        let placement = KeyboardVisualizerPlacementWindowController.placement(
            for: CGPoint(x: 2500, y: 540),
            in: Self.visibleFrames
        )

        XCTAssertEqual(placement?.screenID, 2)
        XCTAssertEqual(placement?.positionX ?? 0, 0.3021, accuracy: 0.0001)
        XCTAssertEqual(placement?.positionY ?? 0, 0.5, accuracy: 0.0001)
    }

    func testPlacementFallsBackToNearestScreen() {
        let placement = KeyboardVisualizerPlacementWindowController.placement(
            for: CGPoint(x: 3950, y: 540),
            in: Self.visibleFrames
        )

        XCTAssertEqual(placement?.screenID, 2)
        XCTAssertEqual(placement?.positionX ?? 0, 1, accuracy: 0.0001)
        XCTAssertEqual(placement?.positionY ?? 0, 0.5, accuracy: 0.0001)
    }

    private static let visibleFrames: [(screenID: CGDirectDisplayID, frame: CGRect)] = [
        (1, CGRect(x: 0, y: 0, width: 1920, height: 1080)),
        (2, CGRect(x: 1920, y: 0, width: 1920, height: 1080)),
    ]
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
            Screen(
                id: 2,
                displayName: "Display 2",
                wallpaperImageURL: nil,
                frame: CGRect(x: 1920, y: 0, width: 1920, height: 1080)
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
