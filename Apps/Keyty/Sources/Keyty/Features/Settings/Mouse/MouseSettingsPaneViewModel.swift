//
//  MouseSettingsPaneViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

@MainActor
final class MouseSettingsPaneViewModel: ObservableObject {
    static let customRingColorSelectionID = "__custom_ring_color__"
    static let customIconBackgroundColorSelectionID = "__custom_icon_background_color__"
    static let customIconTintColorSelectionID = "__custom_icon_tint_color__"

    static let ringSizeRange: ClosedRange<Double> =
        Double(PointerRingSettingsKeys.sizeRange.lowerBound)...Double(PointerRingSettingsKeys.sizeRange.upperBound)
    static let ringSizeStep: Double = 4

    static let ringThicknessRange: ClosedRange<Double> =
        Double(PointerRingSettingsKeys.thicknessRange.lowerBound)...Double(PointerRingSettingsKeys.thicknessRange.upperBound)
    static let ringThicknessStep: Double = 1

    @Published var selectedSettingsTab = SettingsTab.ring

    let ring: RingSection
    let ripples: RipplesSection
    let icon: IconSection

    init(
        ringVisualizer: PointerRingVisualizer,
        ringSettings: any PointerRingSettingsProtocol,
        ripplesVisualizer: PointerRipplesVisualizer,
        ripplesSettings: any PointerRipplesSettingsProtocol,
        iconSettings: any PointerIconSettingsProtocol
    ) {
        self.ring = RingSection(
            visualizer: ringVisualizer,
            settings: ringSettings
        )
        self.ripples = RipplesSection(
            visualizer: ripplesVisualizer,
            settings: ripplesSettings
        )
        self.icon = IconSection(settings: iconSettings)

        let notifyChange: () -> Void = { [weak self] in
            guard let self else { return }
            self.objectWillChange.send()
        }
        self.ring.onChange = notifyChange
        self.ripples.onChange = notifyChange
        self.icon.onChange = notifyChange
    }
}

extension MouseSettingsPaneViewModel {
    enum SettingsTab: CaseIterable {
        case ring
        case ripples
        case icon

        var title: String {
            switch self {
            case .ring:
                return L10n.Mouse.tabRing
            case .ripples:
                return L10n.Mouse.tabRipples
            case .icon:
                return L10n.Mouse.tabIcon
            }
        }
    }
}

extension MouseSettingsPaneViewModel {
    static func selectionID(
        for color: NSColor,
        presets: [ColorPreset],
        selectionOverride: String?,
        customSelectionID: String
    ) -> String {
        if let selectionOverride {
            return selectionOverride
        }

        return presets.first { $0.color.hexString == color.hexString }?.color.hexString
            ?? customSelectionID
    }

    static func selectionID(
        for color: NSColor,
        sections: [[ColorPreset]],
        selectionOverride: String?,
        customSelectionID: String
    ) -> String {
        if let selectionOverride {
            return selectionOverride
        }

        return sections
            .joined()
            .first { $0.color.hexString == color.hexString }?
            .color.hexString
            ?? customSelectionID
    }

    static func selectColor(
        with selectionID: String,
        presets: [ColorPreset],
        selectionOverride: inout String?,
        applyColor: (NSColor) -> Void
    ) {
        guard let preset = presets.first(where: { $0.color.hexString == selectionID }) else {
            return
        }

        selectionOverride = nil
        applyColor(preset.color)
    }

    static func selectIconColor(
        with selectionID: String,
        sections: [[ColorPreset]],
        selectionOverride: inout String?,
        applyColor: (NSColor) -> Void
    ) {
        guard let preset = sections
            .joined()
            .first(where: { $0.color.hexString == selectionID }) else {
            return
        }

        selectionOverride = nil
        applyColor(preset.color)
    }
}
