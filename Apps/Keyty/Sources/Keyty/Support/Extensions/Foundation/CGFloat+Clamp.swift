//
//  CGFloat+Clamp.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics

public extension CGFloat {
    /// Returns this value constrained to the provided closed range.
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }

    /// Returns this value constrained to `minimum...maximum`, or `minimum` when
    /// `maximum` is below `minimum`.
    func clamped(minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        guard maximum >= minimum else { return minimum }
        return self.clamped(to: minimum...maximum)
    }
}
