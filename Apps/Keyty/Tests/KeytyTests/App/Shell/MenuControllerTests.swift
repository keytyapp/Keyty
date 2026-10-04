//
//  MenuControllerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

final class MenuControllerTests: XCTestCase {
    func testStatusMenuVisualizersReflectCurrentSettings() throws {
        let settings = AppSettingsContainer(store: InMemoryKeyValueStore())
        let controller = MenuController()

        let menu = controller.makeStatusMenu(
            shortcutItem: controller.makeStatusShortcutMenuItem(),
            settings: settings
        )
        menu.delegate?.menuNeedsUpdate?(menu)

        let visualizersMenu = try XCTUnwrap(menu.items[1].submenu)
        XCTAssertEqual(visualizersMenu.items.map(\.title), ["Keyboard", "Ring", "Ripples", "Icon"])
        XCTAssertEqual(visualizersMenu.items.map(\.state), [.on, .off, .off, .off])

        settings.keyboardVisualizerSettings.isEnabled = false
        settings.pointerRingSettings.isEnabled = false
        settings.pointerRipplesSettings.isEnabled = false
        settings.pointerIconSettings.isEnabled = true
        menu.delegate?.menuNeedsUpdate?(menu)

        XCTAssertEqual(visualizersMenu.items.map(\.state), [.off, .off, .off, .on])
    }

    func testMainMenuIncludesOnlyRequiredCommandQAndCommandWShortcuts() throws {
        let controller = MenuController()

        let menu = controller.makeMainMenu()
        XCTAssertEqual(menu.items.count, 2)

        let appMenu = try XCTUnwrap(menu.items.first?.submenu)
        XCTAssertEqual(appMenu.items.count, 1)
        let quitItem = try XCTUnwrap(appMenu.items.first)
        XCTAssertEqual(quitItem.keyEquivalent, "q")
        XCTAssertEqual(quitItem.keyEquivalentModifierMask, [.command])
        XCTAssertEqual(quitItem.action, #selector(AppController.quitApplication(_:)))

        let fileMenu = try XCTUnwrap(menu.items.dropFirst().first?.submenu)
        XCTAssertEqual(fileMenu.items.count, 1)
        let closeItem = try XCTUnwrap(fileMenu.items.first)
        XCTAssertEqual(closeItem.keyEquivalent, "w")
        XCTAssertEqual(closeItem.keyEquivalentModifierMask, [.command])
        XCTAssertEqual(closeItem.action, #selector(NSWindow.performClose(_:)))
        XCTAssertNil(closeItem.target)
    }
}
