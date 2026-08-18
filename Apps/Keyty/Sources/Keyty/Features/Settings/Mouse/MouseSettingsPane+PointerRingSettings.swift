//
//  MouseSettingsPane+PointerRingSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

extension MouseSettingsPane {
    var pointerRingSettingsSection: some View {
        let ring = self.model.ring

        return SettingsSectionView {
            SettingsControlRow(title: L10n.Mouse.enabled, subtitle: L10n.Mouse.enabledSubtitle) {
                Toggle("", isOn: self.binding(get: { ring.enabled }, set: { ring.enabled = $0 }))
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.enabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.alwaysVisibleLabel, subtitle: L10n.Mouse.alwaysVisibleSubtitle) {
                Toggle("", isOn: self.binding(get: { ring.alwaysVisible }, set: { ring.alwaysVisible = $0 }))
                    .labelsHidden()
                    .accessibilityLabel(L10n.Mouse.alwaysVisibleLabel)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .disabled(!ring.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringShapeLabel, subtitle: L10n.Mouse.ringShapeSubtitle) {
                Picker("", selection: self.binding(get: { ring.shape }, set: { ring.shape = $0 })) {
                    ForEach(PointerRingShape.allCases) { shape in
                        Text(shape.label).tag(shape)
                    }
                }
                .labelsHidden()
                .accessibilityLabel(L10n.Mouse.ringShapeLabel)
                .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                .disabled(!ring.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringColorLabel, subtitle: L10n.Mouse.ringColorSubtitle) {
                self.ringColorControls
                    .disabled(!ring.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringSizeLabel, subtitle: L10n.Mouse.ringSizeSubtitle) {
                Slider(
                    value: self.binding(get: { ring.size }, set: { ring.size = $0 }),
                    in: MouseSettingsPaneViewModel.ringSizeRange,
                    step: MouseSettingsPaneViewModel.ringSizeStep
                )
                    .frame(width: Spacing.grid(42))
                    .accessibilityLabel(L10n.Mouse.ringSizeLabel)
                    .disabled(!ring.enabled)
            }

            Divider()

            SettingsControlRow(title: L10n.Mouse.ringThicknessLabel, subtitle: L10n.Mouse.ringThicknessSubtitle) {
                Slider(
                    value: self.binding(get: { ring.thickness }, set: { ring.thickness = $0 }),
                    in: MouseSettingsPaneViewModel.ringThicknessRange,
                    step: MouseSettingsPaneViewModel.ringThicknessStep
                )
                    .frame(width: Spacing.grid(42))
                    .accessibilityLabel(L10n.Mouse.ringThicknessLabel)
                    .disabled(!ring.enabled)
            }
        }
    }

    private var ringColorControls: some View {
        return Picker(
            "",
            selection: Binding(
                get: { self.model.ring.colorSelectionID },
                set: { selectionID in
                    if selectionID == MouseSettingsPaneViewModel.customRingColorSelectionID {
                        self.model.ring.beginChoosingCustomColor()
                        self.ringColorPanel.present(initialColor: self.model.ring.color)
                        return
                    }

                    self.model.ring.selectColor(with: selectionID)
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
                    swatchColor: self.model.ring.color,
                    tag: MouseSettingsPaneViewModel.customRingColorSelectionID
                )
            }
        }
        .labelsHidden()
        .accessibilityLabel(L10n.Mouse.ringColorLabel)
        .pickerStyle(.menu)
        .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
        .onAppear {
            self.ringColorPanel.onColorChange = { color in
                self.model.ring.applyCustomColor(color)
            }
            self.iconBackgroundColorPanel.onColorChange = { color in
                self.model.icon.applyCustomBackgroundColor(color)
            }
            self.iconTintColorPanel.onColorChange = { color in
                self.model.icon.applyCustomTintColor(color)
            }
        }
    }
}
