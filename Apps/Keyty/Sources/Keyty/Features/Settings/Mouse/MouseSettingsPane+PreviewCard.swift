//
//  MouseSettingsPane+PreviewCard.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

extension MouseSettingsPane {
    struct PreviewCard: View {
        @ObservedObject var model: MouseSettingsPaneViewModel

        var body: some View {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Color.Theme.Surface.surfaceBackground)

                self.selectedVisualizerPreview
            }
            .frame(height: Spacing.grid(40))
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(Color.Theme.Border.primary, lineWidth: StrokeWidth.standard)
            )
        }

    }
}

extension MouseSettingsPane.PreviewCard {
    static let holdDuration: TimeInterval = 1.75
    static let idleDuration: TimeInterval = 0.82
}

private extension MouseSettingsPane.PreviewCard {
    @ViewBuilder
    var selectedVisualizerPreview: some View {
        switch self.model.selectedSettingsTab {
        case .ring:
            PointerRingPreview(model: self.model)
        case .ripples:
            PointerRipplesPreview(model: self.model)
        case .icon:
            PointerIconPreview(model: self.model)
        }
    }
}

extension MouseSettingsPane.PreviewCard {
    struct CursorImageView: View {
        let previewOffset: CGSize

        var body: some View {
            let cursor = NSCursor.current
            let offset = Self.cursorOffset(for: cursor)

            Image(nsImage: cursor.image)
                .interpolation(.none)
                .offset(
                    x: offset.width + previewOffset.width.rounded(),
                    y: offset.height + previewOffset.height.rounded()
                )
        }

        private static func cursorOffset(for cursor: NSCursor) -> CGSize {
            let imageSize = cursor.image.size
            let hotspot = cursor.hotSpot

            return CGSize(
                width: imageSize.width / 2 - hotspot.x,
                height: imageSize.height / 2 - hotspot.y
            )
        }
    }
}
