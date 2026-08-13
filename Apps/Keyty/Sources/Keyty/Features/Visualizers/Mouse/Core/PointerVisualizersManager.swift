//
//  PointerVisualizersManager.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

@MainActor
final class PointerVisualizersManager {
    let ring: PointerRingVisualizer
    let icon: PointerIconVisualizer

    var isPresentationActive: Bool = false {
        didSet {
            self.all.forEach { $0.isPresentationActive = self.isPresentationActive }
        }
    }

    private var all: [any PointerVisualizer] { [ring, icon] }

    init(
        pointerRingSettings: any PointerRingSettingsProtocol & ReactiveSettings = PointerRingSettings(),
        pointerIconSettings: any PointerIconSettingsProtocol & ReactiveSettings = PointerIconSettings()
    ) {
        ring = PointerRingVisualizer(settings: pointerRingSettings)
        icon = PointerIconVisualizer(settings: pointerIconSettings)
    }

    func display(_ mouseEvent: MouseEvent) {
        guard self.isPresentationActive else { return }
        for visualizer in all where visualizer.isEnabled {
            visualizer.display(mouseEvent)
        }
    }
}
