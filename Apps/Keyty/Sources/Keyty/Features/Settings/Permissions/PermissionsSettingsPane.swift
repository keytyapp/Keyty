//
//  PermissionsSettingsPane.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

struct PermissionsSettingsPane: View {
    @ObservedObject private var model: PermissionsSettingsPaneViewModel

    init(permissionsService: any PermissionsService) {
        self.model = PermissionsSettingsPaneViewModel(permissionsService: permissionsService)
    }

    var body: some View {
        SettingsStack {
            SettingsSectionView(
                title: L10n.Settings.Pane.permissions,
                subtitle: self.subtitle
            ) {
                permissionRow(
                    title: self.permissionTitle,
                    status: model.inputCaptureStatus,
                    action: model.requestInputCapturePermission
                )
            }
        }
    }

    private var permissionTitle: String {
        switch self.model.inputCapturePermission {
        case .accessibility:
            L10n.Permissions.accessibilityLabel
        case .inputMonitoring:
            L10n.Permissions.inputMonitoringLabel
        }
    }

    private var subtitle: String {
        switch self.model.inputCapturePermission {
        case .accessibility:
            L10n.Permissions.accessibilitySectionSubtitle
        case .inputMonitoring:
            L10n.Permissions.inputMonitoringSectionSubtitle
        }
    }

    private func permissionRow(title: String, status: Permission.Status, action: @escaping () -> Void) -> some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.none) {
                Text(title)
                    .font(Typography.Settings.rowTitle)
                    .foregroundColor(Color.Theme.Text.primary)

                HStack(spacing: Spacing.xxs) {
                    Circle()
                        .fill(self.statusColor(for: status))
                        .frame(width: Spacing.unit * 2, height: Spacing.unit * 2)

                    Text(self.statusText(for: status))
                        .font(Typography.Settings.rowTitle)
                        .foregroundColor(Color.Theme.Text.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if status != .granted {
                Button(L10n.Permissions.grantAccessButton, action: action)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func statusText(for status: Permission.Status) -> String {
        switch status {
        case .granted:
            return L10n.Permissions.Status.granted
        case .notGranted:
            return L10n.Permissions.Status.notGranted
        }
    }

    private func statusColor(for status: Permission.Status) -> Color {
        switch status {
        case .granted:
            return Color.Theme.State.success
        case .notGranted:
            return Color.Theme.State.warning
        }
    }
}
