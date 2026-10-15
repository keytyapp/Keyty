//
//  DisplayTracker.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreVideo
import Foundation

final class DisplayTracker {
    private let tick: () -> Void
    private var cvLink: CVDisplayLink?

    init(tick: @escaping () -> Void) {
        self.tick = tick
    }

    func start() {
        CVDisplayLinkCreateWithActiveCGDisplays(&self.cvLink)
        guard let link = self.cvLink else { return }
        CVDisplayLinkSetOutputHandler(link) { [weak self] _, _, _, _, _ in
            DispatchQueue.main.async { self?.tick() }
            return kCVReturnSuccess
        }
        CVDisplayLinkStart(link)
    }

    func stop() {
        guard let link = self.cvLink else { return }
        CVDisplayLinkStop(link)
        self.cvLink = nil
    }
}
