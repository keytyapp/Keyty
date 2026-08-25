//
//  KeycapAppearance+Minimal.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapAppearance {
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
}
