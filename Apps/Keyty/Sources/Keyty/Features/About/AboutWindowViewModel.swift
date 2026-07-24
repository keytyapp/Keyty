//
//  AboutWindowViewModel.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Combine
import Foundation

@MainActor
final class AboutWindowViewModel: ObservableObject {
    let appName: String
    let versionString: String
    let license: [Section]
    let contributors: [Section]
    let credits: [Section]

    @Published var selectedTab: Tab = .license

    init(bundle: Bundle = .main) {
        self.appName = AppConstants.appName
        self.versionString = L10n.About.version(
            bundle.appVersionString,
            bundle.appBuildString
        )
        self.license = [
            Section(
                title: L10n.About.License.keytyTitle,
                subtitle: L10n.About.License.keytySubtitle,
                links: [
                    LinkItem(title: "GitHub", url: AppConstants.githubURL),
                    LinkItem(title: "Website", url: AppConstants.websiteURL)
                ],
                body: """
                The modern keyboard and mouse events visualizer for macOS.
                Copyright © 2026 Serhii Bykov.

                Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

                * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
                * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
                * Neither the name Keyty nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

                THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE.
                """
            )
        ]
        self.contributors = [
            Section(
                title: L10n.About.Contributors.title,
                subtitle: L10n.About.Contributors.subtitle,
                listItems: [
                    ListItem(
                        title: L10n.About.Contributors.serhiiBykov
                    ),
                    ListItem(
                        title: L10n.About.Contributors.yulliaBabichuk
                    ),
                    ListItem(
                        title: L10n.About.Contributors.oleksiiPetruk
                    ),
                    ListItem(
                        title: L10n.About.Contributors.serhiiButenko
                    )
                ]
            )
        ]
        self.credits = [
            Section(
                title: "Sparkle",
                subtitle: L10n.About.Credits.sparkleSubtitle,
                body: LicenseLoader.text(
                    named: "Sparkle",
                    trimmingLeadingLines: [
                        "Sparkle",
                        "The MIT License (MIT)"
                    ]
                )
            ),
            Section(
                title: "AppMover",
                subtitle: L10n.About.Credits.appMoverSubtitle,
                body: LicenseLoader.text(
                    named: "AppMover",
                    trimmingLeadingLines: [
                        "MIT License"
                    ]
                )
            ),
            Section(
                title: "ShortcutRecorder",
                subtitle: L10n.About.Credits.shortcutRecorderSubtitle,
                body: LicenseLoader.text(
                    named: "ShortcutRecorder",
                    trimmingLeadingLines: [
                        "Creative Commons Attribution 4.0 International Public License"
                    ]
                )
            )
        ]
    }

    var selectedSections: [Section] {
        switch self.selectedTab {
        case .license:
            self.license
        case .contributors:
            self.contributors
        case .credits:
            self.credits
        }
    }
}

extension AboutWindowViewModel {
    struct Section: Identifiable {
        let id = UUID()
        let title: String
        var subtitle: String = ""
        var links: [LinkItem] = []
        var listItems: [ListItem] = []
        var body: String = ""
    }

    struct LinkItem: Identifiable {
        let id = UUID()
        let title: String
        let url: URL
    }

    struct ListItem: Identifiable {
        let id = UUID()
        let title: String
        var subtitle: String = ""
    }

    enum Tab: CaseIterable, Identifiable {
        case license
        case contributors
        case credits

        var id: Self { self }

        var title: String {
            switch self {
            case .license:
                L10n.About.Tab.license
            case .contributors:
                L10n.About.Tab.contributors
            case .credits:
                L10n.About.Tab.credits
            }
        }
    }
}

extension AboutWindowViewModel {
    enum LicenseLoader {
    static func text(
        named resourceName: String,
        trimmingLeadingLines linesToTrim: [String] = [],
        bundle: Bundle = .main
    ) -> String {
        let candidates = [
            bundle.url(forResource: resourceName, withExtension: "txt", subdirectory: "AboutLicenses"),
            bundle.url(forResource: resourceName, withExtension: "txt")
        ]

        for candidate in candidates {
            guard let url = candidate else { continue }
            if let text = try? String(contentsOf: url, encoding: .utf8) {
                return Self.sanitized(text, trimmingLeadingLines: linesToTrim)
            }
        }

        return L10n.About.Credits.licenseMissing
    }

    private static func sanitized(_ text: String, trimmingLeadingLines linesToTrim: [String]) -> String {
        var lines = text.components(separatedBy: .newlines)

        while let first = lines.first, first.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.removeFirst()
        }

        for lineToTrim in linesToTrim {
            guard let first = lines.first else { break }
            if first.trimmingCharacters(in: .whitespacesAndNewlines) == lineToTrim {
                lines.removeFirst()
                while let next = lines.first, next.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    lines.removeFirst()
                }
            }
        }

        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    }
}
