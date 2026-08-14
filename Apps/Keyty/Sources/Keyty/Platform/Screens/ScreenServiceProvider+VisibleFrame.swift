//
//  ScreenServiceProvider+VisibleFrame.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreGraphics

extension ScreenServiceProvider {
    func visibleFrame(preferring id: CGDirectDisplayID) -> CGRect? {
        self.visibleFrame(for: id) ?? self.mainVisibleFrame()
    }
}
