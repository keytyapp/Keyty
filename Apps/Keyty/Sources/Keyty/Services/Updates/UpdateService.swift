//
//  UpdateService.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

#if !APP_STORE
import Sparkle
#endif

@MainActor
protocol UpdateService: AnyObject {
    var automaticallyChecksForUpdates: Bool { get set }
    var sendsSystemProfile: Bool { get set }
    var lastUpdateCheckDate: Date? { get }

    func checkForUpdates()
    func checkForUpdatesInBackground()
}

@MainActor
enum UpdateServiceFactory {
    static func make() -> any UpdateService {
        #if APP_STORE
        return NoOpUpdateService()
        #else
        return SparkleUpdateService()
        #endif
    }
}

#if APP_STORE
@MainActor
/// App Store distributions receive updates through macOS rather than an in-app updater.
private final class NoOpUpdateService: UpdateService {
    var automaticallyChecksForUpdates: Bool {
        get { false }
        set {}
    }

    var sendsSystemProfile: Bool {
        get { false }
        set {}
    }

    let lastUpdateCheckDate: Date? = nil

    func checkForUpdates() {}

    func checkForUpdatesInBackground() {}
}
#else
@MainActor
private final class SparkleUpdateService: UpdateService {
    private let controller: SPUStandardUpdaterController

    init() {
        self.controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var automaticallyChecksForUpdates: Bool {
        get { self.controller.updater.automaticallyChecksForUpdates }
        set { self.controller.updater.automaticallyChecksForUpdates = newValue }
    }

    var sendsSystemProfile: Bool {
        get { self.controller.updater.sendsSystemProfile }
        set { self.controller.updater.sendsSystemProfile = newValue }
    }

    var lastUpdateCheckDate: Date? {
        self.controller.updater.lastUpdateCheckDate
    }

    func checkForUpdates() {
        self.controller.updater.checkForUpdates()
    }

    func checkForUpdatesInBackground() {
        self.controller.updater.checkForUpdatesInBackground()
    }
}
#endif
