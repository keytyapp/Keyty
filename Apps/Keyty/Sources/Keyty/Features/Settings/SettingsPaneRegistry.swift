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

    init(
        shortcutManager: ShortcutManager,
        appSettings: any AppSettingsProtocol,
        pointerRingVisualizer: PointerRingVisualizer,
        pointerRingSettings: any PointerRingSettingsProtocol,
        pointerIconSettings: any PointerIconSettingsProtocol,
        keyboardVisualizerSettings: KeyboardVisualizerSettings,
        startSettingKeyboardVisualizerPosition: @escaping @MainActor () -> Void,
        stopSettingKeyboardVisualizerPosition: @escaping @MainActor () -> Void,
        permissionsService: any PermissionsService,
        updater: SPUUpdater
    ) {
        self.entries = [
            SettingsPaneEntry(
                id: .general,
                title: SettingsPaneIdentifier.general.label,
                systemImageName: SettingsPaneIdentifier.general.sfSymbolName,
                makeView: {
                    AnyView(
                        GeneralSettingsPane(
                            shortcutManager: shortcutManager,
                            appSettings: appSettings
                        )
                    )
                }
            ),
            SettingsPaneEntry(
                id: .keyboard,
                title: SettingsPaneIdentifier.keyboard.label,
                systemImageName: SettingsPaneIdentifier.keyboard.sfSymbolName,
                makeView: {
                    AnyView(KeyboardSettingsPane(settings: keyboardVisualizerSettings))
                }
            ),
            SettingsPaneEntry(
                id: .mouse,
                title: SettingsPaneIdentifier.mouse.label,
                systemImageName: SettingsPaneIdentifier.mouse.sfSymbolName,
                makeView: {
                    AnyView(
                        MouseSettingsPane(
                            pointerRingVisualizer: pointerRingVisualizer,
                            pointerRingSettings: pointerRingSettings,
                            pointerIconSettings: pointerIconSettings
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
                            keyboardVisualizerSettings: keyboardVisualizerSettings,
                            startSettingKeyboardVisualizerPosition: startSettingKeyboardVisualizerPosition,
                            stopSettingKeyboardVisualizerPosition: stopSettingKeyboardVisualizerPosition
                        )
                    )
                }
            ),
            SettingsPaneEntry(
                id: .permissions,
                title: SettingsPaneIdentifier.permissions.label,
                systemImageName: SettingsPaneIdentifier.permissions.sfSymbolName,
                makeView: {
                    AnyView(PermissionsSettingsPane(permissionsService: permissionsService))
                }
            ),
            SettingsPaneEntry(
                id: .update,
                title: SettingsPaneIdentifier.update.label,
                systemImageName: SettingsPaneIdentifier.update.sfSymbolName,
                makeView: {
                    AnyView(UpdateSettingsPane(updater: updater))
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
