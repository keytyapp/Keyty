//
//  EventTap.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa
import IOKit.hidsystem

final class EventTap {
    /// Receives every captured event and lifecycle change. Called on the run loop
    /// the tap was installed on, never on a background queue.
    var onOutput: ((Output) -> Void)?

    private(set) var state: EventTap.State = .idle {
        didSet {
            guard oldValue != self.state else { return }
            self.onOutput?(.stateChanged(self.state))
        }
    }

    var isInstalled: Bool {
        if case .installed = state {
            return true
        }
        return false
    }

    fileprivate var installedTaps: [Kind: InstalledTap] = [:]

    deinit {
        if self.isInstalled { self.remove() }
    }
}

// MARK: - Public API
extension EventTap {
    func install() throws(EventTap.Error) {
        guard !self.isInstalled else { return }

        for kind in Kind.allCases {
            guard let installedTap = self.makeTap(kind) else {
                self.resetInstalledResources()
                self.state = .failed(.creationFailed(kind))
                throw .creationFailed(kind)
            }
            self.installedTaps[kind] = installedTap
        }

        self.state = .installed
    }

    func remove() {
        guard self.state != .idle else { return }
        self.resetInstalledResources()
        self.state = .idle
    }
}

// MARK: - Tap Resources
private extension EventTap {
    func makeTap(_ kind: Kind) -> InstalledTap? {
        guard let machPort = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: kind.eventsOfInterest,
            callback: tapCallback(for: kind),
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return nil
        }

        guard let runLoopSource = CFMachPortCreateRunLoopSource(nil, machPort, 0) else {
            CFMachPortInvalidate(machPort)
            return nil
        }

        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        return InstalledTap(machPort: machPort, runLoopSource: runLoopSource)
    }

    func resetInstalledResources() {
        for installedTap in self.installedTaps.values {
            CFRunLoopSourceInvalidate(installedTap.runLoopSource)
        }
        self.installedTaps.removeAll()
    }

    func reenableTap(_ kind: Kind) {
        guard let installedTap = self.installedTaps[kind] else { return }
        CGEvent.tapEnable(tap: installedTap.machPort, enable: true)
        self.state = .installed
    }
}

// MARK: - Event Routing
extension EventTap {
    /// Single entry point for both taps. `kind` matters only for disable notifications,
    /// which report the same event type whichever tap the system turned off.
    fileprivate func handleTapCallback(type: CGEventType, event: CGEvent, kind: Kind) {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            self.handleTapDisabled(type, kind: kind)
        case .keyDown, .keyUp:
            self.handleKeyEvent(event)
        case .systemDefined:
            self.handleSystemDefined(event)
        case .flagsChanged:
            self.handleFlagsChanged(event)
        case .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
             .leftMouseDragged, .rightMouseDragged,
             .otherMouseDown, .otherMouseUp, .otherMouseDragged,
             .scrollWheel:
            self.handleMouseEvent(event)
        default:
            break
        }
    }
}

// MARK: - Event Handling
private extension EventTap {
    func handleKeyEvent(_ cgEvent: CGEvent) {
        guard let nsEvent = NSEvent(cgEvent: cgEvent) else { return }
        self.onOutput?(.keystroke(StandardKeyEvent(nsEvent: nsEvent)))
    }

    func handleFlagsChanged(_ cgEvent: CGEvent) {
        let flags = NSEvent.ModifierFlags(cgEventFlags: cgEvent.flags)
        self.onOutput?(.modifierFlags(flags))
    }

    func handleMouseEvent(_ cgEvent: CGEvent) {
        guard let nsEvent = NSEvent(cgEvent: cgEvent) else { return }
        self.onOutput?(.mouse(MouseEvent(nsEvent: nsEvent, cgEvent: cgEvent)))
    }

    func handleSystemDefined(_ cgEvent: CGEvent) {
        // Media keys arrive as system-defined events with the aux-control-buttons subtype.
        // Other system-defined subtypes (screen changes, etc.) are ignored,
        // and reading `data1` is only safe once the subtype is confirmed.
        guard
            let nsEvent = NSEvent(cgEvent: cgEvent),
            nsEvent.type == .systemDefined,
            nsEvent.subtype.rawValue == NX_SUBTYPE_AUX_CONTROL_BUTTONS
        else {
            return
        }

        self.onOutput?(.mediaKey(MediaKeyEvent(nsEvent: nsEvent)))
    }

    func handleTapDisabled(_ type: CGEventType, kind: Kind) {
        let reason: EventTap.DisableReason
        switch type {
        case .tapDisabledByTimeout:
            reason = .timeout
        case .tapDisabledByUserInput:
            reason = .userInput
        default:
            return
        }
        self.state = .temporarilyDisabled(reason)
        self.reenableTap(kind)
    }
}

// MARK: - C event tap callbacks
// Must be file-scope functions (no captures) to satisfy the @convention(c) requirement,
// so each tap gets a trampoline that supplies its own `Kind`.

private func tapCallback(for kind: EventTap.Kind) -> CGEventTapCallBack {
    switch kind {
    case .key:
        return keyTapCallback
    case .mouseAndFlags:
        return mouseFlagsTapCallback
    }
}

private func keyTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    dispatchTapCallback(type: type, event: event, refcon: refcon, kind: .key)
}

private func mouseFlagsTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    dispatchTapCallback(type: type, event: event, refcon: refcon, kind: .mouseAndFlags)
}

private func dispatchTapCallback(
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?,
    kind: EventTap.Kind
) -> Unmanaged<CGEvent>? {
    if let refcon {
        let tap = Unmanaged<EventTap>.fromOpaque(refcon).takeUnretainedValue()
        tap.handleTapCallback(type: type, event: event, kind: kind)
    }
    return .passUnretained(event)
}
