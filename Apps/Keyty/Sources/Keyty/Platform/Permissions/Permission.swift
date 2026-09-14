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
    case inputMonitoring

    static var inputCapture: Self {
        #if APP_STORE
        .inputMonitoring
        #else
        .accessibility
        #endif
    }

    func isGranted() -> Bool {
        switch self {
        case .accessibility:
            AXIsProcessTrusted()
        case .inputMonitoring:
            CGPreflightListenEventAccess()
        }
    }

    func requestSystemPermission() {
        switch self {
        case .accessibility:
            let key = kAXTrustedCheckOptionPrompt.takeRetainedValue() as String
            AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
            NSWorkspace.shared.openAccessibilitySettings()
        case .inputMonitoring:
            CGRequestListenEventAccess()
            NSWorkspace.shared.openInputMonitoringSettings()
        }
    }
}

// MARK: - Permission Status
extension Permission {
    enum Status: Equatable {
        case granted
        case notGranted
    }
}
