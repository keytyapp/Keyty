//
//  AppSettingsTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class AppSettingsTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var settings: AppSettings!

    override func setUp() {
        super.setUp()
        store = InMemoryKeyValueStore()
        settings = AppSettings(store: store)
    }

    override func tearDown() {
        settings = nil
        store = nil
        super.tearDown()
    }

    func testRegistersDefaults() {
        settings.registerDefaults()

        XCTAssertTrue(store.bool(forKey: AppSettings.visibleAtLaunchKey))
    }

    func testPersistsVisibility() {
        settings.visibleAtLaunch = false

        XCTAssertFalse(settings.visibleAtLaunch)
        XCTAssertFalse(store.bool(forKey: AppSettings.visibleAtLaunchKey))
    }

    func testResetToDefaultsRemovesStoredValue() {
        settings.registerDefaults()
        settings.visibleAtLaunch = false

        settings.resetToDefaults()

        XCTAssertTrue(settings.visibleAtLaunch)
        XCTAssertTrue(store.bool(forKey: AppSettings.visibleAtLaunchKey))
    }
}
