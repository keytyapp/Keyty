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
        startSettingKeyboardVisualizerPosition: @escaping @MainActor (@escaping KeyboardVisualizerPlacementWindowController.PlacementChangeHandler) -> Void = { _ in },
        stopSettingKeyboardVisualizerPosition: @escaping @MainActor () -> KeyboardVisualizerPlacementWindowController.Placement? = { nil }
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
        Group {
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
                        title: L10n.Displays.anchorLabel,
                        subtitle: L10n.Displays.anchorSubtitle
                    ) {
                        Picker("", selection: self.anchorSelection) {
                            ForEach(DisplaysAnchorSelection.allCases, id: \.self) { selection in
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

    var anchorSelection: Binding<DisplaysAnchorSelection> {
        Binding(
            get: { self.model.anchorSelection },
            set: { self.model.anchorSelection = $0 }
        )
    }
}
