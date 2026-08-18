//
//  PointerVisualizersManagerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

@MainActor
final class PointerVisualizersManagerTests: XCTestCase {
    func testRingAndClickRingCanBothStayEnabled() async {
        let ringSettings = PointerRingSettings(store: InMemoryKeyValueStore())
        ringSettings.registerDefaults()
        let clickRingSettings = PointerClickRingSettings(store: InMemoryKeyValueStore())
        clickRingSettings.registerDefaults()

        let manager = PointerVisualizersManager(
            pointerRingSettings: ringSettings,
            pointerClickRingSettings: clickRingSettings,
            pointerIconSettings: PointerIconSettings(store: InMemoryKeyValueStore())
        )

        manager.ring.isEnabled = true
        manager.clickRing.isEnabled = true
        await Task.yield()

        XCTAssertTrue(manager.ring.isEnabled)
        XCTAssertTrue(manager.clickRing.isEnabled)
    }
}
