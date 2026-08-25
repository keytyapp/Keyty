//
//  M0116Palette.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapThemeTokens {
    /// The Apple Standard Keyboard's own colors, sampled from the hardware: cool off-white
    /// caps, a warm olive case, and the near-black plate showing through between the keys.
    ///
    /// The M0116 style paints from this palette rather than the selected theme, so it keeps
    /// the original color scheme whichever theme is active.
    static func m0116Hardware(legendColorOverride: NSColor? = nil) -> KeycapThemeTokens {
        let textColor = legendColorOverride
            ?? NSColor(calibratedRed: 0.290, green: 0.298, blue: 0.337, alpha: 1)
        let swatchColor = NSColor(calibratedRed: 0.898, green: 0.902, blue: 0.910, alpha: 1)
        let badge = KeyboardVisualizerTheme.badgeTokens(swatchColor: swatchColor, textColor: textColor)

        return KeycapThemeTokens(
            swatchColor: swatchColor,
            textColor: textColor,
            groupBackgroundColor: NSColor(calibratedRed: 0.827, green: 0.831, blue: 0.804, alpha: 0.94),
            groupStrokeColor: NSColor(calibratedRed: 0.596, green: 0.600, blue: 0.565, alpha: 0.70),
            badgeFillColor: badge.fill,
            badgeStrokeColor: badge.stroke,
            badgeHighlightColor: badge.highlight,
            badgeTextColor: badge.text,
            surfaceHighlightColor: NSColor(calibratedRed: 0.937, green: 0.941, blue: 0.949, alpha: 1),
            surfaceBaseColor: NSColor(calibratedRed: 0.898, green: 0.902, blue: 0.910, alpha: 1),
            surfaceShadowColor: NSColor(calibratedRed: 0.804, green: 0.808, blue: 0.820, alpha: 1),
            surfaceBorderColor: NSColor(calibratedRed: 0.404, green: 0.404, blue: 0.400, alpha: 1),
            recessColor: NSColor(calibratedRed: 0.267, green: 0.271, blue: 0.267, alpha: 1),
            undersideEdgeColor: NSColor(calibratedRed: 0.180, green: 0.184, blue: 0.180, alpha: 1),
            undersideCenterColor: NSColor(calibratedRed: 0.404, green: 0.408, blue: 0.400, alpha: 1)
        )
    }
}
