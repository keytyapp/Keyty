//
//  KeycapMetrics.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum CommonKeycapMetrics {
    static let horizontalPadding: CGFloat = 10
    static let symbolFont = NSFont.systemFont(ofSize: 22, weight: .medium)
    static let labelFont = NSFont.systemFont(ofSize: 14, weight: .medium)
    static let charFont = NSFont.systemFont(ofSize: 24, weight: .medium)

    /// Shared keycap widths for left and right variants of each modifier kind.
    static let fixedModifierWidths: [KeyboardModifierKey.Kind: CGFloat] = [
        .command: 88,
        .option: 72,
        .shift: 100,
    ]

    /// Fixed widths for individual key identities whose legends need custom sizing.
    static let fixedIdentityWidths: [KeycapIdentity: CGFloat] = [
        .keyCode(KeyboardKeyCode.tab.rawValue): 112,
        .keyCode(KeyboardKeyCode.escape.rawValue): 112,
        .keyCode(KeyboardKeyCode.delete.rawValue): 112,
        .keyCode(KeyboardKeyCode.forwardDelete.rawValue): 112,
        .keyCode(KeyboardKeyCode.home.rawValue): AppleKeycapMetrics.minWidth,
        .keyCode(KeyboardKeyCode.end.rawValue): AppleKeycapMetrics.minWidth,
        .keyCode(KeyboardKeyCode.pageUp.rawValue): AppleKeycapMetrics.minWidth,
        .keyCode(KeyboardKeyCode.pageDown.rawValue): AppleKeycapMetrics.minWidth,
        .keyCode(KeyboardKeyCode.returnKey.rawValue): 128,
        .keyCode(KeyboardKeyCode.keypadEnter.rawValue): 128,
        .keyCode(KeyboardKeyCode.capsLock.rawValue): 144,
    ]
}

enum AppleKeycapMetrics {
    static let height: CGFloat = 74
    static let minWidth: CGFloat = 74
    static let itemSpacing: CGFloat = 6
    static let groupPadding = NSEdgeInsets(top: 10, left: 10, bottom: 18, right: 10)
    static let repeatBadgeInset = CGPoint(x: 6, y: 6)
}

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

enum RetroKeycapMetrics {
    static let height: CGFloat = 96
    static let bodyCornerRadius: CGFloat = 24
    static let faceCornerRadius: CGFloat = 20
    static let faceSideInset: CGFloat = 4
    static let extraWidth: CGFloat = 8
    static let faceTopInset: CGFloat = 7
    static let faceBottomInset: CGFloat = 14
    static let minWidth: CGFloat = 96
    static let horizontalPadding: CGFloat = 24
    static let itemSpacing: CGFloat = 10
    static let groupPadding = NSEdgeInsets(top: 12, left: 12, bottom: 16, right: 12)
    static let repeatBadgeInset = CGPoint(x: 6, y: 6)
    static let pressedTravel: CGFloat = 3
}

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

extension KeycapStyle {
    /// Base (unscaled) group-box height for the style: the keycap height plus the
    /// top and bottom of its group padding.
    var baseGroupHeight: CGFloat {
        switch self {
        case .apple:
            return AppleKeycapMetrics.height
                + AppleKeycapMetrics.groupPadding.top + AppleKeycapMetrics.groupPadding.bottom
        case .pbt:
            return AppleKeycapMetrics.height + 2 * PBTKeycapMetrics.rim
                + PBTKeycapMetrics.groupPadding.top + PBTKeycapMetrics.groupPadding.bottom
        case .minimal:
            return MinimalKeycapMetrics.height
                + MinimalKeycapMetrics.groupPadding.top + MinimalKeycapMetrics.groupPadding.bottom
        case .retro:
            return RetroKeycapMetrics.height
                + RetroKeycapMetrics.groupPadding.top + RetroKeycapMetrics.groupPadding.bottom
        }
    }

    /// Uniform factor that normalizes each style's base box height to Apple's, so the size
    /// slider produces a comparable rendered size across all styles at any scale.
    var sizeNormalization: CGFloat {
        KeycapStyle.apple.baseGroupHeight / baseGroupHeight
    }
}
