//
//  MainMenu.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Builds and wires the status item menu used by the menu-bar-only app.
final class MenuController {
    private weak var appController: AppController?
    private var controlledMenuItems: [NSMenuItem] = []

    init(appController: AppController? = nil) {
        self.appController = appController
    }

    func setAppController(_ appController: AppController) {
        self.appController = appController
        self.controlledMenuItems.forEach { $0.target = appController }
    }

    func makeStatusShortcutMenuItem() -> NSMenuItem {
        self.makeShortcutMenuItem(action: #selector(AppController.toggleCapturing(_:)))
    }

    func makeStatusMenu(shortcutItem: NSMenuItem) -> NSMenu {
        let menu = NSMenu(title: AppConstants.appName)
        menu.addItem(shortcutItem)
        menu.addItem(self.makeSettingsMenuItem())
        menu.addItem(self.makeQuitMenuItem())
        return menu
    }

    func makeMainMenu() -> NSMenu {
        let mainMenu = NSMenu(title: AppConstants.appName)

        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = self.makeApplicationMenu()
        mainMenu.addItem(appMenuItem)

        let fileMenuItem = NSMenuItem()
        fileMenuItem.submenu = self.makeFileMenu()
        mainMenu.addItem(fileMenuItem)

        return mainMenu
    }
}

// MARK: - Private API
private extension MenuController {
    private func makeApplicationMenu() -> NSMenu {
        let menu = NSMenu(title: AppConstants.appName)
        menu.addItem(self.makeQuitMenuItem())
        return menu
    }

    private func makeFileMenu() -> NSMenu {
        let menu = NSMenu(title: L10n.MainMenu.file)
        let close = NSMenuItem(title: L10n.MainMenu.closeWindow, action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        close.keyEquivalentModifierMask = [.command]
        menu.addItem(close)
        return menu
    }

    private func makeSettingsMenuItem() -> NSMenuItem {
        let item = NSMenuItem(
            title: L10n.MainMenu.settings,
            action: #selector(AppController.orderFrontKeytySettingsPanel(_:)),
            keyEquivalent: ","
        )
        return self.register(item)
    }

    private func makeShortcutMenuItem(action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: L10n.General.startCapturing, action: action, keyEquivalent: "S")
        item.keyEquivalentModifierMask = [.shift, .option]
        return self.register(item)
    }

    private func makeQuitMenuItem() -> NSMenuItem {
        let item = NSMenuItem(title: L10n.MainMenu.quit(AppConstants.appName), action: #selector(AppController.quitApplication(_:)), keyEquivalent: "q")
        item.keyEquivalentModifierMask = [.command]
        return self.register(item)
    }

    private func register(_ item: NSMenuItem) -> NSMenuItem {
        item.target = self.appController
        self.controlledMenuItems.append(item)
        return item
    }
}
