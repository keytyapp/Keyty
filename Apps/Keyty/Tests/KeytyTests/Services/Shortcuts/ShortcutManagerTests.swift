//
//  ShortcutManagerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
import ShortcutRecorder
@testable import Keyty

final class ShortcutManagerTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var settings: ShortcutSettings!
    private var globalShortcutMonitor: FakeGlobalShortcutMonitor!
    private var shortcutValidator: FakeShortcutValidator!
    private var menuItemPresenter: FakeShortcutMenuItemPresenter!
    private var manager: ShortcutManager!
    private var toggleCount: Int!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        self.settings = ShortcutSettings(store: self.store)
        self.settings.registerDefaults()
        self.globalShortcutMonitor = FakeGlobalShortcutMonitor()
        self.shortcutValidator = FakeShortcutValidator()
        self.menuItemPresenter = FakeShortcutMenuItemPresenter()
        self.toggleCount = 0
        self.manager = self.makeManager()
    }

    override func tearDown() {
        self.manager = nil
        self.toggleCount = nil
        self.menuItemPresenter = nil
        self.shortcutValidator = nil
        self.globalShortcutMonitor = nil
        self.settings = nil
        self.store = nil
        super.tearDown()
    }

    func testRegistersDefaultShortcutData() {
        XCTAssertEqual(
            self.store.data(forKey: ShortcutSettings.capturingHotKeyKey),
            ShortcutArchiver.defaultData()
        )
    }

    func testPersistsShortcutToSettings() throws {
        let shortcut = Shortcut(
            code: .ansiA,
            modifierFlags: [.command, .option],
            characters: nil,
            charactersIgnoringModifiers: nil
        )

        self.manager.toggleCapturingShortcut = shortcut

        XCTAssertEqual(
            self.store.data(forKey: ShortcutSettings.capturingHotKeyKey),
            try ShortcutArchiver.data(for: shortcut)
        )
    }

    func testClearingShortcutRevertsToDefaultData() {
        self.manager.toggleCapturingShortcut = nil

        XCTAssertEqual(
            self.store.data(forKey: ShortcutSettings.capturingHotKeyKey),
            ShortcutArchiver.defaultData()
        )
    }

    func testLoadsShortcutFromSettings() throws {
        let shortcut = Shortcut(
            code: .ansiB,
            modifierFlags: [.control, .shift],
            characters: nil,
            charactersIgnoringModifiers: nil
        )
        self.store.set(try ShortcutArchiver.data(for: shortcut), forKey: ShortcutSettings.capturingHotKeyKey)

        self.manager = self.makeManager()

        XCTAssertEqual(self.manager.toggleCapturingShortcut, shortcut)
    }

    func testFallsBackToDefaultShortcutWhenStoredDataIsInvalid() {
        self.store.set(Data([0x00, 0x01, 0x02]), forKey: ShortcutSettings.capturingHotKeyKey)

        self.manager = self.makeManager()

        XCTAssertEqual(self.manager.toggleCapturingShortcut, ShortcutArchiver.defaultShortcut())
    }

    func testRegistersGlobalShortcutAtStartup() {
        XCTAssertEqual(self.globalShortcutMonitor.addedActions.count, 1)
        XCTAssertEqual(self.globalShortcutMonitor.addedActions.first?.shortcut, ShortcutArchiver.defaultShortcut())
        XCTAssertEqual(self.globalShortcutMonitor.addedKeyEvents, [.down])
    }

    func testUpdatesRegisteredGlobalShortcutWhenShortcutChanges() {
        let shortcut = Shortcut(
            code: .ansiA,
            modifierFlags: [.command, .option],
            characters: nil,
            charactersIgnoringModifiers: nil
        )

        self.manager.toggleCapturingShortcut = shortcut

        XCTAssertEqual(self.globalShortcutMonitor.removedActions.count, 1)
        XCTAssertEqual(self.globalShortcutMonitor.addedActions.count, 2)
        XCTAssertEqual(self.globalShortcutMonitor.addedActions.last?.shortcut, shortcut)
    }

    func testDoesNotUpdateRegisteredGlobalShortcutWhenShortcutIsUnchanged() {
        let shortcut = ShortcutArchiver.defaultShortcut()

        self.manager.toggleCapturingShortcut = shortcut

        XCTAssertEqual(self.globalShortcutMonitor.removedActions.count, 0)
        XCTAssertEqual(self.globalShortcutMonitor.addedActions.count, 1)
    }

    func testGlobalShortcutActionTogglesCapturing() {
        self.globalShortcutMonitor.performLastAction()

        XCTAssertEqual(self.toggleCount, 1)
    }

    func testUnregistersGlobalShortcutOnDeinit() {
        self.manager = nil

        XCTAssertEqual(self.globalShortcutMonitor.removedActions.count, 1)
    }

    func testDisplaysShortcutInMenuItemsAtStartup() {
        XCTAssertEqual(self.menuItemPresenter.displayedShortcuts, [ShortcutArchiver.defaultShortcut()])
    }

    func testRejectsInvalidShortcutWithoutPersistingOrRegistering() {
        let shortcut = Shortcut(
            code: .ansiA,
            modifierFlags: [.command, .option],
            characters: nil,
            charactersIgnoringModifiers: nil
        )
        self.shortcutValidator.validationMessages[shortcut] = "Already used"

        self.manager.toggleCapturingShortcut = shortcut

        XCTAssertEqual(self.manager.shortcutValidationMessage, "Already used")
        XCTAssertEqual(self.manager.toggleCapturingShortcut, ShortcutArchiver.defaultShortcut())
        XCTAssertEqual(self.globalShortcutMonitor.addedActions.count, 1)
        XCTAssertEqual(self.globalShortcutMonitor.removedActions.count, 0)
    }

    func testReportsInvalidStoredShortcutWithoutRegisteringIt() throws {
        let shortcut = Shortcut(
            code: .ansiB,
            modifierFlags: [.control, .shift],
            characters: nil,
            charactersIgnoringModifiers: nil
        )
        self.store.set(try ShortcutArchiver.data(for: shortcut), forKey: ShortcutSettings.capturingHotKeyKey)
        self.shortcutValidator.validationMessages[shortcut] = "Unavailable"

        self.manager = self.makeManager()

        XCTAssertEqual(self.manager.shortcutValidationMessage, "Unavailable")
        XCTAssertEqual(self.globalShortcutMonitor.addedActions.count, 1)
        XCTAssertEqual(self.globalShortcutMonitor.addedActions.first?.shortcut, ShortcutArchiver.defaultShortcut())
    }

    @MainActor
    func testRecorderValidationRejectsInvalidShortcut() {
        let shortcut = Shortcut(
            code: .ansiA,
            modifierFlags: [.command, .option],
            characters: nil,
            charactersIgnoringModifiers: nil
        )
        self.shortcutValidator.validationMessages[shortcut] = "Conflict"

        let canRecord = self.manager.recorderControl(RecorderControl(frame: .zero), canRecord: shortcut)

        XCTAssertFalse(canRecord)
        XCTAssertEqual(self.manager.shortcutValidationMessage, "Conflict")
    }

    private func makeManager() -> ShortcutManager {
        ShortcutManager(
            settings: self.settings,
            globalShortcutMonitor: self.globalShortcutMonitor,
            shortcutValidator: self.shortcutValidator,
            menuItemPresenter: self.menuItemPresenter,
            onToggleCapturingShortcut: { [weak self] in
                self?.toggleCount += 1
            }
        )
    }
}

private final class FakeGlobalShortcutMonitor: GlobalShortcutMonitoring {
    private(set) var addedActions: [ShortcutAction] = []
    private(set) var addedKeyEvents: [KeyEventType] = []
    private(set) var removedActions: [ShortcutAction] = []

    func addAction(_ action: ShortcutAction, forKeyEvent keyEvent: KeyEventType) {
        self.addedActions.append(action)
        self.addedKeyEvents.append(keyEvent)
    }

    func removeAction(_ action: ShortcutAction) {
        self.removedActions.append(action)
    }

    func performLastAction() {
        self.addedActions.last?.perform(onTarget: nil)
    }
}

private final class FakeShortcutValidator: ShortcutValidating {
    var validationMessages: [Shortcut: String] = [:]

    func validationMessage(for shortcut: Shortcut) -> String? {
        self.validationMessages[shortcut]
    }
}

private final class FakeShortcutMenuItemPresenter: ShortcutMenuItemPresenting {
    private(set) var displayedShortcuts: [Shortcut?] = []

    func displayShortcut(_ shortcut: Shortcut?) {
        self.displayedShortcuts.append(shortcut)
    }
}
