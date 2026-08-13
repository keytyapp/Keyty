//
//  NSEventModifierFlagsDeviceMasks.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension NSEvent.ModifierFlags {
    init(_ flags: Self, deviceMasks masks: UInt...) {
        self.init(rawValue: masks.reduce(flags.rawValue) { $0 | $1 })
    }
}
