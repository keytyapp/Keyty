//
//  PointerRipplesWindow.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import QuartzCore

@MainActor
final class PointerRipplesWindow: NSWindow {
    let ringID = UUID()
    private let onFinish: (UUID) -> Void
    private let animationDuration = PointerRingAnimation.spawnAnimationDuration
    private var cleanupTask: Task<Void, Never>?
    private var didFinish = false
    
    init(
        style: VisualStyle,
        center: NSPoint,
        onFinish: @escaping (UUID) -> Void
    ) {
        self.onFinish = onFinish

        let windowDiameter = PointerRipplesWindow.windowDiameter(for: style)
        let origin = NSPoint(x: center.x - windowDiameter / 2, y: center.y - windowDiameter / 2)

        super.init(
            contentRect: NSRect(origin: origin, size: NSSize(width: windowDiameter, height: windowDiameter)),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.alphaValue = 1
        self.ignoresMouseEvents = true
        self.collectionBehavior = .canJoinAllSpaces
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.addSublayer(self.makeRingLayer(style: style, windowDiameter: windowDiameter))
    }

    deinit {
        self.cleanupTask?.cancel()
    }

    func present() {
        self.orderFrontRegardless()
        self.startCleanupTimer()
    }

    func dismiss() {
        self.finishIfNeeded()
    }

    private func startCleanupTimer() {
        self.cleanupTask?.cancel()
        self.cleanupTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: self?.animationDuration.nanoseconds ?? 0)
            self?.finishIfNeeded()
        }
    }

    private func finishIfNeeded() {
        guard !self.didFinish else { return }
        self.didFinish = true
        self.cleanupTask?.cancel()
        self.cleanupTask = nil
        self.orderOut(nil)
        self.onFinish(self.ringID)
    }

    private static func windowDiameter(for style: VisualStyle) -> CGFloat {
        (style.size * PointerRingAnimation.spawnEndScale) + style.thickness
    }

    private func makeRingLayer(style: VisualStyle, windowDiameter: CGFloat) -> CAShapeLayer {
        let ringLayer = CAShapeLayer()
        let ringOrigin = (windowDiameter - style.size) / 2
        ringLayer.frame = CGRect(
            x: ringOrigin,
            y: ringOrigin,
            width: style.size,
            height: style.size
        )

        let lineWidth = min(style.thickness, style.size / 2)
        let inset = lineWidth / 2
        var rect = NSRect(
            x: inset,
            y: inset,
            width: style.size - lineWidth,
            height: style.size - lineWidth
        )
        if style.shape == .rhomb {
            let extraInsetX = rect.width * (1 - PointerRingAnimation.rhombFitScale) / 2
            let extraInsetY = rect.height * (1 - PointerRingAnimation.rhombFitScale) / 2
            rect = rect.insetBy(dx: extraInsetX, dy: extraInsetY)
        }

        ringLayer.path = PointerRingVisualizerWindow.makeVisualizerPath(shape: style.shape, rect: rect).cgPath
        ringLayer.strokeColor = style.color.cgColor
        ringLayer.fillColor = NSColor.clear.cgColor
        ringLayer.lineWidth = lineWidth
        ringLayer.lineJoin = .round
        ringLayer.opacity = Float(PointerRingAnimation.hiddenOpacity)
        ringLayer.transform = CATransform3DMakeScale(
            PointerRingAnimation.spawnStartScale,
            PointerRingAnimation.spawnStartScale,
            1
        )

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = PointerRingAnimation.visibleOpacity
        opacityAnimation.toValue = PointerRingAnimation.hiddenOpacity

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = PointerRingAnimation.spawnStartScale
        scaleAnimation.toValue = PointerRingAnimation.spawnEndScale

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = self.animationDuration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationGroup.animations = [opacityAnimation, scaleAnimation]
        ringLayer.add(animationGroup, forKey: PointerRingAnimation.clickAnimationKey)

        ringLayer.opacity = Float(PointerRingAnimation.hiddenOpacity)
        ringLayer.transform = CATransform3DMakeScale(
            PointerRingAnimation.spawnEndScale,
            PointerRingAnimation.spawnEndScale,
            1
        )

        return ringLayer
    }
}

extension PointerRipplesWindow {
    struct VisualStyle {
        let color: NSColor
        let size: CGFloat
        let thickness: CGFloat
        let shape: PointerRingShape
    }
}
