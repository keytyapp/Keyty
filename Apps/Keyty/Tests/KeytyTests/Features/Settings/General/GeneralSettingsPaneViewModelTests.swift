//
//  GeneralSettingsPaneViewModelTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Combine
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
            captureController: self.makeCaptureController(),
            appSettings: appSettings,
            onResetAllSettingsToDefaults: {
                appSettings.resetToDefaults()
                shortcutSettings.resetToDefaults()
            }
        )

        model.resetAllSettingsToDefaults()

        XCTAssertTrue(model.visibleAtLaunch)
    }

    func testCapturingToggleUpdatesCaptureController() {
        let controller = self.makeCaptureController()
        let model = self.makeModel(captureController: controller)

        model.isCapturing = false

        XCTAssertFalse(controller.isCapturing)
    }

    func testCaptureControllerChangesUpdateCapturingToggle() async {
        let controller = self.makeCaptureController()
        let model = self.makeModel(captureController: controller)
        let expectation = self.expectation(description: "Capturing toggle updates")
        let cancellable = model.$isCapturing
            .dropFirst()
            .sink { isCapturing in
                guard !isCapturing else { return }
                expectation.fulfill()
            }

        controller.toggleCapturing()

        await self.fulfillment(of: [expectation], timeout: 1)
        XCTAssertFalse(model.isCapturing)
        withExtendedLifetime(cancellable) {}
    }

    private func makeModel(captureController: CaptureController) -> GeneralSettingsPaneViewModel {
        let store = InMemoryKeyValueStore()
        let appSettings = AppSettings(store: store)
        let shortcutSettings = ShortcutSettings(store: store)
        appSettings.registerDefaults()
        shortcutSettings.registerDefaults()
        let shortcutManager = ShortcutManager(
            settings: shortcutSettings,
            globalShortcutMonitor: FakeGlobalShortcutMonitor(),
            shortcutValidator: FakeShortcutValidator(),
            menuItemPresenter: FakeShortcutMenuItemPresenter(),
            onToggleCapturingShortcut: {}
        )
        return GeneralSettingsPaneViewModel(
            shortcutManager: shortcutManager,
            captureController: captureController,
            appSettings: appSettings,
            onResetAllSettingsToDefaults: {}
        )
    }

    private func makeCaptureController() -> CaptureController {
        let store = InMemoryKeyValueStore()
        let keyboardSettings = KeyboardVisualizerSettings(store: store)
        keyboardSettings.registerDefaults()
        let controller = CaptureController(
            pointerVisualizersManager: PointerVisualizersManager(),
            keyboardVisualizer: KeyboardVisualizer(settings: keyboardSettings),
            permissionsService: GeneralSettingsTestPermissionsService()
        )
        controller.start()
        return controller
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

private final class GeneralSettingsTestPermissionsService: PermissionsService {
    func status(for permission: Permission) -> Permission.Status { .granted }
    func request(_ permission: Permission) {}
    func observeChanges(handler: @escaping () -> Void) -> PermissionObservationToken {
        PermissionObservationToken {}
    }
}
