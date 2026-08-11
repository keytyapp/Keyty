//
//  GeneralSettingsPaneViewModelTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import ShortcutRecorder
import XCTest
@testable import Keyty

@MainActor
final class GeneralSettingsPaneViewModelTests: XCTestCase {
    func testResetAllSettingsToDefaultsRefreshesVisibleAtLaunchAfterReset() {
        let store = InMemoryKeyValueStore()
        let appSettings = AppSettings(store: store)
        let shortcutSettings = ShortcutSettings(store: store)
        let shortcutManager = ShortcutManager(
            settings: shortcutSettings,
            globalShortcutMonitor: FakeGlobalShortcutMonitor(),
            shortcutValidator: FakeShortcutValidator(),
            menuItemPresenter: FakeShortcutMenuItemPresenter(),
            onToggleCapturingShortcut: {}
        )

        appSettings.registerDefaults()
        shortcutSettings.registerDefaults()
        appSettings.visibleAtLaunch = false

        let model = GeneralSettingsPaneViewModel(
            shortcutManager: shortcutManager,
            appSettings: appSettings,
            onResetAllSettingsToDefaults: {
                appSettings.resetToDefaults()
                shortcutSettings.resetToDefaults()
            }
        )

        model.resetAllSettingsToDefaults()

        XCTAssertTrue(model.visibleAtLaunch)
    }
}

private final class FakeGlobalShortcutMonitor: GlobalShortcutMonitoring {
    func addAction(_ action: ShortcutAction, forKeyEvent keyEvent: KeyEventType) {}
    func removeAction(_ action: ShortcutAction) {}
}

private final class FakeShortcutValidator: ShortcutValidating {
    func validationMessage(for shortcut: Shortcut) -> String? { nil }
}

private final class FakeShortcutMenuItemPresenter: ShortcutMenuItemPresenting {
    func displayShortcut(_ shortcut: Shortcut?) {}
}
