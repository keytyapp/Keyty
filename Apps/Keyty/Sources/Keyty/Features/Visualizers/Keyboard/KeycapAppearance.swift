//
//  KeycapAppearance.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

struct KeycapThemeTokens {
    let swatchColor: NSColor
    let textColor: NSColor
    
    let groupBackgroundColor: NSColor
    let groupStrokeColor: NSColor
    
    let badgeFillColor: NSColor
    let badgeStrokeColor: NSColor
    let badgeHighlightColor: NSColor
    let badgeTextColor: NSColor
    
    let surfaceHighlightColor: NSColor
    let surfaceBaseColor: NSColor
    let surfaceShadowColor: NSColor
    let surfaceBorderColor: NSColor
    
    let recessColor: NSColor
    /// Optional Apple-style underside edge color override. Falls back to `recessColor`.
    let undersideEdgeColor: NSColor?
    /// Optional Apple-style underside center color override. Falls back to `surfaceBaseColor`.
    let undersideCenterColor: NSColor?
}

enum KeycapAppearance {
    case apple(Apple)
    case pbt(PBT)
    case minimal(Minimal)
    case retro(Retro)
    case m0116(M0116)

    static let dotColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.1, alpha: 1)
    static let inactiveDotColor = NSColor(calibratedWhite: 0.42, alpha: 0.7)

    var textColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.textColor
        case .pbt(let appearance): appearance.textColor
        case .minimal(let appearance): appearance.textColor
        case .retro(let appearance): appearance.textColor
        case .m0116(let appearance): appearance.textColor
        }
    }

    var groupBackgroundColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.groupBackgroundColor
        case .pbt(let appearance): appearance.groupBackgroundColor
        case .minimal(let appearance): appearance.groupBackgroundColor
        case .retro(let appearance): appearance.groupBackgroundColor
        case .m0116(let appearance): appearance.groupBackgroundColor
        }
    }

    var groupStrokeColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.groupStrokeColor
        case .pbt(let appearance): appearance.groupStrokeColor
        case .minimal(let appearance): appearance.groupStrokeColor
        case .retro(let appearance): appearance.groupStrokeColor
        case .m0116(let appearance): appearance.groupStrokeColor
        }
    }

    var badgeFillColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.badgeFillColor
        case .pbt(let appearance): appearance.badgeFillColor
        case .minimal(let appearance): appearance.badgeFillColor
        case .retro(let appearance): appearance.badgeFillColor
        case .m0116(let appearance): appearance.badgeFillColor
        }
    }

    var badgeStrokeColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.badgeStrokeColor
        case .pbt(let appearance): appearance.badgeStrokeColor
        case .minimal(let appearance): appearance.badgeStrokeColor
        case .retro(let appearance): appearance.badgeStrokeColor
        case .m0116(let appearance): appearance.badgeStrokeColor
        }
    }

    var badgeHighlightColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.badgeHighlightColor
        case .pbt(let appearance): appearance.badgeHighlightColor
        case .minimal(let appearance): appearance.badgeHighlightColor
        case .retro(let appearance): appearance.badgeHighlightColor
        case .m0116(let appearance): appearance.badgeHighlightColor
        }
    }

    var badgeTextColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.badgeTextColor
        case .pbt(let appearance): appearance.badgeTextColor
        case .minimal(let appearance): appearance.badgeTextColor
        case .retro(let appearance): appearance.badgeTextColor
        case .m0116(let appearance): appearance.badgeTextColor
        }
    }

    var apple: Apple? {
        guard case .apple(let appearance) = self else { return nil }
        return appearance
    }

    var pbt: PBT? {
        guard case .pbt(let appearance) = self else { return nil }
        return appearance
    }

    var minimal: Minimal? {
        guard case .minimal(let appearance) = self else { return nil }
        return appearance
    }

    var retro: Retro? {
        guard case .retro(let appearance) = self else { return nil }
        return appearance
    }

    var m0116: M0116? {
        guard case .m0116(let appearance) = self else { return nil }
        return appearance
    }
}

// MARK: -  Appearances helpers
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

    struct PBT {
        let textColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
        let badgeFillColor: NSColor
        let badgeStrokeColor: NSColor
        let badgeHighlightColor: NSColor
        let badgeTextColor: NSColor
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

            self.textColor = tokens.textColor
            self.groupBackgroundColor = tokens.groupBackgroundColor
            self.groupStrokeColor = tokens.groupStrokeColor
            self.badgeFillColor = tokens.badgeFillColor
            self.badgeStrokeColor = tokens.badgeStrokeColor
            self.badgeHighlightColor = tokens.badgeHighlightColor
            self.badgeTextColor = tokens.badgeTextColor
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

    struct Minimal {
        let textColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
        let badgeFillColor: NSColor
        let badgeStrokeColor: NSColor
        let badgeHighlightColor: NSColor
        let badgeTextColor: NSColor

        init(tokens: KeycapThemeTokens) {
            self.textColor = tokens.textColor
            self.groupBackgroundColor = tokens.groupBackgroundColor
            self.groupStrokeColor = tokens.groupStrokeColor
            self.badgeFillColor = tokens.badgeFillColor
            self.badgeStrokeColor = tokens.badgeStrokeColor
            self.badgeHighlightColor = tokens.badgeHighlightColor
            self.badgeTextColor = tokens.badgeTextColor
        }
    }
    
    struct Retro {
        let textColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
        let badgeFillColor: NSColor
        let badgeStrokeColor: NSColor
        let badgeHighlightColor: NSColor
        let badgeTextColor: NSColor
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

            self.textColor = tokens.textColor
            self.groupBackgroundColor = groupBackgroundColor
            self.groupStrokeColor = groupStrokeColor
            self.badgeFillColor = tokens.badgeFillColor
            self.badgeStrokeColor = tokens.badgeStrokeColor
            self.badgeHighlightColor = tokens.badgeHighlightColor
            self.badgeTextColor = tokens.badgeTextColor
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

    /// Sculpted beige-era keycap: a lit body, an inset top face, and a front skirt,
    /// all sitting in a near-black well like the plate of an Apple Standard Keyboard.
    struct M0116 {
        let textColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
        let badgeFillColor: NSColor
        let badgeStrokeColor: NSColor
        let badgeHighlightColor: NSColor
        let badgeTextColor: NSColor
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

            self.textColor = tokens.textColor
            self.groupBackgroundColor = tokens.groupBackgroundColor
            self.groupStrokeColor = tokens.groupStrokeColor
            self.badgeFillColor = tokens.badgeFillColor
            self.badgeStrokeColor = tokens.badgeStrokeColor
            self.badgeHighlightColor = tokens.badgeHighlightColor
            self.badgeTextColor = tokens.badgeTextColor
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
