//
//  MouseSettingsPaneViewModel+IconSection.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

extension MouseSettingsPaneViewModel {
    @MainActor
    final class IconSection {
        private let settings: any PointerIconSettingsProtocol
        var onChange: (() -> Void)?
        private var backgroundColorSelectionOverride: String?
        private var tintColorSelectionOverride: String?

        var enabled: Bool {
            didSet {
                self.settings.isEnabled = self.enabled
                self.onChange?()
            }
        }

        var alwaysVisible: Bool {
            didSet {
                self.settings.alwaysVisible = self.alwaysVisible
                self.onChange?()
            }
        }

        var anchor: Int {
            didSet {
                if let anchor = PointerIconAnchor(rawValue: self.anchor) {
                    self.settings.anchor = anchor
                }
                self.onChange?()
            }
        }

        var offset: Double {
            didSet {
                self.settings.offset = CGFloat(self.offset)
                self.onChange?()
            }
        }

        var sizeIndex: Double {
            didSet {
                self.settings.sizeIndex = Int(self.sizeIndex.rounded())
                self.onChange?()
            }
        }

        var backgroundColor: NSColor {
            didSet {
                self.settings.backgroundColor = self.backgroundColor
                self.onChange?()
            }
        }

        var tintColor: NSColor {
            didSet {
                self.settings.tintColor = self.tintColor
                self.onChange?()
            }
        }

        init(settings: any PointerIconSettingsProtocol) {
            self.settings = settings
            self.enabled = settings.isEnabled
            self.alwaysVisible = settings.alwaysVisible
            self.anchor = settings.anchor.rawValue
            self.offset = Double(settings.offset)
            self.sizeIndex = Double(settings.sizeIndex)
            self.backgroundColor = settings.backgroundColor
            self.tintColor = settings.tintColor
        }

        var backgroundColorSelectionID: String {
            MouseSettingsPaneViewModel.selectionID(
                for: self.backgroundColor,
                sections: MouseSettingsPaneViewModel.ColorPreset.iconBackgroundColorSections,
                selectionOverride: self.backgroundColorSelectionOverride,
                customSelectionID: MouseSettingsPaneViewModel.customIconBackgroundColorSelectionID
            )
        }

        var tintColorSelectionID: String {
            MouseSettingsPaneViewModel.selectionID(
                for: self.tintColor,
                sections: MouseSettingsPaneViewModel.ColorPreset.iconTintColorSections,
                selectionOverride: self.tintColorSelectionOverride,
                customSelectionID: MouseSettingsPaneViewModel.customIconTintColorSelectionID
            )
        }

        var anchorValue: PointerIconAnchor {
            PointerIconAnchor(rawValue: self.anchor) ?? PointerIconSettingsKeys.defaultAnchor
        }

        var size: NSSize {
            let index = Int(self.sizeIndex.rounded())
            let clamped = min(max(0, index), PointerIconSettingsKeys.iconSizes.count - 1)
            return PointerIconSettingsKeys.iconSizes[clamped]
        }

        func selectBackgroundColor(with selectionID: String) {
            MouseSettingsPaneViewModel.selectIconColor(
                with: selectionID,
                sections: MouseSettingsPaneViewModel.ColorPreset.iconBackgroundColorSections,
                selectionOverride: &self.backgroundColorSelectionOverride,
                applyColor: { self.backgroundColor = $0 }
            )
        }

        func beginChoosingCustomBackgroundColor() {
            self.backgroundColorSelectionOverride = MouseSettingsPaneViewModel.customIconBackgroundColorSelectionID
            self.onChange?()
        }

        func applyCustomBackgroundColor(_ color: NSColor) {
            self.backgroundColor = color
            self.backgroundColorSelectionOverride = MouseSettingsPaneViewModel.customIconBackgroundColorSelectionID
            self.onChange?()
        }

        func selectTintColor(with selectionID: String) {
            MouseSettingsPaneViewModel.selectIconColor(
                with: selectionID,
                sections: MouseSettingsPaneViewModel.ColorPreset.iconTintColorSections,
                selectionOverride: &self.tintColorSelectionOverride,
                applyColor: { self.tintColor = $0 }
            )
        }

        func beginChoosingCustomTintColor() {
            self.tintColorSelectionOverride = MouseSettingsPaneViewModel.customIconTintColorSelectionID
            self.onChange?()
        }

        func applyCustomTintColor(_ color: NSColor) {
            self.tintColor = color
            self.tintColorSelectionOverride = MouseSettingsPaneViewModel.customIconTintColorSelectionID
            self.onChange?()
        }
    }
}
