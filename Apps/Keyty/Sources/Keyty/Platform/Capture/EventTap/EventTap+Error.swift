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
        /// The system refused to create the tap's mach port, which is how a missing Accessibility grant surfaces.
        case portCreationFailed

        /// The mach port could not be attached to a run loop.
        case runLoopSourceCreationFailed

        var errorDescription: String? {
            L10n.EventTap.creationFailed
        }
    }
}
