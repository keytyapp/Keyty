//
//  KeycapStyle+SizeNormalization.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

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
        case .m0116:
            return M0116KeycapMetrics.height
                + M0116KeycapMetrics.groupPadding.top + M0116KeycapMetrics.groupPadding.bottom
        }
    }

    /// Uniform factor that normalizes each style's base box height to Apple's, so the size
    /// slider produces a comparable rendered size across all styles at any scale.
    var sizeNormalization: CGFloat {
        KeycapStyle.apple.baseGroupHeight / baseGroupHeight
    }
}
