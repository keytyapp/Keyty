//
//  TimeInterval+Nanoseconds.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

extension TimeInterval {
    var nanoseconds: UInt64 {
        UInt64((self * 1_000_000_000).rounded())
    }
}
