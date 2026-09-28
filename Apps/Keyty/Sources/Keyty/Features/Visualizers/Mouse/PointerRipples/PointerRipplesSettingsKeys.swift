//
//  PointerRipplesSettingsKeys.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum PointerRipplesSettingsKeys {
    // Keep the persisted key names stable to preserve existing user preferences.
    static let isEnabled = "pointer_click_ring.isEnabled"
    static let color = "pointer_click_ring.color"
    static let size = "pointer_click_ring.size"
    static let thickness = "pointer_click_ring.thickness"
    static let shape = "pointer_click_ring.shape"
    static let duration = "pointer_click_ring.duration"

    static let defaultIsEnabled = false
    static let defaultColor = automaticVisualizerColor.hexString
    static let defaultSize = CGFloat(75)
    static let defaultThickness = CGFloat(5)
    static let defaultShape = PointerRingShape.circle
    static let defaultDuration = CGFloat(1)
    static let sizeRange: ClosedRange<CGFloat> = 24...96
    static let thicknessRange: ClosedRange<CGFloat> = 1...12
    static let durationRange: ClosedRange<CGFloat> = 0.5...2

    static var automaticVisualizerColor: NSColor {
        .controlAccentColor
    }
}
