//
//  DisplaysSettingsPane+PreviewCard.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

extension DisplaysSettingsPane {
    struct PreviewCard: View {
        let screens: [Screen]
        let selectedScreen: Screen
        let anchor: KeyboardVisualizerAnchor
        let placementMode: KeyboardVisualizerSettings.PlacementMode
        let stackAxis: KeyboardVisualizerStackAxis
        let keyboardScale: Double
        let windowPadding: Double
        let customPositionNormalizedX: Double
        let customPositionNormalizedY: Double
        let customHorizontalAlignment: KeyboardVisualizerAlignment
        let customVerticalAlignment: KeyboardVisualizerAlignment
        let onSelectScreen: (Screen) -> Void

        private let previewHeight = Spacing.grid(48)
        private let displayCornerRadius = Radius.sm
        private let displayInset = Spacing.md

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                GeometryReader { geometry in
                    let scaledFrames = self.scaledFrames(in: geometry.size)

                    ZStack {
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .fill(Color.Theme.Surface.surfaceBackground)

                        ForEach(self.screens) { screen in
                            if let frame = scaledFrames[screen.id] {
                                Button {
                                    self.onSelectScreen(screen)
                                } label: {
                                    self.displayCard(for: screen, size: frame.size)
                                        .contentShape(Rectangle())
                                }
                                .position(x: frame.midX, y: frame.midY)
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: self.previewHeight)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .stroke(Color.Theme.Border.primary, lineWidth: StrokeWidth.standard)
                )
            }
        }
    }
}

// MARK: - Display Card
private extension DisplaysSettingsPane.PreviewCard {
    @ViewBuilder
    func displayCard(for screen: Screen, size: CGSize) -> some View {
        let markerSize = self.markerSize(in: size)

        ZStack {
            self.displayBackground(for: screen)

            if screen.id == self.selectedScreen.id {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(Color.Theme.Accent.controlAccent)
                    .frame(width: markerSize.width, height: markerSize.height)
                    .offset(self.markerOffset(in: size, for: screen, markerSize: markerSize))
                    .shadow(color: Color.Theme.Shadow.displayMarker, radius: 6, y: 2)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: self.displayCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: self.displayCornerRadius, style: .continuous)
                .stroke(
                    self.borderColor(for: screen),
                    lineWidth: self.borderWidth(for: screen)
                )
        )
    }

    @ViewBuilder
    func displayBackground(for screen: Screen) -> some View {
        if let wallpaperImage = screen.wallpaperImage {
            ZStack {
                Image(nsImage: wallpaperImage)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()

                Color(appKitColor: Color.Theme.Palette.black60)
            }
        } else {
            Color(appKitColor: Color.Theme.Palette.black60)
        }
    }
}

// MARK: - Marker
private extension DisplaysSettingsPane.PreviewCard {
    var maximumMarkerSize: CGSize {
        switch self.stackAxis {
        case .vertical:
            return CGSize(width: Spacing.grid(3), height: Spacing.grid(6))
        case .horizontal:
            return CGSize(width: Spacing.grid(6), height: Spacing.grid(3))
        }
    }

    func markerSize(in displaySize: CGSize) -> CGSize {
        let maximumSize = self.maximumMarkerSize
        let scale = self.markerScale(in: displaySize, maximumSize: maximumSize)
        let keyboardScale = CGFloat(self.keyboardScale).clamped(to: 0.5...2.0)
        let scaledSize = CGSize(
            width: maximumSize.width * scale * keyboardScale,
            height: maximumSize.height * scale * keyboardScale
        )

        return CGSize(
            width: min(scaledSize.width, max(displaySize.width - Spacing.xs * 2, Spacing.xs)),
            height: min(scaledSize.height, max(displaySize.height - Spacing.xs * 2, Spacing.xs))
        )
    }

    func markerScale(in displaySize: CGSize, maximumSize: CGSize) -> CGFloat {
        let referenceHeight = max(self.previewHeight - self.displayInset * 2, 1)
        let smallestMaximumDimension = max(min(maximumSize.width, maximumSize.height), 1)
        let minimumScale = min(1, Spacing.xs / smallestMaximumDimension)
        let displayScale = displaySize.height / referenceHeight

        return min(1, max(minimumScale, displayScale))
    }

    func markerOffset(in size: CGSize, for screen: Screen, markerSize: CGSize) -> CGSize {
        switch self.placementMode {
        case .anchored:
            return self.anchorOffset(in: size, for: screen, markerSize: markerSize)
        case .custom:
            return self.customPositionOffset(in: size, markerSize: markerSize)
        }
    }

    func anchorOffset(in size: CGSize, for screen: Screen, markerSize: CGSize) -> CGSize {
        let halfMarkerWidth = markerSize.width / 2
        let halfMarkerHeight = markerSize.height / 2
        let scale = min(
            size.width / max(screen.frame.width, 1),
            size.height / max(screen.frame.height, 1)
        )
        let scaledWindowPadding = CGFloat(self.windowPadding) * scale
        let horizontalInset = scaledWindowPadding
        let verticalInset = scaledWindowPadding

        let x: CGFloat
        switch self.anchor.horizontal {
        case .leading:
            x = -size.width / 2 + horizontalInset + halfMarkerWidth
        case .center:
            x = 0
        case .trailing:
            x = size.width / 2 - horizontalInset - halfMarkerWidth
        }

        let y: CGFloat
        switch self.anchor.vertical {
        case .top:
            y = -size.height / 2 + verticalInset + halfMarkerHeight
        case .middle:
            y = 0
        case .bottom:
            y = size.height / 2 - verticalInset - halfMarkerHeight
        }

        return CGSize(width: x, height: y)
    }

    func customPositionOffset(in size: CGSize, markerSize: CGSize) -> CGSize {
        let halfMarkerWidth = markerSize.width / 2
        let halfMarkerHeight = markerSize.height / 2
        let anchorX = size.width * CGFloat(self.customPositionNormalizedX) - size.width / 2
        let anchorY = size.height / 2 - size.height * CGFloat(self.customPositionNormalizedY)

        let x = (anchorX + self.markerShift(for: self.customHorizontalAlignment, half: halfMarkerWidth))
            .clamped(minimum: -size.width / 2 + halfMarkerWidth, maximum: size.width / 2 - halfMarkerWidth)
        let y = (anchorY - self.markerShift(for: self.customVerticalAlignment, half: halfMarkerHeight))
            .clamped(minimum: -size.height / 2 + halfMarkerHeight, maximum: size.height / 2 - halfMarkerHeight)

        return CGSize(
            width: x,
            height: y
        )
    }

    func markerShift(for alignment: KeyboardVisualizerAlignment, half: CGFloat) -> CGFloat {
        switch alignment {
        case .leading:  return half
        case .center:   return 0
        case .trailing: return -half
        }
    }
}

// MARK: - Layout
private extension DisplaysSettingsPane.PreviewCard {
    func scaledFrames(in size: CGSize) -> [CGDirectDisplayID: CGRect] {
        guard let bounds = self.layoutBounds else {
            return [:]
        }

        let availableWidth = max(0, size.width - self.displayInset * 2)
        let availableHeight = max(0, size.height - self.displayInset * 2)
        let scale = min(
            availableWidth / max(bounds.width, 1),
            availableHeight / max(bounds.height, 1)
        )

        let contentWidth = bounds.width * scale
        let contentHeight = bounds.height * scale
        let originX = (size.width - contentWidth) / 2
        let originY = (size.height - contentHeight) / 2

        return Dictionary(uniqueKeysWithValues: self.screens.map { screen in
            let frame = screen.frame
            let x = originX + (frame.minX - bounds.minX) * scale
            let y = originY + (bounds.maxY - frame.maxY) * scale
            let scaledFrame = CGRect(
                x: x,
                y: y,
                width: frame.width * scale,
                height: frame.height * scale
            )
            return (screen.id, scaledFrame)
        })
    }

    var layoutBounds: CGRect? {
        self.screens.map(\.frame).reduce(nil) { partialResult, frame in
            guard let partialResult else { return frame }
            return partialResult.union(frame)
        }
    }
}

// MARK: - Styling
private extension DisplaysSettingsPane.PreviewCard {
    func borderColor(for screen: Screen) -> Color {
        screen.id == self.selectedScreen.id ? Color.Theme.Accent.controlAccent : Color.Theme.Border.primary
    }

    func borderWidth(for screen: Screen) -> CGFloat {
        screen.id == self.selectedScreen.id ? 2 : 1
    }
}
