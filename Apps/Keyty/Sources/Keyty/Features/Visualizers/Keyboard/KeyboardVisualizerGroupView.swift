//
//  KeyboardVisualizerGroupView.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

final class KeyboardVisualizerGroupView: NSView {
    private var items: [KeycapItem]
    private var settings: KeyboardVisualizerSettings
    private var fadeWorkItem: DispatchWorkItem?

    /// Uniform scale applied to the keycap drawing. Combines the user-selected size with a
    /// per-style normalization factor so every style renders at a comparable size.
    private var scale: CGFloat { settings.style.sizeNormalization * max(0.1, settings.scale) }

    /// Group size in base (unscaled) drawing coordinates.
    private var baseSize: NSSize {
        let sizes = itemSizes()
        let keysWidth = sizes.reduce(CGFloat(0)) { $0 + $1.width }
            + groupSpacing * CGFloat(max(0, sizes.count - 1))
        let fallbackHeight: CGFloat
        switch settings.style {
        case .minimal:
            fallbackHeight = MinimalKeycapMetrics.height
        case .retro:
            fallbackHeight = RetroKeycapMetrics.height
        case .apple, .pbt:
            fallbackHeight = AppleKeycapMetrics.height
        }
        let height = sizes.map(\.height).max() ?? fallbackHeight
        return NSSize(
            width: groupPadding.left + groupPadding.right + keysWidth,
            height: groupPadding.top + groupPadding.bottom + height
        )
    }

    var preferredSize: NSSize {
        NSSize(width: baseSize.width * scale, height: baseSize.height * scale)
    }

    override var intrinsicContentSize: NSSize {
        self.preferredSize
    }

    override var fittingSize: NSSize {
        self.preferredSize
    }

    override var mouseDownCanMoveWindow: Bool {
        true
    }

    init(items: [KeycapItem], settings: KeyboardVisualizerSettings = KeyboardVisualizerSettings()) {
        self.items = items
        self.settings = settings
        super.init(frame: .zero)
        self.alphaValue = 1
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(items:) instead.")
    }

    func configure(items: [KeycapItem], settings: KeyboardVisualizerSettings) {
        self.items = items
        self.settings = settings
        self.invalidateIntrinsicContentSize()
        self.needsDisplay = true
    }

    func scheduleFadeOut(onCompletion completion: @escaping () -> Void) {
        fadeWorkItem?.cancel()
        let delay = max(0.1, TimeInterval(settings.fadeDelay))
        let duration = max(0, TimeInterval(settings.fadeDuration))
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                self.animator().alphaValue = 0
            } completionHandler: {
                completion()
            }
        }
        fadeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()
        let transform = NSAffineTransform()
        transform.scale(by: scale)
        transform.concat()

        drawBackground()

        let sizes = itemSizes()
        var x = groupPadding.left
        for (item, size) in zip(items, sizes) {
            let rect = NSRect(
                x: x,
                y: groupPadding.bottom,
                width: size.width,
                height: size.height
            )
            KeycapRendererFactory.makeRenderer(for: item, settings: settings).draw(
                context: KeycapContext(item: item, settings: settings),
                in: rect
            )
            x += size.width + groupSpacing
        }

        NSGraphicsContext.restoreGraphicsState()
    }

    private func itemSizes() -> [CGSize] {
        self.items.map {
            KeycapRendererFactory.makeRenderer(for: $0, settings: settings)
                .size(for: KeycapContext(item: $0, settings: settings))
        }
    }

    private var groupPadding: NSEdgeInsets {
        switch settings.style {
        case .minimal:
            return MinimalKeycapMetrics.groupPadding
        case .retro:
            return RetroKeycapMetrics.groupPadding
        case .apple:
            return AppleKeycapMetrics.groupPadding
        case .pbt:
            return PBTKeycapMetrics.groupPadding
        }
    }

    private var groupSpacing: CGFloat {
        switch settings.style {
        case .minimal:
            return MinimalKeycapMetrics.itemSpacing
        case .retro:
            return RetroKeycapMetrics.itemSpacing
        case .apple, .pbt:
            return AppleKeycapMetrics.itemSpacing
        }
    }

    private func drawBackground() {
        let baseBounds = NSRect(origin: .zero, size: baseSize)
        let insetBounds = baseBounds.insetBy(dx: 1, dy: 1)
        let radius: CGFloat
        switch settings.style {
        case .minimal:
            radius = insetBounds.height / 2
        case .retro:
            radius = 24
        case .apple, .pbt:
            radius = 18
        }
        let path = NSBezierPath(roundedRect: insetBounds, xRadius: radius, yRadius: radius)
        let appearance = settings.groupAppearance
        appearance.groupBackgroundColor.setFill()
        path.fill()
        appearance.groupStrokeColor.setStroke()
        path.lineWidth = StrokeWidth.standard
        path.stroke()
    }
}
