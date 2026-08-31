//
//  StoredSetting.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine
import Foundation

protocol HasSettingsStore: AnyObject {
    var store: KeyValueStore { get }
}

protocol ReactiveSettings: AnyObject {
    var changes: AnyPublisher<Void, Never> { get }
}

protocol PlacementReactiveSettings: AnyObject {
    var placementChanges: AnyPublisher<Void, Never> { get }
}

protocol AnyStoredSetting {
    var key: String { get }
    var defaultRegistration: (key: String, value: Any)? { get }
    func reset(in store: KeyValueStore)
    func exportedValue(from store: KeyValueStore) -> Any?
    func applyImportedValue(_ value: Any, in store: KeyValueStore) throws
}

struct StoredDescriptor<Value> {
    let key: String
    let defaultValue: Value
    let registrationValue: Any
    let read: (KeyValueStore, String, Value) -> Value
    let write: (KeyValueStore, String, Value) -> Void
    let export: (KeyValueStore, String) -> Any?
    let `import`: (KeyValueStore, String, Any, Value, (Value) -> Void) throws -> Void

    func get(from store: KeyValueStore) -> Value {
        self.read(store, self.key, self.defaultValue)
    }

    func set(_ value: Value, in store: KeyValueStore) {
        self.write(store, self.key, value)
    }

    func exportedValue(from store: KeyValueStore) -> Any? {
        self.export(store, self.key)
    }

    func applyImportedValue(_ value: Any, in store: KeyValueStore) throws {
        try self.import(store, self.key, value, self.defaultValue) { importedValue in
            self.set(importedValue, in: store)
        }
    }
}

@propertyWrapper
struct Stored<Value>: AnyStoredSetting {
    fileprivate let descriptor: StoredDescriptor<Value>

    init(_ descriptor: StoredDescriptor<Value>) {
        self.descriptor = descriptor
    }

    var key: String { self.descriptor.key }

    var defaultRegistration: (key: String, value: Any)? {
        if let optional = self.descriptor.registrationValue as? AnyOptional, optional.isNil {
            return nil
        }
        return (self.descriptor.key, self.descriptor.registrationValue)
    }

    func reset(in store: KeyValueStore) {
        store.removeObject(forKey: self.descriptor.key)
    }

    func exportedValue(from store: KeyValueStore) -> Any? {
        self.descriptor.exportedValue(from: store)
    }

    func applyImportedValue(_ value: Any, in store: KeyValueStore) throws {
        try self.descriptor.applyImportedValue(value, in: store)
    }

    @available(*, unavailable, message: "@Stored can only be used on reference types that conform to HasSettingsStore.")
    var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    static subscript<Owner: HasSettingsStore>(
        _enclosingInstance owner: Owner,
        wrapped _: ReferenceWritableKeyPath<Owner, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Owner, Stored<Value>>
    ) -> Value {
        get {
            owner[keyPath: storageKeyPath].descriptor.get(from: owner.store)
        }
        set {
            owner[keyPath: storageKeyPath].descriptor.set(newValue, in: owner.store)
        }
    }
}

enum StoredDefaults {
    static func register(from object: Any, into store: KeyValueStore) {
        let defaults = Mirror(reflecting: object).children.reduce(into: [String: Any]()) { result, child in
            guard let setting = child.value as? AnyStoredSetting,
                  let registration = setting.defaultRegistration else { return }
            result[registration.key] = registration.value
        }
        guard !defaults.isEmpty else { return }
        store.register(defaults: defaults)
    }
}

extension HasSettingsStore {
    var storedSettings: [AnyStoredSetting] {
        Mirror(reflecting: self).children.compactMap { $0.value as? AnyStoredSetting }
    }

    func registerStoredDefaults() {
        StoredDefaults.register(from: self, into: self.store)
    }

    func resetStoredSettingsToDefaults() {
        self.storedSettings.forEach { $0.reset(in: self.store) }
    }
}

enum StoredSettingImportError: Error, LocalizedError {
    case invalidValue(key: String, expected: String, actual: Any.Type)

    var errorDescription: String? {
        switch self {
        case .invalidValue(let key, let expected, let actual):
            return "Invalid value for setting \"\(key)\". Expected \(expected), got \(String(describing: actual))."
        }
    }
}

extension StoredSettingImportError {
    static func invalidValue(key: String, expected: String, actual value: Any) -> Self {
        .invalidValue(key: key, expected: expected, actual: Swift.type(of: value))
    }
}

extension StoredDescriptor where Value == Bool {
    static func bool(_ key: String, default defaultValue: Bool) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: defaultValue,
            read: { store, key, _ in store.bool(forKey: key) },
            write: { store, key, value in store.set(value, forKey: key) },
            export: { store, key in store.object(forKey: key) },
            import: { _, key, value, _, apply in
                if let boolValue = value as? Bool {
                    apply(boolValue)
                    return
                }
                if let number = value as? NSNumber {
                    apply(number.boolValue)
                    return
                }
                throw StoredSettingImportError.invalidValue(key: key, expected: "Bool", actual: value)
            }
        )
    }
}

extension StoredDescriptor {
    static func custom(
        key: String,
        default defaultValue: Value,
        registrationValue: Any,
        read: @escaping (KeyValueStore, String, Value) -> Value,
        write: @escaping (KeyValueStore, String, Value) -> Void,
        export: @escaping (KeyValueStore, String) -> Any? = { store, key in store.object(forKey: key) },
        import: @escaping (KeyValueStore, String, Any, Value, (Value) -> Void) throws -> Void
    ) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: registrationValue,
            read: read,
            write: write,
            export: export,
            import: `import`
        )
    }
}

extension StoredDescriptor where Value == Int {
    static func int(
        _ key: String,
        default defaultValue: Int,
        clamp range: ClosedRange<Int>? = nil
    ) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: defaultValue,
            read: { store, key, defaultValue in
                let value = store.integer(forKey: key)
                guard let range else { return value }
                return store.object(forKey: key) == nil ? defaultValue : min(max(value, range.lowerBound), range.upperBound)
            },
            write: { store, key, value in
                let sanitizedValue = range.map { min(max(value, $0.lowerBound), $0.upperBound) } ?? value
                store.set(sanitizedValue, forKey: key)
            },
            export: { store, key in store.object(forKey: key) },
            import: { _, key, value, _, apply in
                if let intValue = value as? Int {
                    apply(intValue)
                    return
                }
                if let number = value as? NSNumber {
                    apply(number.intValue)
                    return
                }
                throw StoredSettingImportError.invalidValue(key: key, expected: "Int", actual: value)
            }
        )
    }
}

extension StoredDescriptor where Value == CGFloat {
    static func cgFloat(
        _ key: String,
        default defaultValue: CGFloat,
        clamp range: ClosedRange<CGFloat>? = nil,
        fallback: @escaping (CGFloat, CGFloat) -> CGFloat = { value, defaultValue in
            value
        }
    ) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: defaultValue,
            read: { store, key, defaultValue in
                let value = CGFloat(store.double(forKey: key))
                let fallbackValue = fallback(value, defaultValue)
                guard let range else { return fallbackValue }
                return min(max(fallbackValue, range.lowerBound), range.upperBound)
            },
            write: { store, key, value in
                let sanitizedValue = range.map { min(max(value, $0.lowerBound), $0.upperBound) } ?? value
                store.set(sanitizedValue, forKey: key)
            },
            export: { store, key in store.object(forKey: key) },
            import: { _, key, value, _, apply in
                if let floatValue = value as? CGFloat {
                    apply(floatValue)
                    return
                }
                if let number = value as? NSNumber {
                    apply(CGFloat(number.doubleValue))
                    return
                }
                throw StoredSettingImportError.invalidValue(key: key, expected: "CGFloat", actual: value)
            }
        )
    }
}

extension StoredDescriptor where Value == Data? {
    static func data(_ key: String, default defaultValue: Data? = nil) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: defaultValue as Any,
            read: { store, key, defaultValue in store.data(forKey: key) ?? defaultValue },
            write: { store, key, value in
                if let value {
                    store.set(value, forKey: key)
                } else {
                    store.removeObject(forKey: key)
                }
            },
            export: { store, key in store.data(forKey: key) },
            import: { _, key, value, _, apply in
                guard let dataValue = value as? Data else {
                    throw StoredSettingImportError.invalidValue(key: key, expected: "Data", actual: value)
                }
                apply(dataValue)
            }
        )
    }
}

extension StoredDescriptor where Value == NSColor {
    static func color(_ key: String, default defaultValue: NSColor) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: defaultValue.hexString,
            read: { store, key, defaultValue in store.color(forKey: key) ?? defaultValue },
            write: { store, key, value in store.set(value.hexString, forKey: key) },
            export: { store, key in store.object(forKey: key) },
            import: { _, key, value, defaultValue, apply in
                guard let stringValue = value as? String else {
                    throw StoredSettingImportError.invalidValue(key: key, expected: "String", actual: value)
                }
                apply(NSColor(hexString: stringValue) ?? defaultValue)
            }
        )
    }
}

extension StoredDescriptor where Value: RawRepresentable, Value.RawValue == Int {
    static func `enum`(_ key: String, default defaultValue: Value) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: defaultValue.rawValue,
            read: { store, key, defaultValue in
                Value(rawValue: store.integer(forKey: key)) ?? defaultValue
            },
            write: { store, key, value in store.set(value.rawValue, forKey: key) },
            export: { store, key in store.object(forKey: key) },
            import: { _, key, value, defaultValue, apply in
                if let rawValue = value as? Int {
                    apply(Value(rawValue: rawValue) ?? defaultValue)
                    return
                }
                if let number = value as? NSNumber {
                    apply(Value(rawValue: number.intValue) ?? defaultValue)
                    return
                }
                throw StoredSettingImportError.invalidValue(key: key, expected: "Int", actual: value)
            }
        )
    }
}

extension StoredDescriptor where Value: RawRepresentable, Value.RawValue == String {
    static func `enum`(_ key: String, default defaultValue: Value) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: defaultValue.rawValue,
            read: { store, key, defaultValue in
                guard let rawValue = store.string(forKey: key),
                      let value = Value(rawValue: rawValue) else {
                    return defaultValue
                }
                return value
            },
            write: { store, key, value in store.set(value.rawValue, forKey: key) },
            export: { store, key in store.object(forKey: key) },
            import: { _, key, value, defaultValue, apply in
                guard let rawValue = value as? String else {
                    throw StoredSettingImportError.invalidValue(key: key, expected: "String", actual: value)
                }
                apply(Value(rawValue: rawValue) ?? defaultValue)
            }
        )
    }
}
