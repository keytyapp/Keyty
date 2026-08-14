//
//  CaptureControllerTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import XCTest
@testable import Keyty

@MainActor
final class CaptureControllerTests: XCTestCase {
    private var store: InMemoryKeyValueStore!
    private var keyboardVisualizer: KeyboardVisualizer!
    private var pointerVisualizersManager: PointerVisualizersManager!
    private var permissionsService: TestPermissionsService!
    private var eventTap: TestEventTap!
    private var controller: CaptureController!

    override func setUp() {
        super.setUp()
        self.store = InMemoryKeyValueStore()
        let settings = KeyboardVisualizerSettings(store: self.store)
        settings.registerDefaults()
        self.keyboardVisualizer = KeyboardVisualizer(settings: settings)
        self.pointerVisualizersManager = PointerVisualizersManager()
        self.permissionsService = TestPermissionsService()
        self.eventTap = TestEventTap()
        self.controller = CaptureController(
            pointerVisualizersManager: self.pointerVisualizersManager,
            keyboardVisualizer: self.keyboardVisualizer,
            permissionsService: self.permissionsService,
            eventTap: self.eventTap
        )
    }

    override func tearDown() {
        self.controller = nil
        self.eventTap = nil
        self.permissionsService = nil
        self.pointerVisualizersManager = nil
        self.keyboardVisualizer = nil
        self.store = nil
        super.tearDown()
    }

    // MARK: - Permission Gating

    func testStartInstallsTapWhenPermissionIsGranted() {
        self.permissionsService.currentStatus = .granted

        self.controller.start()

        XCTAssertEqual(self.eventTap.installCount, 1)
        XCTAssertTrue(self.controller.isCapturing)
    }

    func testStartDoesNotInstallTapWhenPermissionIsNotGranted() {
        self.permissionsService.currentStatus = .notGranted

        self.controller.start()

        XCTAssertEqual(self.eventTap.installCount, 0)
        XCTAssertFalse(self.controller.isCapturing)
    }

    func testStartDoesNotPromptForPermission() {
        self.permissionsService.currentStatus = .notGranted

        self.controller.start()

        XCTAssertEqual(self.permissionsService.requestedPermissions, [])
    }

    func testCapturingStartsOncePermissionIsGrantedLater() {
        self.permissionsService.currentStatus = .notGranted
        self.controller.start()
        XCTAssertFalse(self.controller.isCapturing)

        self.permissionsService.currentStatus = .granted
        self.permissionsService.notifyChange()

        XCTAssertEqual(self.eventTap.installCount, 1)
        XCTAssertTrue(self.controller.isCapturing)
    }

    func testCapturingStopsWhenTapCannotBeInstalled() {
        self.permissionsService.currentStatus = .granted
        self.eventTap.installError = .creationFailed

        self.controller.start()

        XCTAssertFalse(self.controller.isCapturing)
    }

    func testStopCapturingRemovesTap() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.controller.stopCapturing()

        XCTAssertEqual(self.eventTap.removeCount, 1)
        XCTAssertFalse(self.controller.isCapturing)
    }

    // MARK: - Tap Recovery

    func testTapIsNotReinstalledBelowTheDisableThreshold() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.eventTap.simulateTemporaryDisable()
        self.eventTap.simulateTemporaryDisable()

        XCTAssertEqual(self.eventTap.installCount, 1)
        XCTAssertTrue(self.controller.isCapturing)
    }

    func testTapIsReinstalledAfterRepeatedDisables() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.eventTap.simulateTemporaryDisable()
        self.eventTap.simulateTemporaryDisable()
        self.eventTap.simulateTemporaryDisable()

        XCTAssertEqual(self.eventTap.installCount, 2)
        XCTAssertTrue(self.controller.isCapturing)
    }

    func testDisableCountResetsAfterAReinstall() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        for _ in 0..<3 { self.eventTap.simulateTemporaryDisable() }
        XCTAssertEqual(self.eventTap.installCount, 2)

        // A fresh run of disables must be needed before the next reinstall.
        self.eventTap.simulateTemporaryDisable()
        self.eventTap.simulateTemporaryDisable()
        XCTAssertEqual(self.eventTap.installCount, 2)

        self.eventTap.simulateTemporaryDisable()
        XCTAssertEqual(self.eventTap.installCount, 3)
    }

    func testCapturingStopsWhenTapReportsFailure() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.eventTap.simulateFailure()

        XCTAssertFalse(self.controller.isCapturing)
    }
}

// MARK: - Test Doubles

private final class TestEventTap: EventTapping {
    var onOutput: ((EventTap.Output) -> Void)?
    var installError: EventTap.Error?

    private(set) var isInstalled = false
    private(set) var installCount = 0
    private(set) var removeCount = 0

    func install() throws(EventTap.Error) {
        if let installError = self.installError { throw installError }
        guard !self.isInstalled else { return }
        self.isInstalled = true
        self.installCount += 1
        self.onOutput?(.stateChanged(.installed))
    }

    func remove() {
        guard self.isInstalled else { return }
        self.isInstalled = false
        self.removeCount += 1
        self.onOutput?(.stateChanged(.idle))
    }

    /// Mirrors `EventTap`: the system disables the tap and it re-enables itself immediately.
    /// The trailing `.installed` is suppressed when the owner reinstalled in response,
    /// matching the real tap's de-duplicated state changes.
    func simulateTemporaryDisable(_ reason: EventTap.DisableReason = .timeout) {
        let installCountBeforeDisable = self.installCount
        self.onOutput?(.stateChanged(.temporarilyDisabled(reason)))
        guard self.isInstalled, self.installCount == installCountBeforeDisable else { return }
        self.onOutput?(.stateChanged(.installed))
    }

    func simulateFailure() {
        self.isInstalled = false
        self.onOutput?(.stateChanged(.failed(.creationFailed)))
    }
}

private final class TestPermissionsService: PermissionsService {
    var currentStatus: Permission.Status = .granted
    private(set) var requestedPermissions: [Permission] = []
    private var observers: [UUID: () -> Void] = [:]

    func status(for permission: Permission) -> Permission.Status {
        self.currentStatus
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

    func notifyChange() {
        self.observers.values.forEach { $0() }
    }
}
