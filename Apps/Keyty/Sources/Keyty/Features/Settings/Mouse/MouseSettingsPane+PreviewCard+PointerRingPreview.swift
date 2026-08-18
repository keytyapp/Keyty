//
//  MouseSettingsPane+PreviewCard+PointerRingPreview.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

extension MouseSettingsPane.PreviewCard {
    struct PointerRingPreviewShape: Shape {
        let shape: PointerRingShape

        func path(in rect: CGRect) -> Path {
            let path = PointerRingVisualizerWindow.makeVisualizerPath(
                shape: self.shape,
                rect: NSRect(origin: .zero, size: rect.size)
            )

            return Path(path.cgPath)
        }
    }
}

extension MouseSettingsPane.PreviewCard {
    struct PointerRingPreview: View {
        @ObservedObject var model: MouseSettingsPaneViewModel
        @State private var previewTask: Task<Void, Never>?
        @State private var animationState = PointerRingAnimation.VisualState.idle(alwaysVisible: false)

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    PointerRingPreviewShape(shape: self.model.ring.shape)
                        .stroke(
                            Color(appKitColor: self.model.ring.color),
                            style: StrokeStyle(
                                lineWidth: self.previewRingThickness,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .frame(
                            width: self.previewRingSize(in: geometry.size),
                            height: self.previewRingSize(in: geometry.size)
                        )
                        .scaleEffect(self.animationState.scale)
                        .opacity(self.previewRingOpacity)

                    CursorImageView(previewOffset: .zero)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .onAppear { self.startAnimation() }
            .onDisappear { self.stopAnimation() }
            .onChange(of: self.model.ring.alwaysVisible) { alwaysVisible in
                guard self.animationState.scale == 1 else { return }
                self.animationState = .idle(alwaysVisible: alwaysVisible)
            }
        }

        private var previewRingOpacity: Double {
            self.model.ring.alwaysVisible
                ? PointerRingAnimation.visibleOpacity
                : self.animationState.opacity
        }

        private func previewRingSize(in size: CGSize) -> CGFloat {
            let maximumSize = min(size.width, size.height) * 0.72
            return min(maximumSize, self.model.ring.size)
        }

        private var previewRingThickness: CGFloat {
            let scale = self.previewScale(for: self.model.ring.size)
            return max(StrokeWidth.standard, self.model.ring.thickness * scale)
        }

        private func previewScale(for ringSize: CGFloat) -> CGFloat {
            guard ringSize > 0 else { return 1 }
            return min(1, Spacing.grid(40) * 0.72 / ringSize)
        }

        private func startAnimation() {
            self.previewTask?.cancel()
            self.animationState = .idle(alwaysVisible: self.model.ring.alwaysVisible)
            self.previewTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: (MouseSettingsPane.PreviewCard.idleDuration / 2).nanoseconds)
                await self.runAnimationLoop()
            }
        }

        private func stopAnimation() {
            self.previewTask?.cancel()
            self.previewTask = nil
            self.animationState = .idle(alwaysVisible: self.model.ring.alwaysVisible)
        }

        private func runAnimationLoop() async {
            while !Task.isCancelled {
                withAnimation(.easeOut(duration: PointerRingAnimation.pressAnimationDuration)) {
                    self.animationState = .pressed
                }

                try? await Task.sleep(nanoseconds: MouseSettingsPane.PreviewCard.holdDuration.nanoseconds)
                guard !Task.isCancelled else { return }

                withAnimation(.easeOut(duration: PointerRingAnimation.releaseAnimationDuration)) {
                    self.animationState = .released(alwaysVisible: self.model.ring.alwaysVisible)
                }

                try? await Task.sleep(nanoseconds: MouseSettingsPane.PreviewCard.idleDuration.nanoseconds)
            }
        }
    }
}
