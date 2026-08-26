//
//  KeycapPresentation.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

/// Style-resolved content and layout for a rendered keycap.
struct KeycapPresentation {
    let legend: KeycapLegend
    let layoutHints: KeycapLayoutHints

    init(
        legend: KeycapLegend,
        layoutHints: KeycapLayoutHints = KeycapLayoutHints()
    ) {
        self.legend = legend
        self.layoutHints = layoutHints
    }
}
