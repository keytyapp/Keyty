//
//  EventTapping.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

/// The capture surface `CaptureController` drives. Installing a real tap requires the
/// Accessibility grant, so the state machine is only testable behind this abstraction.
protocol EventTapping: AnyObject {
    /// Receives every captured event and lifecycle change.
    var onOutput: ((EventTap.Output) -> Void)? { get set }

    func install() throws(EventTap.Error)
    func remove()
}

extension EventTap: EventTapping {}
