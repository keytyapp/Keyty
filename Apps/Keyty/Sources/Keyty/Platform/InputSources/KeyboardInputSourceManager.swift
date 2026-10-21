//
//  KeyboardInputSourceManager.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Carbon
import Foundation

@MainActor
final class KeyboardInputSourceManager {
    static let shared = KeyboardInputSourceManager()

    private let inputSourceObserver: KeyboardInputSourceObserver
    private(set) var currentInputSource: TISInputSource

    init(
        inputSourceObserver: KeyboardInputSourceObserver,
        currentInputSource: TISInputSource
    ) {
        self.inputSourceObserver = inputSourceObserver
        self.currentInputSource = currentInputSource

        inputSourceObserver.inputSourceChanged = { [weak self] inputSource in
            self?.refreshCurrentInputSource(inputSource)
        }
    }

    convenience init() {
        self.init(
            inputSourceObserver: KeyboardInputSourceObserver(),
            currentInputSource: TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue()
        )
    }

    private func refreshCurrentInputSource(_ inputSource: TISInputSource) {
        currentInputSource = inputSource
    }
}
