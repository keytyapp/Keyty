//
//  EventTap+InstalledTap.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa

extension EventTap {
    /// A mach port and its run loop source, kept together so they are torn down together.
    struct InstalledTap {
        let machPort: CFMachPort
        let runLoopSource: CFRunLoopSource
    }
}
