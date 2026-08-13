//
//  TestKeyboardLayouts.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import XCTest

enum TestKeyboardLayouts {
    static func requireUSEnglish(file: StaticString = #filePath,
                                 line: UInt = #line) throws -> TISInputSource {
        try self.require(id: "com.apple.keylayout.US", file: file, line: line)
    }

    /// The German layout, whose ß key exercises legends that expand when uppercased.
    static func requireGerman(file: StaticString = #filePath,
                              line: UInt = #line) throws -> TISInputSource {
        try self.require(id: "com.apple.keylayout.German", file: file, line: line)
    }

    private static func require(id: String,
                                file: StaticString = #filePath,
                                line: UInt = #line) throws -> TISInputSource {
        let properties: [String: Any] = [
            kTISPropertyInputSourceID as String: id,
            kTISPropertyInputSourceType as String: kTISTypeKeyboardLayout as String
        ]
        let inputSources = try XCTUnwrap(
            TISCreateInputSourceList(properties as CFDictionary, true)?
                .takeRetainedValue() as? [TISInputSource],
            "Expected the US English keyboard layout to be available",
            file: file,
            line: line
        )
        return try XCTUnwrap(
            inputSources.first,
            "Expected the US English keyboard layout to be available",
            file: file,
            line: line
        )
    }
}
