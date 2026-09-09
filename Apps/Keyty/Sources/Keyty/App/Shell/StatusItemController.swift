//
//  StatusItemController.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

final class StatusItemController {
    private let menu: NSMenu
    private let shortcutItem: NSMenuItem
    private let statusItem: NSStatusItem

    private var statusItemImage: NSImage {
        if !self.isAccessibilityGranted {
            let image = NSImage.statusItemPermissionRequired
            image.isTemplate = true
            return image
        }

        let image = self.isCapturing ? NSImage.statusItemEnabled : NSImage.statusItemDisabled
        image.isTemplate = true
        return image
    }

    init(menu: NSMenu, shortcutItem: NSMenuItem) {
        self.menu = menu
        self.shortcutItem = shortcutItem
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.menu = menu
        let image = NSImage.statusItemDisabled
        image.isTemplate = true
        item.button?.image = image
        self.statusItem = item
    }

    var isCapturing: Bool = false {
        didSet {
            self.shortcutItem.title = isCapturing ? L10n.General.stopCapturing : L10n.General.startCapturing
            self.updateStatusItemImage()
        }
    }

    var isAccessibilityGranted: Bool = false {
        didSet {
            self.updateStatusItemImage()
        }
    }

    private func updateStatusItemImage() {
        self.statusItem.button?.image = self.statusItemImage
    }
}
