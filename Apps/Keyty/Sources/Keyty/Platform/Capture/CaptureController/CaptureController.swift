//
//  CaptureController.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa

final class CaptureController {
    var isCapturing: Bool { self.state == .capturing }
    var onCapturingChanged: ((Bool) -> Void)?
    private var shouldCapture: Bool = true
    private var state: State = .idle
    private var tapDisableCount: Int = 0
    private let maxTapDisableCountBeforeReinstall = 3

    private let eventTap: any EventTapping
    private let eventProcessor = EventProcessor()
    private let pointerVisualizersManager: PointerVisualizersManager
    private let keyboardVisualizer: KeyboardVisualizer
    private let permissionsService: any PermissionsService
    private var permissionObservationToken: PermissionObservationToken?

    init(
        pointerVisualizersManager: PointerVisualizersManager,
        keyboardVisualizer: KeyboardVisualizer,
        permissionsService: any PermissionsService,
        eventTap: any EventTapping = EventTap()
    ) {
        self.pointerVisualizersManager = pointerVisualizersManager
        self.keyboardVisualizer = keyboardVisualizer
        self.permissionsService = permissionsService
        self.eventTap = eventTap
        self.eventTap.onEvent = { [weak self] event in
            self?.handle(event)
        }
        self.eventTap.onStateChanged = { [weak self] state in
            self?.handleTapStateChange(state)
        }
        self.eventProcessor.onItemProduced = { [keyboardVisualizer] item in
            keyboardVisualizer.display(item)
        }
    }
}

// MARK: - Public API
extension CaptureController {
    /// Call once at launch. Starts capturing immediately if permitted, otherwise waits for permission.
    func start() {
        self.shouldCapture = true
        self.transition(trigger: .appStarted)
    }

    @discardableResult func startCapturing() -> Bool {
        do {
            try self.eventTap.install()
        } catch {
            return false
        }
        self.applyCapturing(true)
        return true
    }

    func stopCapturing() {
        self.shouldCapture = false
        self.transition(trigger: .userDisabledCapture)
    }

    func toggleCapturing() {
        self.shouldCapture.toggle()
        self.transition(trigger: self.shouldCapture ? .userEnabledCapture : .userDisabledCapture)
    }
}

// MARK: - State Transitions
private extension CaptureController {
    func transition(trigger: Trigger) {
        if !self.shouldCapture {
            self.stopObservingPermissionChanges()
            self.stopCapture()
            self.state = .idle
            return
        }

        self.startObservingPermissionChanges()

        let hasAccessibility = self.permissionsService.status(for: .accessibility) == .granted

        guard hasAccessibility else {
            self.stopCapture()
            self.state = self.state == .capturing ? .blockedByPermission : .waitingForPermission
            // Only prompt on an explicit user action; launching must stay silent.
            if case .userEnabledCapture = trigger {
                self.permissionsService.request(.accessibility)
            }
            return
        }

        if self.startCapturing() {
            self.state = .capturing
        } else {
            self.state = .blockedByPermission
        }
    }
}

// MARK: - Permission Observation
private extension CaptureController {
    func stopObservingPermissionChanges() {
        self.permissionObservationToken = nil
    }

    func startObservingPermissionChanges() {
        guard self.permissionObservationToken == nil else { return }
        self.permissionObservationToken = self.permissionsService.observeChanges { [weak self] in
            self?.transition(trigger: .permissionChanged)
        }
    }
}

// MARK: - Capture Lifecycle
private extension CaptureController {
    func applyCapturing(_ capturing: Bool) {
        let wasCapturing = self.isCapturing
        Task { @MainActor [pointerVisualizersManager = self.pointerVisualizersManager, keyboardVisualizer = self.keyboardVisualizer] in
            pointerVisualizersManager.isPresentationActive = capturing
            keyboardVisualizer.isPresentationActive = capturing
        }
        if wasCapturing != capturing {
            self.onCapturingChanged?(capturing)
        }
    }

    func stopCapture() {
        self.applyCapturing(false)
        self.eventTap.remove()
    }
}

// MARK: - Event Tap Handling
private extension CaptureController {
    func reinstallEventTap() {
        self.stopCapture()

        if self.startCapturing() {
            self.tapDisableCount = 0
            self.state = .capturing
        } else {
            self.state = .blockedByTapFailure
        }
    }

    func handleTapFailure() {
        self.stopCapture()
        self.state = .blockedByTapFailure
    }
}

// MARK: - Captured Events
private extension CaptureController {
    func handle(_ event: EventTap.Event) {
        guard self.isCapturing else { return }

        switch event {
        case .keystroke(let keystroke):
            self.eventProcessor.processKeystroke(keystroke)

        case .modifierFlags(let flags):
            self.eventProcessor.processFlagsChanged(flags)

        case .mediaKey(let mediaKey):
            guard mediaKey.isRecognized else { return }
            self.eventProcessor.processMediaKey(mediaKey)

        case .mouse(let mouseEvent):
            Task { @MainActor [pointerVisualizersManager = self.pointerVisualizersManager] in
                pointerVisualizersManager.display(mouseEvent)
            }
            self.eventProcessor.processMouseEvent(mouseEvent)
        }
    }

    func handleTapStateChange(_ state: EventTap.State) {
        switch state {
        case .idle:
            self.tapDisableCount = 0
        case .installed:
            break
        case .disabled:
            self.tapDisableCount += 1
            if self.tapDisableCount >= self.maxTapDisableCountBeforeReinstall {
                self.reinstallEventTap()
            } else {
                self.eventTap.reenable()
            }
        case .failed:
            self.handleTapFailure()
        }
    }
}
