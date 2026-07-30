//
//  KeyboardVisualizer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

final class KeyboardVisualizer {
    private static let trackedModifierFlags: NSEvent.ModifierFlags = [.command, .shift, .option, .control, .function]

    private let visualizerSettings: KeyboardVisualizerSettings
    private let visualizerWindow: KeyboardVisualizerWindow
    private let eventCoordinator = KeycapEventCoordinator<KeyboardVisualizerGroupView, KeycapItem>()
    private var currentModifierFlags: NSEvent.ModifierFlags = []
    private var lastModifierFlags: NSEvent.ModifierFlags = []
    private var hasPendingGroupBreak = false
    
    private var cancellables = Set<AnyCancellable>()

    convenience init() {
        self.init(store: UserDefaultsStore())
    }

    init(store: KeyValueStore) {
        let settings = KeyboardVisualizerSettings(store: store)
        self.visualizerSettings = settings
        self.visualizerWindow = KeyboardVisualizerWindow(settings: settings)
        self.visualizerWindow.onGroupRemoved = { [weak self] group in
            self?.eventCoordinator.removeGroup(group)
        }
        settings.isEnabledChanges
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.clearDisplayState()
            }
            .store(in: &self.cancellables)
    }

    func activate() {
        self.visualizerWindow.orderFront(nil)
    }

    func display(_ item: DisplayItem) {
        guard self.visualizerSettings.isEnabled else {
            self.clearDisplayState()
            return
        }

        if item.kind == .flagsChanged {
            self.currentModifierFlags = item.modifierFlags
            self.displayModifierPreview(item.modifierFlags)
            if self.hasPendingGroupBreak && self.currentTrackedFlags.isEmpty {
                self.finishCurrentGroup(retaining: [])
            }
            return
        }

        if item.kind == .groupBreak {
            if self.currentTrackedFlags.isEmpty {
                self.finishCurrentGroup(retaining: [])
            } else {
                self.hasPendingGroupBreak = true
            }
            return
        }

        guard let sourceEvent = item.sourceEvent else { return }
        switch sourceEvent {
        case .mouse(let mouseEvent):
            guard self.visualizerSettings.showMouseEvents else { return }
            self.prepareForNextContentEvent()

            let modifierItems = KeycapItemFactory.modifierItems(
                currentFlags: mouseEvent.modifierFlags,
                releasedFlags: [],
                palette: self.visualizerSettings.palette
            )
            let keycap = KeycapItemFactory.mouseItem(for: mouseEvent, palette: self.visualizerSettings.palette)
            self.eventCoordinator.handleMouseButton(
                kind: mouseEvent.kind,
                isPressed: keycap.isPressed,
                items: modifierItems + [keycap],
                appendGroup: { self.visualizerWindow.appendGroup(with: $0) },
                updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
            )
            return

        case .mediaKey(let mediaKey):
            guard self.visualizerSettings.showMediaKeyButtons else { return }
            self.prepareForNextContentEvent()

            let keycap = KeycapItemFactory.mediaKeyItem(for: mediaKey, palette: self.visualizerSettings.palette)
            self.eventCoordinator.handleStandalone(
                items: [keycap],
                appendGroup: { self.visualizerWindow.appendGroup(with: $0) },
                updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
            )
            return

        case .keystroke(let keystroke):
            self.displayKeystroke(keystroke)
            return
        }
    }

    private func displayKeystroke(_ keystroke: StandardKeyEvent) {
        // Track command/shift/option/control exclusively through flagsChanged so a modifier
        // release does not create a separate keystroke group after the chord ends.
        if KeyboardGlyphCatalog.isModifierKeyCode(keystroke.keyCode) {
            return
        }

        if self.visualizerSettings.onlyShowModifiedKeystrokes && !keystroke.isModified {
            return
        }

        if !self.visualizerSettings.showSpecialKeys,
           KeyboardSpecialKeyResolver.isSpecial(keystroke) {
            return
        }

        let items = KeycapItemFactory.keycapItems(for: keystroke, palette: self.visualizerSettings.palette)
        guard !items.isEmpty else { return }

        self.prepareForNextContentEvent()

        self.eventCoordinator.handleTrackedKey(
            keyCode: keystroke.keyCode,
            isKeyDown: keystroke.type != .keyUp,
            items: items,
            appendGroup: { self.visualizerWindow.appendGroup(with: $0) },
            updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
        )
    }

    private func displayModifierPreview(_ modifierFlags: NSEvent.ModifierFlags) {
        let currentTrackedFlags = modifierFlags.intersection(Self.trackedModifierFlags)
        let previousTrackedFlags = self.lastModifierFlags.intersection(Self.trackedModifierFlags)
        let releasedTrackedFlags = previousTrackedFlags.subtracting(currentTrackedFlags)
        let releasedModifierFlags = self.lastModifierFlags.subtracting(modifierFlags)

        // Caps Lock: one-shot flash, lit when turning on, dim when turning off
        let capsNow = modifierFlags.contains(.capsLock)
        let capsWas = self.lastModifierFlags.contains(.capsLock)
        if self.visualizerSettings.showSpecialKeys, capsNow != capsWas {
            self.eventCoordinator.handleStandalone(
                items: [KeycapItem(
                    identity: .keyCode(KeyboardKeyCode.capsLock.rawValue),
                    legend: .capsLock,
                    state: KeycapState(isPressed: false, showsDot: true, isDotActive: capsNow),
                    layoutHints: KeycapLayoutHints(alignment: .left),
                    appearance: self.visualizerSettings.palette.appearance(for: .keyCode(KeyboardKeyCode.capsLock.rawValue))
                )],
                appendGroup: { self.visualizerWindow.appendGroup(with: $0) },
                updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
            )
        }

        self.lastModifierFlags = modifierFlags

        let items = KeycapItemFactory.modifierItems(
            currentFlags: modifierFlags,
            releasedFlags: releasedModifierFlags,
            palette: self.visualizerSettings.palette
        )
        guard !items.isEmpty else {
            if currentTrackedFlags.isEmpty {
                self.eventCoordinator.reset()
            }
            return
        }

        self.eventCoordinator.handleFlagsChanged(
            currentTrackedFlags: currentTrackedFlags,
            releasedTrackedFlags: releasedTrackedFlags,
            buildItems: { _, _ in
                KeycapItemFactory.modifierItems(
                    currentFlags: modifierFlags,
                    releasedFlags: releasedModifierFlags,
                    palette: self.visualizerSettings.palette
                )
            },
            appendGroup: { visualizerWindow.appendGroup(with: $0) },
            updateGroup: { group, items in visualizerWindow.updateGroup(group, with: items) }
        )
    }

    private func prepareForNextContentEvent() {
        guard self.hasPendingGroupBreak else { return }
        self.finishCurrentGroup(retaining: self.currentModifierFlags)
    }

    private func finishCurrentGroup(retaining modifierFlags: NSEvent.ModifierFlags) {
        self.eventCoordinator.reset()
        self.lastModifierFlags = modifierFlags
        self.hasPendingGroupBreak = false
    }

    private func clearDisplayState() {
        self.eventCoordinator.reset()
        self.currentModifierFlags = []
        self.lastModifierFlags = []
        self.hasPendingGroupBreak = false
        self.visualizerWindow.removeAllGroups()
    }

    private var currentTrackedFlags: NSEvent.ModifierFlags {
        self.currentModifierFlags.intersection(Self.trackedModifierFlags)
    }
}
