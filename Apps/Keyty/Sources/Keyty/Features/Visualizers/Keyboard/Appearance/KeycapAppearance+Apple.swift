//
//  KeycapAppearance+Apple.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapAppearance {
    struct Apple {
        let textColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
        let badgeFillColor: NSColor
        let badgeStrokeColor: NSColor
        let badgeHighlightColor: NSColor
        let badgeTextColor: NSColor
        let strokeColor: NSColor
        let undersideGradient: NSGradient?
        let mainGradient: NSGradient?

        init(tokens: KeycapThemeTokens) {
            self.textColor = tokens.textColor
            self.groupBackgroundColor = tokens.groupBackgroundColor
            self.groupStrokeColor = tokens.groupStrokeColor
            self.badgeFillColor = tokens.badgeFillColor
            self.badgeStrokeColor = tokens.badgeStrokeColor
            self.badgeHighlightColor = tokens.badgeHighlightColor
            self.badgeTextColor = tokens.badgeTextColor
            self.strokeColor = tokens.surfaceBorderColor
            let undersideEdgeColor = tokens.undersideEdgeColor ?? tokens.recessColor
            let undersideCenterColor = tokens.undersideCenterColor ?? tokens.surfaceBaseColor
            self.undersideGradient = NSGradient(colorsAndLocations:
                (undersideEdgeColor, 0.0),
                (undersideCenterColor, 0.5),
                (undersideEdgeColor, 1.0)
            )
            self.mainGradient = NSGradient(colorsAndLocations:
                (tokens.surfaceBaseColor, 0.0),
                (tokens.surfaceShadowColor, 1.0)
            )
        }
    }
}
