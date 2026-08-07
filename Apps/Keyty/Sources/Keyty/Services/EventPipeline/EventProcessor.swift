//
//  EventProcessor.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

public final class EventProcessor {
    var onItemProduced: ((DisplayEvent) -> Void)?

    private enum ScrollState {
        case idle
        case active(displayed: Bool)
    }

    private var scrollState = ScrollState.idle
    private var scrollDebounceTimer: Timer?
}

// MARK: - Event Handlers
extension EventProcessor {
    func processKeystroke(_ keystroke: StandardKeyEvent) {
        self.onItemProduced?(.keystroke(keystroke))
    }

    func processMouseEvent(_ mouseEvent: MouseEvent) {
        if mouseEvent.type == .scrollWheel {
            self.handleScrollEvent(mouseEvent)
            return
        }

        if [.leftMouseDown, .rightMouseDown, .otherMouseDown].contains(mouseEvent.type) {
            self.onItemProduced?(.mouse(mouseEvent))
            return
        }

        if [.leftMouseUp, .rightMouseUp, .otherMouseUp].contains(mouseEvent.type) {
            self.onItemProduced?(.mouse(mouseEvent))
            self.onItemProduced?(.groupBreak)
            return
        }
    }

    func processMediaKey(_ mediaKey: MediaKeyEvent) {
        self.onItemProduced?(.mediaKey(mediaKey))
    }

    func processFlagsChanged(_ flags: NSEvent.ModifierFlags) {
        self.onItemProduced?(.modifierStateChanged(flags))
    }
}

// MARK: - Scroll Events
private extension EventProcessor {
    func handleScrollEvent(_ mouseEvent: MouseEvent) {
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
            self.onItemProduced?(.mouse(mouseEvent))
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

    var shouldDisplayScrollBezel: Bool {
        switch self.scrollState {
        case .idle:
            return true
        case .active(displayed: let displayed):
            return !displayed
        }
    }

    func finishScrollEvent() {
        self.scrollDebounceTimer?.invalidate()
        self.scrollDebounceTimer = nil
        self.scrollState = .idle
        self.onItemProduced?(.groupBreak)
    }
}
