//
//  ScrollEventProcessor.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

final class ScrollEventProcessor {
    private enum State {
        case idle
        case active(displayed: Bool)
    }

    private let onItemProduced: (DisplayEvent) -> Void

    private var state = State.idle
    private var debounceTimer: Timer?

    init(onItemProduced: @escaping (DisplayEvent) -> Void) {
        self.onItemProduced = onItemProduced
    }

    func process(_ mouseEvent: MouseEvent) {
        let phase = mouseEvent.phase

        if phase == .ended || phase == .cancelled {
            self.finishScrollEvent()
            return
        }

        if phase == .began {
            self.state = .active(displayed: false)
            return
        }

        if mouseEvent.hasZeroScrollDelta {
            return
        }

        // Trackpad (precise): show bezel once per gesture, let phase events drive lifecycle.
        // Scroll wheel (imprecise): update the bezel on every click so direction stays current.
        let isWheel = !mouseEvent.hasPreciseScrollingDeltas
        if self.shouldDisplayScrollBezel || isWheel {
            self.state = .active(displayed: true)
            self.onItemProduced(.mouse(mouseEvent))
        }

        if phase.isEmpty {
            // Wheel events can be 100–200 ms apart; use a longer debounce so the
            // timer does not fire between clicks and cause flicker.
            let debounce: TimeInterval = isWheel ? 0.4 : 0.15
            self.debounceTimer?.invalidate()
            self.debounceTimer = Timer.scheduledTimer(withTimeInterval: debounce, repeats: false) { [weak self] _ in
                self?.finishScrollEvent()
            }
        }
    }

    private var shouldDisplayScrollBezel: Bool {
        switch self.state {
        case .idle:
            return true
        case .active(displayed: let displayed):
            return !displayed
        }
    }

    private func finishScrollEvent() {
        self.debounceTimer?.invalidate()
        self.debounceTimer = nil
        self.state = .idle
        self.onItemProduced(.groupBreak)
    }
}
