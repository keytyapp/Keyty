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
    private var repeatCount: Int
    private var fadeWorkItem: DispatchWorkItem?

    init(
        items: [KeycapItem],
        settings: KeyboardVisualizerSettings = KeyboardVisualizerSettings(),
        repeatCount: Int = 1
    ) {
        self.items = items
        self.settings = settings
        self.repeatCount = max(1, repeatCount)
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
}

extension KeyboardVisualizerGroupView {
    func configure(items: [KeycapItem], settings: KeyboardVisualizerSettings, repeatCount: Int? = nil) {
        self.items = items
        self.settings = settings
        if let repeatCount {
            self.repeatCount = max(1, repeatCount)
        }
        self.invalidateIntrinsicContentSize()
        self.needsDisplay = true
    }

    var currentItems: [KeycapItem] {
        self.items
    }

    func scheduleFadeOut(onCompletion completion: @escaping () -> Void) {
        self.fadeWorkItem?.cancel()
        let delay = max(0.1, TimeInterval(self.settings.fadeDelay))
        let duration = max(0, TimeInterval(self.settings.fadeDuration))
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                self.animator().alphaValue = 0
            } completionHandler: {
                completion()
            }
        }
        self.fadeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}

// MARK: - NSView
extension KeyboardVisualizerGroupView {
    var preferredSize: NSSize {
        let scaledSize = NSSize(
            width: self.baseSize.width * self.scale,
            height: self.baseSize.height * self.scale
        )
        return NSSize(
            width: max(0, scaledSize.width.rounded(.up)),
            height: max(0, scaledSize.height.rounded(.up))
        )
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

    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()
        let transform = NSAffineTransform()
        transform.scale(by: self.scale)
        transform.concat()

        self.drawBackground()

        let sizes = self.itemSizes()
        var x = self.groupPadding.left
        for (item, size) in zip(self.items, sizes) {
            let rect = NSRect(
                x: x,
                y: self.groupPadding.bottom,
                width: size.width,
                height: size.height
            )
            KeycapRendererFactory.makeRenderer(for: item, settings: self.settings).draw(
                context: KeycapContext(item: item, settings: self.settings),
                in: rect
            )
            x += size.width + self.groupSpacing
        }

        if self.repeatCount > 1 {
            self.drawRepeatBadge()
        }

        NSGraphicsContext.restoreGraphicsState()
    }
}

// MARK: - Layout
private extension KeyboardVisualizerGroupView {
    /// Uniform scale applied to the keycap drawing. Combines the user-selected size with a
    /// per-style normalization factor so every style renders at a comparable size.
    var scale: CGFloat { self.settings.style.sizeNormalization * max(0.1, self.settings.scale) }

    /// Group size in base (unscaled) drawing coordinates.
    var baseSize: NSSize {
        let sizes = self.itemSizes()
        let keysWidth = sizes.reduce(CGFloat(0)) { $0 + $1.width }
            + self.groupSpacing * CGFloat(max(0, sizes.count - 1))
        let fallbackHeight: CGFloat
        switch self.settings.style {
        case .minimal:
            fallbackHeight = MinimalKeycapMetrics.height
        case .retro:
            fallbackHeight = RetroKeycapMetrics.height
        case .m0116:
            fallbackHeight = M0116KeycapMetrics.height
        case .apple, .pbt:
            fallbackHeight = AppleKeycapMetrics.height
        }
        let height = sizes.map(\.height).max() ?? fallbackHeight
        return NSSize(
            width: self.groupPadding.left + self.groupPadding.right + keysWidth,
            height: self.groupPadding.top + self.groupPadding.bottom + height
        )
    }

    private func itemSizes() -> [CGSize] {
        self.items.map {
            KeycapRendererFactory.makeRenderer(for: $0, settings: self.settings)
                .size(for: KeycapContext(item: $0, settings: self.settings))
        }
    }

    private var groupPadding: NSEdgeInsets {
        switch self.settings.style {
        case .minimal:
            return MinimalKeycapMetrics.groupPadding
        case .retro:
            return RetroKeycapMetrics.groupPadding
        case .m0116:
            return M0116KeycapMetrics.groupPadding
        case .apple:
            return AppleKeycapMetrics.groupPadding
        case .pbt:
            return PBTKeycapMetrics.groupPadding
        }
    }

    private var groupSpacing: CGFloat {
        switch self.settings.style {
        case .minimal:
            return MinimalKeycapMetrics.itemSpacing
        case .retro:
            return RetroKeycapMetrics.itemSpacing
        case .m0116:
            return M0116KeycapMetrics.itemSpacing
        case .apple, .pbt:
            return AppleKeycapMetrics.itemSpacing
        }
    }

    private var repeatBadgeInset: CGPoint {
        switch self.settings.style {
        case .minimal:
            return MinimalKeycapMetrics.repeatBadgeInset
        case .retro:
            return RetroKeycapMetrics.repeatBadgeInset
        case .m0116:
            return M0116KeycapMetrics.repeatBadgeInset
        case .apple:
            return AppleKeycapMetrics.repeatBadgeInset
        case .pbt:
            return PBTKeycapMetrics.repeatBadgeInset
        }
    }
}

// MARK: - Drawing
private extension KeyboardVisualizerGroupView {
    private func drawBackground() {
        let baseBounds = NSRect(origin: .zero, size: self.baseSize)
        let insetBounds = baseBounds.insetBy(dx: 1, dy: 1)
        let radius: CGFloat
        switch self.settings.style {
        case .minimal:
            radius = insetBounds.height / 2
        case .retro:
            radius = 24
        case .m0116:
            radius = 12
        case .apple, .pbt:
            radius = 18
        }
        let path = NSBezierPath(roundedRect: insetBounds, xRadius: radius, yRadius: radius)
        let appearance = self.settings.groupAppearance
        appearance.shared.groupBackgroundColor.setFill()
        path.fill()
        appearance.shared.groupStrokeColor.setStroke()
        path.lineWidth = StrokeWidth.standard
        path.stroke()
    }

    private func drawRepeatBadge() {
        let badgeText = String(self.repeatCount)
        let font = NSFont.systemFont(ofSize: 15, weight: .semibold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let appearance = self.settings.groupAppearance
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: appearance.shared.badgeTextColor,
            .paragraphStyle: paragraphStyle,
        ]
        let labelSize = badgeText.size(withAttributes: attributes)
        let badgeHeight = max(26, labelSize.height + 8)
        let badgeWidth = max(badgeHeight, labelSize.width + 14)
        let inset = self.repeatBadgeInset
        let badgeRect = NSRect(
            x: self.baseSize.width - badgeWidth - inset.x,
            y: self.baseSize.height - badgeHeight - inset.y,
            width: badgeWidth,
            height: badgeHeight
        )

        let badgePath = NSBezierPath(
            roundedRect: badgeRect,
            xRadius: badgeHeight / 2,
            yRadius: badgeHeight / 2
        )
        appearance.shared.badgeFillColor.setFill()
        badgePath.fill()
        appearance.shared.badgeStrokeColor.setStroke()
        badgePath.lineWidth = StrokeWidth.standard
        badgePath.stroke()

        let highlightRect = badgeRect.insetBy(dx: 1, dy: 1)
        let highlightPath = NSBezierPath(
            roundedRect: highlightRect,
            xRadius: highlightRect.height / 2,
            yRadius: highlightRect.height / 2
        )
        appearance.shared.badgeHighlightColor.setStroke()
        highlightPath.lineWidth = 1
        highlightPath.stroke()

        badgeText.draw(
            in: NSRect(
                x: badgeRect.minX,
                y: badgeRect.midY - labelSize.height / 2,
                width: badgeRect.width,
                height: labelSize.height
            ),
            withAttributes: attributes
        )
    }
}
