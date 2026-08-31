//
//  GeneralSettingsPaneViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

final class GeneralSettingsPaneViewModel: ObservableObject {
    let shortcutManager: ShortcutManager

    private let appSettings: any AppSettingsProtocol
    private let onResetAllSettingsToDefaults: @MainActor () -> Void
    private let onExportSettings: @MainActor () throws -> Void
    private let onImportSettings: @MainActor () throws -> Void

    @Published var visibleAtLaunch: Bool {
        didSet { self.appSettings.visibleAtLaunch = self.visibleAtLaunch }
    }

    @Published var shortcutValidationMessage: String?
    @Published var transferErrorAlert: TransferErrorAlert?

    init(
        shortcutManager: ShortcutManager,
        appSettings: any AppSettingsProtocol,
        onResetAllSettingsToDefaults: @escaping @MainActor () -> Void,
        onExportSettings: @escaping @MainActor () throws -> Void,
        onImportSettings: @escaping @MainActor () throws -> Void
    ) {
        self.shortcutManager = shortcutManager
        self.appSettings = appSettings
        self.onResetAllSettingsToDefaults = onResetAllSettingsToDefaults
        self.onExportSettings = onExportSettings
        self.onImportSettings = onImportSettings

        self.visibleAtLaunch = self.appSettings.visibleAtLaunch
        self.shortcutValidationMessage = self.shortcutManager.shortcutValidationMessage
        self.shortcutManager.onShortcutValidationMessageChanged = { [weak self] message in
            self?.shortcutValidationMessage = message
        }
    }

    @MainActor
    func resetAllSettingsToDefaults() {
        self.onResetAllSettingsToDefaults()
        self.reloadFromSettings()
    }

    @MainActor
    func exportSettings() {
        do {
            try self.onExportSettings()
        } catch {
            self.presentTransferError(error)
        }
    }

    @MainActor
    func importSettings() {
        do {
            try self.onImportSettings()
            self.reloadFromSettings()
        } catch {
            self.presentTransferError(error)
        }
    }

    @MainActor
    func reloadFromSettings() {
        self.visibleAtLaunch = self.appSettings.visibleAtLaunch
        self.shortcutValidationMessage = self.shortcutManager.shortcutValidationMessage
    }
}

extension GeneralSettingsPaneViewModel {
    struct TransferErrorAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
}

private extension GeneralSettingsPaneViewModel {
    func presentTransferError(_ error: Error) {
        self.transferErrorAlert = TransferErrorAlert(
            title: L10n.General.settingsTransferErrorTitle,
            message: error.localizedDescription
        )
    }
}
