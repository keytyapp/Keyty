//
//  PBTKeycapMetrics.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum PBTKeycapMetrics {
    /// Rim added around the content for the PBT style. The dished top surface ends up the
    /// same size as an Apple keycap; the body extends beyond it by this amount on each side.
    static let rim: CGFloat = 13
    static let dishLift: CGFloat = 8
    static let cornerRadius: CGFloat = 18
    static let dishCornerRadius: CGFloat = 10
    static let pressedTravel: CGFloat = 2.5
    static let bodyInset: CGFloat = 2
    static let groupPadding = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    static let repeatBadgeInset = CGPoint(x: 6, y: 6)
}
