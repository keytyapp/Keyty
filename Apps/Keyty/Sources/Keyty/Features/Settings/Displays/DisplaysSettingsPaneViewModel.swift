//
//  DisplaysSettingsPaneViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Combine
import SwiftUI

@MainActor
final class DisplaysSettingsPaneViewModel: ObservableObject {
    private let screensService: any ScreenServiceProvider
    private let keyboardVisualizerSettings: KeyboardVisualizerSettings
    private let startSettingKeyboardVisualizerPosition: @MainActor (@escaping KeyboardVisualizerPlacementChangeHandler) -> Void
    private let stopSettingKeyboardVisualizerPosition: @MainActor () -> KeyboardVisualizerPlacement?
    private var cancellables = Set<AnyCancellable>()

    let paddingRange: ClosedRange<Double> = Double(KeyboardVisualizerSettings.minWindowPadding)...Double(KeyboardVisualizerSettings.maxWindowPadding)
    let paddingStep: Double = Double(Spacing.md)

    @Published private(set) var screens: [Screen]
    @Published private(set) var isSettingCustomPosition = false

    @Published var selectedScreen: Screen {
        didSet { self.keyboardVisualizerSettings.screenID = self.selectedScreen.id }
    }

    var selectedScreenID: CGDirectDisplayID {
        get { self.selectedScreen.id }
        set { self.selectedScreen = self.resolveSelectedScreen(for: newValue) }
    }

    @Published var selectedAnchor: KeyboardVisualizerAnchor {
        didSet { self.keyboardVisualizerSettings.anchor = self.selectedAnchor }
    }

    @Published var placementMode: KeyboardVisualizerSettings.PlacementMode {
        didSet {
            self.keyboardVisualizerSettings.placementMode = self.placementMode
            if self.placementMode != .custom {
                self.stopCustomPositionSetting()
            }
        }
    }

    @Published var windowPadding: Double {
        didSet { self.keyboardVisualizerSettings.windowPadding = CGFloat(self.windowPadding) }
    }

    @Published var customPositionX: Double {
        didSet { self.keyboardVisualizerSettings.customPositionX = CGFloat(self.customPositionX) }
    }

    @Published var customPositionY: Double {
        didSet { self.keyboardVisualizerSettings.customPositionY = CGFloat(self.customPositionY) }
    }

    var stackAxis: KeyboardVisualizerStackAxis {
        self.keyboardVisualizerSettings.stackAxis
    }

    var isCustomPlacement: Bool {
        self.placementMode == .custom
    }

    init(
        screensService: any ScreenServiceProvider = ScreensService.shared,
        keyboardVisualizerSettings: KeyboardVisualizerSettings = KeyboardVisualizerSettings(),
        startSettingKeyboardVisualizerPosition: @escaping @MainActor (@escaping KeyboardVisualizerPlacementChangeHandler) -> Void = { _ in },
        stopSettingKeyboardVisualizerPosition: @escaping @MainActor () -> KeyboardVisualizerPlacement? = { nil }
    ) {
        guard let selectedScreen = Self.initialSelectedScreen(
            screensService: screensService,
            keyboardVisualizerSettings: keyboardVisualizerSettings
        ) else {
            preconditionFailure("DisplaysSettingsPaneViewModel requires at least one available screen")
        }

        self.screensService = screensService
        self.keyboardVisualizerSettings = keyboardVisualizerSettings
        self.startSettingKeyboardVisualizerPosition = startSettingKeyboardVisualizerPosition
        self.stopSettingKeyboardVisualizerPosition = stopSettingKeyboardVisualizerPosition
        self.screens = screensService.screens
        self.selectedScreen = selectedScreen
        self.selectedAnchor = keyboardVisualizerSettings.anchor
        self.placementMode = keyboardVisualizerSettings.placementMode
        self.windowPadding = Double(keyboardVisualizerSettings.windowPadding)
        self.customPositionX = Double(keyboardVisualizerSettings.customPositionX)
        self.customPositionY = Double(keyboardVisualizerSettings.customPositionY)

        self.screensService.screensDidChange
            .receive(on: RunLoop.main)
            .sink { [weak self] screens in
                guard let self else { return }
                self.screens = screens
                self.selectedScreen = self.resolveSelectedScreen(for: self.keyboardVisualizerSettings.screenID)
            }
            .store(in: &self.cancellables)
    }

    func toggleCustomPositionSetting() {
        if self.isSettingCustomPosition {
            self.stopCustomPositionSetting()
        } else {
            self.startSettingKeyboardVisualizerPosition { [weak self] placement in
                self?.applyPlacement(placement)
            }
            self.isSettingCustomPosition = true
        }
    }

    func finishCustomPositionSetting() {
        self.stopCustomPositionSetting()
    }
}

private extension DisplaysSettingsPaneViewModel {
    func stopCustomPositionSetting() {
        guard self.isSettingCustomPosition else { return }
        if let placement = self.stopSettingKeyboardVisualizerPosition() {
            self.applyPlacement(placement)
        }
        self.isSettingCustomPosition = false
    }

    func applyPlacement(_ placement: KeyboardVisualizerPlacement) {
        self.selectedScreenID = placement.screenID
        self.customPositionX = Double(placement.positionX)
        self.customPositionY = Double(placement.positionY)
    }

    static func initialSelectedScreen(
        screensService: any ScreenServiceProvider,
        keyboardVisualizerSettings: KeyboardVisualizerSettings
    ) -> Screen? {
        screensService.display(for: keyboardVisualizerSettings.screenID)
            ?? screensService.mainDisplay()
            ?? screensService.screens.first
    }

    func resolveSelectedScreen(for id: CGDirectDisplayID) -> Screen {
        self.screensService.display(for: id)
            ?? self.screensService.mainDisplay()
            ?? self.screens.first
            ?? self.selectedScreen
    }
}
