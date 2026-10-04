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
            self.handlePress()

        case .drag:
            self.positionAroundPointer()

        case .release:
            self.handleRelease()

        case .ignored:
            break
        }
    }

    public func updatePointerPosition() {
        self.addRingLayerIfNeeded()
        self.positionAroundPointer()
    }

    private func handlePress() {
        self.cancelScheduledFadeOut()
        self.interactionState.press()
        self.positionAroundPointer()
        self.capturePresentationState()
        self.ringLayer?.removeAnimation(forKey: PointerRingAnimation.clickAnimationKey)
        let scaleAnimation = PointerRingAnimation.press(
            fromScale: self.ringLayer?.transform.m11 ?? 1.0
        )
        self.ringLayer?.add(scaleAnimation, forKey: PointerRingAnimation.scaleAnimationKey)
        self.setRingLayerState(
            opacity: Float(PointerRingAnimation.VisualState.pressed.opacity),
            transform: CATransform3DMakeScale(
                PointerRingAnimation.VisualState.pressed.scale,
                PointerRingAnimation.VisualState.pressed.scale,
                1.0
            )
        )
    }

    private func handleRelease() {
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
    }

    private func addRingLayerIfNeeded() {
        guard self.ringLayer == nil else { return }

        self.ringLayer = PointerRingLayer.make(settings: self.settings)
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

        let animationGroup = PointerRingAnimation.fadeOut(duration: duration)
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

}
