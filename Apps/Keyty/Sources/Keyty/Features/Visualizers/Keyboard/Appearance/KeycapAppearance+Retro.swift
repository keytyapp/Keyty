//
//  KeycapAppearance+Retro.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapAppearance {
    struct Retro: KeycapAppearanceProviding {
        let shared: Shared
        let lipGradient: NSGradient?
        let bodyShadowColor: NSColor
        let bodyGradient: NSGradient?
        let bodyStrokeColor: NSColor
        let faceShadowGradient: NSGradient?
        let darkFaceGradient: NSGradient?
        let darkFaceStrokeColor: NSColor
        let lightFaceGradient: NSGradient?
        let lightFaceStrokeColor: NSColor
        let glossColor: NSColor

        init(tokens: KeycapThemeTokens) {
            let bodyEdge = tokens.surfaceShadowColor.darkened(by: 0.08)
            let bodyCenter = tokens.surfaceBaseColor.darkened(by: 0.10)
            let darkFaceTop = tokens.surfaceBaseColor.lightened(by: 0.03)
            let darkFaceBottom = tokens.surfaceBaseColor.darkened(by: 0.01)
            let lightFaceTop = tokens.surfaceHighlightColor.lightened(by: 0.08)
            let lightFaceBottom = tokens.surfaceBaseColor
            let groupBackgroundColor = tokens.recessColor.darkened(by: 0.40)
            let groupStrokeColor = tokens.surfaceBaseColor.withAlphaComponent(0.70)
            let lipEdge = tokens.recessColor.darkened(by: 0.34).withAlphaComponent(0.96)
            let lipCenter = tokens.recessColor.darkened(by: 0.12).withAlphaComponent(0.86)
            let bodyStrokeColor = tokens.surfaceBorderColor.withAlphaComponent(0.20)
            let darkFaceStrokeColor = tokens.surfaceBorderColor.withAlphaComponent(0.20)
            let faceShadowEdge = tokens.recessColor.darkened(by: 0.34).withAlphaComponent(0.46)
            let faceShadowCenter = tokens.recessColor.darkened(by: 0.12).withAlphaComponent(0.26)

            self.shared = Shared(
                badgeFillColor: tokens.badgeFillColor,
                badgeHighlightColor: tokens.badgeHighlightColor,
                badgeStrokeColor: tokens.badgeStrokeColor,
                badgeTextColor: tokens.badgeTextColor,
                groupBackgroundColor: groupBackgroundColor,
                groupStrokeColor: groupStrokeColor,
                textColor: tokens.textColor
            )
            self.lipGradient = NSGradient(colorsAndLocations:
                (lipEdge, 0.0),
                (lipCenter, 0.5),
                (lipEdge, 1.0)
            )
            self.bodyShadowColor = NSColor.black.withAlphaComponent(0.6)
            self.bodyGradient = NSGradient(colorsAndLocations:
                (bodyEdge, 0.0),
                (bodyCenter, 0.32),
                (bodyCenter, 0.68),
                (bodyEdge, 1.0)
            )
            self.bodyStrokeColor = bodyStrokeColor
            self.faceShadowGradient = NSGradient(colorsAndLocations:
                (faceShadowEdge, 0.0),
                (faceShadowCenter, 0.5),
                (faceShadowEdge, 1.0)
            )
            self.darkFaceGradient = NSGradient(colorsAndLocations:
                (darkFaceTop, 0.0),
                (darkFaceBottom, 1.0)
            )
            self.darkFaceStrokeColor = darkFaceStrokeColor
            self.lightFaceGradient = NSGradient(colorsAndLocations:
                (lightFaceTop, 0.0),
                (lightFaceBottom, 1.0)
            )
            self.lightFaceStrokeColor = tokens.surfaceBorderColor.withAlphaComponent(0.55)
            self.glossColor = NSColor(white: 1, alpha: 0.08)
        }
    }
}
