//
//  AppConstants.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

enum AppConstants {
    private static let repositoryBaseURL = "https://github.com/keytyapp/Keyty"

    static var appName: String {
        Bundle.main.displayName ?? Bundle.main.name ?? "Keyty"
    }

    static let githubURL = URL(string: repositoryBaseURL)!
    static let permissionsDocumentationURL = URL(string: "\(repositoryBaseURL)/blob/main/Docs/PERMISSIONS.md")!
    static let websiteURL = URL(string: "https://keyty.app")!
    static let feedbackEmail = "support@keyty.app"
    static let feedbackURL = URL(string: "mailto:\(feedbackEmail)")!
}
