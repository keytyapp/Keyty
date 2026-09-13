//
//  PermissionsSettingsPaneViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import SwiftUI

@MainActor
final class PermissionsSettingsPaneViewModel: ObservableObject {
    @Published private(set) var accessibilityStatus: Permission.Status
    @Published private(set) var inputMonitoringStatus: Permission.Status

    private let permissionsService: any PermissionsService
    private var observationToken: PermissionObservationToken?

    init(permissionsService: any PermissionsService) {
        self.permissionsService = permissionsService
        self.accessibilityStatus = self.permissionsService.status(for: .accessibility)
        self.inputMonitoringStatus = self.permissionsService.status(for: .inputMonitoring)
        self.observationToken = self.permissionsService.observeChanges { [weak self] in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    func requestAccessibility() {
        self.handleAction(for: .accessibility)
        self.refresh()
    }

    func requestInputMonitoring() {
        self.handleAction(for: .inputMonitoring)
        self.refresh()
    }

    func refresh() {
        self.accessibilityStatus = self.permissionsService.status(for: .accessibility)
        self.inputMonitoringStatus = self.permissionsService.status(for: .inputMonitoring)
    }

    private func handleAction(for permission: Permission) {
        guard self.permissionsService.status(for: permission) == .notGranted else { return }
        self.permissionsService.request(permission)
    }
}
