//
//  GeneralSettingsPane.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

struct GeneralSettingsPane: View {
    @StateObject private var model: GeneralSettingsPaneViewModel

    init(shortcutManager: ShortcutManager, appSettings: any AppSettingsProtocol) {
        _model = StateObject(wrappedValue: GeneralSettingsPaneViewModel(
            shortcutManager: shortcutManager,
            appSettings: appSettings
        ))
    }

    var body: some View {
        SettingsStack {
            SettingsSectionView(title: L10n.General.appearanceSectionTitle) {
                SettingsControlRow(
                    title: L10n.General.showSettingsAtLaunch,
                    subtitle: L10n.General.showSettingsAtLaunchSubtitle
                ) {
                    Toggle("", isOn: $model.visibleAtLaunch)
                        .labelsHidden()
                        .accessibilityLabel(L10n.General.showSettingsAtLaunch)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }
            }

            SettingsSectionView(title: L10n.General.shortcutSectionTitle) {
                SettingsControlRow(
                    title: L10n.General.toggleCapturingLabel,
                    subtitle: L10n.General.toggleCapturingSubtitle
                ) {
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        ShortcutRecorderView(shortcutManager: model.shortcutManager)
                            .frame(Size.Settings.recorder)

                        if let validationMessage = model.shortcutValidationMessage {
                            Text(validationMessage)
                                .font(Typography.Settings.rowSubtitle)
                                .foregroundColor(Color.Theme.State.danger)
                                .multilineTextAlignment(.trailing)
                                .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}
