//
//  KeycapRendererSupport.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

@MainActor
protocol KeycapRendering {
    func size(for context: KeycapContext) -> CGSize
    func draw(context: KeycapContext, in rect: NSRect)
}

@MainActor
func keycapWidth(for item: KeycapItem) -> CGFloat {
    if let fixedWidth = item.fixedWidth {
        return fixedWidth
    }

    if let modifier = item.identity.modifierKind,
       let fixedWidth = CommonKeycapMetrics.fixedModifierWidths[modifier] {
        return fixedWidth
    }

    if let fixedWidth = CommonKeycapMetrics.fixedIdentityWidths[item.identity] {
        return fixedWidth
    }

    guard let label = item.label else {
        return AppleKeycapMetrics.minWidth
    }

    let textWidth = label.size(withAttributes: [.font: CommonKeycapMetrics.labelFont]).width
    return max(AppleKeycapMetrics.minWidth, textWidth + CommonKeycapMetrics.horizontalPadding * 2)
}
