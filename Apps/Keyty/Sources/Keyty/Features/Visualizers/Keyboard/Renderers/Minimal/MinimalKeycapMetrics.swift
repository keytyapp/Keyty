//
//  MinimalKeycapMetrics.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum MinimalKeycapMetrics {
    static let height: CGFloat = 48
    static let minWidth: CGFloat = 28
    static let horizontalPadding: CGFloat = 4
    static let itemSpacing: CGFloat = -8
    static let groupPadding = NSEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
    static let repeatBadgeInset = CGPoint(x: 0, y: 0)
    static let labelFont = NSFont.systemFont(ofSize: 26, weight: .medium)
    static let symbolFont = NSFont.systemFont(ofSize: 36, weight: .medium)
    static let imageMaxHeight: CGFloat = 36
    static let pressedScale: CGFloat = 0.78
}
