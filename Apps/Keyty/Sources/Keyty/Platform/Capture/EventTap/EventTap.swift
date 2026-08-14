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
    /// Sends every captured event.
    var onEvent: ((Event) -> Void)?

    /// Send every lifecycle change
    var onStateChanged: ((State) -> Void)?

    private(set) var state: EventTap.State = .idle {
        didSet {
            guard oldValue != self.state else { return }
            self.onStateChanged?(self.state)
        }
    }
    
    private var handle: Handle?

    deinit {
        if self.handle != nil { self.remove() }
    }
}

// MARK: - Public API
extension EventTap {
    func install() throws(EventTap.Error) {
        guard self.handle == nil else { return }

        do {
            self.handle = try Handle(owner: self, eventsOfInterest: Self.eventsOfInterest)
        } catch {
            self.state = .failed(error)
            throw error
        }

        self.state = .installed
    }

    func remove() {
        guard self.state != .idle else { return }
        self.handle?.invalidate()
        self.handle = nil
        self.state = .idle
    }

    func reenable() {
        guard case .disabled = self.state, let handle = self.handle else { return }
        handle.enable()
        self.state = .installed
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
}

// MARK: - Tap Handle
private extension EventTap {
    /// Tap's `CFMachPort` and `CFRunLoopSource`.
    /// 
    /// Owns them for their whole lifetime, so they are always created and invalidated as a unit.
    struct Handle {
        let machPort: CFMachPort
        let runLoopSource: CFRunLoopSource

        /// `owner` is captured unretained as the callback's `userInfo`.
        init(owner: EventTap, eventsOfInterest: CGEventMask) throws(EventTap.Error) {
            guard let machPort = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .listenOnly,
                eventsOfInterest: eventsOfInterest,
                callback: tapCallback,
                userInfo: Unmanaged.passUnretained(owner).toOpaque()
            ) else {
                throw .portCreationFailed
            }

            guard let runLoopSource = CFMachPortCreateRunLoopSource(nil, machPort, 0) else {
                CFMachPortInvalidate(machPort)
                throw .runLoopSourceCreationFailed
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
        self.onEvent?(.keystroke(StandardKeyEvent(nsEvent: nsEvent)))
    }

    func handleFlagsChanged(_ cgEvent: CGEvent) {
        let flags = NSEvent.ModifierFlags(cgEventFlags: cgEvent.flags)
        self.onEvent?(.modifierFlags(flags))
    }

    func handleMouseEvent(_ cgEvent: CGEvent) {
        guard let nsEvent = NSEvent(cgEvent: cgEvent) else { return }
        self.onEvent?(.mouse(MouseEvent(nsEvent: nsEvent, cgEvent: cgEvent)))
    }

    func handleSystemDefined(_ cgEvent: CGEvent) {
        guard
            let nsEvent = NSEvent(cgEvent: cgEvent),
            nsEvent.type == .systemDefined,
            nsEvent.subtype.rawValue == NX_SUBTYPE_AUX_CONTROL_BUTTONS
        else {
            return
        }

        self.onEvent?(.mediaKey(MediaKeyEvent(nsEvent: nsEvent)))
    }

    func handleTapDisabled(_ type: CGEventType) {
        guard let reason = EventTap.DisableReason(eventType: type) else { return }
        self.state = .disabled(reason)
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
