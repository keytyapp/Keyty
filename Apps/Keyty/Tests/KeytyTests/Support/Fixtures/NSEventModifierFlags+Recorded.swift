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
        let deviceMasks = flags.elements().compactMap(Self.deviceMask(for:))
        return flags.addingRawMasks([Self.recordedEventStateMask] + deviceMasks)
    }

    private static func deviceMask(for flag: NSEvent.ModifierFlags) -> UInt? {
        switch flag {
        case .control: return UInt(NX_DEVICELCTLKEYMASK)
        case .shift:   return UInt(NX_DEVICELSHIFTKEYMASK)
        case .command: return UInt(NX_DEVICELCMDKEYMASK)
        case .option:  return UInt(NX_DEVICELALTKEYMASK)
        default:       return nil
        }
    }

    private func elements() -> [NSEvent.ModifierFlags] {
        [.control, .shift, .command, .option, .function, .numericPad].filter(self.contains)
    }
}
