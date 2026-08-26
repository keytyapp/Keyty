//
//  KeycapAppearance+M0116.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapAppearance {
    /// Sculpted beige-era keycap: a lit body, an inset top face, and a front skirt,
    /// all sitting in a near-black well like the plate of an Apple Standard Keyboard.
    struct M0116: KeycapAppearanceProviding {
        let shared: Shared
        let wellColor: NSColor
        let bodyGradient: NSGradient?
        let skirtGradient: NSGradient?
        let faceGradient: NSGradient?
        let creaseColor: NSColor
        let bodyStrokeColor: NSColor

        init(tokens: KeycapThemeTokens) {
            let bodyEdge = tokens.surfaceShadowColor.darkened(by: 0.28)
            let bodyHighlight = tokens.surfaceHighlightColor.blended(
                withFraction: 0.35,
                of: tokens.surfaceBaseColor
            ) ?? tokens.surfaceHighlightColor
            let legendTextColor = tokens.textColor.darkened(by: 0.18)

            self.shared = Shared(
                textColor: legendTextColor,
                groupBackgroundColor: tokens.groupBackgroundColor,
                groupStrokeColor: tokens.groupStrokeColor,
                badgeFillColor: tokens.badgeFillColor,
                badgeStrokeColor: tokens.badgeStrokeColor,
                badgeHighlightColor: tokens.badgeHighlightColor,
                badgeTextColor: tokens.badgeTextColor
            )
            self.wellColor = tokens.recessColor.darkened(by: 0.45)
            // Lit from the left: bright edge, base across the middle, shaded right edge.
            self.bodyGradient = NSGradient(colorsAndLocations:
                (tokens.surfaceHighlightColor, 0.0),
                (bodyHighlight, 0.14),
                (tokens.surfaceBaseColor, 0.55),
                (tokens.surfaceShadowColor, 0.92),
                (bodyEdge, 1.0)
            )
            // The front skirt catches more light at its lower edge than the face above it.
            self.skirtGradient = NSGradient(colorsAndLocations:
                (bodyEdge, 0.0),
                (tokens.surfaceBaseColor, 0.45),
                (tokens.surfaceHighlightColor, 1.0)
            )
            self.faceGradient = NSGradient(colorsAndLocations:
                (tokens.surfaceHighlightColor, 0.0),
                (tokens.surfaceBaseColor, 0.58),
                (tokens.surfaceShadowColor, 1.0)
            )
            self.creaseColor = tokens.surfaceBorderColor.withAlphaComponent(0.42)
            self.bodyStrokeColor = tokens.surfaceBorderColor
        }
    }
}
