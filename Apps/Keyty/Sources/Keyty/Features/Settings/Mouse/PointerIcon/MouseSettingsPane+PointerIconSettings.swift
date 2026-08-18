//
//  MouseSettingsPane+PointerIconSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

extension MouseSettingsPane {
    var pointerIconSettingsSection: some View {
        let icon = self.model.icon

        return SettingsSectionView {
            SettingsControlRow(title: L10n.Mouse.enabled, subtitle: L10n.Mouse.pointerIconEnabledSubtitle) {
                Toggle("", isOn: self.binding(get: { icon.enabled }, set: { icon.enabled = $0 }))
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.enabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.pointerIconAlwaysVisibleLabel, subtitle: L10n.Mouse.pointerIconAlwaysVisibleSubtitle) {
                Toggle("", isOn: self.binding(get: { icon.alwaysVisible }, set: { icon.alwaysVisible = $0 }))
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.pointerIconAlwaysVisibleLabel)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .disabled(!icon.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.pointerIconAnchorLabel, subtitle: L10n.Mouse.pointerIconAnchorSubtitle) {
                Picker("", selection: self.binding(get: { icon.anchor }, set: { icon.anchor = $0 })) {
                    ForEach(PointerIconAnchor.allCases, id: \.rawValue) { anchor in
                        Text(anchor.label).tag(anchor.rawValue)
                    }
                }
                .labelsHidden()
                .accessibilityLabel(L10n.Mouse.pointerIconAnchorLabel)
                .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                .disabled(!icon.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.pointerIconOffsetLabel, subtitle: L10n.Mouse.pointerIconOffsetSubtitle) {
                Slider(value: self.binding(get: { icon.offset }, set: { icon.offset = $0 }), in: 0...80)
                    .frame(width: Spacing.grid(42))
                    .accessibilityLabel(L10n.Mouse.pointerIconOffsetLabel)
                    .disabled(!icon.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.iconSizeLabel, subtitle: L10n.Mouse.iconSizeSubtitle) {
                Slider(value: self.binding(get: { icon.sizeIndex }, set: { icon.sizeIndex = $0 }), in: 0...9, step: 1)
                    .frame(width: Spacing.grid(42))
                    .accessibilityLabel(L10n.Mouse.iconSizeLabel)
                    .disabled(!icon.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.iconBackgroundLabel, subtitle: L10n.Mouse.iconBackgroundSubtitle) {
                self.iconBackgroundColorControls
                    .disabled(!icon.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.iconTintLabel, subtitle: L10n.Mouse.iconTintSubtitle) {
                self.iconTintColorControls
                    .disabled(!icon.enabled)
            }
        }
    }

    private var iconBackgroundColorControls: some View {
        return self.iconColorControls(
            selection: Binding(
                get: { self.model.icon.backgroundColorSelectionID },
                set: { selectionID in
                    if selectionID == MouseSettingsPaneViewModel.customIconBackgroundColorSelectionID {
                        self.model.icon.beginChoosingCustomBackgroundColor()
                        self.iconBackgroundColorPanel.present(initialColor: self.model.icon.backgroundColor)
                        return
                    }

                    self.model.icon.selectBackgroundColor(with: selectionID)
                }
            ),
            sections: MouseSettingsPaneViewModel.ColorPreset.iconBackgroundColorSections,
            currentColor: self.model.icon.backgroundColor,
            customSelectionID: MouseSettingsPaneViewModel.customIconBackgroundColorSelectionID,
            accessibilityLabel: L10n.Mouse.iconBackgroundLabel
        )
    }

    private var iconTintColorControls: some View {
        return self.iconColorControls(
            selection: Binding(
                get: { self.model.icon.tintColorSelectionID },
                set: { selectionID in
                    if selectionID == MouseSettingsPaneViewModel.customIconTintColorSelectionID {
                        self.model.icon.beginChoosingCustomTintColor()
                        self.iconTintColorPanel.present(initialColor: self.model.icon.tintColor)
                        return
                    }

                    self.model.icon.selectTintColor(with: selectionID)
                }
            ),
            sections: MouseSettingsPaneViewModel.ColorPreset.iconTintColorSections,
            currentColor: self.model.icon.tintColor,
            customSelectionID: MouseSettingsPaneViewModel.customIconTintColorSelectionID,
            accessibilityLabel: L10n.Mouse.iconTintLabel
        )
    }

    private func iconColorControls(
        selection: Binding<String>,
        sections: [[MouseSettingsPaneViewModel.ColorPreset]],
        currentColor: NSColor,
        customSelectionID: String,
        accessibilityLabel: String
    ) -> some View {
        Picker("", selection: selection) {
            ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                if index > 0 {
                    Divider()
                }

                ForEach(section) { preset in
                    self.colorMenuItem(
                        title: preset.title,
                        swatchColor: preset.color,
                        tag: preset.color.hexString
                    )
                }
            }

            Divider()

            self.colorMenuItem(
                title: L10n.Mouse.chooseColor,
                swatchColor: currentColor,
                tag: customSelectionID
            )
        }
        .labelsHidden()
        .accessibilityLabel(accessibilityLabel)
        .pickerStyle(.menu)
        .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
    }
}
