//
//  MainMenu.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Builds and wires the status item menu used by the menu-bar-only app.
final class MenuController: NSObject {
    private weak var appController: AppController?
    private var controlledMenuItems: [NSMenuItem] = []
    private var visualizerMenuItems: [Visualizer: NSMenuItem] = [:]
    private var settings: AppSettingsContainer?

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

    func makeStatusMenu(shortcutItem: NSMenuItem, settings: AppSettingsContainer) -> NSMenu {
        self.settings = settings

        let menu = NSMenu(title: AppConstants.appName)
        menu.addItem(shortcutItem)
        menu.addItem(self.makeVisualizersMenuItem())
        menu.addItem(self.makeSettingsMenuItem())
        menu.addItem(self.makeQuitMenuItem())
        menu.delegate = self
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

// MARK: - NSMenuDelegate
extension MenuController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        self.updateVisualizerMenuItemStates()
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

    private func makeVisualizersMenuItem() -> NSMenuItem {
        let menu = NSMenu(title: L10n.MainMenu.visualizers)
        menu.addItem(self.makeVisualizerMenuItem(.keyboard))
        menu.addItem(self.makeVisualizerMenuItem(.pointerRing))
        menu.addItem(self.makeVisualizerMenuItem(.pointerRipples))
        menu.addItem(self.makeVisualizerMenuItem(.pointerIcon))

        let item = NSMenuItem(title: L10n.MainMenu.visualizers, action: nil, keyEquivalent: "")
        item.submenu = menu
        return item
    }

    private func makeVisualizerMenuItem(_ visualizer: Visualizer) -> NSMenuItem {
        let item = NSMenuItem(title: visualizer.title, action: visualizer.action, keyEquivalent: "")
        self.visualizerMenuItems[visualizer] = self.register(item)
        return item
    }

    private func updateVisualizerMenuItemStates() {
        guard let settings = self.settings else { return }

        self.visualizerMenuItems.forEach { visualizer, item in
            item.state = visualizer.isEnabled(in: settings) ? .on : .off
        }
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

private extension MenuController {
    enum Visualizer: CaseIterable {
        case keyboard
        case pointerRing
        case pointerRipples
        case pointerIcon

        var title: String {
            switch self {
            case .keyboard:
                return L10n.Settings.Pane.keyboard
            case .pointerRing:
                return L10n.Mouse.tabRing
            case .pointerRipples:
                return L10n.Mouse.tabRipples
            case .pointerIcon:
                return L10n.Mouse.tabIcon
            }
        }

        var action: Selector {
            switch self {
            case .keyboard:
                return #selector(AppController.toggleKeyboardVisualizer(_:))
            case .pointerRing:
                return #selector(AppController.togglePointerRingVisualizer(_:))
            case .pointerRipples:
                return #selector(AppController.togglePointerRipplesVisualizer(_:))
            case .pointerIcon:
                return #selector(AppController.togglePointerIconVisualizer(_:))
            }
        }

        func isEnabled(in settings: AppSettingsContainer) -> Bool {
            switch self {
            case .keyboard:
                return settings.keyboardVisualizerSettings.isEnabled
            case .pointerRing:
                return settings.pointerRingSettings.isEnabled
            case .pointerRipples:
                return settings.pointerRipplesSettings.isEnabled
            case .pointerIcon:
                return settings.pointerIconSettings.isEnabled
            }
        }
    }
}
