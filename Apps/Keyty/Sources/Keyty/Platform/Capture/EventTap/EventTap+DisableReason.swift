//
//  EventTap+DisableReason.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa

extension EventTap {
    enum DisableReason: Equatable {
        /// The system disabled the tap because the callback stopped responding quickly enough.
        case timeout

        /// The system disabled the tap after user input re-enabled secure or direct input handling.
        case userInput

        /// `nil` for any event type that is not a tap-disabled notification.
        init?(eventType: CGEventType) {
            switch eventType {
            case .tapDisabledByTimeout:
                self = .timeout
            case .tapDisabledByUserInput:
                self = .userInput
            default:
                return nil
            }
        }
    }
}
