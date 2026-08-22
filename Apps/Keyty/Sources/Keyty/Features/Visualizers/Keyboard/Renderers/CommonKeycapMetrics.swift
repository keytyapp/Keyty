//
//  CommonKeycapMetrics.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum CommonKeycapMetrics {
    static let horizontalPadding: CGFloat = 10
    static let symbolFont = NSFont.systemFont(ofSize: 22, weight: .medium)
    static let labelFont = NSFont.systemFont(ofSize: 14, weight: .medium)
    static let charFont = NSFont.systemFont(ofSize: 24, weight: .medium)

    /// Shared keycap widths for left and right variants of each modifier kind.
    static let fixedModifierWidths: [KeyboardModifierKey.Kind: CGFloat] = [
        .command: 88,
        .option: 72,
        .shift: 100,
    ]

    /// Fixed widths for individual key identities whose legends need custom sizing.
    static let fixedIdentityWidths: [KeycapIdentity: CGFloat] = [
        .keyCode(KeyboardKeyCode.tab.rawValue): 112,
        .keyCode(KeyboardKeyCode.escape.rawValue): 112,
        .keyCode(KeyboardKeyCode.delete.rawValue): 112,
        .keyCode(KeyboardKeyCode.forwardDelete.rawValue): 112,
        .keyCode(KeyboardKeyCode.returnKey.rawValue): 128,
        .keyCode(KeyboardKeyCode.keypadEnter.rawValue): 128,
        .keyCode(KeyboardKeyCode.capsLock.rawValue): 144,
    ]
}
