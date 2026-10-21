//
//  DisplayTracker.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import CoreVideo
import Foundation

@MainActor
final class DisplayTracker {
    private let tick: @MainActor () -> Void
    private var cvLink: CVDisplayLink?
    private var generation: UInt64 = 0

    init(tick: @escaping @MainActor () -> Void) {
        self.tick = tick
    }

    func start() {
        guard self.cvLink == nil else { return }

        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let link else { return }

        self.generation &+= 1
        let generation = self.generation
        CVDisplayLinkSetOutputHandler(link) { [weak self] _, _, _, _, _ in
            Task { @MainActor [weak self] in
                guard let self, self.generation == generation else { return }
                self.tick()
            }
            return kCVReturnSuccess
        }
        self.cvLink = link
        CVDisplayLinkStart(link)
    }

    func stop() {
        self.generation &+= 1
        if let link = self.cvLink {
            CVDisplayLinkStop(link)
            self.cvLink = nil
        }
    }

    deinit {
        if let link = self.cvLink {
            CVDisplayLinkStop(link)
        }
    }
}
