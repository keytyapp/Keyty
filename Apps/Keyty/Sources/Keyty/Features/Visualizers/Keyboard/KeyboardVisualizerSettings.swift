//
//  KeyboardVisualizerSettings.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import Combine

protocol KeyboardVisualizerSettingsProtocol: AnyObject {
    var isEnabled: Bool { get set }
    var stackAxis: KeyboardVisualizerStackAxis { get set }
    var maxCount: Int { get set }
    var fadeDelay: CGFloat { get set }
    var fadeDuration: CGFloat { get set }
    var theme: KeyboardVisualizerTheme { get set }
    var legendColorMode: KeyboardLegendColorMode { get set }
    var customLegendColor: NSColor { get set }
    var usesCustomThemePalette: Bool { get set }
    var modifierTheme: KeyboardVisualizerTheme { get set }
    var specialTheme: KeyboardVisualizerTheme { get set }
    var mediaTheme: KeyboardVisualizerTheme { get set }
    var mouseTheme: KeyboardVisualizerTheme { get set }
    var groupBackgroundTheme: KeyboardVisualizerTheme { get set }
    var anchor: KeyboardVisualizerAnchor { get set }
    var screenID: CGDirectDisplayID { get set }
    var scale: CGFloat { get set }
    var windowPadding: CGFloat { get set }
    var style: KeycapStyle { get set }
    var onlyShowModifiedKeystrokes: Bool { get set }
    var showSpecialKeys: Bool { get set }
    var showMediaKeyButtons: Bool { get set }
    var showMouseEvents: Bool { get set }

    func registerDefaults()
}

final class KeyboardVisualizerSettings: KeyboardVisualizerSettingsProtocol, HasSettingsStore, PlacementReactiveSettings {
    static let minWindowPadding: CGFloat = Spacing.none
    static let maxWindowPadding: CGFloat = Spacing.grid(40)

    let store: KeyValueStore
    private var isEnabledSnapshot: Bool?
    private let isEnabledChangesSubject = PassthroughSubject<Bool, Never>()
    private let placementChangesSubject = PassthroughSubject<Void, Never>()
    private var storeChangesCancellable: AnyCancellable?

    var isEnabledChanges: AnyPublisher<Bool, Never> {
        self.isEnabledChangesSubject.eraseToAnyPublisher()
    }

    var placementChanges: AnyPublisher<Void, Never> {
        self.placementChangesSubject.eraseToAnyPublisher()
    }

    init(store: KeyValueStore = UserDefaultsStore()) {
        self.store = store
        self.storeChangesCancellable = self.store.changes
            .sink { [weak self] in
                self?.storeDidChange()
            }
        self.isEnabledSnapshot = self.isEnabled
    }

    func registerDefaults() {
        self.registerStoredDefaults()
        self.isEnabledSnapshot = self.isEnabled
    }

    /// Whether the keyboard overlay window should render input events.
    @Stored(.bool(KeyboardVisualizerSettingsKeys.isEnabled, default: true))
    var isEnabled: Bool

    @Stored(.custom(
        key: KeyboardVisualizerSettingsKeys.axis,
        default: .vertical,
        registrationValue: KeyboardVisualizerStackAxis.vertical.storedValue,
        read: { store, key, _ in
            KeyboardVisualizerStackAxis(storedValue: store.integer(forKey: key))
        },
        write: { store, key, value in
            store.set(value.storedValue, forKey: key)
        }
    ))
    var stackAxis: KeyboardVisualizerStackAxis

    /// Cross-axis alignment, derived from the anchor so groups hug the same edge the
    /// window is pinned to. The cross axis depends on the stacking axis: a vertical
    /// stack uses the anchor's horizontal side; a horizontal stack uses its vertical side
    /// (where AppKit y grows upward, so `.top` maps to `.trailing` and `.bottom` to `.leading`).
    var alignment: KeyboardVisualizerAlignment {
        switch stackAxis {
        case .vertical:
            switch anchor.horizontal {
            case .leading:  return .leading
            case .center:   return .center
            case .trailing: return .trailing
            }
        case .horizontal:
            switch anchor.vertical {
            case .top:    return .trailing
            case .middle: return .center
            case .bottom: return .leading
            }
        }
    }

    @Stored(.int(KeyboardVisualizerSettingsKeys.maxCount, default: KeyboardVisualizerSettingsKeys.defaultMaxCount))
    private var storedMaxCount: Int

    var maxCount: Int {
        get { self.storedMaxCount > 0 ? self.storedMaxCount : KeyboardVisualizerSettingsKeys.defaultMaxCount }
        set { self.storedMaxCount = max(KeyboardVisualizerSettingsKeys.minMaxCount, newValue) }
    }

    @Stored(.cgFloat(KeyboardVisualizerSettingsKeys.fadeDelay, default: 2.0))
    private var storedFadeDelay: CGFloat

    var fadeDelay: CGFloat {
        get { self.storedFadeDelay > 0 ? self.storedFadeDelay : 2.0 }
        set { self.storedFadeDelay = newValue }
    }

    @Stored(.cgFloat(KeyboardVisualizerSettingsKeys.fadeDuration, default: 0.2))
    private var storedFadeDuration: CGFloat

    var fadeDuration: CGFloat {
        get { self.storedFadeDuration >= 0 ? self.storedFadeDuration : 0.2 }
        set { self.storedFadeDuration = newValue }
    }

    /// Base theme. Applies to regular keys and — when `usesCustomThemePalette` is off — every key.
    @Stored(.enum(KeyboardVisualizerSettingsKeys.theme, default: .black))
    var theme: KeyboardVisualizerTheme

    /// Whether keycap legend drawing should use the theme-default color or a custom override.
    @Stored(.enum(KeyboardVisualizerSettingsKeys.legendColorMode, default: .automatic))
    var legendColorMode: KeyboardLegendColorMode

    /// User-selected override for text, glyph, and mouse icon color inside keycaps.
    @Stored(.color(KeyboardVisualizerSettingsKeys.customLegendColor, default: .white))
    var customLegendColor: NSColor

    /// When enabled, each key type draws from its own theme below; otherwise `theme` drives all.
    @Stored(.bool(KeyboardVisualizerSettingsKeys.usesCustomThemePalette, default: false))
    var usesCustomThemePalette: Bool

    @Stored(.enum(KeyboardVisualizerSettingsKeys.modifierTheme, default: .black))
    var modifierTheme: KeyboardVisualizerTheme

    @Stored(.enum(KeyboardVisualizerSettingsKeys.specialTheme, default: .black))
    var specialTheme: KeyboardVisualizerTheme

    @Stored(.enum(KeyboardVisualizerSettingsKeys.mediaTheme, default: .black))
    var mediaTheme: KeyboardVisualizerTheme

    @Stored(.enum(KeyboardVisualizerSettingsKeys.mouseTheme, default: .black))
    var mouseTheme: KeyboardVisualizerTheme

    @Stored(.enum(KeyboardVisualizerSettingsKeys.groupBackgroundTheme, default: .black))
    var groupBackgroundTheme: KeyboardVisualizerTheme

    @Stored(.enum(KeyboardVisualizerSettingsKeys.anchor, default: .default))
    var anchor: KeyboardVisualizerAnchor {
        didSet {
            self.placementChangesSubject.send(())
        }
    }

    /// Target display the window pins to, identified by `CGDirectDisplayID`. `0` means the
    /// main screen (and is the fallback whenever the stored display is not connected).
    @Stored(.custom(
        key: KeyboardVisualizerSettingsKeys.screenID,
        default: CGDirectDisplayID(0),
        registrationValue: 0,
        read: { store, key, _ in
            CGDirectDisplayID(store.integer(forKey: key))
        },
        write: { store, key, value in
            store.set(Int(value), forKey: key)
        }
    ))
    var screenID: CGDirectDisplayID {
        didSet {
            self.placementChangesSubject.send(())
        }
    }

    /// Uniform scale applied to the rendered keycaps, clamped to 50%–200% (1.0 == 100%).
    @Stored(.cgFloat(KeyboardVisualizerSettingsKeys.scale, default: 1.0))
    private var storedScale: CGFloat

    var scale: CGFloat {
        get {
            let value = self.storedScale > 0 ? self.storedScale : 1.0
            return min(max(value, 0.5), 2.0)
        }
        set {
            self.storedScale = min(max(newValue, 0.5), 2.0)
        }
    }

    /// Margin (in points) inset from the anchored screen edges,
    /// clamped to `minWindowPadding...maxWindowPadding`.
    @Stored(.cgFloat(KeyboardVisualizerSettingsKeys.windowPadding, default: Size.KeyboardVisualizer.windowPadding))
    private var storedWindowPadding: CGFloat

    var windowPadding: CGFloat {
        get {
            min(max(self.storedWindowPadding, Self.minWindowPadding), Self.maxWindowPadding)
        }
        set {
            self.storedWindowPadding = min(max(newValue, Self.minWindowPadding), Self.maxWindowPadding)
            self.placementChangesSubject.send(())
        }
    }

    /// Visual style of the rendered keycaps.
    @Stored(.enum(KeyboardVisualizerSettingsKeys.style, default: .default))
    var style: KeycapStyle

    /// Whether only keystrokes pressed with modifiers should be rendered.
    @Stored(.bool(KeyboardVisualizerSettingsKeys.onlyShowModifiedKeystrokes, default: false))
    var onlyShowModifiedKeystrokes: Bool

    /// Whether non-text keyboard keys (tab, return, arrows, fn, F-keys, etc.) should be rendered.
    @Stored(.bool(KeyboardVisualizerSettingsKeys.showSpecialKeys, default: true))
    var showSpecialKeys: Bool

    /// Whether media-key button presses should be rendered in the keyboard overlay.
    @Stored(.bool(KeyboardVisualizerSettingsKeys.showMediaKeyButtons, default: true))
    var showMediaKeyButtons: Bool

    /// Whether mouse clicks and wheel events should be rendered in the keyboard overlay.
    @Stored(.bool(KeyboardVisualizerSettingsKeys.showMouseEvents, default: true))
    var showMouseEvents: Bool

    var themeTokens: KeycapThemeTokens {
        self.theme.tokens(legendColorOverride: self.resolvedLegendColorOverride)
    }

    var appearance: KeycapAppearance {
        self.theme.appearance(for: self.style, legendColorOverride: self.resolvedLegendColorOverride)
    }

    /// Resolves per-key-type appearance. When `usesCustomThemePalette` is off, every category
    /// (and the group background) collapses to the base `theme` — identical to legacy behavior.
    var palette: KeycapThemePalette {
        let base = self.theme
        func resolve(_ specific: KeyboardVisualizerTheme) -> KeyboardVisualizerTheme {
            self.usesCustomThemePalette ? specific : base
        }
        return KeycapThemePalette(
            style: self.style,
            themes: [
                .regular:  base,
                .modifier: resolve(self.modifierTheme),
                .special:  resolve(self.specialTheme),
                .media:    resolve(self.mediaTheme),
                .mouse:    resolve(self.mouseTheme),
            ],
            groupBackgroundTheme: resolve(self.groupBackgroundTheme),
            legendColorOverride: self.resolvedLegendColorOverride
        )
    }

    /// Appearance whose group background/stroke panels a rendered group.
    var groupAppearance: KeycapAppearance {
        self.palette.groupAppearance
    }

    private var resolvedLegendColorOverride: NSColor? {
        guard self.usesCustomThemePalette else {
            return nil
        }

        switch self.legendColorMode {
        case .automatic:
            return nil
        case .custom:
            return self.customLegendColor
        }
    }

    private func storeDidChange() {
        let isEnabled = self.isEnabled
        guard isEnabled != self.isEnabledSnapshot else { return }
        self.isEnabledSnapshot = isEnabled
        self.isEnabledChangesSubject.send(isEnabled)
    }
}
