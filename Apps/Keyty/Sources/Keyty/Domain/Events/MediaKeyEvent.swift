//
//  MediaKeyEvent.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// A media / multimedia key press
/// (volume, playback, brightness, keyboard, illumination, eject).
public struct MediaKeyEvent {
    /// The specific media key, decoded from the
    /// `NX_KEYTYPE_*` constants packed into the high word of `data1`.
    public enum Kind: Hashable {
        case soundUp, soundDown, mute
        case brightnessUp, brightnessDown
        case illuminationUp, illuminationDown, illuminationToggle
        case play, next, previous, fast, rewind, eject
        case unknown(Int)

        init(keyCode: Int) {
            switch keyCode {
            case 0:  self = .soundUp
            case 1:  self = .soundDown
            case 2:  self = .brightnessUp
            case 3:  self = .brightnessDown
            case 7:  self = .mute
            case 14: self = .eject
            case 16: self = .play
            case 17: self = .next
            case 18: self = .previous
            case 19: self = .fast
            case 20: self = .rewind
            case 21: self = .illuminationUp
            case 22: self = .illuminationDown
            case 23: self = .illuminationToggle
            default: self = .unknown(keyCode)
            }
        }
    }

    public let type: NSEvent.EventType
    public let modifierFlags: NSEvent.ModifierFlags
    public let kind: Kind
    /// `true` for a press (`NX_KEYDOWN`, state `0xA`), `false` for the release.
    public let isPressed: Bool

    /// `false` for aux-control events that are not media keys (caps lock, power,
    /// num lock, …) and so should not be displayed — caps lock in particular is
    /// already shown via `flagsChanged`, so displaying it here double-renders it.
    public var isRecognized: Bool {
        if case .unknown = kind { return false }
        return true
    }

    public init(nsEvent event: NSEvent) {
        self.type = event.type
        self.modifierFlags = event.modifierFlags
        // data1 layout: keyCode in bits 16–31, key state in bits 8–15.
        let data1 = event.data1
        let keyCode = (data1 & 0xFFFF0000) >> 16
        let keyState = (data1 & 0xFF00) >> 8
        self.kind = Kind(keyCode: keyCode)
        self.isPressed = keyState == 0x0A
    }

    public var inputEvent: InputEvent {
        .mediaKey(self)
    }

}
