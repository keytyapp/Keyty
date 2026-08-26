//
//  KeycapStyle.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//
enum KeycapStyle: Int, CaseIterable {
    case apple = 0
    case pbt = 1
    case minimal = 2
    case retro = 3
    case m0116 = 4

    static let `default`: KeycapStyle = .apple
}

// MARK: - Titles
extension KeycapStyle {
    var title: String {
        switch self {
        case .apple: L10n.KeyboardVisualizer.Style.apple
        case .pbt:   L10n.KeyboardVisualizer.Style.pbt
        case .minimal: L10n.KeyboardVisualizer.Style.minimal
        case .retro: L10n.KeyboardVisualizer.Style.retro
        case .m0116: L10n.KeyboardVisualizer.Style.m0116
        }
    }
}

// MARK: - Theme Policy
extension KeycapStyle {
    var allowedThemes: [KeyboardVisualizerTheme] {
        switch self {
        case .m0116:
            return [.white]
        case .apple, .pbt, .minimal, .retro:
            return KeyboardVisualizerTheme.allCases
        }
    }

    func allows(theme: KeyboardVisualizerTheme) -> Bool {
        self.allowedThemes.contains(theme)
    }

    func sanitize(theme: KeyboardVisualizerTheme) -> KeyboardVisualizerTheme {
        guard self.allows(theme: theme) else {
            return self.allowedThemes.first ?? .black
        }
        return theme
    }
}

// MARK: - Presentation Policy
extension KeycapStyle {
    func presentation(
        for keyCode: UInt16,
        legend: KeycapLegend,
        layoutHints: KeycapLayoutHints
    ) -> KeycapPresentation {
        guard let specialKey = KeyboardSpecialKeyResolver.specialKey(for: keyCode) else {
            return KeycapPresentation(legend: legend, layoutHints: layoutHints)
        }

        switch (self, specialKey) {
        case (.m0116, .escape):
            return KeycapPresentation(
                legend: KeycapLegend(
                    label: KeyboardSpecialKey.escape.label
                ),
                layoutHints: layoutHints
            )
        case (.apple, _), (.pbt, _), (.minimal, _), (.retro, _), (.m0116, _):
            return KeycapPresentation(legend: legend, layoutHints: layoutHints)
        }
    }
}
