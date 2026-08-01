//
//  KeyboardVisualizerSettings+PlacementMode.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

extension KeyboardVisualizerSettings {
    enum PlacementMode: Int {
        /// Positions the overlay from a screen anchor plus edge inset.
        case anchored

        /// Positions the overlay from a normalized point on the selected display.
        case custom
    }
}
