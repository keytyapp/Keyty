//
//  ColorPanelController.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Bridges the shared `NSColorPanel` target-action callbacks to closure-based color-change handling.
@MainActor
final class ColorPanelController: NSObject {
    var onColorChange: ((NSColor) -> Void)?

    func present(initialColor: NSColor) {
        let panel = NSColorPanel.shared
        panel.showsAlpha = true
        panel.setTarget(self)
        panel.setAction(#selector(self.colorDidChange(_:)))
        panel.color = initialColor
        panel.orderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc
    private func colorDidChange(_ sender: NSColorPanel) {
        self.onColorChange?(sender.color)
    }
}
