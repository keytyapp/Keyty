//
//  KeyboardVisualizerWindow.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

final class KeyboardVisualizerWindow: NSWindow {
    private let settings: KeyboardVisualizerSettings
    private let screensService: any ScreenServiceProvider
    private let rootView = NSView()
    private var groupViews: [KeyboardVisualizerGroupView] = []
    private var cancellables = Set<AnyCancellable>()
    var onGroupRemoved: ((KeyboardVisualizerGroupView) -> Void)?
    var groupCount: Int { self.groupViews.count }

    init(
        settings: KeyboardVisualizerSettings = KeyboardVisualizerSettings(),
        screensService: any ScreenServiceProvider = ScreensService.shared
    ) {
        self.settings = settings
        self.screensService = screensService
        let frame = NSRect(origin: NSPoint(x: settings.windowPadding, y: settings.windowPadding), size: Size.bootstrapWindow)
        super.init(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)

        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.alphaValue = 1
        self.ignoresMouseEvents = true
        self.collectionBehavior = .canJoinAllSpaces
        self.contentView = self.rootView

        // The window is pinned to a screen anchor; re-pin when the placement setting
        // (anchor or target screen) changes or when the screen layout (resolution,
        // arrangement) changes.
        self.settings.placementChanges
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.repositionToAnchor()
            }
            .store(in: &self.cancellables)
        self.screensService.screensDidChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.repositionToAnchor()
            }
            .store(in: &self.cancellables)
        self.repositionToAnchor()
    }

    @discardableResult
    func appendGroup(with items: [KeycapItem]) -> KeyboardVisualizerGroupView {
        let groupView = KeyboardVisualizerGroupView(items: items, settings: self.settings)
        self.rootView.addSubview(groupView)
        self.groupViews.append(groupView)
        self.enforceMaxCount()
        self.layoutGroups()
        self.scheduleFadeOut(for: groupView)
        return groupView
    }

    func updateGroup(_ groupView: KeyboardVisualizerGroupView, with items: [KeycapItem]) {
        guard self.groupViews.contains(where: { $0 === groupView }) else { return }
        groupView.configure(items: items, settings: self.settings)
        groupView.alphaValue = 1
        self.layoutGroups()
        self.scheduleFadeOut(for: groupView)
    }

    func removeAllGroups() {
        let removedGroups = self.groupViews
        self.groupViews.removeAll()
        removedGroups.forEach { groupView in
            groupView.removeFromSuperview()
            self.onGroupRemoved?(groupView)
        }
        self.layoutGroups()
    }

    private func scheduleFadeOut(for groupView: KeyboardVisualizerGroupView) {
        groupView.scheduleFadeOut { [weak self, weak groupView] in
            guard let self, let groupView else { return }
            guard self.groupViews.contains(where: { $0 === groupView }) else { return }
            self.groupViews.removeAll { $0 === groupView }
            groupView.removeFromSuperview()
            self.onGroupRemoved?(groupView)
            self.layoutGroups()
        }
    }

    private func enforceMaxCount() {
        let maxCount = self.settings.maxCount
        while self.groupViews.count > maxCount {
            let view = self.groupViews.removeFirst()
            view.removeFromSuperview()
            self.onGroupRemoved?(view)
        }
    }

    private func layoutGroups() {
        let stackAxis = self.settings.stackAxis
        let alignment = self.settings.alignment
        let spacing = Size.KeyboardVisualizer.groupSpacing
            * self.settings.style.sizeNormalization * self.settings.scale
        let orderedViews = self.groupViews.reversed()
        let viewSizes = orderedViews.map { ($0, $0.preferredSize) }
        var cursor = CGPoint.zero
        var contentSize = NSSize.zero

        for (_, size) in viewSizes {
            switch stackAxis {
            case .horizontal:
                cursor.x += size.width + spacing
                contentSize.width  = cursor.x - spacing
                contentSize.height = max(contentSize.height, size.height)
            case .vertical:
                cursor.y += size.height + spacing
                contentSize.width  = max(contentSize.width, size.width)
                contentSize.height = cursor.y - spacing
            }
        }

        let layoutSize = NSSize(
            width: max(contentSize.width, Size.bootstrapWindow.width),
            height: max(contentSize.height, Size.bootstrapWindow.height)
        )
        let targetFrame = self.anchoredFrame(for: layoutSize)
        let customVerticalAnchorX = self.customVerticalAnchorX(in: targetFrame)

        cursor = .zero
        for (view, size) in viewSizes {
            let origin: CGPoint
            switch stackAxis {
            case .horizontal:
                origin = CGPoint(x: cursor.x, y: self.alignmentOffset(free: layoutSize.height - size.height, alignment: alignment))
                cursor.x += size.width + spacing
            case .vertical:
                origin = CGPoint(
                    x: self.horizontalOriginX(
                        for: size.width,
                        layoutWidth: layoutSize.width,
                        alignment: alignment,
                        customAnchorX: customVerticalAnchorX
                    ),
                    y: cursor.y
                )
                cursor.y += size.height + spacing
            }
            view.frame = NSRect(origin: origin, size: size)
        }

        self.rootView.frame = NSRect(origin: .zero, size: layoutSize)

        // The window is pinned to a screen anchor: it grows inward from the anchored
        // edges as content is added/removed, rather than tracking its previous frame.
        self.setFrame(targetFrame, display: true, animate: false)
    }

    /// Re-pins the window to its anchor without adding or removing any groups. Driven by
    /// anchor-setting and screen-layout changes. Group origins are recomputed too: in custom
    /// placement they are resolved against the anchor point, so alignment changes move them.
    @objc private func repositionToAnchor() {
        self.layoutGroups()
    }

    /// Frame that places `contentSize` against the main screen's visible area for the
    /// configured anchor, inset by `settings.windowPadding` from the anchored edges.
    private func anchoredFrame(for contentSize: NSSize) -> NSRect {
        var size = contentSize
        size.width  = max(size.width, Size.bootstrapWindow.width)
        size.height = max(size.height, Size.bootstrapWindow.height)

        guard let area = self.resolvedVisibleFrame() else {
            return NSRect(origin: self.frame.origin, size: size)
        }

        switch self.settings.placementMode {
        case .anchored:
            return self.anchoredFrame(size: size, in: area)
        case .custom:
            return self.customFrame(size: size, in: area)
        }
    }

    private func anchoredFrame(size: NSSize, in area: CGRect) -> NSRect {
        let anchor = self.settings.anchor
        let margin = self.settings.windowPadding

        let x: CGFloat
        switch anchor.horizontal {
        case .leading:  x = area.minX + margin
        case .center:   x = area.midX - size.width / 2
        case .trailing: x = area.maxX - size.width - margin
        }

        // AppKit's y grows upward, so the screen's top edge is `maxY`.
        let y: CGFloat
        switch anchor.vertical {
        case .top:    y = area.maxY - size.height - margin
        case .middle: y = area.midY - size.height / 2
        case .bottom: y = area.minY + margin
        }

        return NSRect(x: x, y: y, width: size.width, height: size.height)
    }

    private func customFrame(size: NSSize, in area: CGRect) -> NSRect {
        self.settings.effectiveHorizontalAlignment.frame(
            for: size,
            atNormalized: self.customNormalizedPosition,
            in: area
        )
    }

    private var customNormalizedPosition: CGPoint {
        CGPoint(
            x: self.settings.customPositionNormalizedX,
            y: self.settings.customPositionNormalizedY
        )
    }

    private func resolvedVisibleFrame() -> CGRect? {
        self.screensService.visibleFrame(preferring: self.settings.screenID)
    }

    private func alignmentOffset(free: CGFloat, alignment: KeyboardVisualizerAlignment) -> CGFloat {
        switch alignment {
        case .leading:  return 0
        case .center:   return free / 2
        case .trailing: return free
        }
    }

    private func horizontalOriginX(
        for width: CGFloat,
        layoutWidth: CGFloat,
        alignment: KeyboardVisualizerAlignment,
        customAnchorX: CGFloat?
    ) -> CGFloat {
        if let customAnchorX {
            return self.settings.effectiveHorizontalAlignment.originX(
                for: width,
                anchoredAt: customAnchorX
            )
        }

        return self.alignmentOffset(free: layoutWidth - width, alignment: alignment)
    }

    private func customVerticalAnchorX(in frame: NSRect) -> CGFloat? {
        guard self.settings.placementMode == .custom, self.settings.stackAxis == .vertical else {
            return nil
        }
        guard let area = self.resolvedVisibleFrame() else {
            return nil
        }

        // Expressed in window coordinates, since it positions groups inside `rootView`.
        return area.point(forNormalized: self.customNormalizedPosition).x - frame.minX
    }
}
