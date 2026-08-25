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

// MARK: - Shared Accessors
extension KeycapAppearance {
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
