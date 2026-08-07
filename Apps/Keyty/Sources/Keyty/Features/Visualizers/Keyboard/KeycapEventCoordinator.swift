//
//  KeycapEventCoordinator.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

protocol KeycapGroupItem {
    var identity: KeycapIdentity { get }
}

final class KeycapEventCoordinator<GroupView: AnyObject, Item: KeycapGroupItem> {
    private enum TrackedButtonIdentifier: Hashable {
        case mouse(MouseEvent.Kind)
        case media(MediaKeyEvent.Kind)
    }

    private var pendingModifierGroup: GroupView?
    private var completedModifierGroup: GroupView?
    private var activeKeyGroups: [UInt16: GroupView] = [:]
    private var activeButtonGroups: [TrackedButtonIdentifier: GroupView] = [:]
    private var groupItems: [ObjectIdentifier: [Item]] = [:]

    func reset() {
        self.pendingModifierGroup = nil
        self.completedModifierGroup = nil
        self.activeKeyGroups.removeAll(keepingCapacity: true)
        self.activeButtonGroups.removeAll(keepingCapacity: true)
        self.groupItems.removeAll(keepingCapacity: true)
    }

    func removeGroup(_ group: GroupView) {
        if self.pendingModifierGroup === group {
            self.pendingModifierGroup = nil
        }
        if self.completedModifierGroup === group {
            self.completedModifierGroup = nil
        }
        self.activeKeyGroups = self.activeKeyGroups.filter { $0.value !== group }
        self.activeButtonGroups = self.activeButtonGroups.filter { $0.value !== group }
        self.groupItems[ObjectIdentifier(group)] = nil
    }

    func handleFlagsChanged(
        currentTrackedFlags: NSEvent.ModifierFlags,
        releasedTrackedFlags: NSEvent.ModifierFlags,
        buildItems: (NSEvent.ModifierFlags, NSEvent.ModifierFlags) -> [Item],
        appendGroup: ([Item]) -> GroupView,
        updateGroup: (GroupView, [Item]) -> Void
    ) {
        let items = buildItems(currentTrackedFlags, releasedTrackedFlags)
        guard !items.isEmpty else {
            if currentTrackedFlags.isEmpty {
                self.pendingModifierGroup = nil
                self.completedModifierGroup = nil
            }
            return
        }

        if let pendingModifierGroup, self.canAppendModifiers(to: pendingModifierGroup) {
            let merged = self.ordered(items: self.merged(items: items, into: self.storedItems(for: pendingModifierGroup)))
            self.groupItems[ObjectIdentifier(pendingModifierGroup)] = merged
            updateGroup(pendingModifierGroup, merged)
            self.completedModifierGroup = pendingModifierGroup
        } else if let completedModifierGroup, self.canRefreshModifiers(in: completedModifierGroup, with: items) {
            let merged = self.ordered(items: self.merged(items: items, into: self.storedItems(for: completedModifierGroup)))
            self.groupItems[ObjectIdentifier(completedModifierGroup)] = merged
            updateGroup(completedModifierGroup, merged)
        } else {
            let orderedItems = self.ordered(items: items)
            let group = appendGroup(orderedItems)
            self.groupItems[ObjectIdentifier(group)] = orderedItems
            self.pendingModifierGroup = group
            self.completedModifierGroup = group
        }

        if currentTrackedFlags.isEmpty {
            self.pendingModifierGroup = nil
            self.completedModifierGroup = nil
        }
    }

    func handleTrackedKey(
        keyCode: UInt16,
        isKeyDown: Bool,
        items: [Item],
        appendGroup: ([Item]) -> GroupView,
        updateGroup: (GroupView, [Item]) -> Void
    ) {
        guard !items.isEmpty else { return }

        if let activeGroup = self.activeKeyGroups[keyCode] {
            let existingItems = self.storedItems(for: activeGroup)
            let permittedItems = self.permittedTrackedKeyItems(items, forExistingItems: existingItems)
            let merged = self.ordered(items: self.merged(items: permittedItems, into: existingItems))
            self.groupItems[ObjectIdentifier(activeGroup)] = merged
            updateGroup(activeGroup, merged)
            self.pendingModifierGroup = activeGroup
            self.completedModifierGroup = activeGroup
            if !isKeyDown {
                self.activeKeyGroups[keyCode] = nil
            }
            return
        }

        if let pendingModifierGroup, self.canAbsorbIntoPendingChord(pendingModifierGroup) {
            let merged = self.ordered(items: self.merged(items: items, into: self.storedItems(for: pendingModifierGroup)))
            self.groupItems[ObjectIdentifier(pendingModifierGroup)] = merged
            updateGroup(pendingModifierGroup, merged)
            self.pendingModifierGroup = pendingModifierGroup
            self.completedModifierGroup = pendingModifierGroup
            self.activeKeyGroups[keyCode] = pendingModifierGroup
            if !isKeyDown {
                self.activeKeyGroups[keyCode] = nil
            }
            return
        }

        let orderedItems = self.ordered(items: items)
        let group = appendGroup(orderedItems)
        self.groupItems[ObjectIdentifier(group)] = orderedItems
        self.pendingModifierGroup = group
        self.completedModifierGroup = group
        if isKeyDown {
            self.activeKeyGroups[keyCode] = group
        }
    }

    func handleMouseButton(
        kind: MouseEvent.Kind,
        isPressed: Bool,
        items: [Item],
        appendGroup: ([Item]) -> GroupView,
        updateGroup: (GroupView, [Item]) -> Void
    ) {
        self.handleTrackedButton(
            identifier: .mouse(kind),
            isPressed: isPressed,
            items: items,
            appendGroup: appendGroup,
            updateGroup: updateGroup
        )
    }

    func handleStandalone(
        items: [Item],
        appendGroup: ([Item]) -> GroupView,
        updateGroup: (GroupView, [Item]) -> Void
    ) {
        guard !items.isEmpty else { return }

        if let pendingModifierGroup, self.canAbsorbIntoPendingChord(pendingModifierGroup) {
            let merged = self.ordered(items: self.merged(items: items, into: self.storedItems(for: pendingModifierGroup)))
            self.groupItems[ObjectIdentifier(pendingModifierGroup)] = merged
            updateGroup(pendingModifierGroup, merged)
            self.completedModifierGroup = pendingModifierGroup
            return
        }

        let group = appendGroup(items)
        self.groupItems[ObjectIdentifier(group)] = items
    }

    func handleMediaKey(
        kind: MediaKeyEvent.Kind,
        isPressed: Bool,
        items: [Item],
        appendGroup: ([Item]) -> GroupView,
        updateGroup: (GroupView, [Item]) -> Void
    ) {
        self.handleTrackedButton(
            identifier: .media(kind),
            isPressed: isPressed,
            items: items,
            appendGroup: appendGroup,
            updateGroup: updateGroup
        )
    }
}

// MARK: - Private API
private extension KeycapEventCoordinator {
    private func storedItems(for group: GroupView) -> [Item] {
        self.groupItems[ObjectIdentifier(group)] ?? []
    }

    private func handleTrackedButton(
        identifier: TrackedButtonIdentifier,
        isPressed: Bool,
        items: [Item],
        appendGroup: ([Item]) -> GroupView,
        updateGroup: (GroupView, [Item]) -> Void
    ) {
        guard !items.isEmpty else { return }

        if let activeGroup = self.activeButtonGroups[identifier] {
            let merged = self.ordered(items: self.merged(items: items, into: self.storedItems(for: activeGroup)))
            self.groupItems[ObjectIdentifier(activeGroup)] = merged
            updateGroup(activeGroup, merged)
            self.pendingModifierGroup = activeGroup
            self.completedModifierGroup = activeGroup
            if !isPressed {
                self.activeButtonGroups[identifier] = nil
            }
            return
        }

        if let pendingModifierGroup, self.canAbsorbIntoPendingChord(pendingModifierGroup) {
            let merged = self.ordered(items: self.merged(items: items, into: self.storedItems(for: pendingModifierGroup)))
            self.groupItems[ObjectIdentifier(pendingModifierGroup)] = merged
            updateGroup(pendingModifierGroup, merged)
            self.completedModifierGroup = pendingModifierGroup
            if isPressed {
                self.activeButtonGroups[identifier] = pendingModifierGroup
            }
            return
        }

        let orderedItems = self.ordered(items: items)
        let group = appendGroup(orderedItems)
        self.groupItems[ObjectIdentifier(group)] = orderedItems
        self.completedModifierGroup = group
        if isPressed {
            self.activeButtonGroups[identifier] = group
        }
    }

    /// Only pure modifier previews can absorb later modifier-only updates.
    private func canAppendModifiers(to group: GroupView) -> Bool {
        let items = self.storedItems(for: group)
        return !items.isEmpty && items.allSatisfy(\.identity.isModifier)
    }

    /// Only a pure modifier preview can absorb the first non-modifier key in a chord.
    private func canAbsorbIntoPendingChord(_ group: GroupView) -> Bool {
        self.canAppendModifiers(to: group)
    }

    /// Existing chord groups may only receive modifier updates for modifiers they already show.
    private func canRefreshModifiers(in group: GroupView, with items: [Item]) -> Bool {
        let existingModifierIdentities = Set(
            self.storedItems(for: group)
                .filter { $0.identity.isModifier }
                .map(\.identity)
        )
        let incomingModifierIdentities = Set(
            items
                .filter { $0.identity.isModifier }
                .map(\.identity)
        )
        return !incomingModifierIdentities.isEmpty && incomingModifierIdentities.isSubset(of: existingModifierIdentities)
    }

    /// Tracked key updates may refresh existing modifiers, but cannot introduce new ones.
    private func permittedTrackedKeyItems(_ newItems: [Item], forExistingItems existingItems: [Item]) -> [Item] {
        let existingModifierIdentities = Set(
            existingItems
                .filter { $0.identity.isModifier }
                .map(\.identity)
        )

        return newItems.filter { item in
            !item.identity.isModifier || existingModifierIdentities.contains(item.identity)
        }
    }

    private func merged(items newItems: [Item], into existingItems: [Item]) -> [Item] {
        guard !existingItems.isEmpty else { return newItems }

        var merged = existingItems
        for item in newItems {
            if let index = merged.firstIndex(where: { $0.identity == item.identity }) {
                merged[index] = item
            } else {
                merged.append(item)
            }
        }
        return merged
    }

    private func ordered(items: [Item]) -> [Item] {
        let modifiers = items
            .filter { $0.identity.isModifier }
            .sorted {
                (
                    $0.identity.modifierKind?.canonicalDisplayOrderIndex ?? Int.max,
                    $0.identity.modifierLocation?.canonicalDisplayOrderIndex ?? Int.max
                ) < (
                    $1.identity.modifierKind?.canonicalDisplayOrderIndex ?? Int.max,
                    $1.identity.modifierLocation?.canonicalDisplayOrderIndex ?? Int.max
                )
            }
        let others = items.filter { !$0.identity.isModifier }
        return modifiers + others
    }
}
