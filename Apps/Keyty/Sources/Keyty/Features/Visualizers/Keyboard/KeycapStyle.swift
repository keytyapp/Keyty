//
//  KeycapStyle.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

enum KeycapStyle: Int, CaseIterable {
    case apple = 0
    case pbt = 1
    case minimal = 2
    case retro = 3
    case m0116 = 4

    static let `default`: KeycapStyle = .apple

    var title: String {
        switch self {
        case .apple: L10n.KeyboardVisualizer.Style.apple
        case .pbt:   L10n.KeyboardVisualizer.Style.pbt
        case .minimal: L10n.KeyboardVisualizer.Style.minimal
        case .retro: L10n.KeyboardVisualizer.Style.retro
        case .m0116: L10n.KeyboardVisualizer.Style.m0116
        }
    }
}
