//
//  EventTap+Output.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension EventTap {
    /// Everything an installed tap reports to its owner.
    ///
    /// Captured input and lifecycle changes share one channel so that a consumer
    /// handles them in a single ordered switch rather than across several callbacks.
    enum Output {
        case keystroke(StandardKeyEvent)
        case mouse(MouseEvent)
        case mediaKey(MediaKeyEvent)
        case modifierFlags(NSEvent.ModifierFlags)
        case stateChanged(EventTap.State)
    }
}
