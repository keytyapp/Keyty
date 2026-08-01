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

    init(model: DisplaysSettingsPaneViewModel) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        Group {
            DisplaysSettingsPane.PreviewCard(
                screens: self.model.screens,
                selectedScreen: self.model.selectedScreen,
                anchor: self.model.selectedAnchor,
                placementMode: self.model.placementMode,
                stackAxis: self.model.stackAxis,
                keyboardScale: self.model.scale,
                windowPadding: self.model.windowPadding,
                customPositionNormalizedX: self.model.customPositionNormalizedX,
                customPositionNormalizedY: self.model.customPositionNormalizedY,
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
                        Picker("", selection: self.anchorSelection) {
                            ForEach(DisplaysSettingsPaneViewModel.PlacementSelection.allCases, id: \.self) { selection in
                                Text(selection.label).tag(selection)
                            }
                        }
                        .labelsHidden()
                        .accessibilityLabel(L10n.Displays.anchorLabel)
                        .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
                    }

                    if self.model.isCustomPlacement {
                        Divider()

                        self.customPlacementControls
                    } else {
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
        .onDisappear {
            self.model.finishCustomPositionSetting()
        }
    }
}

private extension DisplaysSettingsPane {
    var customPlacementControls: some View {
        SettingsControlRow(
            title: L10n.Displays.CustomPosition.label,
            subtitle: L10n.Displays.CustomPosition.setSubtitle
        ) {
            Button(self.model.isSettingCustomPosition ? L10n.Displays.CustomPosition.stopSettingButton : L10n.Displays.CustomPosition.startSettingButton) {
                self.model.toggleCustomPositionSetting()
            }
            .controlSize(.regular)
            .frame(width: Size.Control.settingsPickerWidth, alignment: .trailing)
        }
    }

    var anchorSelection: Binding<DisplaysSettingsPaneViewModel.PlacementSelection> {
        Binding(
            get: { self.model.anchorSelection },
            set: { self.model.anchorSelection = $0 }
        )
    }
}
