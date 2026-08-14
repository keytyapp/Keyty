//
//  KeyboardVisualizerAlignment+Placement.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics

/// Geometry helpers for custom overlay placement, shared by:
/// - overlay window
/// - placement preview window
///
/// To make sure all resolve the anchor the same way.
extension KeyboardVisualizerAlignment {
    /// Leading edge of `width` when this alignment's edge sits on `x`.
    func originX(for width: CGFloat, anchoredAt x: CGFloat) -> CGFloat {
        switch self {
        case .leading:  return x
        case .center:   return x - width / 2
        case .trailing: return x - width
        }
    }

    /// Bottom edge of `height` when this alignment's edge sits on `y`.
    ///
    /// AppKit's y grows upward, so `leading` is the bottom edge and `trailing` the top one.
    func originY(for height: CGFloat, anchoredAt y: CGFloat) -> CGFloat {
        switch self {
        case .leading:  return y
        case .center:   return y - height / 2
        case .trailing: return y - height
        }
    }

    /// This alignment's edge of `frame` — the point the stored normalized position names.
    func anchorX(in frame: CGRect) -> CGFloat {
        switch self {
        case .leading:  return frame.minX
        case .center:   return frame.midX
        case .trailing: return frame.maxX
        }
    }

    /// This alignment's edge of `frame` on the vertical axis.
    func anchorY(in frame: CGRect) -> CGFloat {
        switch self {
        case .leading:  return frame.minY
        case .center:   return frame.midY
        case .trailing: return frame.maxY
        }
    }

    /// Frame of `size` whose aligned edges sit on the normalized position, clamped inside
    /// `visibleFrame`.
    static func frame(
        for size: CGSize,
        atNormalized position: CGPoint,
        in visibleFrame: CGRect,
        horizontal: KeyboardVisualizerAlignment,
        vertical: KeyboardVisualizerAlignment
    ) -> CGRect {
        let anchor = visibleFrame.point(forNormalized: position)
        let origin = CGPoint(
            x: horizontal.originX(for: size.width, anchoredAt: anchor.x)
                .clamped(minimum: visibleFrame.minX, maximum: visibleFrame.maxX - size.width),
            y: vertical.originY(for: size.height, anchoredAt: anchor.y)
                .clamped(minimum: visibleFrame.minY, maximum: visibleFrame.maxY - size.height)
        )

        return CGRect(origin: origin, size: size)
    }
}
