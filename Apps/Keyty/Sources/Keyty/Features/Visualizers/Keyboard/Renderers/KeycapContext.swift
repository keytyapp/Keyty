//
//  KeycapContext.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

struct KeycapContext {
    let item: KeycapItem
    let settings: KeyboardVisualizerSettings
}

extension KeycapContext {
    var appearance: KeycapAppearance {
        self.item.appearance
    }
}

extension KeycapContext {
    var appleAppearance: KeycapAppearance.Apple {
        if let appearance = self.appearance.apple {
            return appearance
        }
        return self.settings.theme.appearance(for: .apple).apple!
    }

    var pbtAppearance: KeycapAppearance.PBT {
        if let appearance = self.appearance.pbt {
            return appearance
        }
        return self.settings.theme.appearance(for: .pbt).pbt!
    }

    var minimalAppearance: KeycapAppearance.Minimal {
        if let appearance = self.appearance.minimal {
            return appearance
        }
        return self.settings.theme.appearance(for: .minimal).minimal!
    }

    var retroAppearance: KeycapAppearance.Retro {
        if let appearance = self.appearance.retro {
            return appearance
        }
        return self.settings.theme.appearance(for: .retro).retro!
    }
}
