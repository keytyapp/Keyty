//
//  KeycapAppearance+PBT.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapAppearance {
    struct PBT: KeycapAppearanceProviding {
        let shared: Shared
        let bodyGradient: NSGradient?
        let bodyStrokeColor: NSColor
        let underDishColor: NSColor
        let dishGradient: NSGradient?

        init(tokens: KeycapThemeTokens) {
            let bodyTop = tokens.surfaceBaseColor.lightened(by: 0.08)
            let bodyMid = tokens.surfaceShadowColor.lightened(by: 0.03)
            let bodyBottom = tokens.surfaceShadowColor.darkened(by: 0.08)
            let dishTop = tokens.surfaceBaseColor.lightened(by: 0.05)
            let dishMid = tokens.surfaceBaseColor.lightened(by: 0.06)
            let dishBottom = tokens.surfaceShadowColor.lightened(by: 0.05)

            self.shared = Shared(tokens: tokens)
            self.bodyGradient = NSGradient(colorsAndLocations:
                (bodyTop, 0.0),
                (bodyMid, 0.48),
                (bodyBottom, 1.0)
            )
            self.bodyStrokeColor = tokens.surfaceBorderColor
            self.underDishColor = tokens.surfaceBaseColor.lightened(by: 0.12)
            self.dishGradient = NSGradient(colorsAndLocations:
                (dishTop, 0.0),
                (dishMid, 0.32),
                (dishBottom, 1.0)
            )
        }
    }
}
