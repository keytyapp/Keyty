//
//  KeyboardVisualizerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

@MainActor
final class KeyboardVisualizerTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var settings: KeyboardVisualizerSettings!
    private var visualizer: KeyboardVisualizer!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.settings = KeyboardVisualizerSettings(store: self.store)
        self.settings.registerDefaults()
        self.visualizer = KeyboardVisualizer(settings: self.settings)
    }

    override func tearDown() {
        self.visualizer = nil
        self.settings = nil
        self.store = nil
        super.tearDown()
    }

    func testEnabledVisualizerWaitsForPresentationActivation() {
        self.settings.isEnabled = true

        XCTAssertFalse(self.visualizer.isPresented)

        self.visualizer.isPresentationActive = true

        XCTAssertTrue(self.visualizer.isPresented)
    }

    func testPresentationDeactivationClearsVisibleGroupsImmediately() {
        self.settings.isEnabled = true
        self.visualizer.isPresentationActive = true

        let keystroke = TestKeystrokes.make(
            keyCode: KeyboardKeyCode.k.rawValue,
            characters: "k",
            charactersIgnoringModifiers: "k"
        )
        self.visualizer.display(
            DisplayItem(
                asContentWithText: keystroke.displayString,
                sourceEvent: keystroke.inputEvent,
                startsNewLine: false,
                isCommand: keystroke.isCommand,
                isModified: keystroke.isModified,
                isMouseEvent: false
            )
        )

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)

        self.visualizer.isPresentationActive = false

        XCTAssertFalse(self.visualizer.isPresented)
        XCTAssertEqual(self.visualizer.visibleGroupCount, 0)
        XCTAssertTrue(self.settings.isEnabled)
    }
}
