//
//  SettingsTransferPanelPresenter.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

@MainActor
struct SettingsTransferPanelPresenter {
    let presentExportPanel: () -> URL?
    let presentImportPanel: () -> URL?
}

extension SettingsTransferPanelPresenter {
    static let live = SettingsTransferPanelPresenter(
        presentExportPanel: {
            let panel = NSSavePanel()
            panel.canCreateDirectories = true
            panel.isExtensionHidden = false
            panel.allowedFileTypes = [SettingsTransferService.archiveFileExtension]
            panel.nameFieldStringValue = SettingsTransferService.defaultArchiveFilename
            panel.title = L10n.General.exportSettingsPanelTitle
            panel.prompt = L10n.General.exportSettingsButton

            guard panel.runModal() == .OK else { return nil }
            return panel.url
        },
        presentImportPanel: {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            panel.allowedFileTypes = [SettingsTransferService.archiveFileExtension]
            panel.title = L10n.General.importSettingsPanelTitle
            panel.prompt = L10n.General.importSettingsButton

            guard panel.runModal() == .OK else { return nil }
            return panel.url
        }
    )
}
