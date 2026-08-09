//
//  AppSidebarHeaderView.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

struct AppSidebarHeaderView: View {
    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: Spacing.grid(16), height: Spacing.grid(16))

            VStack(alignment: .leading, spacing: 0) {
                Text(AppConstants.appName)
                    .font(Typography.Settings.sidebarAppName)
                    .foregroundColor(Color.Theme.Text.primary)

                Text(L10n.Settings.sidebarVersion(
                    Bundle.main.appVersionString,
                    Bundle.main.appBuildString
                ))
                .font(Typography.Settings.sidebarSubtitle)
                .foregroundColor(Color.Theme.Text.secondary)
                .lineLimit(1)
            }
        }
        .allowsHitTesting(false)
    }
}
