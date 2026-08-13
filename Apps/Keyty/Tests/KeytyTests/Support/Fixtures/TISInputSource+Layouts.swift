//
//  TISInputSource+Layouts.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import XCTest

extension TISInputSource {
    static func usEnglish(file: StaticString = #filePath, line: UInt = #line) throws -> TISInputSource {
        try self.layout(id: "com.apple.keylayout.US", file: file, line: line)
    }

    // The German layout, whose ß key exercises legends that expand when uppercased.
    static func german(file: StaticString = #filePath, line: UInt = #line) throws -> TISInputSource {
        try self.layout(id: "com.apple.keylayout.German", file: file, line: line)
    }

    private static func layout(id: String,
                               file: StaticString = #filePath,
                               line: UInt = #line) throws -> TISInputSource {
        let properties: [String: Any] = [
            kTISPropertyInputSourceID as String: id,
            kTISPropertyInputSourceType as String: kTISTypeKeyboardLayout as String
        ]
        let inputSources = try XCTUnwrap(
            TISCreateInputSourceList(properties as CFDictionary, true)?
                .takeRetainedValue() as? [TISInputSource],
            "Expected the \(id) keyboard layout to be available",
            file: file,
            line: line
        )
        return try XCTUnwrap(
            inputSources.first,
            "Expected the \(id) keyboard layout to be available",
            file: file,
            line: line
        )
    }
}
