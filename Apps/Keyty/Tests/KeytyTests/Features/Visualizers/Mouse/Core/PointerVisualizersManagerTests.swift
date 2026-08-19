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
    func testRingAndRipplesCanBothStayEnabled() async {
        let ringSettings = PointerRingSettings(store: InMemoryKeyValueStore())
        ringSettings.registerDefaults()
        let ripplesSettings = PointerRipplesSettings(store: InMemoryKeyValueStore())
        ripplesSettings.registerDefaults()

        let manager = PointerVisualizersManager(
            pointerRingSettings: ringSettings,
            pointerRipplesSettings: ripplesSettings,
            pointerIconSettings: PointerIconSettings(store: InMemoryKeyValueStore())
        )

        manager.ring.isEnabled = true
        manager.ripples.isEnabled = true
        await Task.yield()

        XCTAssertTrue(manager.ring.isEnabled)
        XCTAssertTrue(manager.ripples.isEnabled)
    }
}
