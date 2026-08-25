//
//  M0116KeycapRenderer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Draws a sculpted Apple Standard Keyboard (M0116) keycap: a near-black well, a body lit
/// from the left, an inset top face, and the lit front skirt below it. Text legends sit on a
/// shared baseline in the lower-left corner, the way the originals were printed.
struct M0116KeycapRenderer: KeycapRendering {
    private let legendRenderer = KeycapLegendRenderer()

    func size(for context: KeycapContext) -> CGSize {
        CGSize(
            width: self.m0116KeycapWidth(for: context.item),
            height: M0116KeycapMetrics.height
        )
    }

    func draw(context: KeycapContext, in rect: NSRect) {
        let item = context.item
        let appearance = context.m0116Appearance
        let press = item.isPressed ? -M0116KeycapMetrics.pressedTravel : 0
        let bodyRect = rect.offsetBy(dx: 0, dy: press)

        self.drawWell(around: rect, appearance: appearance)

        let bodyPath = NSBezierPath(
            roundedRect: bodyRect,
            xRadius: M0116KeycapMetrics.bodyCornerRadius,
            yRadius: M0116KeycapMetrics.bodyCornerRadius
        )
        let faceRect = self.faceRect(in: bodyRect)
        let facePath = NSBezierPath(
            roundedRect: faceRect,
            xRadius: M0116KeycapMetrics.faceCornerRadius,
            yRadius: M0116KeycapMetrics.faceCornerRadius
        )

        NSGraphicsContext.saveGraphicsState()
        bodyPath.addClip()
        appearance.bodyGradient?.draw(
            from: NSPoint(x: bodyRect.minX, y: bodyRect.midY),
            to: NSPoint(x: bodyRect.maxX, y: bodyRect.midY),
            options: []
        )
        appearance.skirtGradient?.draw(
            in: NSRect(
                x: bodyRect.minX,
                y: bodyRect.minY,
                width: bodyRect.width,
                height: M0116KeycapMetrics.faceBottomInset
            ),
            angle: 90
        )
        NSGraphicsContext.restoreGraphicsState()

        NSGraphicsContext.saveGraphicsState()
        facePath.addClip()
        appearance.faceGradient?.draw(in: facePath, angle: 90)
        NSGraphicsContext.restoreGraphicsState()

        appearance.creaseColor.setStroke()
        facePath.lineWidth = StrokeWidth.standard
        facePath.stroke()

        appearance.bodyStrokeColor.setStroke()
        bodyPath.lineWidth = StrokeWidth.standard
        bodyPath.stroke()

        self.drawLegend(item: item, in: faceRect, textColor: appearance.textColor)
    }
}

// MARK: - Geometry
private extension M0116KeycapRenderer {
    /// The shared width helper measures legends in the app-wide label font. This style sets
    /// them in a larger italic face, so the text is re-measured here to keep it from clipping.
    func m0116KeycapWidth(for item: KeycapItem) -> CGFloat {
        let sideInsets = 2 * (M0116KeycapMetrics.horizontalPadding + M0116KeycapMetrics.faceSideInset)
        var legendWidth: CGFloat = 0
        if let label = item.label {
            legendWidth = label.size(withAttributes: [.font: M0116KeycapMetrics.labelFont]).width
        } else if item.image == nil, item.sfSymbolName == nil {
            legendWidth = item.symbol.size(withAttributes: [.font: M0116KeycapMetrics.charFont]).width
        }
        if item.label != nil, !item.symbol.isEmpty {
            legendWidth = max(
                legendWidth,
                item.symbol.size(withAttributes: [.font: M0116KeycapMetrics.symbolFont]).width
            )
        }

        return max(
            M0116KeycapMetrics.minWidth,
            keycapWidth(for: item),
            (legendWidth + sideInsets).rounded(.up)
        )
    }

    func faceRect(in bodyRect: NSRect) -> NSRect {
        NSRect(
            x: bodyRect.minX + M0116KeycapMetrics.faceSideInset,
            y: bodyRect.minY + M0116KeycapMetrics.faceBottomInset,
            width: bodyRect.width - 2 * M0116KeycapMetrics.faceSideInset,
            height: bodyRect.height - M0116KeycapMetrics.faceTopInset - M0116KeycapMetrics.faceBottomInset
        )
    }

    /// The recess the cap sits in. It reaches half the item spacing to each side so
    /// adjacent wells meet, leaving one uninterrupted dark plate between the caps.
    func drawWell(around rect: NSRect, appearance: KeycapAppearance.M0116) {
        let wellRect = NSRect(
            x: rect.minX - M0116KeycapMetrics.wellSideInset,
            y: rect.minY - M0116KeycapMetrics.wellBottomInset,
            width: rect.width + 2 * M0116KeycapMetrics.wellSideInset,
            height: rect.height + M0116KeycapMetrics.wellBottomInset + M0116KeycapMetrics.wellTopInset
        )
        appearance.wellColor.setFill()
        NSBezierPath(
            roundedRect: wellRect,
            xRadius: M0116KeycapMetrics.bodyCornerRadius + 2,
            yRadius: M0116KeycapMetrics.bodyCornerRadius + 2
        ).fill()
    }
}

// MARK: - Legends
private extension M0116KeycapRenderer {
    func drawLegend(item: KeycapItem, in faceRect: NSRect, textColor: NSColor) {
        guard self.rendersOwnLegend(for: item) else {
            self.legendRenderer.draw(item: item, in: faceRect, textColor: textColor)
            return
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let x = faceRect.minX + M0116KeycapMetrics.horizontalPadding
        let baseline = faceRect.minY + M0116KeycapMetrics.legendBaselineInset

        let baseText = item.label ?? item.symbol
        let baseFont = item.label == nil ? M0116KeycapMetrics.charFont : M0116KeycapMetrics.labelFont
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle,
        ]
        baseText.draw(at: NSPoint(x: x, y: baseline), withAttributes: baseAttributes)

        // Keys carrying both a symbol and a label stack the symbol above the baseline,
        // mirroring the shifted legends printed on the original caps.
        if item.label != nil, !item.symbol.isEmpty {
            let symbolAttributes: [NSAttributedString.Key: Any] = [
                .font: M0116KeycapMetrics.symbolFont,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle,
            ]
            let baseHeight = baseText.size(withAttributes: baseAttributes).height
            item.symbol.draw(
                at: NSPoint(x: x, y: baseline + baseHeight - 2),
                withAttributes: symbolAttributes
            )
        }

        if item.state.showsDot {
            self.legendRenderer.drawKeycapDot(in: faceRect, active: item.state.isDotActive)
        }
    }

    /// Image and SF Symbol legends keep the shared centered treatment; only text legends
    /// take the M0116's lower-left baseline.
    func rendersOwnLegend(for item: KeycapItem) -> Bool {
        guard item.image == nil, !item.rendersSymbolWithLabel, !item.rendersCenteredLabel else {
            return false
        }
        if item.label != nil {
            return true
        }
        return item.sfSymbolName == nil && !item.symbol.isEmpty
    }
}
