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
        let frontLipPath = self.frontLipPath(in: bodyRect, faceRect: faceRect)
        let facePath = self.facePath(in: faceRect)

        NSGraphicsContext.saveGraphicsState()
        bodyPath.addClip()
        appearance.bodyGradient?.draw(
            from: NSPoint(x: bodyRect.minX, y: bodyRect.midY),
            to: NSPoint(x: bodyRect.maxX, y: bodyRect.midY),
            options: []
        )
        NSGraphicsContext.restoreGraphicsState()

        NSGraphicsContext.saveGraphicsState()
        bodyPath.addClip()
        appearance.skirtGradient?.draw(in: frontLipPath, angle: 90)
        NSGraphicsContext.restoreGraphicsState()

        NSGraphicsContext.saveGraphicsState()
        facePath.addClip()
        appearance.faceGradient?.draw(in: facePath, angle: 90)
        NSGraphicsContext.restoreGraphicsState()

        appearance.creaseColor.setStroke()
        facePath.lineWidth = StrokeWidth.standard
        facePath.stroke()
        self.drawSideSeams(in: bodyRect, faceRect: faceRect, color: appearance.creaseColor)

        appearance.bodyStrokeColor.setStroke()
        bodyPath.lineWidth = StrokeWidth.standard
        bodyPath.stroke()

        self.drawLegend(item: item, in: faceRect, textColor: appearance.shared.textColor)
    }
}

// MARK: - Geometry
private extension M0116KeycapRenderer {
    /// The shared width helper measures legends in the app-wide label font. This style sets
    /// them in a larger italic face, so the text is re-measured here to keep it from clipping.
    func m0116KeycapWidth(for item: KeycapItem) -> CGFloat {
        if self.usesRegularNavigationWidth(item) {
            return M0116KeycapMetrics.minWidth
        }

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

    func facePath(in faceRect: NSRect) -> NSBezierPath {
        let radius = M0116KeycapMetrics.faceCornerRadius
        let path = NSBezierPath()
        let lowerCornerInset = radius * 0.95
        let lowerVerticalInset = radius * 0.28

        path.move(to: NSPoint(x: faceRect.minX + radius, y: faceRect.maxY))
        path.line(to: NSPoint(x: faceRect.maxX - radius, y: faceRect.maxY))
        path.curve(
            to: NSPoint(x: faceRect.maxX, y: faceRect.maxY - radius),
            controlPoint1: NSPoint(x: faceRect.maxX - radius * 0.45, y: faceRect.maxY),
            controlPoint2: NSPoint(x: faceRect.maxX, y: faceRect.maxY - radius * 0.45)
        )
        path.line(to: NSPoint(x: faceRect.maxX, y: faceRect.minY + lowerVerticalInset))
        path.curve(
            to: NSPoint(x: faceRect.maxX - lowerCornerInset, y: faceRect.minY),
            controlPoint1: NSPoint(x: faceRect.maxX, y: faceRect.minY + lowerVerticalInset * 0.35),
            controlPoint2: NSPoint(x: faceRect.maxX - lowerCornerInset * 0.15, y: faceRect.minY)
        )
        path.line(to: NSPoint(x: faceRect.minX + lowerCornerInset, y: faceRect.minY))
        path.curve(
            to: NSPoint(x: faceRect.minX, y: faceRect.minY + lowerVerticalInset),
            controlPoint1: NSPoint(x: faceRect.minX + lowerCornerInset * 0.15, y: faceRect.minY),
            controlPoint2: NSPoint(x: faceRect.minX, y: faceRect.minY + lowerVerticalInset * 0.35)
        )
        path.line(to: NSPoint(x: faceRect.minX, y: faceRect.maxY - radius))
        path.curve(
            to: NSPoint(x: faceRect.minX + radius, y: faceRect.maxY),
            controlPoint1: NSPoint(x: faceRect.minX, y: faceRect.maxY - radius * 0.45),
            controlPoint2: NSPoint(x: faceRect.minX + radius * 0.45, y: faceRect.maxY)
        )
        path.close()
        return path
    }

    func frontLipPath(in bodyRect: NSRect, faceRect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        let leftSeam = self.sideSeamCurve(
            side: .left,
            in: bodyRect,
            faceRect: faceRect
        )
        let rightSeam = self.sideSeamCurve(
            side: .right,
            in: bodyRect,
            faceRect: faceRect
        )
        let topY = faceRect.minY + M0116KeycapMetrics.frontLipOverlap
        let leftTopX = faceRect.minX + (M0116KeycapMetrics.faceCornerRadius * 0.45)
        let rightTopX = faceRect.maxX - (M0116KeycapMetrics.faceCornerRadius * 0.45)

        path.move(to: NSPoint(x: bodyRect.minX + M0116KeycapMetrics.bodyCornerRadius, y: bodyRect.minY))
        path.line(to: NSPoint(x: bodyRect.maxX - M0116KeycapMetrics.bodyCornerRadius, y: bodyRect.minY))
        path.curve(
            to: NSPoint(x: rightSeam.end.x, y: rightSeam.end.y),
            controlPoint1: NSPoint(x: bodyRect.maxX, y: bodyRect.minY),
            controlPoint2: rightSeam.controlPoint2
        )
        path.line(to: NSPoint(x: rightTopX, y: topY))
        path.line(to: NSPoint(x: leftTopX, y: topY))
        path.line(to: NSPoint(x: leftSeam.end.x, y: leftSeam.end.y))
        path.curve(
            to: NSPoint(x: bodyRect.minX + M0116KeycapMetrics.bodyCornerRadius, y: bodyRect.minY),
            controlPoint1: leftSeam.controlPoint2,
            controlPoint2: NSPoint(x: bodyRect.minX, y: bodyRect.minY)
        )
        path.close()
        return path
    }

    /// The M0116's side walls should be structurally readable on both sides. These seams
    /// trace the transition from the inset face down into the front skirt so the lighting
    /// can stay directional without making one side look accidentally sharper.
    func drawSideSeams(in bodyRect: NSRect, faceRect: NSRect, color: NSColor) {
        color.setStroke()

        for side in [KeycapSide.left, .right] {
            let seamPath = self.sideSeamPath(side: side, in: bodyRect, faceRect: faceRect)
            seamPath.lineWidth = StrokeWidth.standard
            seamPath.stroke()
        }
    }

    func sideSeamPath(side: KeycapSide, in bodyRect: NSRect, faceRect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        let curve = self.sideSeamCurve(side: side, in: bodyRect, faceRect: faceRect)

        path.move(to: curve.start)
        path.line(to: curve.curveStart)
        path.curve(
            to: curve.end,
            controlPoint1: curve.controlPoint1,
            controlPoint2: curve.controlPoint2
        )
        return path
    }

    func sideSeamCurve(side: KeycapSide, in bodyRect: NSRect, faceRect: NSRect) -> SideSeamCurve {
        let isLeft = side == .left
        let faceX = isLeft ? faceRect.minX : faceRect.maxX
        let bodyX = isLeft ? bodyRect.minX : bodyRect.maxX
        let start = NSPoint(
            x: faceX,
            y: faceRect.maxY - (M0116KeycapMetrics.faceCornerRadius * 0.75)
        )
        let curveStart = NSPoint(
            x: faceX,
            y: faceRect.minY + (M0116KeycapMetrics.faceCornerRadius * 0.5)
        )
        let end = NSPoint(
            x: bodyX,
            y: bodyRect.minY + M0116KeycapMetrics.bodyCornerRadius
        )
        let controlPoint1 = NSPoint(x: faceX, y: faceRect.minY - 1)
        let controlPoint2 = NSPoint(
            x: faceX + ((bodyX - faceX) * 0.65),
            y: bodyRect.minY + 2
        )
        return SideSeamCurve(
            start: start,
            curveStart: curveStart,
            end: end,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2
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

        if item.wrapsLabel, let label = item.label {
            self.drawWrappedLabel(label, for: item, in: faceRect, textColor: textColor)
            if item.state.showsDot {
                self.legendRenderer.drawKeycapDot(in: faceRect, active: item.state.isDotActive)
            }
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

    func drawWrappedLabel(_ label: String, for item: KeycapItem, in faceRect: NSRect, textColor: NSColor) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes: [NSAttributedString.Key: Any] = [
            .font: M0116KeycapMetrics.labelFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle,
        ]
        let width = min(
            self.wrappedLabelWidth(for: item, faceRect: faceRect),
            faceRect.width - 2 * M0116KeycapMetrics.horizontalPadding
        )
        let bounds = NSRect(
            x: faceRect.minX + M0116KeycapMetrics.horizontalPadding,
            y: faceRect.minY + M0116KeycapMetrics.legendBaselineInset,
            width: width,
            height: faceRect.height - M0116KeycapMetrics.legendBaselineInset
        )
        let size = label.boundingRect(
            with: bounds.size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes
        ).integral.size
        label.draw(
            in: NSRect(
                x: bounds.minX,
                y: bounds.minY,
                width: bounds.width,
                height: size.height
            ),
            withAttributes: attributes
        )
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

    func wrappedLabelWidth(for item: KeycapItem, faceRect: NSRect) -> CGFloat {
        switch item.identity {
        case .keyCode(KeyboardKeyCode.capsLock.rawValue):
            return M0116KeycapMetrics.capsLockLabelWidth
        case .keyCode(KeyboardKeyCode.pageUp.rawValue), .keyCode(KeyboardKeyCode.pageDown.rawValue):
            return M0116KeycapMetrics.pageNavigationLabelWidth
        default:
            return faceRect.width - 2 * M0116KeycapMetrics.horizontalPadding
        }
    }

    func usesRegularNavigationWidth(_ item: KeycapItem) -> Bool {
        switch item.identity {
        case .keyCode(KeyboardKeyCode.home.rawValue),
             .keyCode(KeyboardKeyCode.end.rawValue),
             .keyCode(KeyboardKeyCode.pageUp.rawValue),
             .keyCode(KeyboardKeyCode.pageDown.rawValue):
            return true
        default:
            return false
        }
    }
}

private extension M0116KeycapRenderer {
    enum KeycapSide {
        case left
        case right
    }

    struct SideSeamCurve {
        let start: NSPoint
        let curveStart: NSPoint
        let end: NSPoint
        let controlPoint1: NSPoint
        let controlPoint2: NSPoint
    }
}
