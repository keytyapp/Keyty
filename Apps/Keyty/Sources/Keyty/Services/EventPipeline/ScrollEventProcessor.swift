//
//  ScrollEventProcessor.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

final class ScrollEventProcessor {
    private enum ScrollState {
        case idle
        case active(displayed: Bool)
    }

    private let emit: (DisplayEvent) -> Void

    private var scrollState = ScrollState.idle
    private var scrollDebounceTimer: Timer?

    init(emit: @escaping (DisplayEvent) -> Void) {
        self.emit = emit
    }

    func process(_ mouseEvent: MouseEvent) {
        let phase = mouseEvent.phase

        if phase == .ended || phase == .cancelled {
            self.finishScrollEvent()
            return
        }

        if phase == .began {
            self.scrollState = .active(displayed: false)
            return
        }

        if mouseEvent.scrollingDeltaX == 0.0 && mouseEvent.scrollingDeltaY == 0.0 {
            return
        }

        // Trackpad (precise): show bezel once per gesture, let phase events drive lifecycle.
        // Scroll wheel (imprecise): update the bezel on every click so direction stays current.
        let isWheel = !mouseEvent.hasPreciseScrollingDeltas
        if self.shouldDisplayScrollBezel || isWheel {
            self.scrollState = .active(displayed: true)
            self.emit(.mouse(mouseEvent))
        }

        if phase.isEmpty {
            // Wheel events can be 100–200 ms apart; use a longer debounce so the
            // timer does not fire between clicks and cause flicker.
            let debounce: TimeInterval = isWheel ? 0.4 : 0.15
            self.scrollDebounceTimer?.invalidate()
            self.scrollDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounce, repeats: false) { [weak self] _ in
                self?.finishScrollEvent()
            }
        }
    }

    private var shouldDisplayScrollBezel: Bool {
        switch self.scrollState {
        case .idle:
            return true
        case .active(displayed: let displayed):
            return !displayed
        }
    }

    private func finishScrollEvent() {
        self.scrollDebounceTimer?.invalidate()
        self.scrollDebounceTimer = nil
        self.scrollState = .idle
        self.emit(.groupBreak)
    }
}
