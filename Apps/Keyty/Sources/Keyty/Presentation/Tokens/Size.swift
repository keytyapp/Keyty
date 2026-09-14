//
//  Size.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics

enum Size {
    static let bootstrapWindow = CGSize(width: Spacing.unit, height: Spacing.unit)

    enum Window {
        static let about = CGSize(width: Spacing.grid(155), height: Spacing.grid(91))
        static let permissionsOnboarding = CGSize(width: Spacing.grid(165), height: Spacing.grid(96))
        static let settings = CGSize(width: Spacing.grid(180) * 1.1, height: Spacing.grid(110) * 1.1)
    }

    enum Pane {
        static let general = Spacing.grid(99)
        static let keyboard = Spacing.grid(96)
        static let permissions = Spacing.grid(96)
        static let mouse = Spacing.grid(96)
        static let displays = Spacing.grid(96)
        static let update = Spacing.grid(96)
        static let minimalKeycapsPreview = CGSize(width: Spacing.grid(95), height: Spacing.grid(95))
        static let pbtKeycapsPreview = CGSize(width: Spacing.grid(95), height: Spacing.grid(43))
        static let appleKeycapsPreview = CGSize(width: Spacing.grid(95), height: Spacing.grid(43))
    }

    enum Settings {
        static let label = Spacing.grid(32)
        static let wideLabel = Spacing.grid(35)
        static let minimalLabel = Spacing.grid(38)
        static let visualizerLabel = Spacing.grid(30)
        static let picker = Spacing.grid(51)
        static let recorder = CGSize(width: Spacing.grid(36), height: Spacing.grid(6))
        static let headerHeight = Spacing.grid(12)
        static let tileHeight = Spacing.grid(44)
        static let emptyUpdatePane = CGSize(width: Pane.update, height: Spacing.grid(25))
        static let sidebarWidth = Spacing.grid(58)
        static let sidebarBadgeHeight = Spacing.grid(4)
        static let sidebarBadgeMinimumWidth = Spacing.grid(4)
        static let detailContentWidth = Spacing.grid(150)
    }

    enum KeyboardVisualizer {
        static let groupSpacing = Spacing.md
        static let windowPadding: CGFloat = Spacing.xs
    }

    enum Control {
        static let height = Spacing.grid(6)
        static let swatch = Spacing.grid(4)
        static let colorWell = CGSize(width: Spacing.grid(11), height: Spacing.grid(6))
        static let numberFieldWidth = Spacing.grid(11)
        static let settingsPickerWidth = Spacing.grid(45)
        static let keyboardStylePickerWidth = Spacing.grid(56)
        static let themePickerWidth = settingsPickerWidth
    }
}
