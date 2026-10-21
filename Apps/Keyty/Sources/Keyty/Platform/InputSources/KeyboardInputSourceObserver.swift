//
//  KeyboardInputSourceObserver.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import Foundation

private func selectedKeyboardInputSourceChanged(
    center: CFNotificationCenter?,
    observer: UnsafeMutableRawPointer?,
    name: CFNotificationName?,
    object: UnsafeRawPointer?,
    userInfo: CFDictionary?
) {
    guard let observer else {
        return
    }

    let inputSourceObserver = Unmanaged<KeyboardInputSourceObserver>.fromOpaque(observer).takeUnretainedValue()
    Task { @MainActor [weak inputSourceObserver] in
        inputSourceObserver?.handleChange()
    }
}

@MainActor
final class KeyboardInputSourceObserver {
    private let notificationName = kTISNotifySelectedKeyboardInputSourceChanged! as String

    var inputSourceChanged: (@MainActor (TISInputSource) -> Void)?

    init() {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDistributedCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            selectedKeyboardInputSourceChanged,
            self.notificationName as CFString,
            nil,
            .deliverImmediately
        )
    }

    deinit {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDistributedCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            CFNotificationName(self.notificationName as CFString),
            nil
        )
    }

    func handleChange() {
        let currentInputSource = TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue()
        self.inputSourceChanged?(currentInputSource)
    }
}
