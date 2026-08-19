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
    private var ripplesSettings: PointerRipplesSettings!
    private var ripplesVisualizer: PointerRipplesVisualizer!
    private var iconSettings: PointerIconSettings!
    private var model: MouseSettingsPaneViewModel!

    override func setUp() {
        super.setUp()

        self.ringSettings = PointerRingSettings(store: InMemoryKeyValueStore())
        self.ringSettings.registerDefaults()
        self.ringVisualizer = PointerRingVisualizer(settings: self.ringSettings)
        self.ripplesSettings = PointerRipplesSettings(store: InMemoryKeyValueStore())
        self.ripplesSettings.registerDefaults()
        self.ripplesVisualizer = PointerRipplesVisualizer(settings: self.ripplesSettings)

        self.iconSettings = PointerIconSettings(store: InMemoryKeyValueStore())
        self.iconSettings.registerDefaults()

        self.model = MouseSettingsPaneViewModel(
            ringVisualizer: self.ringVisualizer,
            ringSettings: self.ringSettings,
            ripplesVisualizer: self.ripplesVisualizer,
            ripplesSettings: self.ripplesSettings,
            iconSettings: self.iconSettings
        )
    }

    override func tearDown() {
        self.model = nil
        self.iconSettings = nil
        self.ripplesVisualizer = nil
        self.ripplesSettings = nil
        self.ringVisualizer = nil
        self.ringSettings = nil

        super.tearDown()
    }

    func testRingSizeIsClampedToItsRangeBeforeReachingSettings() {
        let range = MouseSettingsPaneViewModel.ringSizeRange

        self.model.ring.size = range.upperBound + 100
        XCTAssertEqual(self.ringSettings.size, CGFloat(range.upperBound))

        self.model.ring.size = range.lowerBound - 100
        XCTAssertEqual(self.ringSettings.size, CGFloat(range.lowerBound))
    }

    func testRingSizeStepDividesItsRange() {
        let range = MouseSettingsPaneViewModel.ringSizeRange
        let span = range.upperBound - range.lowerBound

        XCTAssertEqual(span.truncatingRemainder(dividingBy: MouseSettingsPaneViewModel.ringSizeStep), 0)
    }

    func testRingThicknessIsClampedToItsRangeBeforeReachingSettings() {
        let range = MouseSettingsPaneViewModel.ringThicknessRange

        self.model.ring.thickness = range.upperBound + 100
        XCTAssertEqual(self.ringSettings.thickness, CGFloat(range.upperBound))

        self.model.ring.thickness = range.lowerBound - 100
        XCTAssertEqual(self.ringSettings.thickness, CGFloat(range.lowerBound))
    }

    func testRingThicknessStepDividesItsRange() {
        let range = MouseSettingsPaneViewModel.ringThicknessRange
        let span = range.upperBound - range.lowerBound

        XCTAssertEqual(span.truncatingRemainder(dividingBy: MouseSettingsPaneViewModel.ringThicknessStep), 0)
    }

    func testRipplesEnabledUpdatesSettings() {
        self.model.ripples.enabled = true

        XCTAssertTrue(self.ripplesSettings.isEnabled)
    }

    func testEnablingRingDoesNotDisableRipples() {
        self.model.ripples.enabled = true
        self.model.ring.enabled = true

        XCTAssertTrue(self.model.ripples.enabled)
        XCTAssertTrue(self.ripplesSettings.isEnabled)
        XCTAssertTrue(self.model.ring.enabled)
        XCTAssertTrue(self.ringSettings.isEnabled)
    }

    func testDefaultIconColorsUsePresetSelections() {
        XCTAssertEqual(
            self.model.icon.backgroundColorSelectionID,
            PointerIconSettingsKeys.defaultBackgroundColor.hexString
        )
        XCTAssertEqual(
            self.model.icon.tintColorSelectionID,
            PointerIconSettingsKeys.defaultTintColor.hexString
        )
    }

    func testIconBackgroundSelectionUsesBackgroundPresetSections() {
        let preset = MouseSettingsPaneViewModel.ColorPreset.iconBackgroundColorSections[0][0]

        self.model.icon.selectBackgroundColor(with: preset.color.hexString)

        XCTAssertEqual(self.model.icon.backgroundColorSelectionID, preset.color.hexString)
    }

    func testIconTintSelectionUsesTintPresetSections() {
        self.model.icon.selectTintColor(with: NSColor.black.hexString)

        XCTAssertEqual(self.model.icon.tintColorSelectionID, NSColor.black.hexString)
    }
}
