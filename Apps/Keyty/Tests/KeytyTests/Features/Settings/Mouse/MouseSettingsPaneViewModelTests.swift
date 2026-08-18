//
//  MouseSettingsPaneViewModelTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

@MainActor
final class MouseSettingsPaneViewModelTests: XCTestCase {
    private var ringSettings: PointerRingSettings!
    private var ringVisualizer: PointerRingVisualizer!
    private var clickRingSettings: PointerClickRingSettings!
    private var clickRingVisualizer: PointerClickRingVisualizer!
    private var iconSettings: PointerIconSettings!
    private var model: MouseSettingsPaneViewModel!

    override func setUp() {
        super.setUp()

        self.ringSettings = PointerRingSettings(store: InMemoryKeyValueStore())
        self.ringSettings.registerDefaults()
        self.ringVisualizer = PointerRingVisualizer(settings: self.ringSettings)
        self.clickRingSettings = PointerClickRingSettings(store: InMemoryKeyValueStore())
        self.clickRingSettings.registerDefaults()
        self.clickRingVisualizer = PointerClickRingVisualizer(settings: self.clickRingSettings)

        self.iconSettings = PointerIconSettings(store: InMemoryKeyValueStore())
        self.iconSettings.registerDefaults()

        self.model = MouseSettingsPaneViewModel(
            ringVisualizer: self.ringVisualizer,
            ringSettings: self.ringSettings,
            clickRingVisualizer: self.clickRingVisualizer,
            clickRingSettings: self.clickRingSettings,
            iconSettings: self.iconSettings
        )
    }

    override func tearDown() {
        self.model = nil
        self.iconSettings = nil
        self.clickRingVisualizer = nil
        self.clickRingSettings = nil
        self.ringVisualizer = nil
        self.ringSettings = nil

        super.tearDown()
    }

    func testRingSizeIsClampedToItsRangeBeforeReachingSettings() {
        let range = MouseSettingsPaneViewModel.ringSizeRange

        self.model.ringSize = range.upperBound + 100
        XCTAssertEqual(self.ringSettings.size, CGFloat(range.upperBound))

        self.model.ringSize = range.lowerBound - 100
        XCTAssertEqual(self.ringSettings.size, CGFloat(range.lowerBound))
    }

    func testRingSizeStepDividesItsRange() {
        let range = MouseSettingsPaneViewModel.ringSizeRange
        let span = range.upperBound - range.lowerBound

        XCTAssertEqual(span.truncatingRemainder(dividingBy: MouseSettingsPaneViewModel.ringSizeStep), 0)
    }

    func testRingThicknessIsClampedToItsRangeBeforeReachingSettings() {
        let range = MouseSettingsPaneViewModel.ringThicknessRange

        self.model.ringThickness = range.upperBound + 100
        XCTAssertEqual(self.ringSettings.thickness, CGFloat(range.upperBound))

        self.model.ringThickness = range.lowerBound - 100
        XCTAssertEqual(self.ringSettings.thickness, CGFloat(range.lowerBound))
    }

    func testRingThicknessStepDividesItsRange() {
        let range = MouseSettingsPaneViewModel.ringThicknessRange
        let span = range.upperBound - range.lowerBound

        XCTAssertEqual(span.truncatingRemainder(dividingBy: MouseSettingsPaneViewModel.ringThicknessStep), 0)
    }

    func testClickRingEnabledUpdatesSettings() {
        self.model.clickRingEnabled = true

        XCTAssertTrue(self.clickRingSettings.isEnabled)
    }

    func testEnablingRingDoesNotDisableClickRing() {
        self.model.clickRingEnabled = true
        self.model.ringEnabled = true

        XCTAssertTrue(self.model.clickRingEnabled)
        XCTAssertTrue(self.clickRingSettings.isEnabled)
        XCTAssertTrue(self.model.ringEnabled)
        XCTAssertTrue(self.ringSettings.isEnabled)
    }

    func testDefaultIconColorsUsePresetSelections() {
        XCTAssertEqual(
            self.model.iconBackgroundColorSelectionID,
            PointerIconSettingsKeys.defaultBackgroundColor.hexString
        )
        XCTAssertEqual(
            self.model.iconTintColorSelectionID,
            PointerIconSettingsKeys.defaultTintColor.hexString
        )
    }

    func testIconBackgroundSelectionUsesBackgroundPresetSections() {
        let preset = MouseSettingsPaneViewModel.ColorPreset.iconBackgroundColorSections[0][0]

        self.model.selectIconBackgroundColor(with: preset.color.hexString)

        XCTAssertEqual(self.model.iconBackgroundColorSelectionID, preset.color.hexString)
    }

    func testIconTintSelectionUsesTintPresetSections() {
        self.model.selectIconTintColor(with: NSColor.black.hexString)

        XCTAssertEqual(self.model.iconTintColorSelectionID, NSColor.black.hexString)
    }
}
