//
//  KeycapPresentationPolicy.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

protocol KeycapPresentationPolicy {
    /// Indicates whether caps lock should render its indicator dot in this style.
    var showsCapsLockDot: Bool { get }
    /// Returns the legend used for the function key in this style.
    var functionLegend: KeycapLegend { get }

    /// Returns the legend used for a modifier key in this style.
    func modifierLegend(for modifierKey: KeyboardModifierKey) -> KeycapLegend
    /// Returns the style-adjusted keycap presentation for a keyboard key.
    func presentation(
        for keyCode: UInt16,
        legend: KeycapLegend,
        layoutHints: KeycapLayoutHints
    ) -> KeycapPresentation
}
