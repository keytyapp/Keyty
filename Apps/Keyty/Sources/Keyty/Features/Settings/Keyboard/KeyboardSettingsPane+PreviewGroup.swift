//
//  KeyboardSettingsPane+PreviewGroup.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

extension KeyboardSettingsPane {
    struct PreviewGroup: NSViewRepresentable {
        let settings: KeyboardVisualizerSettings
        let items: [KeycapItem]

        init(settings: KeyboardVisualizerSettings, items: [KeycapItem]? = nil) {
            self.settings = settings
            self.items = items ?? Self.previewGroups(settings: settings).first?.items ?? []
        }

        var preferredSize: CGSize {
            KeyboardVisualizerGroupView(items: self.items, settings: self.settings).preferredSize
        }

        func makeNSView(context: Context) -> KeyboardVisualizerGroupView {
            let view = KeyboardVisualizerGroupView(items: self.items, settings: self.settings)
            view.frame = NSRect(origin: .zero, size: view.preferredSize)
            return view
        }

        func updateNSView(_ nsView: KeyboardVisualizerGroupView, context: Context) {
            nsView.configure(items: self.items, settings: self.settings)
            nsView.frame = NSRect(origin: .zero, size: nsView.preferredSize)
            nsView.needsDisplay = true
        }

        static func previewGroups(settings: KeyboardVisualizerSettings) -> [PreviewDescriptor] {
            var groups: [PreviewDescriptor] = []

            if !settings.onlyShowModifiedKeystrokes {
                groups.append(contentsOf: Self.descriptors(for: .plainKey, sampleGroups: Self.plainKeySampleGroups(), settings: settings))
            }

            groups.append(contentsOf: Self.descriptors(for: .keyboardChord, sampleGroups: Self.keyboardChordSampleGroups(), settings: settings))

            if settings.showSpecialKeys {
                groups.append(contentsOf: Self.descriptors(for: .specialKey, sampleGroups: Self.specialKeySampleGroups(), settings: settings))
            }

            if settings.showMediaKeyButtons {
                groups.append(contentsOf: Self.descriptors(for: .mediaKey, sampleGroups: Self.mediaKeySampleGroups(), settings: settings))
            }

            if settings.showMouseEvents {
                groups.append(contentsOf: Self.descriptors(for: .mouseEvent, sampleGroups: Self.mouseEventSampleGroups(), settings: settings))
            }

            return groups
        }

        static func preferredPreviewSize(
            for groups: [PreviewDescriptor],
            settings: KeyboardVisualizerSettings
        ) -> CGSize {
            groups.reduce(.zero) { partialResult, group in
                let size = KeyboardVisualizerGroupView(items: group.items, settings: settings).preferredSize
                return CGSize(
                    width: max(partialResult.width, size.width),
                    height: max(partialResult.height, size.height)
                )
            }
        }

        static func clampedIndex(_ index: Int, groupCount: Int) -> Int {
            guard groupCount > 0 else { return 0 }
            return min(max(0, index), groupCount - 1)
        }

        static func nextIndex(after index: Int, groupCount: Int) -> Int {
            guard groupCount > 1 else { return 0 }
            return (Self.clampedIndex(index, groupCount: groupCount) + 1) % groupCount
        }

        private static func items(from samples: [KeycapPreviewSample], settings: KeyboardVisualizerSettings) -> [KeycapItem] {
            samples.flatMap { KeycapItemFactory.items(for: $0, palette: settings.palette) }
        }

        private static func descriptors(
            for category: PreviewCategory,
            sampleGroups: [[KeycapPreviewSample]],
            settings: KeyboardVisualizerSettings
        ) -> [PreviewDescriptor] {
            sampleGroups.enumerated().map { index, samples in
                PreviewDescriptor(
                    category: category,
                    variant: index,
                    items: Self.items(from: samples, settings: settings)
                )
            }
        }
    }
}

// MARK: - Samples
extension KeyboardSettingsPane.PreviewGroup {
    private static func plainKeySampleGroups() -> [[KeycapPreviewSample]] {
        [
            [
                .key(
                    keyCode: KeyboardKeyCode.a.rawValue,
                    displayString: "A"
                )
            ],
            [
                .key(
                    keyCode: KeyboardKeyCode.space.rawValue,
                    displayString: "Space"
                )
            ],
        ]
    }

    private static func keyboardChordSampleGroups() -> [[KeycapPreviewSample]] {
        [
            [
                .modifiers(
                    released: [.command, .shift]
                ),
                .key(
                    keyCode: 0x28,
                    displayString: "K"
                ),
            ],
            [
                .modifiers(
                    released: [.option, .control]
                ),
                .key(
                    keyCode: KeyboardKeyCode.escape.rawValue,
                    displayString: KeyboardGlyphCatalog.symbol(for: KeyboardSpecialKey.escape)
                ),
            ],
        ]
    }

    private static func specialKeySampleGroups() -> [[KeycapPreviewSample]] {
        [
            [
                .modifiers(
                    released: [.command]
                ),
                .key(
                    keyCode: KeyboardKeyCode.tab.rawValue,
                    displayString: KeyboardGlyphCatalog.tab
                )
            ],
            [
                .key(
                    keyCode: KeyboardKeyCode.returnKey.rawValue,
                    displayString: KeyboardGlyphCatalog.symbol(for: KeyboardSpecialKey.returnKey)
                )
            ],
        ]
    }

    private static func mediaKeySampleGroups() -> [[KeycapPreviewSample]] {
        [
            [
                .media(.brightnessUp)
            ],
            [
                .media(.play)
            ],
        ]
    }

    private static func mouseEventSampleGroups() -> [[KeycapPreviewSample]] {
        [
            [
                .mouse(.leftButton),
            ],
            [
                .mouse(.wheelUp),
            ],
        ]
    }
}

extension KeyboardSettingsPane {
    /// Identifies the kind of preview content shown in the keyboard settings pane.
    enum PreviewCategory: String, CaseIterable {
        /// A plain, unmodified keystroke preview.
        case plainKey
        /// A multi-key shortcut preview.
        case keyboardChord
        /// A non-text keyboard key preview.
        case specialKey
        /// A media control key preview.
        case mediaKey
        /// A mouse input preview.
        case mouseEvent
    }
}

extension KeyboardSettingsPane {
    /// Describes a preview group and the keycap items it renders.
    struct PreviewDescriptor: Identifiable {
        /// The preview category represented by this descriptor.
        let category: PreviewCategory
        /// Distinguishes multiple preview groups within the same category.
        let variant: Int
        /// The keycap items rendered for this preview.
        let items: [KeycapItem]

        /// The stable identifier derived from the preview category and variant.
        var id: String { "\(self.category.rawValue)-\(self.variant)" }
    }
}
