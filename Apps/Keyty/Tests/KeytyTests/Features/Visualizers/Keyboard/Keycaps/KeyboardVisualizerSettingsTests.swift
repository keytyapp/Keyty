//
//  KeyboardVisualizerSettingsTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Combine
import XCTest
@testable import Keyty

final class KeyboardVisualizerSettingsTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var settings: KeyboardVisualizerSettings!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.settings = KeyboardVisualizerSettings(store: self.store)
    }

    override func tearDown() {
        self.settings = nil
        self.store = nil
        super.tearDown()
    }

    func testRegistersDefaults() {
        self.settings.registerDefaults()

        XCTAssertEqual(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.isEnabled), true)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.axis), KeyboardVisualizerStackAxis.vertical.storedValue)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.maxCount), KeyboardVisualizerSettingsKeys.defaultMaxCount)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.fadeDelay), 2.0, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.fadeDuration), 0.2, accuracy: 0.0001)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.theme), KeyboardVisualizerTheme.black.rawValue)
        XCTAssertEqual(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.usesCustomThemePalette), false)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.style), KeycapStyle.apple.rawValue)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.scale), 1.0, accuracy: 0.0001)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.placementMode), KeyboardVisualizerSettings.PlacementMode.anchored.rawValue)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedX), 0.5, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedY), 0.5, accuracy: 0.0001)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.customHorizontalAlignment), KeyboardVisualizerAlignment.center.rawValue)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.windowPadding), Double(Size.KeyboardVisualizer.windowPadding), accuracy: 0.0001)
        XCTAssertEqual(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.onlyShowModifiedKeystrokes), false)
        XCTAssertEqual(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.showSpecialKeys), true)
        XCTAssertEqual(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.showMediaKeyButtons), true)
        XCTAssertEqual(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.showMouseEvents), true)
    }

    func testSharedKeyboardVisualizerSettingsFallbackAndClamping() {
        self.settings.maxCount = 0
        XCTAssertEqual(self.settings.maxCount, 1)

        self.settings.stackAxis = .horizontal
        XCTAssertEqual(self.settings.stackAxis, .horizontal)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.axis), KeyboardVisualizerStackAxis.horizontal.storedValue)

        self.store.set(3, forKey: KeyboardVisualizerSettingsKeys.axis)
        XCTAssertEqual(self.settings.stackAxis, .horizontal)
    }

    func testPersistsIsEnabled() {
        self.settings.isEnabled = false

        XCTAssertFalse(self.settings.isEnabled)
        XCTAssertFalse(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.isEnabled))
    }

    func testPublishesIsEnabledChanges() {
        self.settings.registerDefaults()
        var receivedValues: [Bool] = []
        let cancellable = self.settings.isEnabledChanges.sink { value in
            receivedValues.append(value)
        }

        self.settings.isEnabled = false

        XCTAssertEqual(receivedValues, [false])
        cancellable.cancel()
    }

    func testDoesNotPublishIsEnabledWhenValueIsUnchanged() {
        self.settings.registerDefaults()
        var receivedValues: [Bool] = []
        let cancellable = self.settings.isEnabledChanges.sink { value in
            receivedValues.append(value)
        }

        self.settings.isEnabled = true

        XCTAssertTrue(receivedValues.isEmpty)
        cancellable.cancel()
    }

    func testPersistsScale() {
        self.settings.scale = 1.5

        XCTAssertEqual(self.settings.scale, 1.5, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.scale), 1.5, accuracy: 0.0001)
    }

    func testScaleClampsAndFallsBack() {
        self.settings.scale = 5.0
        XCTAssertEqual(self.settings.scale, 2.0, accuracy: 0.0001)

        self.settings.scale = 0.1
        XCTAssertEqual(self.settings.scale, 0.5, accuracy: 0.0001)

        // Unset (zero) falls back to the 100% default.
        self.store.set(0.0, forKey: KeyboardVisualizerSettingsKeys.scale)
        XCTAssertEqual(self.settings.scale, 1.0, accuracy: 0.0001)
    }

    func testPersistsWindowPadding() {
        self.settings.windowPadding = 24

        XCTAssertEqual(self.settings.windowPadding, 24, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.windowPadding), 24, accuracy: 0.0001)
    }

    func testWindowPaddingClamps() {
        self.settings.windowPadding = KeyboardVisualizerSettings.maxWindowPadding + 10
        XCTAssertEqual(self.settings.windowPadding, KeyboardVisualizerSettings.maxWindowPadding, accuracy: 0.0001)

        self.settings.windowPadding = KeyboardVisualizerSettings.minWindowPadding - 10
        XCTAssertEqual(self.settings.windowPadding, KeyboardVisualizerSettings.minWindowPadding, accuracy: 0.0001)
    }

    func testPersistsPlacementMode() {
        self.settings.placementMode = .custom

        XCTAssertEqual(self.settings.placementMode, .custom)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.placementMode), KeyboardVisualizerSettings.PlacementMode.custom.rawValue)
    }

    func testPersistsCustomHorizontalAlignment() {
        self.settings.customHorizontalAlignment = .trailing

        XCTAssertEqual(self.settings.customHorizontalAlignment, .trailing)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.customHorizontalAlignment), KeyboardVisualizerAlignment.trailing.rawValue)
    }

    func testCustomPlacementUsesCustomHorizontalAlignmentForVerticalStacks() {
        self.settings.placementMode = .custom
        self.settings.stackAxis = .vertical
        self.settings.customHorizontalAlignment = .leading

        XCTAssertEqual(self.settings.alignment, .leading)

        self.settings.customHorizontalAlignment = .trailing

        XCTAssertEqual(self.settings.alignment, .trailing)
    }

    func testCustomPlacementKeepsHorizontalStacksVerticallyCentered() {
        self.settings.placementMode = .custom
        self.settings.stackAxis = .horizontal
        self.settings.customHorizontalAlignment = .trailing

        XCTAssertEqual(self.settings.alignment, .center)
    }

    func testAnchoredPlacementStillDerivesAlignmentFromAnchor() {
        self.settings.placementMode = .anchored
        self.settings.stackAxis = .vertical
        self.settings.anchor = .topLeft
        self.settings.customHorizontalAlignment = .trailing

        XCTAssertEqual(self.settings.alignment, .leading)

        self.settings.stackAxis = .horizontal
        self.settings.anchor = .topRight

        XCTAssertEqual(self.settings.alignment, .trailing)
    }

    func testCustomPositionClamps() {
        self.settings.customPositionNormalizedX = 1.5
        self.settings.customPositionNormalizedY = -0.5

        XCTAssertEqual(self.settings.customPositionNormalizedX, 1, accuracy: 0.0001)
        XCTAssertEqual(self.settings.customPositionNormalizedY, 0, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedX), 1, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedY), 0, accuracy: 0.0001)
    }

    func testApplyCustomPlacementStoresDisplayAndClampedPosition() {
        self.settings.applyCustomPlacement(
            screenID: 42,
            normalizedX: 1.5,
            normalizedY: -0.5
        )

        XCTAssertEqual(self.settings.screenID, 42)
        XCTAssertEqual(self.settings.customPositionNormalizedX, 1, accuracy: 0.0001)
        XCTAssertEqual(self.settings.customPositionNormalizedY, 0, accuracy: 0.0001)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.screenID), 42)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedX), 1, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedY), 0, accuracy: 0.0001)
    }

    func testPublishesPlacementChangesForCustomPlacementSettings() {
        var receivedCount = 0
        let cancellable = self.settings.placementChanges.sink { _ in
            receivedCount += 1
        }

        self.settings.placementMode = .custom
        self.settings.customPositionNormalizedX = 0.25
        self.settings.customPositionNormalizedY = 0.75
        self.settings.customHorizontalAlignment = .leading

        XCTAssertEqual(receivedCount, 3)
        cancellable.cancel()
    }

    func testPersistsSharedTimingSettings() {
        self.settings.fadeDelay = 3.5
        self.settings.fadeDuration = 0.45

        XCTAssertEqual(self.settings.fadeDelay, 3.5, accuracy: 0.0001)
        XCTAssertEqual(self.settings.fadeDuration, 0.45, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.fadeDelay), 3.5, accuracy: 0.0001)
        XCTAssertEqual(self.store.double(forKey: KeyboardVisualizerSettingsKeys.fadeDuration), 0.45, accuracy: 0.0001)
    }

    func testPersistsStyle() {
        self.settings.style = .pbt

        XCTAssertEqual(self.settings.style, .pbt)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.style), KeycapStyle.pbt.rawValue)
    }

    func testPersistsTheme() {
        self.settings.theme = .rose

        XCTAssertEqual(self.settings.theme, .rose)
        XCTAssertEqual(self.store.integer(forKey: KeyboardVisualizerSettingsKeys.theme), KeyboardVisualizerTheme.rose.rawValue)
        XCTAssertEqual(self.settings.themeTokens.textColor, KeyboardVisualizerTheme.rose.tokens.textColor)
    }

    func testPersistsShowMediaKeyButtons() {
        self.settings.showMediaKeyButtons = false

        XCTAssertFalse(self.settings.showMediaKeyButtons)
        XCTAssertFalse(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.showMediaKeyButtons))
    }

    func testPersistsOnlyShowModifiedKeystrokes() {
        self.settings.onlyShowModifiedKeystrokes = true

        XCTAssertTrue(self.settings.onlyShowModifiedKeystrokes)
        XCTAssertTrue(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.onlyShowModifiedKeystrokes))
    }

    func testPersistsShowSpecialKeys() {
        self.settings.showSpecialKeys = false

        XCTAssertFalse(self.settings.showSpecialKeys)
        XCTAssertFalse(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.showSpecialKeys))
    }

    func testPersistsShowMouseEvents() {
        self.settings.showMouseEvents = false

        XCTAssertFalse(self.settings.showMouseEvents)
        XCTAssertFalse(self.store.bool(forKey: KeyboardVisualizerSettingsKeys.showMouseEvents))
    }

    func testAppearanceFollowsSelectedStyle() {
        self.settings.theme = .citrus
        self.settings.style = .apple
        let appleAppearance = self.settings.appearance

        self.settings.style = .pbt
        let pbtAppearance = self.settings.appearance

        XCTAssertEqual(appleAppearance.textColor, pbtAppearance.textColor)
        XCTAssertTrue(appleAppearance.apple != nil)
        XCTAssertTrue(pbtAppearance.pbt != nil)
        XCTAssertEqual(pbtAppearance.pbt?.bodyStrokeColor, KeyboardVisualizerTheme.citrus.appearance(for: .pbt).pbt?.bodyStrokeColor)
    }

    func testThemeExposesSemanticTokens() {
        self.settings.theme = .black

        XCTAssertEqual(self.settings.themeTokens.surfaceBaseColor, KeyboardVisualizerTheme.black.tokens.surfaceBaseColor)
        XCTAssertEqual(self.settings.themeTokens.recessColor, KeyboardVisualizerTheme.black.tokens.recessColor)
    }
}
