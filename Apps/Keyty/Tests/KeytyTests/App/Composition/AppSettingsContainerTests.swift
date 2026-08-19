//
//  AppSettingsContainerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

final class AppSettingsContainerTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var container: AppSettingsContainer!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.container = AppSettingsContainer(store: self.store)
    }

    override func tearDown() {
        self.container = nil
        self.store = nil
        super.tearDown()
    }

    func testResetAllSettingsToDefaultsRestoresAllSettingsGroups() {
        self.container.appSettings.visibleAtLaunch = false
        self.container.pointerRingSettings.isEnabled = true
        self.container.pointerRingSettings.color = .systemRed
        self.container.pointerRipplesSettings.isEnabled = true
        self.container.pointerRipplesSettings.thickness = 9
        self.container.pointerIconSettings.isEnabled = true
        self.container.pointerIconSettings.offset = 42
        self.container.shortcutSettings.capturingHotKeyData = nil
        self.container.keyboardVisualizerSettings.isEnabled = false
        self.container.keyboardVisualizerSettings.scale = 1.75
        self.container.keyboardVisualizerSettings.placementMode = .custom

        self.container.resetAllSettingsToDefaults()

        XCTAssertTrue(self.container.appSettings.visibleAtLaunch)
        XCTAssertEqual(self.container.pointerRingSettings.isEnabled, PointerRingSettingsKeys.defaultIsEnabled)
        XCTAssertEqual(self.container.pointerRingSettings.color.hexString, PointerRingSettingsKeys.automaticVisualizerColor.hexString)
        XCTAssertEqual(self.container.pointerRipplesSettings.isEnabled, PointerRipplesSettingsKeys.defaultIsEnabled)
        XCTAssertEqual(self.container.pointerRipplesSettings.thickness, PointerRipplesSettingsKeys.defaultThickness)
        XCTAssertFalse(self.container.pointerIconSettings.isEnabled)
        XCTAssertEqual(self.container.pointerIconSettings.offset, PointerIconSettingsKeys.defaultOffset, accuracy: 0.0001)
        XCTAssertEqual(self.container.shortcutSettings.capturingHotKeyData, ShortcutArchiver.defaultShortcutData())
        XCTAssertTrue(self.container.keyboardVisualizerSettings.isEnabled)
        XCTAssertEqual(self.container.keyboardVisualizerSettings.scale, 1.0, accuracy: 0.0001)
        XCTAssertEqual(self.container.keyboardVisualizerSettings.placementMode, .anchored)
    }
}
