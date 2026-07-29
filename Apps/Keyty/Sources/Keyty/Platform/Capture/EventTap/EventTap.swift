//
//  EventTap.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa
import IOKit.hidsystem

protocol EventTapDelegate: AnyObject {
    func eventTap(_ tap: EventTap, noteKeystroke keystroke: StandardKeyEvent)
    func eventTap(_ tap: EventTap, noteMouseEvent mouseEvent: MouseEvent)
    func eventTap(_ tap: EventTap, noteFlagsChanged flags: NSEvent.ModifierFlags)
    func eventTap(_ tap: EventTap, noteMediaKey mediaKey: MediaKeyEvent)
    func eventTap(_ tap: EventTap, didChangeState state: EventTap.State)
}

final class EventTap {
    private(set) var state: EventTap.State = .idle {
        didSet {
            guard oldValue != self.state else { return }
            self.delegate?.eventTap(self, didChangeState: self.state)
        }
    }

    var isInstalled: Bool {
        if case .installed = state {
            return true
        }
        return false
    }

    private var keyEventTap: CFMachPort?
    private var mouseAndFlagsEventTap: CFMachPort?
    
    private var keyEventTapSource: CFRunLoopSource?
    private var mouseAndFlagsEventTapSource: CFRunLoopSource?
    
    weak var delegate: EventTapDelegate?

    deinit {
        if self.isInstalled { self.remove() }
    }

    // MARK: - Public

    func install() throws(EventTap.Error) {
        guard !self.isInstalled else { return }

        // We have to try to tap the keydown event independently because CGEventTapCreate will
        // succeed if it can install the event tap for the flags changed event, which apparently
        // doesn't require universal access to be enabled. Thus, the call would succeed but
        // Keyty would be, um, useless.
        self.keyEventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: cgEventMask(.keyDown, .keyUp, .systemDefined),
            callback: keyTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        guard self.keyEventTap != nil else {
            self.state = .failed(.keyTapCreationFailed)
            throw EventTap.Error.keyTapCreationFailed
        }

        self.mouseAndFlagsEventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: cgEventMask(.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
                                          .leftMouseDragged, .rightMouseDragged,
                                          .flagsChanged,
                                          .otherMouseDown, .otherMouseUp, .otherMouseDragged,
                                          .scrollWheel),
            callback: mouseFlagsTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        guard self.mouseAndFlagsEventTap != nil else {
            self.resetInstalledResources()
            self.state = .failed(.mouseAndFlagsTapCreationFailed)
            throw EventTap.Error.mouseAndFlagsTapCreationFailed
        }

        self.keyEventTapSource = CFMachPortCreateRunLoopSource(nil, self.keyEventTap, 0)
        self.mouseAndFlagsEventTapSource = CFMachPortCreateRunLoopSource(nil, self.mouseAndFlagsEventTap, 0)

        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopAddSource(runLoop, self.keyEventTapSource, .commonModes)
        CFRunLoopAddSource(runLoop, self.mouseAndFlagsEventTapSource, .commonModes)

        self.state = .installed
    }

    func remove() {
        guard self.state != .idle else { return }
        self.resetInstalledResources()
        self.state = .idle
    }

    // MARK: - Fileprivate (called from C callbacks)

    fileprivate func handleKeyEvent(_ cgEvent: CGEvent) {
        guard let nsEvent = NSEvent(cgEvent: cgEvent) else { return }
        self.delegate?.eventTap(self, noteKeystroke: StandardKeyEvent(nsEvent: nsEvent))
    }

    fileprivate func handleFlagsChanged(_ cgEvent: CGEvent) {
        let flags = NSEvent.ModifierFlags(cgEventFlags: cgEvent.flags)
        self.delegate?.eventTap(self, noteFlagsChanged: flags)
    }

    fileprivate func handleMouseEvent(_ cgEvent: CGEvent) {
        guard let nsEvent = NSEvent(cgEvent: cgEvent) else { return }
        self.delegate?.eventTap(self, noteMouseEvent: MouseEvent(nsEvent: nsEvent, cgEvent: cgEvent))
    }

    fileprivate func handleSystemDefined(_ cgEvent: CGEvent) {
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
        
        self.delegate?.eventTap(self, noteMediaKey: MediaKeyEvent(nsEvent: nsEvent))
    }

    fileprivate func handleTapDisabled(_ type: CGEventType, kind: EventTap.TapKind) {
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

    private func reenableTap(_ kind: EventTap.TapKind) {
        let machPort: CFMachPort?
        switch kind {
        case .key:
            machPort = self.keyEventTap
        case .mouseAndFlags:
            machPort = self.mouseAndFlagsEventTap
        }

        guard let machPort else { return }
        CGEvent.tapEnable(tap: machPort, enable: true)
        self.state = .installed
    }

    private func resetInstalledResources() {
        if let keyEventTapSource = self.keyEventTapSource {
            CFRunLoopSourceInvalidate(keyEventTapSource)
        }
        if let mouseAndFlagsEventTapSource = self.mouseAndFlagsEventTapSource {
            CFRunLoopSourceInvalidate(mouseAndFlagsEventTapSource)
        }

        self.keyEventTapSource = nil
        self.mouseAndFlagsEventTapSource = nil
        self.keyEventTap = nil
        self.mouseAndFlagsEventTap = nil
    }
}

// MARK: - CGEventMask helper

private func cgEventMask(_ types: CGEventType...) -> CGEventMask {
    types.reduce(0) { $0 | CGEventMask(1 << $1.rawValue) }
}

// MARK: - C event tap callbacks
// Must be file-scope functions (no captures) to satisfy @convention(c) requirement.

private func keyTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if let refcon {
        let tap = Unmanaged<EventTap>.fromOpaque(refcon).takeUnretainedValue()
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            tap.handleTapDisabled(type, kind: .key)
        } else if [.keyDown, .keyUp].contains(type) {
            tap.handleKeyEvent(event)
        } else if type == .systemDefined {
            tap.handleSystemDefined(event)
        }
    }
    return .passUnretained(event)
}

private func mouseFlagsTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if let refcon {
        let tap = Unmanaged<EventTap>.fromOpaque(refcon).takeUnretainedValue()
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            tap.handleTapDisabled(type, kind: .mouseAndFlags)
        case .leftMouseDown, .rightMouseDown, .leftMouseUp, .rightMouseUp,
             .leftMouseDragged, .rightMouseDragged,
             .otherMouseDown, .otherMouseUp, .otherMouseDragged,
             .scrollWheel:
            tap.handleMouseEvent(event)
        case .flagsChanged:
            tap.handleFlagsChanged(event)
        default:
            break
        }
    }
    return .passUnretained(event)
}
