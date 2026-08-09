//
//  SettingsRootView.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

struct SettingsRootView: View {
    let registry: SettingsPaneRegistry
    @ObservedObject var sidebarViewModel: SettingsSidebarViewModel

    private let detailMinimumWidth = Size.Window.settings.width - Size.Settings.sidebarWidth

    var body: some View {
        NavigationView {
            self.sidebar
            self.detail
        }
        .ignoresSafeArea(edges: .top)
        .frame(
            minWidth: Size.Window.settings.width,
            minHeight: Size.Window.settings.height
        )
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: Spacing.none) {
            self.sidebarHeaderRow
                .padding(.horizontal, Spacing.xs)
            
            Spacer(minLength: Spacing.xs)

            List(selection: self.selectedPaneBinding) {
                ForEach(self.registry.entries) { entry in
                    HStack(spacing: Spacing.xs) {
                        self.sidebarRow(for: entry)

                        Spacer(minLength: 0)

                        if let count = self.sidebarViewModel.badgeCount(for: entry.id) {
                            self.countBadge(count)
                        }
                    }
                    .tag(entry.id)
                }
            }
            .listStyle(SidebarListStyle())
        }
        .frame(width: Size.Settings.sidebarWidth)
        .background(SplitViewItemSidebarConfiguration(width: Size.Settings.sidebarWidth))
    }

    private var detail: some View {
        Group {
            if let selectedEntry = self.registry.entry(for: self.sidebarViewModel.selectedPaneID) {
                SettingsDetailContainer(title: selectedEntry.title) {
                    selectedEntry.makeView()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            } else {
                SettingsDetailContainer(title: AppConstants.appName) {
                    EmptyView()
                }
            }
        }
        .frame(minWidth: self.detailMinimumWidth, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea(edges: .top)
    }

    private var sidebarHeaderRow: some View {
        AppSidebarHeaderView()
    }

    private var selectedPaneBinding: Binding<SettingsPaneIdentifier?> {
        Binding(
            get: { self.sidebarViewModel.selectedPaneID },
            set: { identifier in
                guard let identifier else { return }
                self.sidebarViewModel.select(identifier)
            }
        )
    }

    private func countBadge(_ count: Int) -> some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(Typography.Settings.sidebarBadge)
            .foregroundColor(Color.Theme.Brand.white)
            .lineLimit(1)
            .padding(.horizontal, Spacing.xxs)
            .frame(minWidth: Size.Settings.sidebarBadgeMinimumWidth, minHeight: Size.Settings.sidebarBadgeHeight)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.Theme.State.danger)
            )
    }

    private func sidebarRow(for entry: SettingsPaneEntry) -> some View {
        let isSelected = self.sidebarViewModel.selectedPaneID == entry.id

        return HStack(spacing: Spacing.xs) {
            self.sidebarIcon(for: entry, isSelected: isSelected)

            Text(entry.title)
                .foregroundColor(isSelected ? Color.Theme.Text.sidebarItemSelected : Color.Theme.Text.sidebarItem)
        }
    }

    private func sidebarIcon(for entry: SettingsPaneEntry, isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
            .fill(entry.id.sidebarIconGradient)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(
                        isSelected
                        ? Color.Theme.Border.iconBadgeSelected
                        : Color.Theme.Border.iconBadgeUnselected,
                        lineWidth: StrokeWidth.standard
                    )
            )
            .overlay(
                Image(systemName: entry.systemImageName)
                    .font(Typography.Settings.sidebarItemSymbol)
                    .foregroundColor(Color.Theme.Brand.white)
            )
            .frame(width: Spacing.grid(6), height: Spacing.grid(6))
            .shadow(
                color: isSelected ? Color.Theme.Shadow.iconBadgeSelected : Color.Theme.Shadow.iconBadgeUnselected,
                radius: isSelected ? Spacing.xs : Spacing.xxs,
                y: 2
            )
    }
}
