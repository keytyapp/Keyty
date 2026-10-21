//
//  ShortcutManager.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa
import ShortcutRecorder

/// Manages the toggle-capturing shortcut across persistence, menu presentation, recorder validation, and global registration.
final class ShortcutManager: NSObject {
    /// The latest shortcut validation error shown in settings, or `nil` when the current shortcut is valid.
    private(set) var shortcutValidationMessage: String? {
        didSet {
            guard oldValue != self.shortcutValidationMessage else { return }
            self.onShortcutValidationMessageChanged?(self.shortcutValidationMessage)
        }
    }

    /// Called when `shortcutValidationMessage` changes.
    var onShortcutValidationMessageChanged: ((String?) -> Void)?

    private let settings: any ShortcutSettingsProtocol
    private let globalShortcutMonitor: any GlobalShortcutMonitoring
    private let shortcutValidator: any ShortcutValidating
    private let menuItemPresenter: any ShortcutMenuItemPresenting
    private let onToggleCapturingShortcut: () -> Void
    private var _toggleCapturingShortcut: Shortcut?
    private var toggleCapturingShortcutAction: ShortcutAction?

    /// The shortcut assigned to toggle capturing, loaded from settings on first read and persisted on update.
    var toggleCapturingShortcut: Shortcut? {
        get {
            if self._toggleCapturingShortcut == nil {
                self._toggleCapturingShortcut = self.shortcutFromSettings()
            }
            return self._toggleCapturingShortcut
        }
        set {
            self.setToggleCapturingShortcut(newValue)
        }
    }

    init(
        settings: any ShortcutSettingsProtocol = ShortcutSettings(),
        globalShortcutMonitor: any GlobalShortcutMonitoring = GlobalShortcutMonitor.shared,
        shortcutValidator: any ShortcutValidating = ShortcutValidator(),
        menuItemPresenter: any ShortcutMenuItemPresenting,
        onToggleCapturingShortcut: @escaping () -> Void
    ) {
        self.settings = settings
        self.globalShortcutMonitor = globalShortcutMonitor
        self.shortcutValidator = shortcutValidator
        self.menuItemPresenter = menuItemPresenter
        self.onToggleCapturingShortcut = onToggleCapturingShortcut
        super.init()
        self.refreshMenuItems()
        self.refreshGlobalShortcutIfNeeded()
    }

    deinit {
        if let action = self.toggleCapturingShortcutAction {
            self.globalShortcutMonitor.removeAction(action)
        }
    }

    @MainActor
    func configureToggleShortcutRecorder(_ recorder: RecorderControl) {
        recorder.delegate = self
        recorder.objectValue = self.toggleCapturingShortcut
    }

    func refreshMenuItems() {
        self.menuItemPresenter.displayShortcut(self.toggleCapturingShortcut)
    }
}

// MARK: - Logic
private extension ShortcutManager {
    private func shortcutFromSettings() -> Shortcut? {
        guard let data = self.settings.capturingHotKeyData else {
            return ShortcutArchiver.defaultShortcut()
        }
        return ShortcutArchiver.shortcut(from: data) ?? ShortcutArchiver.defaultShortcut()
    }

    private func persistShortcut(_ shortcut: Shortcut?) -> Shortcut? {
        guard let shortcut else {
            self.settings.capturingHotKeyData = nil
            return nil
        }

        do {
            self.settings.capturingHotKeyData = try ShortcutArchiver.data(for: shortcut)
            return shortcut
        } catch {
            return self.shortcutFromSettings()
        }
    }

    private func setToggleCapturingShortcut(_ shortcut: Shortcut?) {
        if let shortcut, let validationMessage = self.shortcutValidator.validationMessage(for: shortcut) {
            self.shortcutValidationMessage = validationMessage
            return
        }

        let currentShortcut = self.toggleCapturingShortcut
        let persistedShortcut = self.persistShortcut(shortcut)
        self.shortcutValidationMessage = nil

        guard currentShortcut != persistedShortcut else {
            self._toggleCapturingShortcut = persistedShortcut
            return
        }

        self._toggleCapturingShortcut = persistedShortcut
        self.refreshMenuItems()
        self.refreshGlobalShortcutIfNeeded()
    }

    private func refreshGlobalShortcutIfNeeded() {
        if let action = self.toggleCapturingShortcutAction {
            self.globalShortcutMonitor.removeAction(action)
        }

        guard let shortcut = self.toggleCapturingShortcut else {
            self.toggleCapturingShortcutAction = nil
            return
        }

        if let validationMessage = self.shortcutValidator.validationMessage(for: shortcut) {
            self.shortcutValidationMessage = validationMessage
            self.toggleCapturingShortcutAction = nil
            return
        }

        self.shortcutValidationMessage = nil
        let action = ShortcutAction(shortcut: shortcut) { [weak self] _ in
            self?.onToggleCapturingShortcut()
            return true
        }
        self.toggleCapturingShortcutAction = action
        self.globalShortcutMonitor.addAction(action, forKeyEvent: .down)
    }
}

// MARK: - SRRecorderControlDelegate
extension ShortcutManager: @MainActor RecorderControlDelegate {
    @objc(recorderControl:canRecordShortcut:)
    @MainActor
    func recorderControl(_ control: RecorderControl, canRecord shortcut: Shortcut) -> Bool {
        if let validationMessage = self.shortcutValidator.validationMessage(for: shortcut) {
            self.shortcutValidationMessage = validationMessage
            return false
        }

        self.shortcutValidationMessage = nil
        return true
    }

    @MainActor @objc func recorderControlDidEndRecording(_ control: RecorderControl) {
        guard let newShortcut = control.objectValue else {
            self.toggleCapturingShortcut = nil
            return
        }
        self.toggleCapturingShortcut = newShortcut
        control.objectValue = newShortcut
    }
}
