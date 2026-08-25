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

        let keystroke = StandardKeyEvent.stub(
            keyCode: .k,
            characters: "k",
            charactersIgnoringModifiers: "k"
        )
        self.visualizer.display(.keystroke(keystroke))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)

        self.visualizer.isPresentationActive = false

        XCTAssertFalse(self.visualizer.isPresented)
        XCTAssertEqual(self.visualizer.visibleGroupCount, 0)
        XCTAssertTrue(self.settings.isEnabled)
    }

    func testOnlyShowModifiedKeystrokesStillShowsStandaloneSpecialKeys() {
        self.settings.onlyShowModifiedKeystrokes = true
        self.settings.showSpecialKeys = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(.keystroke(.stub(keyCode: .escape)))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)
    }

    func testOnlyShowModifiedKeystrokesStillHidesStandaloneRegularKeys() {
        self.settings.onlyShowModifiedKeystrokes = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(.keystroke(.stub(
            keyCode: .a,
            characters: "a",
            charactersIgnoringModifiers: "a"
        )))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 0)
    }

    func testSpecialKeysToggleStillHidesStandaloneSpecialKeysWhenDisabled() {
        self.settings.onlyShowModifiedKeystrokes = true
        self.settings.showSpecialKeys = false
        self.visualizer.isPresentationActive = true

        self.visualizer.display(.keystroke(.stub(keyCode: .escape)))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 0)
    }

    func testFunctionFlagsChangedCreatesStandaloneGroup() {
        self.settings.showSpecialKeys = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(.modifierStateChanged([.function]))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)
    }

    func testFunctionKeyKeystrokeIsIgnoredWhenFunctionStateIsDrivenByFlagsChanged() {
        self.settings.showSpecialKeys = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(.keystroke(.stub(
            keyCode: .function,
            type: .keyDown,
            modifiers: [.function]
        )))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 0)
    }

    func testFunctionKeyPressAndReleaseStaysInASingleGroup() {
        self.settings.showSpecialKeys = true
        self.visualizer.isPresentationActive = true

        self.visualizer.display(.modifierStateChanged([.function]))
        self.visualizer.display(.modifierStateChanged([]))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)
    }

    func testFunctionTransformedKeyRepeatsAppendNewGroupsWhileFnIsHeld() {
        self.settings.collapseRepeatedGroups = true
        self.settings.showSpecialKeys = true
        self.visualizer.isPresentationActive = true

        let pageUpCharacter = String.functionKey(NSPageUpFunctionKey)

        self.visualizer.display(.modifierStateChanged([.function]))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .upArrow,
            type: .keyDown,
            modifiers: [.function],
            characters: pageUpCharacter,
            charactersIgnoringModifiers: pageUpCharacter
        )))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .upArrow,
            type: .keyUp,
            modifiers: [.function],
            characters: pageUpCharacter,
            charactersIgnoringModifiers: pageUpCharacter
        )))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .upArrow,
            type: .keyDown,
            modifiers: [.function],
            characters: pageUpCharacter,
            charactersIgnoringModifiers: pageUpCharacter
        )))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 2)
    }

    func testFunctionTransformedKeyDoesNotRenderFunctionModifierPreviewOnRelease() {
        self.settings.showSpecialKeys = true
        self.visualizer.isPresentationActive = true

        let pageUpCharacter = String.functionKey(NSPageUpFunctionKey)

        self.visualizer.display(.modifierStateChanged([.function]))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .upArrow,
            type: .keyDown,
            modifiers: [.function],
            characters: pageUpCharacter,
            charactersIgnoringModifiers: pageUpCharacter
        )))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .upArrow,
            type: .keyUp,
            modifiers: [.function],
            characters: pageUpCharacter,
            charactersIgnoringModifiers: pageUpCharacter
        )))
        self.visualizer.display(.modifierStateChanged([]))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 2)
    }

    func testCollapseRepeatedGroupsReusesPreviousStandaloneKeyGroup() {
        self.settings.collapseRepeatedGroups = true
        self.visualizer.isPresentationActive = true

        self.pressAndReleaseA()
        self.visualizer.display(.keystroke(.stub(
            keyCode: .a,
            type: .keyDown,
            characters: "a",
            charactersIgnoringModifiers: "a"
        )))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)

        self.visualizer.display(.keystroke(.stub(
            keyCode: .a,
            type: .keyUp,
            characters: "a",
            charactersIgnoringModifiers: "a"
        )))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)

        self.visualizer.display(.keystroke(.stub(
            keyCode: .a,
            type: .keyDown,
            characters: "a",
            charactersIgnoringModifiers: "a"
        )))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)
    }

    func testCollapseRepeatedGroupsReusesPreviousChordGroup() {
        self.settings.collapseRepeatedGroups = true
        self.visualizer.isPresentationActive = true

        let command: NSEvent.ModifierFlags = .recorded([.command])

        self.pressAndReleaseCommandK(command)
        self.visualizer.display(.modifierStateChanged(command))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .k,
            type: .keyDown,
            modifiers: command,
            characters: "k",
            charactersIgnoringModifiers: "k"
        )))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)

        self.visualizer.display(.keystroke(.stub(
            keyCode: .k,
            type: .keyUp,
            modifiers: command,
            characters: "k",
            charactersIgnoringModifiers: "k"
        )))
        self.visualizer.display(.modifierStateChanged([]))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)

        self.visualizer.display(.modifierStateChanged(command))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .k,
            type: .keyDown,
            modifiers: command,
            characters: "k",
            charactersIgnoringModifiers: "k"
        )))

        XCTAssertEqual(self.visualizer.visibleGroupCount, 1)
    }

    private func pressAndReleaseA() {
        self.visualizer.display(.keystroke(.stub(
            keyCode: .a,
            type: .keyDown,
            characters: "a",
            charactersIgnoringModifiers: "a"
        )))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .a,
            type: .keyUp,
            characters: "a",
            charactersIgnoringModifiers: "a"
        )))
    }

    private func pressAndReleaseCommandK(_ command: NSEvent.ModifierFlags) {
        self.visualizer.display(.modifierStateChanged(command))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .k,
            type: .keyDown,
            modifiers: command,
            characters: "k",
            charactersIgnoringModifiers: "k"
        )))
        self.visualizer.display(.keystroke(.stub(
            keyCode: .k,
            type: .keyUp,
            modifiers: command,
            characters: "k",
            charactersIgnoringModifiers: "k"
        )))
        self.visualizer.display(.modifierStateChanged([]))
    }
}
