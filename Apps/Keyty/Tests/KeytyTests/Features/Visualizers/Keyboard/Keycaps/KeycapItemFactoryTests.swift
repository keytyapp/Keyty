//
//  KeycapItemFactoryTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

final class KeycapItemFactoryTests: XCTestCase {
    func testKeyboardModifierKeysDecodeLocationSpecificFlags() {
        let flags = NSEvent.ModifierFlags.command.addingRawMasks(
            UInt(NX_DEVICELCMDKEYMASK),
            UInt(NX_DEVICERCMDKEYMASK)
        )

        XCTAssertEqual(KeyboardModifierKey.keys(in: flags), [.leftCommand, .rightCommand])
    }

    func testModifierItemsIncludeFunctionKey() {
        let items = KeycapItemFactory.modifierItems(
            currentFlags: [.function],
            releasedFlags: [],
            palette: Self.makePalette()
        )

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.identity, .keyCode(KeyboardKeyCode.function.rawValue))
        XCTAssertEqual(items.first?.label, "fn")
        XCTAssertEqual(items.first?.sfSymbolName, "globe")
        XCTAssertEqual(items.first?.isPressed, true)
    }

    func testModifierItemsUseLocationSpecificModifierKeys() {
        let items = KeycapItemFactory.modifierItems(
            currentFlags: NSEvent.ModifierFlags.command.addingRawMasks(
                UInt(NX_DEVICELCMDKEYMASK),
                UInt(NX_DEVICERCMDKEYMASK)
            ),
            releasedFlags: [],
            palette: Self.makePalette()
        )

        XCTAssertEqual(items.map(\.identity), [
            .modifier(.leftCommand),
            .modifier(.rightCommand),
        ])
        XCTAssertEqual(items.map(\.layoutHints.alignment), [.right, .left])
    }

    func testModifierItemsFollowCanonicalDisplayOrder() {
        let items = KeycapItemFactory.modifierItems(
            currentFlags: [.command, .option, .shift],
            releasedFlags: [],
            palette: Self.makePalette()
        )

        XCTAssertEqual(items.map(\.identity), [
            .modifier(.leftOption),
            .modifier(.leftShift),
            .modifier(.leftCommand),
        ])
    }

    func testModifierItemsUseInwardAlignmentForNonCommandModifierKeys() {
        let items = KeycapItemFactory.modifierItems(
            currentFlags: NSEvent.ModifierFlags.shift.addingRawMasks(
                UInt(NX_DEVICELSHIFTKEYMASK),
                UInt(NX_DEVICERSHIFTKEYMASK)
            ),
            releasedFlags: [],
            palette: Self.makePalette()
        )

        XCTAssertEqual(items.map(\.identity), [
            .modifier(.leftShift),
            .modifier(.rightShift),
        ])
        XCTAssertEqual(items.map(\.layoutHints.alignment), [.right, .left])
    }

    func testModifierItemsFallbackToLeftKeyForAggregateFlags() {
        let items = KeycapItemFactory.modifierItems(
            currentFlags: [.command],
            releasedFlags: [],
            palette: Self.makePalette()
        )

        XCTAssertEqual(items.map(\.identity), [.modifier(.leftCommand)])
    }

    func testReturnAndKeypadEnterRenderDifferentLegends() {
        let palette = Self.makePalette()

        let returnItems = KeycapItemFactory.keycapItems(
            keyCode: KeyboardKeyCode.returnKey.rawValue,
            displayString: KeyboardSpecialKey.returnKey.displayText,
            modifierFlags: [],
            isPressed: true,
            palette: palette
        )
        let enterItems = KeycapItemFactory.keycapItems(
            keyCode: KeyboardKeyCode.keypadEnter.rawValue,
            displayString: KeyboardSpecialKey.keypadEnter.displayText,
            modifierFlags: [],
            isPressed: true,
            palette: palette
        )

        XCTAssertEqual(returnItems.map(\.identity), [.keyCode(KeyboardKeyCode.returnKey.rawValue)])
        XCTAssertEqual(returnItems.first?.symbol, UnicodeToken.returnKey.string)
        XCTAssertEqual(returnItems.first?.label, "return")
        XCTAssertEqual(enterItems.map(\.identity), [.keyCode(KeyboardKeyCode.keypadEnter.rawValue)])
        XCTAssertEqual(enterItems.first?.symbol, UnicodeToken.keypadEnter.string)
        XCTAssertEqual(enterItems.first?.label, "enter")
    }

    func testDeleteAndForwardDeleteRenderDifferentLegends() {
        let palette = Self.makePalette()

        let deleteItems = KeycapItemFactory.keycapItems(
            keyCode: KeyboardKeyCode.delete.rawValue,
            displayString: KeyboardSpecialKey.delete.displayText,
            modifierFlags: [],
            isPressed: true,
            palette: palette
        )
        let forwardDeleteItems = KeycapItemFactory.keycapItems(
            keyCode: KeyboardKeyCode.forwardDelete.rawValue,
            displayString: KeyboardSpecialKey.forwardDelete.displayText,
            modifierFlags: [],
            isPressed: true,
            palette: palette
        )

        XCTAssertEqual(deleteItems.map(\.identity), [.keyCode(KeyboardKeyCode.delete.rawValue)])
        XCTAssertEqual(deleteItems.first?.symbol, UnicodeToken.delete.string)
        XCTAssertEqual(deleteItems.first?.label, "delete")
        XCTAssertEqual(forwardDeleteItems.map(\.identity), [.keyCode(KeyboardKeyCode.forwardDelete.rawValue)])
        XCTAssertEqual(forwardDeleteItems.first?.symbol, UnicodeToken.forwardDelete.string)
        XCTAssertEqual(forwardDeleteItems.first?.label, "delete")
    }

    func testMouseItemUsesPressedStateFromMouseEventType() {
        let palette = Self.makePalette()

        let downItem = KeycapItemFactory.mouseItem(
            for: TestMouseEvents.make(type: .leftMouseDown),
            palette: palette
        )
        let upItem = KeycapItemFactory.mouseItem(
            for: TestMouseEvents.make(type: .leftMouseUp),
            palette: palette
        )

        XCTAssertTrue(downItem.isPressed)
        XCTAssertFalse(upItem.isPressed)
    }

    func testMediaKeyItemUsesPressedStateFromMediaKeyEvent() {
        let palette = Self.makePalette()

        let downItem = KeycapItemFactory.mediaKeyItem(
            for: Self.makeMediaKeyEvent(keyCode: 16, keyState: 0x0A),
            palette: palette
        )
        let upItem = KeycapItemFactory.mediaKeyItem(
            for: Self.makeMediaKeyEvent(keyCode: 16, keyState: 0x0B),
            palette: palette
        )

        XCTAssertEqual(downItem.identity, .media(.play))
        XCTAssertTrue(downItem.isPressed)
        XCTAssertFalse(upItem.isPressed)
    }

    private static func makePalette(
        style: KeycapStyle = .minimal,
        theme: KeyboardVisualizerTheme = .citrus
    ) -> KeycapThemePalette {
        KeycapThemePalette(
            style: style,
            themes: [
                .regular:  theme,
                .modifier: theme,
                .special:  theme,
                .media:    theme,
                .mouse:    theme,
            ],
            groupBackgroundTheme: theme,
            legendColorOverride: nil
        )
    }

    private static func makeMediaKeyEvent(keyCode: Int, keyState: Int) -> MediaKeyEvent {
        let data1 = (keyCode << 16) | (keyState << 8)
        let event = NSEvent.otherEvent(
            with: .systemDefined,
            location: .zero,
            modifierFlags: [],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            subtype: Int16(NX_SUBTYPE_AUX_CONTROL_BUTTONS),
            data1: data1,
            data2: 0
        )!

        return MediaKeyEvent(nsEvent: event)
    }

}
