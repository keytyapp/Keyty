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
    var defaultRegistration: (key: String, value: Any)? { get }
    func reset(in store: KeyValueStore)
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

struct StoredDescriptor<Value> {
    let key: String
    let defaultValue: Value
    let registrationValue: Any
    let read: (KeyValueStore, String, Value) -> Value
    let write: (KeyValueStore, String, Value) -> Void

    func get(from store: KeyValueStore) -> Value {
        self.read(store, self.key, self.defaultValue)
    }

    func set(_ value: Value, in store: KeyValueStore) {
        self.write(store, self.key, value)
    }
}

@propertyWrapper
struct Stored<Value>: AnyStoredSetting {
    fileprivate let descriptor: StoredDescriptor<Value>

    init(_ descriptor: StoredDescriptor<Value>) {
        self.descriptor = descriptor
    }

    var defaultRegistration: (key: String, value: Any)? {
        if let optional = self.descriptor.registrationValue as? AnyOptional, optional.isNil {
            return nil
        }
        return (self.descriptor.key, self.descriptor.registrationValue)
    }

    func reset(in store: KeyValueStore) {
        store.removeObject(forKey: self.descriptor.key)
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
    func registerStoredDefaults() {
        StoredDefaults.register(from: self, into: self.store)
    }

    func resetStoredSettingsToDefaults() {
        Mirror(reflecting: self).children.forEach { child in
            (child.value as? AnyStoredSetting)?.reset(in: self.store)
        }
    }
}

extension StoredDescriptor where Value == Bool {
    static func bool(_ key: String, default defaultValue: Bool) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: defaultValue,
            read: { store, key, _ in store.bool(forKey: key) },
            write: { store, key, value in store.set(value, forKey: key) }
        )
    }
}

extension StoredDescriptor {
    static func custom(
        key: String,
        default defaultValue: Value,
        registrationValue: Any,
        read: @escaping (KeyValueStore, String, Value) -> Value,
        write: @escaping (KeyValueStore, String, Value) -> Void
    ) -> Self {
        Self(
            key: key,
            defaultValue: defaultValue,
            registrationValue: registrationValue,
            read: read,
            write: write
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
            write: { store, key, value in store.set(value.hexString, forKey: key) }
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
            write: { store, key, value in store.set(value.rawValue, forKey: key) }
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
            write: { store, key, value in store.set(value.rawValue, forKey: key) }
        )
    }
}
