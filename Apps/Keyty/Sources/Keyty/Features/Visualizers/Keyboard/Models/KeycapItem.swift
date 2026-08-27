//
//  KeycapItem.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Foundation

/// Complete render model for one keycap.
///
/// This is the object consumed by the renderer layer. It combines semantic identity,
/// display content, transient visual state, layout hints, and explicit appearance.
struct KeycapItem {
    let identity: KeycapIdentity
    let legend: KeycapLegend
    let state: KeycapState
    let layoutHints: KeycapLayoutHints
    let appearance: KeycapAppearance

    init(
        identity: KeycapIdentity,
        legend: KeycapLegend,
        state: KeycapState,
        layoutHints: KeycapLayoutHints = KeycapLayoutHints(),
        appearance: KeycapAppearance
    ) {
        self.identity = identity
        self.legend = legend
        self.state = state
        self.layoutHints = layoutHints
        self.appearance = appearance
    }

    // Transitional accessors so the renderer layer can migrate incrementally.
    var symbol: String { self.legend.symbol }
    var image: NSImage? { self.legend.image }
    var imageBadgeText: String? { self.legend.imageBadgeText }
    var sfSymbolName: String? { self.legend.sfSymbolName }
    var label: String? { self.legend.label }
    var rendersSymbolWithLabel: Bool { self.legend.rendersSymbolWithLabel }
    var rendersCenteredLabel: Bool { self.legend.rendersCenteredLabel }
    /// Indicates whether the label should be drawn in a constrained width so it can wrap across lines.
    var wrapsLabel: Bool { self.legend.wrapsLabel }
    var isPressed: Bool { self.state.isPressed }
    var fixedWidth: CGFloat? { self.layoutHints.fixedWidth }
}

extension KeycapItem: KeycapGroupItem {}
