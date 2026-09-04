//
//  UpdateSettingsPaneViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

@MainActor
final class UpdateSettingsPaneViewModel: ObservableObject {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    private let updateService: any UpdateService

    @Published var automaticallyChecksForUpdates: Bool {
        didSet { self.updateService.automaticallyChecksForUpdates = self.automaticallyChecksForUpdates }
    }

    @Published var sendsSystemProfile: Bool {
        didSet { self.updateService.sendsSystemProfile = self.sendsSystemProfile }
    }

    init(updateService: any UpdateService) {
        self.updateService = updateService
        self.automaticallyChecksForUpdates = self.updateService.automaticallyChecksForUpdates
        self.sendsSystemProfile = self.updateService.sendsSystemProfile
    }

    var lastCheckedText: String {
        guard let date = self.updateService.lastUpdateCheckDate else {
            return L10n.Update.never
        }
        return Self.dateFormatter.string(from: date)
    }

    func checkForUpdates() {
        self.updateService.checkForUpdates()
        self.objectWillChange.send()
    }
}
