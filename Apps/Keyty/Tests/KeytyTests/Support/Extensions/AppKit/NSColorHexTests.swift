//
//  NSColorHexTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class NSColorHexTests: XCTestCase {

    // MARK: - NSColor → hex string

    func testHexStringWhite() {
        XCTAssertEqual(NSColor.white.hexString, "#FFFFFFFF")
    }

    func testHexStringBlack() {
        XCTAssertEqual(NSColor.black.hexString, "#000000FF")
    }

    func testHexStringRed() {
        let color = NSColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
        XCTAssertEqual(color.hexString, "#FF0000FF")
    }

    func testHexStringSemiTransparent() {
        let color = NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.5)
        XCTAssertEqual(color.hexString, "#00000080")
    }

    func testHexStringFullyTransparent() {
        let color = NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0)
        XCTAssertEqual(color.hexString, "#FFFFFF00")
    }

    // MARK: - hex string → NSColor

    func testInitEightCharHex() {
        let color = NSColor(hexString: "#FF0000FF")
        XCTAssertNotNil(color)
        XCTAssertEqual(color?.redComponent ?? 0, 1.0, accuracy: 0.01)
        XCTAssertEqual(color?.greenComponent ?? 1, 0.0, accuracy: 0.01)
        XCTAssertEqual(color?.blueComponent ?? 1, 0.0, accuracy: 0.01)
        XCTAssertEqual(color?.alphaComponent ?? 0, 1.0, accuracy: 0.01)
    }

    func testInitSixCharHexDefaultsAlphaToOne() {
        let color = NSColor(hexString: "#FF0000")
        XCTAssertNotNil(color)
        XCTAssertEqual(color?.alphaComponent ?? 0, 1.0, accuracy: 0.01)
    }

    func testInitWithoutHashPrefix() {
        let color = NSColor(hexString: "FF0000FF")
        XCTAssertNotNil(color)
        XCTAssertEqual(color?.redComponent ?? 0, 1.0, accuracy: 0.01)
    }

    func testInitLowercaseHex() {
        let color = NSColor(hexString: "#ff0000ff")
        XCTAssertNotNil(color)
        XCTAssertEqual(color?.redComponent ?? 0, 1.0, accuracy: 0.01)
    }

    func testInitWithLeadingAndTrailingWhitespace() {
        let color = NSColor(hexString: "  #FF0000FF  ")
        XCTAssertNotNil(color)
    }

    func testInitInvalidLengthReturnsNil() {
        XCTAssertNil(NSColor(hexString: "#FFF"))
        XCTAssertNil(NSColor(hexString: "#FFFFF"))
        XCTAssertNil(NSColor(hexString: "#FFFFFFFFF"))
    }

    func testInitNonHexCharactersReturnsNil() {
        XCTAssertNil(NSColor(hexString: "#GGHHIIJJ"))
    }

    func testInitEmptyStringReturnsNil() {
        XCTAssertNil(NSColor(hexString: ""))
    }

    // MARK: - Round-trip

    func testRoundTripPreservesColor() {
        let original = NSColor(srgbRed: 0.2, green: 0.5, blue: 0.8, alpha: 0.75)
        let recovered = NSColor(hexString: original.hexString)
        XCTAssertNotNil(recovered)
        XCTAssertEqual(original.redComponent,   recovered!.redComponent,   accuracy: 0.01)
        XCTAssertEqual(original.greenComponent, recovered!.greenComponent, accuracy: 0.01)
        XCTAssertEqual(original.blueComponent,  recovered!.blueComponent,  accuracy: 0.01)
        XCTAssertEqual(original.alphaComponent, recovered!.alphaComponent, accuracy: 0.01)
    }

    func testRoundTripBlack() {
        let original = NSColor.black
        XCTAssertEqual(NSColor(hexString: original.hexString)?.hexString, original.hexString)
    }

    func testRoundTripWhite() {
        let original = NSColor.white
        XCTAssertEqual(NSColor(hexString: original.hexString)?.hexString, original.hexString)
    }
}
