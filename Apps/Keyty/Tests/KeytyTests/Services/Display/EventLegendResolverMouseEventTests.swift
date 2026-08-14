//
//  EventLegendResolverMouseEventTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import XCTest
@testable import Keyty

final class EventLegendResolverMouseEventTests: XCTestCase {
    var resolver: EventLegendResolver!

    func legend(_ event: MouseEvent) -> EventLegend {
        self.resolver.legend(for: InputEvent.mouse(event))
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.resolver = EventLegendResolver(keyboardLayout: try TISInputSource.usEnglish())
    }
}

// MARK: - Buttons

extension EventLegendResolverMouseEventTests {
    func testButtonsResolveToTheirIconAndName() {
        let cases: [(NSEvent.EventType, Int, MouseEvent.Kind, String)] = [
            (.leftMouseDown, 0, .leftButton, "LMB"),
            (.rightMouseDown, 1, .rightButton, "RMB"),
            (.otherMouseDown, 2, .middleButton, "MMB"),
            (.otherMouseDown, 3, .otherButton(4), "MB4"),
            (.otherMouseDown, 4, .otherButton(5), "MB5")
        ]

        for (type, buttonNumber, kind, text) in cases {
            let legend = self.legend(.stub(type: type, buttonNumber: buttonNumber))

            XCTAssertEqual(legend.kind, .mouseIcon(kind), "for \(kind)")
            XCTAssertEqual(legend.text, text, "for \(kind)")
            XCTAssertTrue(legend.modifiers.isEmpty, "for \(kind)")
        }
    }

    func testScrollDirectionsResolveToTheirOwnIcons() {
        let cases: [(Int32, Int32, MouseEvent.Kind, String)] = [
            (0, 1, .wheelUp, "MWHEELUP"),
            (0, -1, .wheelDown, "MWHEELDOWN"),
            (1, 0, .wheelRight, "MWHEELRIGHT"),
            (-1, 0, .wheelLeft, "MWHEELLEFT")
        ]

        for (deltaX, deltaY, kind, text) in cases {
            let legend = self.legend(.scrollStub(deltaX: deltaX, deltaY: deltaY))

            XCTAssertEqual(legend.kind, .mouseIcon(kind), "for \(kind)")
            XCTAssertEqual(legend.text, text, "for \(kind)")
        }
    }
}

// MARK: - Modifiers

extension EventLegendResolverMouseEventTests {
    func testHeldModifiersAccompanyTheButton() {
        let commandClick = self.legend(.stub(type: .leftMouseDown, modifiers: .command))
        XCTAssertEqual(commandClick.modifiers, [.command])
        XCTAssertEqual(commandClick.text, "LMB")

        let optionShiftClick = self.legend(.stub(
            type: .rightMouseDown,
            buttonNumber: 1,
            modifiers: [.option, .shift]
        ))
        XCTAssertEqual(optionShiftClick.modifiers, [.option, .shift])
        XCTAssertEqual(optionShiftClick.text, "RMB")
    }
}
