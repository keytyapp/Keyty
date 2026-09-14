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
    var inputCapturePermission: Permission { .inputCapture }

    var inputCaptureStatus: Permission.Status {
        self.permissionsService.status(for: .inputCapture)
    }

    var isComplete: Bool {
        self.permissionsService.canCaptureInputEvents
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

    func requestInputCapturePermission() {
        self.handlePermissionAction(for: .inputCapture)
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
