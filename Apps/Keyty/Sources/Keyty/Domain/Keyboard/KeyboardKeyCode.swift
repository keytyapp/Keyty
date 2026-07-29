//
//  KeyboardKeyCode.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

/// Named physical keyboard key codes used by Keyty's keyboard semantics.
///
/// This is intentionally incomplete: unknown keys still flow through the app as
/// raw `UInt16` values, and code converts to this type only where semantics
/// matter.
enum KeyboardKeyCode: UInt16 {
    // MARK: - Letters & punctuation

    case a = 0x00
    case e = 0x0E
    case digit7 = 0x1A
    case minus = 0x1B
    case u = 0x20
    case k = 0x28
    case grave = 0x32

    // MARK: - Whitespace & editing

    case returnKey = 0x24
    case tab = 0x30
    case space = 0x31
    case delete = 0x33
    case forwardDelete = 0x75
    case escape = 0x35

    // MARK: - Modifiers

    case commandRight = 0x36
    case commandLeft = 0x37
    case shiftLeft = 0x38
    case shiftRight = 0x3C
    case optionLeft = 0x3A
    case optionRight = 0x3D
    case controlLeft = 0x3B
    case controlRight = 0x3E
    case capsLock = 0x39
    case function = 0x3F

    // MARK: - Function keys

    case f1 = 0x7A
    case f2 = 0x78
    case f3 = 0x63
    case f4 = 0x76
    case f5 = 0x60
    case f6 = 0x61
    case f7 = 0x62
    case f8 = 0x64
    case f9 = 0x65
    case f10 = 0x6D
    case f11 = 0x67
    case f12 = 0x6F
    case f13 = 0x69
    case f14 = 0x6B
    case f15 = 0x71
    case f16 = 0x6A
    case f17 = 0x40
    case f18 = 0x4F
    case f19 = 0x50
    case f20 = 0x5A

    // MARK: - Keypad

    case keypad0 = 0x52
    case keypad1 = 0x53
    case keypad2 = 0x54
    case keypad3 = 0x55
    case keypad4 = 0x56
    case keypad5 = 0x57
    case keypad6 = 0x58
    case keypad7 = 0x59
    case keypad8 = 0x5B
    case keypad9 = 0x5C
    case keypadDecimal = 0x41
    case keypadMultiply = 0x43
    case keypadPlus = 0x45
    case keypadMinus = 0x4E
    case keypadDivide = 0x4B
    case keypadEquals = 0x51
    case keypadEnter = 0x4C
    case keypadClear = 0x47

    // MARK: - Navigation

    case home = 0x73
    case end = 0x77
    case pageUp = 0x74
    case pageDown = 0x79
    case leftArrow = 0x7B
    case rightArrow = 0x7C
    case downArrow = 0x7D
    case upArrow = 0x7E

    // MARK: - International (JIS)

    case yen = 0x5D
    case jISUnderscore = 0x5E
    case jISKeypadComma = 0x5F
    case eisu = 0x66
    case kana = 0x68

    // MARK: - System & media

    case help = 0x72
    case contextMenu = 0x6E
    case brightnessUp = 0x90
    case brightnessDown = 0x91
    case missionControl = 0xA0
    case launchpad = 0x83
    case spotlight = 0xB1
    case dictation = 0xB0
    case doNotDisturb = 0xB2
}
