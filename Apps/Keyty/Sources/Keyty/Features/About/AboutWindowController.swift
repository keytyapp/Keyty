//
//  AboutWindowController.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class AboutWindowController: NSWindowController {
    let viewModel: AboutWindowViewModel

    private var cancellables = Set<AnyCancellable>()

    init(bundle: Bundle = .main) {
        self.viewModel = AboutWindowViewModel(bundle: bundle)

        let window = Window()
        let rootView = AboutWindowView(viewModel: self.viewModel)
        window.contentViewController = NSHostingController(rootView: rootView)

        super.init(window: window)
        self.bindWindowTitle()
        self.updateWindowTitle(for: self.viewModel.selectedTab)
        window.center()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(bundle:) instead.")
    }

    override func showWindow(_ sender: Any?) {
        self.window?.makeKeyAndOrderFront(sender)
    }

    private func bindWindowTitle() {
        self.viewModel.$selectedTab
            .sink { [weak self] tab in
                self?.updateWindowTitle(for: tab)
            }
            .store(in: &self.cancellables)
    }

    private func updateWindowTitle(for tab: AboutWindowViewModel.Tab) {
        self.window?.title = tab.title
    }
}

// MARK: - Custom Window
extension AboutWindowController {
    final class Window: NSWindow {
        private let titlebarToolbar = NSToolbar(identifier: "KeytyAboutToolbar")

        init() {
            super.init(
                contentRect: NSRect(origin: .zero, size: Size.Window.about),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: true
            )

            self.title = AppConstants.appName
            self.titleVisibility = .hidden
            self.titlebarAppearsTransparent = true
            self.isMovableByWindowBackground = true
            self.isReleasedWhenClosed = false
            self.minSize = Size.Window.about
            self.maxSize = Size.Window.about
            self.toolbarStyle = .unified

            self.titlebarToolbar.allowsUserCustomization = false
            self.titlebarToolbar.autosavesConfiguration = false
            self.titlebarToolbar.displayMode = .iconOnly
            self.titlebarToolbar.showsBaselineSeparator = false
            self.toolbar = self.titlebarToolbar
        }
    }
}
