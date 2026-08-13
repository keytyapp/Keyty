//
//  EventTap+Kind.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa

extension EventTap {
    enum Kind: CaseIterable {
        case key
        case mouseAndFlags
    }
}

extension EventTap.Kind {
    var eventsOfInterest: CGEventMask {
        switch self {
        case .key:
            return Self.mask(.keyDown, .keyUp, .systemDefined)
        case .mouseAndFlags:
            return Self.mask(.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
                             .leftMouseDragged, .rightMouseDragged,
                             .otherMouseDown, .otherMouseUp, .otherMouseDragged,
                             .scrollWheel, .flagsChanged)
        }
    }

    private static func mask(_ types: CGEventType...) -> CGEventMask {
        types.reduce(0) { $0 | CGEventMask(1 << $1.rawValue) }
    }
}
