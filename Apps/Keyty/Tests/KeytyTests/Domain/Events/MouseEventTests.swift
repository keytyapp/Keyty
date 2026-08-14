//
//  MouseEventTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class MouseEventTests: XCTestCase {
    func testKindClassifiesButtonsAndScrollDirections() {
        XCTAssertEqual(MouseEvent.stub(type: .leftMouseDown, buttonNumber: 0).kind, .leftButton)
        XCTAssertEqual(MouseEvent.stub(type: .rightMouseDown, buttonNumber: 1).kind, .rightButton)
        XCTAssertEqual(MouseEvent.stub(type: .otherMouseDown, buttonNumber: 2).kind, .middleButton)
        XCTAssertEqual(MouseEvent.stub(type: .otherMouseDown, buttonNumber: 3).kind, .otherButton(4))
        XCTAssertEqual(MouseEvent.scrollStub(deltaX: 0, deltaY: 1).kind, .wheelUp)
        XCTAssertEqual(MouseEvent.scrollStub(deltaX: 0, deltaY: -1).kind, .wheelDown)
        XCTAssertEqual(MouseEvent.scrollStub(deltaX: -1, deltaY: 0).kind, .wheelLeft)
        XCTAssertEqual(MouseEvent.scrollStub(deltaX: 1, deltaY: 0).kind, .wheelRight)
    }

    func testKindTreatsZeroDeltaScrollEventAsGeneric() {
        XCTAssertEqual(MouseEvent.scrollStub(deltaX: 0, deltaY: 0).kind, .generic)
    }

    func testKindIsScrollRecognizesOnlyWheelCases() {
        XCTAssertFalse(MouseEvent.Kind.leftButton.isScroll)
        XCTAssertFalse(MouseEvent.Kind.otherButton(4).isScroll)
        XCTAssertTrue(MouseEvent.Kind.wheelUp.isScroll)
        XCTAssertTrue(MouseEvent.Kind.wheelDown.isScroll)
        XCTAssertTrue(MouseEvent.Kind.wheelLeft.isScroll)
        XCTAssertTrue(MouseEvent.Kind.wheelRight.isScroll)
    }

    func testKindOtherButtonNumberExtractsOnlyAuxiliaryButtonCases() {
        XCTAssertNil(MouseEvent.Kind.leftButton.otherButtonNumber)
        XCTAssertNil(MouseEvent.Kind.middleButton.otherButtonNumber)
        XCTAssertEqual(MouseEvent.Kind.otherButton(4).otherButtonNumber, 4)
    }

    func testScreenLocationUsesMainScreenForQuartzFlip() {
        let mainScreen = NSRect(x: 0, y: 0, width: 1440, height: 900)
        let upperScreen = NSRect(x: 0, y: 900, width: 1440, height: 900)

        let location = MouseEvent.screenLocation(
            from: CGPoint(x: 400, y: -100),
            screens: [mainScreen, upperScreen],
            mainScreenFrame: mainScreen
        )

        XCTAssertEqual(location.x, 400)
        XCTAssertEqual(location.y, 1000)
    }

    func testScreenLocationKeepsSecondaryDisplayOriginWhenDisplayExtendsAboveMain() {
        let mainScreen = NSRect(x: 0, y: 0, width: 1440, height: 900)
        let rightScreen = NSRect(x: 1440, y: 0, width: 1920, height: 1080)

        let location = MouseEvent.screenLocation(
            from: CGPoint(x: 1600, y: -80),
            screens: [mainScreen, rightScreen],
            mainScreenFrame: mainScreen
        )

        XCTAssertEqual(location.x, 1600)
        XCTAssertEqual(location.y, 980)
    }
}
