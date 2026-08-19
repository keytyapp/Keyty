//
//  MouseSettingsPane+PointerRipplesSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

extension MouseSettingsPane {
    var pointerRipplesSettingsSection: some View {
        let ripples = self.model.ripples

        return SettingsSectionView {
            SettingsControlRow(title: L10n.Mouse.enabled, subtitle: L10n.Mouse.ripplesEnabledSubtitle) {
                Toggle("", isOn: self.binding(get: { ripples.enabled }, set: { ripples.enabled = $0 }))
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.enabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringShapeLabel, subtitle: L10n.Mouse.ripplesShapeSubtitle) {
                Picker("", selection: self.binding(get: { ripples.shape }, set: { ripples.shape = $0 })) {
                    ForEach(PointerRingShape.allCases) { shape in
                        Text(shape.label).tag(shape)
                    }
                }
                .labelsHidden()
                .accessibilityLabel(L10n.Mouse.ringShapeLabel)
                .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                .disabled(!ripples.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringColorLabel, subtitle: L10n.Mouse.ripplesColorSubtitle) {
                self.ripplesColorControls
                    .disabled(!ripples.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringSizeLabel, subtitle: L10n.Mouse.ripplesSizeSubtitle) {
                Slider(
                    value: self.binding(get: { ripples.size }, set: { ripples.size = $0 }),
                    in: MouseSettingsPaneViewModel.ringSizeRange,
                    step: MouseSettingsPaneViewModel.ringSizeStep
                )
                .frame(width: Spacing.grid(42))
                .accessibilityLabel(L10n.Mouse.ringSizeLabel)
                .disabled(!ripples.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringThicknessLabel, subtitle: L10n.Mouse.ripplesThicknessSubtitle) {
                Slider(
                    value: self.binding(get: { ripples.thickness }, set: { ripples.thickness = $0 }),
                    in: MouseSettingsPaneViewModel.ringThicknessRange,
                    step: MouseSettingsPaneViewModel.ringThicknessStep
                )
                .frame(width: Spacing.grid(42))
                .accessibilityLabel(L10n.Mouse.ringThicknessLabel)
                .disabled(!ripples.enabled)
            }
        }
    }

    private var ripplesColorControls: some View {
        return Picker(
            "",
            selection: Binding(
                get: { self.model.ripples.colorSelectionID },
                set: { selectionID in
                    if selectionID == MouseSettingsPaneViewModel.customRingColorSelectionID {
                        self.model.ripples.beginChoosingCustomColor()
                        self.ringColorPanel.present(initialColor: self.model.ripples.color)
                        return
                    }

                    self.model.ripples.selectColor(with: selectionID)
                }
            )
        ) {
            if let automaticPreset = MouseSettingsPaneViewModel.ColorPreset.ringColorPresets.first {
                self.colorMenuItem(
                    title: automaticPreset.title,
                    swatchColor: automaticPreset.color,
                    tag: automaticPreset.color.hexString
                )
            }

            Section {
                ForEach(Array(MouseSettingsPaneViewModel.ColorPreset.ringColorPresets.dropFirst())) { preset in
                    self.colorMenuItem(
                        title: preset.title,
                        swatchColor: preset.color,
                        tag: preset.color.hexString
                    )
                }
            }

            Section {
                self.colorMenuItem(
                    title: L10n.Mouse.chooseColor,
                    swatchColor: self.model.ripples.color,
                    tag: MouseSettingsPaneViewModel.customRingColorSelectionID
                )
            }
        }
        .labelsHidden()
        .accessibilityLabel(L10n.Mouse.ringColorLabel)
        .pickerStyle(.menu)
        .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
    }
}
