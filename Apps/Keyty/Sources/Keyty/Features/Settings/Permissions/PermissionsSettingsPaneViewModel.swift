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
    @Published private(set) var inputCaptureStatus: Permission.Status

    var inputCapturePermission: Permission { .inputCapture }

    private let permissionsService: any PermissionsService
    private var observationToken: PermissionObservationToken?

    init(permissionsService: any PermissionsService) {
        self.permissionsService = permissionsService
        self.inputCaptureStatus = self.permissionsService.status(for: .inputCapture)
        self.observationToken = self.permissionsService.observeChanges { [weak self] in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    func requestInputCapturePermission() {
        self.handleAction(for: .inputCapture)
        self.refresh()
    }

    func refresh() {
        self.inputCaptureStatus = self.permissionsService.status(for: .inputCapture)
    }

    private func handleAction(for permission: Permission) {
        guard self.permissionsService.status(for: permission) == .notGranted else { return }
        self.permissionsService.request(permission)
    }
}
