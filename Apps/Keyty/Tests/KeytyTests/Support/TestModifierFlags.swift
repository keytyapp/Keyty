//
//  TestModifierFlags.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import IOKit.hidsystem
@testable import Keyty

enum TestModifierFlags {
    private static let recordedEventStateMask: UInt = 0x100

    static let none = Self.recorded([])
    static let control = Self.recorded(.control, deviceMasks: UInt(NX_DEVICELCTLKEYMASK))
    static let shift = Self.recorded(.shift, deviceMasks: UInt(NX_DEVICELSHIFTKEYMASK))
    static let controlShift = Self.recorded(
        [.control, .shift],
        deviceMasks: UInt(NX_DEVICELCTLKEYMASK), UInt(NX_DEVICELSHIFTKEYMASK)
    )
    static let command = Self.recorded(.command, deviceMasks: UInt(NX_DEVICELCMDKEYMASK))
    static let commandShift = Self.recorded(
        [.command, .shift],
        deviceMasks: UInt(NX_DEVICELCMDKEYMASK), UInt(NX_DEVICELSHIFTKEYMASK)
    )
    static let commandOption = Self.recorded(
        [.command, .option],
        deviceMasks: UInt(NX_DEVICELCMDKEYMASK), UInt(NX_DEVICELALTKEYMASK)
    )
    static let commandOptionShift = Self.recorded(
        [.command, .option, .shift],
        deviceMasks: UInt(NX_DEVICELCMDKEYMASK), UInt(NX_DEVICELALTKEYMASK), UInt(NX_DEVICELSHIFTKEYMASK)
    )
    static let controlCommandShift = Self.recorded(
        [.control, .command, .shift],
        deviceMasks: UInt(NX_DEVICELCTLKEYMASK), UInt(NX_DEVICELCMDKEYMASK), UInt(NX_DEVICELSHIFTKEYMASK)
    )
    static let controlOption = Self.recorded(
        [.control, .option],
        deviceMasks: UInt(NX_DEVICELCTLKEYMASK), UInt(NX_DEVICELALTKEYMASK)
    )
    static let controlOptionShift = Self.recorded(
        [.control, .option, .shift],
        deviceMasks: UInt(NX_DEVICELCTLKEYMASK), UInt(NX_DEVICELALTKEYMASK), UInt(NX_DEVICELSHIFTKEYMASK)
    )
    static let option = Self.recorded(.option, deviceMasks: UInt(NX_DEVICELALTKEYMASK))
    static let optionShift = Self.recorded(
        [.option, .shift],
        deviceMasks: UInt(NX_DEVICELALTKEYMASK), UInt(NX_DEVICELSHIFTKEYMASK)
    )
    static let function = Self.recorded(.function)
    static let functionOptionShiftNumericPad = Self.recorded(
        [.function, .option, .shift, .numericPad],
        deviceMasks: UInt(NX_DEVICELALTKEYMASK), UInt(NX_DEVICELSHIFTKEYMASK)
    )

    private static func recorded(_ flags: NSEvent.ModifierFlags,
                                 deviceMasks: UInt...) -> NSEvent.ModifierFlags {
        flags.addingRawMasks([recordedEventStateMask] + deviceMasks)
    }
}
