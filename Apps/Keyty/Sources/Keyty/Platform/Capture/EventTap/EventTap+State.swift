//
//  EventTap+State.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

extension EventTap {
    enum State: Equatable {
        /// No taps are installed, either before the first `install()` or after `remove()`.
        case idle

        /// Both taps are installed and the system is delivering events.
        case installed

        /// Still installed, but the system turned a tap off; it is re-enabled automatically.
        case temporarilyDisabled(EventTap.DisableReason)

        /// A tap could not be created, so nothing is installed.
        case failed(EventTap.Error)
    }
}
