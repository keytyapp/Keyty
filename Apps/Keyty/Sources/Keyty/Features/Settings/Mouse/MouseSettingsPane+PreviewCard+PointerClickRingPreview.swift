//
//  MouseSettingsPane+PreviewCard+PointerClickRingPreview.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

extension MouseSettingsPane.PreviewCard {
    enum PreviewClickRingAnimation {
        static let initialClickHoldDuration: TimeInterval = 0.16
        static let cursorTravelDuration: TimeInterval = 0.6
        static let cursorReturnDuration: TimeInterval = 0.2
    }
}

extension MouseSettingsPane.PreviewCard {
    struct ClickRingPreviewVisualState {
        let opacity: Double
        let scale: CGFloat

        static let initial = Self(
            opacity: PointerRingAnimation.visibleOpacity,
            scale: PointerRingAnimation.spawnStartScale
        )
        static let expanded = Self(
            opacity: PointerRingAnimation.hiddenOpacity,
            scale: PointerRingAnimation.spawnEndScale
        )
    }
}

extension MouseSettingsPane.PreviewCard {
    struct ClickRingPreviewRipple: Identifiable {
        let id = UUID()
        let offset: CGSize
        var visualState: ClickRingPreviewVisualState
    }
}

extension MouseSettingsPane.PreviewCard {
    struct PointerClickRingPreview: View {
        @ObservedObject var model: MouseSettingsPaneViewModel
        @State private var previewTask: Task<Void, Never>?
        @State private var ripples: [ClickRingPreviewRipple] = []
        @State private var cursorOffset: CGSize = .zero

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    ForEach(self.ripples) { ripple in
                        PointerRingPreviewShape(shape: self.model.clickRing.shape)
                            .stroke(
                                Color(appKitColor: self.model.clickRing.color),
                                style: StrokeStyle(
                                    lineWidth: self.previewClickRingThickness,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .frame(
                                width: self.previewClickRingSize(in: geometry.size),
                                height: self.previewClickRingSize(in: geometry.size)
                            )
                            .scaleEffect(ripple.visualState.scale)
                            .opacity(ripple.visualState.opacity)
                            .offset(ripple.offset)
                    }

                    CursorImageView(previewOffset: self.cursorOffset)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .onAppear { self.startAnimation() }
            .onDisappear { self.stopAnimation() }
        }

        private var clickRingPreviewOffsets: [CGSize] {
            [
                CGSize(width: -Spacing.grid(11), height: 0),
                CGSize(width: 0, height: 0),
                CGSize(width: Spacing.grid(11), height: 0)
            ]
        }

        private func previewClickRingSize(in size: CGSize) -> CGFloat {
            let maximumSize = min(size.width, size.height) * 0.72
            return min(maximumSize, self.model.clickRing.size)
        }

        private var previewClickRingThickness: CGFloat {
            let scale = self.previewScale(for: self.model.clickRing.size)
            return max(StrokeWidth.standard, self.model.clickRing.thickness * scale)
        }

        private func previewScale(for ringSize: CGFloat) -> CGFloat {
            guard ringSize > 0 else { return 1 }
            return min(1, Spacing.grid(40) * 0.72 / ringSize)
        }

        private func startAnimation() {
            self.previewTask?.cancel()
            self.ripples = []
            self.cursorOffset = self.clickRingPreviewOffsets.first ?? .zero
            self.previewTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: (MouseSettingsPane.PreviewCard.idleDuration / 2).nanoseconds)
                await self.runAnimationLoop()
            }
        }

        private func stopAnimation() {
            self.previewTask?.cancel()
            self.previewTask = nil
            self.ripples = []
            self.cursorOffset = .zero
        }

        private func runAnimationLoop() async {
            while !Task.isCancelled {
                guard let firstOffset = self.clickRingPreviewOffsets.first else { return }

                self.cursorOffset = firstOffset
                self.spawnRipple(at: firstOffset)
                try? await Task.sleep(nanoseconds: PreviewClickRingAnimation.initialClickHoldDuration.nanoseconds)

                for offset in self.clickRingPreviewOffsets.dropFirst() {
                    guard !Task.isCancelled else { return }
                    await self.animateCursorMove(to: offset)
                    guard !Task.isCancelled else { return }
                    self.spawnRipple(at: offset)
                }

                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: PreviewClickRingAnimation.cursorReturnDuration)) {
                    self.cursorOffset = firstOffset
                }

                try? await Task.sleep(nanoseconds: PreviewClickRingAnimation.cursorReturnDuration.nanoseconds)
                guard !Task.isCancelled else { return }

                try? await Task.sleep(
                    nanoseconds: (PointerRingAnimation.spawnAnimationDuration + MouseSettingsPane.PreviewCard.idleDuration).nanoseconds
                )
            }
        }

        private func spawnRipple(at offset: CGSize) {
            let ripple = ClickRingPreviewRipple(offset: offset, visualState: .initial)
            self.ripples.append(ripple)

            withAnimation(.easeOut(duration: PointerRingAnimation.spawnAnimationDuration)) {
                self.updateRipple(id: ripple.id, visualState: .expanded)
            }

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: PointerRingAnimation.spawnAnimationDuration.nanoseconds)
                self.ripples.removeAll { $0.id == ripple.id }
            }
        }

        private func updateRipple(id: UUID, visualState: ClickRingPreviewVisualState) {
            guard let index = self.ripples.firstIndex(where: { $0.id == id }) else { return }
            self.ripples[index].visualState = visualState
        }

        private func animateCursorMove(to offset: CGSize) async {
            withAnimation(.linear(duration: PreviewClickRingAnimation.cursorTravelDuration)) {
                self.cursorOffset = offset
            }
            try? await Task.sleep(nanoseconds: PreviewClickRingAnimation.cursorTravelDuration.nanoseconds)
        }
    }
}
