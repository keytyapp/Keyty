//
//  KeyboardVisualizerSettingsKeys.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum KeyboardVisualizerSettingsKeys {
    static let defaultMaxCount = 1
    static let minMaxCount = 1

    static let isEnabled    = "keyboard_visualizer.isEnabled"
    static let axis         = "keyboard_visualizer.direction"
    static let maxCount     = "keyboard_visualizer.maxCount"
    static let fadeDelay    = "keyboard_visualizer.fadeDelay"
    static let fadeDuration = "keyboard_visualizer.fadeDuration"
    static let theme        = "keyboard_visualizer.theme"
    static let legendColorMode = "keyboard_visualizer.legendColorMode"
    static let customLegendColor = "keyboard_visualizer.customLegendColor"
    static let usesCustomThemePalette = "keyboard_visualizer.usesCustomThemePalette"
    static let modifierTheme      = "keyboard_visualizer.modifierTheme"
    static let specialTheme       = "keyboard_visualizer.specialTheme"
    static let mediaTheme         = "keyboard_visualizer.mediaTheme"
    static let mouseTheme         = "keyboard_visualizer.mouseTheme"
    static let groupBackgroundTheme = "keyboard_visualizer.groupBackgroundTheme"
    static let anchor       = "keyboard_visualizer.anchor"
    static let placementMode = "keyboard_visualizer.placementMode"
    static let customPositionNormalizedX = "keyboard_visualizer.customPositionNormalizedX"
    static let customPositionNormalizedY = "keyboard_visualizer.customPositionNormalizedY"
    static let screenID     = "keyboard_visualizer.screenID"
    static let scale        = "keyboard_visualizer.scale"
    static let windowPadding = "keyboard_visualizer.windowPadding"
    static let style        = "keyboard_visualizer.style"
    static let onlyShowModifiedKeystrokes = "keyboard_visualizer.onlyShowModifiedKeystrokes"
    static let showSpecialKeys = "keyboard_visualizer.showSpecialKeys"
    static let showMediaKeyButtons = "keyboard_visualizer.showMediaKeyButtons"
    static let showMouseEvents = "keyboard_visualizer.showMouseEvents"
}
