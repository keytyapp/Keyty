//
//  ShortcutRecorderView.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import ShortcutRecorder
import SwiftUI

struct ShortcutRecorderView: NSViewRepresentable {
    let shortcutManager: ShortcutManager

    func makeNSView(context: Context) -> RecorderControl {
        let recorder = RecorderControl(frame: .zero)
        recorder.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        shortcutManager.configureToggleShortcutRecorder(recorder)
        return recorder
    }

    func updateNSView(_ nsView: RecorderControl, context: Context) {
        nsView.objectValue = shortcutManager.toggleCapturingShortcut
    }
}
