//
//  CursorVisibilityProvider.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Darwin

/// Reports whether the system cursor is currently visible on screen.
protocol CursorVisibilityProviding {
    var isCursorVisible: Bool { get }
}

struct SystemCursorVisibilityProvider: CursorVisibilityProviding {
    var isCursorVisible: Bool {
        guard let cursorIsVisible else {
            return true
        }

        return cursorIsVisible() != 0
    }

    private typealias CursorIsVisibleFunction = @convention(c) () -> Int32
    
    // The runtime symbol still exists, but the current Swift SDK marks it unavailable.
    private var cursorIsVisible: CursorIsVisibleFunction? {
        Self.cursorIsVisibleFunction
    }

    private static let cursorIsVisibleFunction: CursorIsVisibleFunction? = {
        guard
            let handle = dlopen("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics", RTLD_LAZY),
            let symbol = dlsym(handle, "CGCursorIsVisible")
        else {
            return nil
        }
        return unsafeBitCast(symbol, to: CursorIsVisibleFunction.self)
    }()
}
