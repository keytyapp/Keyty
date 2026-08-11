//
//  SettingsPaneRegistry.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Sparkle
import SwiftUI

struct SettingsPaneEntry: Identifiable {
    let id: SettingsPaneIdentifier
    let title: String
    let systemImageName: String
    let makeView: () -> AnyView
}

@MainActor
struct SettingsPaneRegistry {
    let entries: [SettingsPaneEntry]

    init(context: SettingsContext, displaysViewModel: DisplaysSettingsPaneViewModel) {
        self.entries = [
            SettingsPaneEntry(
                id: .general,
                title: SettingsPaneIdentifier.general.label,
                systemImageName: SettingsPaneIdentifier.general.sfSymbolName,
                makeView: {
                    AnyView(
                        GeneralSettingsPane(
                            shortcutManager: context.shortcutManager,
                            appSettings: context.appSettings,
                            onResetAllSettingsToDefaults: {
                                context.resetAllSettingsToDefaults()
                            }
                        )
                    )
                }
            ),
            SettingsPaneEntry(
                id: .keyboard,
                title: SettingsPaneIdentifier.keyboard.label,
                systemImageName: SettingsPaneIdentifier.keyboard.sfSymbolName,
                makeView: {
                    AnyView(KeyboardSettingsPane(settings: context.keyboardVisualizerSettings))
                }
            ),
            SettingsPaneEntry(
                id: .mouse,
                title: SettingsPaneIdentifier.mouse.label,
                systemImageName: SettingsPaneIdentifier.mouse.sfSymbolName,
                makeView: {
                    AnyView(
                        MouseSettingsPane(
                            pointerRingVisualizer: context.pointerRingVisualizer,
                            pointerRingSettings: context.pointerRingSettings,
                            pointerIconSettings: context.pointerIconSettings
                        )
                    )
                }
            ),
            SettingsPaneEntry(
                id: .displays,
                title: SettingsPaneIdentifier.displays.label,
                systemImageName: SettingsPaneIdentifier.displays.sfSymbolName,
                makeView: {
                    AnyView(
                        DisplaysSettingsPane(
                            model: displaysViewModel
                        )
                    )
                }
            ),
            SettingsPaneEntry(
                id: .permissions,
                title: SettingsPaneIdentifier.permissions.label,
                systemImageName: SettingsPaneIdentifier.permissions.sfSymbolName,
                makeView: {
                    AnyView(PermissionsSettingsPane(permissionsService: context.permissionsService))
                }
            ),
            SettingsPaneEntry(
                id: .update,
                title: SettingsPaneIdentifier.update.label,
                systemImageName: SettingsPaneIdentifier.update.sfSymbolName,
                makeView: {
                    AnyView(UpdateSettingsPane(updater: context.updater))
                }
            ),
            SettingsPaneEntry(
                id: .info,
                title: SettingsPaneIdentifier.info.label,
                systemImageName: SettingsPaneIdentifier.info.sfSymbolName,
                makeView: {
                    AnyView(InfoSettingsPane())
                }
            ),
        ]
    }

    func entry(for identifier: SettingsPaneIdentifier) -> SettingsPaneEntry? {
        self.entries.first { $0.id == identifier }
    }
}
