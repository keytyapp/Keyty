//
//  KeyboardSettingsPaneViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

@MainActor
final class KeyboardSettingsPaneViewModel: ObservableObject {
    private static let previewScale: CGFloat = 1.0
    static let customLegendColorSelectionID = "__custom_legend_color__"

    private let settings: KeyboardVisualizerSettings
    private var legendColorSelectionOverride: String?

    let maxCountRange: ClosedRange<Int> = 1...12
    let scaleRange: ClosedRange<Double> = 0.5...2.0
    let scaleStep: Double = 0.1

    @Published var isEnabled: Bool {
        didSet { self.settings.isEnabled = self.isEnabled }
    }

    @Published var stackAxis: KeyboardVisualizerStackAxis {
        didSet { self.settings.stackAxis = self.stackAxis }
    }

    @Published var anchor: KeyboardVisualizerAnchor {
        didSet { self.settings.anchor = self.anchor }
    }

    @Published var maxCount: Int {
        didSet { self.settings.maxCount = self.maxCount }
    }

    @Published var fadeDelay: Double {
        didSet { self.settings.fadeDelay = CGFloat(self.fadeDelay) }
    }

    @Published var fadeDuration: Double {
        didSet { self.settings.fadeDuration = CGFloat(self.fadeDuration) }
    }

    @Published var theme: KeyboardVisualizerTheme {
        didSet { self.settings.theme = self.theme }
    }

    @Published var legendColorMode: KeyboardLegendColorMode {
        didSet { self.settings.legendColorMode = self.legendColorMode }
    }

    @Published var customLegendColor: NSColor {
        didSet { self.settings.customLegendColor = self.customLegendColor }
    }

    @Published var usesCustomThemePalette: Bool {
        didSet { self.settings.usesCustomThemePalette = self.usesCustomThemePalette }
    }

    /// Drives the base theme picker. Picking a concrete theme turns custom mode
    /// off and sets the base `theme`; picking `.custom` turns custom mode on.
    var themeSelection: ThemeSelection {
        get { self.usesCustomThemePalette ? .custom : .theme(self.theme) }
        set {
            switch newValue {
            case .custom:
                self.usesCustomThemePalette = true
            case .theme(let theme):
                self.usesCustomThemePalette = false
                self.theme = theme
            }
        }
    }

    @Published var modifierTheme: KeyboardVisualizerTheme {
        didSet { self.settings.modifierTheme = self.modifierTheme }
    }

    @Published var specialTheme: KeyboardVisualizerTheme {
        didSet { self.settings.specialTheme = self.specialTheme }
    }

    @Published var mediaTheme: KeyboardVisualizerTheme {
        didSet { self.settings.mediaTheme = self.mediaTheme }
    }

    @Published var mouseTheme: KeyboardVisualizerTheme {
        didSet { self.settings.mouseTheme = self.mouseTheme }
    }

    @Published var groupBackgroundTheme: KeyboardVisualizerTheme {
        didSet { self.settings.groupBackgroundTheme = self.groupBackgroundTheme }
    }

    @Published var style: KeycapStyle {
        didSet { self.settings.style = self.style }
    }

    @Published var scale: Double {
        didSet { self.settings.scale = CGFloat(self.scale) }
    }

    @Published var onlyShowModifiedKeystrokes: Bool {
        didSet { self.settings.onlyShowModifiedKeystrokes = self.onlyShowModifiedKeystrokes }
    }

    @Published var showSpecialKeys: Bool {
        didSet { self.settings.showSpecialKeys = self.showSpecialKeys }
    }

    @Published var showMediaKeyButtons: Bool {
        didSet { self.settings.showMediaKeyButtons = self.showMediaKeyButtons }
    }

    @Published var showMouseEvents: Bool {
        didSet { self.settings.showMouseEvents = self.showMouseEvents }
    }

    init(settings: KeyboardVisualizerSettings) {
        self.settings = settings
        self.isEnabled = settings.isEnabled
        self.stackAxis = settings.stackAxis
        self.anchor = settings.anchor
        self.maxCount = settings.maxCount
        self.fadeDelay = Double(settings.fadeDelay)
        self.fadeDuration = Double(settings.fadeDuration)
        self.theme = settings.theme
        self.legendColorMode = settings.legendColorMode
        self.customLegendColor = settings.customLegendColor
        self.usesCustomThemePalette = settings.usesCustomThemePalette
        self.modifierTheme = settings.modifierTheme
        self.specialTheme = settings.specialTheme
        self.mediaTheme = settings.mediaTheme
        self.mouseTheme = settings.mouseTheme
        self.groupBackgroundTheme = settings.groupBackgroundTheme
        self.style = settings.style
        self.scale = Double(settings.scale)
        self.onlyShowModifiedKeystrokes = settings.onlyShowModifiedKeystrokes
        self.showSpecialKeys = settings.showSpecialKeys
        self.showMediaKeyButtons = settings.showMediaKeyButtons
        self.showMouseEvents = settings.showMouseEvents
    }

    var previewIdentity: String {
        [
            "\(self.style.rawValue)",
            "\(self.isEnabled)",
            "\(self.theme.rawValue)",
            self.legendColorMode.rawValue,
            self.customLegendColor.hexString,
            "\(self.usesCustomThemePalette)",
            "\(self.modifierTheme.rawValue)",
            "\(self.specialTheme.rawValue)",
            "\(self.mediaTheme.rawValue)",
            "\(self.mouseTheme.rawValue)",
            "\(self.groupBackgroundTheme.rawValue)",
            "\(self.stackAxis.rawValue)",
            "\(self.anchor.rawValue)",
            "\(self.maxCount)",
            "\(self.onlyShowModifiedKeystrokes)",
            "\(self.showSpecialKeys)",
            "\(self.showMediaKeyButtons)",
            "\(self.showMouseEvents)",
            "\(self.settings.windowPadding)"
        ].joined(separator: "-")
    }

    var previewRenderSettings: KeyboardVisualizerSettings {
        let settings = KeyboardVisualizerSettings(store: InMemoryKeyValueStore())
        settings.registerDefaults()
        settings.isEnabled = self.isEnabled
        settings.style = self.style
        settings.theme = self.theme
        settings.legendColorMode = self.legendColorMode
        settings.customLegendColor = self.customLegendColor
        settings.usesCustomThemePalette = self.usesCustomThemePalette
        settings.modifierTheme = self.modifierTheme
        settings.specialTheme = self.specialTheme
        settings.mediaTheme = self.mediaTheme
        settings.mouseTheme = self.mouseTheme
        settings.groupBackgroundTheme = self.groupBackgroundTheme
        settings.stackAxis = self.stackAxis
        settings.anchor = self.anchor
        settings.maxCount = self.maxCount
        settings.fadeDelay = CGFloat(self.fadeDelay)
        settings.fadeDuration = CGFloat(self.fadeDuration)
        settings.scale = Self.previewScale
        settings.windowPadding = self.settings.windowPadding
        settings.onlyShowModifiedKeystrokes = self.onlyShowModifiedKeystrokes
        settings.showSpecialKeys = self.showSpecialKeys
        settings.showMediaKeyButtons = self.showMediaKeyButtons
        settings.showMouseEvents = self.showMouseEvents
        return settings
    }

    var legendColorSelectionID: String {
        if let legendColorSelectionOverride {
            return legendColorSelectionOverride
        }

        switch self.legendColorMode {
        case .automatic:
            return KeyboardSettingsPaneViewModel.ColorPreset.automaticSelectionID
        case .custom:
            return KeyboardSettingsPaneViewModel.ColorPreset.presets
                .first { $0.color.hexString == self.customLegendColor.hexString }?
                .color.hexString
                ?? Self.customLegendColorSelectionID
        }
    }

    func selectLegendColor(with selectionID: String) {
        if selectionID == KeyboardSettingsPaneViewModel.ColorPreset.automaticSelectionID {
            self.legendColorMode = .automatic
            self.legendColorSelectionOverride = nil
            return
        }

        guard let preset = KeyboardSettingsPaneViewModel.ColorPreset.presets.first(where: { $0.color.hexString == selectionID }) else {
            return
        }

        self.legendColorMode = .custom
        self.customLegendColor = preset.color
        self.legendColorSelectionOverride = nil
    }

    func beginChoosingCustomLegendColor() {
        self.legendColorMode = .custom
        self.legendColorSelectionOverride = Self.customLegendColorSelectionID
    }

    func applyCustomLegendColor(_ color: NSColor) {
        self.legendColorMode = .custom
        self.customLegendColor = color
        self.legendColorSelectionOverride = Self.customLegendColorSelectionID
    }
}

extension KeyboardSettingsPaneViewModel {
    // Selection backing the base theme picker:
    enum ThemeSelection: Hashable {
        case theme(KeyboardVisualizerTheme)
        case custom
    }
}
