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
        let rawValue = flags.rawValue
        return Set(Self.deviceModifierKeys.compactMap { mask, key in
            rawValue & mask == 0 ? nil : key
        })
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

    private static let deviceModifierKeys: [(mask: UInt, key: KeyboardModifierKey)] = [
        (UInt(NX_DEVICELCMDKEYMASK), .leftCommand),
        (UInt(NX_DEVICERCMDKEYMASK), .rightCommand),
        (UInt(NX_DEVICELSHIFTKEYMASK), .leftShift),
        (UInt(NX_DEVICERSHIFTKEYMASK), .rightShift),
        (UInt(NX_DEVICELALTKEYMASK), .leftOption),
        (UInt(NX_DEVICERALTKEYMASK), .rightOption),
        (UInt(NX_DEVICELCTLKEYMASK), .leftControl),
        (UInt(NX_DEVICERCTLKEYMASK), .rightControl),
    ]
}
