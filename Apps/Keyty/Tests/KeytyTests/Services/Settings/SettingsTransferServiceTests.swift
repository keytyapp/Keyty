//
//  SettingsTransferServiceTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

final class SettingsTransferServiceTests: XCTestCase {
    private var sourceStore: InMemoryKeyValueStore!
    private var sourceSettings: AppSettingsContainer!
    private var sourceService: SettingsTransferService!

    override func setUp() {
        super.setUp()
        self.sourceStore = InMemoryKeyValueStore()
        self.sourceSettings = AppSettingsContainer(store: self.sourceStore)
        self.sourceService = SettingsTransferService(settings: self.sourceSettings)
    }

    override func tearDown() {
        self.sourceService = nil
        self.sourceSettings = nil
        self.sourceStore = nil
        super.tearDown()
    }

    func testExportsAndImportsSettingsRoundTrip() throws {
        self.sourceSettings.appSettings.visibleAtLaunch = false
        self.sourceSettings.pointerRingSettings.alwaysVisible = true
        self.sourceSettings.pointerRingSettings.color = .systemOrange
        self.sourceSettings.pointerRipplesSettings.thickness = 11
        self.sourceSettings.pointerIconSettings.isEnabled = true
        self.sourceSettings.pointerIconSettings.sizeIndex = 2
        self.sourceSettings.keyboardVisualizerSettings.isEnabled = false
        self.sourceSettings.keyboardVisualizerSettings.scale = 1.6
        self.sourceSettings.keyboardVisualizerSettings.placementMode = .custom
        self.sourceSettings.keyboardVisualizerSettings.customPositionNormalizedX = 0.25
        self.sourceSettings.keyboardVisualizerSettings.customPositionNormalizedY = 0.75

        let data = try self.sourceService.exportData()

        let destinationStore = InMemoryKeyValueStore()
        let destinationSettings = AppSettingsContainer(store: destinationStore)
        let destinationService = SettingsTransferService(settings: destinationSettings)

        try destinationService.importData(data)

        XCTAssertFalse(destinationSettings.appSettings.visibleAtLaunch)
        XCTAssertTrue(destinationSettings.pointerRingSettings.alwaysVisible)
        XCTAssertEqual(destinationSettings.pointerRingSettings.color.hexString, NSColor.systemOrange.hexString)
        XCTAssertEqual(destinationSettings.pointerRipplesSettings.thickness, 11, accuracy: 0.0001)
        XCTAssertTrue(destinationSettings.pointerIconSettings.isEnabled)
        XCTAssertEqual(destinationSettings.pointerIconSettings.sizeIndex, 2)
        XCTAssertFalse(destinationSettings.keyboardVisualizerSettings.isEnabled)
        XCTAssertEqual(destinationSettings.keyboardVisualizerSettings.scale, 1.6, accuracy: 0.0001)
        XCTAssertEqual(destinationSettings.keyboardVisualizerSettings.placementMode, .custom)
        XCTAssertEqual(destinationSettings.keyboardVisualizerSettings.customPositionNormalizedX, 0.25, accuracy: 0.0001)
        XCTAssertEqual(destinationSettings.keyboardVisualizerSettings.customPositionNormalizedY, 0.75, accuracy: 0.0001)
    }

    func testImportResetsMissingKeysToDefaultsAndIgnoresUnknownKeys() throws {
        self.sourceSettings.pointerRingSettings.alwaysVisible = true

        let archive = try Self.makeArchive(values: [
            AppSettings.visibleAtLaunchKey: false,
            "unknown.setting": "ignored"
        ])

        try self.sourceService.importData(archive)

        XCTAssertFalse(self.sourceSettings.appSettings.visibleAtLaunch)
        XCTAssertEqual(self.sourceSettings.pointerRingSettings.alwaysVisible, PointerRingSettingsKeys.defaultAlwaysVisible)
    }

    func testImportDoesNotChangeSettingsWhenArchiveContainsInvalidValues() throws {
        self.sourceSettings.appSettings.visibleAtLaunch = false
        self.sourceSettings.pointerRingSettings.color = .systemPink

        let archive = try Self.makeArchive(values: [
            AppSettings.visibleAtLaunchKey: "invalid"
        ])

        XCTAssertThrowsError(try self.sourceService.importData(archive))
        XCTAssertFalse(self.sourceSettings.appSettings.visibleAtLaunch)
        XCTAssertEqual(self.sourceSettings.pointerRingSettings.color.hexString, NSColor.systemPink.hexString)
    }

    func testExportKeepsNumericEnumRawValuesAsIntegers() throws {
        self.sourceSettings.keyboardVisualizerSettings.customHorizontalAlignment = .trailing

        let data = try self.sourceService.exportData()
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let values = try XCTUnwrap(object["values"] as? [String: Any])
        let alignment = try XCTUnwrap(values[KeyboardVisualizerSettingsKeys.customHorizontalAlignment] as? [String: Any])

        XCTAssertEqual(alignment["type"] as? String, "int")
        XCTAssertEqual(alignment["value"] as? Int, KeyboardVisualizerAlignment.trailing.rawValue)
    }
}

private extension SettingsTransferServiceTests {
    static func makeArchive(values: [String: Any]) throws -> Data {
        let archiveValues = values.reduce(into: [String: [String: Any]]()) { result, entry in
            let (key, value) = entry
            let encodedValue: [String: Any]
            switch value {
            case let value as Bool:
                encodedValue = ["type": "bool", "value": value]
            case let value as Int:
                encodedValue = ["type": "int", "value": value]
            case let value as Double:
                encodedValue = ["type": "double", "value": value]
            case let value as String:
                encodedValue = ["type": "string", "value": value]
            case let value as Data:
                encodedValue = ["type": "data", "value": value.base64EncodedString()]
            default:
                fatalError("Unsupported test archive value: \(value)")
            }
            result[key] = encodedValue
        }

        let archive: [String: Any] = [
            "schemaVersion": SettingsTransferService.schemaVersion,
            "exportedAt": "1970-01-01T00:00:00Z",
            "values": archiveValues
        ]

        return try JSONSerialization.data(withJSONObject: archive, options: [.prettyPrinted, .sortedKeys])
    }
}
