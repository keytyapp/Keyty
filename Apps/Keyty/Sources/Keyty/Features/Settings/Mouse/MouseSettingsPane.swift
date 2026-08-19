//
//  MouseSettingsPane.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

struct MouseSettingsPane: View {
    @StateObject var model: MouseSettingsPaneViewModel
    @State var ringColorPanel = ColorPanel()
    @State var iconBackgroundColorPanel = ColorPanel()
    @State var iconTintColorPanel = ColorPanel()

    init(
        pointerRingVisualizer: PointerRingVisualizer,
        pointerRingSettings: any PointerRingSettingsProtocol,
        pointerRipplesVisualizer: PointerRipplesVisualizer,
        pointerRipplesSettings: any PointerRipplesSettingsProtocol,
        pointerIconSettings: any PointerIconSettingsProtocol
    ) {
        _model = StateObject(wrappedValue: MouseSettingsPaneViewModel(
            ringVisualizer: pointerRingVisualizer,
            ringSettings: pointerRingSettings,
            ripplesVisualizer: pointerRipplesVisualizer,
            ripplesSettings: pointerRipplesSettings,
            iconSettings: pointerIconSettings
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            MouseSettingsPane.PreviewCard(model: self.model)
            
            Spacer(minLength: Spacing.xs)

            self.settingsTabPicker

            SettingsStack {
                switch self.model.selectedSettingsTab {
                case .ring:
                    self.pointerRingSettingsSection
                case .ripples:
                    self.pointerRipplesSettingsSection
                case .icon:
                    self.pointerIconSettingsSection
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var settingsTabPicker: some View {
        HStack(spacing: Spacing.none) {
            ForEach(MouseSettingsPaneViewModel.SettingsTab.allCases, id: \.self) { tab in
                self.settingsTabButton(tab)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(Color.Theme.Surface.cardBackground)
        )
    }

    private func settingsTabButton(_ tab: MouseSettingsPaneViewModel.SettingsTab) -> some View {
        let isSelected = self.model.selectedSettingsTab == tab

        return Button {
            self.model.selectedSettingsTab = tab
        } label: {
            Text(tab.title)
                .font(Typography.Settings.value)
                .foregroundColor(isSelected ? Color.Theme.Text.sidebarItemSelected : Color.Theme.Text.primary)
                .frame(maxWidth: .infinity, minHeight: Size.Control.height)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .fill(isSelected ? Color.Theme.Accent.controlAccent : Color.clear)
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension MouseSettingsPane {
    func binding<Value>(get: @escaping () -> Value, set: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: get, set: set)
    }

    func colorMenuItem(title: String, swatchColor: NSColor, tag: String) -> some View {
        HStack(spacing: Spacing.xs) {
            SwiftUI.Image(nsImage: swatchColor.swatchImage())
            Text(title)
        }
        .tag(tag)
    }
}
