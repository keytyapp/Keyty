//
//  MinimalKeycapRenderer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

struct MinimalKeycapRenderer: KeycapRendering {
    func size(for context: KeycapContext) -> CGSize {
        let width = minimalContentWidth(for: context.item) + 2 * MinimalKeycapMetrics.horizontalPadding
        return CGSize(width: width, height: MinimalKeycapMetrics.height)
    }

    func draw(context: KeycapContext, in rect: NSRect) {
        let item = context.item
        let appearance = context.minimalAppearance
        NSGraphicsContext.saveGraphicsState()
        if item.isPressed {
            let transform = NSAffineTransform()
            transform.translateX(by: rect.midX, yBy: rect.midY)
            transform.scale(by: MinimalKeycapMetrics.pressedScale)
            transform.translateX(by: -rect.midX, yBy: -rect.midY)
            transform.concat()
        }

        if let image = item.image {
            let size = scaledImageSize(for: image)
            KeycapImageRenderer.draw(image: image, badgeText: item.imageBadgeText, color: appearance.textColor, in: NSRect(
                x: rect.midX - size.width / 2,
                y: rect.midY - size.height / 2,
                width: size.width,
                height: size.height
            ))
        } else if let sfSymbolName = item.sfSymbolName,
                  let image = SymbolImage.image(
                    named: sfSymbolName,
                    color: appearance.textColor,
                    pointSize: MinimalKeycapMetrics.symbolFont.pointSize
                  ) {
            let size = image.size
            image.draw(in: NSRect(
                x: rect.midX - size.width / 2,
                y: rect.midY - size.height / 2,
                width: size.width,
                height: size.height
            ))
        } else if !item.symbol.isEmpty {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: MinimalKeycapMetrics.symbolFont,
                .foregroundColor: appearance.textColor,
            ]
            let size = item.symbol.size(withAttributes: attributes)
            item.symbol.draw(
                in: NSRect(
                    x: rect.midX - size.width / 2,
                    y: rect.midY - size.height / 2,
                    width: size.width,
                    height: size.height
                ),
                withAttributes: attributes
            )
        } else if let label = item.label {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: MinimalKeycapMetrics.labelFont,
                .foregroundColor: appearance.textColor,
            ]
            let size = label.size(withAttributes: attributes)
            label.draw(
                in: NSRect(
                    x: rect.midX - size.width / 2,
                    y: rect.midY - size.height / 2,
                    width: size.width,
                    height: size.height
                ),
                withAttributes: attributes
            )
        }

        NSGraphicsContext.restoreGraphicsState()
    }

    private func minimalContentWidth(for item: KeycapItem) -> CGFloat {
        if let image = item.image {
            return max(MinimalKeycapMetrics.minWidth, scaledImageSize(for: image).width)
        }

        if item.sfSymbolName != nil {
            return MinimalKeycapMetrics.symbolFont.pointSize
        }

        if !item.symbol.isEmpty {
            let width = item.symbol.size(withAttributes: [.font: MinimalKeycapMetrics.symbolFont]).width
            return max(MinimalKeycapMetrics.minWidth, width)
        }

        if let label = item.label {
            let width = label.size(withAttributes: [.font: MinimalKeycapMetrics.labelFont]).width
            return max(MinimalKeycapMetrics.minWidth, width)
        }

        return MinimalKeycapMetrics.minWidth
    }

    private func scaledImageSize(for image: NSImage) -> NSSize {
        let size = image.size
        guard size.height > 0 else { return size }
        let scale = min(1, MinimalKeycapMetrics.imageMaxHeight / size.height)
        return NSSize(width: size.width * scale, height: size.height * scale)
    }
}
