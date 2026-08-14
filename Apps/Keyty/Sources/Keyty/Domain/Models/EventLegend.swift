//
//  EventLegend.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

/// The resolved visual form of a single input event.
///
/// Names what to draw without deciding how large to draw it: every case
/// identifies a resource, and renderers pick their own sizes, fonts, and colors.
struct EventLegend: Equatable {
    /// Modifiers held for this event (in canonical display order)
    let modifiers: [KeyboardModifierKey.Kind]

    /// How the key itself should be drawn.
    let kind: Kind

    /// The key's textual form, always populated so it can stand in when `kind` cannot be rendered.
    /// (e.g. the "tab" key will store `⇥` here).
    let text: String

    /// Secondary label for keycap styles that pair a symbol with a name.
    /// (e.g. the "tab" key will store "tab" here).
    let label: String?

    init(
        modifiers: [KeyboardModifierKey.Kind] = [],
        kind: Kind = .text,
        text: String,
        label: String? = nil
    ) {
        self.modifiers = modifiers
        self.kind = kind
        self.text = text
        self.label = label
    }
}

extension EventLegend {
    /// The three ways a legend can be drawn, matching the branches every
    /// keycap renderer already has.
    enum Kind: Equatable {
        /// Draw `text`.
        case text

        /// Draw the named SF Symbol.
        case symbol(String)

        /// Draw the icon for this mouse action.
        case mouseIcon(MouseEvent.Kind)
    }
}
