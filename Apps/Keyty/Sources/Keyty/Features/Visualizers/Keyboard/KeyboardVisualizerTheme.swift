//
//  KeyboardVisualizerTheme.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum KeyboardVisualizerTheme: Int, CaseIterable {
    case black = 0
    case white = 1

    case citrus = 2
    case indigo = 3
    case rose = 4

    case red = 5
    case orange = 6
    case yellow = 7
    case green = 8
    case blue = 9
    case purple = 10
    case pink = 11
}

// MARK: - Titles
extension KeyboardVisualizerTheme {
    var title: String {
        switch self {
        case .black: L10n.KeyboardVisualizer.Theme.dark
        case .white: L10n.KeyboardVisualizer.Theme.white
        case .citrus: L10n.KeyboardVisualizer.Theme.citrus
        case .green: L10n.KeyboardVisualizer.Theme.green
        case .blue: L10n.KeyboardVisualizer.Theme.blue
        case .indigo: L10n.KeyboardVisualizer.Theme.indigo
        case .rose: L10n.KeyboardVisualizer.Theme.rose
        case .red: L10n.KeyboardVisualizer.Theme.red
        case .purple: L10n.KeyboardVisualizer.Theme.purple
        case .yellow: L10n.KeyboardVisualizer.Theme.yellow
        case .orange: L10n.KeyboardVisualizer.Theme.orange
        case .pink: L10n.KeyboardVisualizer.Theme.pink
        }
    }
}

// MARK: - Tokens
extension KeyboardVisualizerTheme {
    var tokens: KeycapThemeTokens {
        switch self {
        case .white:
            return KeycapThemeTokens(
                swatchColor: NSColor(white: 0.96, alpha: 1),
                textColor: NSColor(calibratedRed: 0.388, green: 0.384, blue: 0.365, alpha: 1),
                groupBackgroundColor: NSColor(white: 0.90, alpha: 0.92),
                groupStrokeColor: NSColor(white: 0.75, alpha: 0.7),
                surfaceHighlightColor: NSColor(white: 0.99, alpha: 1),
                surfaceBaseColor: NSColor(white: 0.94, alpha: 1),
                surfaceShadowColor: NSColor(white: 0.88, alpha: 1),
                surfaceBorderColor: NSColor(white: 0.78, alpha: 1),
                recessColor: NSColor(white: 0.86, alpha: 1)
            )
        case .black:
            return KeycapThemeTokens(
                swatchColor: NSColor(white: 0.08, alpha: 1),
                textColor: .white,
                groupBackgroundColor: NSColor(white: 0.09, alpha: 0.95),
                groupStrokeColor: NSColor(white: 0.24, alpha: 0.62),
                surfaceHighlightColor: NSColor(white: 0.22, alpha: 1),
                surfaceBaseColor: NSColor(white: 0.11, alpha: 1),
                surfaceShadowColor: NSColor(white: 0.05, alpha: 1),
                surfaceBorderColor: NSColor(white: 0.28, alpha: 1),
                recessColor: NSColor(white: 0.035, alpha: 1)
            )
        case .citrus:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.945, green: 0.937, blue: 0.749, alpha: 1),
                textColor: NSColor(calibratedRed: 0.388, green: 0.384, blue: 0.365, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.804, green: 0.804, blue: 0.522, alpha: 0.9),
                groupStrokeColor: NSColor(calibratedRed: 0.682, green: 0.675, blue: 0.400, alpha: 0.65),
                surfaceHighlightColor: NSColor(calibratedRed: 0.980, green: 0.976, blue: 0.824, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 0.945, green: 0.937, blue: 0.749, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.902, green: 0.890, blue: 0.659, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.620, green: 0.604, blue: 0.361, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.776, green: 0.761, blue: 0.486, alpha: 1)
            )
        case .green:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.470, green: 0.905, blue: 0.000, alpha: 1),
                textColor: NSColor(calibratedWhite: 0.98, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.120, green: 0.145, blue: 0.060, alpha: 0.95),
                groupStrokeColor: NSColor(calibratedRed: 0.360, green: 0.650, blue: 0.060, alpha: 0.60),
                surfaceHighlightColor: NSColor(calibratedRed: 0.570, green: 0.965, blue: 0.060, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 0.460, green: 0.900, blue: 0.000, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.350, green: 0.720, blue: 0.000, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.405, green: 0.760, blue: 0.015, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.270, green: 0.510, blue: 0.000, alpha: 1)
            )
        case .blue:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.220, green: 0.420, blue: 1.000, alpha: 1),
                textColor: NSColor(calibratedWhite: 0.98, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.080, green: 0.100, blue: 0.165, alpha: 0.95),
                groupStrokeColor: NSColor(calibratedRed: 0.245, green: 0.430, blue: 0.900, alpha: 0.62),
                surfaceHighlightColor: NSColor(calibratedRed: 0.330, green: 0.570, blue: 1.000, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 0.230, green: 0.455, blue: 1.000, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.110, green: 0.315, blue: 0.940, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.300, green: 0.545, blue: 1.000, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.090, green: 0.270, blue: 0.820, alpha: 1)
            )
        case .indigo:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.565, green: 0.596, blue: 0.690, alpha: 1),
                textColor: NSColor(calibratedRed: 0.231, green: 0.247, blue: 0.267, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.220, green: 0.251, blue: 0.314, alpha: 0.92),
                groupStrokeColor: NSColor(calibratedRed: 0.471, green: 0.518, blue: 0.631, alpha: 0.65),
                surfaceHighlightColor: NSColor(calibratedRed: 0.624, green: 0.655, blue: 0.749, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 0.565, green: 0.596, blue: 0.690, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.490, green: 0.522, blue: 0.616, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.486, green: 0.533, blue: 0.639, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.314, green: 0.345, blue: 0.431, alpha: 1)
            )
        case .rose:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.941, green: 0.878, blue: 0.878, alpha: 1),
                textColor: NSColor(calibratedRed: 0.349, green: 0.337, blue: 0.333, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.761, green: 0.686, blue: 0.671, alpha: 0.9),
                groupStrokeColor: NSColor(calibratedRed: 0.804, green: 0.725, blue: 0.729, alpha: 0.65),
                surfaceHighlightColor: NSColor(calibratedRed: 0.973, green: 0.918, blue: 0.922, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 0.941, green: 0.878, blue: 0.878, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.894, green: 0.816, blue: 0.824, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.690, green: 0.608, blue: 0.612, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.800, green: 0.718, blue: 0.725, alpha: 1)
            )
        case .red:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 1.000, green: 0.278, blue: 0.251, alpha: 1),
                textColor: NSColor(calibratedWhite: 0.99, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.170, green: 0.085, blue: 0.075, alpha: 0.95),
                groupStrokeColor: NSColor(calibratedRed: 0.500, green: 0.185, blue: 0.150, alpha: 0.62),
                surfaceHighlightColor: NSColor(calibratedRed: 1.000, green: 0.390, blue: 0.355, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 1.000, green: 0.295, blue: 0.265, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.925, green: 0.215, blue: 0.200, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.760, green: 0.180, blue: 0.150, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.760, green: 0.150, blue: 0.120, alpha: 1)
            )
        case .purple:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.36, green: 0.18, blue: 0.69, alpha: 1),
                textColor: NSColor(calibratedWhite: 0.98, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.12, green: 0.01, blue: 0.25, alpha: 0.94),
                groupStrokeColor: NSColor(calibratedRed: 0.25, green: 0.12, blue: 0.46, alpha: 0.72),
                surfaceHighlightColor: NSColor(calibratedRed: 0.53, green: 0.31, blue: 0.86, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 0.45, green: 0.24, blue: 0.79, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.39, green: 0.20, blue: 0.73, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.36, green: 0.19, blue: 0.69, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.41, green: 0.22, blue: 0.75, alpha: 1)
            )
        case .yellow:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.995, green: 0.724, blue: 0.192, alpha: 1),
                textColor: NSColor(calibratedWhite: 0.99, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.160, green: 0.120, blue: 0.050, alpha: 0.95),
                groupStrokeColor: NSColor(calibratedRed: 0.435, green: 0.322, blue: 0.112, alpha: 0.62),
                surfaceHighlightColor: NSColor(calibratedRed: 1.000, green: 0.801, blue: 0.290, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 0.994, green: 0.714, blue: 0.182, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.925, green: 0.610, blue: 0.120, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.705, green: 0.460, blue: 0.060, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.780, green: 0.520, blue: 0.085, alpha: 1)
            )
        case .orange:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.996, green: 0.446, blue: 0.120, alpha: 1),
                textColor: NSColor(calibratedWhite: 0.99, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.175, green: 0.105, blue: 0.050, alpha: 0.95),
                groupStrokeColor: NSColor(calibratedRed: 0.520, green: 0.255, blue: 0.095, alpha: 0.62),
                surfaceHighlightColor: NSColor(calibratedRed: 1.000, green: 0.520, blue: 0.195, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 1.000, green: 0.455, blue: 0.135, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.925, green: 0.340, blue: 0.085, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.795, green: 0.295, blue: 0.055, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.790, green: 0.270, blue: 0.045, alpha: 1)
            )
        case .pink:
            return KeycapThemeTokens(
                swatchColor: NSColor(calibratedRed: 0.900, green: 0.205, blue: 0.785, alpha: 1),
                textColor: NSColor(calibratedWhite: 0.99, alpha: 1),
                groupBackgroundColor: NSColor(calibratedRed: 0.160, green: 0.075, blue: 0.145, alpha: 0.95),
                groupStrokeColor: NSColor(calibratedRed: 0.455, green: 0.165, blue: 0.395, alpha: 0.62),
                surfaceHighlightColor: NSColor(calibratedRed: 0.935, green: 0.305, blue: 0.835, alpha: 1),
                surfaceBaseColor: NSColor(calibratedRed: 0.905, green: 0.225, blue: 0.800, alpha: 1),
                surfaceShadowColor: NSColor(calibratedRed: 0.820, green: 0.155, blue: 0.710, alpha: 1),
                surfaceBorderColor: NSColor(calibratedRed: 0.650, green: 0.120, blue: 0.560, alpha: 1),
                recessColor: NSColor(calibratedRed: 0.700, green: 0.135, blue: 0.610, alpha: 1)
            )
        }
    }
}

// MARK: - Appearance
extension KeyboardVisualizerTheme {
    func tokens(legendColorOverride: NSColor?) -> KeycapThemeTokens {
        let tokens = self.tokens
        guard let legendColorOverride else {
            return tokens
        }

        return KeycapThemeTokens(
            swatchColor: tokens.swatchColor,
            textColor: legendColorOverride,
            groupBackgroundColor: tokens.groupBackgroundColor,
            groupStrokeColor: tokens.groupStrokeColor,
            surfaceHighlightColor: tokens.surfaceHighlightColor,
            surfaceBaseColor: tokens.surfaceBaseColor,
            surfaceShadowColor: tokens.surfaceShadowColor,
            surfaceBorderColor: tokens.surfaceBorderColor,
            recessColor: tokens.recessColor
        )
    }

    func appearance(for style: KeycapStyle, legendColorOverride: NSColor? = nil) -> KeycapAppearance {
        let tokens = self.tokens(legendColorOverride: legendColorOverride)
        switch style {
        case .apple:
            return KeycapAppearance.apple(KeycapAppearance.Apple(tokens: tokens))
        case .pbt:
            return KeycapAppearance.pbt(KeycapAppearance.PBT(tokens: tokens))
        case .minimal:
            return KeycapAppearance.minimal(KeycapAppearance.Minimal(tokens: tokens))
        case .retro:
            return KeycapAppearance.retro(KeycapAppearance.Retro(tokens: tokens))
        }
    }
}

// MARK: - Display
extension KeyboardVisualizerTheme {
    var displayColor: NSColor {
        self.tokens.swatchColor
    }
}

// MARK: - Picker Sections
extension KeyboardVisualizerTheme {
    static let pickerSections: [[KeyboardVisualizerTheme]] = [
        [.black, .white],
        [.citrus, .indigo, .rose],
        [.red, .orange, .yellow, .green, .blue, .purple, .pink],
    ]
}
