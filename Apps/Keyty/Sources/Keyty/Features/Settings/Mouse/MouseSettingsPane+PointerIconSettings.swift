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
        SettingsSectionView {
            SettingsControlRow(title: L10n.Mouse.enabled, subtitle: L10n.Mouse.pointerIconEnabledSubtitle) {
                Toggle("", isOn: self.$model.iconEnabled)
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.enabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.pointerIconAlwaysVisibleLabel, subtitle: L10n.Mouse.pointerIconAlwaysVisibleSubtitle) {
                Toggle("", isOn: self.$model.iconAlwaysVisible)
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.pointerIconAlwaysVisibleLabel)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .disabled(!self.model.iconEnabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.pointerIconAnchorLabel, subtitle: L10n.Mouse.pointerIconAnchorSubtitle) {
                Picker("", selection: self.$model.iconAnchor) {
                    ForEach(PointerIconAnchor.allCases, id: \.rawValue) { anchor in
                        Text(anchor.label).tag(anchor.rawValue)
                    }
                }
                .labelsHidden()
                .accessibilityLabel(L10n.Mouse.pointerIconAnchorLabel)
                .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                .disabled(!self.model.iconEnabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.pointerIconOffsetLabel, subtitle: L10n.Mouse.pointerIconOffsetSubtitle) {
                Slider(value: self.$model.iconOffset, in: 0...80)
                    .frame(width: Spacing.grid(42))
                    .accessibilityLabel(L10n.Mouse.pointerIconOffsetLabel)
                    .disabled(!self.model.iconEnabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.iconSizeLabel, subtitle: L10n.Mouse.iconSizeSubtitle) {
                Slider(value: self.$model.iconSizeIndex, in: 0...9, step: 1)
                    .frame(width: Spacing.grid(42))
                    .accessibilityLabel(L10n.Mouse.iconSizeLabel)
                    .disabled(!self.model.iconEnabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.iconBackgroundLabel, subtitle: L10n.Mouse.iconBackgroundSubtitle) {
                self.iconBackgroundColorControls
                    .disabled(!self.model.iconEnabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.iconTintLabel, subtitle: L10n.Mouse.iconTintSubtitle) {
                self.iconTintColorControls
                    .disabled(!self.model.iconEnabled)
            }
        }
    }

    private var iconBackgroundColorControls: some View {
        self.iconColorControls(
            selection: Binding(
                get: { self.model.iconBackgroundColorSelectionID },
                set: { selectionID in
                    if selectionID == MouseSettingsPaneViewModel.customIconBackgroundColorSelectionID {
                        self.model.beginChoosingCustomIconBackgroundColor()
                        self.iconBackgroundColorPanel.present(initialColor: self.model.iconBackgroundColor)
                        return
                    }

                    self.model.selectIconBackgroundColor(with: selectionID)
                }
            ),
            sections: MouseSettingsPaneViewModel.ColorPreset.iconBackgroundColorSections,
            currentColor: self.model.iconBackgroundColor,
            customSelectionID: MouseSettingsPaneViewModel.customIconBackgroundColorSelectionID,
            accessibilityLabel: L10n.Mouse.iconBackgroundLabel
        )
    }

    private var iconTintColorControls: some View {
        self.iconColorControls(
            selection: Binding(
                get: { self.model.iconTintColorSelectionID },
                set: { selectionID in
                    if selectionID == MouseSettingsPaneViewModel.customIconTintColorSelectionID {
                        self.model.beginChoosingCustomIconTintColor()
                        self.iconTintColorPanel.present(initialColor: self.model.iconTintColor)
                        return
                    }

                    self.model.selectIconTintColor(with: selectionID)
                }
            ),
            sections: MouseSettingsPaneViewModel.ColorPreset.iconTintColorSections,
            currentColor: self.model.iconTintColor,
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
