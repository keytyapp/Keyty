//
//  String+FunctionKey.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension String {
    // The character AppKit reports for a function key such as `NSHelpFunctionKey`.
    static func functionKey(_ key: Int) -> String {
        String(UnicodeScalar(key)!)
    }
}
