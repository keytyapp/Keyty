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
    @State private var isShowingResetConfirmation = false

    init(
        shortcutManager: ShortcutManager,
        appSettings: any AppSettingsProtocol,
        onResetAllSettingsToDefaults: @escaping @MainActor () -> Void
    ) {
        _model = StateObject(wrappedValue: GeneralSettingsPaneViewModel(
            shortcutManager: shortcutManager,
            appSettings: appSettings,
            onResetAllSettingsToDefaults: onResetAllSettingsToDefaults
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

            HStack {
                Spacer(minLength: Spacing.none)

                Button(L10n.General.resetAllSettingsButton) {
                    self.isShowingResetConfirmation = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Spacer(minLength: Spacing.none)
            }
        }
        .alert(isPresented: self.$isShowingResetConfirmation) {
            Alert(
                title: Text(L10n.General.resetAllSettingsConfirmationTitle),
                message: Text(L10n.General.resetAllSettingsConfirmationMessage),
                primaryButton: .destructive(Text(L10n.General.resetAllSettingsConfirmationButton)) {
                    self.model.resetAllSettingsToDefaults()
                },
                secondaryButton: .cancel(Text(L10n.General.resetAllSettingsCancelButton))
            )
        }
    }
}
