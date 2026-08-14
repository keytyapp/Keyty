//
//  KeyboardModifierKey.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// A physical left or right key for a paired keyboard modifier.
public struct KeyboardModifierKey: Hashable {
    let kind: Kind
    let location: Location

    init(_ kind: Kind, location: Location) {
        self.kind = kind
        self.location = location
    }
}

extension KeyboardModifierKey {
    /// The physical side of a paired keyboard modifier key.
    enum Location: CaseIterable, Hashable {
        case left
        case right

        var canonicalDisplayOrderIndex: Int {
            switch self {
            case .left:
                return 0
            case .right:
                return 1
            }
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
        default: return nil
        }
    }

    static func keys(in flags: NSEvent.ModifierFlags) -> Set<KeyboardModifierKey> {
        Set(Self.all.filter { flags.rawValue & $0.deviceMask != 0 })
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
        }
    }
}
