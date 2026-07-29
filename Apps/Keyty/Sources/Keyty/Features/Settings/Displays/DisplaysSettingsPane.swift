//
//  DisplaysSettingsPane.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

struct DisplaysSettingsPane: View {
    @StateObject private var model: DisplaysSettingsPaneViewModel

    init(keyboardVisualizerSettings: KeyboardVisualizerSettings) {
        _model = StateObject(wrappedValue: DisplaysSettingsPaneViewModel(keyboardVisualizerSettings: keyboardVisualizerSettings))
    }

    var body: some View {
        DisplaysSettingsPane.PreviewCard(
            screens: self.model.screens,
            selectedScreen: self.model.selectedScreen,
            anchor: self.model.selectedAnchor,
            stackAxis: self.model.stackAxis,
            windowPadding: self.model.windowPadding,
            onSelectScreen: { screen in
                self.model.selectedScreenID = screen.id
            }
        )
        
        SettingsStack {
            SettingsSectionView {
                SettingsControlRow(
                    title: L10n.Displays.displayLabel,
                    subtitle: L10n.Displays.displaySubtitle
                ) {
                    Picker("", selection: $model.selectedScreenID) {
                        ForEach(model.screens) { screen in
                            Text(screen.displayName).tag(screen.id)
                        }
                    }
                    .labelsHidden()
                    .accessibilityLabel(L10n.Displays.displayLabel)
                    .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                }

                Divider()

                SettingsControlRow(
                    title: L10n.Displays.anchorLabel,
                    subtitle: L10n.Displays.anchorSubtitle
                ) {
                    KeyboardVisualizerAnchorPicker(
                        selection: $model.selectedAnchor,
                        accessibilityLabel: L10n.Displays.anchorLabel
                    )
                }

                Divider()

                SettingsControlRow(
                    title: L10n.Displays.marginLabel,
                    subtitle: L10n.Displays.marginSubtitle
                ) {
                    SettingsSliderControl(
                        value: $model.windowPadding,
                        range: model.paddingRange,
                        step: model.paddingStep,
                        accessibilityLabel: L10n.Displays.marginLabel
                    )
                }
            }
        }
    }
}
