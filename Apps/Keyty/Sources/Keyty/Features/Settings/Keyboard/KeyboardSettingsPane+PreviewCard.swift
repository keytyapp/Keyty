//
//  KeyboardSettingsPane+PreviewCard.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

extension KeyboardSettingsPane {
    struct PreviewCard: View {
        private static let rotationInterval: TimeInterval = 2.0

        let settings: KeyboardVisualizerSettings
        let identity: String

        @State private var activeIndex = 0
        @State private var rotationTask: Task<Void, Never>?

        var body: some View {
            let groups = KeyboardSettingsPane.PreviewGroup.previewGroups(settings: self.settings)
            let resolvedIndex = KeyboardSettingsPane.PreviewGroup.clampedIndex(self.activeIndex, groupCount: groups.count)
            let activeGroup = groups[resolvedIndex]
            let preferredSize = KeyboardSettingsPane.PreviewGroup.preferredPreviewSize(
                for: groups,
                settings: self.settings
            )

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Color.Theme.Surface.surfaceBackground)

                HStack {
                    Spacer(minLength: 0)
                    KeyboardSettingsPane.PreviewGroup(
                        settings: self.settings,
                        items: activeGroup.items
                    )
                        .frame(
                            width: preferredSize.width,
                            height: preferredSize.height
                        )
                        .id(activeGroup.id)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.vertical, Spacing.xl)
                .padding(.horizontal, Spacing.lg)
            }
            .frame(height: Spacing.grid(40))
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(Color.Theme.Border.primary, lineWidth: StrokeWidth.standard)
            )
            .id(self.identity)
            .animation(.easeInOut(duration: 0.2), value: activeGroup.id)
            .onAppear {
                self.startRotation(groupCount: groups.count)
            }
            .onDisappear {
                self.rotationTask?.cancel()
                self.rotationTask = nil
            }
            .onChange(of: groups.map(\.id)) { groupIDs in
                self.activeIndex = KeyboardSettingsPane.PreviewGroup.clampedIndex(
                    self.activeIndex,
                    groupCount: groupIDs.count
                )
                if self.rotationTask != nil {
                    self.startRotation(groupCount: groupIDs.count)
                }
            }
        }

        private func startRotation(groupCount: Int) {
            self.rotationTask?.cancel()
            self.rotationTask = Task { @MainActor in
                while !Task.isCancelled {
                    do {
                        try await Task.sleep(nanoseconds: Self.rotationInterval.nanoseconds)
                    } catch {
                        return
                    }
                    self.activeIndex = KeyboardSettingsPane.PreviewGroup.nextIndex(
                        after: self.activeIndex,
                        groupCount: groupCount
                    )
                }
            }
        }
    }
}
