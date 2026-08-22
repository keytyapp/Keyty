//
//  KeycapLegendRenderer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

struct KeycapLegendRenderer {
    func draw(item: KeycapItem, in keycapRect: NSRect, textColor: NSColor) {
        let centerPara = NSMutableParagraphStyle()
        centerPara.alignment = .center

        if let label = item.label {
            if item.rendersCenteredLabel {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: CommonKeycapMetrics.labelFont,
                    .foregroundColor: textColor,
                    .paragraphStyle: centerPara,
                ]
                let bounds = NSRect(
                    x: keycapRect.minX + CommonKeycapMetrics.horizontalPadding,
                    y: keycapRect.minY,
                    width: keycapRect.width - 2 * CommonKeycapMetrics.horizontalPadding,
                    height: keycapRect.height
                )
                let size = label.boundingRect(
                    with: bounds.size,
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attrs
                ).integral.size
                label.draw(
                    in: NSRect(
                        x: bounds.minX,
                        y: keycapRect.midY - size.height / 2,
                        width: bounds.width,
                        height: size.height
                    ),
                    withAttributes: attrs
                )
                return
            }

            let leftPara = NSMutableParagraphStyle()
            leftPara.alignment = .left

            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: CommonKeycapMetrics.labelFont,
                .foregroundColor: textColor,
                .paragraphStyle: leftPara,
            ]
            let labelSize = label.size(withAttributes: labelAttrs)

            if item.rendersSymbolWithLabel {
                let rightEdge = keycapRect.maxX - CommonKeycapMetrics.horizontalPadding
                let labelX = rightEdge - labelSize.width
                let labelY = keycapRect.maxY - labelSize.height - 8
                label.draw(
                    in: NSRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height),
                    withAttributes: labelAttrs
                )

                if let sfName = item.sfSymbolName,
                   let image = SymbolImage.image(named: sfName, color: textColor, pointSize: 16) {
                    let size = image.size
                    image.draw(in: NSRect(
                        x: keycapRect.minX + CommonKeycapMetrics.horizontalPadding,
                        y: keycapRect.minY + 8,
                        width: size.width,
                        height: size.height
                    ))
                }
            } else {
                let symbolAttrs: [NSAttributedString.Key: Any] = [
                    .font: CommonKeycapMetrics.symbolFont,
                    .foregroundColor: textColor,
                    .paragraphStyle: leftPara,
                ]
                let symbolSize = item.symbol.size(withAttributes: symbolAttrs)

                let labelY = keycapRect.minY + 10
                let symbolY = labelY + labelSize.height + 10

                let labelX: CGFloat
                let symbolX: CGFloat
                switch item.layoutHints.alignment {
                case .center:
                    labelX = keycapRect.midX - labelSize.width / 2
                    symbolX = keycapRect.midX - symbolSize.width / 2
                case .left:
                    labelX = keycapRect.minX + CommonKeycapMetrics.horizontalPadding
                    symbolX = keycapRect.minX + CommonKeycapMetrics.horizontalPadding
                case .automatic, .right:
                    let rightEdge = keycapRect.maxX - CommonKeycapMetrics.horizontalPadding
                    labelX = rightEdge - labelSize.width
                    symbolX = rightEdge - symbolSize.width
                }

                label.draw(
                    in: NSRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height),
                    withAttributes: labelAttrs
                )

                if let sfName = item.sfSymbolName,
                   let image = SymbolImage.image(named: sfName, color: textColor, pointSize: 22) {
                    let size = image.size
                    let x: CGFloat
                    switch item.layoutHints.alignment {
                    case .left:
                        x = keycapRect.minX + CommonKeycapMetrics.horizontalPadding
                    case .automatic, .center, .right:
                        x = keycapRect.maxX - CommonKeycapMetrics.horizontalPadding - size.width
                    }
                    image.draw(in: NSRect(x: x, y: symbolY, width: size.width, height: size.height))
                } else if !item.symbol.isEmpty {
                    item.symbol.draw(
                        in: NSRect(x: symbolX, y: symbolY, width: symbolSize.width, height: symbolSize.height),
                        withAttributes: symbolAttrs
                    )
                }
            }
        } else if let image = item.image {
            let size = image.size
            KeycapImageRenderer.draw(image: image, badgeText: item.imageBadgeText, color: textColor, in: NSRect(
                x: keycapRect.midX - size.width / 2,
                y: keycapRect.midY - size.height / 2,
                width: size.width,
                height: size.height
            ))
        } else if let sfName = item.sfSymbolName,
                  let image = SymbolImage.image(named: sfName, color: textColor, pointSize: 28) {
            let size = image.size
            image.draw(in: NSRect(
                x: keycapRect.midX - size.width / 2,
                y: keycapRect.midY - size.height / 2,
                width: size.width,
                height: size.height
            ))
        } else {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: CommonKeycapMetrics.charFont,
                .foregroundColor: textColor,
                .paragraphStyle: centerPara,
            ]
            let size = item.symbol.size(withAttributes: attrs)
            item.symbol.draw(
                in: NSRect(
                    x: keycapRect.minX,
                    y: keycapRect.midY - size.height / 2,
                    width: keycapRect.width,
                    height: size.height
                ),
                withAttributes: attrs
            )
        }

        if item.state.showsDot {
            drawKeycapDot(in: keycapRect, active: item.state.isDotActive)
        }
    }

    private func drawKeycapDot(in rect: NSRect, active: Bool) {
        let dotSize: CGFloat = 8
        let dotRect = NSRect(
            x: rect.minX + CommonKeycapMetrics.horizontalPadding,
            y: rect.maxY - CommonKeycapMetrics.horizontalPadding - dotSize,
            width: dotSize,
            height: dotSize
        )
        let dotColor = active ? KeycapAppearance.dotColor : KeycapAppearance.inactiveDotColor
        dotColor.setFill()
        NSBezierPath(ovalIn: dotRect).fill()
    }
}
