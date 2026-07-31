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

    init(
        keyboardVisualizerSettings: KeyboardVisualizerSettings,
        startSettingKeyboardVisualizerPosition: @escaping @MainActor () -> Void = {},
        stopSettingKeyboardVisualizerPosition: @escaping @MainActor () -> Void = {}
    ) {
        _model = StateObject(
            wrappedValue: DisplaysSettingsPaneViewModel(
                keyboardVisualizerSettings: keyboardVisualizerSettings,
                startSettingKeyboardVisualizerPosition: startSettingKeyboardVisualizerPosition,
                stopSettingKeyboardVisualizerPosition: stopSettingKeyboardVisualizerPosition
            )
        )
    }

    var body: some View {
        DisplaysSettingsPane.PreviewCard(
            screens: self.model.screens,
            selectedScreen: self.model.selectedScreen,
            anchor: self.model.selectedAnchor,
            placementMode: self.model.placementMode,
            stackAxis: self.model.stackAxis,
            windowPadding: self.model.windowPadding,
            customPositionX: self.model.customPositionX,
            customPositionY: self.model.customPositionY,
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
                    title: L10n.Displays.placementLabel,
                    subtitle: L10n.Displays.placementSubtitle
                ) {
                    Picker("", selection: self.$model.placementMode) {
                        ForEach(KeyboardVisualizerSettings.PlacementMode.allCases, id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .labelsHidden()
                    .accessibilityLabel(L10n.Displays.placementLabel)
                    .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                }

                Divider()

                if self.model.isCustomPlacement {
                    self.customPlacementControls
                } else {
                    SettingsControlRow(
                        title: L10n.Displays.anchorLabel,
                        subtitle: L10n.Displays.anchorSubtitle
                    ) {
                        KeyboardVisualizerAnchorPicker(
                            selection: self.$model.selectedAnchor,
                            accessibilityLabel: L10n.Displays.anchorLabel
                        )
                    }

                    Divider()

                    SettingsControlRow(
                        title: L10n.Displays.marginLabel,
                        subtitle: L10n.Displays.marginSubtitle
                    ) {
                        SettingsSliderControl(
                            value: self.$model.windowPadding,
                            range: self.model.paddingRange,
                            step: self.model.paddingStep,
                            accessibilityLabel: L10n.Displays.marginLabel
                        )
                    }
                }
            }
        }
    }
}

private extension DisplaysSettingsPane {
    var customPlacementControls: some View {
        SettingsControlRow(
            title: L10n.Displays.CustomPosition.setLabel,
            subtitle: L10n.Displays.CustomPosition.setSubtitle
        ) {
            Button(self.model.isSettingCustomPosition ? L10n.Displays.CustomPosition.stopSettingButton : L10n.Displays.CustomPosition.startSettingButton) {
                self.model.toggleCustomPositionSetting()
            }
            .controlSize(.small)
        }
    }
}
