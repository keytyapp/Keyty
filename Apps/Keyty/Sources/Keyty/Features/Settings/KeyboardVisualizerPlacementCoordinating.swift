//
//  KeyboardVisualizerPlacementCoordinating.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

@MainActor
protocol KeyboardVisualizerPlacementCoordinating: AnyObject {
    func startSettingPosition(
        onPlacementChanged: @escaping KeyboardVisualizerPlacementWindowController.PlacementChangeHandler
    )

    func stopSettingPosition() -> KeyboardVisualizerPlacementWindowController.Placement?
}
