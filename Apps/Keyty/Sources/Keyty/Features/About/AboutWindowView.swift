//
//  AboutWindowView.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

struct AboutWindowView: View {
    @ObservedObject var viewModel: AboutWindowViewModel

    private let sidebarWidth = Spacing.grid(50)
    private let detailMinimumWidth = Size.Window.about.width - Spacing.grid(50)

    var body: some View {
        NavigationView {
            self.sidebar
            self.detail
        }
        .ignoresSafeArea(edges: .top)
        .frame(width: Size.Window.about.width, height: Size.Window.about.height)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: Spacing.none) {
            self.sidebarHeaderRow
                .padding(.horizontal, Spacing.xs)

            Spacer(minLength: Spacing.xs)

            List(selection: self.selectedTabBinding) {
                ForEach(AboutWindowViewModel.Tab.allCases) { tab in
                    self.sidebarRow(for: tab)
                        .tag(tab)
                }
            }
            .listStyle(SidebarListStyle())
        }
        .frame(width: self.sidebarWidth)
        .background(SplitViewItemSidebarConfiguration(width: self.sidebarWidth))
    }

    private var sidebarHeaderRow: some View {
        AppSidebarHeaderView()
    }

    private var detail: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                ScrollView {
                    Color.clear
                        .frame(height: 0)
                        .id(Self.topAnchorID)

                    LazyVStack(alignment: .leading, spacing: Spacing.grid(7)) {
                        ForEach(self.viewModel.selectedSections) { section in
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                if !self.shouldHideSectionTitle(section.title) {
                                    Text(section.title)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(Color.Theme.Text.primary)
                                }

                                if !section.subtitle.isEmpty {
                                    Text(section.subtitle)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(Color.Theme.Text.secondary)
                                }

                                if !section.links.isEmpty {
                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        ForEach(section.links) { link in
                                            HStack(spacing: Spacing.xs) {
                                                Text("\(link.title):")
                                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                                    .foregroundColor(Color.Theme.Text.secondary)

                                                Link(destination: link.url) {
                                                    Text(link.url.absoluteString)
                                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                                        .foregroundColor(Color.Theme.About.linkText)
                                                        .underline()
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }

                                if !section.listItems.isEmpty {
                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        ForEach(section.listItems) { item in
                                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                                Text(item.title)
                                                    .font(self.listItemTitleFont)
                                                    .foregroundColor(Color.Theme.Text.primary)

                                                if !item.subtitle.isEmpty {
                                                    Text(item.subtitle)
                                                        .font(.system(size: 11, weight: .regular, design: .rounded))
                                                        .foregroundColor(Color.Theme.Text.secondary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                        }
                                    }
                                }

                                if !section.body.isEmpty {
                                    Self.AboutBodyText(text: section.body)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Size.Settings.headerHeight + Spacing.grid(4))
                    .padding(.bottom, Spacing.grid(4))
                }
                .onChange(of: self.viewModel.selectedTab) { _ in
                    proxy.scrollTo(Self.topAnchorID, anchor: .top)
                }
            }

            self.detailHeader
        }
        .frame(minWidth: self.detailMinimumWidth, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.Theme.Surface.detailBackground)
        .ignoresSafeArea(edges: .top)
    }

    private var selectedTabBinding: Binding<AboutWindowViewModel.Tab?> {
        Binding(
            get: { self.viewModel.selectedTab },
            set: { tab in
                guard let tab else { return }
                self.viewModel.selectedTab = tab
            }
        )
    }
}

private extension AboutWindowView {
    private var listItemTitleFont: Font {
        if self.viewModel.selectedTab == .contributors {
            return .system(size: 12, weight: .regular, design: .rounded)
        }

        return .system(size: 12, weight: .semibold, design: .rounded)
    }

    private func sidebarRow(for tab: AboutWindowViewModel.Tab) -> some View {
        let isSelected = self.viewModel.selectedTab == tab

        return HStack(spacing: Spacing.xs) {
            self.sidebarIcon(for: tab, isSelected: isSelected)

            Text(tab.title)
                .foregroundColor(isSelected ? Color.Theme.Text.sidebarItemSelected : Color.Theme.Text.sidebarItem)
        }
    }

    private func sidebarIcon(for tab: AboutWindowViewModel.Tab, isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
            .fill(tab.iconGradient)
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
                Image(systemName: tab.systemImageName)
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

    private func shouldHideSectionTitle(_ title: String) -> Bool {
        title == self.viewModel.selectedTab.title
    }

    private var detailHeader: some View {
        VStack(spacing: Spacing.none) {
            ZStack {
                VisualEffectView(material: .headerView)

                HStack(alignment: .center, spacing: Spacing.sm) {
                    Text(self.viewModel.selectedTab.title)
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

private extension AboutWindowView {
    static let topAnchorID = "about.scroll.top"

    struct AboutBodyText: View {
        let text: String

        var body: some View {
            LazyVStack(alignment: .leading, spacing: Spacing.none) {
                ForEach(Array(self.text.components(separatedBy: .newlines).enumerated()), id: \.offset) { _, line in
                    if line.isEmpty {
                        Spacer()
                            .frame(height: Spacing.xs)
                    } else {
                        Text(line)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(Color.Theme.Text.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
