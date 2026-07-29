//
//  TestKeyboardCharacters.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum TestKeyboardCharacters {
    static func functionKeyCharacter(_ key: Int) -> String {
        String(UnicodeScalar(key)!)
    }

    static let backTab = String(UnicodeScalar(NSBackTabCharacter)!)
}
