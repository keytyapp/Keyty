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

    static let dotColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.1, alpha: 1)
    static let inactiveDotColor = NSColor(calibratedWhite: 0.42, alpha: 0.7)

    var textColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.textColor
        case .pbt(let appearance): appearance.textColor
        case .minimal(let appearance): appearance.textColor
        case .retro(let appearance): appearance.textColor
        }
    }

    var groupBackgroundColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.groupBackgroundColor
        case .pbt(let appearance): appearance.groupBackgroundColor
        case .minimal(let appearance): appearance.groupBackgroundColor
        case .retro(let appearance): appearance.groupBackgroundColor
        }
    }

    var groupStrokeColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.groupStrokeColor
        case .pbt(let appearance): appearance.groupStrokeColor
        case .minimal(let appearance): appearance.groupStrokeColor
        case .retro(let appearance): appearance.groupStrokeColor
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
}

// MARK: -  Appearances helpers
extension KeycapAppearance {
    struct Apple {
        let textColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
        let strokeColor: NSColor
        let undersideGradient: NSGradient?
        let mainGradient: NSGradient?

        init(tokens: KeycapThemeTokens) {
            self.textColor = tokens.textColor
            self.groupBackgroundColor = tokens.groupBackgroundColor
            self.groupStrokeColor = tokens.groupStrokeColor
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

        init(tokens: KeycapThemeTokens) {
            self.textColor = tokens.textColor
            self.groupBackgroundColor = tokens.groupBackgroundColor
            self.groupStrokeColor = tokens.groupStrokeColor
        }
    }
    
    struct Retro {
        let textColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
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
