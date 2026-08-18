//
//  MouseSettingsPane+PreviewCard+PointerIconPreview.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

extension MouseSettingsPane.PreviewCard {
    enum PreviewIconAnimation {
        static let clickDuration: TimeInterval = 1.2
        static let scrollDuration: TimeInterval = 1.0
    }
}

extension MouseSettingsPane.PreviewCard {
    enum PreviewIconEvent: CaseIterable {
        case leftClick
        case rightClick
        case scrollUp
        case scrollDown

        var visualState: PointerIconContentView.VisualState {
            switch self {
            case .leftClick:
                return .leftClick
            case .rightClick:
                return .rightClick
            case .scrollUp:
                return .scrollUp
            case .scrollDown:
                return .scrollDown
            }
        }

        var duration: TimeInterval {
            switch self {
            case .leftClick, .rightClick:
                return PreviewIconAnimation.clickDuration
            case .scrollUp, .scrollDown:
                return PreviewIconAnimation.scrollDuration
            }
        }
    }
}

extension MouseSettingsPane.PreviewCard {
    struct PointerIconPreview: View {
        @ObservedObject var model: MouseSettingsPaneViewModel
        @State private var previewTask: Task<Void, Never>?
        @State private var visualState = PointerIconContentView.VisualState.idle

        var body: some View {
            GeometryReader { geometry in
                let image = self.pointerIconPreviewImage
                let scale = self.previewIconScale(for: image.size, in: geometry.size)
                let offset = self.previewIconOffset(for: image.size, scale: scale)

                ZStack {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: image.size.width * scale, height: image.size.height * scale)
                        .offset(x: offset.width, y: offset.height)
                        .opacity(self.previewIconOpacity)

                    CursorImageView(previewOffset: .zero)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .onAppear { self.startAnimation() }
            .onDisappear { self.stopAnimation() }
        }

        private var pointerIconPreviewImage: NSImage {
            PointerIconContentView.renderedImage(
                icon: self.visualState.icon,
                displayedKind: self.visualState.displayedKind,
                iconSize: self.model.icon.size,
                backgroundColor: self.model.icon.backgroundColor,
                tintColor: self.model.icon.tintColor
            )
        }

        private var previewIconOpacity: Double {
            self.model.icon.alwaysVisible || self.visualState.isTransientlyVisible
                ? PointerRingAnimation.visibleOpacity
                : PointerRingAnimation.hiddenOpacity
        }

        private func previewIconScale(for iconSize: NSSize, in containerSize: CGSize) -> CGFloat {
            let offset = CGFloat(self.model.icon.offset)
            let horizontalExtent = iconSize.width + offset
            let verticalExtent = iconSize.height + offset
            guard horizontalExtent > 0, verticalExtent > 0 else { return 1 }

            let availableWidth = containerSize.width * 0.42
            let availableHeight = containerSize.height * 0.42
            return min(1, availableWidth / horizontalExtent, availableHeight / verticalExtent)
        }

        private func previewIconOffset(for iconSize: NSSize, scale: CGFloat) -> CGSize {
            let horizontalOffset = (iconSize.width / 2 + CGFloat(self.model.icon.offset)) * scale
            let verticalOffset = (iconSize.height / 2 + CGFloat(self.model.icon.offset)) * scale

            switch self.model.icon.anchorValue {
            case .bottomRight:
                return CGSize(width: horizontalOffset, height: verticalOffset)
            case .bottomLeft:
                return CGSize(width: -horizontalOffset, height: verticalOffset)
            case .topRight:
                return CGSize(width: horizontalOffset, height: -verticalOffset)
            case .topLeft:
                return CGSize(width: -horizontalOffset, height: -verticalOffset)
            }
        }

        private func startAnimation() {
            self.previewTask?.cancel()
            self.visualState = .idle
            self.previewTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: (MouseSettingsPane.PreviewCard.idleDuration / 2).nanoseconds)
                await self.runAnimationLoop()
            }
        }

        private func stopAnimation() {
            self.previewTask?.cancel()
            self.previewTask = nil
            self.visualState = .idle
        }

        private func runAnimationLoop() async {
            while !Task.isCancelled {
                for event in PreviewIconEvent.allCases {
                    guard !Task.isCancelled else { return }
                    self.visualState = event.visualState

                    try? await Task.sleep(nanoseconds: event.duration.nanoseconds)
                    guard !Task.isCancelled else { return }

                    self.visualState = .idle
                    try? await Task.sleep(nanoseconds: MouseSettingsPane.PreviewCard.idleDuration.nanoseconds)
                }

                self.visualState = .idle
                try? await Task.sleep(nanoseconds: MouseSettingsPane.PreviewCard.idleDuration.nanoseconds)
            }
        }
    }
}
