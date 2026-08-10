//
//  PointerIconVisualizerWindow.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

final class PointerIconVisualizerWindow: NSWindow {
    private let pointerContentView: PointerIconContentView

    init(
        contentView: PointerIconContentView,
        contentSize: NSSize
    ) {
        self.pointerContentView = contentView
        super.init(
            contentRect: NSRect(origin: .zero, size: contentSize),
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
        self.contentView = self.pointerContentView
    }

    func updateContentSize(_ size: NSSize) {
        self.setContentSize(size)
        self.contentView?.needsDisplay = true
    }

    func update(screenLocation: NSPoint, anchor: PointerIconAnchor, offset: CGFloat) {
        let size = self.frame.size
        let origin = anchor.origin(relativeTo: screenLocation, windowSize: size, offset: offset)
        self.setFrameOrigin(origin)
    }

    func update(mouseEvent: MouseEvent) {
        self.pointerContentView.handle(mouseEvent: mouseEvent)
    }

    func setVisible(_ isVisible: Bool) {
        if isVisible {
            self.orderFrontRegardless()
        } else {
            self.orderOut(nil)
        }
    }
}

private extension PointerIconAnchor {
    func origin(relativeTo cursor: NSPoint, windowSize: NSSize, offset: CGFloat) -> NSPoint {
        switch self {
        case .bottomRight:
            return NSPoint(x: cursor.x + offset, y: cursor.y - windowSize.height - offset)
        case .bottomLeft:
            return NSPoint(x: cursor.x - windowSize.width - offset, y: cursor.y - windowSize.height - offset)
        case .topRight:
            return NSPoint(x: cursor.x + offset, y: cursor.y + offset)
        case .topLeft:
            return NSPoint(x: cursor.x - windowSize.width - offset, y: cursor.y + offset)
        }
    }
}
