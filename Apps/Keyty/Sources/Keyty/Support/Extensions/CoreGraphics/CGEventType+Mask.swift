//
//  CGEventType+Mask.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa

public extension CGEventType {
    /// The single-bit event-tap mask matching this event type.
    var mask: CGEventMask {
        CGEventMask(1) << CGEventMask(self.rawValue)
    }
}

public extension Sequence where Element == CGEventType {
    /// The combined event-tap mask matching every event type in the sequence,
    /// in the form `CGEvent.tapCreate(eventsOfInterest:)` expects.
    var eventMask: CGEventMask {
        self.reduce(0) { $0 | $1.mask }
    }
}
