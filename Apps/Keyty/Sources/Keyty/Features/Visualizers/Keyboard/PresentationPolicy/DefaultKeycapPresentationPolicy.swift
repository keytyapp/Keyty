//
//  DefaultKeycapPresentationPolicy.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

struct DefaultKeycapPresentationPolicy: KeycapPresentationPolicy {
    var showsCapsLockDot: Bool { true }
    var functionLegend: KeycapLegend { .function }

    func modifierLegend(for modifierKey: KeyboardModifierKey) -> KeycapLegend {
        KeycapLegend(symbol: modifierKey.kind.glyph, label: modifierKey.kind.label)
    }

    func presentation(
        for keyCode: UInt16,
        legend: KeycapLegend,
        layoutHints: KeycapLayoutHints
    ) -> KeycapPresentation {
        KeycapPresentation(legend: legend, layoutHints: layoutHints)
    }
}
