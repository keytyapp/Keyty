//
//  MouseSettingsPaneViewModel+RipplesSection.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension MouseSettingsPaneViewModel {
    @MainActor
    final class RipplesSection {
        private let visualizer: PointerRipplesVisualizer
        private let settings: any PointerRipplesSettingsProtocol
        var onChange: (() -> Void)?
        private var colorSelectionOverride: String?

        var enabled: Bool {
            didSet {
                self.visualizer.isEnabled = self.enabled
                self.onChange?()
            }
        }

        var color: NSColor {
            didSet {
                self.settings.color = self.color
                self.onChange?()
            }
        }

        var size: Double {
            didSet {
                let clamped = min(max(self.size, MouseSettingsPaneViewModel.ringSizeRange.lowerBound), MouseSettingsPaneViewModel.ringSizeRange.upperBound)
                self.settings.size = CGFloat(clamped)
                self.onChange?()
            }
        }

        var thickness: Double {
            didSet {
                let clamped = min(max(self.thickness, MouseSettingsPaneViewModel.ringThicknessRange.lowerBound), MouseSettingsPaneViewModel.ringThicknessRange.upperBound)
                self.settings.thickness = CGFloat(clamped)
                self.onChange?()
            }
        }

        var shape: PointerRingShape {
            didSet {
                self.settings.shape = self.shape
                self.onChange?()
            }
        }

        init(
            visualizer: PointerRipplesVisualizer,
            settings: any PointerRipplesSettingsProtocol
        ) {
            self.visualizer = visualizer
            self.settings = settings
            self.enabled = visualizer.isEnabled
            self.color = settings.color
            self.size = Double(settings.size)
            self.thickness = Double(settings.thickness)
            self.shape = settings.shape
        }

        var colorSelectionID: String {
            MouseSettingsPaneViewModel.selectionID(
                for: self.color,
                presets: MouseSettingsPaneViewModel.ColorPreset.ringColorPresets,
                selectionOverride: self.colorSelectionOverride,
                customSelectionID: MouseSettingsPaneViewModel.customRingColorSelectionID
            )
        }

        func selectColor(with selectionID: String) {
            MouseSettingsPaneViewModel.selectColor(
                with: selectionID,
                presets: MouseSettingsPaneViewModel.ColorPreset.ringColorPresets,
                selectionOverride: &self.colorSelectionOverride,
                applyColor: { self.color = $0 }
            )
        }

        func beginChoosingCustomColor() {
            self.colorSelectionOverride = MouseSettingsPaneViewModel.customRingColorSelectionID
            self.onChange?()
        }

        func applyCustomColor(_ color: NSColor) {
            self.color = color
            self.colorSelectionOverride = MouseSettingsPaneViewModel.customRingColorSelectionID
            self.onChange?()
        }
    }
}
