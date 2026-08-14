//
//  EventTap+Error.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa

extension EventTap {
    enum Error: LocalizedError, Equatable {
        /// The tap could not be created.
        case creationFailed

        var errorDescription: String? {
            L10n.EventTap.creationFailed
        }
    }
}
