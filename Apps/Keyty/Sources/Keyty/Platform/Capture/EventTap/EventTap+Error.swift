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
        case keyTapCreationFailed
        case mouseAndFlagsTapCreationFailed

        var errorDescription: String? {
            switch self {
            case .keyTapCreationFailed:
                return L10n.EventTap.keyTapCreationFailed
            case .mouseAndFlagsTapCreationFailed:
                return L10n.EventTap.mouseAndFlagsTapCreationFailed
            }
        }
    }
}
