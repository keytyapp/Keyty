//
//  Permission.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import ApplicationServices

enum Permission: CaseIterable, Hashable {
    case accessibility

    func isGranted() -> Bool {
        AXIsProcessTrusted()
    }

    func requestSystemPermission() {
        let key = kAXTrustedCheckOptionPrompt.takeRetainedValue() as String
        AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
        NSWorkspace.shared.openAccessibilitySettings()
    }
}

// MARK: - Permission Status
extension Permission {
    enum Status: Equatable {
        case granted
        case notGranted
    }
}
