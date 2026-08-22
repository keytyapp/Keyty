//
//  PBTKeycapRenderer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

struct PBTKeycapRenderer: KeycapRendering {
    private let legendRenderer = KeycapLegendRenderer()

    func size(for context: KeycapContext) -> CGSize {
        let width = keycapWidth(for: context.item) + 2 * PBTKeycapMetrics.rim
        let height = AppleKeycapMetrics.height + 2 * PBTKeycapMetrics.rim
        return CGSize(width: width, height: height)
    }

    func draw(context: KeycapContext, in rect: NSRect) {
        let item = context.item
        let appearance = context.pbtAppearance
        let press: CGFloat = item.isPressed ? -PBTKeycapMetrics.pressedTravel : 0
        let dishLift = PBTKeycapMetrics.dishLift

        let bodyRect = rect.insetBy(dx: PBTKeycapMetrics.bodyInset, dy: PBTKeycapMetrics.bodyInset)
        let bodyPath = NSBezierPath(
            roundedRect: bodyRect,
            xRadius: PBTKeycapMetrics.cornerRadius,
            yRadius: PBTKeycapMetrics.cornerRadius
        )

        NSGraphicsContext.saveGraphicsState()
        let dropShadow = NSShadow()
        dropShadow.shadowColor = NSColor.black.withAlphaComponent(0.72)
        dropShadow.shadowBlurRadius = 6
        dropShadow.shadowOffset = NSSize(width: 0, height: -2)
        dropShadow.set()
        bodyPath.addClip()
        appearance.bodyGradient?.draw(
            from: NSPoint(x: bodyRect.minX, y: bodyRect.maxY),
            to: NSPoint(x: bodyRect.maxX, y: bodyRect.minY),
            options: []
        )
        NSGraphicsContext.restoreGraphicsState()

        appearance.bodyStrokeColor.withAlphaComponent(0.75).setStroke()
        bodyPath.lineWidth = 1.5
        bodyPath.stroke()

        let underDishRect = bodyRect
            .insetBy(dx: PBTKeycapMetrics.rim, dy: PBTKeycapMetrics.rim)
            .offsetBy(dx: 0, dy: dishLift + press - 2.5)
        let underDishPath = NSBezierPath(
            roundedRect: underDishRect,
            xRadius: PBTKeycapMetrics.dishCornerRadius,
            yRadius: PBTKeycapMetrics.dishCornerRadius
        )
        appearance.underDishColor.setFill()
        underDishPath.fill()

        let dishRect = bodyRect
            .insetBy(dx: PBTKeycapMetrics.rim, dy: PBTKeycapMetrics.rim)
            .offsetBy(dx: 0, dy: dishLift + press)
        let dishPath = NSBezierPath(
            roundedRect: dishRect,
            xRadius: PBTKeycapMetrics.dishCornerRadius,
            yRadius: PBTKeycapMetrics.dishCornerRadius
        )
        if appearance.dishGradient != nil {
            NSGraphicsContext.saveGraphicsState()
            dishPath.addClip()
            appearance.dishGradient?.draw(
                from: NSPoint(x: dishRect.maxX, y: dishRect.minY),
                to: NSPoint(x: dishRect.minX, y: dishRect.maxY),
                options: []
            )
            NSGraphicsContext.restoreGraphicsState()
        } else {
            appearance.underDishColor.setFill()
            dishPath.fill()
        }

        legendRenderer.draw(item: item, in: dishRect, textColor: appearance.textColor)
    }
}
