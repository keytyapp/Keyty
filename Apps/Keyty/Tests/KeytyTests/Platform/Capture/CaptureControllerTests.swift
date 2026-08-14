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
        self.eventTap.installError = .portCreationFailed

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

        self.eventTap.simulateDisable()
        self.eventTap.simulateDisable()

        XCTAssertEqual(self.eventTap.installCount, 1)
        XCTAssertTrue(self.controller.isCapturing)
    }

    func testTapIsReenabledBelowTheDisableThreshold() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.eventTap.simulateDisable()
        self.eventTap.simulateDisable()

        XCTAssertEqual(self.eventTap.reenableCount, 2)
        XCTAssertFalse(self.eventTap.isDisabled)
    }

    func testTapIsReinstalledRatherThanReenabledAtTheDisableThreshold() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.eventTap.simulateDisable()
        self.eventTap.simulateDisable()
        self.eventTap.simulateDisable()

        XCTAssertEqual(self.eventTap.reenableCount, 2)
        XCTAssertEqual(self.eventTap.installCount, 2)
    }

    func testTapIsReinstalledAfterRepeatedDisables() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.eventTap.simulateDisable()
        self.eventTap.simulateDisable()
        self.eventTap.simulateDisable()

        XCTAssertEqual(self.eventTap.installCount, 2)
        XCTAssertTrue(self.controller.isCapturing)
    }

    func testDisableCountResetsAfterAReinstall() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        for _ in 0..<3 { self.eventTap.simulateDisable() }
        XCTAssertEqual(self.eventTap.installCount, 2)

        // A fresh run of disables must be needed before the next reinstall.
        self.eventTap.simulateDisable()
        self.eventTap.simulateDisable()
        XCTAssertEqual(self.eventTap.installCount, 2)

        self.eventTap.simulateDisable()
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
    var onEvent: ((EventTap.Event) -> Void)?
    var onStateChanged: ((EventTap.State) -> Void)?
    var installError: EventTap.Error?

    private(set) var isInstalled = false
    private(set) var isDisabled = false
    private(set) var installCount = 0
    private(set) var removeCount = 0
    private(set) var reenableCount = 0

    func install() throws(EventTap.Error) {
        if let installError = self.installError { throw installError }
        guard !self.isInstalled else { return }
        self.isInstalled = true
        self.isDisabled = false
        self.installCount += 1
        self.onStateChanged?(.installed)
    }

    func remove() {
        guard self.isInstalled else { return }
        self.isInstalled = false
        self.isDisabled = false
        self.removeCount += 1
        self.onStateChanged?(.idle)
    }

    func reenable() {
        guard self.isInstalled, self.isDisabled else { return }
        self.isDisabled = false
        self.reenableCount += 1
        self.onStateChanged?(.installed)
    }

    /// The system turns the tap off; it stays off until the owner acts.
    func simulateDisable(_ reason: EventTap.DisableReason = .timeout) {
        guard self.isInstalled else { return }
        self.isDisabled = true
        self.onStateChanged?(.disabled(reason))
    }

    func simulateFailure() {
        self.isInstalled = false
        self.isDisabled = false
        self.onStateChanged?(.failed(.portCreationFailed))
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
