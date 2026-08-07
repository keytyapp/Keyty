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
    private lazy var scrollEventProcessor = ScrollEventProcessor { [weak self] item in
        self?.onItemProduced?(item)
    }
}

// MARK: - Event Handlers
extension EventProcessor {
    func processKeystroke(_ keystroke: StandardKeyEvent) {
        self.onItemProduced?(.keystroke(keystroke))
    }

    func processMouseEvent(_ mouseEvent: MouseEvent) {
        if mouseEvent.type == .scrollWheel {
            self.scrollEventProcessor.process(mouseEvent)
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
