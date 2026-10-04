//
//  PointerRingVisualizerWindow.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine
import QuartzCore

public final class PointerRingVisualizerWindow: NSWindow {
    private let settings: any PointerRingSettingsProtocol & ReactiveSettings

    private var ringLayer: CAShapeLayer?
    private var cancellables = Set<AnyCancellable>()
    private var fadeOutWorkItem: DispatchWorkItem?
    private var fadeOutGeneration = 0
    private var interactionState = StateMachine()

    init(
        settings: any PointerRingSettingsProtocol & ReactiveSettings,
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        self.settings = settings
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.alphaValue = 1
        self.ignoresMouseEvents = true
        self.collectionBehavior = .canJoinAllSpaces

        self.settings.changes
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.settingsDidChange()
            }
            .store(in: &self.cancellables)
    }

    convenience init(settings: any PointerRingSettingsProtocol & ReactiveSettings) {
        let diameter = settings.size
        self.init(
            settings: settings,
            contentRect: NSRect(x: 0, y: 0, width: diameter, height: diameter),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
    }

    private func settingsDidChange() {
        self.ringLayer?.removeFromSuperlayer()
        self.ringLayer = nil
        let size = self.settings.size
        self.setContentSize(NSSize(width: size, height: size))
        self.addRingLayerIfNeeded()
        self.resetRingLayerToIdleState()
        self.updatePointerPosition()
    }

    public func update(with mouseEvent: MouseEvent) {
        self.addRingLayerIfNeeded()

        switch PointerRingAnimation.eventPhase(for: mouseEvent.type) {
        case .press:
            self.cancelScheduledFadeOut()
            self.interactionState.press()
            self.positionAroundPointer()
            self.capturePresentationState()
            self.ringLayer?.removeAnimation(forKey: PointerRingAnimation.clickAnimationKey)
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = PointerRingAnimation.pressAnimationDuration
            scaleAnimation.fromValue = self.ringLayer?.transform.m11 ?? 1.0
            scaleAnimation.toValue = PointerRingAnimation.VisualState.pressed.scale
            self.ringLayer?.add(scaleAnimation, forKey: PointerRingAnimation.scaleAnimationKey)
            self.setRingLayerState(
                opacity: Float(PointerRingAnimation.VisualState.pressed.opacity),
                transform: CATransform3DMakeScale(
                    PointerRingAnimation.VisualState.pressed.scale,
                    PointerRingAnimation.VisualState.pressed.scale,
                    1.0
                )
            )

        case .drag:
            self.positionAroundPointer()

        case .release:
            self.positionAroundPointer()
            self.ringLayer?.removeAnimation(forKey: PointerRingAnimation.scaleAnimationKey)
            if self.settings.alwaysVisible {
                self.cancelScheduledFadeOut()
                self.interactionState.release(alwaysVisible: true)
                self.setRingLayerState(
                    opacity: Float(PointerRingAnimation.visibleOpacity),
                    transform: CATransform3DIdentity
                )
            } else {
                self.interactionState.release(alwaysVisible: false)
                self.scheduleFadeOut()
            }

        case .ignored:
            break
        }
    }

    public func updatePointerPosition() {
        self.addRingLayerIfNeeded()
        self.positionAroundPointer()
    }

    private func addRingLayerIfNeeded() {
        guard self.ringLayer == nil else { return }

        self.ringLayer = self.makeRingLayer()
        if self.contentView?.layer == nil {
            self.contentView?.wantsLayer = true
        }
        if let ringLayer = self.ringLayer {
            self.contentView?.layer?.addSublayer(ringLayer)
        }
        self.resetRingLayerToIdleState()
    }

    private func resetRingLayerToIdleState() {
        self.cancelScheduledFadeOut()
        self.interactionState.reset()
        self.ringLayer?.removeAnimation(forKey: PointerRingAnimation.clickAnimationKey)
        self.ringLayer?.removeAnimation(forKey: PointerRingAnimation.scaleAnimationKey)
        self.ringLayer?.transform = CATransform3DIdentity
        self.ringLayer?.opacity = Float(PointerRingAnimation.VisualState.idle(alwaysVisible: self.settings.alwaysVisible).opacity)
    }

    private func fadeOut() {
        guard self.interactionState.beginFade() else { return }

        let duration = TimeInterval(self.settings.fadeDuration)
        guard duration > 0 else {
            self.setRingLayerState(
                opacity: Float(PointerRingAnimation.hiddenOpacity),
                transform: CATransform3DIdentity
            )
            return
        }

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = PointerRingAnimation.visibleOpacity
        opacityAnimation.toValue = PointerRingAnimation.hiddenOpacity

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = PointerRingAnimation.VisualState.pressed.scale
        scaleAnimation.toValue = 1.0

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationGroup.animations = [opacityAnimation, scaleAnimation]
        self.ringLayer?.add(animationGroup, forKey: PointerRingAnimation.clickAnimationKey)
        self.setRingLayerState(
            opacity: Float(PointerRingAnimation.hiddenOpacity),
            transform: CATransform3DIdentity
        )
    }

    private func scheduleFadeOut() {
        self.cancelScheduledFadeOut()

        let generation = self.fadeOutGeneration

        let fadeOutWorkItem = DispatchWorkItem { [weak self] in
            guard let self, self.fadeOutGeneration == generation else { return }
            self.fadeOutWorkItem = nil
            self.fadeOut()
        }
        self.fadeOutWorkItem = fadeOutWorkItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + TimeInterval(self.settings.displayDuration),
            execute: fadeOutWorkItem
        )
    }

    private func cancelScheduledFadeOut() {
        self.fadeOutWorkItem?.cancel()
        self.fadeOutWorkItem = nil
        self.fadeOutGeneration += 1
    }

    private func capturePresentationState() {
        guard let presentationLayer = self.ringLayer?.presentation() else { return }
        self.setRingLayerState(
            opacity: presentationLayer.opacity,
            transform: presentationLayer.transform
        )
    }

    func setRingLayerState(opacity: Float, transform: CATransform3D) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.ringLayer?.opacity = opacity
        self.ringLayer?.transform = transform
        CATransaction.commit()
    }

    private func positionAroundPointer() {
        let radius = self.settings.size / 2
        let origin = NSEvent.mouseLocation.offsetBy(dx: -radius, dy: -radius)
        self.setFrameOrigin(origin)
    }

    private func makeRingLayer() -> CAShapeLayer {
        let ringLayer = CAShapeLayer()
        let diameter = self.settings.size
        ringLayer.frame = CGRect(origin: .zero, size: NSSize(width: diameter, height: diameter))
        let lineWidth = min(self.settings.thickness, diameter / 2)
        let inset = lineWidth / 2
        var rect = NSRect(
            x: inset,
            y: inset,
            width: diameter - lineWidth,
            height: diameter - lineWidth
        )
        if self.settings.shape == .rhomb {
            let extraInsetX = rect.width * (1 - PointerRingAnimation.rhombFitScale) / 2
            let extraInsetY = rect.height * (1 - PointerRingAnimation.rhombFitScale) / 2
            rect = rect.insetBy(dx: extraInsetX, dy: extraInsetY)
        }

        let path = Self.makeVisualizerPath(shape: self.settings.shape, rect: rect)
        ringLayer.path = path.cgPath

        ringLayer.strokeColor = self.settings.color.cgColor
        ringLayer.fillColor = NSColor.clear.cgColor
        ringLayer.lineWidth = lineWidth
        ringLayer.lineJoin = .round
        ringLayer.opacity = 0.0

        return ringLayer
    }
}

// MARK: - Shapes Helpers
extension PointerRingVisualizerWindow {
    static func makeVisualizerPath(shape: PointerRingShape, rect: NSRect) -> NSBezierPath {
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
        let path = squirclePath(in: rect)
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
