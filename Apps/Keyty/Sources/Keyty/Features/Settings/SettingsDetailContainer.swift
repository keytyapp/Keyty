//
//  SettingsDetailContainer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

struct SettingsDetailContainer<Content: View>: View {
    let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    self.content
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Size.Settings.headerHeight + Spacing.lg)
                .padding(.bottom, Spacing.xxl)
            }

            self.paneHeader
        }
        .background(Color.Theme.Surface.detailBackground)
    }
}

private extension SettingsDetailContainer {
    var paneHeader: some View {
        VStack(spacing: Spacing.none) {
            ZStack {
                VisualEffectView(material: .headerView)

                HStack(alignment: .center, spacing: Spacing.sm) {
                    Text(self.title)
                        .font(Typography.Settings.paneTitle)
                        .foregroundColor(Color.Theme.Text.primary)

                    Spacer(minLength: Spacing.md)
                }
                .padding(.horizontal, Spacing.lg)
            }
            .frame(height: Size.Settings.headerHeight)

            Rectangle()
                .fill(Color.Theme.Border.headerSeparator)
                .frame(height: 1)
        }
    }
}
