//
//  SettingsTransferService.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

final class SettingsTransferService {
    private let settings: AppSettingsContainer

    init(settings: AppSettingsContainer) {
        self.settings = settings
    }
}

// MARK: - Constants
extension SettingsTransferService {
    static let schemaVersion = 1
    static let fileExtension = "json"
}

// MARK: - Export
extension SettingsTransferService {
    func exportData() throws -> Data {
        let values = self.settings.transferableSettings.reduce(into: [String: Any]()) { result, setting in
            if let value = setting.exportedValue(from: self.settings.store) {
                result[setting.key] = value
            }
        }

        let archive = Archive(
            schemaVersion: Self.schemaVersion,
            exportedAt: Date(),
            values: values.mapValues(ArchiveValue.init)
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(archive)
    }

    func export(to url: URL) throws {
        let data = try self.exportData()
        try data.write(to: url, options: .atomic)
    }
}

// MARK: - Import
extension SettingsTransferService {
    func importData(_ data: Data) throws {
        let archive = try self.decodeArchive(data)
        let descriptorsByKey = Dictionary(self.settings.transferableSettings.map { ($0.key, $0) }, uniquingKeysWith: { current, _ in current })

        try self.validateImport(values: archive.values, descriptorsByKey: descriptorsByKey)

        self.settings.resetAllSettingsToDefaults()

        for (key, value) in archive.values {
            guard let setting = descriptorsByKey[key] else {
                continue
            }

            try setting.applyImportedValue(value.rawValue, in: self.settings.store)
        }
    }

    func `import`(from url: URL) throws {
        try self.importData(Data(contentsOf: url))
    }
}

// MARK: - Errors
extension SettingsTransferService {
    enum Error: Swift.Error, LocalizedError {
        case invalidArchive
        case unsupportedSchemaVersion(Int)

        var errorDescription: String? {
            switch self {
            case .invalidArchive:
                return L10n.General.settingsTransferInvalidArchiveMessage
            case .unsupportedSchemaVersion(let version):
                return L10n.General.settingsTransferUnsupportedSchemaVersionMessage(version)
            }
        }
    }
}

// MARK: - Archive
private extension SettingsTransferService {
    struct Archive: Codable {
        let schemaVersion: Int
        let exportedAt: Date
        let values: [String: ArchiveValue]
    }
}

private extension SettingsTransferService {
    enum ArchiveValue: Codable {
        case bool(Bool)
        case int(Int)
        case double(Double)
        case string(String)
        case data(Data)

        init(_ rawValue: Any) {
            switch rawValue {
            case let value as NSNumber:
                if CFGetTypeID(value) == CFBooleanGetTypeID() {
                    self = .bool(value.boolValue)
                } else if value.doubleValue.rounded(.towardZero) == value.doubleValue {
                    self = .int(value.intValue)
                } else {
                    self = .double(value.doubleValue)
                }
            case let value as Bool:
                self = .bool(value)
            case let value as Int:
                self = .int(value)
            case let value as CGFloat:
                self = .double(Double(value))
            case let value as Double:
                self = .double(value)
            case let value as Float:
                self = .double(Double(value))
            case let value as String:
                self = .string(value)
            case let value as Data:
                self = .data(value)
            default:
                self = .string(String(describing: rawValue))
            }
        }

        var rawValue: Any {
            switch self {
            case .bool(let value):
                return value
            case .int(let value):
                return value
            case .double(let value):
                return value
            case .string(let value):
                return value
            case .data(let value):
                return value
            }
        }

        private enum CodingKeys: String, CodingKey {
            case type
            case value
        }

        private enum ValueType: String, Codable {
            case bool
            case int
            case double
            case string
            case data
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(ValueType.self, forKey: .type)
            switch type {
            case .bool:
                self = .bool(try container.decode(Bool.self, forKey: .value))
            case .int:
                self = .int(try container.decode(Int.self, forKey: .value))
            case .double:
                self = .double(try container.decode(Double.self, forKey: .value))
            case .string:
                self = .string(try container.decode(String.self, forKey: .value))
            case .data:
                self = .data(try container.decode(Data.self, forKey: .value))
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .bool(let value):
                try container.encode(ValueType.bool, forKey: .type)
                try container.encode(value, forKey: .value)
            case .int(let value):
                try container.encode(ValueType.int, forKey: .type)
                try container.encode(value, forKey: .value)
            case .double(let value):
                try container.encode(ValueType.double, forKey: .type)
                try container.encode(value, forKey: .value)
            case .string(let value):
                try container.encode(ValueType.string, forKey: .type)
                try container.encode(value, forKey: .value)
            case .data(let value):
                try container.encode(ValueType.data, forKey: .type)
                try container.encode(value, forKey: .value)
            }
        }
    }

    func decodeArchive(_ data: Data) throws -> Archive {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let archive: Archive
        do {
            archive = try decoder.decode(Archive.self, from: data)
        } catch {
            throw Error.invalidArchive
        }

        guard archive.schemaVersion == Self.schemaVersion else {
            throw Error.unsupportedSchemaVersion(archive.schemaVersion)
        }

        return archive
    }

    func validateImport(
        values: [String: ArchiveValue],
        descriptorsByKey: [String: AnyStoredSetting]
    ) throws {
        let validationStore = InMemoryKeyValueStore()

        for (key, value) in values {
            guard let setting = descriptorsByKey[key] else { continue }
            try setting.applyImportedValue(value.rawValue, in: validationStore)
        }
    }
}
