//
//  PointerRingVisualizerWindow+StateMachine.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

extension PointerRingVisualizerWindow {
    struct StateMachine {
        private(set) var state: State = .idle

        mutating func press() {
            self.state = .pressed
        }

        mutating func release(alwaysVisible: Bool) {
            self.state = alwaysVisible ? .idle : .lingering
        }

        mutating func beginFade() -> Bool {
            guard self.state == .lingering else { return false }
            self.state = .fading
            return true
        }

        mutating func reset() {
            self.state = .idle
        }
    }
}

extension PointerRingVisualizerWindow.StateMachine {
    enum State: Equatable {
        case idle
        case pressed
        case lingering
        case fading
    }
}
