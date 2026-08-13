//
//  KeyboardSpecialKey.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

/// A non-text keyboard key whose display should come from key semantics rather
/// than keyboard-layout character translation.
enum KeyboardSpecialKey: Equatable {
    case escape
    case tab

    case delete
    case forwardDelete

    case returnKey
    case keypadEnter
    case space
    case help
    case insert
    case keypadClear
    case home
    case end
    case pageUp
    case pageDown
    case leftArrow
    case rightArrow
    case upArrow
    case downArrow
    case function
    case functionRow(Int)
    case capsLock
    case eisu
    case kana
    case system(SystemKey)
}

// MARK: - Public API
extension KeyboardSpecialKey {
    /// Text rendered inside the keycap for this semantic key.
    ///
    /// Prefer compact symbols for keys that have a standard keyboard glyph, and
    /// short readable names for keys whose glyph would be ambiguous or missing.
    var displayText: String {
        switch self {
        case .escape:
            return UnicodeToken.escape.string
        case .tab:
            return UnicodeToken.tab.string
        case .delete:
            return UnicodeToken.delete.string
        case .forwardDelete:
            return UnicodeToken.forwardDelete.string
        case .returnKey:
            return UnicodeToken.returnKey.string
        case .keypadEnter:
            return UnicodeToken.keypadEnter.string
        case .space:
            return UnicodeToken.visibleSpace.string
        case .help:
            return "help"
        case .insert:
            return "ins"
        case .keypadClear:
            return UnicodeToken.keypadClear.string
        case .home:
            return UnicodeToken.home.string
        case .end:
            return UnicodeToken.end.string
        case .pageUp:
            return UnicodeToken.pageUp.string
        case .pageDown:
            return UnicodeToken.pageDown.string
        case .leftArrow:
            return UnicodeToken.leftArrow.string
        case .rightArrow:
            return UnicodeToken.rightArrow.string
        case .upArrow:
            return UnicodeToken.upArrow.string
        case .downArrow:
            return UnicodeToken.downArrow.string
        case .function:
            return self.label ?? ""
        case .functionRow(let number):
            return "F\(number)"
        case .capsLock:
            return self.label ?? ""
        case .eisu:
            return "英数"
        case .kana:
            return "かな"
        case .system(let key):
            return key.displayText
        }
    }

    /// Optional secondary label rendered with symbol-first keycap styles.
    ///
    /// Labels name keys whose `displayText` is intentionally symbolic or too
    /// compact to be self-explanatory in every visualizer style.
    var label: String? {
        switch self {
        case .function:
            return "fn"
        case .tab:
            return "tab"
        case .escape:
            return "esc"
        case .delete, .forwardDelete:
            return "delete"
        case .returnKey:
            return "return"
        case .keypadEnter:
            return "enter"
        case .capsLock:
            return "caps lock"
        default:
            return nil
        }
    }
}

// MARK: - Function Keys Helpers
extension KeyboardSpecialKey {
    /// Returns the semantic function-row key represented by a raw virtual key code.
    static func functionRow(_ keyCode: KeyboardKeyCode) -> KeyboardSpecialKey? {
        switch keyCode {
        case .f1:  return .functionRow(1)
        case .f2:  return .functionRow(2)
        case .f3:  return .functionRow(3)
        case .f4:  return .functionRow(4)
        case .f5:  return .functionRow(5)
        case .f6:  return .functionRow(6)
        case .f7:  return .functionRow(7)
        case .f8:  return .functionRow(8)
        case .f9:  return .functionRow(9)
        case .f10: return .functionRow(10)
        case .f11: return .functionRow(11)
        case .f12: return .functionRow(12)
        case .f13: return .functionRow(13)
        case .f14: return .functionRow(14)
        case .f15: return .functionRow(15)
        case .f16: return .functionRow(16)
        case .f17: return .functionRow(17)
        case .f18: return .functionRow(18)
        case .f19: return .functionRow(19)
        case .f20: return .functionRow(20)
        default:   return nil
        }
    }
}
