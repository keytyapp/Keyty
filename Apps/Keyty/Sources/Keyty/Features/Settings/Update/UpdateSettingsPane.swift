//
//  UpdateSettingsPane.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Sparkle
import SwiftUI

struct UpdateSettingsPane: View {
    @StateObject private var model: UpdateSettingsPaneViewModel

    init(updater: SPUUpdater) {
        _model = StateObject(wrappedValue: UpdateSettingsPaneViewModel(updater: updater))
    }

    var body: some View {
        SettingsStack {
            SettingsSectionView {
                SettingsControlRow(
                    title: L10n.Update.checkAtStartup,
                    subtitle: L10n.Update.checkAtStartupSubtitle
                ) {
                    Toggle("", isOn: $model.automaticallyChecksForUpdates)
                        .labelsHidden()
                        .accessibilityLabel(L10n.Update.checkAtStartup)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }

                Divider()

                SettingsControlRow(
                    title: L10n.Update.includeSystemProfile,
                    subtitle: L10n.Update.includeSystemProfileSubtitle
                ) {
                    Toggle("", isOn: $model.sendsSystemProfile)
                        .labelsHidden()
                        .accessibilityLabel(L10n.Update.includeSystemProfile)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                        .disabled(!model.automaticallyChecksForUpdates)
                }

                Divider()

                SettingsControlRow(title: L10n.Update.lastCheckedLabel, subtitle: model.lastCheckedText) {
                    Button(L10n.Update.checkNowButton) {
                        model.checkForUpdates()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}
