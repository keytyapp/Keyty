//
//  AppDependencies.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Sparkle

@MainActor
final class AppDependencies {
    let settings: AppSettingsContainer
    let services: AppServiceContainer
    let ui: AppUIContainer

    var captureController: CaptureController { self.services.captureController }
    var appSettings: any AppSettingsProtocol { self.settings.appSettings }
    var permissionsOnboardingWindowController: PermissionsOnboardingWindowController { self.ui.permissionsOnboardingWindowController }
    var aboutWindowController: AboutWindowController { self.ui.aboutWindowController }
    var settingsWindowController: SettingsWindowController { self.ui.settingsWindowController }

    init(
        statusShortcutItem: NSMenuItem,
        updater: SPUUpdater,
        keyValueStore: KeyValueStore = UserDefaultsStore()
    ) {
        self.settings = AppSettingsContainer(store: keyValueStore)
        self.services = AppServiceContainer(
            settings: self.settings,
            statusShortcutItem: statusShortcutItem
        )
        self.ui = AppUIContainer(
            settings: self.settings,
            services: self.services,
            updater: updater
        )
    }
}
