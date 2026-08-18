//
//  PointerRingAnimation.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum PointerRingAnimation {
    enum EventPhase {
        case press
        case drag
        case release
        case ignored
    }

    struct VisualState {
        let opacity: Double
        let scale: CGFloat

        static let pressed = Self(opacity: PointerRingAnimation.visibleOpacity, scale: PointerRingAnimation.clickScaleMultiplier)
        static let dragging = Self(opacity: PointerRingAnimation.visibleOpacity, scale: PointerRingAnimation.clickScaleMultiplier)

        static func idle(alwaysVisible: Bool) -> Self {
            Self(
                opacity: alwaysVisible ? PointerRingAnimation.visibleOpacity : PointerRingAnimation.hiddenOpacity,
                scale: 1
            )
        }

        static func released(alwaysVisible: Bool) -> Self {
            Self(
                opacity: alwaysVisible ? PointerRingAnimation.visibleOpacity : PointerRingAnimation.hiddenOpacity,
                scale: 1
            )
        }
    }

    static let clickScaleMultiplier: CGFloat = 0.5
    static let visibleOpacity: Double = 1.0
    static let hiddenOpacity: Double = 0.0

    // A 45-degree rotated exponent-4 squircle extends beyond its axis-aligned bounds.
    static let rhombFitScale: CGFloat = 0.8408964152537146

    static let clickAnimationKey = "clickAnimation"
    static let scaleAnimationKey = "scaleAnimation"

    static let pressAnimationDuration: TimeInterval = 0.25
    static let releaseAnimationDuration: TimeInterval = 0.25
    static let spawnAnimationDuration: TimeInterval = 1.0
    static let spawnStartScale: CGFloat = 0.5
    static let spawnEndScale: CGFloat = 1.35

    static func eventPhase(for eventType: NSEvent.EventType) -> EventPhase {
        switch eventType {
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            return .press
        case .leftMouseDragged, .rightMouseDragged, .otherMouseDragged:
            return .drag
        case .leftMouseUp, .rightMouseUp, .otherMouseUp:
            return .release
        default:
            return .ignored
        }
    }
}
