//
//  NSEventModifierFlags+Recorded.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import IOKit.hidsystem
@testable import Keyty

extension NSEvent.ModifierFlags {
    private static let recordedEventStateMask: UInt = 0x100

    // The flags a real key event carries: the modifiers themselves, the
    // device-dependent bit for each side-specific key, and the recorded-event bit.
    static func recorded(_ flags: NSEvent.ModifierFlags) -> NSEvent.ModifierFlags {
        let deviceMasks = KeyboardModifierKey.all
            .filter { $0.location == .left && flags.contains($0.kind.flag) }
            .map(\.deviceMask)
        return flags.addingRawMasks([Self.recordedEventStateMask] + deviceMasks)
    }
}
