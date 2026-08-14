//
//  KeyboardVisualizerGroupViewSnapshotTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SnapshotTesting
import XCTest
@testable import Keyty

@MainActor
final class KeyboardVisualizerGroupViewSnapshotTests: XCTestCase {
    func testRendersAppleBlackKeycap() {
        self.assertAppleBlackSnapshot(
            items: self.keycapItems(keyCode: KeyboardKeyCode.a.rawValue, legend: EventLegend(text: "A")),
            named: "apple-black-keycap"
        )
    }

    func testRendersAppleBlackTabKeycap() {
        self.assertAppleBlackSnapshot(
            items: self.keycapItems(keyCode: KeyboardKeyCode.tab.rawValue, legend: EventLegend(text: KeyboardGlyphCatalog.tab, label: KeyboardSpecialKey.tab.label)),
            named: "apple-black-tab-keycap"
        )
    }

    func testRendersAppleBlackCommandShiftKKeycaps() {
        self.assertAppleBlackSnapshot(
            items: self.commandShiftKItems(),
            named: "apple-black-command-shift-k-keycaps"
        )
    }

    func testRendersAppleBlackEscapeKeycap() {
        self.assertAppleBlackSnapshot(
            items: self.keycapItems(
                keyCode: KeyboardKeyCode.escape.rawValue,
                legend: EventLegend(text: KeyboardGlyphCatalog.symbol(for: .escape), label: KeyboardSpecialKey.escape.label)
            ),
            named: "apple-black-escape-keycap"
        )
    }
}

private extension KeyboardVisualizerGroupViewSnapshotTests {
    static var commandShiftFlags: NSEvent.ModifierFlags {
        .recorded([.command, .shift])
    }

    func keycapItems(
        keyCode: UInt16,
        legend: EventLegend,
        modifierFlags: NSEvent.ModifierFlags = []
    ) -> [KeycapItem] {
        KeycapItemFactory.keycapItems(
            keyCode: keyCode,
            legend: legend,
            modifierFlags: modifierFlags,
            isPressed: false,
            palette: self.appleBlackSettings.palette
        )
    }

    func commandShiftKItems() -> [KeycapItem] {
        let settings = self.appleBlackSettings
        return KeycapItemFactory.modifierItems(
            currentFlags: [],
            releasedFlags: Self.commandShiftFlags,
            palette: settings.palette
        )
        + KeycapItemFactory.keycapItems(
            keyCode: KeyboardKeyCode.k.rawValue,
            legend: EventLegend(text: "K"),
            modifierFlags: [],
            isPressed: false,
            palette: settings.palette
        )
    }

    func assertAppleBlackSnapshot(
        items: [KeycapItem],
        named name: String,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let settings = self.appleBlackSettings
        let view = KeyboardVisualizerGroupView(items: items, settings: settings)
        view.frame = NSRect(origin: .zero, size: view.preferredSize)

        assertSnapshot(
            of: self.snapshotImage(for: view),
            as: .image(precision: 0.99, perceptualPrecision: 0.93),
            named: name,
            file: file,
            testName: testName,
            line: line
        )
    }

    var appleBlackSettings: KeyboardVisualizerSettings {
        let settings = KeyboardVisualizerSettings(store: InMemoryKeyValueStore())
        settings.style = .apple
        settings.theme = .black
        settings.scale = 1.0
        return settings
    }

    func snapshotImage(for view: NSView) -> NSImage {
        let scale = 2.0
        let size = view.bounds.size
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: max(1, Int((size.width * scale).rounded())),
            pixelsHigh: max(1, Int((size.height * scale).rounded())),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!
        bitmap.size = size
        view.cacheDisplay(in: view.bounds, to: bitmap)

        let image = NSImage(size: size)
        image.addRepresentation(bitmap)
        return image
    }

}
