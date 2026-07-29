//
//  TimeIntervalNanosecondsTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class TimeIntervalNanosecondsTests: XCTestCase {
    func test_nanoseconds_convertsSecondsToNanoseconds() {
        XCTAssertEqual(TimeInterval(1).nanoseconds, 1_000_000_000)
    }

    func test_nanoseconds_convertsFractionalSecondsToNanoseconds() {
        XCTAssertEqual(TimeInterval(0.82).nanoseconds, 820_000_000)
    }

    func test_nanoseconds_roundsToNearestNanosecond() {
        XCTAssertEqual(TimeInterval(0.000_000_001_5).nanoseconds, 2)
    }
}
