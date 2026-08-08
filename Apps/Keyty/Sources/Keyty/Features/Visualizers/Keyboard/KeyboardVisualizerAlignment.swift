//
//  KeyboardVisualizerAlignment.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

/// Aligns groups on the cross axis of a `KeyboardVisualizerStackAxis`.
/// The same cases map to left/center/right or bottom/center/top depending on stack direction.
enum KeyboardVisualizerAlignment: Int, CaseIterable {
    /// Pinned to the cross-axis start (left for a vertical stack, bottom for a horizontal stack).
    case leading = 0
    /// Centered on the cross axis.
    case center = 1
    /// Pinned to the cross-axis end (right for a vertical stack, top for a horizontal stack).
    case trailing = 2

    var label: String {
        switch self {
        case .leading:
            L10n.Anchor.left
        case .center:
            L10n.Anchor.center
        case .trailing:
            L10n.Anchor.right
        }
    }
}
