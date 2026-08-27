//
//  KeycapThemeTokens.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Carries the base colors used to construct a concrete keycap appearance.
struct KeycapThemeTokens {
    let groupBackgroundColor: NSColor
    let groupStrokeColor: NSColor

    let badgeFillColor: NSColor
    let badgeHighlightColor: NSColor
    let badgeStrokeColor: NSColor
    let badgeTextColor: NSColor

    let surfaceBaseColor: NSColor
    let surfaceBorderColor: NSColor
    let surfaceHighlightColor: NSColor
    let surfaceShadowColor: NSColor

    let recessColor: NSColor
    /// Optional Apple-style underside center color override. Falls back to `surfaceBaseColor`.
    let undersideCenterColor: NSColor?
    /// Optional Apple-style underside edge color override. Falls back to `recessColor`.
    let undersideEdgeColor: NSColor?

    let swatchColor: NSColor
    let textColor: NSColor
}
