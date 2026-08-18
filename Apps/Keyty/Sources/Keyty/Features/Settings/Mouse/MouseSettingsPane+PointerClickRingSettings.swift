//
//  MouseSettingsPane+PointerClickRingSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

extension MouseSettingsPane {
    var pointerClickRingSettingsSection: some View {
        SettingsSectionView {
            SettingsControlRow(title: L10n.Mouse.enabled, subtitle: L10n.Mouse.clickRingEnabledSubtitle) {
                Toggle("", isOn: self.$model.clickRingEnabled)
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.enabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringShapeLabel, subtitle: L10n.Mouse.clickRingShapeSubtitle) {
                Picker("", selection: self.$model.clickRingShape) {
                    ForEach(PointerRingShape.allCases) { shape in
                        Text(shape.label).tag(shape)
                    }
                }
                .labelsHidden()
                .accessibilityLabel(L10n.Mouse.ringShapeLabel)
                .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                .disabled(!self.model.clickRingEnabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringColorLabel, subtitle: L10n.Mouse.clickRingColorSubtitle) {
                self.clickRingColorControls
                    .disabled(!self.model.clickRingEnabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringSizeLabel, subtitle: L10n.Mouse.clickRingSizeSubtitle) {
                Slider(
                    value: self.$model.clickRingSize,
                    in: MouseSettingsPaneViewModel.ringSizeRange,
                    step: MouseSettingsPaneViewModel.ringSizeStep
                )
                .frame(width: Spacing.grid(42))
                .accessibilityLabel(L10n.Mouse.ringSizeLabel)
                .disabled(!self.model.clickRingEnabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringThicknessLabel, subtitle: L10n.Mouse.clickRingThicknessSubtitle) {
                Slider(
                    value: self.$model.clickRingThickness,
                    in: MouseSettingsPaneViewModel.ringThicknessRange,
                    step: MouseSettingsPaneViewModel.ringThicknessStep
                )
                .frame(width: Spacing.grid(42))
                .accessibilityLabel(L10n.Mouse.ringThicknessLabel)
                .disabled(!self.model.clickRingEnabled)
            }
        }
    }

    private var clickRingColorControls: some View {
        Picker(
            "",
            selection: Binding(
                get: { self.model.clickRingColorSelectionID },
                set: { selectionID in
                    if selectionID == MouseSettingsPaneViewModel.customRingColorSelectionID {
                        self.model.beginChoosingCustomClickRingColor()
                        self.ringColorPanel.present(initialColor: self.model.clickRingColor)
                        return
                    }

                    self.model.selectClickRingColor(with: selectionID)
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
                    swatchColor: self.model.clickRingColor,
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
