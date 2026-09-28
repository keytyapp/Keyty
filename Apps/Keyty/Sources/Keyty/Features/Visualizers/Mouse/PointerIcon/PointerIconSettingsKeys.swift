//
//  PointerIconSettingsKeys.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

enum PointerIconSettingsKeys {
    static let isEnabled        = "pointer_icon.isEnabled"
    static let alwaysVisible    = "pointer_icon.alwaysVisible"
    static let anchor           = "pointer_icon.anchor"
    static let offset           = "pointer_icon.offset"
    static let backgroundColor  = "pointer_icon.backgroundColor"
    static let tintColor        = "pointer_icon.tintColor"
    static let size             = "pointer_icon.size"
    static let clickDisplayDuration = "pointer_icon.clickDisplayDuration"
    static let scrollDisplayDuration = "pointer_icon.scrollDisplayDuration"

    static let defaultAlwaysVisible:   Bool              = true
    static let defaultAnchor:          PointerIconAnchor = .bottomRight
    static let defaultOffset:          CGFloat           = 12
    static let defaultBackgroundColor: NSColor           = Color.Theme.Palette.black60
    static let defaultTintColor:       NSColor           = Color.Theme.Palette.white
    static let defaultSizeIndex:       Int               = 2
    static let defaultClickDisplayDuration: CGFloat = 0
    static let defaultScrollDisplayDuration: CGFloat = 0.35
    static let clickDisplayDurationRange: ClosedRange<CGFloat> = 0...2
    static let scrollDisplayDurationRange: ClosedRange<CGFloat> = 0.1...2

    // 10 preset icon sizes (w×h), aspect ratio ~3:4
    static let iconSizes: [NSSize] = [
        NSSize(width: 24, height: 32),  // XS
        NSSize(width: 26, height: 35),  // XS/XS-S
        NSSize(width: 28, height: 37),  // XS/S
        NSSize(width: 33, height: 44),  // S
        NSSize(width: 36, height: 48),  // S/S-M
        NSSize(width: 40, height: 53),  // S/M
        NSSize(width: 48, height: 64),  // M
        NSSize(width: 54, height: 72),  // M/L
        NSSize(width: 60, height: 80),  // L
        NSSize(width: 72, height: 96),  // XL
    ]

}
