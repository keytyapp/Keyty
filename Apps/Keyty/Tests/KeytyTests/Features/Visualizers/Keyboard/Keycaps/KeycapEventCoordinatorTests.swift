//
//  KeycapEventCoordinatorTests.swift
//  KeytyTests
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import XCTest
@testable import Keyty

final class KeycapEventCoordinatorTests: XCTestCase {
    func testFlagsChangedStartsNewGroupAfterRegularKeyGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleTrackedKey(
            keyCode: 8,
            isKeyDown: true,
            items: [TestItem(identity: .keyCode(8))],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 2)
        XCTAssertEqual(appendedGroups[0].map(\.identity), [.keyCode(8)])
        XCTAssertEqual(appendedGroups[1].map(\.identity), [.modifier(.leftCommand)])
        XCTAssertTrue(updatedGroups.isEmpty)
    }

    func testFlagsChangedContinuesExistingModifierGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command, .shift],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 1)
        XCTAssertEqual(updatedGroups.count, 1)
        XCTAssertEqual(updatedGroups[0].map(\.identity), [.modifier(.leftCommand), .modifier(.leftShift)])
    }

    func testTrackedKeyUpdateDoesNotAppendLaterModifierToExistingKeyGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleTrackedKey(
            keyCode: 8,
            isKeyDown: true,
            items: [TestItem(identity: .keyCode(8))],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleTrackedKey(
            keyCode: 8,
            isKeyDown: false,
            items: [
                TestItem(identity: .modifier(.leftCommand)),
                TestItem(identity: .keyCode(8))
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 2)
        XCTAssertEqual(appendedGroups[0].map(\.identity), [.keyCode(8)])
        XCTAssertEqual(appendedGroups[1].map(\.identity), [.modifier(.leftCommand)])
        XCTAssertEqual(updatedGroups.count, 1)
        XCTAssertEqual(updatedGroups[0].map(\.identity), [.keyCode(8)])
    }

    func testFlagsChangedDoesNotMergeNewModifierIntoExistingPlainKeyGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleTrackedKey(
            keyCode: 1,
            isKeyDown: true,
            items: [TestItem(identity: .keyCode(1), isPressed: true)],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 2)
        XCTAssertEqual(appendedGroups[0].map(\.identity), [.keyCode(1)])
        XCTAssertEqual(appendedGroups[1].map(\.identity), [.modifier(.leftCommand)])
        XCTAssertTrue(updatedGroups.isEmpty)
    }

    func testModifierReleaseUpdatesExistingChordGroupInsteadOfAppendingNewGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleTrackedKey(
            keyCode: 8,
            isKeyDown: true,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .keyCode(8), isPressed: true)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [],
            releasedTrackedFlags: [.command],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 1)
        XCTAssertEqual(updatedGroups.count, 2)
        XCTAssertEqual(updatedGroups[0].map(\.identity), [.modifier(.leftCommand), .keyCode(8)])
        XCTAssertEqual(updatedGroups[1].map(\.identity), [.modifier(.leftCommand), .keyCode(8)])
        XCTAssertEqual(updatedGroups[1].first(where: { $0.identity == .modifier(.leftCommand) })?.isPressed, false)
    }

    func testNextModifiedKeyStartsNewGroupWhileModifiersRemainHeld() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command, .shift],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleTrackedKey(
            keyCode: 29,
            isKeyDown: true,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .modifier(.leftShift), isPressed: true),
                TestItem(identity: .keyCode(29), isPressed: true)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleTrackedKey(
            keyCode: 29,
            isKeyDown: false,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .modifier(.leftShift), isPressed: true),
                TestItem(identity: .keyCode(29), isPressed: false)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleTrackedKey(
            keyCode: 18,
            isKeyDown: true,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .modifier(.leftShift), isPressed: true),
                TestItem(identity: .keyCode(18), isPressed: true)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 2)
        XCTAssertEqual(appendedGroups[0].map(\.identity), [.modifier(.leftCommand), .modifier(.leftShift)])
        XCTAssertEqual(updatedGroups[0].map(\.identity), [.modifier(.leftCommand), .modifier(.leftShift), .keyCode(29)])
        XCTAssertEqual(updatedGroups[1].map(\.identity), [.modifier(.leftCommand), .modifier(.leftShift), .keyCode(29)])
        XCTAssertEqual(appendedGroups[1].map(\.identity), [.modifier(.leftCommand), .modifier(.leftShift), .keyCode(18)])
    }

    func testStandaloneItemAbsorbsExistingModifierGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command, .shift],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleStandalone(
            items: [TestItem(identity: .mouse(.leftButton))],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 1)
        XCTAssertEqual(appendedGroups[0].map(\.identity), [.modifier(.leftCommand), .modifier(.leftShift)])
        XCTAssertEqual(updatedGroups.count, 1)
        XCTAssertEqual(updatedGroups[0].map(\.identity), [.modifier(.leftCommand), .modifier(.leftShift), .mouse(.leftButton)])
    }

    func testMouseButtonReleaseUpdatesExistingChordGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleMouseButton(
            kind: .leftButton,
            isPressed: true,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .mouse(.leftButton), isPressed: true)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleMouseButton(
            kind: .leftButton,
            isPressed: false,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .mouse(.leftButton), isPressed: false)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 1)
        XCTAssertEqual(appendedGroups[0].map(\.identity), [.modifier(.leftCommand)])
        XCTAssertEqual(updatedGroups.count, 2)
        XCTAssertEqual(updatedGroups[0].map(\.identity), [.modifier(.leftCommand), .mouse(.leftButton)])
        XCTAssertEqual(updatedGroups[0].first(where: { $0.identity == .mouse(.leftButton) })?.isPressed, true)
        XCTAssertEqual(updatedGroups[1].map(\.identity), [.modifier(.leftCommand), .mouse(.leftButton)])
        XCTAssertEqual(updatedGroups[1].first(where: { $0.identity == .mouse(.leftButton) })?.isPressed, false)
    }

    func testMediaKeyReleaseUpdatesExistingGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleMediaKey(
            kind: .play,
            isPressed: true,
            items: [TestItem(identity: .media(.play), isPressed: true)],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleMediaKey(
            kind: .play,
            isPressed: false,
            items: [TestItem(identity: .media(.play), isPressed: false)],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 1)
        XCTAssertEqual(appendedGroups[0].map(\.identity), [.media(.play)])
        XCTAssertEqual(appendedGroups[0].first?.isPressed, true)
        XCTAssertEqual(updatedGroups.count, 1)
        XCTAssertEqual(updatedGroups[0].map(\.identity), [.media(.play)])
        XCTAssertEqual(updatedGroups[0].first?.isPressed, false)
    }

    func testMediaKeyReleaseUpdatesExistingChordGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleMediaKey(
            kind: .play,
            isPressed: true,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .media(.play), isPressed: true)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleMediaKey(
            kind: .play,
            isPressed: false,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .media(.play), isPressed: false)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 1)
        XCTAssertEqual(appendedGroups[0].map(\.identity), [.modifier(.leftCommand)])
        XCTAssertEqual(updatedGroups.count, 2)
        XCTAssertEqual(updatedGroups[0].map(\.identity), [.modifier(.leftCommand), .media(.play)])
        XCTAssertEqual(updatedGroups[0].first(where: { $0.identity == .media(.play) })?.isPressed, true)
        XCTAssertEqual(updatedGroups[1].map(\.identity), [.modifier(.leftCommand), .media(.play)])
        XCTAssertEqual(updatedGroups[1].first(where: { $0.identity == .media(.play) })?.isPressed, false)
    }

    func testRemoveGroupClearsTrackedKeyState() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        let removedGroup = TestGroupView()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleTrackedKey(
            keyCode: 8,
            isKeyDown: true,
            items: [TestItem(identity: .keyCode(8), isPressed: true)],
            appendGroup: {
                appendedGroups.append($0)
                return removedGroup
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.removeGroup(removedGroup)

        coordinator.handleTrackedKey(
            keyCode: 8,
            isKeyDown: false,
            items: [TestItem(identity: .keyCode(8), isPressed: false)],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 2)
        XCTAssertTrue(updatedGroups.isEmpty)
        XCTAssertEqual(appendedGroups[1].map(\.identity), [.keyCode(8)])
        XCTAssertEqual(appendedGroups[1].first?.isPressed, false)
    }

    func testRemoveGroupClearsTrackedMouseState() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        let removedGroup = TestGroupView()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleMouseButton(
            kind: .leftButton,
            isPressed: true,
            items: [TestItem(identity: .mouse(.leftButton), isPressed: true)],
            appendGroup: {
                appendedGroups.append($0)
                return removedGroup
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.removeGroup(removedGroup)

        coordinator.handleMouseButton(
            kind: .leftButton,
            isPressed: false,
            items: [TestItem(identity: .mouse(.leftButton), isPressed: false)],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 2)
        XCTAssertTrue(updatedGroups.isEmpty)
        XCTAssertEqual(appendedGroups[1].map(\.identity), [.mouse(.leftButton)])
        XCTAssertEqual(appendedGroups[1].first?.isPressed, false)
    }

    func testRemoveGroupClearsTrackedMediaState() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        let removedGroup = TestGroupView()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleMediaKey(
            kind: .play,
            isPressed: true,
            items: [TestItem(identity: .media(.play), isPressed: true)],
            appendGroup: {
                appendedGroups.append($0)
                return removedGroup
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.removeGroup(removedGroup)

        coordinator.handleMediaKey(
            kind: .play,
            isPressed: false,
            items: [TestItem(identity: .media(.play), isPressed: false)],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 2)
        XCTAssertTrue(updatedGroups.isEmpty)
        XCTAssertEqual(appendedGroups[1].map(\.identity), [.media(.play)])
        XCTAssertEqual(appendedGroups[1].first?.isPressed, false)
    }

    func testMediaKeyAppendCanRemoveExistingTrackedGroup() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        let removedGroup = TestGroupView()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleMediaKey(
            kind: .play,
            isPressed: true,
            items: [TestItem(identity: .media(.play), isPressed: true)],
            appendGroup: {
                appendedGroups.append($0)
                return removedGroup
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleMediaKey(
            kind: .next,
            isPressed: true,
            items: [TestItem(identity: .media(.next), isPressed: true)],
            appendGroup: {
                coordinator.removeGroup(removedGroup)
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.handleMediaKey(
            kind: .play,
            isPressed: false,
            items: [TestItem(identity: .media(.play), isPressed: false)],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 3)
        XCTAssertTrue(updatedGroups.isEmpty)
        XCTAssertEqual(appendedGroups[2].map(\.identity), [.media(.play)])
        XCTAssertEqual(appendedGroups[2].first?.isPressed, false)
    }

    func testRemoveGroupClearsPendingModifierState() {
        let coordinator = KeycapEventCoordinator<TestGroupView, TestItem>()
        let removedGroup = TestGroupView()
        var appendedGroups: [[TestItem]] = []
        var updatedGroups: [[TestItem]] = []

        coordinator.handleFlagsChanged(
            currentTrackedFlags: [.command],
            releasedTrackedFlags: [],
            buildItems: { currentFlags, releasedFlags in
                Self.modifierItems(currentFlags: currentFlags, releasedFlags: releasedFlags)
            },
            appendGroup: {
                appendedGroups.append($0)
                return removedGroup
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        coordinator.removeGroup(removedGroup)

        coordinator.handleTrackedKey(
            keyCode: 8,
            isKeyDown: true,
            items: [
                TestItem(identity: .modifier(.leftCommand), isPressed: true),
                TestItem(identity: .keyCode(8), isPressed: true)
            ],
            appendGroup: {
                appendedGroups.append($0)
                return TestGroupView()
            },
            updateGroup: { _, items in
                updatedGroups.append(items)
            }
        )

        XCTAssertEqual(appendedGroups.count, 2)
        XCTAssertTrue(updatedGroups.isEmpty)
        XCTAssertEqual(appendedGroups[1].map(\.identity), [.modifier(.leftCommand), .keyCode(8)])
    }

    private static func modifierItems(
        currentFlags: NSEvent.ModifierFlags,
        releasedFlags: NSEvent.ModifierFlags
    ) -> [TestItem] {
        var items: [TestItem] = []
        if currentFlags.contains(.command) || releasedFlags.contains(.command) {
            items.append(TestItem(identity: .modifier(.leftCommand), isPressed: currentFlags.contains(.command)))
        }
        if currentFlags.contains(.shift) || releasedFlags.contains(.shift) {
            items.append(TestItem(identity: .modifier(.leftShift), isPressed: currentFlags.contains(.shift)))
        }
        if currentFlags.contains(.option) || releasedFlags.contains(.option) {
            items.append(TestItem(identity: .modifier(.leftOption), isPressed: currentFlags.contains(.option)))
        }
        if currentFlags.contains(.control) || releasedFlags.contains(.control) {
            items.append(TestItem(identity: .modifier(.leftControl), isPressed: currentFlags.contains(.control)))
        }
        return items
    }
}

private final class TestGroupView {}

private struct TestItem: KeycapGroupItem {
    let identity: KeycapIdentity
    let isPressed: Bool

    init(identity: KeycapIdentity, isPressed: Bool = false) {
        self.identity = identity
        self.isPressed = isPressed
    }
}
