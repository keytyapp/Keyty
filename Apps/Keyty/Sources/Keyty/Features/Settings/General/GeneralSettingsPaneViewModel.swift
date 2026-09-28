//
//  GeneralSettingsPaneViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Combine
import SwiftUI

final class GeneralSettingsPaneViewModel: ObservableObject {
    let shortcutManager: ShortcutManager

    private let captureController: CaptureController
    private let appSettings: any AppSettingsProtocol
    private let onResetAllSettingsToDefaults: @MainActor () -> Void
    private var cancellables = Set<AnyCancellable>()

    @Published var isCapturing: Bool {
        didSet {
            guard self.isCapturing != self.captureController.isCapturing else { return }
            self.captureController.toggleCapturing()
        }
    }

    @Published var visibleAtLaunch: Bool {
        didSet { self.appSettings.visibleAtLaunch = self.visibleAtLaunch }
    }

    @Published var shortcutValidationMessage: String?

    init(
        shortcutManager: ShortcutManager,
        captureController: CaptureController,
        appSettings: any AppSettingsProtocol,
        onResetAllSettingsToDefaults: @escaping @MainActor () -> Void
    ) {
        self.shortcutManager = shortcutManager
        self.captureController = captureController
        self.appSettings = appSettings
        self.onResetAllSettingsToDefaults = onResetAllSettingsToDefaults

        self.isCapturing = captureController.isCapturing
        self.visibleAtLaunch = self.appSettings.visibleAtLaunch
        self.shortcutValidationMessage = self.shortcutManager.shortcutValidationMessage
        self.shortcutManager.onShortcutValidationMessageChanged = { [weak self] message in
            self?.shortcutValidationMessage = message
        }
        captureController.isCapturingChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCapturing in
                self?.isCapturing = isCapturing
            }
            .store(in: &self.cancellables)
    }

    @MainActor
    func resetAllSettingsToDefaults() {
        self.onResetAllSettingsToDefaults()
        self.visibleAtLaunch = self.appSettings.visibleAtLaunch
        self.shortcutValidationMessage = self.shortcutManager.shortcutValidationMessage
    }
}
