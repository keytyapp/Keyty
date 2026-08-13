//
//  InputEventSymbolMapper.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

enum InputEventSymbolMapper {
    static func sfSymbolName(for event: InputEvent) -> String? {
        switch event {
        case .keystroke(let keystroke):
            return Self.keystrokeSymbolName(for: keystroke)
        case .mediaKey(let mediaKey):
            return Self.mediaKeySymbolName(for: mediaKey.kind)
        case .mouse:
            return nil
        }
    }

    static func keystrokeSymbolName(for event: StandardKeyEvent) -> String? {
        Self.keystrokeSymbolName(for: event.keyCode)
    }

    static func keystrokeSymbolName(for keyCode: UInt16) -> String? {
        guard let keyCode = KeyboardKeyCode(rawValue: keyCode) else { return nil }
        switch keyCode {
        case .dictation: return "microphone"
        case .spotlight: return "magnifyingglass"
        case .doNotDisturb: return "moon"
        case .brightnessUp: return "sun.max.fill"
        case .brightnessDown: return "sun.min.fill"
        case .missionControl: return "square.grid.2x2.fill"
        case .launchpad: return "square.grid.3x3.fill"
        case .contextMenu: return "contextualmenu.and.cursorarrow"
        default: return nil
        }
    }

    static func mediaKeySymbolName(for kind: MediaKeyEvent.Kind) -> String? {
        switch kind {
        case .soundUp:            return "speaker.wave.3"
        case .soundDown:          return "speaker.wave.1"
        case .mute:               return "speaker"
        case .brightnessUp:       return "sun.max.fill"
        case .brightnessDown:     return "sun.min.fill"
        case .illuminationUp:     return "light.max"
        case .illuminationDown:   return "light.min"
        case .illuminationToggle: return "keyboard"
        case .play:               return "playpause"
        case .next:               return "forward.end"
        case .previous:           return "backward.end"
        case .fast:               return "forward"
        case .rewind:             return "backward"
        case .eject:              return "eject"
        case .unknown:            return "music.note"
        }
    }
}
