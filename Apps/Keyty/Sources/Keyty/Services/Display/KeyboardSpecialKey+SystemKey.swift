//
//  KeyboardSpecialKey+SystemKey.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

extension KeyboardSpecialKey {
    /// Hardware or OS-level keys that do not map to ordinary text input.
    enum SystemKey {
        case contextMenu
        case brightnessUp
        case brightnessDown
        case missionControl
        case launchpad
        case spotlight
        case dictation
        case doNotDisturb
    }
}

extension KeyboardSpecialKey.SystemKey {
    /// Short text name for this key; keycaps normally render an SF Symbol instead.
    var displayText: String {
        switch self {
        case .contextMenu:
            return "menu"
        case .brightnessUp:
            return "brighter"
        case .brightnessDown:
            return "dimmer"
        case .missionControl:
            return "mission"
        case .launchpad:
            return "launchpad"
        case .spotlight:
            return "search"
        case .dictation:
            return "dictation"
        case .doNotDisturb:
            return "focus"
        }
    }

    static func key(for keyCode: KeyboardKeyCode) -> KeyboardSpecialKey.SystemKey? {
        switch keyCode {
        case .contextMenu:    return .contextMenu
        case .brightnessUp:   return .brightnessUp
        case .brightnessDown: return .brightnessDown
        case .missionControl: return .missionControl
        case .launchpad:      return .launchpad
        case .spotlight:      return .spotlight
        case .dictation:      return .dictation
        case .doNotDisturb:   return .doNotDisturb
        default:              return nil
        }
    }
}
