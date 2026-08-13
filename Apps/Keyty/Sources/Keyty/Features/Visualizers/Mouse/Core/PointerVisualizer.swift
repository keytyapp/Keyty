//
//  PointerVisualizer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Updates an on-screen pointer visualizer in response to captured mouse input.
@MainActor
protocol PointerVisualizer: AnyObject {
    /// Whether the visualizer should currently respond to pointer events.
    var isEnabled: Bool { get }

    /// Whether app-wide capture state currently allows pointer presentation.
    var isPresentationActive: Bool { get set }

    /// Handles a captured mouse event and updates the visualizer if needed.
    func display(_ mouseEvent: MouseEvent)
}
