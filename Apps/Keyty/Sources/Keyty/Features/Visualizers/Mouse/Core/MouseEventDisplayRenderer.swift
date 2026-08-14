//
//  MouseEventDisplayRenderer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum MouseEventDisplayRenderer {
    static func iconImage(for event: MouseEvent, height targetHeight: CGFloat, color textColor: NSColor) -> NSImage? {
        Self.iconImage(
            for: event.kind,
            buttonNumber: event.buttonNumber,
            height: targetHeight,
            color: textColor
        )
    }

    static func iconImage(for kind: MouseEvent.Kind, height targetHeight: CGFloat, color textColor: NSColor) -> NSImage? {
        Self.iconImage(for: kind, buttonNumber: 0, height: targetHeight, color: textColor)
    }

    static func templateIconImage(for kind: MouseEvent.Kind, height targetHeight: CGFloat) -> NSImage? {
        let baseIcon = kind.isScroll ? Self.scrollIcon(for: kind) : Self.sourceIcon(for: kind)
        guard let baseIcon else { return nil }

        let aspect = baseIcon.size.width / baseIcon.size.height
        guard aspect.isFinite, aspect > 0 else { return baseIcon }

        let image = baseIcon.copy() as? NSImage ?? baseIcon
        image.size = NSSize(width: targetHeight * aspect, height: targetHeight)
        return image
    }


    static func sourceIcon(for kind: MouseEvent.Kind) -> NSImage? {
        switch kind {
        case .leftButton:
            return NSImage.mouseLeftClick
        case .rightButton:
            return NSImage.mouseRightClick
        case .middleButton:
            return NSImage.mouseScrollClick
        case .otherButton, .generic:
            return NSImage.mouseDefault
        case .wheelUp, .wheelDown, .wheelLeft, .wheelRight:
            return nil
        }
    }

    static func scrollIcon(for kind: MouseEvent.Kind) -> NSImage? {
        switch kind {
        case .wheelUp:
            return NSImage.mouseScrollUp
        case .wheelDown:
            return NSImage.mouseScrollDown
        case .wheelLeft:
            return NSImage.mouseScrollLeft
        case .wheelRight:
            return NSImage.mouseScrollRight
        default:
            return nil
        }
    }

    private static func tintedIcon(from baseIcon: NSImage, height targetHeight: CGFloat, color textColor: NSColor) -> NSImage {
        let aspect = baseIcon.size.width / baseIcon.size.height
        let iconSize = NSSize(width: targetHeight * aspect, height: targetHeight)

        return baseIcon.tinted(with: textColor, size: iconSize)
    }

    private static func badgeMetrics(for event: MouseEvent, iconHeight: CGFloat) -> (size: NSSize, padding: NSSize, font: NSFont) {
        let label = Self.buttonLabel(for: event)
        let fontSize = iconHeight * 0.22
        let font = NSFont.boldSystemFont(ofSize: fontSize)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
        let labelSize = label.size(withAttributes: attrs)
        let padding = NSSize(width: fontSize * 0.30, height: fontSize * 0.15)
        let naturalHeight = labelSize.height + padding.height * 2
        let minWidth = naturalHeight * 1.25
        let width = max(labelSize.width + padding.width * 2, minWidth)
        return (NSSize(width: width, height: naturalHeight), padding, font)
    }

    private static func badgeSize(for event: MouseEvent, iconHeight: CGFloat) -> NSSize {
        Self.badgeMetrics(for: event, iconHeight: iconHeight).size
    }

    private static func drawButtonBadge(for event: MouseEvent, in canvasSize: NSSize, color textColor: NSColor) {
        let label = Self.buttonLabel(for: event)
        let (bSize, _, font) = Self.badgeMetrics(for: event, iconHeight: canvasSize.height)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]

        let badgeRect = NSRect(
            x: canvasSize.width - bSize.width - 0.5,
            y: 0.5,
            width: bSize.width,
            height: bSize.height
        )

        textColor.setFill()
        NSBezierPath(roundedRect: badgeRect, xRadius: bSize.height / 2, yRadius: bSize.height / 2).fill()

        let labelSize = label.size(withAttributes: attrs)
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        var centeredAttrs = attrs
        centeredAttrs[.paragraphStyle] = para

        let textRect = NSRect(
            x: badgeRect.minX,
            y: badgeRect.midY - labelSize.height / 2,
            width: bSize.width,
            height: labelSize.height
        )
        NSGraphicsContext.current?.compositingOperation = .clear
        label.draw(in: textRect, withAttributes: centeredAttrs)
        NSGraphicsContext.current?.compositingOperation = .sourceOver
    }

    private static func buttonLabel(for event: MouseEvent) -> String {
        String(event.kind.otherButtonNumber ?? (event.buttonNumber + 1))
    }

    private static func iconImage(
        for kind: MouseEvent.Kind,
        buttonNumber: Int,
        height targetHeight: CGFloat,
        color textColor: NSColor
    ) -> NSImage? {
        if kind.isScroll {
            guard let baseIcon = Self.scrollIcon(for: kind) else { return nil }
            return Self.tintedIcon(from: baseIcon, height: targetHeight, color: textColor)
        }

        guard let baseIcon = Self.sourceIcon(for: kind) else {
            return nil
        }

        let aspect = baseIcon.size.width / baseIcon.size.height
        let iconSize = NSSize(width: targetHeight * aspect, height: targetHeight)

        let tinted = baseIcon.tinted(with: textColor, size: iconSize)
        guard kind.otherButtonNumber != nil else { return tinted }

        let canvas = NSImage(size: iconSize)
        canvas.lockFocus()
        tinted.draw(in: NSRect(origin: .zero, size: iconSize))
        Self.drawButtonBadge(for: kind, buttonNumber: buttonNumber, in: iconSize, color: textColor)
        canvas.unlockFocus()
        return canvas
    }

    private static func badgeMetrics(
        for kind: MouseEvent.Kind,
        buttonNumber: Int,
        iconHeight: CGFloat
    ) -> (size: NSSize, padding: NSSize, font: NSFont) {
        let label = Self.buttonLabel(for: kind, buttonNumber: buttonNumber)
        let fontSize = iconHeight * 0.26
        let font = NSFont.boldSystemFont(ofSize: fontSize)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
        let labelSize = label.size(withAttributes: attrs)
        let padding = NSSize(width: fontSize * 0.34, height: fontSize * 0.10)
        let naturalHeight = labelSize.height + padding.height * 2
        let width = max(labelSize.width + padding.width * 2, naturalHeight)
        return (NSSize(width: width, height: naturalHeight), padding, font)
    }

    private static func drawButtonBadge(
        for kind: MouseEvent.Kind,
        buttonNumber: Int,
        in canvasSize: NSSize,
        color textColor: NSColor
    ) {
        let label = Self.buttonLabel(for: kind, buttonNumber: buttonNumber)
        let (bSize, _, font) = Self.badgeMetrics(for: kind, buttonNumber: buttonNumber, iconHeight: canvasSize.height)

        let para = NSMutableParagraphStyle()
        para.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: para,
        ]

        let labelSize = label.size(withAttributes: attrs)
        let textRect = NSRect(
            x: canvasSize.width / 2 - bSize.width / 2,
            y: canvasSize.height * 0.16 + (bSize.height - labelSize.height) / 2,
            width: bSize.width,
            height: labelSize.height
        )
        label.draw(in: textRect, withAttributes: attrs)
    }

    private static func buttonLabel(for kind: MouseEvent.Kind, buttonNumber: Int) -> String {
        String(kind.otherButtonNumber ?? (buttonNumber + 1))
    }
}
