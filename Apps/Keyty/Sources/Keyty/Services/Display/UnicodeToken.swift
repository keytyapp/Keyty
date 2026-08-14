//
//  UnicodeToken.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

/// Atomic Unicode text tokens used to compose displayed keyboard/input strings.
///
/// Keep this namespace restricted to single reusable tokens. Composed output
/// strings belong in higher-level mappers or catalogs.
enum UnicodeToken {
    static let command: Unicode.Scalar = "\u{2318}"
    static let shift: Unicode.Scalar = "\u{21E7}"
    static let option: Unicode.Scalar = "\u{2325}"
    static let control: Unicode.Scalar = "\u{2303}"

    static let tab: Unicode.Scalar = "\u{21E5}"
    static let escape: Unicode.Scalar = "\u{238B}"
    static let delete: Unicode.Scalar = "\u{232B}"
    static let keypadClear: Unicode.Scalar = "\u{2327}"
    static let forwardDelete: Unicode.Scalar = "\u{2326}"
    
    static let returnKey: Unicode.Scalar = "\u{21A9}"
    static let keypadEnter: Unicode.Scalar = "\u{2305}"
    
    static let home: Unicode.Scalar = "\u{2196}"
    static let end: Unicode.Scalar = "\u{2198}"
    static let pageUp: Unicode.Scalar = "\u{21DE}"
    static let pageDown: Unicode.Scalar = "\u{21DF}"

    static let leftArrow: Unicode.Scalar = "\u{25C0}"
    static let rightArrow: Unicode.Scalar = "\u{25B6}"
    static let upArrow: Unicode.Scalar = "\u{25B2}"
    static let downArrow: Unicode.Scalar = "\u{25BC}"

    static let leftwardsArrow: Unicode.Scalar = "\u{2190}"
    static let rightwardsArrow: Unicode.Scalar = "\u{2192}"
    static let upwardsArrow: Unicode.Scalar = "\u{2191}"
    static let downwardsArrow: Unicode.Scalar = "\u{2193}"
    
    static let upLeftArrow: Unicode.Scalar = "\u{2196}"
    static let upRightArrow: Unicode.Scalar = "\u{2197}"
    static let downLeftArrow: Unicode.Scalar = "\u{2199}"
    static let downRightArrow: Unicode.Scalar = "\u{2198}"
    static let bulletOperator: Unicode.Scalar = "\u{2022}"

    static let visibleSpace: Unicode.Scalar = "\u{2423}"

    static let brightnessDown: Unicode.Scalar = "\u{1F505}"
    static let brightnessUp: Unicode.Scalar = "\u{1F506}"

    static let speakerMuted: Unicode.Scalar = "\u{1F507}"
    static let speakerLow: Unicode.Scalar = "\u{1F509}"
    static let speakerHigh: Unicode.Scalar = "\u{1F50A}"
    static let keyboard: Unicode.Scalar = "\u{2328}"
    static let emojiPresentation: Unicode.Scalar = "\u{FE0F}"
    static let plus: Unicode.Scalar = "\u{002B}"
    static let minus: Unicode.Scalar = "\u{2212}"
    static let playPause: Unicode.Scalar = "\u{23EF}"
    static let nextTrack: Unicode.Scalar = "\u{23ED}"
    static let previousTrack: Unicode.Scalar = "\u{23EE}"
    static let fastForward: Unicode.Scalar = "\u{23E9}"
    static let rewind: Unicode.Scalar = "\u{23EA}"
    static let eject: Unicode.Scalar = "\u{23CF}"
    
    static let musicNote: Unicode.Scalar = "\u{266A}"
}
