//
//  SystemPermissionsService.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

@MainActor
protocol PermissionsProvider {
    func isGranted(_ permission: Permission) -> Bool
    func request(_ permission: Permission)
}

private struct LivePermissionsProvider: PermissionsProvider {
    func isGranted(_ permission: Permission) -> Bool {
        permission.isGranted()
    }

    func request(_ permission: Permission) {
        permission.requestSystemPermission()
    }
}

@MainActor
final class SystemPermissionsService {
    private final class Observation {
        weak var token: PermissionObservationToken?
        let handler: () -> Void

        init(token: PermissionObservationToken, handler: @escaping () -> Void) {
            self.token = token
            self.handler = handler
        }
    }

    private let provider: any PermissionsProvider
    private var observers: [UUID: Observation] = [:]
    private var lastStatuses: [Permission: Permission.Status] = [:]
    private var pollTask: Task<Void, Never>?

    init(provider: any PermissionsProvider) {
        self.provider = provider
    }

    convenience init() {
        self.init(provider: LivePermissionsProvider())
    }

    deinit {
        self.pollTask?.cancel()
    }
}

// MARK: - PermissionsService
extension SystemPermissionsService: PermissionsService {
    func status(for permission: Permission) -> Permission.Status {
        self.provider.isGranted(permission) ? .granted : .notGranted
    }

    func request(_ permission: Permission) {
        guard self.status(for: permission) == .notGranted else { return }
        self.provider.request(permission)
    }

    func observeChanges(handler: @escaping () -> Void) -> PermissionObservationToken {
        self.observers = self.observers.filter { $0.value.token != nil }
        if self.observers.isEmpty { self.stopPolling() }

        let id = UUID()
        let token = PermissionObservationToken { [weak self] in
            Task { @MainActor [weak self] in
                self?.removeObserver(id: id)
            }
        }
        self.observers[id] = Observation(token: token, handler: handler)
        self.startPollingIfNeeded()
        return token
    }
}

private extension SystemPermissionsService {
    private func checkForChanges() {
        let currentStatuses = currentStatuses()
        guard currentStatuses != lastStatuses else {
            return
        }
        self.lastStatuses = currentStatuses
        self.observers.values.forEach { observer in
            if observer.token != nil { observer.handler() }
        }
    }

    private func removeObserver(id: UUID) {
        self.observers.removeValue(forKey: id)
        if self.observers.isEmpty { self.stopPolling() }
    }

    private func currentStatuses() -> [Permission: Permission.Status] {
        Permission.allCases.reduce(into: [:]) { statuses, permission in
            statuses[permission] = self.status(for: permission)
        }
    }
}

// MARK: - Polling
private extension SystemPermissionsService {
    func startPollingIfNeeded() {
        guard self.pollTask == nil else { return }
        lastStatuses = self.currentStatuses()
        self.pollTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    return
                }
                guard let self else { return }
                self.checkForChanges()
            }
        }
    }

    func stopPolling() {
        self.pollTask?.cancel()
        self.pollTask = nil
    }
}
