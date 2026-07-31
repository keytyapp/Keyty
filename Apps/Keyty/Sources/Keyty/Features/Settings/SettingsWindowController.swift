//
//  SettingsWindowController.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine
import Sparkle
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
    let sidebarViewModel = SettingsSidebarViewModel()
    private let registry: SettingsPaneRegistry
    private var cancellables = Set<AnyCancellable>()
    private var permissionObservationToken: PermissionObservationToken?

    init(
        shortcutManager: ShortcutManager,
        appSettings: any AppSettingsProtocol,
        pointerRingVisualizer: PointerRingVisualizer,
        pointerRingSettings: any PointerRingSettingsProtocol,
        pointerIconSettings: any PointerIconSettingsProtocol,
        keyboardVisualizerSettings: KeyboardVisualizerSettings,
        startSettingKeyboardVisualizerPosition: @escaping @MainActor () -> Void,
        stopSettingKeyboardVisualizerPosition: @escaping @MainActor () -> Void,
        permissionsService: any PermissionsService,
        updater: SPUUpdater
    ) {
        self.registry = SettingsPaneRegistry(
            shortcutManager: shortcutManager,
            appSettings: appSettings,
            pointerRingVisualizer: pointerRingVisualizer,
            pointerRingSettings: pointerRingSettings,
            pointerIconSettings: pointerIconSettings,
            keyboardVisualizerSettings: keyboardVisualizerSettings,
            startSettingKeyboardVisualizerPosition: startSettingKeyboardVisualizerPosition,
            stopSettingKeyboardVisualizerPosition: stopSettingKeyboardVisualizerPosition,
            permissionsService: permissionsService,
            updater: updater
        )

        let window = Window()
        let rootView = SettingsRootView(registry: self.registry, sidebarViewModel: self.sidebarViewModel)
        window.contentViewController = NSHostingController(rootView: rootView)

        super.init(window: window)
        self.bindWindowTitle()
        self.bindSidebarBadges(permissionsService: permissionsService)
        self.updateWindowTitle(for: self.sidebarViewModel.selectedPaneID)
        window.center()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(shortcutManager:appSettings:pointerRingVisualizer:pointerRingSettings:pointerIconSettings:keyboardVisualizerSettings:startSettingKeyboardVisualizerPosition:stopSettingKeyboardVisualizerPosition:permissionsService:updater:) instead.")
    }

    override func showWindow(_ sender: Any?) {
        self.window?.makeKeyAndOrderFront(sender)
        self.window?.center()
    }

    func selectPane(_ identifier: SettingsPaneIdentifier) {
        self.sidebarViewModel.select(identifier)
    }

    private func bindWindowTitle() {
        self.sidebarViewModel.$selectedPaneID
            .sink { [weak self] identifier in
                self?.updateWindowTitle(for: identifier)
            }
            .store(in: &self.cancellables)
    }

    private func bindSidebarBadges(permissionsService: any PermissionsService) {
        self.updatePermissionsBadge(permissionsService: permissionsService)
        self.permissionObservationToken = permissionsService.observeChanges { [weak self, weak permissionsService] in
            guard let permissionsService else { return }
            Task { @MainActor in
                self?.updatePermissionsBadge(permissionsService: permissionsService)
            }
        }
    }

    private func updatePermissionsBadge(permissionsService: any PermissionsService) {
        let missingPermissionCount = Permission.allCases.filter {
            permissionsService.status(for: $0) == .notGranted
        }.count

        self.sidebarViewModel.setBadgeCount(missingPermissionCount, for: .permissions)
    }

    private func updateWindowTitle(for identifier: SettingsPaneIdentifier) {
        self.window?.title = self.registry.entry(for: identifier)?.title ?? AppConstants.appName
    }
}

extension SettingsWindowController {
    final class Window: NSWindow {
        private let titlebarToolbar = NSToolbar(identifier: "KeytySettingsToolbar")

        init() {
            super.init(
                contentRect: NSRect(origin: .zero, size: Size.Window.settings),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: true
            )
            self.title = AppConstants.appName
            self.titleVisibility = .hidden
            self.titlebarAppearsTransparent = true
            self.isReleasedWhenClosed = false
            self.minSize = Size.Window.settings
            self.toolbarStyle = .unified

            self.titlebarToolbar.allowsUserCustomization = false
            self.titlebarToolbar.autosavesConfiguration = false
            self.titlebarToolbar.displayMode = .iconOnly
            self.titlebarToolbar.showsBaselineSeparator = false
            self.toolbar = self.titlebarToolbar
        }
    }
}
