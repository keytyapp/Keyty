//
//  EventTap+State.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

extension EventTap {
    enum State: Equatable {
        /// No tap is installed, either before the first `install()` or after `remove()`.
        case idle

        /// The tap is installed and the system is delivering events.
        case installed

        /// Installed, but the system turned the tap off. 
        case disabled(EventTap.DisableReason)

        /// The tap could not be created, so nothing is installed.
        case failed(EventTap.Error)
    }
}
