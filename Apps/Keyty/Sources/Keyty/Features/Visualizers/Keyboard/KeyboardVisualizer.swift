//
//  KeyboardVisualizer.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Carbon
import Combine

final class KeyboardVisualizer {
    private static let trackedModifierFlags: NSEvent.ModifierFlags = [.command, .shift, .option, .control, .function]

    var isPresentationActive: Bool = false {
        didSet {
            self.updatePresentationState()
        }
    }

    var isPresented: Bool {
        self.visualizerWindow.isVisible
    }

    var visibleGroupCount: Int {
        self.visualizerWindow.groupCount
    }

    private let visualizerSettings: KeyboardVisualizerSettings
    private let visualizerWindow: KeyboardVisualizerWindow
    private let eventCoordinator = KeycapEventCoordinator<KeyboardVisualizerGroupView, KeycapItem>()

    // Rebuilt only when the selected keyboard layout changes.
    private var cachedLegendResolver: (source: TISInputSource, resolver: EventLegendResolver)?
    private var cancellables = Set<AnyCancellable>()
    private var currentModifierFlags: NSEvent.ModifierFlags = []
    private var lastModifierFlags: NSEvent.ModifierFlags = []
    private var hasPendingGroupBreak = false

    convenience init() {
        self.init(store: UserDefaultsStore())
    }

    convenience init(store: KeyValueStore) {
        self.init(settings: KeyboardVisualizerSettings(store: store))
    }

    init(settings: KeyboardVisualizerSettings) {
        self.visualizerSettings = settings
        self.visualizerWindow = KeyboardVisualizerWindow(settings: settings)
        self.visualizerWindow.onGroupRemoved = { [weak self] group in
            self?.eventCoordinator.removeGroup(group)
        }
        settings.isEnabledChanges
            .sink { [weak self] isEnabled in
                guard let self else { return }
                if !isEnabled {
                    self.clearDisplayState()
                }
                self.updatePresentationState()
            }
            .store(in: &self.cancellables)
    }

    func activate() {
        self.updatePresentationState()
    }

    func display(_ item: DisplayEvent) {
        guard self.visualizerSettings.isEnabled, self.isPresentationActive else {
            self.clearDisplayState()
            return
        }

        switch item {
        case .modifierStateChanged(let modifierFlags):
            self.currentModifierFlags = modifierFlags
            self.displayModifierPreview(modifierFlags)
            if self.hasPendingGroupBreak && self.currentTrackedFlags.isEmpty {
                self.finishCurrentGroup(retaining: [])
            }
            return

        case .groupBreak:
            if self.currentTrackedFlags.isEmpty {
                self.finishCurrentGroup(retaining: [])
            } else {
                self.hasPendingGroupBreak = true
            }
            return

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
            self.eventCoordinator.handleMediaKey(
                kind: mediaKey.kind,
                isPressed: keycap.isPressed,
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

        let items = KeycapItemFactory.keycapItems(
            for: keystroke,
            legend: self.legendResolver.legend(for: .keystroke(keystroke)),
            palette: self.visualizerSettings.palette
        )
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

    private func updatePresentationState() {
        guard self.visualizerSettings.isEnabled, self.isPresentationActive else {
            self.clearDisplayState()
            self.visualizerWindow.orderOut(nil)
            return
        }
        self.visualizerWindow.orderFront(nil)
    }

    private var currentTrackedFlags: NSEvent.ModifierFlags {
        self.currentModifierFlags.intersection(Self.trackedModifierFlags)
    }
}

// MARK: - Legend Resolution
private extension KeyboardVisualizer {
    var legendResolver: EventLegendResolver {
        let source = KeyboardInputSourceManager.shared.currentInputSource
        if let cached = self.cachedLegendResolver, cached.source === source {
            return cached.resolver
        }

        let resolver = EventLegendResolver(keyboardLayout: source)
        self.cachedLegendResolver = (source, resolver)
        return resolver
    }
}
