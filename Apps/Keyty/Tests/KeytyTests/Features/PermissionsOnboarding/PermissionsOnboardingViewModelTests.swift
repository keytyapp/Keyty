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
    func testIsCompleteRequiresAccessibilityPermission() async {
        let service = TestPermissionsService(statuses: [
            .accessibility: .granted,
        ])
        let model = PermissionsOnboardingViewModel(permissionsService: service)

        XCTAssertTrue(model.isComplete)

        service.statuses[.accessibility] = .notGranted
        service.notifyObservers()
        await Task.yield()

        XCTAssertFalse(model.isComplete)
    }

    func testRequestAccessibilityForwardsAccessibilityRequest() {
        let service = TestPermissionsService()
        let model = PermissionsOnboardingViewModel(permissionsService: service)

        model.requestAccessibility()

        XCTAssertEqual(service.requestedPermissions, [.accessibility])
    }

    func testCompletionDoesNotRunWhenAccessibilityBecomesGranted() async {
        let service = TestPermissionsService()
        let model = PermissionsOnboardingViewModel(permissionsService: service)
        var completionCount = 0
        model.onCompletion = { completionCount += 1 }

        service.statuses[.accessibility] = .granted
        service.notifyObservers()
        await Task.yield()
        XCTAssertEqual(completionCount, 0)
    }

    func testContinueRunsCompletionWhenAccessibilityIsGranted() {
        let service = TestPermissionsService(statuses: [
            .accessibility: .granted,
        ])
        let model = PermissionsOnboardingViewModel(permissionsService: service)
        var completionCount = 0
        model.onCompletion = { completionCount += 1 }

        model.continueIfComplete()

        XCTAssertEqual(completionCount, 1)
    }

    func testContinueDoesNotRunCompletionWhenAccessibilityIsNotGranted() {
        let service = TestPermissionsService()
        let model = PermissionsOnboardingViewModel(permissionsService: service)
        var completionCount = 0
        model.onCompletion = { completionCount += 1 }

        model.continueIfComplete()

        XCTAssertEqual(completionCount, 0)
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
