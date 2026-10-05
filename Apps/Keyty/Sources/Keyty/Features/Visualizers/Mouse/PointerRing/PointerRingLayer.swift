//
//  PointerRingLayer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import QuartzCore

enum PointerRingLayer {
    static func make(settings: any PointerRingSettingsProtocol) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let diameter = settings.size
        layer.frame = CGRect(origin: .zero, size: NSSize(width: diameter, height: diameter))

        let lineWidth = min(settings.thickness, diameter / 2)
        let inset = lineWidth / 2
        var rect = NSRect(
            x: inset,
            y: inset,
            width: diameter - lineWidth,
            height: diameter - lineWidth
        )
        if settings.shape == .rhomb {
            let extraInsetX = rect.width * (1 - PointerRingAnimation.rhombFitScale) / 2
            let extraInsetY = rect.height * (1 - PointerRingAnimation.rhombFitScale) / 2
            rect = rect.insetBy(dx: extraInsetX, dy: extraInsetY)
        }

        layer.path = self.makePath(shape: settings.shape, rect: rect).cgPath
        layer.strokeColor = settings.color.cgColor
        layer.fillColor = NSColor.clear.cgColor
        layer.lineWidth = lineWidth
        layer.lineJoin = .round
        layer.opacity = Float(PointerRingAnimation.hiddenOpacity)

        return layer
    }

    static func makePath(shape: PointerRingShape, rect: NSRect) -> NSBezierPath {
        switch shape {
        case .circle:
            return NSBezierPath(ovalIn: rect)
        case .rhomb:
            return self.rhombPath(in: rect)
        case .squircle:
            return self.squirclePath(in: rect)
        }
    }

    private static func rhombPath(in rect: NSRect) -> NSBezierPath {
        let path = self.squirclePath(in: rect)
        let transform = NSAffineTransform()
        transform.translateX(by: rect.midX, yBy: rect.midY)
        transform.rotate(byDegrees: 45)
        transform.translateX(by: -rect.midX, yBy: -rect.midY)
        path.transform(using: transform as AffineTransform)
        return path
    }

    private static func squirclePath(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        let center = NSPoint(x: rect.midX, y: rect.midY)
        let radiusX = rect.width / 2
        let radiusY = rect.height / 2
        guard radiusX > 0, radiusY > 0 else { return path }

        let exponent: CGFloat = 4.0
        let samplesPerQuadrant = 16
        let totalSamples = samplesPerQuadrant * 4

        func point(at angle: CGFloat) -> NSPoint {
            let cosValue = cos(angle)
            let sinValue = sin(angle)
            let x = radiusX * cosValue.signedSuperellipseComponent(exponent: exponent)
            let y = radiusY * sinValue.signedSuperellipseComponent(exponent: exponent)
            return NSPoint(x: center.x + x, y: center.y + y)
        }

        for index in 0...totalSamples {
            let angle = (CGFloat(index) / CGFloat(totalSamples)) * .pi * 2
            let point = point(at: angle)
            if index == 0 {
                path.move(to: point)
            } else {
                path.line(to: point)
            }
        }

        path.close()
        return path
    }
}
