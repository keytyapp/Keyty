//
//  AppleKeycapRenderer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

struct AppleKeycapRenderer: KeycapRendering {
    private let legendRenderer = KeycapLegendRenderer()

    func size(for context: KeycapContext) -> CGSize {
        CGSize(
            width: self.keycapWidth(for: context.item),
            height: AppleKeycapMetrics.height
        )
    }

    func draw(context: KeycapContext, in rect: NSRect) {
        let item = context.item
        let appearance = context.appleAppearance
        let baseKeycapRect = rect.insetBy(dx: 2, dy: 2)
        let keycapRect = baseKeycapRect.offsetBy(dx: 0, dy: item.isPressed ? -5 : 0)
        let undersideRect = baseKeycapRect.offsetBy(dx: 0, dy: -8)
        let path = NSBezierPath(roundedRect: keycapRect, xRadius: 8, yRadius: 8)
        let undersidePath = NSBezierPath(roundedRect: undersideRect, xRadius: 8, yRadius: 8)

        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.7)
        shadow.shadowBlurRadius = 4
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.set()
        appearance.undersideGradient?.draw(in: undersidePath, angle: 0)
        appearance.strokeColor.withAlphaComponent(0.5).setStroke()
        undersidePath.lineWidth = StrokeWidth.standard
        undersidePath.stroke()
        appearance.mainGradient?.draw(in: path, angle: 90)
        NSGraphicsContext.restoreGraphicsState()

        appearance.strokeColor.setStroke()
        path.lineWidth = StrokeWidth.standard
        path.stroke()

        self.legendRenderer.draw(item: item, in: keycapRect, textColor: appearance.textColor)
    }
}
