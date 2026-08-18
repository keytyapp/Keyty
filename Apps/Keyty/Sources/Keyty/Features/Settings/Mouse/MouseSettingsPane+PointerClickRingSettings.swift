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
        let clickRing = self.model.clickRing

        return SettingsSectionView {
            SettingsControlRow(title: L10n.Mouse.enabled, subtitle: L10n.Mouse.clickRingEnabledSubtitle) {
                Toggle("", isOn: self.binding(get: { clickRing.enabled }, set: { clickRing.enabled = $0 }))
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.enabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringShapeLabel, subtitle: L10n.Mouse.clickRingShapeSubtitle) {
                Picker("", selection: self.binding(get: { clickRing.shape }, set: { clickRing.shape = $0 })) {
                    ForEach(PointerRingShape.allCases) { shape in
                        Text(shape.label).tag(shape)
                    }
                }
                .labelsHidden()
                .accessibilityLabel(L10n.Mouse.ringShapeLabel)
                .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                .disabled(!clickRing.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringColorLabel, subtitle: L10n.Mouse.clickRingColorSubtitle) {
                self.clickRingColorControls
                    .disabled(!clickRing.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringSizeLabel, subtitle: L10n.Mouse.clickRingSizeSubtitle) {
                Slider(
                    value: self.binding(get: { clickRing.size }, set: { clickRing.size = $0 }),
                    in: MouseSettingsPaneViewModel.ringSizeRange,
                    step: MouseSettingsPaneViewModel.ringSizeStep
                )
                .frame(width: Spacing.grid(42))
                .accessibilityLabel(L10n.Mouse.ringSizeLabel)
                .disabled(!clickRing.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringThicknessLabel, subtitle: L10n.Mouse.clickRingThicknessSubtitle) {
                Slider(
                    value: self.binding(get: { clickRing.thickness }, set: { clickRing.thickness = $0 }),
                    in: MouseSettingsPaneViewModel.ringThicknessRange,
                    step: MouseSettingsPaneViewModel.ringThicknessStep
                )
                .frame(width: Spacing.grid(42))
                .accessibilityLabel(L10n.Mouse.ringThicknessLabel)
                .disabled(!clickRing.enabled)
            }
        }
    }

    private var clickRingColorControls: some View {
        return Picker(
            "",
            selection: Binding(
                get: { self.model.clickRing.colorSelectionID },
                set: { selectionID in
                    if selectionID == MouseSettingsPaneViewModel.customRingColorSelectionID {
                        self.model.clickRing.beginChoosingCustomColor()
                        self.ringColorPanel.present(initialColor: self.model.clickRing.color)
                        return
                    }

                    self.model.clickRing.selectColor(with: selectionID)
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
                    swatchColor: self.model.clickRing.color,
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
