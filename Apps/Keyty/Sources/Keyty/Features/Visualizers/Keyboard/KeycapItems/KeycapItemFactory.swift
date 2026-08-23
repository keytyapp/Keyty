//
//  KeycapItemFactory.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Centralizes conversion into `KeycapItem` so runtime input events
/// and settings previews are built from the same rules.
///
/// Each item resolves its own appearance from the `KeycapThemePalette` by its
/// `KeycapIdentity`, so per-key-type theming applies uniformly across every branch.
enum KeycapItemFactory {
    static let mouseIconHeight: CGFloat = 44
    static let orderedModifierLocations: [KeyboardModifierKey.Location] = [.left, .right]
}
