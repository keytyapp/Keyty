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

    func noteKeystroke(_ keystroke: StandardKeyEvent) {
        let item = DisplayEvent.content(
            text: keystroke.displayString,
            sourceEvent: keystroke.inputEvent,
            startsNewLine: keystroke.isCommand,
            isModified: keystroke.isModified,
            isMouseEvent: false
        )
        onItemProduced?(item)
    }

    func noteMouseEvent(_ mouseEvent: MouseEvent) {
        if mouseEvent.type == .scrollWheel {
            handleScrollEvent(mouseEvent)
            return
        }

        if [.leftMouseDown, .rightMouseDown, .otherMouseDown].contains(mouseEvent.type) {
            let item = DisplayEvent.content(
                text: mouseEvent.displayString,
                sourceEvent: mouseEvent.inputEvent,
                startsNewLine: true,
                isModified: false,
                isMouseEvent: true
            )
            onItemProduced?(item)
            return
        }

        if [.leftMouseUp, .rightMouseUp, .otherMouseUp].contains(mouseEvent.type) {
            let item = DisplayEvent.content(
                text: mouseEvent.displayString,
                sourceEvent: mouseEvent.inputEvent,
                startsNewLine: true,
                isModified: false,
                isMouseEvent: true
            )
            onItemProduced?(item)
            onItemProduced?(.groupBreak)
            return
        }

        // Drags discarded.
    }

    func noteMediaKey(_ mediaKey: MediaKeyEvent) {
        let item = DisplayEvent.content(
            text: mediaKey.displayString,
            sourceEvent: mediaKey.inputEvent,
            startsNewLine: false,
            isModified: false,
            isMouseEvent: false
        )
        onItemProduced?(item)
    }

    func noteFlagsChanged(_ flags: NSEvent.ModifierFlags) {
        let item = DisplayEvent.flagsChanged(flags)
        onItemProduced?(item)
    }

    private func handleScrollEvent(_ mouseEvent: MouseEvent) {
        let phase = mouseEvent.phase

        if phase == .ended || phase == .cancelled {
            finishScrollEvent()
            return
        }

        if phase == .began {
            scrollState = .active(displayed: false)
            return
        }

        if mouseEvent.scrollingDeltaX == 0.0 && mouseEvent.scrollingDeltaY == 0.0 {
            return
        }

        // Trackpad (precise): show bezel once per gesture, let phase events drive lifecycle.
        // Scroll wheel (imprecise): update the bezel on every click so direction stays current.
        let isWheel = !mouseEvent.hasPreciseScrollingDeltas
        if shouldDisplayScrollBezel || isWheel {
            scrollState = .active(displayed: true)
            let item = DisplayEvent.content(
                text: mouseEvent.displayString,
                sourceEvent: mouseEvent.inputEvent,
                startsNewLine: true,
                isModified: false,
                isMouseEvent: true
            )
            onItemProduced?(item)
        }

        if phase.isEmpty {
            // Wheel events can be 100–200 ms apart; use a longer debounce so the
            // timer does not fire between clicks and cause flicker.
            let debounce: TimeInterval = isWheel ? 0.4 : 0.15
            scrollDebounceTimer?.invalidate()
            scrollDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounce, repeats: false) { [weak self] _ in
                self?.finishScrollEvent()
            }
        }
    }

    private var shouldDisplayScrollBezel: Bool {
        switch scrollState {
        case .idle:
            return true
        case .active(displayed: let displayed):
            return !displayed
        }
    }

    private func finishScrollEvent() {
        scrollDebounceTimer?.invalidate()
        scrollDebounceTimer = nil
        scrollState = .idle
        onItemProduced?(.groupBreak)
    }
}
