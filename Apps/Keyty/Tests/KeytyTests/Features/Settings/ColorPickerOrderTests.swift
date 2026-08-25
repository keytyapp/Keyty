//
//  ColorPickerOrderTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI
import XCTest
@testable import Keyty

final class ColorPickerOrderTests: XCTestCase {
    func testKeyboardThemePickerOrdersColorsBySpectrum() {
        XCTAssertEqual(
            KeyboardVisualizerTheme.pickerSections.last,
            [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        )
    }

    func testM0116ThemePickerOnlyShowsWhite() {
        XCTAssertEqual(
            KeyboardVisualizerTheme.pickerSections(for: KeycapStyle.m0116.allowedThemes),
            [[.white]]
        )
    }

    func testKeyboardLegendColorPickerOrdersColorsBySpectrum() {
        XCTAssertEqual(
            Array(KeyboardSettingsPaneViewModel.ColorPreset.presets.suffix(Self.colorOrder.count)).map(\.color.hexString),
            Self.colorOrder.map(\.hexString)
        )
    }

    func testMouseRingColorPickerOrdersColorsBySpectrum() {
        XCTAssertEqual(
            Array(MouseSettingsPaneViewModel.ColorPreset.ringColorPresets.dropFirst().prefix(Self.colorOrder.count)).map(\.color.hexString),
            Self.colorOrder.map(\.hexString)
        )
    }

    func testMouseIconBackgroundColorPickerOrdersColorsBySpectrum() {
        XCTAssertEqual(
            MouseSettingsPaneViewModel.ColorPreset.iconBackgroundColorSections.last?.map(\.color.hexString),
            Self.translucentColorOrder.map(\.hexString)
        )
    }

    func testMouseIconTintColorPickerOrdersColorsBySpectrum() {
        XCTAssertEqual(
            MouseSettingsPaneViewModel.ColorPreset.iconTintColorSections.last?.map(\.color.hexString),
            Self.colorOrder.map(\.hexString)
        )
    }

    private static let colorOrder: [NSColor] = [
        Color.Theme.Palette.red,
        Color.Theme.Palette.orange,
        Color.Theme.Palette.yellow,
        Color.Theme.Palette.green,
        Color.Theme.Palette.blue,
        Color.Theme.Palette.purple,
        Color.Theme.Palette.pink,
    ]

    private static let translucentColorOrder: [NSColor] = [
        Color.Theme.Palette.red60,
        Color.Theme.Palette.orange60,
        Color.Theme.Palette.yellow60,
        Color.Theme.Palette.green60,
        Color.Theme.Palette.blue60,
        Color.Theme.Palette.purple60,
        Color.Theme.Palette.pink60,
    ]
}
