//
//  Color+Theme.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

extension Color {
    enum Theme {}
}

extension Color.Theme {
    enum About {
        static let linkText = Color(.sRGB, red: 0.35, green: 0.72, blue: 1.0, opacity: 1)
    }

    enum Settings {
        static let clear = Color.clear
    }

    enum Surface {
        static let detailBackground = Color(appKitColor: .clear)
        static let cardBackground = Color(appKitColor:  .alternatingContentBackgroundColors[1])
        static let surfaceBackground = Color(appKitColor: NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                return NSColor(calibratedWhite: 0.14, alpha: 1)
            } else {
                return NSColor(calibratedWhite: 0.94, alpha: 1)
            }
        })
    }

    enum Border {
        static let primary = Color.white.opacity(0.07)
        static let sidebar = Color(appKitColor: .separatorColor).opacity(0.55)
        static let headerSeparator = Color(appKitColor: .separatorColor).opacity(0.4)
        static let selection = Color(appKitColor: .separatorColor).opacity(0.2)
        static let iconBadgeSelected = Color.white.opacity(0.18)
        static let iconBadgeUnselected = Color.white.opacity(0.10)
    }

    enum Text {
        static let primary = Color(appKitColor: .labelColor)
        static let header = Color(appKitColor: .headerTextColor)
        static let secondary = Color(appKitColor: .secondaryLabelColor)
        static let selected = Color(appKitColor: .selectedTextColor)
        
        static let sidebarItem = Color(appKitColor: .labelColor)
        static let sidebarItemSelected = Color.white
    }

    enum Accent {
        static let controlAccent = Color(appKitColor: .controlAccentColor)
    }

    enum Shadow {
        static let primary = Color.black.opacity(0.35)
        static let displayMarker = primary.opacity(0.35)
        static let iconBadgeSelected = Color.black.opacity(0.24)
        static let iconBadgeUnselected = Color.black.opacity(0.14)
    }

    enum Preview {
        static let badgeBackground = Color.black.opacity(0.42)
    }

    enum State {
        static let success = Color(appKitColor: .systemGreen)
        static let danger = Color(appKitColor: .systemRed)
        static let warning = Color(appKitColor: .systemOrange)
    }
    
    enum Brand {
        static let black = Color.black
        static let white = Color.white
    }

    /// Reusable semantic accent colors derived from system hues.
    /// Use these as shared building blocks, then compose feature-specific gradients or states closer to the consumer.
    enum Palette {
        static let graphite = NSColor.systemGray
        static let blue = NSColor.systemBlue
        static let orange = NSColor.systemOrange
        static let indigo = NSColor.systemIndigo
        static let red = NSColor.systemRed
        static let yellow = NSColor.systemYellow
        static let green = NSColor.systemGreen
        static let purple = NSColor.systemPurple
        static let pink = NSColor.systemPink
        static let teal = NSColor.systemTeal
        static let white = NSColor.white
        static let black = NSColor.black

        static let graphite60 = graphite.withAlphaComponent(0.6)
        static let blue60 = blue.withAlphaComponent(0.6)
        static let orange60 = orange.withAlphaComponent(0.6)
        static let indigo60 = indigo.withAlphaComponent(0.6)
        static let red60 = red.withAlphaComponent(0.6)
        static let yellow60 = yellow.withAlphaComponent(0.6)
        static let green60 = green.withAlphaComponent(0.6)
        static let purple60 = purple.withAlphaComponent(0.6)
        static let pink60 = pink.withAlphaComponent(0.6)
        static let teal60 = teal.withAlphaComponent(0.6)
        static let white60 = white.withAlphaComponent(0.6)
        static let black60 = black.withAlphaComponent(0.6)
    }
}
