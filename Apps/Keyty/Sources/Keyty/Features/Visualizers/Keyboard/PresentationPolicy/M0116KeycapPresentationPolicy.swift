//
//  M0116KeycapPresentationPolicy.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

struct M0116KeycapPresentationPolicy: KeycapPresentationPolicy {
    var functionLegend: KeycapLegend {
        KeycapLegend(label: KeyboardSpecialKey.function.label)
    }

    func modifierLegend(for modifierKey: KeyboardModifierKey) -> KeycapLegend {
        KeycapLegend(label: modifierKey.kind.label)
    }

    func presentation(
        for keyCode: UInt16,
        legend: KeycapLegend,
        layoutHints: KeycapLayoutHints
    ) -> KeycapPresentation {
        guard let specialKey = KeyboardSpecialKeyResolver.specialKey(for: keyCode) else {
            return KeycapPresentation(legend: legend, layoutHints: layoutHints)
        }

        switch specialKey {
        case .escape:
            return self.textOnlyPresentation(for: .escape, layoutHints: layoutHints)
        case .tab:
            return self.textOnlyPresentation(for: .tab, layoutHints: layoutHints)
        case .delete:
            return self.textOnlyPresentation(for: .delete, layoutHints: layoutHints)
        case .returnKey:
            return self.textOnlyPresentation(for: .returnKey, layoutHints: layoutHints)
        case .space:
            return KeycapPresentation(legend: KeycapLegend(), layoutHints: layoutHints)
        case .leftArrow:
            return KeycapPresentation(
                legend: KeycapLegend(symbol: UnicodeToken.leftwardsDashedArrow.string),
                layoutHints: layoutHints
            )
        case .rightArrow:
            return KeycapPresentation(
                legend: KeycapLegend(symbol: UnicodeToken.rightwardsDashedArrow.string),
                layoutHints: layoutHints
            )
        case .upArrow:
            return KeycapPresentation(
                legend: KeycapLegend(symbol: UnicodeToken.upwardsDashedArrow.string),
                layoutHints: layoutHints
            )
        case .downArrow:
            return KeycapPresentation(
                legend: KeycapLegend(symbol: UnicodeToken.downwardsDashedArrow.string),
                layoutHints: layoutHints
            )
        case .forwardDelete, .keypadEnter, .help, .insert, .keypadClear, .home, .end, .pageUp, .pageDown,
             .function, .functionRow, .capsLock, .eisu, .kana, .system:
            return KeycapPresentation(legend: legend, layoutHints: layoutHints)
        }
    }

    private func textOnlyPresentation(
        for specialKey: KeyboardSpecialKey,
        layoutHints: KeycapLayoutHints
    ) -> KeycapPresentation {
        KeycapPresentation(
            legend: KeycapLegend(label: specialKey.label),
            layoutHints: layoutHints
        )
    }
}
