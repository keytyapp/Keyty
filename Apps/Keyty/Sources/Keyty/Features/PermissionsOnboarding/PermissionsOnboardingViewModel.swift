//
//  PermissionsOnboardingViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

@MainActor
final class PermissionsOnboardingViewModel: ObservableObject {
    var accessibilityStatus: Permission.Status {
        self.permissionsService.status(for: .accessibility)
    }

    var inputMonitoringStatus: Permission.Status {
        self.permissionsService.status(for: .inputMonitoring)
    }

    var isComplete: Bool {
        self.inputMonitoringStatus == .granted || self.accessibilityStatus == .granted
    }

    var onCompletion: (() -> Void)?

    private let permissionsService: any PermissionsService
    private let learnMoreURL: URL
    private var observationToken: PermissionObservationToken?

    init(
        permissionsService: any PermissionsService,
        learnMoreURL: URL = AppConstants.permissionsDocumentationURL
    ) {
        self.permissionsService = permissionsService
        self.learnMoreURL = learnMoreURL
        self.observationToken = self.permissionsService.observeChanges { [weak self] in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    func requestAccessibility() {
        self.handlePermissionAction(for: .accessibility)
    }

    func requestInputMonitoring() {
        self.handlePermissionAction(for: .inputMonitoring)
    }

    func continueIfComplete() {
        guard self.isComplete else { return }
        self.onCompletion?()
    }

    func openLearnMore() {
        NSWorkspace.shared.open(self.learnMoreURL)
    }

    func refresh() {
        self.objectWillChange.send()
    }

    private func handlePermissionAction(for permission: Permission) {
        guard self.permissionsService.status(for: permission) == .notGranted else {
            self.refresh()
            return
        }

        self.permissionsService.request(permission)
        self.refresh()
    }
}
