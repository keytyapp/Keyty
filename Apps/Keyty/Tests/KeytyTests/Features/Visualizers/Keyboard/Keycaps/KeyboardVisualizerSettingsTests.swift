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
        store = InMemoryKeyValueStore()
        settings = KeyboardVisualizerSettings(store: store)
    }

    override func tearDown() {
        settings = nil
        store = nil
        super.tearDown()
    }

    func testRegistersDefaults() {
        settings.registerDefaults()

        XCTAssertEqual(store.bool(forKey: KeyboardVisualizerSettingsKeys.isEnabled), true)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.axis), KeyboardVisualizerStackAxis.vertical.storedValue)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.maxCount), KeyboardVisualizerSettingsKeys.defaultMaxCount)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.fadeDelay), 2.0, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.fadeDuration), 0.2, accuracy: 0.0001)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.theme), KeyboardVisualizerTheme.black.rawValue)
        XCTAssertEqual(store.bool(forKey: KeyboardVisualizerSettingsKeys.usesCustomThemePalette), false)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.style), KeycapStyle.apple.rawValue)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.scale), 1.0, accuracy: 0.0001)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.placementMode), KeyboardVisualizerSettings.PlacementMode.anchored.rawValue)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedX), 0.5, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedY), 0.5, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.windowPadding), Double(Size.KeyboardVisualizer.windowPadding), accuracy: 0.0001)
        XCTAssertEqual(store.bool(forKey: KeyboardVisualizerSettingsKeys.onlyShowModifiedKeystrokes), false)
        XCTAssertEqual(store.bool(forKey: KeyboardVisualizerSettingsKeys.showSpecialKeys), true)
        XCTAssertEqual(store.bool(forKey: KeyboardVisualizerSettingsKeys.showMediaKeyButtons), true)
        XCTAssertEqual(store.bool(forKey: KeyboardVisualizerSettingsKeys.showMouseEvents), true)
    }

    func testSharedKeyboardVisualizerSettingsFallbackAndClamping() {
        settings.maxCount = 0
        XCTAssertEqual(settings.maxCount, 1)

        settings.stackAxis = .horizontal
        XCTAssertEqual(settings.stackAxis, .horizontal)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.axis), KeyboardVisualizerStackAxis.horizontal.storedValue)

        store.set(3, forKey: KeyboardVisualizerSettingsKeys.axis)
        XCTAssertEqual(settings.stackAxis, .horizontal)
    }

    func testPersistsIsEnabled() {
        settings.isEnabled = false

        XCTAssertFalse(settings.isEnabled)
        XCTAssertFalse(store.bool(forKey: KeyboardVisualizerSettingsKeys.isEnabled))
    }

    func testPublishesIsEnabledChanges() {
        settings.registerDefaults()
        var receivedValues: [Bool] = []
        let cancellable = settings.isEnabledChanges.sink { value in
            receivedValues.append(value)
        }

        settings.isEnabled = false

        XCTAssertEqual(receivedValues, [false])
        cancellable.cancel()
    }

    func testDoesNotPublishIsEnabledWhenValueIsUnchanged() {
        settings.registerDefaults()
        var receivedValues: [Bool] = []
        let cancellable = settings.isEnabledChanges.sink { value in
            receivedValues.append(value)
        }

        settings.isEnabled = true

        XCTAssertTrue(receivedValues.isEmpty)
        cancellable.cancel()
    }

    func testPersistsScale() {
        settings.scale = 1.5

        XCTAssertEqual(settings.scale, 1.5, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.scale), 1.5, accuracy: 0.0001)
    }

    func testScaleClampsAndFallsBack() {
        settings.scale = 5.0
        XCTAssertEqual(settings.scale, 2.0, accuracy: 0.0001)

        settings.scale = 0.1
        XCTAssertEqual(settings.scale, 0.5, accuracy: 0.0001)

        // Unset (zero) falls back to the 100% default.
        store.set(0.0, forKey: KeyboardVisualizerSettingsKeys.scale)
        XCTAssertEqual(settings.scale, 1.0, accuracy: 0.0001)
    }

    func testPersistsWindowPadding() {
        settings.windowPadding = 24

        XCTAssertEqual(settings.windowPadding, 24, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.windowPadding), 24, accuracy: 0.0001)
    }

    func testWindowPaddingClamps() {
        settings.windowPadding = KeyboardVisualizerSettings.maxWindowPadding + 10
        XCTAssertEqual(settings.windowPadding, KeyboardVisualizerSettings.maxWindowPadding, accuracy: 0.0001)

        settings.windowPadding = KeyboardVisualizerSettings.minWindowPadding - 10
        XCTAssertEqual(settings.windowPadding, KeyboardVisualizerSettings.minWindowPadding, accuracy: 0.0001)
    }

    func testPersistsPlacementMode() {
        settings.placementMode = .custom

        XCTAssertEqual(settings.placementMode, .custom)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.placementMode), KeyboardVisualizerSettings.PlacementMode.custom.rawValue)
    }

    func testCustomPositionClamps() {
        settings.customPositionNormalizedX = 1.5
        settings.customPositionNormalizedY = -0.5

        XCTAssertEqual(settings.customPositionNormalizedX, 1, accuracy: 0.0001)
        XCTAssertEqual(settings.customPositionNormalizedY, 0, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedX), 1, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedY), 0, accuracy: 0.0001)
    }

    func testApplyCustomPlacementStoresDisplayAndClampedPosition() {
        settings.applyCustomPlacement(
            screenID: 42,
            normalizedX: 1.5,
            normalizedY: -0.5
        )

        XCTAssertEqual(settings.screenID, 42)
        XCTAssertEqual(settings.customPositionNormalizedX, 1, accuracy: 0.0001)
        XCTAssertEqual(settings.customPositionNormalizedY, 0, accuracy: 0.0001)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.screenID), 42)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedX), 1, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.customPositionNormalizedY), 0, accuracy: 0.0001)
    }

    func testPublishesPlacementChangesForCustomPlacementSettings() {
        var receivedCount = 0
        let cancellable = settings.placementChanges.sink { _ in
            receivedCount += 1
        }

        settings.placementMode = .custom
        settings.customPositionNormalizedX = 0.25
        settings.customPositionNormalizedY = 0.75

        XCTAssertEqual(receivedCount, 3)
        cancellable.cancel()
    }

    func testPersistsSharedTimingSettings() {
        settings.fadeDelay = 3.5
        settings.fadeDuration = 0.45

        XCTAssertEqual(settings.fadeDelay, 3.5, accuracy: 0.0001)
        XCTAssertEqual(settings.fadeDuration, 0.45, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.fadeDelay), 3.5, accuracy: 0.0001)
        XCTAssertEqual(store.double(forKey: KeyboardVisualizerSettingsKeys.fadeDuration), 0.45, accuracy: 0.0001)
    }

    func testPersistsStyle() {
        settings.style = .pbt

        XCTAssertEqual(settings.style, .pbt)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.style), KeycapStyle.pbt.rawValue)
    }

    func testPersistsTheme() {
        settings.theme = .rose

        XCTAssertEqual(settings.theme, .rose)
        XCTAssertEqual(store.integer(forKey: KeyboardVisualizerSettingsKeys.theme), KeyboardVisualizerTheme.rose.rawValue)
        XCTAssertEqual(settings.themeTokens.textColor, KeyboardVisualizerTheme.rose.tokens.textColor)
    }

    func testPersistsShowMediaKeyButtons() {
        settings.showMediaKeyButtons = false

        XCTAssertFalse(settings.showMediaKeyButtons)
        XCTAssertFalse(store.bool(forKey: KeyboardVisualizerSettingsKeys.showMediaKeyButtons))
    }

    func testPersistsOnlyShowModifiedKeystrokes() {
        settings.onlyShowModifiedKeystrokes = true

        XCTAssertTrue(settings.onlyShowModifiedKeystrokes)
        XCTAssertTrue(store.bool(forKey: KeyboardVisualizerSettingsKeys.onlyShowModifiedKeystrokes))
    }

    func testPersistsShowSpecialKeys() {
        settings.showSpecialKeys = false

        XCTAssertFalse(settings.showSpecialKeys)
        XCTAssertFalse(store.bool(forKey: KeyboardVisualizerSettingsKeys.showSpecialKeys))
    }

    func testPersistsShowMouseEvents() {
        settings.showMouseEvents = false

        XCTAssertFalse(settings.showMouseEvents)
        XCTAssertFalse(store.bool(forKey: KeyboardVisualizerSettingsKeys.showMouseEvents))
    }

    func testAppearanceFollowsSelectedStyle() {
        settings.theme = .citrus
        settings.style = .apple
        let appleAppearance = settings.appearance

        settings.style = .pbt
        let pbtAppearance = settings.appearance

        XCTAssertEqual(appleAppearance.textColor, pbtAppearance.textColor)
        XCTAssertTrue(appleAppearance.apple != nil)
        XCTAssertTrue(pbtAppearance.pbt != nil)
        XCTAssertEqual(pbtAppearance.pbt?.bodyStrokeColor, KeyboardVisualizerTheme.citrus.appearance(for: .pbt).pbt?.bodyStrokeColor)
    }

    func testThemeExposesSemanticTokens() {
        settings.theme = .black

        XCTAssertEqual(settings.themeTokens.surfaceBaseColor, KeyboardVisualizerTheme.black.tokens.surfaceBaseColor)
        XCTAssertEqual(settings.themeTokens.recessColor, KeyboardVisualizerTheme.black.tokens.recessColor)
    }
}
