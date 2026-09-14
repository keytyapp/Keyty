//
//  PermissionsOnboardingViewModelTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

@MainActor
final class PermissionsOnboardingViewModelTests: XCTestCase {
    func testIsCompleteWhenInputCapturePermissionIsGranted() async {
        let service = TestPermissionsService(statuses: [
            .inputCapture: .granted,
        ])
        let model = PermissionsOnboardingViewModel(permissionsService: service)

        XCTAssertTrue(model.isComplete)

        service.statuses[.inputCapture] = .notGranted
        service.notifyObservers()
        await Task.yield()

        XCTAssertFalse(model.isComplete)
    }

    func testIsNotCompleteWhenInactivePermissionIsGranted() {
        let service = TestPermissionsService(statuses: [
            Self.inactiveInputCapturePermission: .granted,
        ])
        let model = PermissionsOnboardingViewModel(permissionsService: service)

        XCTAssertFalse(model.isComplete)
    }

    func testRequestInputCapturePermissionForwardsActivePermissionRequest() {
        let service = TestPermissionsService()
        let model = PermissionsOnboardingViewModel(permissionsService: service)

        model.requestInputCapturePermission()

        XCTAssertEqual(service.requestedPermissions, [.inputCapture])
    }

    func testCompletionDoesNotRunWhenInputCapturePermissionBecomesGranted() async {
        let service = TestPermissionsService()
        let model = PermissionsOnboardingViewModel(permissionsService: service)
        var completionCount = 0
        model.onCompletion = { completionCount += 1 }

        service.statuses[.inputCapture] = .granted
        service.notifyObservers()
        await Task.yield()
        XCTAssertEqual(completionCount, 0)
    }

    func testContinueRunsCompletionWhenInputCapturePermissionIsGranted() {
        let service = TestPermissionsService(statuses: [
            .inputCapture: .granted,
        ])
        let model = PermissionsOnboardingViewModel(permissionsService: service)
        var completionCount = 0
        model.onCompletion = { completionCount += 1 }

        model.continueIfComplete()

        XCTAssertEqual(completionCount, 1)
    }

    func testContinueDoesNotRunCompletionWhenInputCapturePermissionIsNotGranted() {
        let service = TestPermissionsService()
        let model = PermissionsOnboardingViewModel(permissionsService: service)
        var completionCount = 0
        model.onCompletion = { completionCount += 1 }

        model.continueIfComplete()

        XCTAssertEqual(completionCount, 0)
    }

    private static var inactiveInputCapturePermission: Permission {
        Permission.inputCapture == .inputMonitoring ? .accessibility : .inputMonitoring
    }
}

private final class TestPermissionsService: PermissionsService {
    var statuses: [Permission: Permission.Status]
    private(set) var requestedPermissions: [Permission] = []
    private var observers: [UUID: () -> Void] = [:]

    init(statuses: [Permission: Permission.Status] = [:]) {
        self.statuses = statuses
    }

    func status(for permission: Permission) -> Permission.Status {
        self.statuses[permission] ?? .notGranted
    }

    func request(_ permission: Permission) {
        self.requestedPermissions.append(permission)
    }

    func observeChanges(handler: @escaping () -> Void) -> PermissionObservationToken {
        let id = UUID()
        self.observers[id] = handler
        return PermissionObservationToken { [weak self] in
            self?.observers.removeValue(forKey: id)
        }
    }

    func notifyObservers() {
        self.observers.values.forEach { $0() }
    }
}
