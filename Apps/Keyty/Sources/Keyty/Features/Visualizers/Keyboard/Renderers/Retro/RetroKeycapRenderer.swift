//
//  RetroKeycapRenderer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

struct RetroKeycapRenderer: KeycapRendering {
    private let legendRenderer = KeycapLegendRenderer()

    func size(for context: KeycapContext) -> CGSize {
        CGSize(
            width: retroKeycapWidth(for: context.item),
            height: RetroKeycapMetrics.height
        )
    }

    func draw(context: KeycapContext, in rect: NSRect) {
        let item = context.item
        let appearance = context.retroAppearance
        let press = item.isPressed ? -RetroKeycapMetrics.pressedTravel : 0
        let bodyRect = rect.offsetBy(dx: 0, dy: press)
        let baseLipRect = NSRect(
            x: bodyRect.minX + 5,
            y: bodyRect.minY + 2,
            width: bodyRect.width - 10,
            height: bodyRect.height - 18
        )
        let baseLipPath = NSBezierPath(
            roundedRect: baseLipRect,
            xRadius: RetroKeycapMetrics.bodyCornerRadius,
            yRadius: RetroKeycapMetrics.bodyCornerRadius
        )
        let bodyPath = NSBezierPath(
            roundedRect: bodyRect,
            xRadius: RetroKeycapMetrics.bodyCornerRadius,
            yRadius: RetroKeycapMetrics.bodyCornerRadius
        )

        NSGraphicsContext.saveGraphicsState()
        baseLipPath.addClip()
        appearance.lipGradient?.draw(
            from: NSPoint(x: baseLipRect.minX, y: baseLipRect.midY),
            to: NSPoint(x: baseLipRect.maxX, y: baseLipRect.midY),
            options: []
        )
        NSGraphicsContext.restoreGraphicsState()

        NSGraphicsContext.saveGraphicsState()
        let bodyShadow = NSShadow()
        bodyShadow.shadowColor = appearance.bodyShadowColor
        bodyShadow.shadowBlurRadius = 6
        bodyShadow.shadowOffset = NSSize(width: 0, height: -1)
        bodyShadow.set()
        bodyPath.addClip()
        appearance.bodyGradient?.draw(
            from: NSPoint(x: bodyRect.minX, y: bodyRect.midY),
            to: NSPoint(x: bodyRect.maxX, y: bodyRect.midY),
            options: []
        )
        NSGraphicsContext.restoreGraphicsState()

        appearance.bodyStrokeColor.setStroke()
        bodyPath.lineWidth = 1.5
        bodyPath.stroke()

        let faceRect = NSRect(
            x: bodyRect.minX + RetroKeycapMetrics.faceSideInset,
            y: bodyRect.minY + RetroKeycapMetrics.faceBottomInset,
            width: bodyRect.width - 2 * RetroKeycapMetrics.faceSideInset,
            height: bodyRect.height - RetroKeycapMetrics.faceTopInset - RetroKeycapMetrics.faceBottomInset
        )
        let facePath = NSBezierPath(
            roundedRect: faceRect,
            xRadius: RetroKeycapMetrics.faceCornerRadius,
            yRadius: RetroKeycapMetrics.faceCornerRadius
        )

        let faceGradient = appearance.darkFaceGradient
        let faceStrokeColor = appearance.darkFaceStrokeColor

        NSGraphicsContext.saveGraphicsState()
        facePath.addClip()
        faceGradient?.draw(in: facePath, angle: -90)
        NSGraphicsContext.restoreGraphicsState()

        faceStrokeColor.setStroke()
        facePath.lineWidth = 1.25
        facePath.stroke()

        legendRenderer.draw(item: item, in: faceRect, textColor: appearance.textColor)
    }

    private func retroKeycapWidth(for item: KeycapItem) -> CGFloat {
        return keycapWidth(for: item) + 2 * RetroKeycapMetrics.faceSideInset + RetroKeycapMetrics.extraWidth
    }
}
