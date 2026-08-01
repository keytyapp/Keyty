//
//  Screen.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

struct Screen: Identifiable, Equatable {
    let id: CGDirectDisplayID
    let displayName: String
    let wallpaperImageURL: URL?
    let frame: CGRect

    init(
        id: CGDirectDisplayID,
        displayName: String,
        wallpaperImageURL: URL?,
        frame: CGRect
    ) {
        self.id = id
        self.displayName = displayName
        self.wallpaperImageURL = wallpaperImageURL
        self.frame = frame
    }

    init(_ nsScreen: NSScreen) {
        self.id = nsScreen.displayID
        self.displayName = nsScreen.localizedName
        self.wallpaperImageURL = NSWorkspace.shared.desktopImageURL(for: nsScreen)
        self.frame = nsScreen.frame
    }

    var wallpaperImage: NSImage? {
        guard let wallpaperImageURL else {
            return nil
        }

        return NSImage(contentsOf: wallpaperImageURL)
    }
}
