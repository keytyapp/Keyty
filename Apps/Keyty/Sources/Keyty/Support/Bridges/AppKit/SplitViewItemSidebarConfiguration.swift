//
//  SplitViewItemSidebarConfiguration.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

/// Configures the first split view item of an enclosing `NSSplitViewController`.
///
/// This avoids replacing the split view delegate that SwiftUI's `NavigationView`
/// already owns, and instead mutates the controller-managed `NSSplitViewItem`.
struct SplitViewItemSidebarConfiguration: NSViewRepresentable {
    let width: CGFloat

    func makeNSView(context: Context) -> NSView {
        NSView(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let splitViewController = self.findSplitViewController(from: nsView) else { return }
            guard let sidebarItem = splitViewController.splitViewItems.first else { return }

            sidebarItem.canCollapse = false
            sidebarItem.canCollapseFromWindowResize = false
            sidebarItem.minimumThickness = self.width
            sidebarItem.maximumThickness = self.width
            sidebarItem.automaticMaximumThickness = self.width
        }
    }
}

private extension SplitViewItemSidebarConfiguration {
    func findSplitViewController(from view: NSView) -> NSSplitViewController? {
        if let controller = view.window?.contentViewController.flatMap({ self.findSplitViewController(in: $0) }) {
            return controller
        }

        var responder: NSResponder? = view
        while let current = responder {
            if let controller = current as? NSViewController,
               let splitViewController = self.findSplitViewController(in: controller) {
                return splitViewController
            }
            responder = current.nextResponder
        }

        return nil
    }

    func findSplitViewController(in controller: NSViewController) -> NSSplitViewController? {
        if let splitViewController = controller as? NSSplitViewController {
            return splitViewController
        }

        for childViewController in controller.children {
            if let splitViewController = self.findSplitViewController(in: childViewController) {
                return splitViewController
            }
        }

        if let presentedViewController = controller.presentedViewControllers?.first {
            return self.findSplitViewController(in: presentedViewController)
        }

        return nil
    }
}
