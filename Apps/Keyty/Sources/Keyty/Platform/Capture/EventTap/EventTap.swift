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

    /// Non-nil exactly while the tap is installed. `state` cannot stand in for this:
    /// it reports `.temporarilyDisabled` while the tap is still installed.
    private var handle: Handle?

    deinit {
        if self.handle != nil { self.remove() }
    }
}

// MARK: - Public API
extension EventTap {
    func install() throws(EventTap.Error) {
        guard self.handle == nil else { return }

        guard let handle = Handle(
            owner: self,
            eventsOfInterest: Self.eventsOfInterest
        ) else {
            self.state = .failed(.creationFailed)
            throw .creationFailed
        }

        self.handle = handle
        self.state = .installed
    }

    func remove() {
        guard self.state != .idle else { return }
        self.handle?.invalidate()
        self.handle = nil
        self.state = .idle
    }
}

// MARK: - Tap Resources
private extension EventTap {
    /// Every event type the app visualizes. Creation fails as a whole when the
    /// Accessibility grant is missing, so a `nil` port is a truthful capability signal.
    static let eventsOfInterest: CGEventMask = [
        .keyDown, .keyUp, .systemDefined, .flagsChanged,
        .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
        .leftMouseDragged, .rightMouseDragged,
        .otherMouseDown, .otherMouseUp, .otherMouseDragged,
        .scrollWheel
    ].eventMask

    func reenableTap() {
        guard let handle = self.handle else { return }
        handle.enable()
        self.state = .installed
    }
}

// MARK: - Tap Handle
private extension EventTap {
    /// The tap's mach port and its run loop source. Owns both for their whole lifetime,
    /// so they are always created and invalidated as a unit.
    struct Handle {
        let machPort: CFMachPort
        let runLoopSource: CFRunLoopSource

        /// Fails when the tap cannot be created, which is how a missing Accessibility
        /// grant surfaces. `owner` is captured unretained as the callback's `userInfo`.
        init?(owner: EventTap, eventsOfInterest: CGEventMask) {
            guard let machPort = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .listenOnly,
                eventsOfInterest: eventsOfInterest,
                callback: tapCallback,
                userInfo: Unmanaged.passUnretained(owner).toOpaque()
            ) else {
                return nil
            }

            guard let runLoopSource = CFMachPortCreateRunLoopSource(nil, machPort, 0) else {
                CFMachPortInvalidate(machPort)
                return nil
            }

            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.machPort = machPort
            self.runLoopSource = runLoopSource
        }

        func invalidate() {
            CFRunLoopSourceInvalidate(self.runLoopSource)
            CFMachPortInvalidate(self.machPort)
        }

        func enable() {
            CGEvent.tapEnable(tap: self.machPort, enable: true)
        }
    }
}

// MARK: - Event Routing
extension EventTap {
    fileprivate func handleTapCallback(type: CGEventType, event: CGEvent) {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            self.handleTapDisabled(type)
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

    func handleTapDisabled(_ type: CGEventType) {
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
        self.reenableTap()
    }
}

// MARK: - C event tap callback
private func tapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if let refcon {
        let tap = Unmanaged<EventTap>.fromOpaque(refcon).takeUnretainedValue()
        tap.handleTapCallback(type: type, event: event)
    }
    return .passUnretained(event)
}
