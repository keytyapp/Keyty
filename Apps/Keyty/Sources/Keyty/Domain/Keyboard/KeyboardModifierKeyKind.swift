//
//  KeyboardModifierKeyKind.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeyboardModifierKey {
    /// The semantic modifier represented by a physical modifier key.
    public enum Kind: CaseIterable, Hashable {
        case command
        case shift
        case option
        case control

        /// Modifier order guidance from Apple style guide:
        /// https://support.apple.com/guide/applestyleguide/k-apsgf9067ae8/1.0/web/1.0
        static let canonicalDisplayOrder: [Self] = [.control, .option, .shift, .command]

        var glyph: String {
            switch self {
            case .command: return UnicodeToken.command.string
            case .shift:   return UnicodeToken.shift.string
            case .option:  return UnicodeToken.option.string
            case .control: return UnicodeToken.control.string
            }
        }

        var label: String {
            switch self {
            case .command: return "command"
            case .shift:   return "shift"
            case .option:  return "option"
            case .control: return "control"
            }
        }

        public var flag: NSEvent.ModifierFlags {
            switch self {
            case .command: return .command
            case .shift: return .shift
            case .option: return .option
            case .control: return .control
            }
        }

        /// Physical key codes for the left and right keys for this modifier.
        var keyCodes: Set<KeyboardKeyCode> {
            switch self {
            case .command: return [.commandLeft, .commandRight]
            case .shift:   return [.shiftLeft, .shiftRight]
            case .option:  return [.optionLeft, .optionRight]
            case .control: return [.controlLeft, .controlRight]
            }
        }

        func keyCode(for location: Location) -> KeyboardKeyCode {
            switch (self, location) {
            case (.command, .left): return .commandLeft
            case (.command, .right): return .commandRight
            case (.shift, .left): return .shiftLeft
            case (.shift, .right): return .shiftRight
            case (.option, .left): return .optionLeft
            case (.option, .right): return .optionRight
            case (.control, .left): return .controlLeft
            case (.control, .right): return .controlRight
            }
        }

        var canonicalDisplayOrderIndex: Int {
            Self.canonicalDisplayOrder.firstIndex(of: self) ?? Self.canonicalDisplayOrder.endIndex
        }
    }
}
