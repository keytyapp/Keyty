//
//  KeyboardVisualizerSettings+PlacementMode.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

extension KeyboardVisualizerSettings {
    enum PlacementMode: Int, CaseIterable {
        /// Positions the overlay from a screen anchor plus edge inset.
        case anchored

        /// Positions the overlay from a normalized point on the selected display.
        case custom

        var label: String {
            switch self {
            case .anchored:
                return L10n.Displays.Placement.anchored
            case .custom:
                return L10n.Displays.Placement.custom
            }
        }
    }
}
