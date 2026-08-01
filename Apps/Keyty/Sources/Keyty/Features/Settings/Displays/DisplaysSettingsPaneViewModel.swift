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
    private let startSettingKeyboardVisualizerPosition: @MainActor (@escaping KeyboardVisualizerPlacementWindowController.PlacementChangeHandler) -> Void
    private let stopSettingKeyboardVisualizerPosition: @MainActor () -> KeyboardVisualizerPlacementWindowController.Placement?
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

    @Published var customPositionNormalizedX: Double {
        didSet { self.keyboardVisualizerSettings.customPositionNormalizedX = CGFloat(self.customPositionNormalizedX) }
    }

    @Published var customPositionNormalizedY: Double {
        didSet { self.keyboardVisualizerSettings.customPositionNormalizedY = CGFloat(self.customPositionNormalizedY) }
    }

    var stackAxis: KeyboardVisualizerStackAxis {
        self.keyboardVisualizerSettings.stackAxis
    }

    var isCustomPlacement: Bool {
        self.placementMode == .custom
    }

    var anchorSelection: PlacementSelection {
        get {
            switch self.placementMode {
            case .anchored:
                return .anchor(self.selectedAnchor)
            case .custom:
                return .custom
            }
        }
        set {
            switch newValue {
            case .anchor(let anchor):
                self.selectedAnchor = anchor
                self.placementMode = .anchored
            case .custom:
                self.placementMode = .custom
            }
        }
    }

    init(
        screensService: any ScreenServiceProvider = ScreensService.shared,
        keyboardVisualizerSettings: KeyboardVisualizerSettings = KeyboardVisualizerSettings(),
        startSettingKeyboardVisualizerPosition: @escaping @MainActor (@escaping KeyboardVisualizerPlacementWindowController.PlacementChangeHandler) -> Void = { _ in },
        stopSettingKeyboardVisualizerPosition: @escaping @MainActor () -> KeyboardVisualizerPlacementWindowController.Placement? = { nil }
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
        self.customPositionNormalizedX = Double(keyboardVisualizerSettings.customPositionNormalizedX)
        self.customPositionNormalizedY = Double(keyboardVisualizerSettings.customPositionNormalizedY)

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

extension DisplaysSettingsPaneViewModel {
    enum PlacementSelection: Hashable {
        case anchor(KeyboardVisualizerAnchor)
        case custom

        static let allCases: [PlacementSelection] = KeyboardVisualizerAnchor.allCases.map(Self.anchor) + [.custom]

        var label: String {
            switch self {
            case .anchor(let anchor):
                return "\(anchor.symbol) \(anchor.label)"
            case .custom:
                return L10n.Displays.Placement.custom
            }
        }
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

    func applyPlacement(_ placement: KeyboardVisualizerPlacementWindowController.Placement) {
        self.selectedScreenID = placement.screenID
        self.customPositionNormalizedX = Double(placement.positionX)
        self.customPositionNormalizedY = Double(placement.positionY)
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
