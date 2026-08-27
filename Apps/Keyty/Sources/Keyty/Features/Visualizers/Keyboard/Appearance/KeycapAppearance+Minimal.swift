//
//  KeycapAppearance+Minimal.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension KeycapAppearance {
    struct Minimal: KeycapAppearanceProviding {
        let shared: Shared

        init(tokens: KeycapThemeTokens) {
            self.shared = Shared(tokens: tokens)
        }
    }
}
