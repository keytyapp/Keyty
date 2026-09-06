//
//  NSWorkspace+AccessibilitySettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension NSWorkspace {
    func openAccessibilitySettings() {
        self.open(.accessibilitySettings)
    }
}
