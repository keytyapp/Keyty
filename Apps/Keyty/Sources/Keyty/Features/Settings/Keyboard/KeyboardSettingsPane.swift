//
//  KeyboardSettingsPane.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

struct KeyboardSettingsPane: View {
    @StateObject private var model: KeyboardSettingsPaneViewModel
    @State private var legendColorPanel = ColorPanel()

    init(settings: KeyboardVisualizerSettings) {
        self._model = StateObject(wrappedValue: KeyboardSettingsPaneViewModel(settings: settings))
    }

    var body: some View {
        KeyboardSettingsPane.PreviewCard(settings: self.model.previewRenderSettings, identity: self.model.previewIdentity)

        SettingsStack {
            SettingsSectionView(
                title: L10n.KeyboardVisualizer.generalSectionTitle,
                subtitle: L10n.KeyboardVisualizer.generalSectionSubtitle
            ) {
                SettingsControlRow(
                    title: L10n.KeyboardVisualizer.enabledLabel,
                    subtitle: L10n.KeyboardVisualizer.enabledSubtitle
                ) {
                    Toggle("", isOn: self.$model.isEnabled)
                        .labelsHidden()
                        .accessibilityLabel(L10n.KeyboardVisualizer.enabledLabel)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }

                Divider()

                self.stylePicker
                    .disabled(!self.model.isEnabled)

                Divider()

                self.baseThemePicker
                    .disabled(!self.model.isEnabled)
            }

            if self.model.usesCustomThemePalette {
                SettingsSectionView(
                    title: L10n.KeyboardVisualizer.themeSectionTitle,
                    subtitle: L10n.KeyboardVisualizer.themeSectionSubtitle
                ) {
                    self.themePicker(
                        title: L10n.KeyboardVisualizer.groupBackgroundThemeLabel,
                        subtitle: L10n.KeyboardVisualizer.groupBackgroundThemeSubtitle,
                        selection: self.$model.groupBackgroundTheme
                    )
                    
                    Divider()

                    SettingsControlRow(
                        title: L10n.KeyboardVisualizer.legendColorLabel,
                        subtitle: L10n.KeyboardVisualizer.legendColorSubtitle
                    ) {
                        self.legendColorControls
                    }
                    
                    self.themePicker(
                        title: L10n.KeyboardVisualizer.regularThemeLabel,
                        subtitle: L10n.KeyboardVisualizer.regularThemeSubtitle,
                        selection: self.$model.theme
                    )
                    

                    Divider()

                    self.themePicker(
                        title: L10n.KeyboardVisualizer.modifierThemeLabel,
                        subtitle: L10n.KeyboardVisualizer.modifierThemeSubtitle,
                        selection: self.$model.modifierTheme
                    )

                    Divider()

                    self.themePicker(
                        title: L10n.KeyboardVisualizer.specialThemeLabel,
                        subtitle: L10n.KeyboardVisualizer.specialThemeSubtitle,
                        selection: self.$model.specialTheme
                    )

                    Divider()

                    self.themePicker(
                        title: L10n.KeyboardVisualizer.mediaThemeLabel,
                        subtitle: L10n.KeyboardVisualizer.mediaThemeSubtitle,
                        selection: self.$model.mediaTheme
                    )

                    Divider()

                    self.themePicker(
                        title: L10n.KeyboardVisualizer.mouseThemeLabel,
                        subtitle: L10n.KeyboardVisualizer.mouseThemeSubtitle,
                        selection: self.$model.mouseTheme
                    )
                }
                .disabled(!self.model.isEnabled)
            }

            SettingsSectionView(
                title: L10n.KeyboardVisualizer.filterSectionTitle,
                subtitle: L10n.KeyboardVisualizer.filterSectionSubtitle
            ) {
                SettingsControlRow(
                    title: L10n.KeyboardVisualizer.onlyShowModifiedKeystrokesLabel,
                    subtitle: L10n.KeyboardVisualizer.onlyShowModifiedKeystrokesSubtitle
                ) {
                    Toggle("", isOn: self.$model.onlyShowModifiedKeystrokes)
                        .labelsHidden()
                        .accessibilityLabel(L10n.KeyboardVisualizer.onlyShowModifiedKeystrokesLabel)
                        .toggleStyle(.switch)
                }

                Divider()

                SettingsControlRow(
                    title: L10n.KeyboardVisualizer.showSpecialKeysLabel,
                    subtitle: L10n.KeyboardVisualizer.showSpecialKeysSubtitle
                ) {
                    Toggle("", isOn: self.$model.showSpecialKeys)
                        .labelsHidden()
                        .accessibilityLabel(L10n.KeyboardVisualizer.showSpecialKeysLabel)
                        .toggleStyle(.switch)
                }

                Divider()

                SettingsControlRow(
                    title: L10n.KeyboardVisualizer.showMediaKeyButtonsLabel,
                    subtitle: L10n.KeyboardVisualizer.showMediaKeyButtonsSubtitle
                ) {
                    Toggle("", isOn: self.$model.showMediaKeyButtons)
                        .labelsHidden()
                        .accessibilityLabel(L10n.KeyboardVisualizer.showMediaKeyButtonsLabel)
                        .toggleStyle(.switch)
                }

                Divider()

                SettingsControlRow(
                    title: L10n.KeyboardVisualizer.showMouseEventsLabel,
                    subtitle: L10n.KeyboardVisualizer.showMouseEventsSubtitle
                ) {
                    Toggle("", isOn: self.$model.showMouseEvents)
                        .labelsHidden()
                        .accessibilityLabel(L10n.KeyboardVisualizer.showMouseEventsLabel)
                        .toggleStyle(.switch)
                }
            }
            .disabled(!self.model.isEnabled)

            SettingsSectionView(
                title: L10n.KeyboardVisualizer.layoutSectionTitle,
                subtitle: L10n.KeyboardVisualizer.layoutSectionSubtitle
            ) {
                SettingsControlRow(title: L10n.KeyboardVisualizer.anchorLabel, subtitle: L10n.KeyboardVisualizer.anchorSubtitle) {
                    KeyboardVisualizerAnchorPicker(
                        selection: self.$model.anchor,
                        accessibilityLabel: L10n.KeyboardVisualizer.anchorLabel
                    )
                }

                Divider()

                SettingsControlRow(title: L10n.KeyboardVisualizer.sizeLabel, subtitle: L10n.KeyboardVisualizer.sizeSubtitle) {
                    SettingsSliderControl(
                        value: self.$model.scale,
                        range: self.model.scaleRange,
                        step: self.model.scaleStep,
                        accessibilityLabel: L10n.KeyboardVisualizer.sizeLabel
                    )
                }
            }
            .disabled(!self.model.isEnabled)

            SettingsSectionView(
                title: L10n.KeyboardVisualizer.historySectionTitle,
                subtitle: L10n.KeyboardVisualizer.historySectionSubtitle
            ) {
                SettingsControlRow(title: L10n.KeyboardVisualizer.maxCountLabel, subtitle: L10n.KeyboardVisualizer.maxCountSubtitle) {
                    HStack(spacing: Spacing.sm) {
                        Text("\(self.model.maxCount)")
                            .font(Typography.Settings.value)
                            .foregroundColor(Color.Theme.Text.primary)
                            .frame(width: Spacing.grid(8))

                        Stepper("", value: self.$model.maxCount, in: self.model.maxCountRange)
                            .labelsHidden()
                            .accessibilityLabel(L10n.KeyboardVisualizer.maxCountLabel)
                    }
                }

                Divider()

                SettingsControlRow(title: L10n.KeyboardVisualizer.axisLabel, subtitle: L10n.KeyboardVisualizer.axisSubtitle) {
                    self.axisPicker
                }
            }
            .disabled(!self.model.isEnabled)

            SettingsSectionView(
                title: L10n.KeyboardVisualizer.timingSectionTitle,
                subtitle: L10n.KeyboardVisualizer.timingSectionSubtitle
            ) {
                SettingsControlRow(title: L10n.KeyboardVisualizer.lingerTimeLabel, subtitle: L10n.KeyboardVisualizer.lingerTimeSubtitle) {
                    SettingsSliderControl(
                        value: self.$model.fadeDelay,
                        range: 0.2...5,
                        step: 0.2,
                        edgeLabels: SettingsSliderEdgeLabels(
                            leading: L10n.KeyboardVisualizer.LingerTime.short,
                            trailing: L10n.KeyboardVisualizer.LingerTime.long
                        ),
                        accessibilityLabel: L10n.KeyboardVisualizer.lingerTimeLabel
                    )
                }

                Divider()

                SettingsControlRow(title: L10n.KeyboardVisualizer.fadeDurationLabel, subtitle: L10n.KeyboardVisualizer.fadeDurationSubtitle) {
                    SettingsSliderControl(
                        value: self.$model.fadeDuration,
                        range: 0...1,
                        step: 0.05,
                        edgeLabels: SettingsSliderEdgeLabels(
                            leading: L10n.KeyboardVisualizer.FadeDuration.fast,
                            trailing: L10n.KeyboardVisualizer.FadeDuration.slow
                        ),
                        accessibilityLabel: L10n.KeyboardVisualizer.fadeDurationLabel
                    )
                }
            }
            .disabled(!self.model.isEnabled)
        }
    }

    private var baseThemePicker: some View {
        SettingsControlRow(
            title: L10n.KeyboardVisualizer.themeLabel,
            subtitle: L10n.KeyboardVisualizer.themeSubtitle
        ) {
            Picker("", selection: self.$model.themeSelection) {
                ForEach(Array(KeyboardVisualizerTheme.pickerSections.enumerated()), id: \.offset) { index, section in
                    if index > 0 {
                        Divider()
                    }

                    ForEach(section, id: \.self) { theme in
                        self.themeRow(theme).tag(KeyboardSettingsPaneViewModel.ThemeSelection.theme(theme))
                    }
                }

                Divider()

                Text(L10n.KeyboardVisualizer.themeCustom)
                    .tag(KeyboardSettingsPaneViewModel.ThemeSelection.custom)
            }
            .labelsHidden()
            .accessibilityLabel(L10n.KeyboardVisualizer.themeLabel)
            .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
        }
    }

    private var legendColorControls: some View {
        Picker(
            "",
            selection: Binding(
                get: { self.model.legendColorSelectionID },
                set: { selectionID in
                    if selectionID == KeyboardSettingsPaneViewModel.customLegendColorSelectionID {
                        self.model.beginChoosingCustomLegendColor()
                        self.legendColorPanel.present(initialColor: self.model.customLegendColor)
                        return
                    }

                    self.model.selectLegendColor(with: selectionID)
                }
            )
        ) {
            self.colorMenuItem(
                title: L10n.KeyboardVisualizer.Color.automatic,
                swatchColor: self.model.theme.displayColor,
                tag: KeyboardSettingsPaneViewModel.ColorPreset.automaticSelectionID
            )

            Divider()

            ForEach(KeyboardSettingsPaneViewModel.ColorPreset.presets) { preset in
                self.colorMenuItem(
                    title: preset.title,
                    swatchColor: preset.color,
                    tag: preset.color.hexString
                )
            }

            Divider()

            self.colorMenuItem(
                title: L10n.KeyboardVisualizer.chooseColor,
                swatchColor: self.model.customLegendColor,
                tag: KeyboardSettingsPaneViewModel.customLegendColorSelectionID
            )
        }
        .labelsHidden()
        .accessibilityLabel(L10n.KeyboardVisualizer.legendColorLabel)
        .pickerStyle(.menu)
        .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
        .onAppear {
            self.legendColorPanel.onColorChange = { color in
                self.model.applyCustomLegendColor(color)
            }
        }
    }

    private func themePicker(
        title: String,
        subtitle: String,
        selection: Binding<KeyboardVisualizerTheme>
    ) -> some View {
        SettingsControlRow(title: title, subtitle: subtitle) {
            Picker("", selection: selection) {
                ForEach(Array(KeyboardVisualizerTheme.pickerSections.enumerated()), id: \.offset) { index, section in
                    if index > 0 {
                        Divider()
                    }

                    ForEach(section, id: \.self) { theme in
                        self.themeRow(theme).tag(theme)
                    }
                }
            }
            .labelsHidden()
            .accessibilityLabel(title)
            .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
        }
    }

    private func themeRow(_ theme: KeyboardVisualizerTheme) -> some View {
        HStack(spacing: Spacing.none) {
            SwiftUI.Image(nsImage: theme.displayColor.swatchImage(trailingPadding: Spacing.xxs))
            Text(theme.title)
        }
    }

    private func colorMenuItem(title: String, swatchColor: NSColor, tag: String) -> some View {
        HStack(spacing: Spacing.xs) {
            SwiftUI.Image(nsImage: swatchColor.swatchImage())
            Text(title)
        }
        .tag(tag)
    }

    private var stylePicker: some View {
        SettingsControlRow(title: L10n.KeyboardVisualizer.styleLabel, subtitle: L10n.KeyboardVisualizer.styleSubtitle) {
            Picker("", selection: self.$model.style) {
                ForEach(KeycapStyle.allCases, id: \.self) { style in
                    Text(style.title).tag(style)
                }
            }
            .labelsHidden()
            .accessibilityLabel(L10n.KeyboardVisualizer.styleLabel)
            .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
        }
    }

    private var axisPicker: some View {
        Picker("", selection: self.$model.stackAxis) {
            Text(L10n.KeyboardVisualizer.Axis.vertical)
                .tag(KeyboardVisualizerStackAxis.vertical)
            Text(L10n.KeyboardVisualizer.Axis.horizontal)
                .tag(KeyboardVisualizerStackAxis.horizontal)
        }
        .labelsHidden()
        .accessibilityLabel(L10n.KeyboardVisualizer.axisLabel)
        .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
    }

}
