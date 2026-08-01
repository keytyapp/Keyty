//
//  CGRect+NormalizedPoint.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics

public extension CGRect {
    /// Returns `point` as a normalized coordinate within this rectangle.
    ///
    /// The returned point is clamped to `0...1` on both axes. Empty dimensions are
    /// treated as `1` to avoid division by zero.
    func normalizedPoint(for point: CGPoint) -> CGPoint {
        CGPoint(
            x: ((point.x - self.minX) / Swift.max(self.width, 1)).clamped(to: 0...1),
            y: ((point.y - self.minY) / Swift.max(self.height, 1)).clamped(to: 0...1)
        )
    }
}
