//
//  EventTapping.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

/// Abstraction to mock `EventTap`
protocol EventTapping: AnyObject {
    /// Receives every captured event.
    var onEvent: ((EventTap.Event) -> Void)? { get set }

    /// Receives every lifecycle change.
    var onStateChanged: ((EventTap.State) -> Void)? { get set }

    func install() throws(EventTap.Error)
    func remove()
    func reenable()
}

extension EventTap: EventTapping {}
