//
//  PointerRingSettingsKeys.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum PointerRingSettingsKeys {
    static let isEnabled = "pointer_ring.isEnabled"
    static let alwaysVisible = "pointer_ring.alwaysVisible"
    static let color = "pointer_ring.color"
    static let size = "pointer_ring.size"
    static let thickness = "pointer_ring.thickness"
    static let shape = "pointer_ring.shape"
    static let displayDuration = "pointer_ring.displayDuration"
    static let fadeDuration = "pointer_ring.fadeDuration"
    
    static let defaultIsEnabled = false
    static let defaultAlwaysVisible = false
    static let defaultColor = automaticVisualizerColor.hexString
    static let defaultSize = CGFloat(75)
    static let defaultThickness = CGFloat(5)
    static let defaultShape = PointerRingShape.circle
    static let defaultDisplayDuration = CGFloat(0)
    static let defaultFadeDuration = CGFloat(0.25)
    static let sizeRange: ClosedRange<CGFloat> = 24...96
    static let thicknessRange: ClosedRange<CGFloat> = 1...12
    static let displayDurationRange: ClosedRange<CGFloat> = 0...2
    static let fadeDurationRange: ClosedRange<CGFloat> = 0.2...1

    static var automaticVisualizerColor: NSColor {
        return .controlAccentColor
    }
}
