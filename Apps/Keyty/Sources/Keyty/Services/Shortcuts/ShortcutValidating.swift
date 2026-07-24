//
//  ShortcutValidating.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation
import ShortcutRecorder

/// Validates shortcuts before they are persisted or registered as global hotkeys.
protocol ShortcutValidating: AnyObject {
    /// Returns a localized validation failure message, or `nil` when the shortcut is valid.
    func validationMessage(for shortcut: Shortcut) -> String?
}

extension ShortcutValidator: ShortcutValidating {
    func validationMessage(for shortcut: Shortcut) -> String? {
        do {
            try self.validate(shortcut: shortcut)
            return nil
        } catch {
            return error.localizedDescription.isEmpty
                ? L10n.General.shortcutValidationFallback
                : error.localizedDescription
        }
    }
}
