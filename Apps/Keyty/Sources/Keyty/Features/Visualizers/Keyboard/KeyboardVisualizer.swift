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
    private static let trackedModifierFlags: NSEvent.ModifierFlags = [.command, .shift, .option, .control]

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
    private var lastFinalizedGroup: FinalizedGroup?

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
            self?.clearFinalizedGroupIfNeeded(for: group)
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
}

extension KeyboardVisualizer {
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
            let group = self.eventCoordinator.handleMouseButton(
                kind: mouseEvent.kind,
                isPressed: keycap.isPressed,
                items: modifierItems + [keycap],
                appendGroup: { self.visualizerWindow.appendGroup(with: $0, defersMaxCount: self.visualizerSettings.collapseRepeatedGroups) },
                updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
            )
            self.collapseActiveRepeatIfNeeded(group)
            if !keycap.isPressed, mouseEvent.modifierFlags.intersection(Self.trackedModifierFlags).isEmpty {
                self.finalizeGroupIfNeeded(group)
            }
            return

        case .mediaKey(let mediaKey):
            guard self.visualizerSettings.showMediaKeyButtons else { return }
            self.prepareForNextContentEvent()

            let keycap = KeycapItemFactory.mediaKeyItem(for: mediaKey, palette: self.visualizerSettings.palette)
            let group = self.eventCoordinator.handleMediaKey(
                kind: mediaKey.kind,
                isPressed: keycap.isPressed,
                items: [keycap],
                appendGroup: { self.visualizerWindow.appendGroup(with: $0, defersMaxCount: self.visualizerSettings.collapseRepeatedGroups) },
                updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
            )
            self.collapseActiveRepeatIfNeeded(group)
            if !keycap.isPressed {
                self.finalizeGroupIfNeeded(group)
            }
            return

        case .keystroke(let keystroke):
            self.displayKeystroke(keystroke)
            return
        }
    }
}

// MARK: - Event Display
private extension KeyboardVisualizer {
    private func displayKeystroke(_ keystroke: StandardKeyEvent) {
        // Track modifier-driven keys exclusively through flagsChanged so a modifier
        // release does not create a separate keystroke group after the chord ends.
        if KeyboardKeyCode.isFlagsChangedDriven(keystroke.keyCode) {
            return
        }

        let isSpecialKey = KeyboardSpecialKeyResolver.isSpecial(keystroke)

        if !self.visualizerSettings.showSpecialKeys, isSpecialKey {
            return
        }

        if self.visualizerSettings.onlyShowModifiedKeystrokes && !keystroke.isModified && !isSpecialKey {
            return
        }

        let legend = self.legendResolver.legend(for: .keystroke(keystroke))
        let items = KeycapItemFactory.keycapItems(
            keyCode: keystroke.keyCode,
            legend: legend,
            modifierFlags: keystroke.modifierFlags.subtracting(.function),
            isPressed: keystroke.type != .keyUp,
            palette: self.visualizerSettings.palette
        )
        guard !items.isEmpty else { return }

        self.prepareForNextContentEvent()

        let group = self.eventCoordinator.handleTrackedKey(
            keyCode: keystroke.keyCode,
            isKeyDown: keystroke.type != .keyUp,
            items: items,
            appendGroup: { self.visualizerWindow.appendGroup(with: $0, defersMaxCount: self.visualizerSettings.collapseRepeatedGroups) },
            updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
        )
        self.collapseActiveRepeatIfNeeded(group)
        if keystroke.type == .keyUp, keystroke.modifierFlags.intersection(Self.trackedModifierFlags).isEmpty {
            self.finalizeGroupIfNeeded(group)
        }
    }

    private func displayModifierPreview(_ modifierFlags: NSEvent.ModifierFlags) {
        let currentTrackedFlags = modifierFlags.intersection(Self.trackedModifierFlags)
        let previousTrackedFlags = self.lastModifierFlags.intersection(Self.trackedModifierFlags)
        let releasedTrackedFlags = previousTrackedFlags.subtracting(currentTrackedFlags)
        let releasedModifierFlags = self.lastModifierFlags.subtracting(modifierFlags)
        let functionNow = modifierFlags.contains(.function)
        let functionWas = self.lastModifierFlags.contains(.function)

        // Caps Lock: one-shot flash, lit when turning on, dim when turning off
        let capsNow = modifierFlags.contains(.capsLock)
        let capsWas = self.lastModifierFlags.contains(.capsLock)
        if self.visualizerSettings.showSpecialKeys, capsNow != capsWas {
            let group = self.eventCoordinator.handleStandalone(
                items: [KeycapItem(
                    identity: .keyCode(KeyboardKeyCode.capsLock.rawValue),
                    legend: .capsLock,
                    state: KeycapState(isPressed: false, showsDot: true, isDotActive: capsNow),
                    layoutHints: KeycapLayoutHints(alignment: .left),
                    appearance: self.visualizerSettings.palette.appearance(for: .keyCode(KeyboardKeyCode.capsLock.rawValue))
                )],
                appendGroup: { self.visualizerWindow.appendGroup(with: $0, defersMaxCount: self.visualizerSettings.collapseRepeatedGroups) },
                updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
            )
            self.collapseActiveRepeatIfNeeded(group)
            self.finalizeGroupIfNeeded(group)
        }

        if self.visualizerSettings.showSpecialKeys, functionNow != functionWas {
            let group = self.eventCoordinator.handleIndependentTrackedKey(
                keyCode: KeyboardKeyCode.function.rawValue,
                isKeyDown: functionNow,
                items: [self.functionKeycapItem(isPressed: functionNow)],
                appendGroup: { self.visualizerWindow.appendGroup(with: $0, defersMaxCount: self.visualizerSettings.collapseRepeatedGroups) },
                updateGroup: { group, items in self.visualizerWindow.updateGroup(group, with: items) }
            )
            self.collapseActiveRepeatIfNeeded(group)
            if !functionNow {
                self.finalizeGroupIfNeeded(group)
            }
        }

        self.lastModifierFlags = modifierFlags

        let items = KeycapItemFactory.modifierItems(
            currentFlags: modifierFlags,
            releasedFlags: releasedModifierFlags,
            palette: self.visualizerSettings.palette
        )
        guard !items.isEmpty else {
            if currentTrackedFlags.isEmpty, !functionNow {
                self.eventCoordinator.reset()
            }
            return
        }

        let group = self.eventCoordinator.handleFlagsChanged(
            currentTrackedFlags: currentTrackedFlags,
            releasedTrackedFlags: releasedTrackedFlags,
            buildItems: { _, _ in
                KeycapItemFactory.modifierItems(
                    currentFlags: modifierFlags,
                    releasedFlags: releasedModifierFlags,
                    palette: self.visualizerSettings.palette
                )
            },
            appendGroup: { visualizerWindow.appendGroup(with: $0, defersMaxCount: self.visualizerSettings.collapseRepeatedGroups) },
            updateGroup: { group, items in visualizerWindow.updateGroup(group, with: items) }
        )
        self.collapseActiveRepeatIfNeeded(group)
        if currentTrackedFlags.isEmpty {
            self.finalizeGroupIfNeeded(group)
        }
    }

    private func functionKeycapItem(isPressed: Bool) -> KeycapItem {
        KeycapItemFactory.keycapItems(
            keyCode: KeyboardKeyCode.function.rawValue,
            legend: EventLegend(
                text: KeyboardSpecialKey.function.displayText,
                label: KeyboardSpecialKey.function.label
            ),
            modifierFlags: [],
            isPressed: isPressed,
            palette: self.visualizerSettings.palette
        ).first!
    }
}

// MARK: - State
private extension KeyboardVisualizer {
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
        self.lastFinalizedGroup = nil
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

// MARK: - Repeat Collapse Models
private extension KeyboardVisualizer {
    /// Tracks the last completed visible group and its repeat count for collapse decisions.
    struct FinalizedGroup {
        let group: KeyboardVisualizerGroupView
        let identity: GroupIdentity
        let repeatCount: Int
    }

    /// Semantic identity of a rendered group, used to detect consecutive repeats.
    struct GroupIdentity: Hashable {
        let items: [ItemIdentity]
    }

    /// Stable comparison shape for a rendered keycap within a grouped overlay.
    struct ItemIdentity: Hashable {
        let identity: KeycapIdentity
        let symbol: String
        let imageBadgeText: String?
        let sfSymbolName: String?
        let label: String?
        let rendersSymbolWithLabel: Bool
        let fixedWidth: CGFloat?
    }
}

// MARK: - Repeat Collapse
private extension KeyboardVisualizer {
    func finalizeGroupIfNeeded(_ group: KeyboardVisualizerGroupView?) {
        guard let group else { return }
        let items = self.eventCoordinator.items(for: group)
        guard !items.isEmpty else { return }

        let identity = self.groupIdentity(for: items)

        guard self.visualizerSettings.collapseRepeatedGroups else {
            self.lastFinalizedGroup = FinalizedGroup(group: group, identity: identity, repeatCount: 1)
            self.visualizerWindow.enforceMaxCount()
            return
        }

        if let previous = self.lastFinalizedGroup, previous.group === group {
            let repeatCount = previous.identity == identity ? previous.repeatCount : 1
            self.lastFinalizedGroup = FinalizedGroup(group: group, identity: identity, repeatCount: repeatCount)
            self.visualizerWindow.enforceMaxCount()
            return
        }

        guard let previous = self.lastFinalizedGroup,
              previous.group !== group,
              previous.identity == identity else {
            self.lastFinalizedGroup = FinalizedGroup(group: group, identity: identity, repeatCount: 1)
            self.visualizerWindow.enforceMaxCount()
            return
        }

        let nextRepeatCount = previous.repeatCount + 1
        self.visualizerWindow.updateRepeatCount(nextRepeatCount, for: previous.group)
        self.visualizerWindow.removeGroup(group)
        self.lastFinalizedGroup = FinalizedGroup(group: previous.group, identity: identity, repeatCount: nextRepeatCount)
        self.visualizerWindow.enforceMaxCount()
    }

    func collapseActiveRepeatIfNeeded(_ group: KeyboardVisualizerGroupView?) {
        guard self.visualizerSettings.collapseRepeatedGroups, let group else { return }
        guard let previous = self.lastFinalizedGroup, previous.group !== group else { return }

        let items = self.eventCoordinator.items(for: group)
        guard !items.isEmpty else { return }

        let identity = self.groupIdentity(for: items)
        guard previous.identity == identity else { return }

        let nextRepeatCount = previous.repeatCount + 1
        self.visualizerWindow.updateGroup(previous.group, with: items, repeatCount: nextRepeatCount)
        self.eventCoordinator.replaceGroup(group, with: previous.group, items: items)
        self.visualizerWindow.removeGroup(group)
        self.lastFinalizedGroup = FinalizedGroup(group: previous.group, identity: identity, repeatCount: nextRepeatCount)
        self.visualizerWindow.enforceMaxCount()
    }

    func clearFinalizedGroupIfNeeded(for group: KeyboardVisualizerGroupView) {
        guard self.lastFinalizedGroup?.group === group else { return }
        self.lastFinalizedGroup = nil
    }

    func groupIdentity(for items: [KeycapItem]) -> GroupIdentity {
        GroupIdentity(items: items.map {
            ItemIdentity(
                identity: $0.identity,
                symbol: $0.symbol,
                imageBadgeText: $0.imageBadgeText,
                sfSymbolName: $0.sfSymbolName,
                label: $0.label,
                rendersSymbolWithLabel: $0.rendersSymbolWithLabel,
                fixedWidth: $0.fixedWidth
            )
        })
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
