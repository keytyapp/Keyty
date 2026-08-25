//
//  KeyboardModifierKey.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// A physical key for a keyboard modifier.
public struct KeyboardModifierKey: Hashable {
    let kind: Kind
    let location: Location

    init(_ kind: Kind, location: Location) {
        self.kind = kind
        self.location = location
    }
}

extension KeyboardModifierKey {
    /// The physical position of a modifier key.
    enum Location: CaseIterable, Hashable {
        case left
        case right
        case single

        var canonicalDisplayOrderIndex: Int {
            switch self {
            case .left:
                return 0
            case .right:
                return 1
            case .single:
                return 2
            }
        }
    }
    
    var legendAlignment: KeycapLegendAlignment {
        switch self.location {
        case .left:
            return .right
        case .right:
            return .left
        case .single:
            return .center
        }
    }
}

// MARK: - Helpers
extension KeyboardModifierKey {
    static func key(for keyCode: KeyboardKeyCode) -> KeyboardModifierKey? {
        switch keyCode {
        case .commandLeft: return .leftCommand
        case .commandRight: return .rightCommand
        case .shiftLeft: return .leftShift
        case .shiftRight: return .rightShift
        case .optionLeft: return .leftOption
        case .optionRight: return .rightOption
        case .controlLeft: return .leftControl
        case .controlRight: return .rightControl
        case .function: return .function
        default: return nil
        }
    }

    static func keys(in flags: NSEvent.ModifierFlags) -> Set<KeyboardModifierKey> {
        var keys = Set(Self.all.filter { flags.rawValue & $0.deviceMask != 0 })
        if flags.contains(.function) {
            keys.insert(.function)
        }
        return keys
    }
}

// MARK: - Instances
extension KeyboardModifierKey {
    static let leftCommand = KeyboardModifierKey(.command, location: .left)
    static let rightCommand = KeyboardModifierKey(.command, location: .right)
    static let leftShift = KeyboardModifierKey(.shift, location: .left)
    static let rightShift = KeyboardModifierKey(.shift, location: .right)
    static let leftOption = KeyboardModifierKey(.option, location: .left)
    static let rightOption = KeyboardModifierKey(.option, location: .right)
    static let leftControl = KeyboardModifierKey(.control, location: .left)
    static let rightControl = KeyboardModifierKey(.control, location: .right)
    static let function = KeyboardModifierKey(.function, location: .single)

    static let all: [KeyboardModifierKey] = [
        .leftCommand, .rightCommand,
        .leftShift, .rightShift,
        .leftOption, .rightOption,
        .leftControl, .rightControl
    ]

    // The device-dependent bit macOS sets for this specific physical key.
    var deviceMask: UInt {
        switch (self.kind, self.location) {
        case (.command, .left):  return UInt(NX_DEVICELCMDKEYMASK)
        case (.command, .right): return UInt(NX_DEVICERCMDKEYMASK)
        case (.shift, .left):    return UInt(NX_DEVICELSHIFTKEYMASK)
        case (.shift, .right):   return UInt(NX_DEVICERSHIFTKEYMASK)
        case (.option, .left):   return UInt(NX_DEVICELALTKEYMASK)
        case (.option, .right):  return UInt(NX_DEVICERALTKEYMASK)
        case (.control, .left):  return UInt(NX_DEVICELCTLKEYMASK)
        case (.control, .right): return UInt(NX_DEVICERCTLKEYMASK)
        case (.function, .single): return 0
        case (.command, .single), (.shift, .single), (.option, .single), (.control, .single):
            return 0
        case (.function, .left), (.function, .right):
            return 0
        }
    }
}
