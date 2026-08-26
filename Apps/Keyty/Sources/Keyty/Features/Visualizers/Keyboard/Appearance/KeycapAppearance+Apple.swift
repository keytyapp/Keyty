//
//  KeycapAppearance+Apple.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapAppearance {
    struct Apple: KeycapAppearanceProviding {
        let shared: Shared
        let strokeColor: NSColor
        let undersideGradient: NSGradient?
        let mainGradient: NSGradient?

        init(tokens: KeycapThemeTokens) {
            self.shared = Shared(tokens: tokens)
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
