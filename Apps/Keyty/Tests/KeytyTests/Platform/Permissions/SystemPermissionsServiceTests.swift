//
//  SystemPermissionsServiceTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

@MainActor
final class SystemPermissionsServiceTests: XCTestCase {
    private let testPollInterval: TimeInterval = 0.01

    func testStatusIsNotGrantedWhenSystemDeniesPermission() {
        let provider = TestPermissionsProvider()
        let service = SystemPermissionsService(provider: provider)

        XCTAssertEqual(service.status(for: .accessibility), .notGranted)
    }

    func testStatusIsGrantedWhenSystemGrantsPermission() {
        let provider = TestPermissionsProvider(grantedPermissions: [.accessibility])
        let service = SystemPermissionsService(provider: provider)

        XCTAssertEqual(service.status(for: .accessibility), .granted)
    }

    func testInputMonitoringStatusIsGrantedWhenSystemGrantsPermission() {
        let provider = TestPermissionsProvider(grantedPermissions: [.inputMonitoring])
        let service = SystemPermissionsService(provider: provider)

        XCTAssertEqual(service.status(for: .inputMonitoring), .granted)
    }

    func testCanCaptureInputEventsWhenActivePermissionIsGranted() {
        let activeProvider = TestPermissionsProvider(grantedPermissions: [.inputCapture])
        let inactivePermission: Permission = Permission.inputCapture == .inputMonitoring ? .accessibility : .inputMonitoring
        let inactiveProvider = TestPermissionsProvider(grantedPermissions: [inactivePermission])
        let deniedProvider = TestPermissionsProvider()

        XCTAssertTrue(SystemPermissionsService(provider: activeProvider).canCaptureInputEvents)
        XCTAssertFalse(SystemPermissionsService(provider: inactiveProvider).canCaptureInputEvents)
        XCTAssertFalse(SystemPermissionsService(provider: deniedProvider).canCaptureInputEvents)
    }

    func testStatusFollowsSystemStateWithoutRememberingPastRequests() {
        let provider = TestPermissionsProvider()
        let service = SystemPermissionsService(provider: provider)

        service.request(.accessibility)
        XCTAssertEqual(service.status(for: .accessibility), .notGranted)

        provider.grantedPermissions = [.accessibility]
        XCTAssertEqual(service.status(for: .accessibility), .granted)

        provider.grantedPermissions = []
        XCTAssertEqual(service.status(for: .accessibility), .notGranted)
    }

    func testRequestIsForwardedOnlyWhenPermissionIsNotGranted() {
        let provider = TestPermissionsProvider(grantedPermissions: [.accessibility])
        let service = SystemPermissionsService(provider: provider)

        service.request(.accessibility)
        XCTAssertEqual(provider.requestedPermissions, [])

        provider.grantedPermissions = []
        service.request(.accessibility)
        XCTAssertEqual(provider.requestedPermissions, [.accessibility])
    }

    func testInputMonitoringRequestIsForwardedOnlyWhenPermissionIsNotGranted() {
        let provider = TestPermissionsProvider(grantedPermissions: [.inputMonitoring])
        let service = SystemPermissionsService(provider: provider)

        service.request(.inputMonitoring)
        XCTAssertEqual(provider.requestedPermissions, [])

        provider.grantedPermissions = []
        service.request(.inputMonitoring)
        XCTAssertEqual(provider.requestedPermissions, [.inputMonitoring])
    }

    func testObserverIsNotifiedWhenSystemStatusChanges() {
        let provider = TestPermissionsProvider()
        let service = SystemPermissionsService(provider: provider, pollInterval: self.testPollInterval)

        let notified = expectation(description: "observer notified")
        let token = service.observeChanges { notified.fulfill() }

        provider.grantedPermissions = [.accessibility]

        wait(for: [notified], timeout: 1)
        XCTAssertNotNil(token)
    }

    func testObserverIsNotNotifiedAfterTokenIsReleased() {
        let provider = TestPermissionsProvider()
        let service = SystemPermissionsService(provider: provider, pollInterval: self.testPollInterval)

        var callCount = 0
        var token: PermissionObservationToken? = service.observeChanges { callCount += 1 }
        XCTAssertNotNil(token)
        token = nil

        provider.grantedPermissions = [.accessibility]

        let unexpectedNotification = expectation(description: "observer is not notified")
        unexpectedNotification.isInverted = true
        wait(for: [unexpectedNotification], timeout: self.testPollInterval * 3)

        XCTAssertEqual(callCount, 0)
    }
}

private final class TestPermissionsProvider: PermissionsProvider {
    var grantedPermissions: Set<Permission>
    private(set) var requestedPermissions: [Permission] = []

    init(grantedPermissions: Set<Permission> = []) {
        self.grantedPermissions = grantedPermissions
    }

    func isGranted(_ permission: Permission) -> Bool {
        self.grantedPermissions.contains(permission)
    }

    func request(_ permission: Permission) {
        self.requestedPermissions.append(permission)
    }
}
