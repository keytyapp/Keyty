//
//  CGRect+Distance.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics

public extension CGRect {
    /// Returns the squared distance from this rectangle to `point`.
    ///
    /// Points inside the rectangle have a distance of zero.
    func squaredDistance(to point: CGPoint) -> CGFloat {
        let dx: CGFloat
        if point.x < self.minX {
            dx = self.minX - point.x
        } else if point.x > self.maxX {
            dx = point.x - self.maxX
        } else {
            dx = 0
        }

        let dy: CGFloat
        if point.y < self.minY {
            dy = self.minY - point.y
        } else if point.y > self.maxY {
            dy = point.y - self.maxY
        } else {
            dy = 0
        }

        return dx * dx + dy * dy
    }
}
