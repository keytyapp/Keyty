//
//  PermissionsService.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

protocol PermissionsService: AnyObject {
    func status(for permission: Permission) -> Permission.Status
    func request(_ permission: Permission)
    func observeChanges(handler: @escaping () -> Void) -> PermissionObservationToken
}

extension PermissionsService {
    var canCaptureInputEvents: Bool {
        self.status(for: .inputCapture) == .granted
    }
}

/// Holds an observation; cancels it automatically on deinit.
final class PermissionObservationToken {
    private let cancel: () -> Void
    init(cancel: @escaping () -> Void) { self.cancel = cancel }
    deinit { cancel() }
}
