//
//  KeycapRendererFactory.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

enum KeycapRendererFactory {
    static func makeRenderer(for item: KeycapItem, settings: KeyboardVisualizerSettings) -> any KeycapRendering {
        switch settings.style {
        case .apple:
            return AppleKeycapRenderer()
        case .pbt:
            return PBTKeycapRenderer()
        case .minimal:
            return MinimalKeycapRenderer()
        case .retro:
            return RetroKeycapRenderer()
        case .m0116:
            return M0116KeycapRenderer()
        }
    }
}
