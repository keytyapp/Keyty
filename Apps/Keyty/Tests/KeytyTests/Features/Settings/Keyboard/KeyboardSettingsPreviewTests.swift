//
//  KeyboardSettingsPreviewTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

final class KeyboardSettingsPreviewTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var settings: KeyboardVisualizerSettings!

    override func setUp() {
        super.setUp()
        store = InMemoryKeyValueStore()
        settings = KeyboardVisualizerSettings(store: store)
        settings.registerDefaults()
    }

    override func tearDown() {
        settings = nil
        store = nil
        super.tearDown()
    }

    func testPreviewGroupsIncludeAllEnabledCategories() {
        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)

        XCTAssertEqual(groups.map(\.category), [
            .plainKey, .plainKey,
            .keyboardChord, .keyboardChord,
            .specialKey, .specialKey,
            .mediaKey, .mediaKey,
            .mouseEvent, .mouseEvent,
        ])
    }

    func testPreviewGroupsOmitPlainKeyCategoryWhenShowingModifiedKeystrokesOnly() {
        settings.onlyShowModifiedKeystrokes = true

        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)

        XCTAssertEqual(groups.map(\.category), [
            .keyboardChord, .keyboardChord,
            .specialKey, .specialKey,
            .mediaKey, .mediaKey,
            .mouseEvent, .mouseEvent,
        ])
    }

    func testPreviewGroupsOmitSpecialKeyCategoryWhenDisabled() {
        settings.showSpecialKeys = false

        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)

        XCTAssertEqual(groups.map(\.category), [
            .plainKey, .plainKey,
            .keyboardChord, .keyboardChord,
            .mediaKey, .mediaKey,
            .mouseEvent, .mouseEvent,
        ])
    }

    func testPreviewGroupsOmitMediaCategoryWhenDisabled() {
        settings.showMediaKeyButtons = false

        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)

        XCTAssertEqual(groups.map(\.category), [
            .plainKey, .plainKey,
            .keyboardChord, .keyboardChord,
            .specialKey, .specialKey,
            .mouseEvent, .mouseEvent,
        ])
    }

    func testPreviewGroupsOmitMouseCategoryWhenDisabled() {
        settings.showMouseEvents = false

        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)

        XCTAssertEqual(groups.map(\.category), [
            .plainKey, .plainKey,
            .keyboardChord, .keyboardChord,
            .specialKey, .specialKey,
            .mediaKey, .mediaKey,
        ])
    }

    func testMediaPreviewGroupsRenderPressedMediaKeys() {
        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)
        let mediaGroups = groups.filter { $0.category == .mediaKey }

        XCTAssertEqual(mediaGroups.count, 2)
        XCTAssertTrue(mediaGroups.allSatisfy { group in
            group.items.allSatisfy(\.isPressed)
        })
    }

    func testPreviewGroupsFallBackToKeyboardCategoryOnly() {
        settings.onlyShowModifiedKeystrokes = true
        settings.showSpecialKeys = false
        settings.showMediaKeyButtons = false
        settings.showMouseEvents = false

        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)

        XCTAssertEqual(groups.map(\.category), [.keyboardChord, .keyboardChord])
    }

    func testPreviewGroupsProduceStableDistinctIDsPerVariant() {
        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)

        XCTAssertEqual(Set(groups.map(\.id)).count, groups.count)
    }

    func testPreferredPreviewSizeMatchesLargestEnabledGroup() {
        let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)

        let size = KeyboardSettingsPane.PreviewGroup.preferredPreviewSize(for: groups, settings: settings)
        let individualSizes = groups.map {
            KeyboardSettingsPane.PreviewGroup(settings: settings, items: $0.items).preferredSize
        }

        XCTAssertEqual(size.width, individualSizes.map(\.width).max() ?? 0, accuracy: 0.001)
        XCTAssertEqual(size.height, individualSizes.map(\.height).max() ?? 0, accuracy: 0.001)
    }

    func testPreferredPreviewSizeRecalculatesWhenCategoriesChange() {
        let allGroups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)
        let allSize = KeyboardSettingsPane.PreviewGroup.preferredPreviewSize(for: allGroups, settings: settings)

        settings.showMouseEvents = false
        let reducedGroups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: settings)
        let reducedSize = KeyboardSettingsPane.PreviewGroup.preferredPreviewSize(for: reducedGroups, settings: settings)

        XCTAssertLessThanOrEqual(reducedSize.width, allSize.width + 0.001)
        XCTAssertLessThanOrEqual(reducedSize.height, allSize.height + 0.001)
    }

    func testNextIndexWrapsAroundAcrossEnabledGroups() {
        XCTAssertEqual(KeyboardSettingsPane.PreviewGroup.nextIndex(after: 0, groupCount: 10), 1)
        XCTAssertEqual(KeyboardSettingsPane.PreviewGroup.nextIndex(after: 9, groupCount: 10), 0)
    }

    func testClampedIndexAdjustsWhenEnabledGroupCountShrinks() {
        XCTAssertEqual(KeyboardSettingsPane.PreviewGroup.clampedIndex(2, groupCount: 2), 1)
        XCTAssertEqual(KeyboardSettingsPane.PreviewGroup.clampedIndex(5, groupCount: 1), 0)
        XCTAssertEqual(KeyboardSettingsPane.PreviewGroup.nextIndex(after: 0, groupCount: 1), 0)
    }
}
