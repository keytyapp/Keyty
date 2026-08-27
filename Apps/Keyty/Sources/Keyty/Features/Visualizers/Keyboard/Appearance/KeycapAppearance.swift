//
//  KeycapAppearance.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Exposes the shared visual attributes every keycap appearance variant provides.
protocol KeycapAppearanceProviding {
    var shared: KeycapAppearance.Shared { get }
}

/// Enumerates the concrete keycap appearance variants the keyboard visualizer can render.
enum KeycapAppearance {
    case apple(Apple)
    case pbt(PBT)
    case minimal(Minimal)
    case retro(Retro)
    case m0116(M0116)

    static let dotColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.1, alpha: 1)
    static let inactiveDotColor = NSColor(calibratedWhite: 0.42, alpha: 0.7)
}

// MARK: - Shared Appearance
extension KeycapAppearance {
    /// Holds the color values reused across all keycap appearance variants.
    struct Shared {
        let badgeFillColor: NSColor
        let badgeHighlightColor: NSColor
        let badgeStrokeColor: NSColor
        let badgeTextColor: NSColor
        let groupBackgroundColor: NSColor
        let groupStrokeColor: NSColor
        let textColor: NSColor

        init(
            badgeFillColor: NSColor,
            badgeHighlightColor: NSColor,
            badgeStrokeColor: NSColor,
            badgeTextColor: NSColor,
            groupBackgroundColor: NSColor,
            groupStrokeColor: NSColor,
            textColor: NSColor
        ) {
            self.badgeFillColor = badgeFillColor
            self.badgeHighlightColor = badgeHighlightColor
            self.badgeStrokeColor = badgeStrokeColor
            self.badgeTextColor = badgeTextColor
            self.groupBackgroundColor = groupBackgroundColor
            self.groupStrokeColor = groupStrokeColor
            self.textColor = textColor
        }

        init(tokens: KeycapThemeTokens) {
            self.init(
                badgeFillColor: tokens.badgeFillColor,
                badgeHighlightColor: tokens.badgeHighlightColor,
                badgeStrokeColor: tokens.badgeStrokeColor,
                badgeTextColor: tokens.badgeTextColor,
                groupBackgroundColor: tokens.groupBackgroundColor,
                groupStrokeColor: tokens.groupStrokeColor,
                textColor: tokens.textColor
            )
        }
    }
}

// MARK: - Shared Accessors
extension KeycapAppearance {
    var shared: Shared {
        switch self {
        case .apple(let appearance): appearance.shared
        case .pbt(let appearance): appearance.shared
        case .minimal(let appearance): appearance.shared
        case .retro(let appearance): appearance.shared
        case .m0116(let appearance): appearance.shared
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
