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

    /// This alignment's edge of `frame` — the point the stored normalized position names.
    func anchorX(in frame: CGRect) -> CGFloat {
        switch self {
        case .leading:  return frame.minX
        case .center:   return frame.midX
        case .trailing: return frame.maxX
        }
    }

    /// Frame of `size` whose aligned edge sits on the normalized position and which is
    /// vertically centered on it, clamped inside `visibleFrame`.
    func frame(for size: CGSize, atNormalized position: CGPoint, in visibleFrame: CGRect) -> CGRect {
        let anchor = visibleFrame.point(forNormalized: position)
        let origin = CGPoint(
            x: self.originX(for: size.width, anchoredAt: anchor.x)
                .clamped(minimum: visibleFrame.minX, maximum: visibleFrame.maxX - size.width),
            y: (anchor.y - size.height / 2)
                .clamped(minimum: visibleFrame.minY, maximum: visibleFrame.maxY - size.height)
        )

        return CGRect(origin: origin, size: size)
    }
}
