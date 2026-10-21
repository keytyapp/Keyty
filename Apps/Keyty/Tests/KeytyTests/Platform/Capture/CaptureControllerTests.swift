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

    override func setUp() async throws {
        try await super.setUp()
        nonisolated(unsafe) let testCase = self
        await MainActor.run {
            testCase.store = InMemoryKeyValueStore()
            let settings = KeyboardVisualizerSettings(store: testCase.store)
            settings.registerDefaults()
            testCase.keyboardVisualizer = KeyboardVisualizer(settings: settings)
            testCase.pointerVisualizersManager = PointerVisualizersManager()
            testCase.permissionsService = TestPermissionsService()
            testCase.eventTap = TestEventTap()
            testCase.controller = CaptureController(
                pointerVisualizersManager: testCase.pointerVisualizersManager,
                keyboardVisualizer: testCase.keyboardVisualizer,
                permissionsService: testCase.permissionsService,
                eventTap: testCase.eventTap
            )
        }
    }

    override func tearDown() async throws {
        nonisolated(unsafe) let testCase = self
        await MainActor.run {
            testCase.controller = nil
            testCase.eventTap = nil
            testCase.permissionsService = nil
            testCase.pointerVisualizersManager = nil
            testCase.keyboardVisualizer = nil
            testCase.store = nil
        }
        try await super.tearDown()
    }

    // MARK: - Permission Gating

    func testStartInstallsTapWhenPermissionIsGranted() {
        self.permissionsService.currentStatus = .granted

        self.controller.start()

        XCTAssertEqual(self.eventTap.installCount, 1)
        XCTAssertTrue(self.controller.isCapturing)
    }

    func testStartActivatesPresentationsBeforeReturning() {
        self.permissionsService.currentStatus = .granted

        self.controller.start()

        XCTAssertTrue(self.pointerVisualizersManager.isPresentationActive)
        XCTAssertTrue(self.keyboardVisualizer.isPresentationActive)
    }

    func testStartInstallsTapWhenOnlyInputCapturePermissionIsGranted() {
        self.permissionsService.currentStatus = .notGranted
        self.permissionsService.statuses[.inputCapture] = .granted

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

    func testExplicitCaptureEnableRequestsInputCapturePermission() {
        self.permissionsService.currentStatus = .notGranted
        self.controller.stopCapturing()

        self.controller.toggleCapturing()

        XCTAssertEqual(self.permissionsService.requestedPermissions, [.inputCapture])
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

    func testStopDeactivatesPresentationsBeforeReturning() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.controller.stopCapturing()

        XCTAssertFalse(self.pointerVisualizersManager.isPresentationActive)
        XCTAssertFalse(self.keyboardVisualizer.isPresentationActive)
    }

    func testCapturedKeystrokeIsDisplayedBeforeCallbackReturns() {
        self.permissionsService.currentStatus = .granted
        self.controller.start()

        self.eventTap.simulateEvent(.keystroke(.stub(
            keyCode: .k,
            characters: "k",
            charactersIgnoringModifiers: "k"
        )))

        XCTAssertEqual(self.keyboardVisualizer.visibleGroupCount, 1)
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

@MainActor
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

    func simulateEvent(_ event: EventTap.Event) {
        guard self.isInstalled, !self.isDisabled else { return }
        self.onEvent?(event)
    }
}

private final class TestPermissionsService: PermissionsService {
    var currentStatus: Permission.Status = .granted
    var statuses: [Permission: Permission.Status] = [:]
    private(set) var requestedPermissions: [Permission] = []
    private var observers: [UUID: () -> Void] = [:]

    func status(for permission: Permission) -> Permission.Status {
        self.statuses[permission] ?? self.currentStatus
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
