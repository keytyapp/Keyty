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
}

extension KeycapAppearance {
    struct Shared {
        let textColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
        let badgeFillColor: NSColor
        let badgeStrokeColor: NSColor
        let badgeHighlightColor: NSColor
        let badgeTextColor: NSColor

        init(
            textColor: NSColor,
            groupBackgroundColor: NSColor,
            groupStrokeColor: NSColor,
            badgeFillColor: NSColor,
            badgeStrokeColor: NSColor,
            badgeHighlightColor: NSColor,
            badgeTextColor: NSColor
        ) {
            self.textColor = textColor
            self.groupBackgroundColor = groupBackgroundColor
            self.groupStrokeColor = groupStrokeColor
            self.badgeFillColor = badgeFillColor
            self.badgeStrokeColor = badgeStrokeColor
            self.badgeHighlightColor = badgeHighlightColor
            self.badgeTextColor = badgeTextColor
        }

        init(tokens: KeycapThemeTokens) {
            self.init(
                textColor: tokens.textColor,
                groupBackgroundColor: tokens.groupBackgroundColor,
                groupStrokeColor: tokens.groupStrokeColor,
                badgeFillColor: tokens.badgeFillColor,
                badgeStrokeColor: tokens.badgeStrokeColor,
                badgeHighlightColor: tokens.badgeHighlightColor,
                badgeTextColor: tokens.badgeTextColor
            )
        }
    }
}

// MARK: - Shared Accessors
extension KeycapAppearance {
    var textColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.shared.textColor
        case .pbt(let appearance): appearance.shared.textColor
        case .minimal(let appearance): appearance.shared.textColor
        case .retro(let appearance): appearance.shared.textColor
        case .m0116(let appearance): appearance.shared.textColor
        }
    }

    var groupBackgroundColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.shared.groupBackgroundColor
        case .pbt(let appearance): appearance.shared.groupBackgroundColor
        case .minimal(let appearance): appearance.shared.groupBackgroundColor
        case .retro(let appearance): appearance.shared.groupBackgroundColor
        case .m0116(let appearance): appearance.shared.groupBackgroundColor
        }
    }

    var groupStrokeColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.shared.groupStrokeColor
        case .pbt(let appearance): appearance.shared.groupStrokeColor
        case .minimal(let appearance): appearance.shared.groupStrokeColor
        case .retro(let appearance): appearance.shared.groupStrokeColor
        case .m0116(let appearance): appearance.shared.groupStrokeColor
        }
    }

    var badgeFillColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.shared.badgeFillColor
        case .pbt(let appearance): appearance.shared.badgeFillColor
        case .minimal(let appearance): appearance.shared.badgeFillColor
        case .retro(let appearance): appearance.shared.badgeFillColor
        case .m0116(let appearance): appearance.shared.badgeFillColor
        }
    }

    var badgeStrokeColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.shared.badgeStrokeColor
        case .pbt(let appearance): appearance.shared.badgeStrokeColor
        case .minimal(let appearance): appearance.shared.badgeStrokeColor
        case .retro(let appearance): appearance.shared.badgeStrokeColor
        case .m0116(let appearance): appearance.shared.badgeStrokeColor
        }
    }

    var badgeHighlightColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.shared.badgeHighlightColor
        case .pbt(let appearance): appearance.shared.badgeHighlightColor
        case .minimal(let appearance): appearance.shared.badgeHighlightColor
        case .retro(let appearance): appearance.shared.badgeHighlightColor
        case .m0116(let appearance): appearance.shared.badgeHighlightColor
        }
    }

    var badgeTextColor: NSColor {
        switch self {
        case .apple(let appearance): appearance.shared.badgeTextColor
        case .pbt(let appearance): appearance.shared.badgeTextColor
        case .minimal(let appearance): appearance.shared.badgeTextColor
        case .retro(let appearance): appearance.shared.badgeTextColor
        case .m0116(let appearance): appearance.shared.badgeTextColor
        }
    }

}

// MARK: - Case Accessors
extension KeycapAppearance {
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
