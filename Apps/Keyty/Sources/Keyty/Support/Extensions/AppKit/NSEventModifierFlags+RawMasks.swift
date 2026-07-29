//
//  NSEventModifierFlags+RawMasks.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension NSEvent.ModifierFlags {
    init(cgEventFlags: CGEventFlags) {
        self.init(rawValue: UInt(cgEventFlags.rawValue))
    }

    func addingRawMasks(_ masks: UInt...) -> Self {
        self.addingRawMasks(masks)
    }

    func addingRawMasks(_ masks: [UInt]) -> Self {
        Self(rawValue: masks.reduce(self.rawValue) { $0 | $1 })
    }
}
